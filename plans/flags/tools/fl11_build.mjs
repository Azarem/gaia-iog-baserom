#!/usr/bin/env node
// fl11_build.mjs - READ-ONLY builder for the FL11 deliverables (event triggers and death actions, flags $0100-$01FF).
//
// This script WRITES NOTHING. It prints to stdout; the caller redirects the output into plans/flags/results/.
// It reads only plans/flags/tools/fl11_meanings.json (the hand analysis), plans/flags/inventory.json, db-us/groups.json,
// rebuilt/Illusion of Gaia.smc (to check the event_block_table offsets) and the output of fl11_query.mjs
// (usage, blocks, rows, spine). It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl11_build.mjs registry   > plans/flags/results/registry/FL11_registry.json
//   node plans/flags/tools/fl11_build.mjs queue      > plans/flags/results/queue/FL11_queue.json
//   node plans/flags/tools/fl11_build.mjs tables     # markdown tables for the report (coverage, records, proposals, death rows)
//   node plans/flags/tools/fl11_build.mjs counts     # grade counts and coverage numbers
import fs from 'node:fs';
import { execFileSync } from 'node:child_process';

const mode = process.argv[2];
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
const q = cmd => execFileSync('node', ['plans/flags/tools/fl11_query.mjs', ...cmd.split(' ')], { encoding: 'utf8', maxBuffer: 1 << 26 }).trim().split('\n');
const meanings = JSON.parse(fs.readFileSync('plans/flags/tools/fl11_meanings.json', 'utf8'));
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const sceneInfo = new Map();
for (const [g, v] of Object.entries(groups)) for (const [name, s] of Object.entries(v.scenes)) sceneInfo.set(s.id, { group: g, prefix: v.prefix, name });

// ---- blocks ----
const blocks = new Map();
for (const l of q('blocks')) {
  const f = l.split('\t');
  const n = parseInt(f[0], 16), [sx, sy] = f[3].slice(4).split(','), [w, h] = f[4].split('x'), [dx, dy] = f[5].slice(4).split(',');
  blocks.set(n, { n, line: parseInt(f[1].slice(4), 10), scene: parseInt(f[2].slice(6), 16), src: [sx, sy], w: parseInt(w, 16) || parseInt(w, 10), h, dst: [dx, dy], layer: parseInt(f[6].slice(6), 10), offset: 119758 + 8 * n, wd: f[4] });
}
for (const b of blocks.values()) if (ROM[b.offset] !== b.scene) throw new Error(`event_block_table offset check failed for n=${hex(b.n)}`);

