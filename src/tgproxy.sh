#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which base64 http jq fzf tee xargs xdg-open >/dev/null

URL="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL25lbGxpbW9uaXgvbXRwcm94eV9saXN0L3JlZnMvaGVhZHMvbWFpbi9tdHByb3h5Lmpzb24K"
<<< "$URL" base64 -d \
    | read -r URL

http GET "$URL" \
    | jq -r '.[] | "\(.country) \(.addTime | todateiso8601) tg://proxy?server=\(.host)&port=\(.port)&secret=\(.secret)"' \
    | fzf --accept-nth 3 \
    | tee >(xargs printf "Try %s\n" >&2) \
    | xargs xdg-open
