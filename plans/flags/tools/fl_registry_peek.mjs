#!/usr/bin/env node
// fl_registry_peek.mjs - READ-ONLY view over the registry fragments in plans/flags/results/registry/.
//
// This script WRITES NOTHING: it reads plans/flags/results/registry/FL*_registry.json and prints to stdout.
// It never touches extracted/, db-us/, notes/, docs/, src/ or any other file.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl_registry_peek.mjs <index>[,<index>...]   # indices in hex (e.g. 4C,0119) or decimal prefixed with d (d76)
//   node plans/flags/tools/fl_registry_peek.mjs all                    # one line per record and per proposal of every fragment
//
// For every fragment it prints the `flags` meanings and the `proposals` entries whose index matches. A fragment's
// `flags` object is keyed by decimal index; `proposals` is either an object keyed by decimal index or an array whose
// items carry an `index`/`flag` field (the shapes differ between iterations, so both are handled).
import fs from 'node:fs';
import path from 'node:path';

const dir = 'plans/flags/results/registry';
const arg = process.argv[2];
if (!arg) {
    console.error('usage: fl_registry_peek.mjs <index,...>|all');
    process.exit(1);
}
const wanted = new Set();
if (arg !== 'all') {
    for (const t of arg.split(',').filter(Boolean)) wanted.add(t.startsWith('d') ? Number(t.slice(1)) : parseInt(t, 16));
}
const hex = (n) => '$' + Number(n).toString(16).toUpperCase().padStart(4, '0');

for (const f of fs.readdirSync(dir).filter((x) => /^FL\d+_registry\.json$/.test(x)).sort()) {
    const j = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8'));
    for (const [k, v] of Object.entries(j.flags ?? {})) {
        if (arg !== 'all' && !wanted.has(Number(k))) continue;
        for (const m of v.meanings ?? []) {
            console.log(`${f}\tflag\t${hex(k)}\t${JSON.stringify(m.scope)}\t${m.name}\t${m.grade}\t${(m.summary ?? '').slice(0, 160)}`);
        }
    }
    const pr = j.proposals;
    const items = Array.isArray(pr) ? pr : Object.entries(pr ?? {}).flatMap(([k, v]) => (Array.isArray(v) ? v.map((x) => ({ index: Number(k), ...x })) : [{ index: Number(k), ...v }]));
    for (const p of items) {
        const idx = p.index ?? p.flag;
        if (arg !== 'all' && !wanted.has(Number(idx))) continue;
        console.log(`${f}\tproposal\t${hex(idx)}\t${JSON.stringify(p.scope ?? null)}\t${p.name}\t${p.confidence ?? ''}\t${(p.summary ?? '').slice(0, 160)}`);
    }
}
