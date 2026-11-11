#!/usr/bin/env node
// fl_query.mjs - READ-ONLY query helper over plans/flags/inventory.json (FL01 output).
//
// This script WRITES NOTHING: it only reads plans/flags/inventory.json and (for `rom`) the original ROM image
// `rebuilt/Illusion of Gaia.smc`, and prints to stdout. It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl_query.mjs symrefs                  # direct accesses that name $eventFlags/$wramFlags (flagSymbol rows)
//   node plans/flags/tools/fl_query.mjs bytes [lo] [hi]          # per-byte direct access summary, hex addresses, default 0A00 0AB3
//   node plans/flags/tools/fl_query.mjs gates                    # the $13 scene-meta gates
//   node plans/flags/tools/fl_query.mjs index <hex>              # every COP/helper/gate site of one global flag index (e.g. FF, 0170)
//   node plans/flags/tools/fl_query.mjs byte <hex>               # every site that touches the flag array byte (e.g. 0A1F) via COP/helper/direct
//   node plans/flags/tools/fl_query.mjs rom <decimalOffset> [n]  # hex dump of the original ROM at a tagged offset
//   node plans/flags/tools/fl_query.mjs scanaddr [loHex] [hiHex] [list]  # independent rescan of extracted/ for operands in a WRAM range
//   node plans/flags/tools/fl_query.mjs counts                   # index -> site counts (S/C/T/W/helper) for a range: counts <loHex> <hiHex>
import fs from 'node:fs';

const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const [cmd, a, b] = process.argv.slice(2);
const hex = (n, w = 4) => '$' + n.toString(16).toUpperCase().padStart(w, '0');

