#!/usr/bin/env bash
set -e
shopt -s lastpipe

which fzf xdg-open >/dev/null

fzf --accept-nth 1 \
    | read -r URL

xdg-open "$URL"
