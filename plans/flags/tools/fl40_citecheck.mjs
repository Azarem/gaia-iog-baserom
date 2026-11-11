// fl40_citecheck.mjs: READ-ONLY helper. Writes nowhere (stdout only).
// Checks every "path.asm:LINE {OFFSET}" citation in a text/JSON file against extracted/:
// the cited line must carry the tag "; {OFFSET}". Reports the actual line of the offset when it differs.
// Usage: node plans/flags/tools/fl40_citecheck.mjs <file> [--fix-lines]   (--fix-lines only prints suggestions)
import fs from 'fs';
import path from 'path';

const txt = fs.readFileSync(process.argv[2], 'utf8');
const files = [];
(function walk(d) {
  for (const e of fs.readdirSync(d, { withFileTypes: true })) {
    const p = path.join(d, e.name);
    if (e.isDirectory()) walk(p);
    else if (p.endsWith('.asm')) files.push(p.split(path.sep).join('/'));
  }
})('extracted');

const cache = new Map();
const lines = (f) => { if (!cache.has(f)) cache.set(f, fs.readFileSync(f, 'utf8').split(/\r?\n/)); return cache.get(f); };
const re = /([A-Za-z0-9_\/\-]+\.asm):(\d+)(?:[^{"\n]{0,3})? ?\{(\d+)\}/g;
let m, n = 0, bad = 0;
while ((m = re.exec(txt))) {
  n++;
  const [, f, l, o] = m;
  const cands = files.filter((x) => x.endsWith('/' + f) || x.endsWith(f));
  if (!cands.length) { console.log('NOFILE', f, l, o); bad++; continue; }
  const ok = cands.some((c) => (lines(c)[+l - 1] || '').includes('{' + o + '}'));
  if (!ok) {
    bad++;
    const hit = cands.map((c) => [c, lines(c).findIndex((x) => x.includes('{' + o + '}')) + 1]).find((x) => x[1] > 0);
    console.log('BAD', f, l, o, hit ? `-> offset is at ${hit[0]}:${hit[1]}` : '-> offset not in that file');
  }
}
console.log('checked', n, 'bad', bad);
