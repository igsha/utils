#!/usr/bin/env bash
set -e
shopt -s lastpipe

which fzf xdg-open >/dev/null

fzf --sync --accept-nth 1 --bind 'ctrl-x:execute(xdg-open {1}),enter:accept' \
    | read -r URL

if [[ -n "$URL" ]]; then
    xdg-open "$URL"
else
    echo "Cancel"
fi