if (cmd === 'symrefs') {
    for (const d of inv.direct_accesses.filter(d => d.flagSymbol)) {
        console.log(`${d.offset}\t${d.file}:${d.line}\t${d.opcode} ${d.operands}\t${d.access}\t${d.width}\t${d.addressHex}`);
    }
} else if (cmd === 'bytes') {
    const lo = parseInt(a ?? '0A00', 16), hi = parseInt(b ?? '0AB3', 16);
    const m = new Map();
    for (const d of inv.direct_accesses) {
        if (d.address < lo || d.address > hi) continue;
        const e = m.get(d.address) ?? { sym: new Set(), r: 0, w: 0, files: new Set() };
        if (d.symbol) e.sym.add(d.symbol);
        if (d.access === 'read') e.r++; else e.w++;
        e.files.add(d.file);
        m.set(d.address, e);
    }
    for (const k of [...m.keys()].sort((x, y) => x - y)) {
        const e = m.get(k);
        console.log(`${hex(k)}\t${[...e.sym].join(',') || '-'}\tR${e.r} W${e.w}\tfiles ${e.files.size}`);
    }
} else if (cmd === 'gates') {
    for (const s of inv.sites.filter(s => s.kind === 'scene_gate')) {
        console.log(`${s.offset}\t${s.file}:${s.line}\trecord ${hex(s.record, 2)}\tflag ${hex(s.index)}\tlabel ${hex(s.label, 2)}\tscenes ${s.scenes.map(x => hex(x, 2)).join(',')}`);
    }
} else if (cmd === 'index') {
    const n = parseInt(a, 16);
    for (const s of inv.sites.filter(s => s.index === n)) {
        console.log(`${s.offset}\t${s.file}:${s.line}\t${s.kind}\t${s.opcode}\t${s.operands}\t${s.role}\t${s.sense ?? ''}\tscenes ${(s.scenes ?? []).map(x => hex(x, 2)).join(',')}`);
    }
} else if (cmd === 'byte') {
    const addr = parseInt(a, 16);
    const lo = (addr - 0xA00) * 8, hi = lo + 7;
    for (const s of inv.sites.filter(s => s.index >= lo && s.index <= hi)) {
        console.log(`${s.offset}\t${s.file}:${s.line}\t${s.kind}\t${s.opcode}\t${s.operands}\t${s.role}\tidx ${hex(s.index)}`);
    }
    for (const d of inv.direct_accesses.filter(d => d.address === addr)) {
        console.log(`${d.offset}\t${d.file}:${d.line}\tdirect\t${d.opcode}\t${d.operands}\t${d.access}`);
    }
} else if (cmd === 'rom') {
    const off = parseInt(a, 10), n = parseInt(b ?? '16', 10);
    const rom = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
    console.log(off + ': ' + [...rom.subarray(off, off + n)].map(x => x.toString(16).padStart(2, '0')).join(' '));
} else if (cmd === 'counts') {
    const lo = parseInt(a, 16), hi = parseInt(b, 16);
    const m = new Map();
    for (const s of inv.sites) {
        if (s.index === undefined || s.index < lo || s.index > hi) continue;
        const e = m.get(s.index) ?? { set: 0, clear: 0, test: 0, wait: 0, other: 0, files: new Set() };
        if (s.role === 'set') e.set++; else if (s.role === 'clear') e.clear++; else if (s.role === 'branch') e.test++;
        else if (s.role === 'wait') e.wait++; else e.other++;
        e.files.add(s.file);
        m.set(s.index, e);
    }
    for (const k of [...m.keys()].sort((x, y) => x - y)) {
        const e = m.get(k);
        console.log(`${hex(k)}\tS${e.set} C${e.clear} T${e.test} W${e.wait} o${e.other}\tfiles ${e.files.size}`);
    }
} else if (cmd === 'scanaddr') {
    // Independent re-scan of extracted/**/*.asm (comments stripped) for operands in [lo, hi] (hex): `$0AA4`, `$00:0AA4`-style
    // 4/6-digit literals and `!symbol` aliases with an optional `+n` offset. Prints address -> sites. Independent of inventory.json.
    const lo = parseInt(a ?? '0A00', 16), hi = parseInt(b ?? '0AB3', 16);
    const walk = d => fs.readdirSync(d, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(d + '/' + e.name) : e.name.endsWith('.asm') ? [d + '/' + e.name] : []);
    const hits = new Map();
    for (const f of walk('extracted')) {
        const lines = fs.readFileSync(f, 'utf8').split(/\r?\n/);
        const syms = new Map();
        for (const l of lines) {
            const m = /^!(\w+)\s+([0-9A-Fa-f]{4,6})\s*$/.exec(l);
            if (m) syms.set(m[1], parseInt(m[2], 16) & 0xFFFFFF);
        }
        lines.forEach((raw, i) => {
            const code = raw.split(';')[0];
            if (!/^\s+[A-Z]{3}\b/.test(code)) return; // instruction lines only
            for (const m of code.matchAll(/\$(?:([0-9A-Fa-f]{2})|([0-9A-Fa-f]{4}))([0-9A-Fa-f]{4})?\b|\$(\w+)(?:\+([0-9A-Fa-f]+))?/g)) {
                let addr = null, bank = 0;
                if (m[4] && syms.has(m[4])) { const v = syms.get(m[4]); bank = v >> 16; addr = (v & 0xFFFF) + (m[5] ? parseInt(m[5], 16) : 0); }
                else if (m[3] === undefined && m[2]) addr = parseInt(m[2], 16);
                else if (m[1] && m[3]) { bank = parseInt(m[1], 16); addr = parseInt(m[3], 16); }
                if (addr === null || addr < lo || addr > hi) continue;
                if (bank !== 0 && bank !== 0x7E && bank !== 0x80 && bank !== 0x81) continue; // $7F:0Axxx etc. is not the flag page
                const k = hex(addr);
                (hits.get(k) ?? hits.set(k, []).get(k)).push(`${f.replace('extracted/', '')}:${i + 1} ${code.trim()}`);
            }
        });
    }
    for (const k of [...hits.keys()].sort()) console.log(`${k}\t${hits.get(k).length} sites\t${[...new Set(hits.get(k).map(s => s.split(':')[0]))].length} files`);
    if (process.argv[5] === 'list') for (const k of [...hits.keys()].sort()) for (const s of hits.get(k)) console.log(k, s);
} else {
    console.error('see the header of this file for the commands');
    process.exit(1);
}
