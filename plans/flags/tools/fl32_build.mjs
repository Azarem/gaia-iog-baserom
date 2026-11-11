#!/usr/bin/env node
// fl32_build.mjs - FL32 generator (progression graph). Reads the analysis inputs and writes ONLY the FL32 result files:
//   plans/flags/results/FL32_20261104.md
//   plans/flags/results/registry/FL32_registry.json
//   plans/flags/results/specs/FL32_scene-flags.json
//   plans/flags/results/specs/FL32_presets.json
//   plans/flags/results/queue/FL32_queue.json
// (and nothing else: it never touches extracted/, db-us/, notes/, docs/, src/, artifacts/, us/, baserom/ or the plan files.)
//
// Inputs (read only): plans/flags/results/registry/FL10..FL31b fragments, plans/flags/inventory.json, db-us/groups.json,
// db-us/scene-flags.json (to write the expectOld of scene 10), extracted/**/*.asm (through fl32_guards.mjs / fl32_lib.mjs),
// plans/flags/tools/fl32_decisions.json, fl32_scene_decisions.json, fl32_preset_decisions.json (hand-written decisions),
// and, if present, the dry-run output files plans/flags/results/FL32_20261104_dryrun_*.txt (embedded into the report).
//
// Usage (repo root):
//   node plans/flags/tools/fl32_build.mjs check   # diagnostics on stdout, writes nothing
//   node plans/flags/tools/fl32_build.mjs write   # check + write the five result files
import fs from 'node:fs';
import path from 'node:path';
import { readJson, readLines, loadGroups, loadInventory, loadRegistry, labelIndex, loadSceneActors, asmFiles } from './fl32_lib.mjs';
import { computeEdges, lockGuards, siteGuards } from './fl32_guards.mjs';

const MODE = process.argv[2] ?? 'check';
const DATE = '20261104';
const R = 'plans/flags/results';
const D = readJson('plans/flags/tools/fl32_decisions.json');
const SD = readJson('plans/flags/tools/fl32_scene_decisions.json');
const PD = readJson('plans/flags/tools/fl32_preset_decisions.json');
const inv = loadInventory();
const reg = loadRegistry();
const { scenes } = loadGroups();
const problems = [];
const warn = (m) => problems.push(m);
const H = (s) => parseInt(s, 16);
const hx = (n) => n.toString(16).toUpperCase().padStart(2, '0');
const sceneHex = (id) => hx(id);
const MS = D.milestones;
const MORDER = MS.map((m) => m.id);
const MBY = new Map(MS.map((m) => [m.id, m]));
const PERSIST = (dom) => dom !== 'D1';

// ---------------------------------------------------------------------------------------------------------------
// 1. rows (persistent meanings), stage, milestone
// ---------------------------------------------------------------------------------------------------------------
const rows = [];
for (const [idx, rec] of reg.flags) {
    if (!PERSIST(rec.domain)) continue;
    for (const m of rec.meanings) rows.push({ idx, rec, m, hx: hx(idx) });
}
const stageOf = (r) => {
    if (D.flagStage[r.hx]) return D.flagStage[r.hx];
    if (r.rec.domain === 'D6') return 'transient.dungeon_kill';
    const s = D.areaStage[r.m.area];
    if (!s) { warn(`no stage for ${r.hx} ${r.m.name} (area ${r.m.area})`); return null; }
    return s;
};
const milestoneOf = (r) => {
    if (r.rec.domain === 'D6') return null;
    if (D.flagMilestone[r.hx]) return D.flagMilestone[r.hx];
    if (D.flagNoMilestone.includes(r.hx)) return null;
    return D.areaMilestone[r.m.area] ?? null;
};
for (const r of rows) { r.stage = stageOf(r); r.milestone = milestoneOf(r); }

// names
const globalName = (idx) => {
    const rec = reg.flags.get(idx);
    if (!rec) return null;
    const g = rec.meanings.filter((m) => !m.scope);
    return g.length === 1 && rec.meanings.length === 1 ? g[0].name : null;
};
const nameToIdx = new Map();
for (const [idx, rec] of reg.flags) for (const m of rec.meanings) if (m.name && !nameToIdx.has(m.name)) nameToIdx.set(m.name, idx);
const refIdx = (x) => (typeof x === 'number' ? x : /^$[0-9A-Fa-f]+$/.test(x) ? parseInt(x.slice(1), 16) : nameToIdx.get(x));
const refOut = (idx) => globalName(idx) ?? idx;

// ---------------------------------------------------------------------------------------------------------------
// 2. edges (requires / excludes from set-time guards)
// ---------------------------------------------------------------------------------------------------------------
const edges = computeEdges();
const helperSet = new Set();
for (const h of inv.helper_calls) if (h.action === 'set') for (const i of h.indices ?? []) helperSet.add(i);
const tableRef = new Set(inv.sites.filter((s) => s.role === 'table reference' && s.index !== undefined).map((s) => s.index));
const clearSites = new Map();
for (const s of inv.sites) if (s.kind === 'cop' && s.role === 'clear' && s.index >= 16 && !(s.file ?? '').startsWith('unused/')) {
    if (!clearSites.has(s.index)) clearSites.set(s.index, []);
    clearSites.get(s.index).push(s);
}
const setSites = new Map();
for (const s of inv.sites) if (s.kind === 'cop' && s.role === 'set' && !(s.file ?? '').startsWith('unused/')) {
    if (!setSites.has(s.index)) setSites.set(s.index, []);
    setSites.get(s.index).push(s);
}
const cycled = new Set(clearSites.keys());

