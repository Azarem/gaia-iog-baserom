#!/usr/bin/env node
// fl31_build.mjs - builds the FL31 spine-flag registry fragments and queue from the earlier fragments.
//
// WRITES ONLY these four files (and nothing else, never extracted/, notes/, db-us/, baserom/, docs/, src/, us/):
//   plans/flags/results/registry/FL31_registry.json         final records of the spine flags that have no record yet
//   plans/flags/results/registry/FL31b_registry.json        patch entries (expectOld) for the spine flags that already own a record
//   plans/flags/results/queue/FL31_queue.json               new runtime-queue items
//   plans/flags/results/FL31_20261104_sites.md              coverage and site appendix of the spine
// It READS plans/flags/inventory.json, plans/flags/results/registry/FL*_registry.json (proposals and records),
// plans/flags/results/queue/FL*_queue.json, db-us/groups.json and plans/flags/tools/fl31_decisions.json (hand-authored).
//
// Record rule: the owner iteration is the non-FL10/FL11/FL30 proposal with the highest confidence (latest wins on a tie);
// FL10/FL11 count only when nothing else exists. Summary, kinds and notes come from the owner (sentences about the
// proposal process are dropped), evidence lists EVERY inventory site of the index, effects exist only where
// fl31_decisions.json writes them. fl31_decisions.json overrides any field. Usage (repo root): node plans/flags/tools/fl31_build.mjs [--check]
import fs from 'node:fs';
import path from 'node:path';

const CHECK = process.argv.includes('--check');
const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const decisions = JSON.parse(fs.readFileSync('plans/flags/tools/fl31_decisions.json', 'utf8'));
const regDir = 'plans/flags/results/registry';
const qDir = 'plans/flags/results/queue';
const KINDS = ['once-latch', 'quest-guard', 'quest-done', 'gate-open', 'handshake', 'cutscene-stage', 'puzzle-state', 'reward-claimed', 'form-latch', 'engine', 'idiom', 'unknown'];
const KIND_MAP = { 'boss-defeated': 'quest-done', 'party-trigger': 'cutscene-stage', 'scene-latch': 'once-latch' };
const hex = (n, w = 4) => '$' + Number(n).toString(16).toUpperCase().padStart(w, '0');
const group = (f) => (f.includes('/') ? f.split('/')[0] : '(root)');
const CONF = { low: 0, medium: 1, high: 2 };

// ---- spine (same definition as fl31_spine.mjs)
const byIdx = new Map();
for (const s of inv.sites.filter((x) => x.kind === 'cop' && x.index != null && x.index >= 16)) {
    const e = byIdx.get(s.index) ?? { sites: [], groups: new Set() };
    e.sites.push(s);
    e.groups.add(group(s.file));
    byIdx.set(s.index, e);
}
const spine = [...byIdx].filter(([, e]) => e.groups.size >= 2).map(([i]) => i).sort((a, b) => a - b);

// ---- fragments
const records = new Map(); // idx -> [{src, ...meaning}]
const proposals = new Map();
const allNames = []; // {name, idx, src}
for (const f of fs.readdirSync(regDir).filter((x) => /^FL\d+_registry\.json$/.test(x) && !x.startsWith('FL31')).sort()) {
    const src = f.slice(0, 4);
    const j = JSON.parse(fs.readFileSync(path.join(regDir, f), 'utf8'));
    for (const [k, v] of Object.entries(j.flags ?? {})) for (const m of v.meanings ?? []) {
        (records.get(Number(k)) ?? records.set(Number(k), []).get(Number(k))).push({ src, ...m });
        if (m.name) allNames.push({ name: m.name, idx: Number(k), src });
    }
    for (const [k, v] of Object.entries(j.proposals ?? {})) for (const p of Array.isArray(v) ? v : [v]) {
        (proposals.get(Number(k)) ?? proposals.set(Number(k), []).get(Number(k))).push({ src, ...p });
        if (p.name) allNames.push({ name: p.name, idx: Number(k), src });
    }
}
const queueByFlag = new Map();
for (const f of fs.readdirSync(qDir).filter((x) => /^FL\d+_queue\.json$/.test(x) && !x.startsWith('FL31'))) {
    const q = JSON.parse(fs.readFileSync(path.join(qDir, f), 'utf8'));
    for (const it of Array.isArray(q) ? q : q.items ?? []) (queueByFlag.get(it.flag) ?? queueByFlag.set(it.flag, []).get(it.flag)).push(it.id);
}

