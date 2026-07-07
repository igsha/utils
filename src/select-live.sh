#!/usr/bin/env bash
set -e

which nc parallel >/dev/null

checker() {
    ADDR="$1"
    OTHER="${@:2}"
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

    if nc -w5 -z "$SERVER" "$PORT" 2>/dev/null; then
        echo "$ADDR $OTHER"
    fi
}

export -f checker
parallel --colsep ' ' checker "{}"