const edgeRows = []; // for the report appendix
const patchRows = new Map(); // idx -> {domain, meanings: []}
let stageNew = 0, stageSame = 0, stageConflict = 0, edgeAdded = 0;
for (const r of rows) {
    // a persistent index with a single meaning must carry scope null (the earlier fragments scope two D2 records; the patch re-scopes them)
    const patch = { expectOld: r.m.name, patch: true, scope: r.rec.meanings.length === 1 ? null : r.m.scope ?? null };
    let changed = false;
    if (r.stage) {
        if (r.m.stage && r.m.stage !== r.stage) { stageConflict++; warn(`stage conflict ${r.hx} ${r.m.name}: stored ${r.m.stage}, computed ${r.stage}`); }
        else if (r.m.stage === r.stage) stageSame++;
        else { patch.stage = r.stage; stageNew++; changed = true; }
    }
    const single = r.rec.meanings.length === 1 && !r.m.scope;
    const e = edges.get(r.idx);
    if (single && e && !helperSet.has(r.idx) && !tableRef.has(r.idx) && ['D2', 'D3', 'D4', 'D7'].includes(r.rec.domain)) {
        const keep = (t) => t !== r.idx && reg.flags.has(t) && PERSIST(reg.flags.get(t).domain);
        const merge = (field, derived) => {
            const have = r.m[field] ?? [];
            const haveIdx = new Set(have.map(refIdx));
            const add = derived.filter(keep).filter((t) => !haveIdx.has(t));
            if (add.length === 0) return null;
            return [...have.map((x) => { const i = refIdx(x); return i === undefined ? x : refOut(i); }), ...add.map(refOut)];
        };
        const rq = merge('requires', e.requires);
        const ex = merge('excludes', e.excludes);
        if (rq) { patch.requires = rq; changed = true; edgeAdded += rq.length - (r.m.requires?.length ?? 0); }
        if (ex) { patch.excludes = ex; changed = true; edgeAdded += ex.length - (r.m.excludes?.length ?? 0); }
        if (rq || ex) edgeRows.push({ r, e, setters: e.sites });
    }
    if (changed) {
        if (!patchRows.has(r.idx)) patchRows.set(r.idx, { domain: r.rec.domain, meanings: [] });
        patchRows.get(r.idx).meanings.push(patch);
    }
}
// cycles in the final requires graph
const reqGraph = new Map();
for (const r of rows) {
    const p = patchRows.get(r.idx)?.meanings.find((x) => x.expectOld === r.m.name);
    const list = (p?.requires ?? r.m.requires ?? []).map(refIdx).filter((x) => x !== undefined);
    if (list.length) reqGraph.set(r.idx, list);
}
const cycles = [];
{
    const state = new Map();
    const stack = [];
    const dfs = (n) => {
        state.set(n, 1); stack.push(n);
        for (const t of reqGraph.get(n) ?? []) {
            if (state.get(t) === 1) cycles.push([...stack.slice(stack.indexOf(t)), t]);
            else if (!state.get(t)) dfs(t);
        }
        stack.pop(); state.set(n, 2);
    };
    for (const n of reqGraph.keys()) if (!state.get(n)) dfs(n);
}
for (const c of cycles) warn('requires cycle: ' + c.map((x) => '$' + hx(x)).join(' -> '));

// proposals without a record
const proposals = {};
const recordless = [...reg.proposals.keys()].filter((i) => !reg.flags.has(i)).sort((a, b) => a - b);
const PROPOSAL_STAGE = { F8: 'act2.gold_ship', 138: 'act3.seaside_palace', 185: 'act2.gold_ship', 512: 'act3.great_wall' };
const PROPOSAL_MS = { F8: 'M09', 138: 'M15', 185: 'M09', 512: 'M19' };
for (const i of recordless) {
    const k = hx(i);
    const p = reg.proposals.get(i)[0];
    proposals[String(i)] = [{
        source: 'FL32', scope: null, name: p.name, summary: p.summary, kinds: p.kinds, confidence: 'medium',
        notes: `Progression: stage ${PROPOSAL_STAGE[k]}, milestone ${PROPOSAL_MS[k]} (${MBY.get(PROPOSAL_MS[k]).title}). Stage and milestone are proposals like the name: FL31 writes the record.`,
    }];
    if (!proposals[String(i)][0].kinds) delete proposals[String(i)][0].kinds;
}

// ---------------------------------------------------------------------------------------------------------------
// 3. scenes
// ---------------------------------------------------------------------------------------------------------------
const labels = labelIndex();
const placed = loadSceneActors();
const fileOfLabel = (lab) => { const p = lab.split('.'); return labels.get(p[p.length - 1]) ?? labels.get(p[0]) ?? null; };
const sceneLockSites = (id) => {
    // per placed actor label: only the actor-def block(s) of that label are roots (a file can hold several actor-defs)
    const by = new Map();
    for (const a of placed.get(id)?.actors ?? []) {
        const f = fileOfLabel(a.label);
        if (!f || f.startsWith('actors/')) continue;
        const parts = a.label.split('.');
        if (!by.has(f)) by.set(f, new Set());
        for (const p of parts) by.get(f).add(p);
    }
    const out = [];
    for (const [f, labs] of by) {
        for (const l of lockGuards(f, true, [...labs])) if ((l.lock === 'lock' || l.lock === 'write') && !l.delayed && !l.cond) out.push({ ...l, file: f });
    }
    return out;
};
const existingScene = readJson('db-us/scene-flags.json');
const sceneSpec = {};
const sceneTable = [];
for (const [id, sc] of [...scenes].sort((a, b) => a[0] - b[0])) {
    const h = sceneHex(id);
    const d = SD.scenes[h];
    let e;
    if (d) {
        const flags = d.flags.map(H).sort((a, b) => a - b);
        e = { flags, entry: d.entry, grade: 'INFERRED', note: d.note, source: d.source };
        const names = flags.map(globalName).filter(Boolean);
        if (names.length) e.names = names;
        for (const f of flags) if (!reg.flags.has(f)) warn(`scene ${h}: flag $${hx(f)} has no registry record`);
    } else {
        e = { flags: [], entry: 'free', grade: 'INFERRED', note: SD.freeDefaultNote, source: SD.freeDefaultSource };
    }
    // consistency with the lock search
    const locks = sceneLockSites(id);
    if (!d && locks.length) warn(`scene ${h} (${sc.key}) is not classified but has lock sites: ${locks.map((l) => `${l.file}:${l.line} {${l.offset}}`).join(' ')}`);
    if (d && d.entry === 'cutscene' && locks.length === 0) sceneTable.noLock = (sceneTable.noLock ?? []).concat(h);
    if (existingScene[String(id)]) {
        const old = existingScene[String(id)];
        e.expectOld = { note: old.note };
        e.entry = 'locked-until-flag';
        e.note = `${old.note} Static reading (FL32): ec0A_left_guard releases the lock itself after its dialog (extracted/edward_castle/edward_castle/ec0A_left_guard.asm:34 {311328}); the lock is transient unless the scripted walk stalls in a warp-in start. FR40 decides.`;
        e.source = `${old.source}; static: extracted/edward_castle/edward_castle/ec0A_left_guard.asm:19 {311290}, set :32 {311322}`;
    }
    sceneSpec[String(id)] = e;
    sceneTable.push({ id, h, key: sc.key, group: sc.group, desc: sc.desc, entry: e.entry, flags: e.flags, locks });
}
// flag mention check: each flag of a decision must appear as operand in a source file named in the source text
const flagMentioned = (file, idx) => {
    const L = readLines('extracted/' + file);
    const byte = '#' + hx(idx), word = '#$' + idx.toString(16).toUpperCase().padStart(4, '0');
    return L.some((l) => /COP \[(Set|Clear|BranchOn|WaitOn)Flag(Byte|Word)\]/.test(l) && (l.includes('( ' + byte + ',') || l.includes('( ' + byte + ' )') || l.includes('( ' + word + ',') || l.includes('( ' + word + ' )')));
};
for (const [h, d] of Object.entries(SD.scenes)) {
    if (d.entry !== 'cutscene' || d.flags.length === 0) continue;
    const files = [...d.source.matchAll(/extracted\/([\w./-]+\.asm)|([A-Za-z0-9_]+\.asm)/g)].map((m) => m[1] ?? m[2]);
    const placedFiles = (placed.get(H(h))?.actors ?? []).map((a) => fileOfLabel(a.label)).filter(Boolean);
    const cand = new Set([...files.map((f) => (asmFiles().includes(f) ? f : asmFiles().find((x) => x.endsWith('/' + f)))).filter(Boolean), ...placedFiles]);
    for (const f of d.flags) {
        const idx = H(f);
        if (idx >= 0x300) continue; // table / helper flags (boss reward)
        if (![...cand].some((c) => flagMentioned(c, idx))) warn(`scene ${h}: flag $${f} is not an operand of any COP flag instruction in the cited or placed files`);
    }
}

