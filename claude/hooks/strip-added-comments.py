#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11,<3.14"
# dependencies = ["tree-sitter>=0.23", "tree-sitter-language-pack>=0.9"]
# ///
"""Stop hook: delete the comments Claude added during the turn.

Pairs with snapshot-edited-file.sh, which stores each touched file's pre-edit
content under ~/.claude/comment-stripper/<session>/. Here we diff old vs new,
parse the new file with tree-sitter, and remove only those comment nodes that
sit entirely inside lines the diff marks as added. Comments that were already in
the file survive, as do load-bearing ones (linter pragmas, build tags, licenses).

Set CLAUDE_KEEP_COMMENTS=1 to turn the whole thing off for a session.
"""

import difflib
import json
import os
import re
import shutil
import sys
import time
from collections import Counter
from pathlib import Path

KEEP_TODOS = False

STATE_ROOT = Path.home() / ".claude" / "comment-stripper"
STALE_AFTER = 3 * 24 * 3600

EXT_LANG = {
    ".py": "python", ".pyi": "python",
    ".ts": "typescript", ".mts": "typescript", ".cts": "typescript",
    ".tsx": "tsx", ".jsx": "javascript",
    ".js": "javascript", ".mjs": "javascript", ".cjs": "javascript",
    ".go": "go", ".rs": "rust",
    ".tf": "hcl", ".tfvars": "hcl", ".hcl": "hcl",
    ".yaml": "yaml", ".yml": "yaml",
    ".sh": "bash", ".bash": "bash", ".zsh": "bash",
    ".c": "c", ".h": "c",
    ".cc": "cpp", ".cpp": "cpp", ".cxx": "cpp", ".hpp": "cpp", ".hh": "cpp",
    ".java": "java", ".kt": "kotlin", ".kts": "kotlin", ".swift": "swift",
    ".rb": "ruby", ".php": "php", ".lua": "lua", ".scala": "scala",
    ".cs": "csharp", ".ex": "elixir", ".exs": "elixir", ".zig": "zig",
    ".css": "css", ".scss": "scss", ".sql": "sql", ".toml": "toml",
    ".proto": "proto", ".graphql": "graphql", ".gql": "graphql",
    ".vue": "vue", ".svelte": "svelte", ".dart": "dart", ".hs": "haskell",
    ".nix": "nix", ".pl": "perl", ".r": "r", ".sol": "solidity",
    ".gradle": "groovy", ".groovy": "groovy", ".erl": "erlang",
    ".clj": "clojure", ".cljs": "clojure", ".ml": "ocaml",
}

NAME_LANG = {
    "dockerfile": "dockerfile",
    "makefile": "make",
    "justfile": "just",
}

_KEEP = [
    r"^#!",
    r"coding[:=]\s*[-\w.]+",
    r"\bnoqa\b",
    r"\btype:\s*ignore\b",
    r"\b(pragma|pylint|mypy|ruff|flake8|pyright|pytype):",
    r"\b(nosec|nosemgrep|noinspection)\b",
    r"\bfmt:\s*(on|off|skip)\b",
    r"\beslint-(disable|enable)",
    r"\bts-(ignore|expect-error|nocheck|check)\b",
    r"\b(prettier-ignore|biome-ignore|dprint-ignore|deno-lint-ignore|deno-fmt-ignore)\b",
    r"\b(istanbul|c8|v8)\s+ignore\b",
    r"\bgo:[a-z]+",
    r"\+build\b",
    r"\bnolint\b",
    r"\b(tflint-ignore|tfsec:|checkov:skip|terraform:)\b",
    r"\bshellcheck\s+(disable|source|shell|enable)\b",
    r"\bSPDX-License-Identifier\b",
    r"\bcopyright\b",
    r"\blicen[cs]ed under\b",
    r"@(jsx|jsxImportSource|jsxRuntime|flow|license|preserve|generated)\b",
    r"^\s*/\*\s*(global|eslint|exported)\b",
    r"<reference\s",
    r"\bsourceMappingURL\b",
    r"\bcodegen\b|\bDO NOT EDIT\b|\bauto-?generated\b",
    r"\blanguage=\w+",
    r"\bcspell:|\bspell-checker:",
]
if KEEP_TODOS:
    _KEEP.append(r"\b(TODO|FIXME|XXX|HACK|NOTE!|WARNING!)\b")

KEEP_RE = re.compile("|".join(_KEEP), re.IGNORECASE)


def language_for(path: Path) -> str | None:
    lang = EXT_LANG.get(path.suffix.lower())
    if lang:
        return lang
    return NAME_LANG.get(path.name.lower())


def added_rows(old_text: str, new_text: str) -> set[int]:
    """0-indexed rows of new_text that the diff considers new."""
    old_lines = old_text.splitlines()
    new_lines = new_text.splitlines()
    rows: set[int] = set()
    matcher = difflib.SequenceMatcher(None, old_lines, new_lines, autojunk=False)
    for tag, _i1, _i2, j1, j2 in matcher.get_opcodes():
        if tag in ("insert", "replace"):
            rows.update(range(j1, j2))
    return rows


def comment_nodes(root):
    """Top-level comment nodes; nested ones are already covered by their parent."""
    out = []
    stack = [root]
    while stack:
        node = stack.pop()
        if node.type.endswith("comment"):
            out.append(node)
            continue
        stack.extend(node.children)
    return out


def normalize(text: str) -> str:
    return " ".join(text.split())


