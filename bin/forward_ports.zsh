#!/usr/bin/env zsh

set -o pipefail
set -e

ports=(8004 8001 3001 3003 8002 3002 8000 8003 8005 8006 8008 8009 3004 3000 5672 6379 3005 8011)

for port in $ports; do
    sshpass -e ssh -L "$port":localhost:"$port" niilohlin@niils-mac-studio -N &
done