const prefixToGroup = new Map(Object.entries(groups).map(([g, d]) => [d.prefix, g]));
prefixToGroup.set('sys', 'system');
const areaOf = (name) => prefixToGroup.get(name.split('_')[0]);
const mapKinds = (ks) => [...new Set((ks ?? []).map((k) => KIND_MAP[k] ?? k).filter((k) => KINDS.includes(k)))];
const evLine = (s) => `extracted/${s.file}:${s.line} {${s.offset}}`;
const siteEvidence = (idx, filter) => {
    const out = inv.sites.filter((s) => s.index === idx && s.offset != null && (!filter || filter(s)))
        .sort((a, b) => a.offset - b.offset).map(evLine);
    return [...new Set(out)];
};
const agrees = (t) => /^(Agrees|Name and roles agree|Name and roles agree)/i.test((t ?? '').trim());
const noise = /(nothing in this scope contradicts it|Name and roles agree with the earlier iteration)\.?/gi;
// sentences of the group iterations that only talk about the proposal process (resolved by this fragment)
const STALE = /(same name as|agrees? with|\bFL3[01] (decides|should|settles|owns)|FL\d\d (proposed|proposal|side)|(FL10|FL11|FL20|FL21|FL22|FL23|FL24|FL27|FL28|FL29|FL30) proposals?\b|the \w+ group settles it|settles it|^Queue FL\d+-\d+\.?$|\bCONTRADICTS\b|spine proposal|\bFL31\b|\bFL\d\d owns\b|\bfor FL\d\d\b|FL\d\d_notes\.json|spec FL\d\d|^[;\s]*$)/i;

function pickOwner(props) {
    const sane = props.filter((p) => !['FL10', 'FL11', 'FL30'].includes(p.src));
    const pool = sane.length ? sane : props.filter((p) => p.src !== 'FL30').length ? props.filter((p) => p.src !== 'FL30') : props;
    const best = Math.max(...pool.map((p) => CONF[p.confidence] ?? 0));
    const top = pool.filter((p) => (CONF[p.confidence] ?? 0) === best);
    return top[top.length - 1];
}

const out = {}, patches = {}, newQueue = [];
const inferredReason = 'The writers and readers are all listed in the evidence and read; the story label of the state rests on the setter\'s context and dialog text and has not been seen in a running game (queue ids).';
const problems = [];
const meaningRows = [];

