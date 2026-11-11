#!/usr/bin/env node
// fl32_scenes.mjs - READ-ONLY per-scene facts for the FL32 scene-entry classification.
//
// This script WRITES NOTHING: it reads extracted/**/*.asm, plans/flags/inventory.json and db-us/groups.json and prints
// to stdout (redirect it yourself if you want to keep it). It never touches extracted/, db-us/, notes/, docs/, src/.
//
// For every scene id of db-us/groups.json it joins:
//   - the actors placed by tables/scene_actors.asm and the actor file of each (label at column 0 -> file)
//   - the joypad-lock writes of each actor file (TSB/STA/ORA to $joypadMaskStd) and the persistent flags that file tests
//   - the thinkers, the change-scene warps (scene-warp rectangles, destination scene) and the QueueMapChange targets
//     of every placed actor file (destination scene = first operand)
// Usage (run from the repo root):
//   node plans/flags/tools/fl32_scenes.mjs facts [<hexSceneId>[,<hexSceneId>...]]   # per-scene fact lines
//   node plans/flags/tools/fl32_scenes.mjs edges                                   # directed edges: src scene -> dest scene (kind, site)
//   node plans/flags/tools/fl32_scenes.mjs reach                                   # scenes with no inbound edge, and the reachable set from scene $8C/$FC
//   node plans/flags/tools/fl32_scenes.mjs json                                    # everything as JSON on stdout
import fs from 'node:fs';
import { hex, loadGroups, loadInventory, labelIndex, loadSceneActors, loadSceneThinkers, loadSceneWarps, loadSceneMetaGates, readLines, asmFiles } from './fl32_lib.mjs';

const { scenes } = loadGroups();
const inv = loadInventory();
const labels = labelIndex();
const placed = loadSceneActors();
const thinkers = loadSceneThinkers();
const warps = loadSceneWarps();
const gates = loadSceneMetaGates(inv);

const fileOfActor = (lab) => {
    const parts = lab.split('.');
    return labels.get(parts[parts.length - 1]) ?? labels.get(parts[0]) ?? null;
};

