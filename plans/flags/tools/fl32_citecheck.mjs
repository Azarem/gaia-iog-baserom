#!/usr/bin/env node
// fl32_citecheck.mjs - READ-ONLY citation checker for FL32 deliverables.
//
// This script WRITES NOTHING: it reads the given files and extracted/**/*.asm and prints to stdout.
// It finds every `file.asm:LINE {OFFSET}` (also the short forms `:LINE {OFFSET}` and `base.asm:LINE {OFFSET}` that reuse
// the last file of the same text) and checks that line LINE of that file carries the line-tracking tag {OFFSET}.
// A mismatch prints the line that does carry the tag (if any). Exit code 1 when a mismatch exists.
//   node plans/flags/tools/fl32_citecheck.mjs <file> [<file> ...]
import fs from 'node:fs';
import path from 'node:path';
import { asmFiles, readLines } from './fl32_lib.mjs';

const all = asmFiles();
const byBase = new Map();
for (const f of all) {
    const b = path.posix.basename(f);
    if (!byBase.has(b)) byBase.set(b, []);
    byBase.get(b).push(f);
}
const lineCache = new Map();
const lines = (f) => { if (!lineCache.has(f)) lineCache.set(f, readLines('extracted/' + f)); return lineCache.get(f); };

function resolve(name, last) {
    if (!name) return last;
    let n = name.replace(/^extracted\//, '');
    if (all.includes(n)) return n;
    const c = byBase.get(path.posix.basename(n));
    if (!c) return null;
    if (c.length === 1) return c[0];
    const dir = last ? path.posix.dirname(last) : '';
    return c.find((x) => path.posix.dirname(x) === dir) ?? c[0];
}

let bad = 0, ok = 0;
for (const file of process.argv.slice(2)) {
    const text = fs.readFileSync(file, 'utf8');
    // split into logical strings: JSON string values or markdown lines
    const chunks = text.split(/\r?\n/);
    for (const [ci, chunk] of chunks.entries()) {
        let last = null;
        const re = /(?:([A-Za-z0-9_./-]+\.asm))?:(\d+)(?:-\d+)?\s*\{(\d+)\}/g;
        let m;
        while ((m = re.exec(chunk))) {
            const f = resolve(m[1], last);
            if (m[1] && f) last = f;
            if (!f) { if (m[1]) { console.log(`${file}:${ci + 1}: cannot resolve ${m[1]}`); bad++; } continue; }
            const ln = Number(m[2]);
            const tag = `{${m[3]}}`;
            const L = lines(f);
            if ((L[ln - 1] ?? '').includes(tag)) { ok++; continue; }
            const at = L.findIndex((x) => x.includes(tag));
            console.log(`${file}:${ci + 1}: ${f}:${ln} ${tag} -> ${at >= 0 ? 'tag is on line ' + (at + 1) : 'tag not found in file'}`);
            bad++;
        }
    }
}
console.log(`citecheck: ${ok} ok, ${bad} problem(s)`);
process.exit(bad ? 1 : 0);
