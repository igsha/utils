#!/usr/bin/env zx

const b64url = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL25lbGxpbW9uaXgvbXRwcm94eV9saXN0L3JlZnMvaGVhZHMvbWFpbi9tdHByb3h5Lmpzb24K";
const url = atob(b64url);
process.stderr.write(`tgproxy: Download list from ${url}`);

const response = await fetch(url);
if (!response.ok) {
    throw new Error(`HTTP error! Status: ${response.status}`);
}

const data = await response.json();

const keyBytes = new Uint8Array(Buffer.from("656741bc0ba1efc105f996a53e88cb61fd34ef48aca22290af2881b4956f304e", "hex"));
const iv = Uint8Array.from(atob(data.iv), function(_c) {
    return _c.charCodeAt(0);
});
const encryptedDataWithTag = Uint8Array.from(atob(data.ct), function(_c) {
    return _c.charCodeAt(0);
});

const cryptoKey = await crypto.subtle.importKey("raw", keyBytes, { name: "AES-GCM" }, false, ["decrypt"]);
const decryptedBuffer = await crypto.subtle.decrypt({name: "AES-GCM", iv: iv, tagLength: 128}, cryptoKey,encryptedDataWithTag);
const json = JSON.parse(new TextDecoder().decode(decryptedBuffer));

const items = json.map(function(item) {
    const datetime = new Date(item.addTime * 1000);
    const datetimeInLocalTimezone = new Date(datetime - datetime.getTimezoneOffset() * 60000).toISOString().slice(0, -1);
    return `${item.country} ${datetimeInLocalTimezone} tg://proxy?server=${item.host}&port=${item.port}&secret=${item.secret}`;
});

const text = items.join("\n");

if (argv.s || argv.select) {
    const program = $`fzf --accept-nth 3`;
    program.stdin.write(text);
    program.stdin.end();
    const selectedValue = await program;
    process.stderr.write(`tgproxy: Try ${selectedValue}\n`);
    await $`xdg-open ${selectedValue}`;
} else {
    console.log(text);
}
