#!/bin/sh

set -u

herdr=${HERDR_BIN_PATH:-herdr}

status=$("$herdr" agent list 2>/dev/null |
	jq -r '[.result.agents[]? | select(.focused) | .agent_status] | first // "none"')

case $status in
working) seq='\033]9;4;3;0\007' ;;
blocked) seq='\033]9;4;2;100\007' ;;
*) seq='\033]9;4;0;0\007' ;;
esac

ttys=$(ps -eo tty=,args= | awk '
	$1 == "??" || $1 == "?" { next }
	{
		n = split($2, path, "/")
		if (path[n] != "herdr") next
		for (i = 3; i <= NF; i++)
			if ($i ~ /^(agent|api|channel|completion|config|integration|notification|pane|plugin|server|session|status|tab|update|workspace|worktree)$/) next
		print "/dev/" $1
	}')

[ -n "$ttys" ] || exit 0

state_file=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}/last-state
key="$status $(echo "$ttys" | tr '\n' ' ')"
[ "$(cat "$state_file" 2>/dev/null)" = "$key" ] && exit 0

for tty in $ttys; do
	[ -w "$tty" ] && printf '%b' "$seq" >"$tty"
done

printf '%s' "$key" >"$state_file"
