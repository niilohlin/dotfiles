#!/usr/bin/env bash
# Prepend a Claude status glyph to the current tmux window name, preserving the
# base name. Invoked from Claude Code hooks (UserPromptSubmit / Stop / Notification).
# Arg 1: the glyph to show. No-op when not running inside tmux.

glyph="$1"
# Skip inside the headless `claude -p` spawned by tmux-window-title.sh, which
# inherits this tmux env and would otherwise clobber the window name.
[ -n "$CLAUDE_TMUX_TITLING" ] && exit 0
[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

current=$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null) || exit 0

# Strip a previously-set status glyph (and its trailing space) so they don't stack.
# Includes the old emoji glyphs so windows still showing one get cleaned up.
base=$current
for g in '~' '?' '✓' '⏳' '✅' '🔔'; do
  case "$base" in
    "$g "*) base=${base#"$g "} ;;
    "$g") base='' ;;
  esac
done

if [ -n "$base" ]; then
  newname="$glyph $base"
else
  newname="$glyph"
fi

# Freeze the name so tmux's automatic-rename doesn't overwrite our glyph.
tmux set-window-option -t "$TMUX_PANE" automatic-rename off >/dev/null 2>&1
tmux rename-window -t "$TMUX_PANE" "$newname" >/dev/null 2>&1
exit 0