// ---------------------------------------------------------------------------------------------------------------
// 4. presets
// ---------------------------------------------------------------------------------------------------------------
const itemName = (id) => {
    const j = readJson(`${R}/registry/FL40_registry.json`)._stateGates.items[String(H(id))];
    return j ? j.name : '?';
};
const KEY_ITEMS = {};
const presetSpec = {};
const presetInfo = [];
const setScenesOf = (idx) => {
    const s = setSites.get(idx);
    if (!s || s.length === 0) return null;
    return new Set(s.flatMap((x) => x.scenes ?? []));
};
const abilityFlags = PD.abilityFlags;
const abilityOrderByMs = (upToIdx) => {
    const out = [];
    for (let i = 0; i <= upToIdx; i++) for (const a of MBY.get(MORDER[i]).abilities) out.push(a);
    return out;
};
const slotsAt = (upToIdx) => {
    const slots = new Array(16).fill(null);
    for (let i = 0; i <= upToIdx; i++) {
        const ev = PD.itemEvents[MORDER[i]];
        if (!ev) continue;
        for (const id of ev.remove ?? []) { const at = slots.indexOf(id); if (at < 0) warn(`item ${id} removed at ${MORDER[i]} but not held`); else slots[at] = null; }
        for (const id of ev.give ?? []) { const at = slots.indexOf(null); slots[at] = id; }
    }
    return slots;
};
for (const p of PD.presets) {
    const upIdx = p.upTo ? MORDER.indexOf(p.upTo) : -1;
    if (p.upTo && upIdx < 0) { warn(`preset ${p.name}: unknown milestone ${p.upTo}`); continue; }
    const flags = new Set();
    const excluded = { optional: [], cycled: [], noSetter: [], afterBoss: [] };
    for (const r of rows) {
        if (!['D2', 'D3'].includes(r.rec.domain) || r.m.scope) continue;
        const mi = r.milestone ? MORDER.indexOf(r.milestone) : -1;
        if (mi < 0 || mi > upIdx) continue;
        if (D.flagOptional.includes(r.hx)) { excluded.optional.push(r.idx); continue; }
        if (cycled.has(r.idx)) { excluded.cycled.push(r.idx); continue; }
        if (p.boss && mi === upIdx) {
            const sc = setScenesOf(r.idx);
            if (sc === null) { excluded.noSetter.push(r.idx); continue; }
            const after = new Set(p.afterScenes.map(H));
            if ([...sc].some((s) => after.has(s))) { excluded.afterBoss.push(r.idx); continue; }
        }
        flags.add(r.idx);
    }
    // bosses defeated before the target (D7 500-507 follow their milestone), without own-milestone boss flags
    for (let i = 0; i < D.milestones.length && i <= upIdx; i++) {
        // boss reward flags are D7 and are not in the D2/D3 loop: add those of earlier milestones
    }
    const bossFlags = [['500', 'M08'], ['501', 'M14'], ['502', 'M16'], ['503', 'M19'], ['504', 'M27']];
    for (const [f, ms] of bossFlags) { const mi = MORDER.indexOf(ms); if (mi <= upIdx && !(p.boss && mi === upIdx) && reg.flags.has(H(f))) flags.add(H(f)); }
    const abil = abilityOrderByMs(upIdx);
    for (const a of abil) flags.add(H(abilityFlags[a]));
    const slots = slotsAt(upIdx);
    const items = slots.map((id, slot) => (id ? { id: H(id), slot } : null)).filter(Boolean);
    const flagList = [...flags].sort((a, b) => a - b);
    const flagNames = flagList.map(globalName).filter(Boolean);
    const vId = H(p.verifyScene);
    if (!scenes.has(vId)) warn(`preset ${p.name}: verify scene ${p.verifyScene} not in groups`);
    const vEntry = sceneSpec[String(vId)];
    const vSkip = vEntry.flags.length > 0 && vEntry.flags.every((f) => flags.has(f));
    const vSome = vEntry.flags.some((f) => flags.has(f));
    const entryLine = vEntry.entry === 'free'
        ? `Entry class of scene $${p.verifyScene} is free: no lock expected.`
        : vEntry.flags.length === 0
            ? `Entry class of scene $${p.verifyScene} is ${vEntry.entry} with no skip flag: the arrival script runs every time.`
            : `Entry class of scene $${p.verifyScene} is ${vEntry.entry}; skip flags ${vEntry.flags.map((f) => '$' + hx(f)).join(', ')}: ${vSkip ? 'the preset sets all of them, so the arrival is free' : vSome ? 'the preset sets some of them' : 'the preset sets none of them, so the arrival script runs'}.`;
    const heldText = items.length ? items.map((i) => `${hx(i.id)} ${itemName(hx(i.id))}`).join(', ') : 'none';
    const msEv = p.upTo ? MBY.get(p.upTo) : null;
    const note = `Verify in scene $${p.verifyScene} (${scenes.get(vId)?.key}): ${p.expect} ${entryLine} Key items held: ${heldText}. Consumables, chest items and Red Jewels are not set (gems = 0; the gem count is not flag-gated). Chest ($0200-$02FF), clear-reward ($0300-$03FF) and dungeon-kill ($0400-$04FF) flags are not set so that no pickup is lost. Flags cleared by story code (${excluded.cycled.map((x) => '$' + hx(x)).join(' ') || 'none'}) and optional flags are not set.${p.boss ? ` Flags of milestone ${p.upTo} whose only literal setters lie in scene(s) ${p.afterScenes.map((x) => '$' + x).join(', ')} or that have no literal setter (${excluded.afterBoss.concat(excluded.noSetter).map((x) => '$' + hx(x)).join(' ') || 'none'}) are left clear.` : ''}`;
    const spec = {
        ...(p.after ? { after: p.after } : {}),
        flags: flagList,
        ...(flagNames.length ? { flagNames } : {}),
        ...(items.length ? { items } : {}),
        form: 'Will', gems: 0,
        ...(abil.length ? { abilities: abil } : {}),
        verifyScene: vId, grade: 'INFERRED',
        evidence: p.upTo ? [`FL32 milestone ${p.upTo} (${msEv.title})`, ...msEv.evidence] : ['FL32 milestone M01 (new_game_start)', ...MBY.get('M01').evidence],
        note,
    };
    presetSpec[p.name] = spec;
    presetInfo.push({ p, spec, excluded, vEntry, vSkip, upIdx });
}
// presets are full snapshots: warn when an `after` preset has flags the next lacks (tool warns too)
for (const { p, spec } of presetInfo) {
    if (!p.after) continue;
    const prev = presetSpec[p.after];
    const miss = prev.flags.filter((f) => !spec.flags.includes(f));
    if (miss.length) warn(`preset ${p.name} lacks flags of ${p.after}: ${miss.map((f) => '$' + hx(f)).join(' ')} (boss-own-milestone flags removed by design when the previous preset is a full milestone)`);
}

