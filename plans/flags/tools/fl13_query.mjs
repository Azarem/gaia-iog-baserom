#!/usr/bin/env node
// fl13_query.mjs - READ-ONLY query tool for the FL13 analysis (per-scene clear reward, domain D5, global flags $0300-$03FF).
//
// This script WRITES NOTHING. It prints to stdout; the caller redirects the output into plans/flags/results/.
// It reads only:
//   rebuilt/Illusion of Gaia.smc                   (2 MB original image, no header; decimal file offsets) to decode and cross-check table rows and scene_actors rows
//   extracted/tables/enemy_clear_reward_table.asm  (tier bytes, file:line of every row)
//   extracted/tables/scene_actors.asm              (scene actor lists: enemy-spawn rows, file:line)
//   extracted/**/*.asm                             (enemy actor scripts, scanned for their death path)
//   db-us/groups.json                              (scene id -> group, scene name, prefix)
//   plans/flags/inventory.json                     (FL01 inventory: helper calls and the enemy_clear_reward_flags trace)
// It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl13_query.mjs table      # tier per scene, asm vs ROM, offset and file:line, tier counts
//   node plans/flags/tools/fl13_query.mjs scenes     # per table scene: group/name and its enemy-spawn rows (actor, stats, enemy number, event block)
//   node plans/flags/tools/fl13_query.mjs actors     # per enemy actor label: file, death-path keywords found in its own script
//   node plans/flags/tools/fl13_query.mjs tierscan   # table scenes without enemies, tier-0 scenes with enemies, boss and reward placements
//   node plans/flags/tools/fl13_query.mjs reach      # warp entries and literal QueueMapChange operands naming each table scene
//   node plans/flags/tools/fl13_query.mjs notecheck  # tier lists of the enemy_clear_reward_table block note against the decoded table
//   node plans/flags/tools/fl13_query.mjs md         # the 87-row scene table of the report (stdout)
//   node plans/flags/tools/fl13_query.mjs registry   # the registry fragment JSON (stdout; the caller redirects it into plans/flags/results/registry/)
import fs from 'node:fs';
import path from 'node:path';

const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const sceneInfo = new Map();
for (const [g, v] of Object.entries(groups)) for (const [name, s] of Object.entries(v.scenes)) sceneInfo.set(s.id, { group: g, prefix: v.prefix, name, description: s.description });
const sceneTxt = s => { const i = sceneInfo.get(s); return `$${hex(s)} ${i ? i.group + '/' + i.name : '?'}`; };

const TABLE_FILE = 'extracted/tables/enemy_clear_reward_table.asm';
const ACTORS_FILE = 'extracted/tables/scene_actors.asm';
const TABLE_ROM = 109278;            // enemy_clear_reward_table: 256 bytes, bank $01
const ACTOR_PTR_TABLE = 819200;      // scene_actors: 256 words, records in bank $0C
const ACTOR_BANK_BASE = 786432;      // 0xC0000
const TIER_NAME = ['none', 'Max HP +1', 'STR +1', 'DEF +1'];

// ---------------------------------------------------------------- reward table
export function tableRows() {
    const lines = fs.readFileSync(TABLE_FILE, 'utf8').split(/\r?\n/);
    const rows = [];
    lines.forEach((l, i) => {
        const m = /^\s+#([0-9A-F]{2})\s+;([0-9A-F]{2})\s*$/.exec(l);
        if (m) rows.push({ scene: parseInt(m[2], 16), tier: parseInt(m[1], 16), line: i + 1 });
    });
    for (const r of rows) {
        r.offset = TABLE_ROM + r.scene;
        r.rom = ROM[r.offset];
        r.romMatch = r.rom === r.tier;
        r.flag = 0x300 + r.scene;
        r.byte = 0xA00 + (r.flag >> 3);
        r.bit = r.flag & 7;
        r.si = sceneInfo.get(r.scene);
    }
    return rows;
}

