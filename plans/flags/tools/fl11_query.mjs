#!/usr/bin/env node
// fl11_query.mjs - READ-ONLY query helper for the FL11 analysis (event blocks, death actions).
//
// This script WRITES NOTHING. It reads only:
//   rebuilt/Illusion of Gaia.smc           (2 MB original image, no header; offsets are decimal file offsets)
//   extracted/tables/scene_actors.asm      (joined to the ROM rows for file:line and actor labels)
//   extracted/system/event_block_table.asm (the event-block-def rows)
//   extracted/**/*.asm                     (COP site scans; offsets come from the "; {n}" line-tracking tags)
//   plans/flags/inventory.json             (FL01 site list, for the flag-index join)
// and prints to stdout. It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl11_query.mjs rows [all]        # decoded scene_actors spawn rows with event-block byte != 0 (or all rows)
//   node plans/flags/tools/fl11_query.mjs actor <label>     # every spawn row whose actor label contains <label>
//   node plans/flags/tools/fl11_query.mjs blocks            # event_block_table rows with their index n (hex) and tag
//   node plans/flags/tools/fl11_query.mjs bgsites           # every COP StageBgChange site: file:line, offset, operand (hex), enclosing scene(s)
//   node plans/flags/tools/fl11_query.mjs usage             # per event block n: all users (flag word COP, helper, StageBgChange, death-action rows)
//   node plans/flags/tools/fl11_query.mjs spine             # per D3 index: the groups touching it (flag COP sites, StageBgChange sites, death-row scene group, block scene group)
//   node plans/flags/tools/fl11_query.mjs unused <lo> <hi>  # per index in [lo,hi] (hex): inventory sites, narrow helper-call indices, trace candidates, literal "$01xx" lines on a Flag/Event line
//   node plans/flags/tools/fl11_query.mjs verify            # cross-check: ROM decode vs asm rows (count, x, y, stats, enemyNum, block)
import fs from 'node:fs';
import path from 'node:path';

const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');

// ---------- ROM decode of scene_actors ----------
function decodeRom() {
  const rows = [];
  const BASE = 786432; // 0xC0000: bank $0C of the extraction, record pointers are $8xxx
  const seen = new Set();
  for (let sc = 0; sc < 256; sc++) {
    const ptr = ROM[819200 + sc * 2] | (ROM[819200 + sc * 2 + 1] << 8);
    const start = BASE + ptr;
    if (seen.has(start)) { continue; } // 16 unused ids share the default record
    seen.add(start);
    let o = start, idx = 0;
    while (ROM[o] !== 0xFF) {
      const r = { scene: sc, idx, offset: o, x: ROM[o], y: ROM[o + 1], attr: ROM[o + 2], code: ROM[o + 3] | (ROM[o + 4] << 8), bank: ROM[o + 5], stats: ROM[o + 6] };
      if (r.stats) { r.num = ROM[o + 7]; r.block = ROM[o + 8]; r.len = 9; } else { r.len = 7; }
      rows.push(r);
      o += r.len; idx++;
    }
  }
  return rows;
}