for (const idx of spine) {
    const dec = decisions[idx.toString(16).toUpperCase()] ?? {};
    const domain = idx < 256 ? 'D2' : 'D3';
    const own = records.get(idx) ?? [];
    const props = proposals.get(idx) ?? [];
    const existingQ = queueByFlag.get(idx) ?? [];
    const queue = [...new Set([...existingQ, ...(dec.queueNew ?? [])])];

    if (dec.meanings) {
        const ms = dec.meanings.map((m) => {
            const { evidenceGroup, queueNew, ...rest } = m;
            return { ...rest, evidence: siteEvidence(idx, (s) => group(s.file) === evidenceGroup), queue: [...new Set([...(m.queue ?? []), ...(queueNew ?? [])])] };
        });
        out[idx] = { domain, meanings: ms };
        for (const m of ms) meaningRows.push({ idx, m });
        continue;
    }

    if (own.length) {
        // existing record: patch entry only
        const rec = own[0];
        const p = { expectOld: rec.name, patch: true, scope: rec.scope ?? null };
        for (const k of ['requires', 'excludes', 'pairsWith']) if (dec[k]) p[k] = dec[k];
        const q2 = [...new Set([...(rec.queue ?? []), ...queue])];
        if (q2.length) p.queue = q2;
        if (dec.notesAppend) p.notes = `${rec.notes ?? ''} ${dec.notesAppend}`.trim();
        // patch carries only fields that change
        if (Object.keys(p).length > 3) {
            patches[idx] = { domain, meanings: [p] };
        }
        meaningRows.push({ idx, m: { ...rec, queue: q2, requires: dec.requires, pairsWith: dec.pairsWith }, patched: true });
        continue;
    }

    if (!props.length) { problems.push(`${hex(idx)}: no record and no proposal`); continue; }
    const owner = pickOwner(props);
    const name = dec.name ?? owner.name;
    const area = dec.area ?? areaOf(name);
    if (!area) problems.push(`${hex(idx)} ${name}: cannot derive area from prefix`);
    const conf = Math.max(...props.filter((p) => !['FL10', 'FL11'].includes(p.src) || props.length === 1).map((p) => CONF[p.confidence] ?? 0));
    const grade = dec.grade ?? (conf >= 2 ? 'VERIFIED-STATIC' : 'INFERRED');
    let summary = dec.summary ?? owner.summary;
    if (agrees(summary)) summary = (props.find((p) => !agrees(p.summary)) ?? owner).summary;
    const kinds = mapKinds(dec.kinds ?? [...(owner.kinds ?? []), ...props.flatMap((p) => p.kinds ?? [])]);
    const noteParts = [];
    const seen = new Set();
    for (const p of [owner, ...props.filter((x) => x !== owner)]) {
        if (!p.notes || ['FL10'].includes(p.src) && props.length > 1) continue;
        const t = p.notes.replace(noise, '').replace(/\bQ\d+[.:]\s*/g, '').replace(/\s;\s*$/, '').split(/(?<=[.!?])\s+(?=[A-Z$'(`])/)
            .filter((s) => !STALE.test(s)).map((s) => s.trim()).filter(Boolean).join(' ');
        if (!t || agrees(t) || seen.has(t)) continue;
        seen.add(t);
        noteParts.push(t);
    }
    if (dec.notes) noteParts.length = 0, noteParts.push(dec.notes);
    if (dec.notesAppend) noteParts.push(dec.notesAppend);
    if (grade === 'INFERRED' && !dec.notes) noteParts.push(`INFERRED: ${inferredReason}`);
    const meaning = {
        scope: null,
        name,
        area,
        summary,
        kinds,
        grade,
        ...(dec.effects ? { effects: dec.effects } : {}),
        ...(dec.requires ? { requires: dec.requires } : {}),
        ...(dec.excludes ? { excludes: dec.excludes } : {}),
        ...(dec.pairsWith ? { pairsWith: dec.pairsWith } : {}),
        evidence: [...siteEvidence(idx), ...(dec.extraEvidence ?? [])],
        ...(queue.length ? { queue } : {}),
        notes: noteParts.join(' '),
    };
    out[idx] = { domain, meanings: [meaning] };
    meaningRows.push({ idx, m: meaning });
}

// ---- name uniqueness against every other fragment (persistent names are unique registry-wide)
const mine = new Map();
for (const { idx, m } of meaningRows) mine.set(m.name, idx);
for (const [name, idx] of mine) {
    const clash = allNames.filter((n) => n.name === name && n.idx !== idx && n.idx >= 16);
    if (clash.length) problems.push(`name clash ${name} ($${idx.toString(16)}): ${clash.map((c) => `${c.src} ${hex(c.idx)}`).join(', ')}`);
}
const seenNames = new Map();
for (const { idx, m } of meaningRows) {
    if (seenNames.has(m.name) && seenNames.get(m.name) !== idx) problems.push(`duplicate name in FL31: ${m.name}`);
    seenNames.set(m.name, idx);
}

// ---- new queue items (hand-authored below)
const Q = (id, flag, scope, claim, priority, start, trial, confirms, refutes, needs = ['FR00']) => ({ id, flag, scope, claim, priority, start, trial, confirms, refutes, needs });
newQueue.push(
    Q('FL31-01', 255, null, 'After the inventory closes, thinkers parked on WaitOnFlagByte(#FF, #00) resume: the first UpdateFrameRender of the close path runs the restored thinker list while $FF is still clear, so the palette loops replay their bundle and the HDMA / PPU-register thinkers re-initialise.', 'P1',
        { scene: 1, flags: [22], form: 'Will', state: null },
        { control: 'in scene $01 with $16 set and $1C clear, let flag_gated_palette_warm apply bundle #02; log CGRAM writes (palette buffer $7F0A00) and the COP stream of the thinker for 120 frames', forced: 'open the inventory (Select) and close it; repeat in scene $2F (gold_ship_wreck_palette) and in scene $E8 (sE8_comet_display_config rewrites TM/TS/BG1SC)', observe: ['PaletteStart executes for the thinker in the first frame after the close ({192186})', 'the thinker sets $0A1F bit 7 again before the overlay sets it at {192190}', 'no replay while the inventory is open'] },
        'the wake at inventory close described in sys_scene_setup_done (set and clear effects)', 'no PaletteStart / register rewrite in the close frame (the thinkers would stay parked)'),
    Q('FL31-02', 255, null, 'Only two code sites clear $FF: the direct write at scene_lifecycle.asm:844 {253423} and at inventory_overlay.asm:133 {191819}.', 'P2',
        { scene: 'any scene', flags: [], form: 'Will', state: null },
        { control: 'write breakpoint on $0A1F with a condition on bit 7 going 1 -> 0, play title -> South Cape -> inventory -> another scene -> Dark Space for several minutes', forced: 'none', observe: ['PC of every write that clears bit 7', 'count per scene change and per inventory open'] },
        'the absence claim in sys_scene_setup_done (no other clearer)', 'a third PC that clears bit 7'),
    Q('FL31-03', 16, { scenes: [8, 251] }, 'The South Cape church lesson flag and the boot-logo latch are the same bit and never meet: after a boot (or reset) $10 is clear when the title is reached, and Load Game replaces the array.', 'P2',
        { scene: 251, flags: [], form: 'Will', state: null },
        { control: 'cold boot; watch $0A02 bit 0 through the first logo, the second logo, the title and New Game; then play the South Cape church lesson', forced: 'load a save written after the lesson ($10 set), then reach the title again by reset and choose New Game', observe: ['$0A02 bit 0 at each step', 'whether the lesson plays on New Game after a loaded game and a reset', 'whether any path reaches the title without a boot (scene $FC queue sites)'] },
        'both scoped meanings of $10 and the "cannot meet" claim', 'the flag set on arrival at New Game (lesson skipped) or the first logo skipped'),
    Q('FL31-04', 150, null, 'Flag $96 is true from the end of the Lance/Lilly reunion on the Great Wall until the Russian Glass game ends in Watermia.', 'P2',
        { scene: 139, flags: [], form: 'Will', state: null },
        { control: 'play gw8B_lance_lily to the end; read $0A12 bit 6 before and after; enter Watermia (scene $78)', forced: 'set and clear $96 with the debugger in scene $78', observe: ['$96 at the setter {505825}', 'dark palette (pal_watermia_dark) while set', 'glass game spawns while set; flag cleared at {496163}'] },
        'wa_festival_night_active (set interval, name)', 'the flag staying set after the glass game'),
    Q('FL31-05', 244, null, 'Flag $F4 is set by the title idle timeout and cleared in pr8C_prologue1 (first pass of scene $8C); the second pass (pr8C_prologue5) runs with it clear.', 'P2',
        { scene: 252, flags: [], form: 'Will', state: null },
        { control: 'idle on the title for 2516 ticks; read $0A1E bit 4 at the transition and in each pass of scene $8C', forced: 'none', observe: ['$F4 value at scene $8C entry, after pr8C_prologue1, at the second entry', 'which map the scene-meta gate loads in each pass (map_prologue_prophecy_2 first)'] },
        'pr_prophecy_first_pass_active (set = first pass)', 'the flag set in the second pass'),
    Q('FL31-06', 179, null, 'Flag $B3 is set at the end of the Angkor Wat entrance narration and then removes the Native Village Hamlet NPC and switches the scene $AC music.', 'P3',
        { scene: 172, flags: [], form: 'Will', state: null },
        { control: 'enter scene $AC with $B3 clear: Hamlet present, bgm_ominous_whispers', forced: 'set $B3 with the debugger and reload scene $AC', observe: ['Hamlet dies at spawn', 'bgm_blessing_of_nature plays'] },
        'aw_entrance_intro_seen (once-latch and the two readers)', 'Hamlet present or the old music with $B3 set'),
    Q('FL31-07', 187, null, 'Flag $BB is set at the end of the Pyramid Jackal sequence (scene $CD); it stands the Jackal and Kara up, refuses Lola\'s Melody in scene $CD and kills the Dao hotel Kara while $D0 is clear.', 'P2',
        { scene: 205, flags: [], form: 'Will', state: null },
        { control: 'in scene $CD with $BB clear, play the Jackal sequence; read $0A17 bit 3 before and after', forced: 'set $BB and reload scene $CD and scene $C4', observe: ['Jackal solid prop at tile (09,0B)', 'Kara at tile (08,0B)', 'Lola\'s Melody message in $CD', 'Dao Kara dies at spawn'] },
        'py_jackal_scene_done and its readers', 'any reader that does not change with $BB'),
    Q('FL31-08', 64, { scenes: [21] }, 'Flag $40 is set by Lola\'s Melody in the Itory meadow; Lily starts the reveal when it is set, and the melody refuses to play twice.', 'P2',
        { scene: 21, flags: [], form: 'Will', state: null },
        { control: 'play Lola\'s Melody in scene $15 with $40 clear; read $0A08 bit 0', forced: 'set $40 and talk to Lily; try the melody again', observe: ['setter {232527}', 'it15_lily reveal (palette flash thinker 18, camera pan)', 'refusal text at {232406}', 'any tile change in the village'] },
        'it_meadow_lola_melody_played (setter, readers, refusal)', 'a tile change with the flag (a lifted barrier) or a reachable set-branch at {232521}'),
    Q('FL31-09', 377, null, 'Flag $0179 is set by the Neo Queen watcher in the Babel boss lair (scene $F6) and opens the crystal gate in scene $E3; the Mummy Queen does not set it.', 'P2',
        { scene: 246, flags: [], form: 'Shadow', state: null },
        { control: 'fight btF6_neo_queen to the end with a write watch on $0A2F bit 1', forced: 'defeat the Mummy Queen in the Pyramid (scene $DD) with the same watch', observe: ['write at {763546} only in scene $F6', 'btE3_crystal_gate dies and its cells open when $0179 is set'] },
        'bt_crystal_gate_e_open (Neo Queen setter)', 'the flag set by the Mummy Queen fight'),
    Q('FL31-10', 75, null, 'Flag $4B is set after Lily\'s Elder-quote dialog at the Incan ruins entrance (scene $1C); with it set Kara and Lily start in their post state and it15_kara in Itory dies.', 'P3',
        { scene: 28, flags: [], form: 'Will', state: null },
        { control: 'enter scene $1C with $4B clear and walk into tiles (1A,0F)-(1B,11)', forced: 'set $4B and reload scene $1C and scene $15', observe: ['Kara and Lily at tiles (15,13), (16,13)', 'Freedan form returned to Will', 'it15_kara absent in Itory'] },
        'ir_entrance_kara_catchup_done effects', 'post state not reached with the flag set'),
    Q('FL31-11', 165, null, 'Flag $A5 is set by the Euro arrival narration (scene $91) and changes three Watermia actors and the Euro intro.', 'P3',
        { scene: 145, flags: [], form: 'Will', state: null },
        { control: 'play eu91_intro; read $0A14 bit 5', forced: 'set $A5 and enter scenes $79 and $7A', observe: ['wa79_lily and wa79_lance post lines', 'Lance gives the Red Jewel once ($E2)', 'wa7A_lances_father line'] },
        'eu_arrival_cutscene_played effects', 'any Watermia actor unchanged with the flag set'),
);

const doc = (flags) => ({ _note: 'FL31 registry fragment (spine flags). Generated by plans/flags/tools/fl31_build.mjs from the group fragments and plans/flags/tools/fl31_decisions.json.', flags });
const text = JSON.stringify(doc(out), null, 2) + '\n';
const ptext = JSON.stringify({ _note: 'FL31 patch fragment: spine flags that already own a record (FL22, FL27, FL29, FL30). Apply after those fragments: each entry carries expectOld.', flags: patches }, null, 2) + '\n';
const qtext = JSON.stringify(newQueue, null, 2) + '\n';

// ---- appendix
const md = [];
md.push('# FL31 spine appendix (generated)', '', 'Every inventory site of the 62 spine flags. `offset` is the decimal ROM offset (`{n}` tag). Generated by `plans/flags/tools/fl31_build.mjs`.', '');
md.push('## Coverage', '', '| index | name | sites | groups | grade | queue |', '|---|---|---|---|---|---|');
let total = 0;
const counted = new Set();
for (const { idx, m, patched } of meaningRows.sort((a, b) => a.idx - b.idx)) {
    const e = byIdx.get(idx);
    if (!counted.has(idx)) { counted.add(idx); total += e.sites.length; }
    md.push(`| \`${hex(idx)}\` | \`${m.name}\` | ${e.sites.length} | ${[...e.groups].join(', ')} | ${m.grade}${patched ? ' (record kept)' : ''} | ${(m.queue ?? []).join(', ')} |`);
}
md.push('', `Total COP sites: ${total} in ${spine.length} flags.`, '');
md.push('## Sites', '');
for (const idx of spine) {
    const e = byIdx.get(idx);
    md.push(`### \`${hex(idx)}\``, '', '| file:line | offset | opcode | operands | role | scenes |', '|---|---|---|---|---|---|');
    for (const s of [...e.sites].sort((a, b) => a.offset - b.offset)) {
        md.push(`| \`${s.file}:${s.line}\` | ${s.offset} | ${s.opcode} | \`${s.operands}\` | ${s.role}${s.sense ? ' (' + s.sense + ')' : ''} | ${(s.scenes ?? []).map((x) => hex(x, 2)).join(' ')} |`);
    }
    for (const s of inv.sites.filter((x) => x.kind !== 'cop' && x.index === idx)) md.push(`| \`${s.file}:${s.line}\` | ${s.offset} | ${s.kind} | \`${s.operands ?? ''}\` | scene gate |  |`);
    md.push('');
}

if (problems.length) {
    console.error('PROBLEMS:\n' + problems.join('\n'));
}
console.log(`records ${Object.keys(out).length}, patches ${Object.keys(patches).length}, queue ${newQueue.length}, sites ${total}, spine ${spine.length}`);
if (!CHECK && !problems.length) {
    fs.writeFileSync(path.join(regDir, 'FL31_registry.json'), text);
    fs.writeFileSync(path.join(regDir, 'FL31b_registry.json'), ptext);
    fs.writeFileSync(path.join(qDir, 'FL31_queue.json'), qtext);
    fs.writeFileSync('plans/flags/results/FL31_20261104_sites.md', md.join('\n') + '\n');
    console.log('written');
}
