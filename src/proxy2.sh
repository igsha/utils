#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which base64 http htmlq sed xq >/dev/null

URL="aHR0cHM6Ly9pcHNwZWVkLmluZm8vZnJlZS1wcm94eS5waHAK"
<<< "$URL" base64 -d \
    | read -r URL

echo "Download proxy list from $URL" >&2
http GET "$URL" \
    | htmlq 'table tr' --remove-nodes th \
    | sed -e 's;<br>;,;g' -e '1i<div>' -e '$a</div>' \
    | xq -r '.div.tr[] | select(. != null) | .td | "\(.[3].["#text"] | ascii_downcase | split(",")[-1])://\(.[1]):\(.[2].["#text"]) \(.[0])"'
