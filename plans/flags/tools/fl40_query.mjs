#!/usr/bin/env node
// fl40_query.mjs - READ-ONLY query helper for the non-bitfield gate iteration (FL40: items, form, counters).
//
// This script WRITES NOTHING. It reads plans/flags/inventory.json and extracted/**/*.asm and prints to stdout.
// It never touches extracted/, db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself if you want to keep it.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl40_query.mjs gate <offset> [n]      # an item site: the body of its &target label, the next lines of its script and the dialog strings they print (text cut to n chars, default 260)
//   node plans/flags/tools/fl40_query.mjs verify                 # every inventory item/switch/direct row: does the file:line still carry the "; {offset}" tag? (tree drift check)
//   node plans/flags/tools/fl40_query.mjs items                  # item COP sites (inventory item_sites) with item name, file:line, offset, scenes
//   node plans/flags/tools/fl40_query.mjs ctx <offset> [b] [a]   # file:line context (b lines before, a after; default 6/10) around a tagged offset
//   node plans/flags/tools/fl40_query.mjs direct [addrHex|all]   # direct accesses outside flag_helpers/save code, grouped by address and file, with the line's comment
//   node plans/flags/tools/fl40_query.mjs direct-md              # the same rows as one markdown table (address, variable, file:line, ROM offset, access, instruction)
//   node plans/flags/tools/fl40_query.mjs scan <regex> [dir]     # rg-like scan of extracted/ (or a subdirectory) for a JS regex; prints file:line and the text
//   node plans/flags/tools/fl40_query.mjs scenes <fileSubstring> # scene ids that place the actors/files matching the substring (from inventory scenes of item sites)
import fs from 'node:fs';
import path from 'node:path';

const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const ROOT = 'extracted';
const cache = new Map();
const lines = (f) => {
    if (!cache.has(f)) cache.set(f, fs.readFileSync(path.join(ROOT, f), 'utf8').split(/\r?\n/));
    return cache.get(f);
};
const ITEM = ['(none)', 'Red Jewel', 'Prison Key', 'Incan Statue A', 'Incan Statue B', 'Incan Melody', 'Herb', 'Blue Block', 'Wind Melody', "Lola's Melody", 'Meat',
    'Mine Key A', 'Mine Key B', 'Memory Melody', 'Crystal Ball', 'Elevator Key', 'Palace Key', 'Purify Stone', 'Statue of Hope', 'Rama Statue', 'Magic Dust',
    'Blue Journal', "Lance's Letter", 'Necklace Stones', 'Will', 'Teapot', 'Mushroom Drop', 'Bag of Gold', 'Black Glasses', 'Gorgon Flower',
    'Hieroglyph 1', 'Hieroglyph 2', 'Hieroglyph 3', 'Hieroglyph 4', 'Hieroglyph 5', 'Hieroglyph 6', 'Aura', "Lola's Letter", "Father's Journal", 'Crystal Ring', 'Red Apple'];
const hex2 = (n) => n.toString(16).toUpperCase().padStart(2, '0');
const name = (id) => (id < ITEM.length ? ITEM[id] : id >= 0x38 && id <= 0x3f ? 'Mystic Statue' : id >= 0x29 ? 'blank' : '?');
const tagLine = (f, off) => {
    const L = lines(f);
    for (let i = 0; i < L.length; i++) if (L[i].includes(`{${off}}`)) return i + 1;
    return -1;
};
const [cmd, a, b, c] = process.argv.slice(2);