// ---------------------------------------------------------------- scene_actors
export function sceneActors() {
    const lines = fs.readFileSync(ACTORS_FILE, 'utf8').split(/\r?\n/);
    const scenes = new Map(); // scene -> { line, rows: [] }
    let cur = null;
    lines.forEach((l, i) => {
        let m = /^scene_([0-9A-F]{2})_actors \[/.exec(l);
        if (m) { cur = { scene: parseInt(m[1], 16), line: i + 1, rows: [] }; scenes.set(cur.scene, cur); return; }
        if (/^scene_default_actors \[/.test(l)) { cur = null; return; }
        if (/^\]/.test(l)) { cur = null; return; }
        m = /^\s+(enemy|actor)-spawn < (.*) >\s+;([0-9A-F]+)\s*$/.exec(l);
        if (m && cur) {
            const ops = m[2].split(',').map(s => s.trim());
            const row = { kind: m[1], row: parseInt(m[3], 16), line: i + 1, x: parseInt(ops[0].slice(1), 16), y: parseInt(ops[1].slice(1), 16), attr: parseInt(ops[2].slice(1), 16), actor: ops[3].replace(/^@/, '') };
            if (m[1] === 'enemy') { row.stats = parseInt(ops[4].slice(1), 16); row.enemyNum = parseInt(ops[5].slice(1), 16); row.evt = parseInt(ops[6].slice(1), 16); }
            cur.rows.push(row);
        }
    });
    // ROM offsets per row
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
            }
            o += stats ? 9 : 7; k++;
        }
        S.romRows = k;
    }
    return scenes;
}

// ---------------------------------------------------------------- extracted file index (label -> file)
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
    // an actor label is defined as "label [" / "label {" at column 0, or is the file stem
    const stem = asmFiles().find(f => path.basename(f, '.asm') === label);
    if (stem) return stem;
    const re = new RegExp('^' + label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ' [\\[{]', 'm');
    return asmFiles().find(f => re.test(fs.readFileSync(f, 'utf8'))) ?? null;
}

// ---------------------------------------------------------------- commands
function cmdTable() {
    const rows = tableRows();
    let bad = 0;
    for (const r of rows) {
        if (r.tier || process.argv[3] === 'all') {
            console.log([`$${hex(r.scene)}`, sceneInfo.get(r.scene) ? `${r.si.group}/${r.si.name}` : '(no scene record)', `tier ${r.tier} ${TIER_NAME[r.tier] ?? '?'}`, `flag $${hex(r.flag, 4)} (${r.flag})`, `byte $${hex(r.byte, 4)} bit ${r.bit}`, `offset ${r.offset}`, `asm:${r.line}`, r.romMatch ? 'rom-ok' : 'ROM-MISMATCH'].join('\t'));
        }
        if (!r.romMatch) bad++;
    }
    const cnt = [0, 0, 0, 0, 0];
    for (const r of rows) cnt[Math.min(r.tier, 4)]++;
    console.log(`# rows ${rows.length}, rom mismatches ${bad}, tier counts: 0=${cnt[0]} 1=${cnt[1]} 2=${cnt[2]} 3=${cnt[3]} >3=${cnt[4]}; nonzero ${rows.filter(r => r.tier).length}`);
}

function cmdScenes() {
    const rows = tableRows().filter(r => r.tier);
    const SA = sceneActors();
    for (const r of rows) {
        const S = SA.get(r.scene);
        console.log(`\n== ${sceneTxt(r.scene)} tier ${r.tier} flag $${hex(r.flag, 4)} list asm:${S?.line} offset ${S?.romStart}`);
        if (!S) { console.log('  (no scene record)'); continue; }
        for (const x of S.rows) {
            if (x.kind === 'enemy') console.log(`  enemy #${hex(x.row)} ${x.actor} stats $${hex(x.stats)} num $${hex(x.enemyNum)} evt $${hex(x.evt)} asm:${x.line} off ${x.offset}${x.romMatch ? '' : ' ROM-MISMATCH'}`);
        }
    }
}


const readLines = f => fs.readFileSync(f, 'utf8').split(/\r?\n/);

