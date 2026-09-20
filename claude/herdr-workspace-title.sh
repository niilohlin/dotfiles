#!/usr/bin/env bash
# On Stop, if the herdr workspace still carries its default label, generate a
# short (<=17 char) label from the session transcript via a fast LLM call and
# rename the workspace to it. Wired as an async Stop hook so it never blocks the
# UI. Reads the Stop hook payload (with .transcript_path) as JSON on stdin.

# Recursion guard: the `claude -p` call below inherits this herdr env; without
# the guard its own Stop hooks would re-enter here (and rename our workspace).
[ -n "$CLAUDE_HERDR_TITLING" ] && exit 0
[ -z "$HERDR_WORKSPACE_ID" ] && exit 0
herdr=${HERDR_BIN_PATH:-herdr}
command -v "$herdr" >/dev/null 2>&1 || exit 0
command -v claude >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)

ws=$("$herdr" workspace get "$HERDR_WORKSPACE_ID" 2>/dev/null) || exit 0
current=$(printf '%s' "$ws" | jq -r '.result.workspace.label // empty' 2>/dev/null)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

# herdr names a new workspace after its directory, so a label still matching the
# basename (or a bare number) means nobody has titled this workspace yet.
dirname=$(basename "$cwd")
case "$current" in
  '' | "$dirname") ;;
  *[!0-9]*) exit 0 ;;
esac

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# Pull recent human/assistant text out of the JSONL transcript.
convo=$(tail -n 120 "$transcript" 2>/dev/null | jq -r '
  select(.type == "user" or .type == "assistant")
  | .message.content as $c
  | if ($c | type) == "string" then $c
    elif ($c | type) == "array" then ($c[] | select(.type == "text") | .text)
    else empty end
' 2>/dev/null | tail -c 4000)
[ -n "$convo" ] || exit 0

label=$(CLAUDE_HERDR_TITLING=1 claude -p --model haiku "Summarize what this Claude Code session is working on, as a short terminal workspace label. Rules: at most 17 characters, lowercase, words separated by single spaces, no quotes, no punctuation. Reply with ONLY the label, nothing else.

Transcript:
$convo" 2>/dev/null)

# Sanitize: first line, drop quotes, trim whitespace, hard cap at 17 chars.
label=$(printf '%s' "$label" | head -n1)
label="${label//\"/}"
label="${label//\'/}"
label="${label#"${label%%[![:space:]]*}"}"
label="${label%"${label##*[![:space:]]}"}"
label=${label:0:17}
label="${label%"${label##*[![:space:]]}"}"
[ -n "$label" ] || exit 0

# The sidebar renders the number and status glyph as their own columns, so the
# label stays bare.
"$herdr" workspace rename "$HERDR_WORKSPACE_ID" "$label" >/dev/null 2>&1
exit 0