// ---------------------------------------------------------------------------------------------------------------
// 5. milestone table
// ---------------------------------------------------------------------------------------------------------------
const msFlags = new Map(MS.map((m) => [m.id, { d2: [], d3: [], d7: [], d4: 0, d5: 0 }]));
for (const r of rows) {
    if (!r.milestone) continue;
    const b = msFlags.get(r.milestone);
    if (r.rec.domain === 'D2') b.d2.push(r);
    else if (r.rec.domain === 'D3') b.d3.push(r);
    else if (r.rec.domain === 'D7') b.d7.push(r);
    else if (r.rec.domain === 'D4') b.d4++;
    else if (r.rec.domain === 'D5') b.d5++;
}
const noStage = rows.filter((r) => !r.stage);
const noMs = rows.filter((r) => !r.milestone && !['D6'].includes(r.rec.domain));
const perDomain = {};
for (const r of rows) perDomain[r.rec.domain] = (perDomain[r.rec.domain] ?? 0) + 1;

// ---------------------------------------------------------------------------------------------------------------
// 6. queue
// ---------------------------------------------------------------------------------------------------------------
const STATE = 'orig_S01r_south-cape-ready.mss';
const queue = [];
let qn = 0;
const qid = () => `FL32-${String(++qn).padStart(2, '0')}`;
for (const { p, spec } of presetInfo) {
    queue.push({
        id: qid(), flag: null, scope: { scenes: [spec.verifyScene] }, priority: p.name === 'new_game_start' || p.name === 'after_castle_letter' ? 'P1' : 'P2',
        claim: `Preset ${p.name} reproduces its checkpoint: with the listed flags, items, form and abilities set, scene $${p.verifyScene} behaves as the preset note says.`,
        start: { scene: spec.verifyScene, flags: spec.flags, form: 'Will', state: STATE },
        trial: { control: `warp to scene $${p.verifyScene} with only the flags of preset ${spec.after ?? 'none'}`, forced: `warp to scene $${p.verifyScene} after writing the preset flags to $0A00, the items to $0AB4-$0AC3 and the abilities to $0AA2`, observe: ['joypadMaskStd $065A', 'playerFlags $09AE', 'actor list', 'screenshot', 'the next scene change'] },
        confirms: `the preset is a consistent checkpoint (grade INFERRED to VERIFIED-RUNTIME)`, refutes: 'the arrival lock, a missing actor or a soft lock differs from the note', needs: ['FR00', 'FR50'],
    });
}
const lockedByGroup = new Map();
for (const t of sceneTable) {
    if (t.entry !== 'cutscene' && t.entry !== 'locked-until-flag') continue;
    if (t.flags.length === 0) continue;
    const g = t.group;
    if (!lockedByGroup.has(g)) lockedByGroup.set(g, []);
    lockedByGroup.get(g).push(t);
}
for (const [g, list] of lockedByGroup) {
    const flags = [...new Set(list.flatMap((t) => t.flags))].sort((a, b) => a - b);
    queue.push({
        id: qid(), flag: null, scope: { scenes: list.map((t) => t.id) }, priority: 'P2',
        claim: `Scene entry, group ${g}: with the skip flags clear the arrival script locks the joypad and releases it by itself; with the skip flags set the arrival is free (scenes ${list.map((t) => '$' + t.h).join(' ')}).`,
        start: { scene: list[0].id, flags: [], form: 'Will', state: STATE },
        trial: { control: 'warp to each scene with all skip flags clear and wait for the script to end', forced: 'warp again with the skip flags of the scene entry set', observe: ['joypadMaskStd $065A over 600 frames', 'the flags of the scene entry', 'actor list', 'screenshot'] },
        confirms: 'entry class and flags of the scene entry (INFERRED to VERIFIED-RUNTIME)', refutes: 'the lock never ends, or the skip flags do not remove it', needs: ['FR00', 'FR40'],
    });
}
queue.push({
    id: qid(), flag: 63, scope: { scenes: [10] }, priority: 'P1',
    claim: 'Scene $0A with flag $3F clear: the lock of ec0A_left_guard ends by itself when the guard script finishes (static), while the shipped note says joypadMaskStd stays nonzero.',
    start: { scene: 10, flags: [], form: 'Will', state: STATE },
    trial: { control: 'warp to scene $0A without flag $3F and wait 900 frames', forced: 'repeat with flag $3F set', observe: ['joypadMaskStd $065A', 'flag $3F', 'guard actor position', 'screenshot'] },
    confirms: 'the lock is transient (entry class cutscene)', refutes: 'the lock stays nonzero (entry class locked-until-flag as shipped)', needs: ['FR00', 'FR40'],
});
queue.push({
    id: qid(), flag: 134, scope: { scenes: [103] }, priority: 'P1',
    claim: 'Scene $67 with flag $86 clear and flag $0502 set (a preset after the vampires): the lock set by mu67_erik never ends because the vampires that release it do not spawn.',
    start: { scene: 103, flags: [1282], form: 'Will', state: STATE },
    trial: { control: 'warp to scene $67 with $0502 clear', forced: 'warp to scene $67 with $0502 set and $86 clear, then with $86 set', observe: ['joypadMaskStd $065A', 'actor list', 'screenshot'] },
    confirms: 'a preset after the Mu boss needs flag $86 (soft lock otherwise)', refutes: 'the arrival is free without $86', needs: ['FR00', 'FR50'],
});
for (const i of recordless) {
    const k = hx(i);
    queue.push({
        id: qid(), flag: i, scope: null, priority: 'P2',
        claim: `Spine proposal $${k} ${reg.proposals.get(i)[0].name}: stage ${PROPOSAL_STAGE[k]}, milestone ${PROPOSAL_MS[k]}.`,
        start: { scene: 1, flags: [], form: 'Will', state: STATE },
        trial: { control: 'play or warp through the milestone without the flag', forced: 'census of $0A00-$0AB3 at the end of the milestone', observe: [`flag $${k}`, 'the gate it opens'] },
        confirms: 'the flag is set when the milestone completes', refutes: 'the flag stays clear, or is set earlier', needs: ['FR00', 'FR40'],
    });
}
for (const m of MS) {
    const b = msFlags.get(m.id);
    const fl = [...b.d2, ...b.d7].map((r) => r.idx).sort((a, b2) => a - b2);
    queue.push({
        id: qid(), flag: null, scope: { scenes: m.scenes.map(H) }, priority: 'P2',
        claim: `Milestone ${m.id} ${m.title}: after it the story flags assigned to it are set (${fl.length} D2/D7 flags; the list is in the FL32 report).`,
        start: { scene: m.scenes.length ? H(m.scenes[0]) : 1, flags: [], form: 'Will', state: STATE },
        trial: { control: 'census of $0A00-$0AB3 before the milestone', forced: 'census after finishing the milestone (play or scripted), diff both', observe: ['flags set between the censuses', 'inventory $0AB4-$0AC3', '$0AD4', '$0AA2'] },
        confirms: `the milestone owns the flags of its table row`, refutes: 'a flag of the row is set earlier or later, or a flag outside the row is set', needs: ['FR00', 'FR40'],
    });
}
for (const q of queue) {
    if (q.flag === null && !q.scope) q.scope = null;
}

