#!/usr/bin/env node
// fl31_spine.mjs - READ-ONLY spine query for the FL31 iteration.
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json and plans/flags/results/registry/FL*_registry.json
// and prints to stdout. It never touches extracted/, db-us/, notes/, docs/, src/ or any other file.
//
// A "group" is the first path segment of the site file (prologue, south_cape, ..., system, actors, thinkers, tables,
// unused). The spine is every persistent (index >= $10) literal COP index whose sites lie in two or more groups.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl31_spine.mjs list                 # one row per spine index: sites S/C/T/W, groups, fragment names
//   node plans/flags/tools/fl31_spine.mjs sites <hex>          # every inventory site of one index (file:line, offset, role, sense, scenes)
//   node plans/flags/tools/fl31_spine.mjs show <hex>           # sites + every fragment record and proposal (name, scope, grade, summary, roles, notes)
//   node plans/flags/tools/fl31_spine.mjs names                # name -> indices across all fragments (flags and proposals); prints clashes
//   node plans/flags/tools/fl31_spine.mjs conflicts            # spine indices whose fragments carry more than one distinct name or scope
import fs from 'node:fs';
import path from 'node:path';

const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const regDir = 'plans/flags/results/registry';
const hex = (n, w = 4) => '$' + Number(n).toString(16).toUpperCase().padStart(w, '0');
const group = (f) => (f.includes('/') ? f.split('/')[0] : '(root)');
const role = (s) => ({ set: 'S', clear: 'C', branch: 'T', wait: 'W' })[s.role] ?? '?';

const cop = inv.sites.filter((s) => s.kind === 'cop' && s.index != null);
const byIdx = new Map();
for (const s of cop) {
    if (s.index < 16) continue;
    const e = byIdx.get(s.index) ?? { sites: [], groups: new Map() };
    e.sites.push(s);
    e.groups.set(group(s.file), (e.groups.get(group(s.file)) ?? 0) + 1);
    byIdx.set(s.index, e);
}
const spine = [...byIdx].filter(([, e]) => e.groups.size >= 2).sort((a, b) => a[0] - b[0]);

function fragments() {
    const out = [];
    for (const f of fs.readdirSync(regDir).filter((x) => /^FL\d+_registry\.json$/.test(x)).sort()) {
        const src = f.slice(0, 4);
        const j = JSON.parse(fs.readFileSync(path.join(regDir, f), 'utf8'));
        for (const [k, v] of Object.entries(j.flags ?? {})) {
            for (const m of v.meanings ?? []) out.push({ src, kind: 'flag', index: Number(k), ...m });
        }
        const pr = j.proposals ?? {};
        for (const [k, v] of Object.entries(pr)) {
            for (const m of Array.isArray(v) ? v : [v]) out.push({ src, kind: 'proposal', index: Number(k), ...m });
        }
    }
    return out;
}

const [cmd, arg] = process.argv.slice(2);
const frs = fragments();