// per-file facts, cached
const fileCache = new Map();
const lockRe = /\b(TSB|STA|ORA|TRB)\s+\$joypadMaskStd/;
function fileFacts(f) {
    if (fileCache.has(f)) return fileCache.get(f);
    const lines = readLines('extracted/' + f);
    const locks = [];
    const qmc = [];
    lines.forEach((l, i) => {
        if (lockRe.test(l)) {
            const tag = l.match(/\{(\d+)\}/);
            locks.push({ line: i + 1, op: l.trim().split(/\s+/)[0], offset: tag ? Number(tag[1]) : null, prev: (lines[i - 1] ?? '').trim() });
        }
        const q = l.match(/COP \[QueueMapChange\] \( #([0-9A-F]{2})/);
        if (q) qmc.push({ line: i + 1, dest: parseInt(q[1], 16), offset: (l.match(/\{(\d+)\}/) ?? [])[1] });
    });
    const tests = inv.sites.filter((s) => s.file === f && s.index != null && s.index >= 16 && (s.role === 'branch' || s.role === 'wait')).map((s) => s.index);
    const facts = { locks, qmc, tests: [...new Set(tests)].sort((a, b) => a - b) };
    fileCache.set(f, facts);
    return facts;
}

const sceneFacts = new Map();
for (const [id, sc] of scenes) {
    const p = placed.get(id);
    const actorFiles = new Map();
    for (const a of p?.actors ?? []) {
        const f = fileOfActor(a.label);
        const key = f ?? '(unresolved:' + a.label + ')';
        if (!actorFiles.has(key)) actorFiles.set(key, []);
        actorFiles.get(key).push(a.label);
    }
    const lockFiles = [];
    const qmc = [];
    for (const [f, labs] of actorFiles) {
        if (f.startsWith('(')) continue;
        const ff = fileFacts(f);
        if (ff.locks.length) lockFiles.push({ file: f, labels: [...new Set(labs)], locks: ff.locks, tests: ff.tests });
        for (const q of ff.qmc) qmc.push({ file: f, ...q });
    }
    sceneFacts.set(id, {
        id, group: sc.group, desc: sc.desc,
        actors: p?.actors.length ?? 0,
        placedLabel: p?.label ?? null,
        lockFiles,
        qmc,
        thinkers: thinkers.get(id) ?? [],
        warps: (warps.get(id) ?? []).map((w) => ({ dest: w.dest, line: w.line })),
        gates: gates.get(id) ?? [],
    });
}

// global QueueMapChange sources (files with a QMC that are not actor-placed by any scene, e.g. world map options)
const placedFiles = new Set();
for (const sf of sceneFacts.values()) for (const lf of sf.lockFiles) placedFiles.add(lf.file);
const allPlacedFiles = new Set();
for (const [id, p] of placed) for (const a of p.actors) { const f = fileOfActor(a.label); if (f) allPlacedFiles.add(f); }
const globalQmc = [];
for (const f of asmFiles()) {
    if (allPlacedFiles.has(f)) continue;
    const ff = fileFacts(f);
    for (const q of ff.qmc) globalQmc.push({ file: f, ...q });
}

// edges
const edges = [];
for (const sf of sceneFacts.values()) {
    for (const w of sf.warps) edges.push({ from: sf.id, to: w.dest, kind: 'scene-warp', site: 'tables/scene_warps.asm:' + w.line });
    for (const q of sf.qmc) edges.push({ from: sf.id, to: q.dest, kind: 'QueueMapChange', site: `${q.file}:${q.line} {${q.offset}}` });
}
for (const q of globalQmc) edges.push({ from: 'global:' + q.file, to: q.dest, kind: 'QueueMapChange', site: `${q.file}:${q.line} {${q.offset}}` });

/** Reachability over real edges: roots boot/title/diary/load; debug and unused sources are dropped. */
function reachSet() {
    const out = new Map();
    const real = edges.filter((e) => typeof e.from === 'number' || (e.from.startsWith('global:') && !/debug_man|unused\//.test(e.from)));
    // scenes that place the overworld_exit actor can reach the world map ($FE); the world map reaches the options targets
    const exitScenes = new Set();
    for (const sf of sceneFacts.values()) {
        const p = placed.get(sf.id);
        if ((p?.actors ?? []).some((a) => /overworld_exit/.test(a.label))) exitScenes.add(sf.id);
    }
    const adj = new Map();
    const add = (a, b) => { if (!adj.has(a)) adj.set(a, new Set()); adj.get(a).add(b); };
    for (const e of real) {
        if (typeof e.from === 'number') add(e.from, e.to);
        else if (/world_map_options/.test(e.from)) add(0xfe, e.to);
        else add('*', e.to);
    }
    for (const s of exitScenes) add(s, 0xfe);
    const queue = [0xfb, 0xfc, 0xfa, 0xe6];
    for (const q of queue) out.set(q, null);
    while (queue.length) {
        const cur = queue.shift();
        for (const nx of [...(adj.get(cur) ?? []), ...(cur === 0xfb ? [] : [])]) if (!out.has(nx)) { out.set(nx, cur); queue.push(nx); }
    }
    for (const nx of adj.get('*') ?? []) if (!out.has(nx)) { out.set(nx, '*'); queue.push(nx); }
    while (queue.length) {
        const cur = queue.shift();
        for (const nx of adj.get(cur) ?? []) if (!out.has(nx)) { out.set(nx, cur); queue.push(nx); }
    }
    return out;
}

const cmd = process.argv[2] ?? 'facts';
const arg = process.argv[3];
if (cmd === 'facts') {
    const want = arg ? new Set(arg.split(',').map((x) => parseInt(x, 16))) : null;
    for (const [id, sf] of sceneFacts) {
        if (want && !want.has(id)) continue;
        console.log(`${hex(id, 2)} ${sf.group}/${sf.desc} actors=${sf.actors} thinkers=${sf.thinkers.length} warps->[${[...new Set(sf.warps.map((w) => hex(w.dest, 2)))].join(' ')}] qmc->[${[...new Set(sf.qmc.map((q) => hex(q.dest, 2)))].join(' ')}] metaGates=[${sf.gates.map((g) => hex(g.flag, 2)).join(' ')}]`);
        for (const lf of sf.lockFiles) console.log(`    lock ${lf.file} lines ${lf.locks.map((l) => l.line + ':' + l.op).join(',')} tests=[${lf.tests.map((t) => hex(t, 2)).join(' ')}]`);
    }
} else if (cmd === 'edges') {
    for (const e of edges) console.log(`${typeof e.from === 'number' ? hex(e.from, 2) : e.from} -> ${hex(e.to, 2)} ${e.kind} ${e.site}`);
} else if (cmd === 'reach') {
    const inbound = new Map();
    for (const e of edges) { if (!inbound.has(e.to)) inbound.set(e.to, []); inbound.get(e.to).push(e); }
    const noInbound = [...scenes.keys()].filter((id) => !inbound.has(id));
    console.log('scenes without any inbound scene-warp / QueueMapChange edge (' + noInbound.length + '):');
    for (const id of noInbound) console.log('  ' + hex(id, 2) + ' ' + scenes.get(id).group + '/' + scenes.get(id).desc);
    console.log('edge counts: ' + edges.length);
    const bfs = reachSet();
    const unreached = [...scenes.keys()].filter((id) => !bfs.has(id));
    console.log('not reached by BFS from boot ($FB), title ($FC), diary ($FA), load ($E6) over real edges (debug_man and unused/ sources dropped; scene -> $FE for scenes that place overworld_exit; $FE -> world_map_options targets): ' + unreached.length);
    for (const id of unreached) console.log('  ' + hex(id, 2) + ' ' + scenes.get(id).group + '/' + scenes.get(id).desc + '  inbound: ' + (inbound.get(id) ?? []).map((e) => (typeof e.from === 'number' ? hex(e.from, 2) : e.from) + ' ' + e.kind).join('; '));
} else if (cmd === 'json') {
    console.log(JSON.stringify({ scenes: [...sceneFacts.values()], edges, globalQmc }, null, 1));
}