if (cmd === 'verify') {
    let bad = 0, n = 0;
    for (const [k, rows] of [['item_sites', inv.item_sites], ['switch_sites', inv.switch_sites], ['direct_accesses', inv.direct_accesses]]) {
        for (const s of rows) {
            n++;
            const L = lines(s.file);
            const ok = L[s.line - 1] && L[s.line - 1].includes(`{${s.offset}}`);
            if (!ok) { bad++; console.log(`DRIFT ${k} ${s.file}:${s.line} offset ${s.offset} (tag now at line ${tagLine(s.file, s.offset)})`); }
        }
    }
    console.log(`${n} rows checked, ${bad} drifted`);
} else if (cmd === 'items') {
    for (const s of inv.item_sites) {
        const sc = (s.scenes ?? []);
        console.log([s.opcode, '$' + hex2(s.itemId), name(s.itemId), s.offset, `${s.file}:${s.line}`, s.operands, sc.length > 8 ? sc.length + ' scenes' : sc.map((x) => '$' + hex2(x)).join(',')].join('\t'));
    }
} else if (cmd === 'ctx') {
    const off = Number(a), before = Number(b ?? 6), after = Number(c ?? 10);
    const rows = [...inv.item_sites, ...inv.switch_sites, ...inv.direct_accesses].filter((s) => s.offset === off);
    let file, line;
    if (rows.length) { file = rows[0].file; line = rows[0].line; }
    else {
        const hits = [];
        const walk = (d) => { for (const e of fs.readdirSync(path.join(ROOT, d), { withFileTypes: true })) { const p = d ? d + '/' + e.name : e.name; if (e.isDirectory()) walk(p); else if (p.endsWith('.asm')) hits.push(p); } };
        walk('');
        for (const f of hits) { const l = tagLine(f, off); if (l > 0) { file = f; line = l; break; } }
    }
    if (!file) { console.log('offset not found'); process.exit(1); }
    const L = lines(file);
    console.log(`== ${file}:${line} offset ${off}`);
    for (let i = Math.max(0, line - 1 - before); i < Math.min(L.length, line + after); i++) console.log(`${i + 1}: ${L[i].slice(0, 230)}`);
} else if (cmd === 'direct') {
    const rows = inv.direct_accesses.filter((s) => s.scope === 'other' && (!a || a === 'all' || s.addressHex.toLowerCase() === a.toLowerCase()));
    rows.sort((x, y) => x.address - y.address || x.file.localeCompare(y.file) || x.line - y.line);
    let last = '';
    for (const s of rows) {
        const k = s.addressHex + ' ' + (s.symbol ?? '');
        if (k !== last) { console.log(`\n### ${k}`); last = k; }
        const t = lines(s.file)[s.line - 1] ?? '';
        const cm = (t.split(';').slice(1).join(';') || '').replace(/\{\d+\}\s*/, '').trim();
        const pv = (lines(s.file)[s.line - 2] ?? '').replace(/\{\d+\}\s*/, '').replace(/\s+/g, ' ').trim().slice(0, 70);
        console.log(`${s.file}:${s.line}\t${s.offset}\t${s.access}\t${s.opcode} ${s.operands}\t${cm.slice(0, 150)}${cm ? '' : '\t[prev: ' + pv + ']'}`);
    }
} else if (cmd === 'direct-md') {
    // Markdown table of every direct access row outside flag_helpers/save code (stdout only; redirect it yourself).
    const rows = inv.direct_accesses.filter((s) => s.scope === 'other');
    rows.sort((x, y) => x.address - y.address || x.file.localeCompare(y.file) || x.line - y.line);
    console.log('| Address | Variable | Site (file:line) | ROM offset | Access | Instruction |');
    console.log('|---|---|---|---|---|---|');
    for (const s of rows) {
        console.log(`| ${s.addressHex} | ${s.symbol ?? 'unnamed'} | \`${s.file}:${s.line}\` | ${s.offset} | ${s.access} | \`${s.opcode} ${s.operands}\` |`);
    }
} else if (cmd === 'gate') {
    const off = Number(a), cut = Number(b ?? 260);
    const s = inv.item_sites.find((x) => x.offset === off);
    if (!s) { console.log('not an item site'); process.exit(1); }
    const L = lines(s.file);
    console.log(`== ${s.opcode} ${name(s.itemId)} ${s.file}:${s.line} offset ${off}`);
    const dlg = (txt) => {
        for (const d of txt.matchAll(/&(?:[A-Za-z0-9_]+\.)?(dialogstring_[0-9A-F]+)/g)) {
            if (seenDlg.has(d[1])) continue;
            seenDlg.add(d[1]);
            const j = L.findIndex((t) => t.startsWith(d[1] + ' `'));
            if (j >= 0) console.log('    ' + d[1] + ': ' + L[j].slice(d[1].length + 2, d[1].length + 2 + cut));
        }
    };
    const seenDlg = new Set();
    const body = (label) => {
        const i = L.findIndex((t) => t.replace(/^\s+/, '').startsWith(label + ' {') || t.replace(/^\s+/, '').startsWith(label + ':'));
        if (i < 0) return [];
        const out = [];
        for (let k = i; k < Math.min(L.length, i + 40); k++) { out.push(`${k + 1}: ${L[k].slice(0, 170)}`); if (/^\}/.test(L[k])) break; }
        return out;
    };
    const m = s.operands.match(/&([A-Za-z0-9_.]+)/);
    if (m) {
        const b2 = body(m[1].split('.').pop());
        b2.forEach((x) => console.log('  target ' + x));
        dlg(b2.join('\n'));
    }
    for (let k = s.line; k < Math.min(L.length, s.line + 10); k++) { console.log('  next ' + (k + 1) + ': ' + L[k].slice(0, 170)); if (/^\}/.test(L[k])) break; }
    for (let k = s.line - 6; k < Math.min(L.length, s.line + 12); k++) dlg(L[k] ?? '');
} else if (cmd === 'scan') {
    const re = new RegExp(a);
    const base = b ? b : '';
    const walk = (d) => { for (const e of fs.readdirSync(path.join(ROOT, d), { withFileTypes: true })) { const p = d ? d + '/' + e.name : e.name; if (e.isDirectory()) walk(p); else if (p.endsWith('.asm')) { lines(p).forEach((t, i) => { if (re.test(t)) console.log(`${p}:${i + 1}\t${t.slice(0, 200)}`); }); } } };
    walk(base);
} else if (cmd === 'scenes') {
    for (const s of inv.item_sites.filter((s) => s.file.includes(a))) console.log(`${s.file}:${s.line}\t${(s.scenes ?? []).map((x) => '$' + hex2(x)).join(',')}`);
} else {
    console.log('commands: verify | items | ctx <offset> [b] [a] | direct [addrHex|all] | scan <regex> [dir] | scenes <substr>');
}
