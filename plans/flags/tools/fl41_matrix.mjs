#!/usr/bin/env node
// fl41_matrix.mjs - READ-ONLY bit matrix of the flag array $0A00-$0AB3 (FL41 gap analysis).
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json, the registry fragments and queue files under
// plans/flags/results/, extracted/tables/*.asm (through fl32_lib.mjs) and prints to stdout. It never touches extracted/,
// db-us/, notes/, docs/, src/ or any other file. Redirect its output yourself (the FL41 report was produced with
// `fl41_report.mjs coverage > plans/flags/results/coverage.md`).
//
// Usage (repository root):
//   node plans/flags/tools/fl41_matrix.mjs summary     counts per axis and per domain
//   node plans/flags/tools/fl41_matrix.mjs bit <hex>   the row of one bit as JSON
//   node plans/flags/tools/fl41_matrix.mjs rows        every bit row as tab separated text
//
// Axes per bit (each bit has exactly one value per axis):
//   doc  (what the project knows):  record | scene-row | proposal | table-row | none
//   ref  (how the code reaches it): both | set-only | test-only | gate-only | helper-only | table-only | direct-only | debug-only |
//                                   unreferenced | not-a-flag     (set-only and test-only describe LITERAL COP sites; a dynamic
//                                   engine reader is a separate tag and the Task 2 table says where the other half lives)
//   primary: one status from the FL41 vocabulary, by precedence overlap > named record > scene row only > reference status.
// The word "free" is never used: an unreferenced bit names its searches in coverage.md.
import { loadAll, domainOf, byteOf, H4, ranges, BITS, loadGroups } from './fl41_lib.mjs';
import { loadSceneActors } from './fl32_lib.mjs';

export const PRIMARY = [
    'named record', 'scene row only', 'helper-only (no literal COP)', 'table-only', 'set-only', 'test-only',
    'referenced by a direct read', 'literal COP both ways, no record', 'unreferenced', 'overlaps inventory/ability/other state',
];

