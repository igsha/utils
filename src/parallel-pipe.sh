#!/usr/bin/env bash
set -e
shopt -s lastpipe

which parallel >/dev/null || { echo "ERROR: Some program missing"; exit 1; }

realpath "$0" \
    | xargs dirname \
    | read -r SCRIPT_DIR

PATH+=:"$SCRIPT_DIR" parallel --pipe -N 1 "$@"
