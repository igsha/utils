#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which base64 http rg htmlq xq >/dev/null

URL="aHR0cHM6Ly9zcHlzLm9uZS9lbi9zb2Nrcy1wcm94eS1saXN0Lwo="
<<< "$URL" base64 -d \
    | read -r URL

echo "Download proxy list from $URL" >&2
http -f POST "$URL" xpp=3 xf1=0 xf2=0 xf4=0 xf5=2 \
    | mapfile HTML

declare -A VARS=()
# Calc js code
<<< "${HTML[@]}" htmlq script -t \
    | rg '([a-z\d]+=\d+(\^[a-z\d]+)?;){3,}' \
    | while read -d';' VARLINE && [[ -n "$VARLINE" ]]; do
        if [[ "$VARLINE" =~ ([a-z0-9]+)=([0-9]+)\^([a-z0-9]+) ]]; then
            NAME="${BASH_REMATCH[1]}"
            VAL="${BASH_REMATCH[2]}"
            VARNAME="${BASH_REMATCH[3]}"
            VARS["$NAME"]="$((VAL ^ VARS[$VARNAME]))"
        elif [[ "$VARLINE" =~ ([a-z0-9]+)=([0-9]+) ]]; then
            NAME="${BASH_REMATCH[1]}"
            VAL="${BASH_REMATCH[2]}"
            VARS["$NAME"]="$VAL"
        else
            echo "Cannot parse: $VARLINE" >&2
            exit 1
        fi
    done

<<< "${HTML[@]}" htmlq 'table table tr[onmouseover] td' \
    | while mapfile -t -n 10 ARR && ((${#ARR[@]})); do
        <<< "${ARR[0]}" rg "(\d+\.\d+\.\d+\.\d+).*?\+([+a-z\d^()]+)\)" -or '$1 $2' \
            | read -r IPADDRESS PORTEXPR

        PORT=""
        while read -d'+' AA && [[ -n "$AA" ]]; do
            if [[ "$AA" =~ ([a-z0-9]+)\^([a-z0-9]+) ]]; then
                VAR0="${BASH_REMATCH[1]}"
                VAR1="${BASH_REMATCH[2]}"
                PORT+="$((VARS[$VAR0] ^ VARS[$VAR1]))"
            fi
        done <<< "${PORTEXPR}+"

        <<< "${ARR[1]}" xq -r '.td.["#text"] | ascii_downcase' \
            | read -r TYPE

        <<< "${ARR[3]}" xq -r '[.. | .["#text"]? | select(.)] | join(" ")' \
            | read -r COUNTRY

        printf "%s\t[%s]\n" "$TYPE://$IPADDRESS:$PORT" "$COUNTRY"
    done
