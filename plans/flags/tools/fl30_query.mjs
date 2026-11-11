#!/usr/bin/env node
// fl30_query.mjs - READ-ONLY query helper for the engine-owned flag iteration (FL30).
//
// This script WRITES NOTHING: it reads extracted/tables/scene_actors.asm, scene_thinkers.asm (and, for `unplaced`,
// the extracted/**/*.asm file list) and plans/flags/inventory.json, and prints to stdout. It never touches extracted/,
// db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself if you want to keep it.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl30_query.mjs placed <actorLabel>[,<label>...]   # scenes whose actor list spawns the actor (with line, tile, slot)
//   node plans/flags/tools/fl30_query.mjs paramrows <actorLabel>             # every placement with its three spawn operands
//   node plans/flags/tools/fl30_query.mjs thinkers <thinkerLabel>            # scenes whose thinker list spawns the thinker
//   node plans/flags/tools/fl30_query.mjs scenes-of <hexFlag> <dirPrefix>    # literal COP sites of one index with their scene lists, one scene id per site, decimal
//   node plans/flags/tools/fl30_query.mjs bits <decimalOffset> [n]           # hex dump of the original ROM (rebuilt/Illusion of Gaia.smc) at a tagged offset
import fs from 'node:fs';

const rd = (f) => fs.readFileSync('extracted/tables/' + f, 'utf8').split(/\r?\n/);
const hex2 = (n) => n.toString(16).toUpperCase().padStart(2, '0');
const [cmd, a, b] = process.argv.slice(2);

function actorBlocks() {
    const lines = rd('scene_actors.asm');
    const out = [];
    let cur = null;
    lines.forEach((l, i) => {
        const h = l.match(/^(scene_([0-9A-F]{2})_actors|scene_default_actors) \[/);
        if (h) cur = { label: h[1], id: h[2] ? parseInt(h[2], 16) : null, line: i + 1, rows: [] };
        else if (l.startsWith(']')) { if (cur) out.push(cur); cur = null; }
        else if (cur) {
            const m = l.match(/actor-spawn < #([0-9A-F$]+), #([0-9A-F$]+), #([0-9A-F$]+), @?([A-Za-z0-9_.]+) >\s*;([0-9A-F]{2})/);
            if (m) cur.rows.push({ line: i + 1, x: m[1], y: m[2], p: m[3], actor: m[4], slot: m[5] });
        }
    });
    return out;
}

if (cmd === 'placed' || cmd === 'paramrows') {
    const names = a.split(',');
    for (const blk of actorBlocks()) {
        for (const r of blk.rows) {
            if (names.some((n) => r.actor === n || r.actor.endsWith('.' + n))) {
                console.log(`scene ${blk.id === null ? 'default' : '$' + hex2(blk.id) + ' (' + blk.id + ')'}\tscene_actors.asm:${r.line}\tslot ${r.slot}\ttile (${r.x},${r.y})\tparam #${r.p}\t${r.actor}`);
            }
        }
    }
} else if (cmd === 'thinkers') {
    const lines = rd('scene_thinkers.asm');
    let cur = null;
    lines.forEach((l, i) => {
        const h = l.match(/^([A-Za-z0-9_]+) \[/);
        if (h) cur = h[1];
        if (cur && l.includes(a)) console.log(`scene_thinkers.asm:${i + 1}\tlist ${cur}\t${l.trim()}`);
    });
    const tbl = lines.findIndex((l) => l.startsWith('scene_thinkers ['));
    console.log('(list label -> scene id: see rows `scene_thinkers [` from line ' + (tbl + 1) + ')');
} else if (cmd === 'scenes-of') {
    const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
    const n = parseInt(a, 16);
    for (const s of inv.sites.filter((s) => s.index === n && (!b || s.file.startsWith(b)))) {
        console.log(`${s.file}:${s.line}\t${s.offset}\t${s.opcode}\t${s.role}\tscenes ${(s.scenes ?? []).join(',')}`);
    }
} else if (cmd === 'bits') {
    const off = parseInt(a, 10), n = parseInt(b ?? '16', 10);
    const rom = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
    console.log(off + ': ' + [...rom.subarray(off, off + n)].map((x) => x.toString(16).padStart(2, '0')).join(' '));
} else {
    console.error('usage: placed|paramrows|thinkers|scenes-of|bits (see the header)');
    process.exit(1);
}
