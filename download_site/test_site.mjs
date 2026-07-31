import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("./index.html", import.meta.url), "utf8");

assert.match(html, /<html lang="vi">/);
assert.match(html, /SmartNote/);
assert.match(html, /Tải APK/);
assert.match(html, /data-apk-url/);
assert.match(html, /https:\/\/[^"]+\.public\.blob\.vercel-storage\.com\/app-debug\.apk/);
assert.doesNotMatch(html, /SMARTNOTE_APK_URL/);
assert.match(html, /931E254919CA123A096C3D4E96F5EA7C08EFEB8FD6FAB8FFF317E6C664EF2529/);
assert.match(html, /163\.3 MB/);

console.log("SmartNote download page contract passed.");