// enemy actor labels placed by scene_actors, with the lines of their own script that touch the death path
function cmdActors() {
    const SA = sceneActors();
    const tbl = new Map(tableRows().map(r => [r.scene, r.tier]));
    const labels = new Map();
    for (const [sc, S] of SA) for (const x of S.rows) {
        if (x.kind !== 'enemy') continue;
        const e = labels.get(x.actor) ?? { scenes: new Set(), tableScenes: new Set(), stats: new Set() };
        e.scenes.add(sc); e.stats.add(x.stats); if (tbl.get(sc)) e.tableScenes.add(sc);
        labels.set(x.actor, e);
    }
    const kw = /StandardEnemyDefeatHandler|EnemyDefeatDispatch|EnemyDefeatFlashAndDrop|SetDeathCallback|EnemyDefeatBossCleanup|enemiesRemaining|\$0AEC|\$0AEE|OrExtraFlags|extendedFlags|\$7F002A/;
    for (const [label, e] of [...labels].sort()) {
        const stem = label.split('.')[0];
        const f = fileOfActor(stem);
        const hits = [];
        if (f) readLines(f).forEach((l, i) => { if (kw.test(l) && !/^\s*;/.test(l)) hits.push(`${i + 1}:${l.trim().slice(0, 110)}`); });
        console.log(`${label}\tfile ${f}\tstats ${[...e.stats].map(x => '$' + hex(x)).join(',')}\tscenes ${e.scenes.size} (table ${e.tableScenes.size})`);
        for (const h of hits.slice(0, 8)) console.log('    ' + h);
    }
}

// every scene: tier, enemy-spawn rows (all have a nonzero stats index, so all are counted at spawn), boss/reward placements
const BOSS_RANGES = [ // boss_reward_range_table rows 0-4 (actors/boss_clear_reward_handler.asm): scene, first, last (exclusive)
    { n: 0, scene: 0x29, first: 0x0C, last: 0x29 }, { n: 1, scene: 0x55, first: 0x3D, last: 0x55 }, { n: 2, scene: 0x67, first: 0x5A, last: 0x67 },
    { n: 3, scene: 0x8A, first: 0x6D, last: 0x8A }, { n: 4, scene: 0xDD, first: 0xA0, last: 0xDD },
];
function rangeOf(scene) { return BOSS_RANGES.find(r => scene >= r.first && scene < r.last) ?? null; }

function cmdAll() {
    const T = new Map(tableRows().map(r => [r.scene, r]));
    const SA = sceneActors();
    const out = [];
    for (let sc = 0; sc < 256; sc++) {
        const S = SA.get(sc);
        const en = S ? S.rows.filter(r => r.kind === 'enemy') : [];
        const placed = S ? S.rows.filter(r => /boss_clear_reward_handler|e_hp_increase|e_str_increase|e_def_increase|field_reveal_object|reward_actors/.test(r.actor)).map(r => r.actor) : [];
        out.push({ sc, tier: T.get(sc).tier, enemies: en.length, untracked: en.filter(r => r.enemyNum === 0).length, boss: S?.rows.some(r => /boss_clear_reward_handler/.test(r.actor)) ?? false, placed, range: rangeOf(sc)?.n ?? '-', info: sceneTxt(sc), hasRecord: !!S });
    }
    return out;
}
function cmdTierScan() {
    const all = cmdAll();
    console.log('# table scenes (tier>0) with no enemy-spawn row:');
    for (const r of all.filter(r => r.tier && !r.enemies)) console.log(`  ${r.info} tier ${r.tier} range ${r.range} record ${r.hasRecord}`);
    console.log('# table scenes outside every boss range:');
    for (const r of all.filter(r => r.tier && r.range === '-')) console.log(`  ${r.info} tier ${r.tier}`);
    console.log('# scenes with enemy-spawn rows and tier 0 (last kill pays nothing, flag $0300+scene is never set, last enemy never drops a gem):');
    for (const r of all.filter(r => !r.tier && r.enemies)) console.log(`  ${r.info} enemies ${r.enemies} untracked ${r.untracked} range ${r.range}`);
    console.log('# boss_clear_reward_handler placements:');
    for (const r of all.filter(r => r.boss)) console.log(`  ${r.info} tier ${r.tier} range ${r.range}`);
    console.log('# scenes that place a reward actor or field_reveal_object directly:');
    for (const r of all.filter(r => r.placed.some(a => !/boss_clear/.test(a)))) console.log(`  ${r.info} ${r.placed.join(',')}`);
    console.log('# totals: table scenes', all.filter(r => r.tier).length, '| table scenes with enemies', all.filter(r => r.tier && r.enemies).length, '| tier-0 scenes with enemies', all.filter(r => !r.tier && r.enemies).length);
}