// ---------- asm side ----------
function parseSceneActorsAsm() {
  const lines = fs.readFileSync('extracted/tables/scene_actors.asm', 'utf8').split(/\r?\n/);
  const rows = [];
  let scene = null;
  lines.forEach((l, i) => {
    let m = /^scene_([0-9A-F]{2})_actors \[/.exec(l);
    if (m) { scene = parseInt(m[1], 16); return; }
    if (/^scene_default_actors \[/.test(l)) { scene = 'default'; return; }
    if (/^\]/.test(l)) { scene = null; return; }
    m = /^\s+(enemy|actor)-spawn < (.*) >\s+;([0-9A-F]+)\s*$/.exec(l);
    if (m && scene !== null) {
      const ops = m[2].split(',').map(s => s.trim());
      rows.push({ scene, idx: parseInt(m[3], 16), kind: m[1], line: i + 1, ops, text: l.trim() });
    }
  });
  return rows;
}

function joined() {
  const rom = decodeRom();
  const asm = parseSceneActorsAsm();
  const key = r => `${r.scene}:${r.idx}`;
  const am = new Map(asm.map(r => [key(r), r]));
  const out = [];
  for (const r of rom) {
    const a = am.get(key(r));
    if (a) {
      r.line = a.line; r.label = a.ops[3]; r.asmOps = a.ops;
    }
    out.push(r);
  }
  return out;
}

function parseBlocks() {
  const lines = fs.readFileSync('extracted/system/event_block_table.asm', 'utf8').split(/\r?\n/);
  const out = [];
  lines.forEach((l, i) => {
    const m = /event-block-def < (.*) >\s+;([0-9A-F]{2})/.exec(l);
    if (m) {
      const v = m[1].split(',').map(s => parseInt(s.trim().replace('#', ''), 16));
      out.push({ n: parseInt(m[2], 16), line: i + 1, scene: v[0], sx: v[1], sy: v[2], w: v[3], h: v[4], dx: v[5], dy: v[6], layer: v[7] });
    }
  });
  return out;
}

function walk(d) {
  return fs.readdirSync(d, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(d + '/' + e.name) : e.name.endsWith('.asm') ? [d + '/' + e.name] : []);
}

function bgSites() {
  const out = [];
  for (const f of walk('extracted')) {
    const lines = fs.readFileSync(f, 'utf8').split(/\r?\n/);
    lines.forEach((l, i) => {
      const m = /COP \[(StageBgChange|StageBgChangeFromDeathIdx|ApplyBgChange)\](?: \( #([0-9A-Fa-f]+) \))?.*?; \{(\d+)\}/.exec(l);
      if (m) out.push({ file: f.replace('extracted/', ''), line: i + 1, op: m[1], operand: m[2] === undefined ? null : parseInt(m[2], 16), offset: parseInt(m[3], 10) });
    });
  }
  return out;
}

const [cmd, a] = process.argv.slice(2);
if (cmd === 'rows') {
  const j = joined();
  for (const r of j.filter(r => a === 'all' || (r.stats && r.block))) {
    console.log([r.offset, 'scene ' + hex(r.scene), '#' + hex(r.idx), 'asm:' + (r.line ?? '?'), r.label ?? '?', `xy ${hex(r.x)},${hex(r.y)}`, `attr ${hex(r.attr)}`, r.stats ? `stats ${hex(r.stats)} enemyNum ${hex(r.num)} block ${hex(r.block)}` : 'no-stats'].join('\t'));
  }
} else if (cmd === 'actor') {
  for (const r of joined().filter(r => (r.label ?? '').includes(a))) {
    console.log([r.offset, 'scene ' + hex(r.scene), '#' + hex(r.idx), 'asm:' + (r.line ?? '?'), r.label, `xy ${hex(r.x)},${hex(r.y)}`, `attr ${hex(r.attr)}`, r.stats ? `stats ${hex(r.stats)} enemyNum ${hex(r.num)} block ${hex(r.block)}` : 'no-stats'].join('\t'));
  }
} else if (cmd === 'blocks') {
  for (const b of parseBlocks()) console.log(`${hex(b.n)}\tasm:${b.line}\tscene ${hex(b.scene)}\tsrc ${hex(b.sx)},${hex(b.sy)}\t${b.w}x${b.h}\tdst ${hex(b.dx)},${hex(b.dy)}\tlayer ${b.layer}`);
} else if (cmd === 'bgsites') {
  for (const s of bgSites().sort((x, y) => x.offset - y.offset)) console.log(`${s.offset}\t${s.file}:${s.line}\t${s.op}\t${s.operand === null ? '' : '#' + hex(s.operand)}`);
} else if (cmd === 'usage') {
  const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
  const blocks = parseBlocks();
  const rows = joined().filter(r => r.stats && r.block);
  const bg = bgSites().filter(s => s.op === 'StageBgChange');
  for (const b of blocks) {
    const n = b.n, flag = 0x100 + n;
    const f = inv.sites.filter(s => s.index === flag).map(s => `${s.opcode} ${s.file}:${s.line} {${s.offset}}`);
    const h = inv.helper_calls.filter(h => (h.indices || []).includes(flag) && /_0100/.test(h.helper)).length;
    const bgs = bg.filter(s => s.operand === n).map(s => `${s.file}:${s.line} {${s.offset}}`);
    const dr = rows.filter(r => r.block === n).map(r => `${hex(r.scene)}#${hex(r.idx)} ${r.label} {${r.offset}} asm:${r.line}`);
    console.log(`n=${hex(n)} flag=${hex(flag, 4)} scene=${hex(b.scene)}\n  flagCOP: ${f.join(' | ') || '-'}\n  StageBgChange: ${bgs.join(' | ') || '-'}\n  deathRows: ${dr.join(' | ') || '-'}`);
  }
} else if (cmd === 'spine') {
  const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
  const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
  const sceneGroup = new Map();
  for (const [g, v] of Object.entries(groups)) for (const sc of Object.values(v.scenes || {})) sceneGroup.set(sc.id, g);
  const grp = f => f.split('/')[0];
  const blocks = parseBlocks();
  const rows = joined().filter(r => r.stats && r.block);
  const bg = bgSites().filter(s => s.op === 'StageBgChange');
  for (const b of blocks) {
    const flag = 0x100 + b.n;
    const g = new Set();
    const bits = [];
    for (const s of inv.sites.filter(s => s.index === flag)) { g.add(grp(s.file)); bits.push('cop:' + grp(s.file)); }
    for (const s of bg.filter(s => s.operand === b.n)) { g.add(grp(s.file)); bits.push('bg:' + grp(s.file)); }
    for (const r of rows.filter(r => r.block === b.n)) { const sg = sceneGroup.get(r.scene) || '?'; g.add(sg); bits.push('death:' + sg); }
    const bsg = sceneGroup.get(b.scene) || '?';
    g.add(bsg);
    console.log(`${hex(flag, 4)} blockScene=${hex(b.scene)}(${bsg}) n=${g.size} groups=${[...g].sort().join(',')}  ${[...new Set(bits)].join(' ')}`);
  }
} else if (cmd === 'unused') {
  const lo = parseInt(process.argv[3], 16), hi = parseInt(process.argv[4], 16);
  const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
  const texts = [];
  (function w(d) { for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) w(p); else if (e.name.endsWith('.asm')) texts.push([p, fs.readFileSync(p, 'utf8')]); } })('extracted');
  for (let n = lo; n <= hi; n++) {
    const sites = inv.sites.filter(s => s.index === n).length;
    const hc = inv.helper_calls.filter(h => (h.indices || []).includes(n) && h.indices.length < 64).length;
    const tc = inv.traces.filter(t => (t.candidates || []).some(c => (typeof c === 'number' ? c : c.index) === n)).map(t => t.id);
    const hx = hex(n, 4);
    const re = new RegExp('\\$' + hx + '\\b', 'i');
    let lit = 0;
    for (const [, t] of texts) if (t.split('\n').some(l => re.test(l) && !/^\s*;/.test(l) && /Flag|Event/i.test(l))) lit++;
    console.log(`${hx} sites=${sites} narrowHelperCalls=${hc} traces=[${tc.join(',')}] filesWithFlagLiteral=${lit}`);
  }
} else if (cmd === 'verify') {
  const rom = decodeRom();
  const asm = parseSceneActorsAsm();
  console.log('rom rows', rom.length, 'asm rows', asm.length);
  const am = new Map(asm.map(r => [`${r.scene}:${r.idx}`, r]));
  let bad = 0, miss = 0;
  for (const r of rom) {
    const x = am.get(`${r.scene}:${r.idx}`);
    if (!x) { miss++; if (miss < 5) console.log('no asm row for', r.scene, r.idx, r.offset); continue; }
    const v = s => parseInt(s.replace('#', ''), 16);
    const ok = v(x.ops[0]) === r.x && v(x.ops[1]) === r.y && v(x.ops[2]) === r.attr && (r.stats ? (x.ops.length === 7 && v(x.ops[4]) === r.stats && v(x.ops[5]) === r.num && v(x.ops[6]) === r.block) : x.ops.length === 4);
    if (!ok) { bad++; if (bad < 10) console.log('MISMATCH', r.scene, r.idx, r.offset, x.text); }
  }
  console.log('unmatched rom rows', miss, 'mismatches', bad);
} else {
  console.error('see the header of this file for the commands');
  process.exit(1);
}
