#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which http parallel >/dev/null

CHECKSITE="aHR0cHM6Ly95b3V0dWJlLmNvbQo="
<<< "$CHECKSITE" base64 -d \
    | read -r CHECKSITE

echo "Check proxies against $CHECKSITE" >&2
checker() {
    <<< "$@" read -r ADDR DESC
    if ALL_PROXY="$ADDR" http --timeout 4 --ignore-stdin -F GET "$CHECKSITE" &>/dev/null; then
        echo "Workable proxy[$DESC]: $ADDR"
    fi
}

export -f checker

parallel --colsep ' ' checker "{}"