// ---------------------------------------------------------------------------------------------------------------
// 7. report
// ---------------------------------------------------------------------------------------------------------------
const gradeCount = {};
for (const r of rows) gradeCount[r.m.grade] = (gradeCount[r.m.grade] ?? 0) + 1;
const exitGates = [];
{
    const lines = readLines('extracted/actors/overworld_exit.asm');
    lines.forEach((l, i) => { if (/^; \| [0-9A-F]{2} \|/.test(l) && !/^; \| Scene/.test(l)) exitGates.push({ line: i + 1, text: l.replace(/^; /, '') }); });
}
const metaGates = inv.sites.filter((s) => s.kind === 'scene_gate');
const copFlagSites = inv.sites.filter((s) => s.kind === 'cop' && ['set', 'clear'].includes(s.role));
let siteGuardRows = 0;
for (const f of [...new Set(inv.sites.filter((s) => s.kind === 'cop' && s.file && !s.file.startsWith('unused/')).map((s) => s.file))]) siteGuardRows += siteGuards(f).length;
const lockFilesAll = asmFiles().filter((f) => !f.startsWith('tables/') && fs.readFileSync('extracted/' + f, 'utf8').includes('$joypadMaskStd'));
let lockSiteCount = 0;
for (const f of lockFilesAll) lockSiteCount += lockGuards(f).length;
const dry = (name) => {
    const f = `${R}/FL32_${DATE}_dryrun_${name}.txt`;
    if (!fs.existsSync(f)) return '(not run yet)';
    const T = fs.readFileSync(f, 'utf8').trim().split(/\r?\n/).map((l) => (l.length > 220 ? l.slice(0, 217) + '...' : l));
    if (T.length <= 45) return T.join('\n');
    return [...T.slice(0, 12), `... (${T.length - 30} lines omitted; full output in plans/flags/results/FL32_${DATE}_dryrun_${name}.txt) ...`, ...T.slice(-18)].join('\n');
};
const mdEsc = (s) => String(s).replace(/\|/g, '\\|');
const flagLabel = (r) => `\`$${r.hx}\` ${r.m.name}${cycled.has(r.idx) ? ' †' : ''}${D.flagOptional.includes(r.hx) ? ' *' : ''}`;

