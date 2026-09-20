#!/usr/bin/env bash
# PreToolUse hook for Write|Edit|MultiEdit.
# Saves the pre-edit content of every file Claude touches, so the Stop hook can
# tell which comments Claude added from which comments were already there.
# First snapshot of a path wins; the Stop hook clears the directory when it runs.

payload=$(cat)

sid=$(printf '%s' "$payload" | jq -r '.session_id // "nosession"')
fp=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

[ -n "$fp" ] || exit 0

dir="$HOME/.claude/comment-stripper/$sid"
mkdir -p "$dir" || exit 0

key=$(printf '%s' "$fp" | shasum -a 256 | cut -d' ' -f1)
[ -e "$dir/$key.path" ] && exit 0

printf '%s' "$fp" >"$dir/$key.path"
if [ -f "$fp" ]; then
  cp "$fp" "$dir/$key.orig" 2>/dev/null || : >"$dir/$key.orig"
else
  # New file: empty baseline means every line counts as added.
  : >"$dir/$key.orig"
fi

exit 0
