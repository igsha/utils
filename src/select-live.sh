#!/usr/bin/env bash
set -e

which nc >/dev/null

TIMEOUT=${1:-5}
while read -r ADDR OTHER; do
    if [[ "$ADDR" =~ tg://proxy\?server=([^&]+)\&port=([0-9]+) ]]; then
        SERVER="${BASH_REMATCH[1]}"
        PORT="${BASH_REMATCH[2]}"
    elif [[ "$ADDR" =~ [^/]+://([^:]+):([0-9]+) ]]; then
        SERVER="${BASH_REMATCH[1]}"
        PORT="${BASH_REMATCH[2]}"
    else
        echo "Unsupported address $ADDR" >&2
        continue
    fi

    if nc -w "$TIMEOUT" -z "$SERVER" "$PORT" 2>/dev/null; then
        echo "$ADDR $OTHER"
    fi
done