const out = [];
const P = (s = '') => out.push(s);
P('# FL32 Progression graph: stages, milestones, prerequisites, scene entry, presets');
P();
P(`Date ${DATE} · agent Claude Sonnet 5.5 · Inputs: inventory \`${inv.source?.sha256 ?? inv.source?.source_sha256 ?? 'plans/flags/inventory.json'}\`, extracted tree tagged (\`; {n}\` line tracking present: ${inv.counts.tagged_files} of ${inv.counts.asm_files} files), registry chain FL10-FL31b + FL40.`);
P(`Scope: all persistent records (${rows.length} meanings in ${new Set(rows.map((r) => r.idx)).size} indices) and all ${scenes.size} scenes of \`db-us/groups.json\`; files read: every actor file placed in a scene (lock search), every file that contains a flag COP (${new Set(inv.sites.filter((s) => s.kind === 'cop').map((s) => s.file)).size} files, guard analysis), the headers of \`overworld_exit.asm\`, and the key actors cited below.`);
P(`Coverage: flag Set/Clear COP sites analysed for guards ${siteGuardRows} of ${copFlagSites.length} (the other ${copFlagSites.length - siteGuardRows} lie in unused/ and are excluded from edges); joypad-lock writes analysed ${lockSiteCount} in ${lockFilesAll.length} files; scene-meta gates read ${metaGates.length} of ${inv.counts.scene_gates}; overworld-exit gate rows read ${exitGates.length}.`);
P();
P('Everything below is **INFERRED**: the static analysis and the story-order reading are consistent, but no runtime evidence exists before FR40/FR50. No claim here is VERIFIED-RUNTIME.');
P();
P('## 1. Method');
P();
P('- **Stage** (`stage` field of the record): `act<N>.<area>` from the area of the record (`db-us/groups.json` group of the scenes that own the flag) with overrides for the engine, Dark Space and jeweler flags (`any.*`) and the dungeon kill table (`transient.dungeon_kill`). Acts: ' + Object.entries(D.acts).filter(([k]) => k.startsWith('act')).map(([k, v]) => `${k} ${v}`).join('; ') + '.');
P('- **Milestone** (M01-M29): the story order comes from the world-map exit gates of `overworld_exit.asm` and the scene-warp / `QueueMapChange` edge graph (`fl32_scenes.mjs edges`, 709 edges, every scene except `$FF` reachable from the boot scene). A flag belongs to the milestone of its area unless `fl32_decisions.json` overrides it with a flag-level reason (the first South Cape evening, the castle letter, hotel and second-visit flags, Gorgon hut flags, bosses, statues, abilities). The registry schema has no milestone field: the milestone of each flag is the table below and `_milestones` in the fragment; the `stage` carries the act and area.');
P('- **Prerequisite edges** (`requires` / `excludes`): a must-analysis of every setter site. For each literal `SetFlag*` site the guard set is the set of flag tests that hold on every path from the actor entry to the site (`BranchOnFlag*` taken or fall-through, `WaitOnFlag*` completed). A flag requires `X` when every setter site is guarded by X set, and excludes `X` when every site is guarded by X clear. These are **set-time guards** (the condition under which the setter runs), not permanent invariants: a flag that is cleared later can lose the relation. Flags written by helpers or tables (' + [...helperSet].length + ' indices) or with several meanings get no derived edge. Sites in `unused/` are ignored.');
P('- **Scene entry**: the joypad-lock writes (`TSB/ORA/STA $joypadMaskStd`) of every actor file a scene places (engine actors under `actors/` excluded), reached from the actor-def entry without a halt (an arrival lock), with the guards that hold; classified against FL20-FL29 scene-entry tables and the cited actor files. `cutscene` = an arrival script locks the joypad and releases it by itself; `flags` = the minimum persistent flags that skip it.');
P('- **Presets**: the flags of all milestones up to the target (D2 story and D3 event flags, ability flags from the ability list, boss flags of earlier bosses), minus optional flags and flags that story code clears; key items from the FL40 give/remove events simulated into inventory slots (first empty slot); form Will; gems 0.');
P();
P('## 2. Milestone table');
P();
P('| Milestone | Flags set (D2 story / D7 boss+ability) | Event flags D3 | Chest D4 / reward D5 | Key items given (removed) | Abilities | Form | Scenes unlocked | Evidence |');
P('|---|---|---|---|---|---|---|---|---|');
for (const m of MS) {
    const b = msFlags.get(m.id);
    const f2 = [...b.d2, ...b.d7].sort((x, y) => x.idx - y.idx).map(flagLabel).join('<br>') || 'none';
    const f3 = b.d3.length ? `${b.d3.length}: ` + b.d3.sort((x, y) => x.idx - y.idx).map((r) => '`$' + r.hx.padStart(4, '0') + '`').join(' ') : 'none';
    const ev = PD.itemEvents[m.id];
    const items = [...(ev?.give ?? []).map((i) => `${i} ${itemName(i)}`), ...(ev?.remove ?? []).map((i) => `(−${i} ${itemName(i)})`)].join(', ') || 'none';
    P(`| **${m.id}** ${m.title}<br>${mdEsc(m.note)} | ${f2} | ${f3} | ${b.d4} / ${b.d5} | ${items} | ${m.abilities.join(', ') || 'none'} | ${m.form} | ${m.scenes.map((s) => '$' + s).join(' ') || 'none'} | ${m.evidence.map((e) => '`' + e + '`').join('<br>')} |`);
}
P();
P('Marks: † the flag is also cleared by story code (not presettable, see section 4); * optional-route flag (not in any preset).');
P();
P(`Flags without a milestone (optional, engine, Dark Space, jeweler, unused, dungeon kill table): ${noMs.length} meanings (D6 ${perDomain.D6 ?? 0} not counted). Optional-route flags: ${D.flagOptional.map((x) => '$' + x).join(' ')}.`);
P();
P('Records changed by this iteration: stage added to ' + stageNew + ' meanings (' + stageSame + ' already had the same stage, ' + stageConflict + ' conflicts), requires/excludes entries added: ' + edgeAdded + ' in ' + edgeRows.length + ' records (appendix A). Records without a stage after the pass: ' + noStage.length + '.');
P();
P('## 3. Scene entry (all ' + scenes.size + ' scenes)');
P();
const byEntry = {};
for (const t of sceneTable) byEntry[t.entry] = (byEntry[t.entry] ?? 0) + 1;
P('Counts: ' + Object.entries(byEntry).map(([k, v]) => `${k} ${v}`).join(', ') + '. The spec `specs/FL32_scene-flags.json` carries one entry per scene (grade INFERRED). No scene is classified `unreachable`: the only scene without an inbound edge is `$FF` (opened by the menu overlay, class unknown) and `$FE` (world map) is entered from every exit scene. No scene was found whose arrival lock never ends in the normal story; `locked-until-flag` is used only for scene `$0A`, where the shipped note says so.');
P();
P('| Scene | Group / key | Class | Skip flags (minimum) | Lock sites found in placed actor files (entry reached without halt) |');
P('|---|---|---|---|---|');
for (const t of sceneTable) {
    const flags = t.flags.map((f) => `\`$${hx(f)}\`${globalName(f) ? ' ' + globalName(f) : ''}`).join('<br>') || '-';
    const lk = t.locks.length ? t.locks.slice(0, 3).map((l) => `${l.file}:${l.line} {${l.offset}}`).join('<br>') + (t.locks.length > 3 ? `<br>+${t.locks.length - 3} more` : '') : 'none';
    P(`| \`$${t.h}\` | ${t.group}/${t.key} | ${t.entry} | ${flags} | ${lk} |`);
}
P();
P('Absence claim for the `free` rows: the search was every actor file placed by `extracted/tables/scene_actors.asm` for the scene (engine actors under `actors/` excluded), for `TSB`/`ORA`/`STA` to `$joypadMaskStd` on paths from the actor-def entry (`fl32_guards.mjs scenelocks`); a lock written only by a handler reached after player input is not an arrival lock and is not listed; thinkers, `scene_meta` scene commands and warp rectangles were not searched for locks (they run no actor code that writes the mask in the files read).');
P();
P('### 3.1 Gates that block scene entry or exits (read, not scene-entry classes)');
P();
P('`overworld_exit.asm` header rows (world-map exit gates by flag; offsets: not available, header comment):');
P();
for (const g of exitGates) P(`- \`extracted/actors/overworld_exit.asm:${g.line}\` ${mdEsc(g.text)}`);
P();
P('Scene-meta gates (`scene_meta.asm`, kind `scene_gate`; this table file carries no `; {n}` line-tracking tags, the offsets are the FL01 inventory offsets):');
P();
for (const s of metaGates) P(`- \`extracted/${s.file}:${s.line} {${s.offset}}\` flag \`$${hx(s.index)}\` ${globalName(s.index) ?? ''} ${s.sense} -> scene(s) ${(s.scenes ?? []).map((x) => '$' + hx(x)).join(' ')}`);
P();
P('## 4. Presets');
P();
P('| Preset | After | Up to | Flags | Items (id:slot) | Abilities | Verify scene | Entry class there |');
P('|---|---|---|---|---|---|---|---|');
for (const { p, spec, vEntry } of presetInfo) P(`| ${p.name} | ${spec.after ?? '-'} | ${p.upTo ?? '-'} | ${spec.flags.length} | ${(spec.items ?? []).map((i) => `${hx(i.id)}:${i.slot}`).join(' ') || '-'} | ${(spec.abilities ?? []).join(', ') || '-'} | \`$${p.verifyScene}\` | ${vEntry.entry} |`);
P();
P('Every preset names a verify scene and an expectation (the `note` field of the spec; the preset schema has no separate expectation field). Excluded from every preset by rule: chest, clear-reward and dungeon-kill flags (so no pickup is lost), optional flags, and the ' + cycled.size + ' persistent flags that story code clears (' + [...cycled].sort((a, b) => a - b).map((x) => '`$' + hx(x) + '`').join(' ') + '; their state at a checkpoint is not known statically). Flags a boss preset leaves clear: flags of the dungeon milestone whose literal setters lie in the boss scene or that have no literal setter.');
P();
P('## 5. Contradictions with shipped text');
P();
P('| Shipped text | What the code does | Spec row |');
P('|---|---|---|');
P('| `db-us/scene-flags.json` scene 10 (`$0A`): "Without it the guard actor locks the joypad (joypadMaskStd $065A stays nonzero)." | `ec0A_left_guard.asm:19 {311290}` locks at spawn while flags `$21` and `$3F` are clear, runs the walk and dialog, sets `$3F` at `:32 {311322}` and releases the lock at `:34 {311328}`. Static reading: the lock ends by itself. The shipped text is an observation in Mesen2 (a warp-in start); a stalled script cannot be excluded statically. Not proven wrong: **disputed**, queue item FL32-' + String(queue.findIndex((q) => q.flag === 63) + 1).padStart(2, '0') + '. | `specs/FL32_scene-flags.json` key 10 (class kept `locked-until-flag`, note extended, `expectOld` = shipped note) |');
P();
P('No `specs/FL32_notes.json` is written: no shipped block, part or inline note was shown wrong by this iteration.');
P();
P('## 6. Index reuses');
P();
const reuse = [...reg.flags].filter(([i, f]) => f.domain !== 'D1' && f.meanings.length > 1);
const NL2 = String.fromCharCode(10);
P(reuse.length
    ? reuse.map(([i, f]) => '- `$' + hx(i) + '`: ' + f.meanings.map((m) => m.name).join(' / ')).join(NL2) + NL2 + NL2 + 'FL32 found no new index reuse.'
    : 'No persistent index has more than one meaning in the registry chain. FL32 found no new index reuse.');
