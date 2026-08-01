import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("./index.html", import.meta.url), "utf8");

assert.match(html, /<html lang="vi">/);
assert.match(html, /SmartNote/);
assert.match(html, /Tải APK/);
assert.match(html, /data-apk-url/);
assert.match(html, /https:\/\/[^"]+\.public\.blob\.vercel-storage\.com\/app-debug\.apk/);
assert.doesNotMatch(html, /SMARTNOTE_APK_URL/);
assert.match(html, /068303290D8C874B62724B7DFE6F8732EE4FE127982D18E3D5227C4F52B29089/);
assert.match(html, /202\.2 MB/);

console.log("SmartNote download page contract passed.");
