#!/usr/bin/env node
// fl_scene_map.mjs - READ-ONLY scene placement query over extracted/tables/*.asm.
//
// This script WRITES NOTHING: it reads extracted/tables/scene_actors.asm, scene_thinkers.asm, scene_warps.asm,
// scene_chest_table.asm and scene_meta.asm and prints to stdout. It never touches extracted/, db-us/, notes/, docs/,
// src/ or any other file. Redirect its output yourself if you want to keep it.
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl_scene_map.mjs <hexSceneId>[,<hexSceneId>...]
//   node plans/flags/tools/fl_scene_map.mjs enter <hexSceneId>      # list every warp (any scene) whose destination is the scene
//
// For each scene it prints: actor list (spawn index, tile x/y, attribute, actor; enemy records with stats, enemy number,
// event-block / death-action index), the thinker list the scene points at, the scene-warp rectangles with their
// destination scene, and the `branch <flag, label>` commands of the scene_meta record (D9 gates).
import fs from 'node:fs';

const rd = (f) => fs.readFileSync('extracted/tables/' + f, 'utf8').split(/\r?\n/);
const actors = rd('scene_actors.asm');
const thinkers = rd('scene_thinkers.asm');
const warps = rd('scene_warps.asm');
const meta = rd('scene_meta.asm');

const blockOf = (lines, label) => {
    const start = lines.findIndex((l) => l.startsWith(label + ' ['));
    if (start < 0) return null;
    let end = start + 1;
    while (end < lines.length && !lines[end].startsWith(']')) end++;
    return { start, lines: lines.slice(start, end + 1) };
};
const pointerRow = (lines, tableLabel, idHex) => {
    const start = lines.findIndex((l) => l.startsWith(tableLabel + ' ['));
    for (let i = start + 1; i < lines.length && !lines[i].startsWith(']'); i++) {
        const m = lines[i].match(/^\s*&?([A-Za-z0-9_+#$]+)\s*;([0-9A-F]{2})\s*$/);
        if (m && m[2] === idHex) return m[1];
    }
    return null;
};

const arg = process.argv[2];
if (arg === 'enter') {
    const target = (process.argv[3] ?? '').toUpperCase().padStart(2, '0');
    let cur = null;
    warps.forEach((l, i) => {
        const h = l.match(/^(warp_def_[0-9A-F]{2}|warp_def_empty) \[/);
        if (h) cur = h[1];
        const w = l.match(/scene-warp < #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}),/);
        if (w && w[5] === target) console.log(`${cur} (line ${i + 1}) rect x${w[1]} y${w[2]} ${w[3]}x${w[4]} -> ${target}`);
    });
    process.exit(0);
}
for (const id of (arg ?? '').split(',').filter(Boolean).map((x) => x.toUpperCase().padStart(2, '0'))) {
    console.log(`===== scene $${id} (${parseInt(id, 16)})`);
    const a = blockOf(actors, `scene_${id}_actors`);
    if (a) {
        console.log(`-- actors (extracted/tables/scene_actors.asm:${a.start + 1})`);
        for (const l of a.lines.slice(1, -1)) console.log(l.trim());
    }
    const tp = pointerRow(thinkers, 'scene_thinkers', id);
    console.log(`-- thinker list: ${tp}`);
    const base = tp?.replace(/^thinker_spawn_/, 'thinker_spawn_').split('+')[0];
    const tb = base ? blockOf(thinkers, base) : null;
    if (tb) for (const l of tb.lines.slice(1, -1)) console.log('   ' + l.trim());
    const wp = pointerRow(warps, 'scene_warps', id);
    console.log(`-- warps: ${wp}`);
    const wb = wp ? blockOf(warps, wp) : null;
    if (wb) for (const l of wb.lines) if (/scene-warp|stair-warp/.test(l)) console.log('   ' + l.trim());
    const mb = blockOf(meta, `scene_meta_00${id}`);
    if (mb) {
        const gates = mb.lines.filter((l) => /branch </.test(l));
        console.log(`-- scene_meta_00${id} (line ${mb.start + 1}): ${gates.length ? gates.map((g) => g.trim()).join(' | ') : 'no branch gate'}`);
    }
}
