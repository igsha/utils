#!/usr/bin/env bash
set -eo pipefail
shopt -s lastpipe

which base64 http htmlq xargs xdg-open >/dev/null

BASEURL="aHR0cHM6Ly9tdHByb3RvLnJ1Cg=="
<<< "$BASEURL" base64 -d \
    | read -r BASEURL

URL="$BASEURL/main.php"
#URL="$BASEURL/example-other.php"
while [[ "${URL:0:10}" != tg://proxy ]]; do
    echo "Try $URL" >&2
    http --session=mysession GET "$URL" \
        | mapfile HTML

    if <<< "${HTML[@]}" htmlq --base "$BASEURL" '#get-message a' -a href | read -r FIRSTURL; then
        URL="$FIRSTURL"
    else
        http --session-read-only=mysession GET "$BASEURL/main-captcha.php" \
                origin:http://mtproto.ru referer:http://mtproto.ru/main.php \
            | catimg - >&2
        read -rp "Input captcha: " CAPTCHAVAL

        http -Ff --session-read-only=mysession POST "$BASEURL/main-verify.php" captcha_input="$CAPTCHAVAL" \
                origin:http://mtproto.ru referer:http://mtproto.ru/main.php \
            | mapfile HTML

        <<< "${HTML[@]}" htmlq --base "$BASEURL" '#get-message a' -a href \
            | read -r URL
    fi
done

echo "Open url in tg: $URL"
xdg-open "$URL"
