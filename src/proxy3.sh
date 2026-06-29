#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which base64 http htmlq xq >/dev/null

URL="aHR0cHM6Ly9hZHZhbmNlZC5uYW1lL2ZyZWVwcm94eT90eXBlPXNvY2tzNQo="
<<< "$URL" base64 -d \
    | read -r URL

echo "Download proxy list from $URL" >&2
http "$URL" \
    | htmlq '#table_proxies tbody' --remove-nodes img \
    | xq -r '.tbody.tr[] | "socks5://\(.td[1].["@data-ip"] | @base64d):\(.td[2].["@data-port"] | @base64d)\t\(.td[4].a.["#text"])"'
