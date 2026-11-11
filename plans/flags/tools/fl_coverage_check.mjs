#!/usr/bin/env node
// fl_coverage_check.mjs - READ-ONLY check of a registry fragment against plans/flags/inventory.json.
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json and one fragment file and prints to stdout. It never
// touches extracted/, db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself if you want to keep it.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl_coverage_check.mjs <fragment.json> <dir>[,<dir>...] [--sites]
//   --sites prints a markdown row per in-scope site naming the record that cites it (lines starting with "|";
//   filter the check lines out with rg '^\|' before pasting it into a report).
//
// Checks:
//   1. every "<file>.asm:<line> {<offset>}" reference in the fragment (evidence strings and proposal roles) names a
//      real inventory site: same offset, same file name, same line. Mismatches are listed with the real site.
//   2. every inventory site of the given dirs has its offset cited somewhere in the fragment (coverage); the
//      uncovered ones are listed.
//   3. prints the covered/total counts.
import fs from 'node:fs';

const [, , fragPath, dirArg] = process.argv;
if (!fragPath || !dirArg) {
    console.error('usage: node plans/flags/tools/fl_coverage_check.mjs <fragment.json> <dir>[,<dir>...]');
    process.exit(2);
}
const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const dirs = dirArg.split(',').filter(Boolean).map((d) => d + '/');
const text = fs.readFileSync(fragPath, 'utf8');

const all = [...inv.sites, ...(inv.item_sites ?? []), ...(inv.direct_accesses ?? []), ...(inv.helper_calls ?? [])];
const byOffset = new Map();
for (const s of all) if (s.offset !== undefined) { const a = byOffset.get(s.offset) ?? []; a.push(s); byOffset.set(s.offset, a); }
const base = (f) => f.split('/').pop();

const refRe = /([A-Za-z0-9_\/]+\.asm):(\d+)\s*\{(\d+)\}/g;
const cited = new Set();
let bad = 0;
let refs = 0;
for (const m of text.matchAll(refRe)) {
    refs++;
    const file = m[1], line = Number(m[2]), off = Number(m[3]);
    cited.add(off);
    const hit = (byOffset.get(off) ?? []).find((s) => base(s.file) === base(file) && s.line === line);
    if (!hit) {
        bad++;
        const near = (byOffset.get(off) ?? []).map((s) => `${s.file}:${s.line}`).join(' | ') || 'no site with this offset';
        console.log(`MISMATCH ${file}:${line} {${off}}  ->  ${near}`);
    }
}
// bare offsets in braces without a file:line prefix also count as cited
for (const m of text.matchAll(/\{(\d{4,7})\}/g)) cited.add(Number(m[1]));

// 4. index consistency: a site cited under flags[key] or proposals[key] must be a site of that very index
//    (site.index === key); full "extracted/<path>" evidence strings must match the inventory file path.
let badIdx = 0;
const frag = JSON.parse(text);
const checkStr = (key, str) => {
    for (const m of str.matchAll(refRe)) {
        const off = Number(m[3]);
        for (const s of (byOffset.get(off) ?? []).filter((x) => base(x.file) === base(m[1]) && x.line === Number(m[2]))) {
            if (s.index !== undefined && s.index !== null && s.index !== Number(key)) {
                badIdx++;
                console.log(`INDEX-MISMATCH key ${key}: ${s.file}:${s.line} {${off}} is index ${s.index}`);
            }
            if (m[1].startsWith('extracted/') && m[1] !== 'extracted/' + s.file) {
                badIdx++;
                console.log(`PATH-MISMATCH ${m[1]} vs extracted/${s.file}`);
            }
        }
    }
};
const walk = (key, v) => {
    if (typeof v === 'string') checkStr(key, v);
    else if (Array.isArray(v)) v.forEach((x) => walk(key, x));
    else if (v && typeof v === 'object') Object.values(v).forEach((x) => walk(key, x));
};
for (const part of ['flags', 'proposals']) for (const [k, v] of Object.entries(frag[part] ?? {})) walk(k, v);
console.log(`index/path mismatches ${badIdx}`);

// 5. with --sites: print the site table (one markdown row per in-scope site, naming the record that cites it)
if (process.argv.includes('--sites')) {
    const owner = new Map(); // offset -> record names
    const note = (name, str) => { for (const m of str.matchAll(/\{(\d{4,7})\}/g)) { const a = owner.get(Number(m[1])) ?? new Set(); a.add(name); owner.set(Number(m[1]), a); } };
    const walkName = (name, v) => {
        if (typeof v === 'string') note(name, v);
        else if (Array.isArray(v)) v.forEach((x) => walkName(name, x));
        else if (v && typeof v === 'object') Object.values(v).forEach((x) => walkName(name, x));
    };
    for (const v of Object.values(frag.flags ?? {})) for (const m of v.meanings ?? []) walkName(m.name + (m.scope?.scenes ? ' [scene ' + m.scope.scenes.map((x) => x.toString(16).toUpperCase()).join('/') + ']' : ''), m.evidence);
    for (const v of Object.values(frag.proposals ?? {})) for (const p of v) walkName(p.name + ' (proposal)', p.roles);
    const hex = (n, w = 4) => '$' + n.toString(16).toUpperCase().padStart(w, '0');
    const rows = inv.sites.filter((s) => s.index !== undefined && s.index !== null && dirs.some((d) => s.file.startsWith(d)))
        .sort((x, y) => x.file.localeCompare(y.file) || x.line - y.line);
    console.log('| file:line | offset | instruction | index | role | record |');
    console.log('|---|---|---|---|---|---|');
    for (const s of rows) console.log(`| ${s.file}:${s.line} | ${s.offset} | ${s.opcode} ${s.operands} | ${hex(s.index)} | ${s.role}${s.sense ? ' ' + s.sense : ''} | ${[...(owner.get(s.offset) ?? ['UNCOVERED'])].join('; ')} |`);
    process.exit(0);
}

const mine = inv.sites.filter((s) => s.index !== undefined && s.index !== null && dirs.some((d) => s.file.startsWith(d)));
const missing = mine.filter((s) => !cited.has(s.offset));
for (const s of missing) console.log(`UNCOVERED ${s.file}:${s.line} {${s.offset}} ${s.opcode} ${s.operands}`);
console.log(`references checked ${refs}, mismatches ${bad}`);
console.log(`sites covered ${mine.length - missing.length} of ${mine.length}`);