if (cmd === 'list') {
    for (const [i, e] of spine) {
        const c = { S: 0, C: 0, T: 0, W: 0, '?': 0 };
        for (const s of e.sites) c[role(s)]++;
        const fr = frs.filter((x) => x.index === i);
        const names = [...new Set(fr.map((x) => x.name))];
        console.log(`${hex(i)}\t${i}\tS${c.S}/C${c.C}/T${c.T}/W${c.W}\tn${e.sites.length}\t${[...e.groups].map(([g, n]) => g + ':' + n).join(' ')}\t${fr.map((x) => x.src + (x.kind === 'flag' ? '*' : '')).join(',')}\t${names.join(' | ')}`);
    }
    console.log(`spine ${spine.length}`);
} else if (cmd === 'sites' || cmd === 'show') {
    const n = parseInt(arg, 16);
    const e = byIdx.get(n);
    for (const s of (e?.sites ?? cop.filter((x) => x.index === n)).sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line)) {
        console.log(`${s.file}:${s.line}\t{${s.offset}}\t${s.opcode}\t${s.operands}\t${s.role}\t${s.sense ?? ''}\tscenes ${(s.scenes ?? []).map((x) => hex(x, 2)).join(',')}`);
    }
    const others = inv.sites.filter((s) => s.kind !== 'cop' && s.index === n);
    for (const s of others) console.log(`[${s.kind}] ${s.file}:${s.line}\t{${s.offset}}\t${s.operands ?? s.helper ?? ''}`);
    if (cmd === 'show') {
        for (const x of frs.filter((x) => x.index === n)) {
            console.log(`\n== ${x.src} ${x.kind} ${hex(n)} scope=${JSON.stringify(x.scope ?? null)} name=${x.name} grade/conf=${x.grade ?? x.confidence ?? ''}`);
            console.log(`summary: ${x.summary}`);
            if (x.kinds) console.log(`kinds: ${x.kinds.join(',')}`);
            if (x.roles) for (const r of x.roles) console.log(`  role: ${r}`);
            if (x.evidence) for (const r of x.evidence) console.log(`  ev: ${r}`);
            if (x.effects) console.log(`effects: ${JSON.stringify(x.effects)}`);
            if (x.notes) console.log(`notes: ${x.notes}`);
        }
    }
} else if (cmd === 'names') {
    const m = new Map();
    for (const x of frs) {
        const e = m.get(x.name) ?? new Set();
        e.add(`${hex(x.index)}${x.scope ? JSON.stringify(x.scope) : ''}`);
        m.set(x.name, e);
    }
    for (const [name, set] of [...m].sort()) if (set.size > 1) console.log(`${name}\t${[...set].join(' ')}`);
} else if (cmd === 'conflicts') {
    for (const [i] of spine) {
        const fr = frs.filter((x) => x.index === i);
        const names = new Set(fr.map((x) => x.name));
        const scopes = new Set(fr.map((x) => JSON.stringify(x.scope ?? null)));
        if (names.size > 1 || scopes.size > 1) console.log(`${hex(i)}\tnames ${[...names].join(' | ')}\tscopes ${[...scopes].join(' ; ')}`);
    }
} else if (cmd === 'comments') {
    // shipped comments in extracted/ that mention a spine flag (flag word in the comment, index as #XX, $XX or "flag XX")
    const walk = (d, o = []) => {
        for (const f of fs.readdirSync(d, { withFileTypes: true })) {
            const p = path.join(d, f.name);
            if (f.isDirectory()) walk(p, o);
            else if (f.name.endsWith('.asm')) o.push(p);
        }
        return o;
    };
    const want = arg ? new Set(arg.split(',').map((t) => parseInt(t, 16))) : null;
    for (const f of walk('extracted')) {
        const lines = fs.readFileSync(f, 'utf8').split(/\r?\n/);
        lines.forEach((l, i) => {
            const ci = l.indexOf(';');
            if (ci < 0) return;
            const c = l.slice(ci);
            if (!/flag/i.test(c)) return;
            for (const [idx] of spine) {
                if (want && !want.has(idx)) continue;
                const h = idx.toString(16).toUpperCase().padStart(idx > 255 ? 4 : 2, '0');
                const re = new RegExp(`\\bflags?\\s+(?:index\\s+)?[#$]\\$?0*${h}(?![0-9A-Fa-f])`, 'i');
                if (re.test(c)) console.log(`${f.replace(/\\/g, '/')}:${i + 1}\t${hex(idx)}\t${c.trim().slice(0, 300)}`);
            }
        });
    }
} else if (cmd === 'uncited') {
    // spine sites whose decimal ROM offset appears in no fragment entry of the same index
    let miss = 0;
    for (const [i, e] of spine) {
        const text = frs.filter((x) => x.index === i).map((x) => JSON.stringify(x)).join('\n');
        const rows = e.sites.filter((s) => !new RegExp(`(?<![0-9])${s.offset}(?![0-9])`).test(text));
        for (const s of rows) {
            miss++;
            console.log(`${hex(i)}\t${s.file}:${s.line}\t{${s.offset}}\t${s.opcode}\t${s.role}`);
        }
    }
    console.log(`uncited sites ${miss}`);
} else {
    console.log('usage: list|sites <hex>|show <hex>|names|conflicts|uncited (see header)');
}
