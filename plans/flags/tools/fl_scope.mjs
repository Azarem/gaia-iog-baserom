#!/usr/bin/env node
// fl_scope.mjs - READ-ONLY scope query over plans/flags/inventory.json (FL01 output) for the scene-group iterations.
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json and prints to stdout. It never touches extracted/,
// db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself if you want to paste it into a report.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl_scope.mjs coverage <dir>[,<dir>...]    # per-index coverage table: sites S/C/T/W, owned|spine, other dirs
//   node plans/flags/tools/fl_scope.mjs sites <dir>[,<dir>...]       # every site of the scope in file/line order (offset, role, sense, scenes)
//   node plans/flags/tools/fl_scope.mjs files <dir>[,<dir>...]       # per-file site counts
//   node plans/flags/tools/fl_scope.mjs index <hex> [<dir>,...]      # every site of one index; with dirs, marks those inside the scope
//   node plans/flags/tools/fl_scope.mjs direct <dir>[,<dir>...]      # direct $0A00-$0BFB accesses inside the scope
//   node plans/flags/tools/fl_scope.mjs scene <decimalSceneId>       # sites whose scene list contains the id
//
// Roles of the columns: S = SetFlag*, C = ClearFlag*, T = BranchOnFlag* (test), W = WaitOnFlag*.
import fs from 'node:fs';

const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const [cmd, a, b] = process.argv.slice(2);
const hex = (n, w = 4) => '$' + n.toString(16).toUpperCase().padStart(w, '0');
const dirsOf = (s) => (s ?? '').split(',').filter(Boolean).map((d) => d + '/');
const inScope = (file, dirs) => dirs.some((d) => file.startsWith(d));
const grp = (file) => (file.includes('/') ? file.split('/')[0] : file.split('.')[0] === file ? file : '(' + file.split('/')[0] + ')');
const roleKey = (s) => ({ set: 'S', clear: 'C', branch: 'T', wait: 'W' })[s.role] ?? '?';
const idxSites = inv.sites.filter((s) => s.index !== undefined && s.index !== null);

if (cmd === 'coverage') {
    const dirs = dirsOf(a);
    const byIdx = new Map();
    for (const s of idxSites) {
        const e = byIdx.get(s.index) ?? { mine: [], other: [] };
        (inScope(s.file, dirs) ? e.mine : e.other).push(s);
        byIdx.set(s.index, e);
    }
    const rows = [...byIdx.entries()].filter(([, e]) => e.mine.length).sort((x, y) => x[0] - y[0]);
    for (const [i, e] of rows) {
        const c = { S: 0, C: 0, T: 0, W: 0, '?': 0 };
        for (const s of e.mine) c[roleKey(s)]++;
        const others = new Map();
        for (const s of e.other) { const g = s.file.split('/')[0]; others.set(g, (others.get(g) ?? 0) + 1); }
        const kind = e.mine[0].kind;
        console.log(`${hex(i)}\t${i}\tS${c.S}/C${c.C}/T${c.T}/W${c.W}\t${e.mine.length}\t${others.size ? 'SPINE' : 'owned'}\t${[...others].map(([g, n]) => g + ':' + n).join(' ')}\t${kind}`);
    }
} else if (cmd === 'sites') {
    const dirs = dirsOf(a);
    const rows = idxSites.filter((s) => inScope(s.file, dirs)).sort((x, y) => x.file.localeCompare(y.file) || x.line - y.line);
    for (const s of rows) {
        console.log(`${s.file}:${s.line}\t${s.offset}\t${s.opcode}\t${s.operands}\t${hex(s.index)}\t${s.role}\t${s.sense ?? ''}\tscenes ${(s.scenes ?? []).map((x) => hex(x, 2)).join(',')}`);
    }
} else if (cmd === 'files') {
    const dirs = dirsOf(a);
    const m = new Map();
    for (const s of idxSites.filter((s) => inScope(s.file, dirs))) m.set(s.file, (m.get(s.file) ?? 0) + 1);
    for (const [f, n] of [...m].sort()) console.log(`${n}\t${f}`);
    console.log(`files ${m.size}`);
} else if (cmd === 'index') {
    const n = parseInt(a, 16);
    const dirs = dirsOf(b);
    for (const s of idxSites.filter((s) => s.index === n).sort((x, y) => x.file.localeCompare(y.file) || x.line - y.line)) {
        console.log(`${dirs.length && inScope(s.file, dirs) ? '*' : ' '} ${s.file}:${s.line}\t${s.offset}\t${s.opcode}\t${s.operands}\t${s.role}\t${s.sense ?? ''}\tscenes ${(s.scenes ?? []).map((x) => hex(x, 2)).join(',')}`);
    }
} else if (cmd === 'direct') {
    const dirs = dirsOf(a);
    for (const d of inv.direct_accesses.filter((d) => inScope(d.file, dirs))) {
        console.log(`${d.file}:${d.line}\t${d.offset}\t${d.opcode} ${d.operands}\t${d.addressHex}\t${d.access}\t${d.region}`);
    }
} else if (cmd === 'scene') {
    const id = parseInt(a, 10);
    for (const s of idxSites.filter((s) => (s.scenes ?? []).includes(id)).sort((x, y) => x.file.localeCompare(y.file) || x.line - y.line)) {
        console.log(`${s.file}:${s.line}\t${s.offset}\t${s.opcode}\t${s.operands}\t${hex(s.index)}\t${s.role}\t${s.sense ?? ''}`);
    }
} else {
    console.log('usage: coverage|sites|files|index|direct|scene (see header)');
}