let cache = null;
export function buildBits() {
    if (cache) return cache;
    const { inv, reg, cop, traces, raw } = loadAll();
    const fl11 = raw.find((r) => r.file === 'FL11_registry.json').json;
    const fl15 = raw.find((r) => r.file === 'FL15_registry.json').json;
    const blockOnly = new Set(Object.keys(fl11._block_only ?? {}).map(Number));
    const noUseBlock = new Set(Object.keys(fl11._no_use ?? {}).map(Number));
    const fl15Doc = new Map();
    for (const [k, v] of Object.entries(fl15._no_use ?? {})) {
        const [a, b] = k.split('-').map(Number);
        for (let i = a; i <= (b ?? a); i++) fl15Doc.set(i, v.note);
    }
    const groups = loadGroups();
    const sceneActors = loadSceneActors();
    const enemyScenes = new Set();
    for (const [id, v] of sceneActors) if (v.actors.some((a) => a.kind === 'other' && /enemy-spawn/.test(a.text))) enemyScenes.add(id);
    // tier table candidates (tier != 0) from the trace
    const tierScenes = new Set((inv.traces.find((t) => t.id === 'enemy_clear_reward_flags').candidate_indices ?? []).map((i) => i - 0x300));
    const directBits = new Map();
    const addDirect = (b, what, cite) => { const a = directBits.get(b) ?? []; a.push({ what, cite }); directBits.set(b, a); };
    for (const b of [1, 2, 3, 4]) addDirect(b, 'plate gate mask $001E', 'incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:19 {640148}');
    for (let b = 0; b < 8; b++) addDirect(b, 'Rama compare low byte == $FE', 'mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951}');
    for (let b = 8; b < 16; b++) addDirect(b, 'laborer hit counter (byte $0A01)', 'diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042}');
    addDirect(255, 'engine clear/set of flag $FF', 'system/engine/scene_lifecycle.asm:842 {253418}, :844 {253423}; system/inventory/inventory_overlay.asm:131 {191814}, :133 {191819}');
    for (let b = 0x4f8; b <= 0x4ff; b++) addDirect(b, 'tomb mask byte $0A9F == $3F', 'great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380}');
    // abilityBitmask direct reads (BIT masks): bit -> cite
    const abil = [
        [0x510, '$0005', 'actors/player/attack_ability_system.asm:155 {178162}'],
        [0x512, '$0005/$0004', 'actors/player/attack_ability_system.asm:155 {178162}, :177 {178217}; great_wall/wall_rampway/gw85_spin_dash_gate.asm:27 {518420}'],
        [0x511, '$0002', 'actors/player/player_character.asm:1293 {183198}'],
        [0x514, '$0050', 'actors/player/attack_ability_system.asm:213 {178285}'],
        [0x516, '$0050/$0040', 'actors/player/attack_ability_system.asm:213 {178285}; actors/player/player_character.asm:593 {181957}'],
        [0x515, '$0020', 'actors/player/attack_ability_system.asm:236 {178346}'],
    ];
    for (const [b, m, c] of abil) addDirect(b, `abilityBitmask BIT #${m}`, c);
    const debugStores = [781889, 637608];
    for (const off of debugStores) if (!inv.direct_accesses.some((d) => d.offset === off)) throw new Error('debug store offset ' + off + ' missing from the inventory');

    const rows = [];
    for (let b = 0; b < BITS; b++) {
        const dom = domainOf(b);
        const rec = reg.flags.get(b);
        const props = reg.proposals.get(b) ?? [];
        const meanings = rec?.meanings ?? [];
        const named = meanings.filter((m) => m.level !== 'row' && m.name);
        const rowOnly = meanings.filter((m) => m.level === 'row');
        const c = cop.get(b);
        const tr = traces.get(b);
        const byte = byteOf(b);
        const tags = [];
        let doc = 'none';
        if (named.length) doc = 'record';
        else if (rowOnly.length) doc = 'scene-row';
        else if (props.length) doc = 'proposal';
        const writes = c ? c.S + c.C : 0;
        const tests = c ? c.T + c.W + c.G : 0;
        const helperRefs = tr ? [...new Set(tr.helper)] : [];
        const tableRefs = tr ? [...new Set(tr.table)] : [];
        const eventBlockRow = dom === 'D3' && b - 256 <= 157;
        if (c?.G) tags.push('scene-meta gate');
        if (c?.word) tags.push('word form');
        if (helperRefs.length) tags.push('helper: ' + helperRefs.join(','));
        if (tableRefs.length) tags.push('table: ' + tableRefs.join(','));
        if (eventBlockRow) tags.push('event block row $' + (b - 256).toString(16).toUpperCase().padStart(2, '0'));
        if (dom === 'D3') tags.push('read by the ApplyAllEventBlocks scan (event_blocks.asm:81 {172529}, all 256 bits)');
        if (dom === 'D3' && !eventBlockRow) tags.push('beyond the 158-row table: LookupEventBlock has no bound check');
        if (directBits.has(b)) tags.push('direct: ' + directBits.get(b).map((x) => x.what).join('; '));
        if (dom === 'D7a') tags.push('overlaps abilityBitmask $0AA2-$0AA3');
        if (b >= 8 && b < 16) tags.push('overlaps counter byte $0A01');
        let ref;
        let dynTest = false;
        if (dom === 'S') ref = 'not-a-flag';
        else if (writes > 0 && tests > 0) ref = 'both';
        else if (writes > 0) ref = 'set-only';
        else if (tests > 0) ref = c.T + c.W > 0 ? 'test-only' : 'gate-only';
        else if (helperRefs.length && directBits.has(b)) ref = 'helper+direct';
        else if (helperRefs.length) ref = 'helper-only';
        else if (tableRefs.length || eventBlockRow) ref = 'table-only';
        else if (directBits.has(b)) ref = 'direct-only';
        else if (dom === 'D7a' && b <= 0x517) ref = 'debug-only';
        else if (dom === 'D3') { ref = 'test-only'; dynTest = true; } // engine scan only
        else if (dom === 'D5') {
            const s = b - 0x300;
            if (groups.scenes.has(s)) {
                ref = 'test-only';
                dynTest = true;
                tags.push(enemyScenes.has(s) ? 'dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows' : 'dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row');
            } else ref = 'unreferenced';
        } else ref = 'unreferenced';
        if (doc === 'none' && (tableRefs.length || eventBlockRow)) doc = 'table-row';
        // primary status
        let primary;
        if (dom === 'S' || (dom === 'D7a' && doc !== 'record')) primary = 'overlaps inventory/ability/other state';
        else if (doc === 'record') primary = 'named record';
        else if (doc === 'scene-row') primary = 'scene row only';
        else if (ref === 'both') primary = 'literal COP both ways, no record';
        else if (ref === 'helper-only' || ref === 'helper+direct') primary = 'helper-only (no literal COP)';
        else if (ref === 'table-only') primary = 'table-only';
        else if (ref === 'set-only') primary = 'set-only';
        else if (ref === 'test-only' || ref === 'gate-only') primary = 'test-only';
        else if (ref === 'direct-only' || ref === 'debug-only') primary = 'referenced by a direct read';
        else primary = 'unreferenced';
        // debug-only bits of the ability byte are overlap bits by the rule above; keep the ref axis for the detail
        rows.push({
            b, hex: H4(b), byte, bit: b & 7, dom, doc, ref, primary, tags, dynTest,
            names: named.map((m) => ({ name: m.name, scope: m.scope ?? null, grade: m.grade })),
            rowScopes: rowOnly.map((m) => m.scope),
            proposals: props.map((p) => p.name),
            cop: c ? { S: c.S, C: c.C, T: c.T, W: c.W, G: c.G, scenes: [...c.scenes].sort((x, y) => x - y) } : null,
            blockOnly: blockOnly.has(b), noUseBlock: noUseBlock.has(b), fl15: fl15Doc.get(b) ?? null,
            direct: directBits.get(b) ?? [],
            helperRefs, tableRefs,
            enemyScene: dom === 'D5' ? enemyScenes.has(b - 0x300) : null,
            tier: dom === 'D5' ? tierScenes.has(b - 0x300) : null,
        });
    }
    cache = rows;
    return rows;
}

