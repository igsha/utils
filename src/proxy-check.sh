#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which http parallel nc >/dev/null

CHECKSITE=${1:-https://bbc.com}
echo "Check proxies against $CHECKSITE" >&2
checker() {
    <<< "$@" read -r ADDR DESC
    [[ "$ADDR" =~ [^:]+://([^:]+):([0-9]+) ]]
    IP="${BASH_REMATCH[1]}"
    PORT="${BASH_REMATCH[2]}"
    if nc -w5 -z "$IP" "$PORT" 2>/dev/null; then
        echo "Available proxy[$DESC]: $ADDR"
        if ALL_PROXY="$ADDR" http --timeout 60 --ignore-stdin -F GET "$CHECKSITE" &>/dev/null; then
            echo "Workable proxy[$DESC]: $ADDR"
        fi
    fi
}

export -f checker

parallel --colsep ' ' checker "{}"
