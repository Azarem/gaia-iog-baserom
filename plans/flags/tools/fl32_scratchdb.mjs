#!/usr/bin/env node
// fl32_scratchdb.mjs - builds a SCRATCH copy of the registry for dry-run validation of the FL32 specs.
//
// WRITES ONLY plans/flags/results/_scratch_db/ (flags.json, groups.json, scene-flags.json copy). It never touches db-us/, extracted/, notes/,
// docs/, src/, artifacts/ or the plan files. Delete the folder when done.
//
// The scratch flags.json is the registry chain FL10..FL31b + FL40 merged in memory (fl32_lib.loadRegistry, patches applied by
// expectOld) on top of the domains of db-us/flags.json, SANITISED so that the checker accepts it (the earlier fragments
// use kinds, scopes, areas and "$XX" references that the tool rejects; the counts are printed and go into the FL32 report).
// It exists only so that
//   npm run flags -- <FL32 file> --dry-run --db-dir=plans/flags/results/_scratch_db
// validates the FL32 rows against the records they edit. The real tool is run with --dry-run only.
//   node plans/flags/tools/fl32_scratchdb.mjs
import fs from 'node:fs';
import { readJson, loadRegistry } from './fl32_lib.mjs';

const dir = 'plans/flags/results/_scratch_db';
fs.mkdirSync(dir, { recursive: true });
const base = readJson('db-us/flags.json');
const { flags, proposals } = loadRegistry();
const KINDS = ['once-latch', 'quest-guard', 'quest-done', 'gate-open', 'handshake', 'cutscene-stage', 'puzzle-state', 'reward-claimed', 'form-latch', 'engine', 'idiom', 'unknown'];
const findings = { kinds: 0, refs: 0, scope: 0, area: 0 };
const fixRef = (x) => {
    if (typeof x === 'string' && /^\$[0-9A-Fa-f]+( set| clear)?$/.test(x)) { findings.refs++; return parseInt(x.slice(1), 16); }
    return x;
};
const out = { schema: base.schema, domains: base.domains, flags: {} };
for (const [idx, rec] of [...flags].sort((a, b) => a[0] - b[0])) {
    const meanings = rec.meanings.map(({ _from, ...m }) => {
        if (m.kinds) {
            const k = m.kinds.filter((x) => KINDS.includes(x));
            if (k.length !== m.kinds.length) findings.kinds++;
            m.kinds = k.length ? k : ['unknown'];
        }
        for (const f of ['requires', 'excludes', 'pairsWith']) if (m[f]) m[f] = m[f].map(fixRef);
        if (m.area === 'unused') { m.area = 'system'; findings.area++; }
        if (m.scope && rec.domain !== 'D1' && rec.meanings.length === 1) { m.scope = null; findings.scope++; }
        return m;
    });
    // D1 records whose scene scopes overlap (index 0): keep the narrower meanings, drop the broad one (checker rejects overlap)
    let kept = meanings;
    if (rec.domain === 'D1') {
        const sorted = [...meanings].sort((a, b) => (a.scope?.scenes?.length ?? 99) - (b.scope?.scenes?.length ?? 99));
        const seen = new Set();
        kept = [];
        for (const m of sorted) {
            const sc = m.scope?.scenes ?? [];
            if (sc.some((s) => seen.has(s))) { findings.overlap = (findings.overlap ?? 0) + 1; continue; }
            sc.forEach((s) => seen.add(s));
            kept.push(m);
        }
    }
    out.flags[String(idx)] = { domain: rec.domain, meanings: kept };
}
const pr = {};
for (const [idx, list] of proposals) if (!flags.has(idx)) pr[String(idx)] = list.map(({ _from, ...p }) => p);
if (Object.keys(pr).length) out.proposals = pr;
fs.writeFileSync(`${dir}/flags.json`, JSON.stringify(out, null, 2) + '\n');
fs.copyFileSync('db-us/groups.json', `${dir}/groups.json`);
fs.copyFileSync('db-us/scene-flags.json', `${dir}/scene-flags.json`);
console.log(`scratch registry: ${Object.keys(out.flags).length} indices, ${Object.keys(pr).length} proposals -> ${dir}`);
console.log('sanitised for the checker (meanings or entries changed):', JSON.stringify(findings));