const isMain = process.argv[1] && /fl41_matrix\.mjs$/.test(process.argv[1]);
if (isMain) {
    const cmd = process.argv[2];
    const rows = buildBits();
    const count = (key) => rows.reduce((a, r) => ((a[r[key]] = (a[r[key]] ?? 0) + 1), a), {});
    if (cmd === 'summary') {
        console.log('doc', JSON.stringify(count('doc')));
        console.log('ref', JSON.stringify(count('ref')));
        console.log('primary', JSON.stringify(count('primary')));
        const cross = {};
        for (const r of rows) cross[`${r.dom} ${r.primary}`] = (cross[`${r.dom} ${r.primary}`] ?? 0) + 1;
        for (const k of Object.keys(cross).sort()) console.log(k, cross[k]);
    } else if (cmd === 'bit') {
        console.log(JSON.stringify(rows[parseInt(process.argv[3], 16)], null, 1));
    } else if (cmd === 'rows') {
        for (const r of rows) console.log([r.hex, '$' + r.byte.toString(16).toUpperCase(), r.bit, r.dom, r.doc, r.ref, r.primary, r.names.map((n) => n.name).join('|'), r.tags.join('; ')].join('\t'));
    } else if (cmd === 'unref') {
        console.log(ranges(rows.filter((r) => r.primary === 'unreferenced').map((r) => r.b)));
    }
}