def previous_comments(old_text: str, parser) -> Counter:
    """Comment texts already in the file before Claude touched it."""
    try:
        root = parser.parse(old_text.encode("utf-8")).root_node
    except Exception:
        return Counter()
    src = old_text.encode("utf-8")
    return Counter(
        normalize(src[n.start_byte:n.end_byte].decode("utf-8", "replace"))
        for n in comment_nodes(root)
    )


def error_count(root) -> int:
    if not root.has_error:
        return 0
    n = 0
    stack = [root]
    while stack:
        node = stack.pop()
        if node.type == "ERROR" or node.is_missing:
            n += 1
        stack.extend(node.children)
    return n


def strip_file(path: Path, old_text: str, parser_for) -> int:
    """Rewrite path without Claude's new comments. Returns comments removed."""
    try:
        new_text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return 0
    if new_text == old_text:
        return 0

    lang = language_for(path)
    if lang is None:
        return 0
    parser = parser_for(lang)
    if parser is None:
        return 0

    src = new_text.encode("utf-8")
    tree = parser.parse(src)
    before_errors = error_count(tree.root_node)

    fresh = added_rows(old_text, new_text)
    if not fresh:
        return 0
    # Editing a line that already carried a comment makes difflib call that row
    # added. Anything whose text was in the file before is the user's, not ours.
    preexisting = previous_comments(old_text, parser)

    lines = new_text.splitlines(keepends=True)
    line_start = []
    offset = 0
    for line in lines:
        line_start.append(offset)
        offset += len(line.encode("utf-8"))

    drop_rows: set[int] = set()
    edits: dict[int, list[tuple[int, int]]] = {}
    removed = 0

    for node in comment_nodes(tree.root_node):
        r0, r1 = node.start_point[0], node.end_point[0]
        if r1 >= len(lines):
            continue
        if any(r not in fresh for r in range(r0, r1 + 1)):
            continue
        text = src[node.start_byte:node.end_byte].decode("utf-8", "replace")
        if KEEP_RE.search(text):
            continue
        key = normalize(text)
        if preexisting[key]:
            preexisting[key] -= 1
            continue

        head = src[line_start[r0]:node.start_byte]
        tail_end = line_start[r1] + len(lines[r1].encode("utf-8"))
        tail = src[node.end_byte:tail_end]
        standalone = head.strip() == b"" and tail.strip() == b""

        if standalone:
            drop_rows.update(range(r0, r1 + 1))
            removed += 1
        elif r0 == r1:
            edits.setdefault(r0, []).append((node.start_byte, node.end_byte))
            removed += 1
        # Inline block comment spanning several lines: rare, not worth the risk.

    if not removed:
        return 0

    for row, spans in edits.items():
        raw = lines[row].encode("utf-8")
        base = line_start[row]
        for start, end in sorted(spans, reverse=True):
            raw = raw[: start - base] + raw[end - base :]
        rebuilt = raw.decode("utf-8")
        body, sep, eol = rebuilt.partition("\n")
        body = body.rstrip()
        if body.strip() == "":
            drop_rows.add(row)
        else:
            lines[row] = body + sep + eol

    kept = [(i, l) for i, l in enumerate(lines) if i not in drop_rows]
    result: list[str] = []
    for idx, (row, line) in enumerate(kept):
        blank = line.strip() == ""
        if blank and result and result[-1].strip() == "" and row - kept[idx - 1][0] > 1:
            continue  # blank / removed comment / blank -> single blank
        result.append(line)

    out = "".join(result)
    if out == new_text:
        return 0
    if error_count(parser.parse(out.encode("utf-8")).root_node) > before_errors:
        return 0

    path.write_text(out, encoding="utf-8")
    return removed


def sweep_stale():
    now = time.time()
    for d in STATE_ROOT.iterdir():
        if d.is_dir() and now - d.stat().st_mtime > STALE_AFTER:
            shutil.rmtree(d, ignore_errors=True)


def main() -> int:
    if os.environ.get("CLAUDE_KEEP_COMMENTS"):
        return 0
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}
    session = payload.get("session_id") or "nosession"
    state = STATE_ROOT / session
    if not state.is_dir():
        return 0

    entries = sorted(state.glob("*.path"))
    if not entries:
        shutil.rmtree(state, ignore_errors=True)
        return 0

    from tree_sitter_language_pack import get_parser

    cache: dict[str, object] = {}

    def parser_for(lang: str):
        if lang not in cache:
            try:
                cache[lang] = get_parser(lang)
            except Exception:
                cache[lang] = None
        return cache[lang]

    touched: list[tuple[str, int]] = []
    for marker in entries:
        orig = marker.with_suffix(".orig")
        if not orig.exists():
            continue
        path = Path(marker.read_text(encoding="utf-8"))
        if not path.is_file():
            continue
        try:
            old_text = orig.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        try:
            n = strip_file(path, old_text, parser_for)
        except Exception:
            continue
        if n:
            touched.append((path.name, n))

    shutil.rmtree(state, ignore_errors=True)
    try:
        sweep_stale()
    except OSError:
        pass

    if touched:
        total = sum(n for _, n in touched)
        where = ", ".join(f"{name} ({n})" for name, n in touched[:6])
        if len(touched) > 6:
            where += f", +{len(touched) - 6} more"
        print(json.dumps({
            "systemMessage": f"Stripped {total} added comment(s): {where}",
            "suppressOutput": True,
        }))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)