// ---- usage ----
const usage = new Map();
{
  const lines = q('usage'); let cur;
  for (const l of lines) {
    let m;
    if ((m = l.match(/^n=([0-9A-F]{2}) flag=([0-9A-F]{4}) scene=([0-9A-F]{2})/))) { cur = { n: parseInt(m[1], 16), cop: [], bg: [], death: [] }; usage.set(cur.n, cur); }
    else if ((m = l.match(/^\s+flagCOP: (.*)$/)) && m[1] !== '-') cur.cop = m[1].split(' | ').map(s => { const x = s.match(/^(\w+) (\S+):(\d+) \{(\d+)\}/); return { op: x[1], file: x[2], line: +x[3], off: +x[4] }; });
    else if ((m = l.match(/^\s+StageBgChange: (.*)$/)) && m[1] !== '-') cur.bg = m[1].split(' | ').map(s => { const x = s.match(/^(\S+):(\d+) \{(\d+)\}/); return { file: x[1], line: +x[2], off: +x[3] }; });
    else if ((m = l.match(/^\s+deathRows: (.*)$/)) && m[1] !== '-') cur.death = m[1].split(' | ').map(s => { const x = s.match(/^([0-9A-F]{2})#([0-9A-F]+) (\S+) \{(\d+)\} asm:(\d+)/); return { scene: parseInt(x[1], 16), idx: x[2], label: x[3], off: +x[4], asm: +x[5] }; });
  }
}
// enemy numbers from rows
const enemyNum = new Map();
for (const l of q('rows')) { const m = l.match(/^(\d+)\tscene ([0-9A-F]{2})\t#([0-9A-F]+)\t.*enemyNum ([0-9A-F]{2}) block ([0-9A-F]{2})/); if (m) enemyNum.set(`${m[2]}#${m[3]}`, m[4]); }
// spine
const spineSet = new Set(Object.keys(meanings.spine).map(k => parseInt(k, 16)));

const kindOp = op => (/^Set/.test(op) ? 'S' : /^Clear/.test(op) ? 'C' : /^Test|^Branch/.test(op) ? 'T' : /^Wait/.test(op) ? 'W' : '?');
const siteCounts = u => { const c = { S: 0, C: 0, T: 0, W: 0 }; for (const s of u.cop) c[kindOp(s.op)]++; return c; };
const evStr = (file, line, off) => `extracted/${file.replace(/\\/g, '/')}:${line} {${off}}`;
const rectText = b => `scene $${hex(b.scene)}: ${b.wd} metatiles from (${b.src[0]},${b.src[1]}) to (${b.dst[0]},${b.dst[1]}), layer ${b.layer}`;
const READER = 'extracted/system/engine/event_blocks.asm:81 {172529}';
const HANDLERS = ['extracted/functions/StandardEnemyDefeatHandler.asm:119 {56361}', 'extracted/functions/StandardEnemyDefeatHandler.asm:122 {56371}', 'extracted/functions/EnemyDefeatDispatch.asm:88 {697534}', 'extracted/functions/EnemyDefeatDispatch.asm:91 {697544}'];
const OWN = { 'awB1_wall_walker': ['extracted/angkor_wat/awB1_wall_walker.asm:535 {770400}', 'extracted/angkor_wat/awB1_wall_walker.asm:538 {770410}'], 'pyCC_mystic_ball': ['extracted/pyramid/pyCC_mystic_ball.asm:248 {771956}', 'extracted/pyramid/pyCC_mystic_ball.asm:251 {771966}'] };

function short(label) {
  const part = label.replace(/^@/, '').split('.').pop();
  return part.replace(/^[a-z]{1,3}[0-9A-F]{1,2}_/i, '').toLowerCase();
}
function areaOf(n) { return sceneInfo.get(blocks.get(n).scene)?.group; }

function evidenceFor(n, u) {
  const e = [];
  for (const s of u.cop) e.push(evStr(s.file, s.line, s.off));
  for (const s of u.bg) e.push(evStr(s.file, s.line, s.off));
  for (const d of u.death) e.push(`extracted/tables/scene_actors.asm:${d.asm} {${d.off}}`);
  if (u.death.length) { const own = u.death.map(d => Object.keys(OWN).find(k => d.label.includes(k))).filter(Boolean); e.push(...(own.length ? OWN[own[0]] : HANDLERS)); }
  e.push(READER, `extracted/system/event_block_table.asm:${blocks.get(n).line} {${blocks.get(n).offset}}`);
  return [...new Set(e)];
}

function autoDeath(n, u) {
  const b = blocks.get(n), d = u.death[0], si = sceneInfo.get(d.scene);
  const en = enemyNum.get(`${hex(d.scene)}#${d.idx}`);
  const actor = short(d.label);
  const name = `${si.prefix}_${si.name}_${actor}_${d.idx.toLowerCase()}_defeated`.replace(/__+/g, '_');
  const twoStage = /skull_chaser/.test(d.label);
  return {
    name, area: si.group, scope: null,
    summary: `The enemy at scene $${hex(d.scene)} row #${d.idx} (${d.label.split('.').pop()}, enemy number $${en}) was defeated; its death-action index $${hex(n)} set this flag and applied event block $${hex(n)}.`,
    kinds: ['gate-open'], grade: 'VERIFIED-STATIC',
    effects: {
      set: `The defeat handler (${OWN[Object.keys(OWN).find(k => d.label.includes(k))] ? 'the actor\'s own copy of the kill code' : 'StandardEnemyDefeatHandler or EnemyDefeatDispatch'}) sets the flag when deathActionIdx is $${hex(n)} and the flag is clear, and spawns SpawnFieldRevealEffect (flags $0342), which flies to the destination rectangle and runs StageBgChangeFromDeathIdx and ApplyBgChange; every later load of scene $${hex(b.scene)} and every inventory close re-applies block $${hex(n)} through ApplyAllEventBlocks.`,
      clear: 'No clear site: ClearFlag_0100 has no caller and no COP clears this index. The block stays applied in the save.'
    },
    evidence: evidenceFor(n, u),
    notes: `Event block $${hex(n)}: ${rectText(b)}. Enemy number $${en} ${en === '00' ? 'is zero, so no dungeon kill flag exists for this row' : 'also has a D6 kill flag, and CheckEnemyDefeatedFlag applies the block at spawn while that flag is set (D6 is cleared at world-map entry; this flag is not)'}.${twoStage ? ' The skull chaser changes into a second form on its first death (its death callback is cleared), and the flag is set on the second death.' : ''} The tiles were not decoded, so what the rectangle looks like is not stated.`
  };
}

// ---- assemble ----
const flags = {}, proposals = {}, blockOnly = {}, noUse = {}, queueSpec = [];
const records = []; // for tables
for (const b of [...blocks.values()].sort((a, c) => a.n - c.n)) {
  const n = b.n, u = usage.get(n), idx = 0x100 + n, key = String(idx), nh = hex(n);
  const base = { domain: 'D3' }; // hex, address and mask are derived by the tool
  if (spineSet.has(n)) {
    const s = meanings.spine[nh];
    proposals[key] = [{ source: 'FL11', scope: null, name: s.name, summary: s.summary, kinds: s.kinds, roles: [...s.roles, `event block $${nh}: ${rectText(b)} (extracted/system/event_block_table.asm:${b.line}, offset ${b.offset})`], confidence: s.confidence, notes: s.notes }];
    records.push({ idx, n, cls: 'spine', name: s.name, kinds: s.kinds, grade: '-', summary: s.summary, u });
    queueSpec.push({ idx, n, claim: `Proposal ${s.name}: ${s.summary}`, spine: true, b });
    continue;
  }
  const hand = meanings.records[nh];
  if (hand || u.cop.length || u.death.length) {
    let m;
    if (hand) {
      m = { name: hand.name, area: areaOf(n), scope: null, summary: hand.summary, kinds: hand.kinds, grade: hand.grade, effects: { set: hand.set, clear: hand.clear }, ...(hand.pairs ? { pairsWith: hand.pairs } : {}), evidence: evidenceFor(n, u), notes: `${hand.notes ? hand.notes + ' ' : ''}Event block $${nh}: ${rectText(b)}.` };
      if (hand.queue) queueSpec.push({ idx, n, claim: hand.summary, hand, b });
    } else m = autoDeath(n, u);
    if (m.grade === 'INFERRED' && !hand?.queue) throw new Error('INFERRED without queue ' + nh);
    flags[key] = { ...base, meanings: [m] };
    records.push({ idx, n, cls: 'owned', name: m.name, kinds: m.kinds, grade: m.grade, summary: m.summary, u });
  } else if (u.bg.length) {
    blockOnly[key] = { block: nh, scene: `$${hex(b.scene)}`, rect: rectText(b), stageBgChange: u.bg.map(s => evStr(s.file, s.line, s.off)), note: 'No flag COP site, no helper call and no death row uses this index. The block is reachable only through StageBgChange (COP #32) at the listed sites; setting the flag by hand would apply it at the next load of the scene.' };
    records.push({ idx, n, cls: 'block-only', u });
  } else {
    noUse[key] = { block: nh, scene: `$${hex(b.scene)}`, rect: rectText(b), note: 'No use found: inventory sites 0, narrow helper-call indices 0, trace candidates none, no StageBgChange operand, no scene_actors row with this event-block byte, literal $01xx hits on Flag/Event lines are positions or tick counts.' };
    records.push({ idx, n, cls: 'no-use', u });
  }
}
// queue ids
queueSpec.forEach((x, i) => { x.id = `FL11-${String(i + 1).padStart(2, '0')}`; });
for (const x of queueSpec) { const f = flags[String(x.idx)]; if (f) f.meanings[0].queue = [x.id]; }

const domainD3 = {
  name: 'event triggers / death actions', ranges: [[256, 511]], indexed: true, persistence: 'save',
  lifecycle: 'Bytes $0A20-$0A3F of the save block. ApplyAllEventBlocks (scene load, after InitCameraBounds and before SpawnSceneActors, and at inventory close) walks all 256 bits; a set flag $0100+n applies event block n when the block\'s scene byte equals sceneCurrent. Scene loads never clear these bits. The only clear sites are the sg52 blockers ($0125-$012A), the Ishtar room controller ($0149-$0150 at each room start), the Adrift script ($0120), the stone coffin retry ($013B), Kara\'s return ($0119) and the prologue ($017C-$017F). Blocks n >= 158 have no table entry (LookupEventBlock does not bound the index); no flag in $019E-$01FF has a setter.',
  access: 'COP word forms ($CD/$CF/$D1/$D3 and the Branch/Wait variants), SetFlag_0100/TestFlag_0100 (death-action indices, pyCC Dark Space portal), ApplyAllEventBlocks (LDA $0A20,Y), enemy-spawn rows of tables/scene_actors.asm (last operand = event-block index, stored at $7F0024).'
};

if (mode === 'registry') {
  const out = {
    _note: 'FL11 fragment. flags: one full record per owned index of $0100-$019D with a flag site or a death-action row (D3). proposals: spine indices (touched by more than one scene group). _block_only and _no_use are informational (keys starting with _ are ignored by the tool): indices whose block is reachable only through StageBgChange, and indices with no use.',
    domains: { D3: domainD3 },
    flags, proposals,
    _block_only: blockOnly, _no_use: noUse,
    _no_use_range: { '$019E-$01FF': { count: 98, note: 'Not event blocks (the table has 158 entries, $00-$9D). Searches: plans/flags/inventory.json sites 0, narrow helper-call indices 0, trace candidates none; fl11_query.mjs unused 19E 1FF lists every index with a literal $01xx hit on a Flag/Event line, and each of those hits is a SpawnAfterAbsFlags position operand, a tick count or a sprite-part tile number (each hit was read in its file). The only access to bytes $0A20-$0A3F outside the COP and helper paths is event_blocks.asm:81. Hazard: a set bit here would make LookupEventBlock read past the table (entry address event_block_table + 8n, no bound check).' } }
  };
  console.log(JSON.stringify(out, null, 2));
} else if (mode === 'queue') {
  const items = queueSpec.map(x => {
    const b = x.b, base = { id: x.id, flag: x.idx, scope: null };
    const start = { scene: b.scene, flags: [], form: 'Will', state: null };
    const rect = `mapLayerTilemap ($7EA000) and collisionLayer ($7FC000) rectangle ${b.wd} metatiles at (${b.dst[0]},${b.dst[1]})`;
    if (x.hand?.queue) {
      const custom = {
        '20': { claim: 'Reloading scene $2F with flag $0120 set applies the layer-1 block $20 (32x16 effect-layer copy); the next reload after $0120 is cleared shows the plain effect layer.', control: 'enter scene $2F with $0120 clear and screenshot the effect layer', forced: 'set $0120 ($0A24 bit 0) and reload the scene, then clear it and reload again', observe: ['effectLayerTilemap ($7EC000) rows 0-15', 'screenshot of both reloads'], confirms: 'the first reload differs from the control in the effect layer and the second reload equals the control', refutes: 'both reloads equal the control, or the swap leaves the effect layer untouched' },
        '59': { claim: 'Applying block $59 alone (flag $0159 set, $0158 clear) on a reload of scene $A2 gives the same picture as the stepwise StageBgChange #58 + #59 sequence.', control: 'solve the crossroads gate in play, screenshot the opened gate', forced: 'start from a state with the gate closed, set only $0159 ($0A2B bit 1) and load scene $A2', observe: [rect, 'screenshot'], confirms: 'the loaded picture equals the played one', refutes: 'the loaded picture differs (an earlier step block is needed)' },
        '5F': { claim: 'Applying block $5F alone on a reload of scene $A5 gives the same picture as the stepwise #5A-#5F sequence of gate A.', control: 'solve gate A in play, screenshot', forced: 'closed state, set only $015F ($0A2B bit 7) and load scene $A5', observe: [rect, 'screenshot'], confirms: 'identical pictures', refutes: 'different pictures' },
        '67': { claim: 'Applying block $67 alone on a reload of scene $A5 gives the same picture as the stepwise #60-#67 sequence of gate B.', control: 'solve gate B in play, screenshot', forced: 'closed state, set only $0167 ($0A2C bit 7) and load scene $A5', observe: [rect, 'screenshot'], confirms: 'identical pictures', refutes: 'different pictures' }
      }[hex(x.n)];
      return { ...base, claim: custom.claim, priority: 'P3', start, trial: { control: custom.control, forced: custom.forced, observe: custom.observe }, confirms: custom.confirms, refutes: custom.refutes, needs: ['FR00'] };
    }
    return { ...base, claim: x.claim, priority: 'P2', start, trial: { control: `load scene $${hex(b.scene)} with flag $${hex(x.idx, 4)} clear and record ${rect}`, forced: `set flag $${hex(x.idx, 4)} (byte $${hex(0x0A20 + (x.n >> 3), 4)} bit ${x.n & 7}) and load the same scene again`, observe: [rect, 'screenshot of the destination area'] }, confirms: `the rectangle shows the copy of the source rectangle (${b.src[0]},${b.src[1]}) only in the forced load; with the real setter played in the story the same picture appears`, refutes: 'the rectangle is unchanged in the forced load, or a second setter exists', needs: ['FR00'] };
  });
  console.log(JSON.stringify(items, null, 2));
} else if (mode === 'counts') {
  const g = {};
  for (const f of Object.values(flags)) g[f.meanings[0].grade] = (g[f.meanings[0].grade] || 0) + 1;
  const cls = {}; for (const r of records) cls[r.cls] = (cls[r.cls] || 0) + 1;
  const siteTotal = [...usage.values()].reduce((a, u) => a + u.cop.length, 0);
  const bgTotal = [...usage.values()].reduce((a, u) => a + u.bg.length, 0);
  const dr = [...usage.values()].reduce((a, u) => a + u.death.length, 0);
  console.log(JSON.stringify({ grades: g, classes: cls, proposals: Object.keys(proposals).length, flagRecords: Object.keys(flags).length, queue: queueSpec.length, flagCopSites: siteTotal, bgSites: bgTotal, deathRows: dr }, null, 1));
} else if (mode === 'tables') {
  const esc = s => String(s).replace(/\|/g, '\\|');
  console.log('### Coverage (event blocks $00-$9D, flags $0100-$019D)\n\n| Flag | Block scene | Sites S/C/T/W | StageBgChange | Death rows | Class | Decision |\n|---|---|---|---:|---:|---|---|');
  for (const r of records) {
    const b = blocks.get(r.n), c = siteCounts(r.u), si = sceneInfo.get(b.scene);
    const dec = r.cls === 'owned' ? `record ${r.grade}` : r.cls === 'spine' ? 'proposal' : r.cls === 'block-only' ? 'block reachable only by StageBgChange' : 'no use found';
    console.log(`| $${hex(r.idx, 4)} | $${hex(b.scene)} ${si?.name ?? '?'} | ${c.S}/${c.C}/${c.T}/${c.W} | ${r.u.bg.length} | ${r.u.death.length} | ${r.cls} | ${dec} |`);
  }
  console.log('\n### Records\n\n| Flag | Name | Kinds | Grade | Summary |\n|---|---|---|---|---|');
  for (const r of records.filter(r => r.cls === 'owned')) console.log(`| $${hex(r.idx, 4)} | \`${r.name}\` | ${r.kinds.join(', ')} | ${r.grade} | ${esc(r.summary).slice(0, 170)} |`);
  console.log('\n### Spine proposals\n\n| Flag | Proposed name | Groups | Confidence |\n|---|---|---|---|');
  const spineGroups = new Map(q('spine').map(l => { const m = l.match(/^([0-9A-F]{4}) .* groups=(\S+)/); return [m[1], m[2]]; }));
  for (const r of records.filter(r => r.cls === 'spine')) console.log(`| $${hex(r.idx, 4)} | \`${r.name}\` | ${spineGroups.get(hex(r.idx, 4))} | ${meanings.spine[hex(r.n)].confidence} |`);
  console.log('\n### Death-action rows ($7F0024 = last operand of enemy-spawn rows)\n\n| Flag | Row (scene#idx) | scene_actors.asm line | ROM offset | Actor | Enemy no. | Block (scene, rectangle) |\n|---|---|---|---:|---|---|---|');
  for (const r of records) for (const d of r.u.death) { const b = blocks.get(r.n); console.log(`| $${hex(r.idx, 4)} | $${hex(d.scene)}#${d.idx} | ${d.asm} | ${d.off} | ${d.label} | $${enemyNum.get(`${hex(d.scene)}#${d.idx}`)} | $${hex(b.scene)} ${b.wd} (${b.src.join(',')})->(${b.dst.join(',')}) L${b.layer} |`); }
  console.log('\n### Event-block table mapped to scenes (entry n at ROM offset 119758 + 8n)\n\n| n | Scene | Group | Rectangle | Triggers |\n|---|---|---|---|---|');
  for (const r of records) { const b = blocks.get(r.n), si = sceneInfo.get(b.scene); const t = []; if (r.u.cop.length) t.push(`flag COP x${r.u.cop.length}`); if (r.u.bg.length) t.push(`StageBgChange x${r.u.bg.length}`); if (r.u.death.length) t.push(`death row x${r.u.death.length}`); console.log(`| $${hex(r.n)} | $${hex(b.scene)} ${si?.name ?? '?'} | ${si?.group ?? '?'} | ${b.wd} (${b.src.join(',')})->(${b.dst.join(',')}) L${b.layer} | ${t.join(', ') || 'none'} |`); }
} else { console.error('see the header of this file for the commands'); process.exit(1); }
