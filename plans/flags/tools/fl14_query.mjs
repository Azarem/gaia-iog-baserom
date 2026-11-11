#!/usr/bin/env node
// fl14_query.mjs - READ-ONLY query tool for the FL14 analysis (dungeon kill flags, domain D6, global flags $0400-$04FF, bytes $0A80-$0A9F).
//
// This script WRITES NOTHING. It prints to stdout; the caller redirects the output into plans/flags/results/.
// It reads only:
//   rebuilt/Illusion of Gaia.smc            (2 MB original image, no header; decimal file offsets) to decode the scene_actors rows and to
//                                           cross-check every row against the asm text (extracted/tables/scene_actors.asm carries no "; {n}" tags)
//   extracted/tables/scene_actors.asm       (scene actor lists: enemy-spawn rows, operand 6 = enemy number, file:line of every row)
//   extracted/**/*.asm                      (enemy actor scripts, scanned for their death path; scene_warps is read from the ROM)
//   db-us/groups.json                       (scene id -> group, scene name, prefix)
//   plans/flags/inventory.json              (FL01 inventory: the dungeon_kill_wram_flags trace and the D8 site count)
// It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl14_query.mjs rows        # every enemy-spawn row: scene, row, actor, stats, enemy number, event block, asm:line, rom offset, rom-match
//   node plans/flags/tools/fl14_query.mjs summary     # totals, ROM-vs-asm cross-check, distinct numbers, shared numbers, unused numbers
//   node plans/flags/tools/fl14_query.mjs table       # the report table: one line per used enemy number
//   node plans/flags/tools/fl14_query.mjs shared      # numbers used by more than one row/scene/actor label
//   node plans/flags/tools/fl14_query.mjs unused      # numbers $01-$FF with no row
//   node plans/flags/tools/fl14_query.mjs actors      # per placed enemy actor label: file, death-path lines (callback, defeat handler jumps, D8, boss bit)
//   node plans/flags/tools/fl14_query.mjs reach       # per scene with tracked rows: warp entries and literal QueueMapChange operands naming it
//   node plans/flags/tools/fl14_query.mjs unplaced    # enemy-looking actor definitions in extracted/ that no scene_actors row places
//   node plans/flags/tools/fl14_query.mjs registry    # the registry fragment JSON (stdout; the caller redirects it into plans/flags/results/registry/)
import fs from 'node:fs';
import path from 'node:path';

const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const sceneInfo = new Map();
for (const [g, v] of Object.entries(groups)) for (const [name, s] of Object.entries(v.scenes)) sceneInfo.set(s.id, { group: g, prefix: v.prefix, name, description: s.description });
const sceneTxt = s => { const i = sceneInfo.get(s); return `$${hex(s)} ${i ? i.group + '/' + i.name : '(no scene record in groups.json)'}`; };

const ACTORS_FILE = 'extracted/tables/scene_actors.asm';
const ACTOR_PTR_TABLE = 819200;      // scene_actors: 256 words, records in bank $0C
const ACTOR_BANK_BASE = 786432;      // 0xC0000
const readLines = f => fs.readFileSync(f, 'utf8').split(/\r?\n/);

// ---------------------------------------------------------------- scene_actors
export function sceneActors() {
    const lines = readLines(ACTORS_FILE);
    const scenes = new Map();
    let cur = null;
    lines.forEach((l, i) => {
        let m = /^scene_([0-9A-F]{2})_actors \[/.exec(l);
        if (m) { cur = { scene: parseInt(m[1], 16), line: i + 1, rows: [] }; scenes.set(cur.scene, cur); return; }
        if (/^scene_default_actors \[/.test(l)) { cur = null; return; }
        if (/^\]/.test(l)) { cur = null; return; }
        m = /^\s+(enemy|actor)-spawn < (.*) >(?:\s+;([0-9A-F]+))?\s*$/.exec(l);
        if (m && cur) {
            const ops = m[2].split(',').map(s => s.trim());
            const row = { kind: m[1], row: m[3] === undefined ? cur.rows.length : parseInt(m[3], 16), line: i + 1, x: parseInt(ops[0].slice(1), 16), y: parseInt(ops[1].slice(1), 16), attr: parseInt(ops[2].slice(1), 16), actor: ops[3].replace(/^@/, '') };
            if (m[1] === 'enemy') { row.stats = parseInt(ops[4].slice(1), 16); row.enemyNum = parseInt(ops[5].slice(1), 16); row.evt = parseInt(ops[6].slice(1), 16); }
            cur.rows.push(row);
        }
    });
    for (const [sc, S] of scenes) {
        const ptr = ROM[ACTOR_PTR_TABLE + sc * 2] | (ROM[ACTOR_PTR_TABLE + sc * 2 + 1] << 8);
        let o = ACTOR_BANK_BASE + ptr, k = 0;
        S.romStart = o;
        while (ROM[o] !== 0xFF) {
            const stats = ROM[o + 6];
            const r = S.rows[k];
            if (r) {
                r.offset = o;
                r.romMatch = r.x === ROM[o] && r.y === ROM[o + 1] && r.attr === ROM[o + 2] && (r.kind === 'enemy') === (stats !== 0)
                    && (r.kind !== 'enemy' || (r.stats === stats && r.enemyNum === ROM[o + 7] && r.evt === ROM[o + 8]));
                if (r.kind === 'enemy') r.numOffset = o + 7;   // the enemy-number byte itself
            }
            o += stats ? 9 : 7; k++;
        }
        S.romRows = k;
    }
    return scenes;
}

export function enemyRows() {
    const out = [];
    for (const [sc, S] of sceneActors()) for (const r of S.rows) if (r.kind === 'enemy') out.push({ ...r, scene: sc, listLine: S.line });
    return out;
}

// ---------------------------------------------------------------- extracted index
function walk(dir, out = []) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        if (e.isDirectory()) walk(p, out); else if (e.name.endsWith('.asm')) out.push(p);
    }
    return out;
}
let _files = null;
export function asmFiles() { return _files ??= walk('extracted').map(p => p.replace(/\\/g, '/')); }
export function fileOfActor(label) {
    const stem = asmFiles().find(f => path.basename(f, '.asm') === label);
    if (stem) return stem;
    const re = new RegExp('^' + label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ' [\\[{]', 'm');
    return asmFiles().find(f => re.test(fs.readFileSync(f, 'utf8'))) ?? null;
}