// reachability hint: how many scene_warps entries and literal QueueMapChange operands name the scene (a partial hint; computed destinations are not seen)
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
function cmdReach() {
    const { warp, qmc } = destinations();
    for (const r of tableRows().filter(r => r.tier)) {
        const w = warp.get(r.scene) ?? [], q = qmc.get(r.scene) ?? [];
        console.log(`${sceneTxt(r.scene)}\twarp entries naming it ${w.length} (from ${[...new Set(w)].map(x => hex(x)).join(',') || '-'})\tQueueMapChange literals ${q.length}${q.length ? ' ' + q.slice(0, 2).join(' ') : ''}`);
    }
}

// the tier table of the enemy_clear_reward_table block note (comment lines of the asm) against the decoded rows
function cmdNoteCheck() {
    const lines = readLines(TABLE_FILE);
    const rows = tableRows();
    let bad = 0;
    for (const t of [1, 2, 3]) {
        const l = lines.find(x => new RegExp('^; \\| ' + t + ' \\|').test(x));
        const m = /\| (\d+): ([^|]*)\|/.exec(l);
        const listed = m[2].trim().split(/\s+/).map(s => parseInt(s.slice(1), 16));
        const actual = rows.filter(r => r.tier === t).map(r => r.scene);
        const same = listed.length === actual.length && listed.every((v, i) => v === actual[i]);
        console.log(`tier ${t}: note says ${m[1]} scenes, table has ${actual.length}; lists ${same ? 'match' : 'DIFFER'}`);
        if (!same) bad++;
    }
    const l0 = lines.find(x => /^; \| 0 \| none \|/.test(x));
    console.log(`tier 0: note says ${/\| (\d+) \|$/.exec(l0)?.[1]}, table has ${rows.filter(r => !r.tier).length}`);
    console.log(bad ? 'MISMATCH' : 'note table matches the decoded table');
}

// ---------------------------------------------------------------- per-scene synthesis (report rows and registry fragment)
const ACTOR_OF_TIER = ['', 'e_hp_increase', 'e_str_increase', 'e_def_increase'];
const SDH_SPAWN = { 1: 'StandardEnemyDefeatHandler.asm:227 {56758}', 2: 'StandardEnemyDefeatHandler.asm:236 {56778}', 3: 'StandardEnemyDefeatHandler.asm:245 {56798}' };
const BOSS_NAME = ['castoth_lair', 'viper_lair', 'mu_vampire_lair', 'sand_fanger_lair', 'mummy_queen_lair'];
const PASSIVE = /ir21_frozen_whirligig|dm41_bat_spawner|awB7_sliding_gate/;
const ZOMBIE = /awB0_zombie/;
const AREA = { edward_castle: 'ec', incan_ruins: 'ir', diamond_mine: 'dm', sky_garden: 'sg', mu: 'mu', angel_village: 'av', great_wall: 'gw', mountain_temple: 'mt', angkor_wat: 'aw', pyramid: 'py', itory: 'it', seaside_palace: 'sp', mansion: 'ma', babel_tower: 'bt' };

