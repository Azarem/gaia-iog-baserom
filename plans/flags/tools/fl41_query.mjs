#!/usr/bin/env node
// fl41_query.mjs - READ-ONLY query helper of the FL41 gap analysis (flag array coverage).
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json, plans/flags/results/registry/FL*_registry.json,
// plans/flags/results/queue/FL*_queue.json and extracted/**/*.asm (through fl32_lib.mjs) and prints to stdout. It never
// touches extracted/, db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself if you want to keep it.
//
// Usage (run from the repository root, c:\Work\gaia-iog-baserom):
//   node plans/flags/tools/fl41_query.mjs flag <hex>[,<hex>...]   registry meanings, proposals, inventory sites, helper/trace/direct hits of each index
//   node plans/flags/tools/fl41_query.mjs oneside                  the literal indices with no literal test (set-only) and with no literal set (test-only)
//   node plans/flags/tools/fl41_query.mjs trace <traceId>          candidates of one inventory trace
import { loadInventory, loadRegistry, hex } from './fl32_lib.mjs';

const inv = loadInventory();
const cmd = process.argv[2];
const arg = process.argv[3] ?? '';
const H = (n) => hex(n);
const cops = inv.sites.filter((s) => s.kind === 'cop');
const gates = inv.sites.filter((s) => s.kind === 'scene_gate');
const roleKey = { set: 'S', clear: 'C', branch: 'T', wait: 'W' };

function tally(list) {
    const m = new Map();
    for (const s of list) {
        const r = m.get(s.index) ?? { S: 0, C: 0, T: 0, W: 0, sites: [] };
        r[roleKey[s.role] ?? 'T']++;
        r.sites.push(s);
        m.set(s.index, r);
    }
    return m;
}

if (cmd === 'oneside') {
    const t = tally(cops);
    const setOnly = [], testOnly = [];
    for (const [i, r] of [...t].sort((a, b) => a[0] - b[0])) {
        if (r.S + r.C > 0 && r.T + r.W === 0) setOnly.push(i);
        if (r.T + r.W > 0 && r.S === 0) testOnly.push(i);
    }
    console.log(`literal indices ${t.size}`);
    console.log(`set/clear COP, no literal Branch/Wait COP (${setOnly.length}): ${setOnly.map(H).join(' ')}`);
    console.log(`Branch/Wait COP, no literal Set COP (${testOnly.length}): ${testOnly.map(H).join(' ')}`);
} else if (cmd === 'flag') {
    const { flags, proposals } = loadRegistry(true);
    const t = tally(cops);
    for (const tok of arg.split(',').filter(Boolean)) {
        const i = parseInt(tok, 16);
        console.log(`=== ${H(i)} (${i}) byte $${(0xa00 + (i >> 3)).toString(16).toUpperCase()} bit ${i & 7}`);
        const rec = flags.get(i);
        for (const m of rec?.meanings ?? []) {
            console.log(`  record ${rec.domain} ${JSON.stringify(m.scope ?? null)} ${m.name} [${m.grade}] kinds=${(m.kinds ?? []).join(',')} from ${m._from}`);
            console.log(`    summary: ${(m.summary ?? '').slice(0, 260)}`);
            if (m.notes) console.log(`    notes: ${m.notes.slice(0, 500)}`);
            if (m.queue) console.log(`    queue: ${JSON.stringify(m.queue)}`);
        }
        for (const p of proposals.get(i) ?? []) console.log(`  proposal ${p._from} ${p.name} (${p.confidence ?? ''})`);
        const r = t.get(i);
        if (r) {
            console.log(`  literal COP S${r.S}/C${r.C}/T${r.T}/W${r.W}`);
            for (const s of r.sites) console.log(`    ${s.file}:${s.line} {${s.offset}} ${s.opcode} ${s.operands} scenes=${(s.scenes ?? []).join(',')}`);
        }
        for (const g of gates.filter((x) => x.index === i)) console.log(`  scene gate ${g.file}:${g.line} {${g.offset}} scenes=${(g.scenes ?? []).join(',')}`);
        for (const h of inv.helper_calls.filter((x) => (x.indices ?? []).includes(i))) console.log(`  helper ${h.helper} ${h.file}:${h.line} {${h.offset}} resolution=${h.resolution} trace=${h.trace}`);
        for (const tr of inv.traces) {
            const hit = (tr.candidates ?? []).filter((c) => (c.indices ?? [c.index]).includes(i) || c.index === i || c.global === i);
            if (hit.length) console.log(`  trace ${tr.id}: ${hit.length} candidate row(s) e.g. ${JSON.stringify(hit[0]).slice(0, 300)}`);
        }
        const byte = 0xa00 + (i >> 3);
        for (const d of inv.direct_accesses.filter((x) => x.address === byte)) console.log(`  direct ${d.access} ${d.file}:${d.line} {${d.offset}} ${d.opcode} ${d.operands}`);
    }
} else if (cmd === 'trace') {
    const tr = inv.traces.find((x) => x.id === arg);
    console.log(JSON.stringify(tr, null, 1).slice(0, 6000));
} else {
    console.error('usage: fl41_query.mjs flag <hex,...> | oneside | trace <id>');
    process.exit(2);
}