P();
P('## 7. Spine proposals');
P();
P('| Index | Proposed name | Stage / milestone (proposal) | Confidence |');
P('|---|---|---|---|');
for (const i of recordless) { const k = hx(i); P(`| \`$${k}\` | ${proposals[String(i)][0].name} | ${PROPOSAL_STAGE[k]} / ${PROPOSAL_MS[k]} | medium |`); }
P();
P('## 8. Draft specs and dry-run output');
P();
P('Files: `registry/FL32_registry.json` (patch rows with `expectOld` for stage / requires / excludes, 4 proposals, `_milestones`), `specs/FL32_scene-flags.json` (' + Object.keys(sceneSpec).length + ' scenes), `specs/FL32_presets.json` (' + Object.keys(presetSpec).length + ' presets), `queue/FL32_queue.json` (' + queue.length + ' items).');
P();
const SC = '--db-dir=plans/flags/results/_scratch_db';
const sections = [
    ['`npm run flags -- plans/flags/results/registry/FL32_registry.json --dry-run` against the shipped `db-us/flags.json` (the file is the empty skeleton, so every patch row is rejected with "no record to edit"; the rows apply only after FL10..FL31b, FL40 are applied)', 'realdb_registry'],
    ['`npm run flags -- scene-flags plans/flags/results/specs/FL32_scene-flags.json --dry-run` against the shipped db (rejected: the flag indices are not in the registry yet)', 'realdb_scene'],
    ['`npm run flags -- presets plans/flags/results/specs/FL32_presets.json --dry-run` against the shipped db (rejected for the same reason)', 'realdb_presets'],
    ['`npm run flags -- --check` on the shipped db', 'check'],
    ['`npm run flags -- plans/flags/results/registry/FL32_registry.json --dry-run ' + SC + '` (scratch registry = chain FL10..FL31b, FL40 merged in memory and sanitised by `fl32_scratchdb.mjs`)', 'registry'],
    ['`npm run flags -- scene-flags plans/flags/results/specs/FL32_scene-flags.json --dry-run ' + SC + '`', 'scene'],
    ['`npm run flags -- presets plans/flags/results/specs/FL32_presets.json --dry-run ' + SC + '`', 'presets'],
    ['`npm run flags -- --check ' + SC + '` (scratch registry before FL32; the canonical-form error exists only because the scratch file is built by the helper, not written by the tool)', 'chain'],
    ['`node plans/flags/tools/fl32_citecheck.mjs` on the decision files, specs, registry, queue and this report', 'cite'],
];
for (const [title, name] of sections) {
    P('**' + title + '**');
    P();
    P('```text');
    P(dry(name));
    P('```');
    P();
}
P('## 9. Counts');
P();
P(`Persistent meanings by grade (the grade of the record is untouched; FL32 adds INFERRED stage, milestone and prerequisite assertions on top): ${Object.entries(gradeCount).map(([k, v]) => `${k} ${v}`).join(', ')}. By domain: ${Object.entries(perDomain).map(([k, v]) => `${k} ${v}`).join(', ')}.`);
P(`FL32 assertions (all INFERRED): ${rows.filter((r) => r.stage).length} stage tags, ${rows.filter((r) => r.milestone).length} milestone assignments, ${edgeRows.length} records with new prerequisite edges (${edgeAdded} entries), ${sceneTable.length} scene-entry classes, ${presetInfo.length} presets. VERIFIED-STATIC added: 0. UNKNOWN: ${sceneTable.filter((t) => t.entry === 'unknown').length} scene classes. CONTRADICTED: 0 (one disputed note).`);
P();
P('## 10. Runtime queue');
P();
P(`${queue.length} items in \`queue/FL32_queue.json\`: ${presetInfo.length} preset replays (FR50), ${lockedByGroup.size} scene-entry batches (FR40), 2 hazard items (scene $0A note, scene $67 preset), ${recordless.length} spine proposals, ${MS.length} milestone censuses (FR40).`);
P();
P('## 11. Pass-criteria check (plan section 5, FL32)');
P();
P(`- Every persistent flag has a stage: ${noStage.length === 0 ? 'yes' : 'NO, ' + noStage.length + ' without'} (${rows.length} meanings; ${perDomain.D6 ?? 0} D6 dungeon kill flags carry \`transient.dungeon_kill\`). Index records absent from the registry (4 spine proposals) have a proposal with stage and milestone in its notes.`);
P(`- Every scene has an entry class: ${sceneTable.length === scenes.size ? 'yes' : 'NO'} (${sceneTable.length} of ${scenes.size}).`);
P(`- Every preset names a verification scene and an expectation: ${presetInfo.every((x) => x.spec.verifyScene && x.spec.note) ? 'yes' : 'NO'}.`);
P('- No runtime claim: every FL32 assertion is INFERRED until FR40/FR50.');
P();
P('## 12. Diagnostics of the generator');
P();
P(problems.length ? problems.map((x) => '- ' + x).join('\n') : 'none');
P();
P('## Appendix A. Prerequisite edges added');
P();
P('| Flag | Requires (set-time) | Excludes (set-time) | Setter sites |');
P('|---|---|---|---|');
for (const { r, e, setters } of edgeRows.sort((a, b) => a.r.idx - b.r.idx)) {
    const p = patchRows.get(r.idx).meanings.find((x) => x.expectOld === r.m.name);
    const show = (arr) => (arr ?? []).map((x) => (typeof x === 'number' ? '$' + hx(x) : x)).join(', ') || '-';
    P(`| \`$${r.hx}\` ${r.m.name} | ${show(p.requires ?? r.m.requires)} | ${show(p.excludes ?? r.m.excludes)} | ${setters.slice(0, 3).map((s) => `${s.file}:${s.line} {${s.offset}}`).join('<br>')}${setters.length > 3 ? `<br>+${setters.length - 3} more` : ''} |`);
}
P();
P('## New questions (text only)');
P();
P('- The fragments FL10-FL40 do not pass `npm run flags -- --check` as they are: merged in order into a scratch registry (`fl32_scratchdb.mjs`) they give 86 errors (44 unknown kinds such as `cue`, `item-gate`, `pickup-claimed`; 32 `requires` / `excludes` and 7 `pairsWith` entries written as `$XXXX` or `$XXXX set` text instead of an index or a name; 2 scoped single D2 meanings ($F2, $F3); area `unused`; 5 overlapping D1 scopes of index 0). The scratch copy was sanitised for these (counts in section 8) so that the FL32 rows could be dry-run; FL32 rows that touch the two scoped D2 records re-scope them to null, and every `requires` / `excludes` entry FL32 re-emits is normalised to an index or a name. The apply pass must fix the rest of the chain.');
P('- The registry schema has no `milestone` field; milestones live in `_milestones` of the fragment and in this report. Add a `milestone` meaning key (and a `milestones` table to `flags.json`) if the docs and `flags -- export` should carry them.');
P('- Flags `$F8`, `$0138`, `$0185` and `$0512` have no record (FL31 writes them); until then their stage and milestone are proposal notes only.');
P('- Scenes `$FE` and `$FF` fit no entry class cleanly (`unknown`): `$FF` has no inbound scene edge (menu overlay), `$FE` is a controller. Should the schema get a `system` class?');
P('- Hazard: a preset after the Mu boss needs flag `$86`, otherwise scene `$67` locks the joypad for good (queue item FL32-' + String(queue.findIndex((q) => q.flag === 134) + 1).padStart(2, '0') + '). The presets leave `$86` clear in `before_vampires` only.');
P(`- ${cycled.size} persistent flags are cleared by story code (listed in section 4). Their state at each checkpoint needs a runtime census (FR40); the presets leave them clear.`);
P('- 7 direct writes to `eventFlags` outside the helpers (`inventory.json` `direct_accesses`, region `flags:event`) are not part of the edge derivation.');
P();
const report = out.join('\n') + '\n';