function synth() {
    const SA = sceneActors();
    const out = [];
    for (const r of tableRows().filter(r => r.tier)) {
        const S = SA.get(r.scene);
        const en = S ? S.rows.filter(x => x.kind === 'enemy') : [];
        const rg = rangeOf(r.scene);
        const si = sceneInfo.get(r.scene);
        const group = si?.group ?? (rg ? ['edward_castle', 'diamond_mine', 'seaside_palace', 'great_wall', 'pyramid'][rg.n] : null);
        const area = si ? si.group : 'great_wall';
        const slug = si ? si.name : 'scene_' + hex(r.scene).toLowerCase();
        const pre = AREA[area] ?? area;
        const passive = en.filter(x => PASSIVE.test(x.actor));
        const zombie = en.filter(x => ZOMBIE.test(x.actor));
        const labels = [...new Set(en.map(x => x.actor.split('.')[0]))];
        out.push({ ...r, S, en, rg, area, slug, name: `${pre}_${slug}_clear_reward_claimed`, passive, zombie, labels, kind: ['', 'Max HP +1', 'STR +1', 'DEF +1'][r.tier] });
    }
    return out;
}
function cmdMd() {
    for (const x of synth()) {
        const sc = `$${hex(x.scene)} ${x.si ? x.si.group + '/' + x.si.name : '(no scene record)'}`;
        const last = x.en.length ? `${x.en.length} enemy rows (${x.labels.slice(0, 3).join(', ')}${x.labels.length > 3 ? ', ...' : ''}); scene_actors.asm:${x.S.line}` : 'none (no enemy row)';
        const notes = [];
        if (!x.en.length) notes.push(`no enemy row: only the boss catch-up can pay it${x.si ? '' : '; no scene record, no warp entry'}`);
        if (x.passive.length) notes.push(`counted row without a death path read: ${x.passive.map(p => `#${hex(p.row)} ${p.actor} asm:${p.line} {${p.offset}}`).join('; ')}`);
        if (x.zombie.length) notes.push(`${x.zombie.length} awB0_zombie rows: death callback code_0BB800 (768000) does not reach the counters in the code read`);
        const grade = (x.passive.length || x.zombie.length) ? 'INFERRED' : 'VERIFIED-STATIC';
        console.log(`| ${sc} | $${hex(x.flag, 4)} = ${x.flag}; $${hex(x.byte, 4)} bit ${x.bit} | ${x.kind} (${ACTOR_OF_TIER[x.tier]}) | asm:${x.line} {${x.offset}} | ${last} | boss ${x.rg.n} (scene $${hex(x.rg.scene)} ${BOSS_NAME[x.rg.n]}) | ${grade}${notes.length ? '; ' + notes.join('; ') : ''} |`);
    }
}
function cmdRegistry() {
    const rows = synth();
    const names = new Set();
    const flags = {};
    const sources = {
        radar: 'extracted/system/engine/radar_map_screen.asm:175 {229828}',
        sdhTest: 'extracted/functions/StandardEnemyDefeatHandler.asm:204 {56727}',
        sdhGem: 'extracted/functions/StandardEnemyDefeatHandler.asm:89 {56311}',
        vfx: 'extracted/actors/reward_actors.asm:115 {57679}',
        bossTest: 'extracted/actors/boss_clear_reward_handler.asm:154 {50026}',
        bossSet: 'extracted/actors/boss_clear_reward_handler.asm:159 {50035}',
    };
    for (const x of rows) {
        if (names.has(x.name)) throw new Error('duplicate name ' + x.name);
        names.add(x.name);
        const place = x.si ? `scene $${hex(x.scene)} (${x.slug})` : `scene $${hex(x.scene)} (no scene record)`;
        const grade = (x.passive.length || x.zombie.length) ? 'INFERRED' : 'VERIFIED-STATIC';
        const evidence = [`extracted/tables/enemy_clear_reward_table.asm:${x.line} {${x.offset}}`, sources.sdhTest, 'extracted/functions/StandardEnemyDefeatHandler.asm:' + SDH_SPAWN[x.tier].split(':')[1], sources.vfx, sources.bossTest, sources.bossSet, sources.radar, sources.sdhGem];
        if (x.S) evidence.push(`extracted/tables/scene_actors.asm:${x.S.line} {${x.S.romStart}}`);
        for (const p of x.passive) evidence.push(`extracted/tables/scene_actors.asm:${p.line} {${p.offset}}`);
        const notes = [];
        notes.push(`Table row asm:${x.line} (tier byte ${x.tier}, checked against the ROM byte at ${x.offset}). Boss catch-up row ${x.rg.n} of boss_reward_range_table covers this scene (boss scene $${hex(x.rg.scene)}, range $${hex(x.rg.first)}-$${hex(x.rg.last - 1)}); that handler also sets the flag.`);
        if (!x.en.length) notes.push('The scene list holds no enemy-spawn row, so the last-enemy route cannot fire here: only the boss catch-up pays this flag.' + (x.si ? '' : ' No scene record or warp entry names the scene.'));
        if (x.passive.length) notes.push(`The scene list holds ${x.passive.length} enemy-spawn row(s) whose actor script has no death path (${x.passive.map(p => p.actor).join(', ')}); InitActorFromSceneData counts them at spawn (actor_execution.asm:1005 {249750}), so the last-enemy test may never reach 0 and the boss catch-up may be the only payer. Whether the player can kill them is not traced (runtime queue).`);
        if (x.zombie.length) notes.push(`${x.zombie.length} awB0_zombie rows are counted at spawn; the zombie death callback code_0BB800 (awB0_zombie.asm {768000}) does not decrement the counters in the code read, so the last-enemy route is unresolved (runtime queue).`);
        notes.push('The name is derived from the scene list and the table, not from dialog text.');
        flags[String(x.flag)] = {
            domain: 'D5',
            meanings: [{
                scope: null,
                name: x.name,
                area: x.area,
                summary: `The stat reward of ${place} (${x.kind}) has been claimed.`,
                kinds: ['reward-claimed'],
                grade,
                effects: {
                    set: `The radar map draws no reward frame; EnemyStatBonusReward ends in Die without a pickup; every enemy of the scene takes the gem path (stats byte +3), the last one included; BossClearApplyStatReward skips the room.`,
                    clear: `The radar map shows the reward frame, icon and label while the scene is current; the last enemy spawns ${ACTOR_OF_TIER[x.tier]} (${x.kind}) and drops no gem; the pickup sets the flag when it reaches the player; the boss catch-up of boss ${x.rg.n} pays the room if the flag is still clear at the boss's death.`,
                },
                evidence,
                notes: notes.join(' '),
            }],
        };
        if (grade === 'INFERRED') flags[String(x.flag)].meanings[0].queue = [`FL13-${x.passive.length ? 'PASSIVE' : 'ZOMBIE'}-${hex(x.scene)}`];
    }
    const out = {
        _note: 'FL13 fragment. domains.D5 is the domain record; flags: one record per nonzero row of enemy_clear_reward_table (87 scenes). Every flag is read by the radar, StandardEnemyDefeatHandler and boss_clear_reward_handler and written by RewardActorVFX and BossClearApplyStatReward, so each gets a full record. No spine flags. The 169 zero-tier scenes have no writer and no reader of an effect (the helpers can still test them), so they get no record.',
        domains: {
            D5: {
                name: 'scene clear reward',
                ranges: [[768, 1023]],
                indexed: true,
                persistence: 'save',
                lifecycle: 'Bytes $0A60-$0A7F of the save block; ClearSceneState zeroes only $0A00-$0A01 and ClearAllWramFlags only $0A80-$0A9F, and no clear wrapper exists for the _0300 base, so a set bit stays for the life of the save. Flag $0300 + scene id marks the stat reward of that scene as claimed. Only the 87 scenes with a nonzero enemy_clear_reward_table tier ever get the bit; the other 169 indices are never written.',
                access: 'TestFlag_0300 (RadarScreenSetup, StandardEnemyDefeatHandler twice, field_reveal_object, BossClearApplyStatReward) and SetFlag_0300 (RewardActorVFX, BossClearApplyStatReward); no COP operand, no direct byte access and no other helper reaches $0300-$03FF.',
            },
        },
        flags,
    };
    console.log(JSON.stringify(out, null, 2));
}

const cmd = process.argv[2];
if (cmd === 'md') cmdMd();
else if (cmd === 'registry') cmdRegistry();
else if (cmd === 'table') cmdTable();
else if (cmd === 'scenes') cmdScenes();
else if (cmd === 'actors') cmdActors();
else if (cmd === 'tierscan') cmdTierScan();
else if (cmd === 'reach') cmdReach();
else if (cmd === 'notecheck') cmdNoteCheck();
else if (cmd) { console.error('unknown command ' + cmd); process.exit(1); }