// ---------------------------------------------------------------- aggregation
export function byNumber() {
    const m = new Map();
    for (const r of enemyRows()) {
        if (!r.enemyNum) continue;
        const e = m.get(r.enemyNum) ?? { num: r.enemyNum, rows: [], scenes: new Set(), labels: new Set() };
        e.rows.push(r); e.scenes.add(r.scene); e.labels.add(r.actor.split('.')[0]);
        m.set(r.enemyNum, e);
    }
    return m;
}

// reachability hint: warp entries (scene_warps in the ROM) and literal QueueMapChange operands naming each scene
export function destinations() {
    const warp = new Map(), qmc = new Map();
    for (let sc = 0; sc < 255; sc++) {
        const w = ROM[98868 + sc * 2] | (ROM[98868 + sc * 2 + 1] << 8);
        let o = 65536 + w;
        while (ROM[o] < 0x80) { const d = ROM[o + 4]; (warp.get(d) ?? warp.set(d, []).get(d)).push(sc); o += 12; }
    }
    for (const f of asmFiles()) {
        readLines(f).forEach((l, i) => {
            const m = /COP \[QueueMapChange\] \( #([0-9A-F]{2}),/.exec(l.split(';')[0]);
            if (m) { const d = parseInt(m[1], 16); (qmc.get(d) ?? qmc.set(d, []).get(d)).push(`${f.replace('extracted/', '')}:${i + 1}`); }
        });
    }
    return { warp, qmc };
}

// ---------------------------------------------------------------- commands
function cmdRows() {
    for (const r of enemyRows()) {
        console.log([`$${hex(r.scene)}`, `#${hex(r.row)}`, r.actor, `stats $${hex(r.stats)}`, `num $${hex(r.enemyNum)}`, `evt $${hex(r.evt)}`, `asm:${r.line}`, `off ${r.offset}`, `numoff ${r.numOffset}`, r.romMatch ? 'rom-ok' : 'ROM-MISMATCH'].join('\t'));
    }
}

function cmdSummary() {
    const rows = enemyRows();
    const bad = rows.filter(r => !r.romMatch);
    const SA = sceneActors();
    const recMismatch = [...SA.values()].filter(S => S.romRows !== S.rows.length);
    const nz = rows.filter(r => r.enemyNum);
    const N = byNumber();
    const shared = [...N.values()].filter(e => e.scenes.size > 1);
    const multiRow = [...N.values()].filter(e => e.rows.length > 1);
    const multiLabel = [...N.values()].filter(e => e.labels.size > 1);
    console.log(`scene lists parsed ${SA.size}; lists whose ROM row count differs from the asm row count: ${recMismatch.length}`);
    console.log(`enemy-spawn rows ${rows.length}; with enemy number 0 ${rows.length - nz.length}; nonzero ${nz.length}; ROM mismatches ${bad.length}`);
    console.log(`distinct nonzero numbers ${N.size} (min $${hex(Math.min(...N.keys()))}, max $${hex(Math.max(...N.keys()))})`);
    console.log(`numbers in more than one scene ${shared.length}; numbers on more than one row ${multiRow.length}; numbers on more than one actor label ${multiLabel.length}`);
    const unused = []; for (let n = 1; n <= 255; n++) if (!N.has(n)) unused.push('$' + hex(n));
    console.log(`unused numbers $01-$FF: ${unused.length}: ${unused.join(' ')}`);
    const scenesWith = new Set(rows.map(r => r.scene)), scenesNz = new Set(nz.map(r => r.scene));
    console.log(`scenes with enemy rows ${scenesWith.size}; scenes with a tracked (nonzero) row ${scenesNz.size}`);
    // per-scene: rows that share a number inside one scene
    const inScene = [];
    for (const sc of scenesNz) { const c = new Map(); for (const r of nz.filter(r => r.scene === sc)) c.set(r.enemyNum, (c.get(r.enemyNum) ?? 0) + 1); for (const [n, k] of c) if (k > 1) inScene.push(`$${hex(sc)}:$${hex(n)}x${k}`); }
    console.log(`numbers repeated inside one scene: ${inScene.length}: ${inScene.join(' ')}`);
    // records with no stats-bearing row sharing: rows with evt
    console.log(`rows with an event block ${rows.filter(r => r.evt).length}; tracked rows with an event block ${nz.filter(r => r.evt).length}`);
}

const labelList = e => [...e.labels].sort().join(', ');
function cmdTable() {
    const { warp, qmc } = destinations();
    const N = byNumber();
    for (const e of [...N.values()].sort((a, b) => a.num - b.num)) {
        const sc = [...e.scenes].sort((a, b) => a - b);
        const scTxt = sc.map(s => `$${hex(s)}`).join(' ');
        const rowTxt = e.rows.map(r => `$${hex(r.scene)}#${hex(r.row)} ${r.actor} (asm:${r.line} {${r.offset}})`).join('; ');
        const flag = 0x400 + e.num;
        console.log(`| $${hex(e.num)} | $${hex(flag, 4)} = ${flag}; $${hex(0xA80 + (e.num >> 3), 4)} bit ${e.num & 7} | ${scTxt} | ${rowTxt} | ${sc.length > 1 ? 'SHARED across ' + sc.length + ' scenes' : ''}${e.rows.length > 1 && sc.length === 1 ? 'shared by ' + e.rows.length + ' rows of one scene' : ''} |`);
    }
}

function cmdShared() {
    const N = byNumber();
    for (const e of [...N.values()].sort((a, b) => a.num - b.num)) {
        if (e.scenes.size > 1 || e.rows.length > 1) {
            console.log(`$${hex(e.num)}\tscenes ${[...e.scenes].map(s => '$' + hex(s)).join(',')}\trows ${e.rows.length}\tlabels ${labelList(e)}\t${e.rows.map(r => `$${hex(r.scene)}#${hex(r.row)}`).join(' ')}`);
        }
    }
}

function cmdUnused() {
    const N = byNumber();
    const u = []; for (let n = 1; n <= 255; n++) if (!N.has(n)) u.push('$' + hex(n));
    console.log(`${u.length} numbers without a row: ${u.join(' ')}`);
}

const KW = /StandardEnemyDefeatHandler|EnemyDefeatDispatch|EnemyDefeatFlashAndDrop|SetDeathCallback|EnemyDefeatBossCleanup|SetDungeonKillFlag|OrExtraFlags|AndExtraFlags|ClearExtraFlags|\$7F002A|extendedFlags|enemiesRemaining|\$0AEC|\$0AEE|EnemyInitBasic|enemy_stats_table|statsPtr|\$7F0020|\$7F0022/;
function cmdActors() {
    const labels = new Map();
    for (const r of enemyRows()) {
        const e = labels.get(r.actor) ?? { scenes: new Set(), stats: new Set(), nums: new Set(), rows: 0, tracked: 0 };
        e.scenes.add(r.scene); e.stats.add(r.stats); e.rows++; if (r.enemyNum) { e.tracked++; e.nums.add(r.enemyNum); }
        labels.set(r.actor, e);
    }
    for (const [label, e] of [...labels].sort()) {
        const stem = label.split('.')[0];
        const f = fileOfActor(stem);
        console.log(`${label}\tfile ${f}\tstats ${[...e.stats].map(x => '$' + hex(x)).join(',')}\trows ${e.rows} tracked ${e.tracked} scenes ${e.scenes.size}`);
        if (f) readLines(f).forEach((l, i) => { if (KW.test(l.split(';')[0])) console.log(`    ${i + 1}: ${l.trim().slice(0, 130)}`); });
    }
}

function cmdReach() {
    const { warp, qmc } = destinations();
    const rows = enemyRows().filter(r => r.enemyNum);
    for (const sc of [...new Set(rows.map(r => r.scene))].sort((a, b) => a - b)) {
        const w = warp.get(sc) ?? [], q = qmc.get(sc) ?? [];
        console.log(`${sceneTxt(sc)}\twarp entries ${w.length} (from ${[...new Set(w)].map(x => hex(x)).join(',') || '-'})\tQueueMapChange literals ${q.length}${q.length ? ' ' + q.slice(0, 2).join(' ') : ''}`);
    }
}

// actor definitions whose own script touches the defeat machinery but that no scene row places
function cmdUnplaced() {
    const placed = new Set(enemyRows().map(r => r.actor.split('.')[0]));
    const allPlaced = new Set();
    for (const [, S] of sceneActors()) for (const r of S.rows) allPlaced.add(r.actor.split('.')[0]);
    const cand = [];
    for (const f of asmFiles()) {
        if (/tables\/|\.sprite\.asm$/.test(f)) continue;
        const text = readLines(f).map(l => l.split(';')[0]).join('\n');
        if (/SetDeathCallback|StandardEnemyDefeatHandler|EnemyDefeatDispatch|EnemyInitBasic|SetDungeonKillFlag/.test(text)) cand.push(f);
    }
    for (const f of cand) {
        const stem = path.basename(f, '.asm');
        console.log(`${f}\tstem placed as enemy: ${placed.has(stem)}\tstem placed at all: ${allPlaced.has(stem)}`);
    }
}

// scene lists whose ROM record count differs from the parsed asm row count (diagnostic)
function cmdListCheck() {
    for (const [sc, S] of sceneActors()) {
        if (S.romRows !== S.rows.length) console.log(`${sceneTxt(sc)}\tasm rows ${S.rows.length} (list asm:${S.line})\tROM rows ${S.romRows} (offset ${S.romStart})`);
    }
}

// per scene: rows, rows with number 0, distinct numbers and their range, numbers also used in another scene of the same group
function cmdScenes() {
    const SA = sceneActors();
    const rows = enemyRows();
    const N = byNumber();
    for (const sc of [...new Set(rows.map(r => r.scene))].sort((a, b) => a - b)) {
        const rs = rows.filter(r => r.scene === sc);
        const nums = [...new Set(rs.filter(r => r.enemyNum).map(r => r.enemyNum))].sort((a, b) => a - b);
        const grp = sceneInfo.get(sc)?.group;
        const sameGroup = nums.filter(n => [...N.get(n).scenes].some(s => s !== sc && sceneInfo.get(s)?.group === grp));
        console.log(`${sceneTxt(sc)}\tlist asm:${SA.get(sc).line}\trows ${rs.length}\tnum0 ${rs.filter(r => !r.enemyNum).length}\tdistinct ${nums.length}${nums.length ? ` $${hex(nums[0])}-$${hex(nums[nums.length - 1])}` : ''}\tshared-in-group ${sameGroup.length}`);
    }
}

// scene graph WITHOUT the world map: edges = scene_warps entries (ROM, src -> dst) + literal QueueMapChange operands (source scenes = the scenes that
// place an actor defined in the file that holds the COP). Scene $FE (world map) and every edge that leaves it are dropped, because every world-map
// entry runs ClearAllWramFlags. Weakly connected components; a number used in two scenes of one component is a real kill-bit collision.
function sceneGraph(warpsOnly = process.argv[3] === 'warps') {
    const SA = sceneActors();
    const label2scenes = new Map();
    for (const [sc, S] of SA) for (const r of S.rows) { const b = r.actor.split('.')[0]; (label2scenes.get(b) ?? label2scenes.set(b, new Set()).get(b)).add(sc); }
    const file2scenes = new Map();
    for (const [b, set] of label2scenes) { const f = fileOfActor(b); if (f) { const s = file2scenes.get(f) ?? file2scenes.set(f, new Set()).get(f); for (const x of set) s.add(x); } }
    const edges = []; // {from, to, why}
    for (let sc = 0; sc < 255; sc++) {
        const w = ROM[98868 + sc * 2] | (ROM[98868 + sc * 2 + 1] << 8);
        let o = 65536 + w;
        while (ROM[o] < 0x80) { edges.push({ from: sc, to: ROM[o + 4], why: `warp entry @${o}` }); o += 12; }
    }
    for (const f of warpsOnly ? [] : asmFiles()) {   // 'components warps' keeps only the ROM warp entries
        const srcs = file2scenes.get(f);
        readLines(f).forEach((l, i) => {
            const m = /COP \[QueueMapChange\] \( #([0-9A-F]{2}),/.exec(l.split(';')[0]);
            if (m && srcs && srcs.size === 1) for (const s of srcs) edges.push({ from: s, to: parseInt(m[1], 16), why: `${f.replace('extracted/', '')}:${i + 1}` });
        });
    }
    return edges.filter(e => e.from !== 0xFE && e.to !== 0xFE && e.from !== 0xE6 && e.to !== 0xE6 && e.from !== 0xFD && e.to !== 0xFD && e.from !== 0xFF && e.to !== 0xFF && e.from !== e.to);
}
function components(warpsOnly) {
    const edges = sceneGraph(warpsOnly);
    const parent = new Map();
    const find = x => { if (!parent.has(x)) parent.set(x, x); while (parent.get(x) !== x) { parent.set(x, parent.get(parent.get(x))); x = parent.get(x); } return x; };
    for (const e of edges) parent.set(find(e.from), find(e.to));
    return { find, edges };
}
function cmdComponents() {
    const { find, edges } = components();
    const N = byNumber();
    const rows = enemyRows().filter(r => r.enemyNum);
    const scenes = [...new Set(rows.map(r => r.scene))].sort((a, b) => a - b);
    const comp = new Map();
    for (const sc of scenes) { const c = find(sc); (comp.get(c) ?? comp.set(c, []).get(c)).push(sc); }
    for (const [, list] of comp) console.log(`component: ${list.map(s => '$' + hex(s)).join(' ')}`);
    console.log('# numbers used by two or more scenes of one component (real kill-bit collisions within one world-map session):');
    for (const e of [...N.values()].sort((a, b) => a.num - b.num)) {
        const byC = new Map();
        for (const s of e.scenes) { const c = find(s); (byC.get(c) ?? byC.set(c, []).get(c)).push(s); }
        for (const [, l] of byC) if (l.length > 1) console.log(`  $${hex(e.num)}: scenes ${l.sort((a, b) => a - b).map(s => '$' + hex(s)).join(' ')}`);
    }
}
function cmdEdges() {
    const scenesWith = new Set(enemyRows().filter(r => r.enemyNum).map(r => r.scene));
    const cross = process.argv[3] === 'cross';   // only edges between scenes of different groups
    const g = s => sceneInfo.get(s)?.group ?? '?';
    for (const e of sceneGraph()) {
        if (process.argv[3] !== 'all' && !(scenesWith.has(e.from) || scenesWith.has(e.to)) && !cross) continue;
        if (cross && g(e.from) === g(e.to)) continue;
        console.log(`${sceneTxt(e.from)} -> ${sceneTxt(e.to)}\t${e.why}`);
    }
}

// session boundaries: for each dungeon component (warp-entry graph restricted to the tracked scenes), every transition that enters or leaves it
// (warp entries from/to other scenes; literal QueueMapChange operands in files that a scene of the component places, or that name a scene of the component).
// Also lists the world-map exit actor gates (overworld_exit scene ids) for context.
function cmdBoundaries() {
    const SA = sceneActors();
    const tracked = new Set(enemyRows().filter(r => r.enemyNum).map(r => r.scene));
    const { find } = components(true);
    const compOf = s => tracked.has(s) ? find(s) : null;
    const label2scenes = new Map();
    for (const [sc, S] of SA) for (const r of S.rows) { const b = r.actor.split('.')[0]; (label2scenes.get(b) ?? label2scenes.set(b, new Set()).get(b)).add(sc); }
    const file2scenes = new Map();
    for (const [b, set] of label2scenes) { const f = fileOfActor(b); if (f) { const s = file2scenes.get(f) ?? file2scenes.set(f, new Set()).get(f); for (const x of set) s.add(x); } }
    const comps = new Map();
    for (const sc of [...tracked].sort((a, b) => a - b)) (comps.get(find(sc)) ?? comps.set(find(sc), []).get(find(sc))).push(sc);
    const out = [];
    for (let sc = 0; sc < 255; sc++) {
        const w = ROM[98868 + sc * 2] | (ROM[98868 + sc * 2 + 1] << 8);
        let o = 65536 + w;
        while (ROM[o] < 0x80) { out.push({ from: sc, to: ROM[o + 4], why: `warp entry @${o}` }); o += 12; }
    }
    for (const f of asmFiles()) {
        const srcs = file2scenes.get(f) ?? new Set();
        readLines(f).forEach((l, i) => {
            const m = /COP \[QueueMapChange\] \( #([0-9A-F]{2}),/.exec(l.split(';')[0]);
            if (!m) return;
            const to = parseInt(m[1], 16);
            const where = `${f.replace('extracted/', '')}:${i + 1}`;
            if (srcs.size === 0) out.push({ from: null, to, why: where + ' (file placed by no scene row)' });
            for (const s of srcs) out.push({ from: s, to, why: where + (srcs.size > 1 ? ` (file placed in ${srcs.size} scenes)` : '') });
        });
    }
    for (const [c, list] of comps) {
        console.log(`\n== component ${list.map(s => '$' + hex(s)).join(' ')}`);
        const set = new Set(list);
        const seen = new Set();
        for (const e of out) {
            const fin = e.from !== null && set.has(e.from), tin = set.has(e.to);
            if (fin === tin) continue;       // internal or unrelated
            if ([0xE6, 0xFD, 0xFF].includes(e.to) || [0xE6, 0xFD, 0xFF].includes(e.from)) continue;
            const k = `${e.from}>${e.to}>${e.why}`; if (seen.has(k)) continue; seen.add(k);
            console.log(`  ${fin ? 'OUT' : 'IN '} ${e.from === null ? '?' : sceneTxt(e.from)} -> ${sceneTxt(e.to)}\t${e.why}`);
        }
    }
}

// shortest path (BFS) from scene A to scene B over the graph without the world map: `path <fromHex> <toHex>`; edges as in sceneGraph(false)
function cmdPath() {
    const from = parseInt(process.argv[3], 16), to = parseInt(process.argv[4], 16);
    const edges = sceneGraph(false);
    const prev = new Map([[from, null]]);
    const q = [from];
    while (q.length && !prev.has(to)) {
        const x = q.shift();
        for (const e of edges) if (e.from === x && !prev.has(e.to)) { prev.set(e.to, e); q.push(e.to); }
    }
    if (!prev.has(to)) { console.log(`no path $${hex(from)} -> $${hex(to)} without the world map`); return; }
    const p = []; for (let x = to; prev.get(x); x = prev.get(x).from) p.unshift(prev.get(x));
    for (const e of p) console.log(`  ${sceneTxt(e.from)} -> ${sceneTxt(e.to)}\t${e.why}`);
}

// exposures: for every ordered pair of dungeon sessions (components of the warp graph over the tracked scenes) that share at least one enemy number,
// is there a path from a scene of A to a scene of B that avoids the world map, $E6, $FD, $FF AND every QueueMapChange issued by a file that also calls
// ClearAllWramFlags (st68_kara, sp58_red_eye)? Edges: ROM warp entries + literal QueueMapChange operands of files placed by exactly one scene row group (<= 2 scenes).
function cmdExposures() {
    const resetFiles = asmFiles().filter(f => /ClearAllWramFlags/.test(readLines(f).map(l => l.split(';')[0]).join('\n')) && !/flag_helpers/.test(f)).map(f => f.replace('extracted/', ''));
    const edges = sceneGraph(false).filter(e => !resetFiles.some(r => e.why.startsWith(r)));
    const tracked = new Set(enemyRows().filter(r => r.enemyNum).map(r => r.scene));
    const { find } = components(true);
    const comps = new Map();
    for (const sc of [...tracked].sort((a, b) => a - b)) (comps.get(find(sc)) ?? comps.set(find(sc), []).get(find(sc))).push(sc);
    const N = byNumber();
    console.log(`reset files (QueueMapChange edges of these are dropped): ${resetFiles.join(', ')}`);
    const list = [...comps.values()];
    for (const A of list) for (const B of list) {
        if (A === B) continue;
        const common = [...N.values()].filter(e => A.some(s => e.scenes.has(s)) && B.some(s => e.scenes.has(s)));
        if (!common.length) continue;
        const prev = new Map(A.map(s => [s, null]));
        const q = [...A];
        let hit = null;
        while (q.length && !hit) {
            const x = q.shift();
            for (const e of edges) if (e.from === x && !prev.has(e.to)) { prev.set(e.to, e); q.push(e.to); if (B.includes(e.to)) { hit = e.to; break; } }
        }
        if (hit) {
            const p = []; for (let x = hit; prev.get(x); x = prev.get(x).from) p.unshift(prev.get(x));
            console.log(`EXPOSED ${A.map(s => hex(s)).join(',')} -> ${B.map(s => hex(s)).join(',')}\tshared numbers ${common.length}\tpath: ${p.map(e => `$${hex(e.from)}>$${hex(e.to)} (${e.why})`).join(' ; ')}`);
        }
    }
}

// defeat: per actor file placed as an enemy row, how its death reaches the kill bit. 'ref' = the file names StandardEnemyDefeatHandler, EnemyDefeatDispatch or
// SetDungeonKillFlag outside ?INCLUDE lines; 'default' = no SetDeathCallback (the engine death routing applies); 'callback-only' = SetDeathCallback and no reference (needs a manual read).
function cmdDefeat() {
    const files = new Map();
    for (const r of enemyRows()) {
        const stem = r.actor.split('.')[0];
        const f = fileOfActor(stem);
        const e = files.get(f) ?? files.set(f, { stems: new Set(), rows: 0, tracked: 0, nums: new Set() }).get(f);
        e.stems.add(stem); e.rows++; if (r.enemyNum) { e.tracked++; e.nums.add(r.enemyNum); }
    }
    for (const [f, e] of [...files].sort((a, b) => String(a[0]).localeCompare(String(b[0])))) {
        const code = f ? readLines(f).map(l => l.split(';')[0]).filter(l => !/^\s*\?INCLUDE/.test(l)).join('\n') : '';
        const ref = /StandardEnemyDefeatHandler|EnemyDefeatDispatch|SetDungeonKillFlag/.test(code);
        const cb = /SetDeathCallback/.test(code);
        const boss = /OrExtraFlags\s*\(\s*#\$0080/.test(code);
        const cls = ref ? 'ref' : cb ? 'callback-only' : 'default';
        console.log(`${cls}${boss ? '+bossbit' : ''}\t${f ?? '?'}\trows ${e.rows} tracked ${e.tracked} numbers ${e.nums.size}`);
    }
}

// ---------------------------------------------------------------- registry / queue emitters (stdout only; the caller redirects into plans/flags/results/)
const ENGINE_EVIDENCE = [
    'extracted/system/engine/actor_execution.asm:991 {249715}',
    'extracted/system/engine/actor_execution.asm:993 {249721}',
    'extracted/system/engine/actor_execution.asm:995 {249726}',
    'extracted/system/engine/actor_execution.asm:1196 {250099}',
    'extracted/system/engine/cop_handlers_dungeon_switch.asm:24 {44172}',
    'extracted/functions/StandardEnemyDefeatHandler.asm:87 {56306}',
];
const QUEUE_ID = { awB1_wall_walker: 'FL14-WALLWALKER', pyD2_haunt: 'FL14-HAUNT', gw8A_sand_fanger: 'FL14-SANDFANGER', awB0_zombie: 'FL14-ZOMBIE', ec12_skull_chaser: 'FL14-SKULL' };
const OWN_D8 = new Set(['awB1_wall_walker', 'pyCC_mystic_ball']);
const NEVER_SET = { awB1_wall_walker: 'boss-bit branch (OrExtraFlags #$0080 at awB1_wall_walker.asm:128 {769087} and :185 {769211}) makes StandardEnemyDefeatHandler skip the kill bit; the own death routine (:526 {770381}) sets it on every non-last kill', pyD2_haunt: 'OrExtraFlags #$0090 (pyD2_haunt.asm:211 {770788}) includes the boss bit $0080, so the StandardEnemyDefeatHandler path skips the kill bit', gw8A_sand_fanger: 'OrExtraFlags #$0080 (gw8A_sand_fanger.asm:1312 {756183}) is the boss bit, so the StandardEnemyDefeatHandler path skips the kill bit', awB0_zombie: 'SetDeathCallback code_0BB800 (awB0_zombie.asm:631 {767902}, body :678-686) flashes and returns; the file holds no SetDungeonKillFlag, StandardEnemyDefeatHandler, EnemyDefeatDispatch or Die', ec12_skull_chaser: 'two-phase death: the first death runs code_0A853E (SetDeathCallback at ec12_skull_chaser.asm:23 {689282}), which resets stats and clears the callback ($000000 at :137 {689513}); the kill bit is set by the second death through the default routing' };

function sessionInfo() {
    const { find } = components(true);
    const tracked = [...new Set(enemyRows().filter(r => r.enemyNum).map(r => r.scene))];
    const sess = new Map();
    for (const sc of tracked) (sess.get(find(sc)) ?? sess.set(find(sc), []).get(find(sc))).push(sc);
    const idOf = new Map();
    for (const list of sess.values()) for (const sc of list) idOf.set(sc, Math.min(...list));
    return { idOf, sess };
}

function selection(N, idOf) {
    const sel = new Map();
    for (const e of N.values()) {
        const why = [];
        if (e.rows.some(r => OWN_D8.has(r.actor.split('.')[0]))) why.push('own-D8 actor row');
        const perSession = new Map();
        for (const r of e.rows) { const k = idOf.get(r.scene); perSession.set(k, (perSession.get(k) ?? 0) + 1); }
        if ([...perSession.values()].some(c => c > 1)) why.push('several rows in one session');
        if (e.num >= 1 && e.num <= 5 && [...e.scenes].some(s => s >= 0xF2 && s <= 0xF6)) why.push('Babel dark-lair boss row');
        if (e.num >= 0xF8) why.push('tomb mask byte $0A9F');
        if ([...e.labels].some(l => NEVER_SET[l])) why.push('actor that may skip or never write the bit');
        if (why.length) sel.set(e.num, why);
    }
    return sel;
}

function cmdRegistry() {
    const N = byNumber();
    const { idOf } = sessionInfo();
    const sel = selection(N, idOf);
    const flags = {};
    let verified = 0, inferred = 0;
    for (const n of [...sel.keys()].sort((a, b) => a - b)) {
        const e = N.get(n);
        const scenes = [...e.scenes].sort((a, b) => a - b);
        const sessions = new Set(scenes.map(s => idOf.get(s)));
        const stems = [...e.labels];
        const weak = stems.filter(s => NEVER_SET[s]);
        const tomb = n >= 0xF8 && n <= 0xFD;
        const grade = weak.length ? 'INFERRED' : 'VERIFIED-STATIC';
        grade === 'INFERRED' ? inferred++ : verified++;
        const notes = [];
        notes.push(`Rows: ${e.rows.map(r => `$${hex(r.scene)}#${hex(r.row)} ${r.actor}`).join('; ')}.`);
        notes.push(`The number is used in ${sessions.size} dungeon session(s) (warp-graph components of the scenes with tracked numbers: ${[...sessions].map(s => '$' + hex(s)).join(' ')}); a reset runs only at world-map entry, st68_kara, sp58_red_eye and game over, so same-number rows of different sessions share one bit unless one of those intervenes.`);
        const why = sel.get(n);
        notes.push(`Full record because: ${why.join(', ')}.`);
        for (const s of weak) notes.push(`${s}: ${NEVER_SET[s]}.`);
        if (tomb) notes.push('Bit ' + (n & 7) + ' of $0A9F is tested by gw88_tomb_dark_space (gw88_tomb_dark_space.asm:18 {507380}): the low byte of $0A9F equals $3F only when $F8-$FD are all set and $FE-$FF are clear.');
        if (n === 0xFE) notes.push('$FE has to stay clear for the wall_tomb check ($0A9F AND $FF = $3F, gw88_tomb_dark_space.asm:19-21 {507383}-{507386}); pyramid scene $DB rows #05 and #06 carry it.');
        notes.push('The name is a slot name (enemy number), not derived from dialog text.');
        const evidence = [...ENGINE_EVIDENCE, ...e.rows.map(r => `extracted/tables/scene_actors.asm:${r.line} {${r.offset}}`)];
        if (e.rows.some(r => r.actor.startsWith('awB1_wall_walker'))) evidence.push('extracted/angkor_wat/awB1_wall_walker.asm:526 {770381}');
        if (e.rows.some(r => r.actor.startsWith('pyCC_mystic_ball'))) evidence.push('extracted/pyramid/pyCC_mystic_ball.asm:239 {771937}');
        if (tomb) evidence.push('extracted/great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380}');
        flags[1024 + n] = {
            domain: 'D6',
            meanings: [{
                scope: null,
                name: `sys_dungeon_enemy_${hex(n).toLowerCase()}_killed`,
                area: 'system',
                summary: `The enemy with number $${hex(n)} (flag index $${hex(1024 + n, 4)}) has been defeated since the last reset of the kill bits; scene load skips every spawn record that carries this number.`,
                kinds: tomb ? ['once-latch', 'puzzle-state'] : ['once-latch'],
                grade,
                effects: {
                    set: 'InitActorFromSceneData frees the slot of every enemy spawn record with this number (CheckEnemyDefeatedFlag carry set), does not count it in enemiesRemaining and swaps the record\'s event-block tiles' + (tomb ? '; for $F8-$FD the wall_tomb Dark Space actor changes the background and sets event flag $0174 when the whole low byte of $0A9F equals $3F' : ''),
                    clear: 'Every spawn record with this number spawns its actor normally and the actor is counted in enemiesRemaining.',
                },
                evidence,
                ...(weak.length ? { queue: weak.map(w => QUEUE_ID[w]) } : {}),
                notes: notes.join(' '),
            }],
        };
    }
    const out = {
        _note: `FL14 fragment. domains.D6 is the domain record (253 numbers $01-$FE in use, $F7 and $FF have no spawn row). Full records for ${sel.size} numbers: ${[...new Set([...sel.values()].flat())].join('; ')}. The other ${253 - sel.size} numbers need no individual record: each is carried only by actors whose death reaches SetDungeonKillFlag through the default routing, and has no consumer except the spawn check (several of them are still reused by other dungeons: see the table) (table in FL14_20261031_table.md). No spine flags. Grades: ${verified} VERIFIED-STATIC, ${inferred} INFERRED (a row belongs to an actor whose script may skip or never reach the kill-bit write).`,
        domains: {
            D6: {
                name: 'dungeon enemy kill',
                ranges: [[1024, 1279]],
                indexed: true,
                persistence: 'save',
                lifecycle: 'Bytes $0A80-$0A9F of the save block (flag $0400 + enemy number; byte $0A80 + (n >> 3), bit n AND 7). Zeroed by ClearAllWramFlags (WorldMapController entry {238336}, st68_kara {438261}, sp58_red_eye {426502} only when $0AA6 = 2), by the inline loop of game_over_sequence {54988}-{55002} on a real game over (gems < 100; a revive keeps the bits) and at boot. ClearSceneState zeroes only $0A00-$0A01, so ordinary scene changes keep the bits: a number reused by two scenes of one visit is one shared bit, and a number reused by the next dungeon is a stale bit unless a reset ran between the dungeons. Each dungeon numbers its enemies from about $01, so 241 of the 253 numbers appear in several scenes.',
                access: 'COP $D8 SetDungeonKillFlag (StandardEnemyDefeatHandler {56306}, EnemyDefeatDispatch {697510}, awB1_wall_walker {770381}, pyCC_mystic_ball {771937}; all reach SetWramFlag {44172}), CheckEnemyDefeatedFlag at spawn ({249721}), one direct reader (gw88_tomb_dark_space {507380}, $0A9F) and the two clearing sites. No COP flag operand and no other helper call reaches $0400-$04FF.',
            },
        },
        flags,
    };
    console.log(JSON.stringify(out, null, 2));
}

const cmd = process.argv[2];
const table = { registry: cmdRegistry, defeat: cmdDefeat, exposures: cmdExposures, path: cmdPath, boundaries: cmdBoundaries, components: cmdComponents, edges: cmdEdges, scenes: cmdScenes, listcheck: cmdListCheck, rows: cmdRows, summary: cmdSummary, table: cmdTable, shared: cmdShared, unused: cmdUnused, actors: cmdActors, reach: cmdReach, unplaced: cmdUnplaced };
if (cmd && table[cmd]) table[cmd]();
else if (cmd && cmd !== 'registry') { console.error('unknown command ' + cmd); process.exit(1); }