// ---------------------------------------------------------------------------------------------------------------
// 8. outputs
// ---------------------------------------------------------------------------------------------------------------
const fragment = {
    _note: 'FL32 fragment: stage (act.area) and derived requires/excludes as patch rows (expectOld = stored name). Milestones are in _milestones because the meaning schema has no milestone key. Proposals F8, 0138, 0185 and 0512 carry their stage and milestone in notes. requires/excludes derived by plans/flags/tools/fl32_guards.mjs are set-time guards of every literal setter site.',
    flags: Object.fromEntries([...patchRows].sort((a, b) => a[0] - b[0]).map(([k, v]) => [String(k), v])),
    proposals,
    _milestones: Object.fromEntries(MS.map((m) => {
        const b = msFlags.get(m.id);
        return [m.id, {
            title: m.title, note: m.note, grade: 'INFERRED',
            flags: [...b.d2, ...b.d3, ...b.d7].map((r) => r.idx).sort((x, y) => x - y),
            flagNames: [...b.d2, ...b.d7].sort((x, y) => x.idx - y.idx).map((r) => r.m.name),
            items: PD.itemEvents[m.id] ?? {}, abilities: m.abilities, form: m.form, scenes: m.scenes.map(H), evidence: m.evidence,
        }];
    })),
};
const jsonText = (o) => JSON.stringify(o, null, 2) + '\n';

console.log(`rows ${rows.length}, patch records ${patchRows.size}, stage new ${stageNew} same ${stageSame} conflict ${stageConflict}, edges ${edgeAdded} in ${edgeRows.length} records, cycled ${cycled.size}`);
console.log(`scenes ${sceneTable.length} (${Object.entries(byEntry).map(([k, v]) => k + ' ' + v).join(', ')}), presets ${presetInfo.length}, queue ${queue.length}, proposals ${Object.keys(proposals).length}`);
if (sceneTable.noLock) console.log('cutscene decisions without a found lock site: ' + sceneTable.noLock.join(' '));
console.log(`problems: ${problems.length}`);
for (const p of problems) console.log('  - ' + p);
if (MODE === 'write') {
    fs.mkdirSync(`${R}/specs`, { recursive: true });
    fs.writeFileSync(`${R}/registry/FL32_registry.json`, jsonText(fragment));
    fs.writeFileSync(`${R}/specs/FL32_scene-flags.json`, jsonText(sceneSpec));
    fs.writeFileSync(`${R}/specs/FL32_presets.json`, jsonText(presetSpec));
    fs.writeFileSync(`${R}/queue/FL32_queue.json`, jsonText(queue));
    fs.writeFileSync(`${R}/FL32_${DATE}.md`, report);
    console.log('written: registry, scene-flags, presets, queue, report');
}
