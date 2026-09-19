# ghostty-progress

Agents like Claude Code report how busy they are with OSC 9;4, the ConEmu
progress sequence, and Ghostty draws that as a progress bar on the window.
Herdr reads the same sequence per pane to decide whether an agent is working,
blocked, or idle, but it only ever writes OSC 0 titles and bells back to the
terminal it runs in. The progress report dies there.

This plugin closes the loop. Herdr runs `sync.sh` on every event that can change
which agent you are looking at or what that agent is doing. The script asks
Herdr for the focused pane's state and writes the matching sequence directly to
the attached client's tty, which is a Ghostty pty, so it lands in Ghostty
without going through Herdr's renderer.

| Focused agent | Sequence     | Ghostty               |
| ------------- | ------------ | --------------------- |
| working       | `9;4;3;0`    | indeterminate bar     |
| blocked       | `9;4;2;100`  | red bar, needs an answer |
| anything else | `9;4;0;0`    | no bar                |

Panes with no agent count as "anything else", so focusing a plain shell clears
the bar.

Install:

    herdr plugin link ~/dotfiles/herdr/plugins/ghostty-progress

Debug with `herdr plugin log list --plugin ghostty-progress`. The last sequence
written is cached under `~/.local/state/herdr/plugins/ghostty-progress` so
repeated events do not keep writing into a tty Herdr is busy repainting; delete
that file to force the next event through.

Needs `jq`. If Herdr ever forwards OSC 9;4 itself, delete this.
