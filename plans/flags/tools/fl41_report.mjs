#!/usr/bin/env node
// fl41_report.mjs - READ-ONLY generator of the FL41 text deliverables (prints to stdout; redirect it yourself).
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json, the registry fragments and queue files under
// plans/flags/results/, plans/flags/results/FL31_20261104.md (spine list), extracted/tables/*.asm and db-us/groups.json through
// fl41_matrix.mjs / fl41_lib.mjs / fl32_lib.mjs and prints to stdout. It never touches extracted/, db-us/, notes/, docs/, src/ or
// any other file.
//
// Usage (repository root):
//   node plans/flags/tools/fl41_report.mjs coverage      -> plans/flags/results/coverage.md
//   node plans/flags/tools/fl41_report.mjs ranked        -> plans/flags/results/queue/ranked_queue.json
//   node plans/flags/tools/fl41_report.mjs stats         -> counts used in the report (text)
import fs from 'node:fs';
import { buildBits, PRIMARY } from './fl41_matrix.mjs';
import { loadAll, loadQueues, domainOf, DOMAIN_TEXT, byteOf, H4, ranges, loadGroups, HELPER_TRACES } from './fl41_lib.mjs';

const cmd = process.argv[2];
const rows = buildBits();
const all = loadAll();
const { inv, reg, queues, cop, raw } = all;
const groups = loadGroups();
const groupsRaw = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const prefixOfArea = new Map(Object.entries(groupsRaw).map(([k, v]) => [k, v.prefix]));
const out = [];
const P = (s = '') => out.push(s);
const pct = (n, d) => `${n} of ${d}`;
const hx = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');

// ------------------------------------------------------------------ shared lookups
const idsAll = new Set(queues.map((q) => q.id));
const queueByFlag = new Map();
for (const q of queues) if (typeof q.flag === 'number') (queueByFlag.get(q.flag) ?? queueByFlag.set(q.flag, []).get(q.flag)).push(q.id);
const queueFor = (i) => {
    const s = new Set(queueByFlag.get(i) ?? []);
    for (const m of reg.flags.get(i)?.meanings ?? []) for (const x of m.queue ?? []) s.add(x);
    return [...s];
};
const gradesOf = (i) => [...new Set((reg.flags.get(i)?.meanings ?? []).map((m) => m.grade).filter(Boolean))];
const nameOf = (i) => (reg.flags.get(i)?.meanings ?? []).filter((m) => m.level !== 'row' && m.name).map((m) => m.name).join(' / ') || (reg.proposals.get(i)?.[0]?.name ? `(proposal) ${reg.proposals.get(i)[0].name}` : '');
const siteCite = (s) => `${s.file}:${s.line} {${s.offset}}`;

// spine set: FL31 coverage table (62 indices) + the proposals still without a record
function spineSet() {
    const t = fs.readFileSync('plans/flags/results/FL31_20261104.md', 'utf8').split('\n');
    const set = new Set();
    let cov = false;
    for (const l of t) {
        if (l.startsWith('## Coverage')) cov = true;
        else if (l.startsWith('## ') && cov) break;
        if (!cov) continue;
        let m = l.match(/^\| `\$([0-9A-F]+)`(?:-`\$([0-9A-F]+)`)? \|/);
        if (m) { const a = parseInt(m[1], 16), b = m[2] ? parseInt(m[2], 16) : a; for (let i = a; i <= b; i++) set.add(i); continue; }
        if (/^\| `\$BF`\/`\$C0`\/`\$C1`/.test(l)) [0xbf, 0xc0, 0xc1].forEach((i) => set.add(i));
        if (/^\| \*\*`\$FF`\*\*/.test(l)) set.add(0xff);
    }
    for (const i of [0xf8, 0x138, 0x185, 0x512]) set.add(i);
    return set;
}
const spine = spineSet();

// ------------------------------------------------------------------ Task 2: the 38 one-sided literal flags
const SET_ONLY = rows.filter((r) => r.dom !== 'S' && r.cop && r.cop.S + r.cop.C > 0 && r.cop.T + r.cop.W + r.cop.G === 0).map((r) => r.b);
const TEST_ONLY = rows.filter((r) => r.dom !== 'S' && r.cop && r.cop.S + r.cop.C === 0 && r.cop.T + r.cop.W > 0).map((r) => r.b);
const eventRows = [...fs.readFileSync('extracted/system/event_block_table.asm', 'utf8').matchAll(/event-block-def < #([0-9A-F]{2}),[^;]*;([0-9A-F]{2})/g)].map((m) => [parseInt(m[2], 16), parseInt(m[1], 16)]);
const DEAD = {
    0x2e: 'none found: write-only (UseItem_IncanMelody has no reader). Closed as a dead write; queued for the runtime check.',
    0x6d: 'none found: write-only. Closed as a dead write (static, searches S1-S5, S8); runtime read census queued as FL41-04.',
};
const STATUE = 'statue-reward row +0 is the raw flag index: `SetFlagRaw` at `system/statue_inventory/statue_inventory_reward.asm:114 {52689}` (trace `statue_reward_flags`, candidates `$F8-$FD`)';
const DEATH = '`SetFlag_0100` at `functions/StandardEnemyDefeatHandler.asm:122 {56371}` (also `EnemyDefeatDispatch.asm:91 {697544}`, `awB1_wall_walker.asm:538 {770410}`, `pyCC_mystic_ball.asm:251 {771966}`), index = death-action operand of an enemy-spawn row (trace `enemy_death_action_flags`)';
function otherHalf(i) {
    const c = cop.get(i);
    const set = c.S + c.C > 0;
    if (DEAD[i]) return { how: 'dead', text: DEAD[i] };
    if (i === 0x20) return { how: 'none', text: 'no setter anywhere: literal COP, helper traces, direct byte `$0A04` (none), dynamic helper inputs (0 unresolved), ROM byte scan all found nothing; the record says UNKNOWN' };
    if (i === 0x43) return { how: 'none', text: 'no setter anywhere (same searches as `$20`; none of the 17 trace candidate sets holds index 67); the record says UNKNOWN' };
    if ([0xf8, 0xf9, 0xfc, 0xfd].includes(i)) return { how: 'table', text: STATUE };
    if ([0x116, 0x132, 0x16a, 0x16b].includes(i)) return { how: 'table', text: DEATH };
    if (i >= 0x100 && i <= 0x1ff && set) {
        const row = eventRows[i - 256];
        const siteScenes = [...c.scenes];
        const same = row && siteScenes.includes(row[1]);
        const rs = row ? `$${hx(row[1])}` : 'none';
        return { how: 'table', text: `event block row $${hx(i - 256)} (scene ${rs}) is applied by the \`ApplyAllEventBlocks\` scan (\`event_blocks.asm:81 {172529}\`, reads all of \`$0A20-$0A3F\`); ${same ? 'same scene as the setter' : `setter scene ${siteScenes.map((s) => '$' + hx(s)).join(', ')} differs from the row scene: the block is applied when the player loads scene ${rs} later`}` };
    }
    return { how: '?', text: '' };
}

// ------------------------------------------------------------------ quality checks
function quality() {
    const q = {};
    // names
    const names = new Map();
    for (const [i, r] of reg.flags) for (const m of r.meanings) if (m.name) (names.get(m.name) ?? names.set(m.name, []).get(m.name)).push(i);
    q.dupNames = [...names].filter(([, l]) => l.length > 1);
    // proposals whose name equals a record name at another index
    q.propClash = [];
    for (const [i, ps] of reg.proposals) for (const p of ps) if (p.name && names.has(p.name) && !names.get(p.name).includes(i)) q.propClash.push([i, p.name, names.get(p.name)]);
    // prefix vs area
    q.prefix = [];
    for (const [i, r] of reg.flags) for (const m of r.meanings) {
        if (!m.name || !m.area) continue;
        const p = m.name.split('_')[0];
        const ap = prefixOfArea.get(m.area);
        if (m.area === 'system') { if (p !== 'sys' && p !== 'sy') q.prefix.push([i, m.name, m.area, 'sys']); continue; }
        if (ap && p !== ap) q.prefix.push([i, m.name, m.area, ap]);
        if (!ap) q.prefix.push([i, m.name, m.area, '(area not in groups.json)']);
    }
    // D1
    q.d1Null = []; q.d1Overlap = []; q.d1RowNoGrade = [];
    for (let i = 0; i < 16; i++) {
        const seen = new Map();
        for (const m of reg.flags.get(i).meanings) {
            if (m.scope == null) q.d1Null.push([i, m.name]);
            if (m.level === 'row' && !m.grade) q.d1RowNoGrade.push([i, m.scope?.scenes]);
            for (const s of m.scope?.scenes ?? []) (seen.get(s) ?? seen.set(s, []).get(s)).push(m.name ?? '(row)');
        }
        for (const [s, l] of seen) if (l.length > 1) q.d1Overlap.push([i, s, l]);
    }
    // grades without evidence / queue
    q.noEvidence = []; q.noQueueField = []; q.badQueueRef = [];
    for (const [i, r] of reg.flags) for (const m of r.meanings) {
        if (!(m.evidence ?? []).length && m.level !== 'row') q.noEvidence.push([i, m.name, m.grade]);
        if ((m.grade === 'INFERRED' || m.grade === 'UNKNOWN') && !(m.queue ?? []).length) q.noQueueField.push([i, m.name, m.grade, queueFor(i)]);
        for (const x of m.queue ?? []) if (!idsAll.has(x)) q.badQueueRef.push([i, x]);
    }
    // grade counts
    q.grades = {};
    for (const [, r] of reg.flags) for (const m of r.meanings) q.grades[m.grade ?? '(none)'] = (q.grades[m.grade ?? '(none)'] ?? 0) + 1;
    // fragment name disagreement
    const by = new Map();
    for (const fr of raw) {
        const j = fr.json;
        for (const [k, v] of Object.entries(j.flags ?? {})) for (const m of v.meanings ?? []) if (m.name) (by.get(+k) ?? by.set(+k, []).get(+k)).push([fr.file.slice(0, fr.file.indexOf('_')), m.name, 'record']);
        for (const [k, v] of Object.entries(j.proposals ?? {})) for (const m of Array.isArray(v) ? v : [v]) if (m?.name) (by.get(+k) ?? by.set(+k, []).get(+k)).push([fr.file.slice(0, fr.file.indexOf('_')), m.name, 'proposal']);
    }
    q.disagree = [];
    for (const [i, l] of [...by].sort((a, b) => a[0] - b[0])) {
        if (i < 16) continue;
        const ns = new Set(l.map((x) => x[1]));
        if (ns.size > 1) q.disagree.push([i, l, nameOf(i)]);
    }
    return q;
}

// ------------------------------------------------------------------ coverage.md
function coverage() {
    const Q = quality();
    const count = (f) => rows.filter(f).length;
    P('# FL41 coverage matrix of the flag array `$0A00-$0AB3`');
    P();
    P('Generated read-only by `node plans/flags/tools/fl41_report.mjs coverage` (2026-11-04). Inputs: `plans/flags/inventory.json` (FL01 build, 909 asm files, 818 tagged, 1,693 literal COP sites, 18 scene-meta gates, 57 helper calls, 17 traces, 674 direct accesses), the registry fragments FL10-FL40 merged in order (`fl32_lib.mjs loadRegistry`), the queue files FL10-FL40 (337 items), `extracted/tables/*.asm` (event block table, scene actors) and `db-us/groups.json`. `db-us/flags.json` is still the empty skeleton, so "named record" means a record in the merged fragment chain, not a shipped one. Bits are global flag indices `$0000-$059F` (1,440 bits); byte = `$0A00 + (index >> 3)`, bit = `index & 7`. The tables name the bits by their hex index. The one-line status rule per bit is in section 1; the per-bit rows are in the appendix (section 9).');
    P();
    P('## 1. How to read this file');
    P();
    P('Every bit has one **primary status** (the FL41 vocabulary, precedence top to bottom) and two detail axes.');
    P();
    P('| Primary status | Rule |');
    P('|---|---|');
    P('| overlaps inventory/ability/other state | the byte is not flag storage (`$0AA4-$0AB3` state words), or it is an ability-bitmask bit (`$0510-$051F`) that has no named record |');
    P('| named record | at least one non-row meaning with a name in the merged registry |');
    P('| scene row only | only `level: "row"` meanings (no bit has this status; the scene-level version is in section 5) |');
    P('| literal COP both ways, no record | set and tested by literal COP, no record (added to the vocabulary: the bit `$0138`) |');
    P('| helper-only (no literal COP) | reached by a helper trace only, no record |');
    P('| table-only | reached through a data table or the event-block scan row, no literal COP, no record |');
    P('| set-only / test-only | literal COP sets (or only tests) the bit, or an engine scan / dynamic helper only reads it; no record; no other half found |');
    P('| referenced by a direct read | only a direct-address access reaches it (`LDA $0A9F` tomb mask) |');
    P('| unreferenced | none of the searches S1-S9 finds a use; section 4.9 names them per range |');
    P();
    P('**Detail axes.** *doc*: record / proposal / table-row / none. *ref*: `both`, `set-only` and `test-only` (literal COP), `gate-only`, `helper-only`, `helper+direct`, `table-only`, `direct-only`, `debug-only`, `unreferenced`, `not-a-flag`. A `test-only` ref with no literal COP means a dynamic reader (the event-block scan or `TestFlag_0300(sceneCurrent)`); the tag in the appendix says which.');
    P();
    P('**Searches (the proof behind "unreferenced").**');
    P();
    P('| id | Search | Result |');
    P('|---|---|---|');
    P('| S1 | literal COP operands: `inventory.json` `sites` kind `cop` (1,693 sites, 284 distinct indices); cross-checked by `fl41_romscan.mjs`, a ROM byte scan of `02 <CC-D3> <operands>` (2,018 byte matches, 1,693 equal to inventory sites, 325 not: 22 mid-instruction operand bytes and 303 inside data regions, none a code site) | indices in section 4 |');
    P('| S2 | scene-meta gates: `branch < flag, label >` in `tables/scene_meta.asm` (18 lines, 9 distinct indices, all literal; `SceneCmd_Branch` reads the operand with `ReadScriptByte`, so it reaches `$00-$FF` only) | 18 of 18 decoded |');
    P('| S3 | helper call sites: 57 in `inventory.json` `helper_calls`, matching an independent label-name scan (`rg` of every `flag_helpers` entry), and no call by numeric address (`rg` of `JSL/JSR/JML/JMP/PEA $B0xx-$B4xx` and `$80Bxxx` in `extracted/`: 0 matches); 17 traces with candidate index sets | `unresolved_dynamic_helper_inputs` = [] |');
    P('| S4 | direct accesses to bytes `$0A00-$0AB3`: 674 rows in `direct_accesses` (flag region rows: `$0A00` 13, `$0A01` 3, `$0A1F` 4, `$0A20` 1, `$0A80` 6, `$0A9F` 1, `$0AA2` 31, then the state words) | bytes with no row: every byte not listed here |');
    P('| S5 | event-block table (158 rows) and the `ApplyAllEventBlocks` scan of `$0A20-$0A3F` (all 256 bits; `event_blocks.asm:81 {172529}`) | D3 |');
    P('| S6 | kill-flag spawn rows: enemy-spawn rows of `tables/scene_actors.asm` (operand 6 = enemy number); `CheckEnemyDefeatedFlag`; `ClearAllWramFlags` | D6 |');
    P('| S7 | data tables that feed helpers: `scene_chest_table` (46 rows, 7-bit flag), `enemy_clear_reward_table` (256 bytes, 87 nonzero), boss `boss-reward-range` rows (6 matched), `statue-reward` rows, hidden red jewel actor parameters | D4, D5, D7 |');
    P('| S8 | numeric-address helper calls | none (see S3) |');
    P('| S9 | the registry: 912 meanings in FL10-FL40 and their `_no_use`, `_block_only` and `_no_use_range` notes | per-range notes below |');
    P();
    P('## 2. Summary');
    P();
    P('### 2.1 Primary status per domain');
    P();
    const doms = ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7b', 'U', 'D7a', 'S'];
    P('| Domain | index range | bytes | ' + PRIMARY.map((s) => s.replace('overlaps inventory/ability/other state', 'overlaps').replace('literal COP both ways, no record', 'both, no record').replace('referenced by a direct read', 'direct read').replace('helper-only (no literal COP)', 'helper-only')).join(' | ') + ' | total |');
    P('|---|---|---|' + PRIMARY.map(() => '---:').join('|') + '|---:|');
    const dr = { D1: ['0000', '000F', '0A00-0A01'], D2: ['0010', '00FF', '0A02-0A1F'], D3: ['0100', '01FF', '0A20-0A3F'], D4: ['0200', '02FF', '0A40-0A5F'], D5: ['0300', '03FF', '0A60-0A7F'], D6: ['0400', '04FF', '0A80-0A9F'], D7b: ['0500', '0507', '0AA0'], U: ['0508', '050F', '0AA1'], D7a: ['0510', '051F', '0AA2-0AA3'], S: ['0520', '059F', '0AA4-0AB3'] };
    const tot = {};
    for (const d of doms) {
        const rr = rows.filter((r) => r.dom === d);
        P(`| ${DOMAIN_TEXT[d]} | \`$${dr[d][0]}-$${dr[d][1]}\` | \`$${dr[d][2]}\` | ` + PRIMARY.map((s) => { const n = rr.filter((r) => r.primary === s).length; tot[s] = (tot[s] ?? 0) + n; return n || '.'; }).join(' | ') + ` | ${rr.length} |`);
    }
    P(`| **total** | | | ` + PRIMARY.map((s) => `**${tot[s] ?? 0}**`).join(' | ') + ` | **${rows.length}** |`);
    P();
    P('### 2.2 Reference axis and documentation axis');
    P();
    const cr = {}, cd = {};
    for (const r of rows) { cr[r.ref] = (cr[r.ref] ?? 0) + 1; cd[r.doc] = (cd[r.doc] ?? 0) + 1; }
    P('| ref | bits | | doc | bits |');
    P('|---|---:|---|---|---:|');
    const rk = Object.keys(cr).sort((a, b) => cr[b] - cr[a]);
    const dk = Object.keys(cd).sort((a, b) => cd[b] - cd[a]);
    for (let i = 0; i < Math.max(rk.length, dk.length); i++) P(`| ${rk[i] ?? ''} | ${rk[i] ? cr[rk[i]] : ''} | | ${dk[i] ?? ''} | ${dk[i] ? cd[dk[i]] : ''} |`);
    P();
    P('Reading the table: 683 bits own a named record (D1 16, D2 211, D3 102, D4 62, D5 87, D6 192, D7 13). The 261 unreferenced bits are listed in section 4.9; every one of them is also covered by the runtime write census FL41-01 (section 8.4). `D5 test-only 142` are the scene-reward bits of scenes that have tier 0 in the table but are read anyway by `TestFlag_0300(sceneCurrent)` (section 7).');
    P();
    P('## 3. Per-byte summary (180 bytes)');
    P();
    P('Columns: R = named record, T = table-only, S/Tst = set-only / test-only, X = direct read, U = unreferenced, O = overlaps state; "both" = literal COP both ways without a record (`$0138`). Bytes with all eight bits in one status show one number.');
    P();
    P('| byte | indices | domain | R | T | S | Tst | X | both | U | O | records on the byte |');
    P('|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|');
    for (let by = 0xa00; by <= 0xab3; by++) {
        const rr = rows.filter((r) => r.byte === by);
        const k = (s) => rr.filter((r) => r.primary === s).length || '.';
        const nm = rr.filter((r) => r.names.length).map((r) => r.bit).join('');
        P(`| \`$${hx(by, 4)}\` | \`$${hx(rr[0].b, 4)}-$${hx(rr[7].b, 4)}\` | ${rr[0].dom} | ${k('named record')} | ${k('table-only')} | ${k('set-only')} | ${k('test-only')} | ${k('referenced by a direct read')} | ${k('literal COP both ways, no record')} | ${k('unreferenced')} | ${k('overlaps inventory/ability/other state')} | ${nm ? 'bits ' + nm.split('').join(',') : '-'} |`);
    }
    P();
    P('## 4. Lists per status');
    P();
    const listOf = (s) => rows.filter((r) => r.primary === s).map((r) => r.b);
    P('### 4.1 Named record');
    P();
    P(`${listOf('named record').length} bits: ${ranges(listOf('named record'))}`);
    P();
    P('### 4.2 Scene row only');
    P();
    P('No bit. Scene-level coverage of D1 (the only domain where rows exist) is in section 5.');
    P();
    P('### 4.3 Helper-only (no literal COP): reference axis');
    P();
    P('Bits reached by a helper trace and by no literal COP, whether or not they have a record (the record decides the primary status).');
    P();
    P('| index | name | helper trace | note |');
    P('|---|---|---|---|');
    for (const r of rows.filter((r) => r.ref === 'helper-only' || r.ref === 'helper+direct')) P(`| \`$${hx(r.b, 4)}\` | ${nameOf(r.b) || '(no record)'} | ${r.helperRefs.join(', ')} | ${r.ref === 'helper+direct' ? 'also a direct read of `abilityBitmask`: ' + r.direct.map((d) => d.cite).join('; ') : ''} |`);
    P();
    P('### 4.4 Table-only: reference axis');
    P();
    const tbl = rows.filter((r) => r.ref === 'table-only');
    P(`${tbl.length} bits. By source: event-block rows without a literal COP ${tbl.filter((r) => r.dom === 'D3').length} (${ranges(tbl.filter((r) => r.dom === 'D3').map((r) => r.b))}); scene reward tier rows ${tbl.filter((r) => r.dom === 'D5').length}; chest rows ${tbl.filter((r) => r.dom === 'D4').length}; kill flags ${tbl.filter((r) => r.dom === 'D6').length}; boss row ${tbl.filter((r) => r.dom === 'D7b').length}. Bits without a record: ${tbl.filter((r) => r.doc === 'table-row').length} (${ranges(tbl.filter((r) => r.doc === 'table-row').map((r) => r.b))}).`);
    P();
    P('### 4.5 Set-only (literal COP): the 28');
    P();
    P(ranges(SET_ONLY) + ' (table in section 6).');
    P();
    P('### 4.6 Test-only (literal COP): the 10');
    P();
    P(ranges(TEST_ONLY) + ' (table in section 6).');
    P();
    P('Test-only by a dynamic reader and no literal COP, no record: ' + `${rows.filter((r) => r.dynTest && r.dom === 'D3').length} D3 bits (${ranges(rows.filter((r) => r.dynTest && r.dom === 'D3').map((r) => r.b))}: scanned by \`ApplyAllEventBlocks\`, beyond the 158-row table) and ${rows.filter((r) => r.dynTest && r.dom === 'D5').length} D5 bits (tier-0 scenes read by \`TestFlag_0300(sceneCurrent)\`).`);
    P();
    P('### 4.7 Referenced by a direct read');
    P();
    P('| index | what | cite |');
    P('|---|---|---|');
    for (const r of rows.filter((r) => r.direct.length)) P(`| \`$${hx(r.b, 4)}\` | ${r.direct.map((d) => d.what).join('; ')} | ${r.direct.map((d) => d.cite).join('; ')} |`);
    P();
    P('### 4.8 Literal COP both ways, no record');
    P();
    P(ranges(rows.filter((r) => r.primary === 'literal COP both ways, no record').map((r) => r.b)) + ' (`$0138`, the Seaside Palace key door; proposal only, section 8.3).');
    P();
    P('### 4.9 Unreferenced (each range names the searches that found nothing)');
    P();
    P('| range | bits | searches that found no use | other evidence |');
    P('|---|---:|---|---|');
    const unr = rows.filter((r) => r.primary === 'unreferenced');
    const grp = (f) => ranges(unr.filter(f).map((r) => r.b));
    const cnt = (f) => unr.filter(f).length;
    P(`| D2 ${grp((r) => r.dom === 'D2')} | ${cnt((r) => r.dom === 'D2')} | S1 (no literal COP of the index), S2 (not a gate operand), S3 (not in any trace candidate set), S4 (no direct access to the byte except \`$0A1F\` bit 7), S8 | each index appears in no FL20-FL29 registry record or site table; the 62 indices of FL10 section 5 'no static site' agree for the bytes it lists |`);
    P(`| D4 ${grp((r) => r.dom === 'D4')} | ${cnt((r) => r.dom === 'D4')} | S1, S2, S3 (only the 46 chest rows via \`barrier_chest_flags\` and the 16 jewel numbers reach \`$0200\`-based indices), S4 (no direct access to \`$0A40-$0A5F\`), S7 (no chest row has another flag value) | FL12 section 3: 62 mapped, 194 with no path; census item FL12-06 queued; \`$0200\` is chest flag 0 (no row uses it) |`);
    P(`| D5 ${grp((r) => r.dom === 'D5')} | ${cnt((r) => r.dom === 'D5')} | S1, S2, S3 (candidates are tier rows; helper callers read \`$0300 + sceneCurrent\` only for ids that are scenes), S4 (no direct access to \`$0A60-$0A7F\`), \`groups.json\` lookup: the scene id is not a scene | the id is not a scene id of \`db-us/groups.json\`, so \`sceneCurrent\` never has this value (the 142 tier-0 ids that are scenes are \`test-only\`, section 7) |`);
    P(`| D6 ${grp((r) => r.dom === 'D6')} | ${cnt((r) => r.dom === 'D6')} | S1, S3, S6 (no enemy-spawn row with enemy number \`$00\` or \`$F7\`), S4 (\`$0A9E\`: no direct access) | FL14: \`$0400\` is 'no flag'; \`$04F7\` has no spawn row; \`$04FF\` is not unreferenced (tomb mask) |`);
    P(`| D7 ${grp((r) => r.dom === 'D7b')} | ${cnt((r) => r.dom === 'D7b')} | S1, S3 (the \`Offset100\` helpers mask to 3 bits; boss rows 0-5 match, rows 6-7 are placeholder rows that the first-match scan never reaches), S4 (\`$0AA0\` has no direct access) | FL15 section 4 (boss rows 5-7 placeholders) |`);
    P(`| unassigned byte ${grp((r) => r.dom === 'U')} | ${cnt((r) => r.dom === 'U')} | S1, S3 (3-bit mask never reaches byte \`$0AA1\`), S4 (no row for \`$0AA1\`) | FL10-18 queue item (unassigned bytes), FL10 section 5 |`);
    P();
    P('### 4.10 Overlaps inventory/ability/other state');
    P();
    const ov = rows.filter((r) => r.primary === 'overlaps inventory/ability/other state');
    P(`${ov.length} bits: \`$0520-$059F\` = bytes \`$0AA4-$0AB3\` (128 bits: \`$0AA4-$0AA5\` unassigned, \`$0AA6\` state word with 81 direct sites, \`$0AA8-$0AAB\` unassigned, \`$0AAC\` state word, \`$0AAE-$0AAF\` unassigned, \`$0AB0\` word, \`$0AB2\` word, \`$0AB4\` starts \`inventorySlots\`) and the ability bits that have no record: ${ranges(ov.filter((r) => r.dom === 'D7a').map((r) => r.b))}. Of those, \`$0512\` is the Spin Dash bit (helper \`TestFlag_0510\` and the BIT masks at \`attack_ability_system.asm:155 {178162}\`, \`:177 {178217}\`, \`gw85_spin_dash_gate.asm:27 {518420}\`; proposal only), \`$0513\` and \`$0517\` are touched only by the 16-bit debug stores of \`$00FF\` into \`abilityBitmask\` (\`debug_man\` {781889}, \`unused_debug_mode\` {637608}; no BIT mask in any reader includes bit 3 or 7), and \`$051B-$051F\` appear in no reader mask, no helper candidate set and no setter. The bytes \`$0AA4-$0AB3\` are not flag storage: a flag index there would only be reached by a word-form COP with an operand above \`$051F\`, and the inventory has no such operand (largest literal index \`$0185\`).`);
    P();
    P('## 5. D1 scratch flags: (scene, bit) coverage');
    P();
    P('D1 is scoped by scene. Pairs = distinct scene ids on the literal sites of an index; covered = a non-row meaning scopes the scene; row = only a `level: "row"` meaning scopes it. Sites whose scene list is the whole game are shared engine readers (`player_character.asm` runs in 223 scenes for index 0).');
    P();
    P('| index | meanings | scenes on sites | covered by a record | row only | not scoped | of which shared-engine sites only |');
    P('|---|---:|---:|---:|---:|---:|---:|');
    let tp = 0, tr_ = 0, trow = 0, tu = 0;
    for (let i = 0; i < 16; i++) {
        const c = cop.get(i);
        const ms = reg.flags.get(i).meanings;
        const rec = new Set(), row = new Set();
        for (const m of ms) for (const s of m.scope?.scenes ?? []) (m.level === 'row' ? row : rec).add(s);
        const specific = new Set();
        for (const s of c.sites) if (s.kind === 'cop' && (s.scenes ?? []).length > 0 && s.scenes.length <= 30) for (const x of s.scenes) specific.add(x);
        const scenes = [...c.scenes];
        const covered = scenes.filter((s) => rec.has(s)).length;
        const rowo = scenes.filter((s) => !rec.has(s) && row.has(s)).length;
        const unc = scenes.filter((s) => !rec.has(s) && !row.has(s));
        const uncSpecific = unc.filter((s) => specific.has(s));
        tp += scenes.length; tr_ += covered; trow += rowo; tu += unc.length;
        P(`| \`$${hx(i, 4)}\` | ${ms.length} | ${scenes.length} | ${covered} | ${rowo} | ${unc.length} | ${unc.length - uncSpecific.length} shared + ${uncSpecific.length} scene-specific |`);
    }
    P(`| **total** | | ${tp} | ${tr_} | ${trow} | ${tu} | |`);
    P();
    P('The 19 scene-specific pairs without a scope entry are all sites of directory-wide actors or the inventory pseudo-scene `$FF`; each site is cited in the evidence of a record whose scope names the scene that matters (`overworld_exit.asm:210 {52010}` in `$0001` scene `$15`, `item_use_system.asm:701 {232398}` is cited by no record: quality item Q-E6 below, `mu67_vampires.asm:193 {717483}` in `$0002` scene `$67`, `item_use_system.asm:811 {232828}`, `:710/:711 {232420, 232426}` in `$000D/$000E` scene `$CD`, `:931 {233336}` in `$000F` scene `$39`, `gw82_archer.asm:135 {757688}` in `$000F` scene `$87`). The 188 shared-engine scenes of index `$0000` read a bit that nothing sets in those scenes: the record `sys_player_alt_idle_active` (34 scenes) covers the scenes where it is set.');
    P();
    // ---------------------------------------------------------------- Task 2
    P('## 6. The 28 set-only and 10 test-only literal flags: where the other half lives');
    P();
    P('Method: for each flag the inventory gives literal COP sites; the other half is looked for in S3 (helper trace candidates), S5 (event-block row and scan), S4 (direct byte accesses), S1 again with the opposite role, and the dynamic inputs (none unresolved). "Closed" = a concrete other half is cited; "dead write" = every search found no reader, the claim is static; "queued" = a runtime item exists. Row scene = scene byte of the event block row `n` of `extracted/system/event_block_table.asm`.');
    P();
    P('| index | name | grade | literal | other half | status |');
    P('|---|---|---|---|---|---|');
    for (const i of [...SET_ONLY, ...TEST_ONLY].sort((a, b) => a - b)) {
        const c = cop.get(i);
        const oh = otherHalf(i);
        const lit = c.sites.slice(0, 2).map((s) => `${s.role[0].toUpperCase()}: ${siteCite(s)}`).join('; ') + (c.sites.length > 2 ? ` (+${c.sites.length - 2})` : '');
        const gr = gradesOf(i).join('/') || 'proposal';
        const qs = queueFor(i);
        const status = oh.how === 'table' ? 'closed (table)' + (qs.length ? `; queued ${qs.join(', ')}` : '') : oh.how === 'dead' ? 'closed (dead write)' + (qs.length ? `; queued ${qs.join(', ')}` : '') : `queued ${qs.join(', ') || 'MISSING'}`;
        P(`| \`$${hx(i, 4)}\` | ${nameOf(i) || '(no record)'} | ${gr} | ${lit} | ${oh.text} | ${status} |`);
    }
    P();
    P(`Result: ${[...SET_ONLY, ...TEST_ONLY].filter((i) => otherHalf(i).how === 'table').length} flags closed by a table or helper other half (26 event-block rows, 4 statue-reward rows, 4 death-action rows), 2 dead writes (\`$2E\`, \`$6D\`), 2 test-only flags with no setter anywhere (\`$20\`, \`$43\`, both UNKNOWN and queued FL20-10, FL21-08). Cross-scene rows: \`$0125\`, \`$0129\`, \`$012D\` are set in scene \`$52\` and applied in scene \`$51\`; \`$0151\` is set in \`$75\` and applied in \`$74\`; \`$0185\` is set in \`$2C\` and applied in \`$1E\`. No dynamic-trace or dead-code explanation is needed beyond these.`);
    P();
    // ---------------------------------------------------------------- Task 3
    P('## 7. Dynamic inputs and helper callers');
    P();
    P('`inventory.json` reports `unresolved_dynamic_helper_inputs = []` and `unresolved_cop_sites = []`. `SceneCmd_Branch` (`scene_script.asm:264 {164941}`) is decoded: all 18 `branch < flag, label >` lines of `tables/scene_meta.asm` (an independent `rg` count agrees) have a literal one-byte operand, 9 distinct indices (`$21 $4C $70 $7B $7E $88 $96 $B3 $F4` in decimal 33, 76, 112, 123, 126, 136, 150, 179, 244); no other file carries a `branch <` command.');
    P();
    P('Bound of every helper caller (57 call sites, grouped by trace):');
    P();
    P('| Trace / group | call sites | input | bound | result |');
    P('|---|---:|---|---|---|');
    const hc = {};
    for (const h of inv.helper_calls) { const k = h.trace ?? h.resolution; (hc[k] = hc[k] ?? []).push(h); }
    const BOUND = {
        'cop-operand': ['COP operand of the script command', 'all 1,693 COP sites have literal operands (`unresolved_cop_sites` empty)', 'bounded'],
        dungeon_kill_wram_flags: ['actor field enemy number from the spawn row', '253 candidates = nonzero enemy numbers of `scene_actors` (FL14 table, 1 to 255)', 'bounded (rows)'],
        enemy_clear_reward_flags: ['`$0300 + sceneCurrent` (tests) or the placed scene (boss handler, reward actors)', 'the 87-scene candidate set bounds only the SET sites (`boss_clear_reward_handler.asm:159 {50035}`, `reward_actors.asm:115 {57679}`, reached after a tier read). The TEST sites `StandardEnemyDefeatHandler.asm:89 {56311}`, `:204 {56727}` (test before the tier-0 check), `radar_map_screen.asm:175 {229828}`, `field_reveal_object.asm:45 {55948}` and `boss_clear_reward_handler.asm:154 {50026}` read `$0300 + sceneCurrent` for any scene value', '**not bounded by the candidate set**: reads cover every scene id; the 142 tier-0 scene ids are read and never set (D5 `test-only`); harmless (read only), but the candidate list understates the read set'],
        enemy_death_action_flags: ['`deathActionIdx` stored from operand 7 of an enemy-spawn row; the callers skip index 0', '42 candidates from the rows; `StandardEnemyDefeatHandler.asm:119 {56361}` tests only when the index is nonzero', 'bounded (rows)'],
        barrier_chest_flags: ['chest-table byte 3 & `$7F`', '46 rows, so at most 46 indices (`$0201-$027E`)', 'bounded (rows)'],
        hidden_red_jewel_flags: ['actor parameter `$0E + $80` on base `$0200`', '16 actors placed in scene rows (`$0280-$028F`)', 'bounded (placement)'],
        hit_switch_flags: ['actor parameter `$24 := $0E`', '5 values (`$01-$04`, `$0F`) over 3 scenes (placement)', 'bounded (placement)'],
        statue_reward_flags: ['statue-reward row +0', '6 rows (`$F8-$FD`)', 'bounded (rows)'],
        necklace_stone_flags: ['byte table indexed by actor parameter', '2 candidates (`$98 $99`)', 'bounded (placement)'],
        diamond_mine_laborer_flags: ['byte table indexed by actor parameter', '4 candidates (`$A0-$A3`)', 'bounded (placement)'],
        falling_orb_flags: ['actor parameter `$0E + $80`', '2 candidates (`$F2 $F3`)', 'bounded (placement)'],
        gold_tile_flags: ['actor parameter `$0E`', '4 candidates (`$01-$04`)', 'bounded (placement)'],
        dark_space_portal_death_flags: ['actor parameter `$0E` (spawn byte >> 1) on base `$0100`', '1 candidate (`$0173`), 1 scene', 'bounded (placement)'],
        boss_reward_wram_flags: ['boss row number & 7', '6 rows matched (rows 6-7 are shadowed placeholders); `$0500-$0505`', 'bounded (rows)'],
        wram_offset_constant_callers: ['immediate `LDA` before `TestWramFlag_Offset100`', '6 constants (`$00-$04`, `$03`)', 'bounded (constants)'],
        inventory_ability_flags: ['`4 * characterForm + slot`', 'forms 0-2 times slots 0-2 = 9 candidates; a `characterForm` above 2 would index `$051C+`', 'bounded by the form domain (assumption: `characterForm` stays 0-2)'],
        scene_meta_gates: ['`SceneCmd_Branch` operand', '18 literal gates, 9 indices', 'bounded (decoded)'],
        block: ['none (`ClearAllWramFlags` has no input)', '3 callers', 'no input'],
    };
    for (const k of Object.keys(hc)) {
        const b = BOUND[k] ?? ['?', '?', '?'];
        P(`| ${k} | ${hc[k].length} | ${b[0]} | ${b[1]} | ${b[2]} |`);
    }
    P();
    P('Findings: (1) no helper input is unresolved and no helper is called by numeric address. (2) The only unbounded input is `sceneCurrent` in the `TestFlag_0300` callers; its read set is all 256 values, so the matrix classifies the 142 tier-0 scene ids as test-only and the 27 non-scene ids as unreferenced (a scene id that does not exist cannot be `sceneCurrent`). (3) The scan in `ApplyAllEventBlocks` reads all 256 D3 bits while the table has 158 rows: `LookupEventBlock` has no bound check (FL11), so a set bit in `$019E-$01FF` makes the scan read 8 bytes beyond the table and apply a block when the junk scene byte equals `sceneCurrent`. No code sets those bits; a preset or census harness must not write them (queue item FL41-02). (4) `inventory_ability_flags` is bounded only by the domain of `characterForm`.');
    P();
    // ---------------------------------------------------------------- Task 4
    P('## 8. Quality audit');
    P();
    P('### 8.1 Counts');
    P();
    P(`Merged chain: ${reg.flags.size} index records, ${Object.values(Q.grades).reduce((a, b) => a + b, 0)} meanings; grades ${Object.entries(Q.grades).map(([k, v]) => `${k} ${v}`).join(', ')} (the 6 meanings without a grade are the D1 row meanings, Q-C3). Proposals without a record: ${rows.filter((r) => r.doc === 'proposal').map((r) => '`$' + hx(r.b, 4) + '`').join(', ')}. Names: ${[...new Set(rows.flatMap((r) => r.names.map((n) => n.name)))].length} distinct, ${Q.dupNames.length} reused across indices. Queue items: ${queues.length} in 20 files.`);
    P();
    P('### 8.2 Checks run and results');
    P();
    P('| check | method | result |');
    P('|---|---|---|');
    P(`| duplicate or non-unique names | every \`name\` of every meaning, merged chain | ${Q.dupNames.length} names used at two indices; ${Q.propClash.length} proposals reuse a record name at another index |`);
    P(`| D1 records with \`scope: null\` | indices \`$0000-$000F\` | ${Q.d1Null.length} |`);
    P(`| D1 overlapping scopes | scene present in two meanings of one D1 index | ${Q.d1Overlap.length} scene overlaps (Q-C2) |`);
    P(`| name prefix versus area | prefix of the name against \`db-us/groups.json\` prefix (system = \`sys\`) | ${Q.prefix.length} meanings (Q-D) |`);
    P(`| grades without evidence | VERIFIED-STATIC with no \`{offset}\` evidence entry: 0; any meaning without evidence: ${Q.noEvidence.length} | ${Q.noEvidence.map((x) => '`$' + hx(x[0], 4) + '` ' + x[1] + ' (' + x[2] + ')').join('; ')} (Q-F) |`);
    P(`| INFERRED/UNKNOWN without \`queue\` field | meaning field \`queue\` empty | ${Q.noQueueField.length} of 164, each covered by a queue item of the same flag (Q-B1) |`);
    P(`| \`queue\` ids that do not exist | field against the 337 ids | ${Q.badQueueRef.length} |`);
    P('| citations `file:line {offset}` | `fl32_citecheck.mjs` over the 22 registry fragments and 20 queue files | 1 real mismatch (Q-E1); the tool also prints 29 lines for shorthand citations that re-use the previous file name, and 130 lines for data-table rows (`tables/*.asm`, `boss-reward-range` rows) that carry no `; {n}` tag; all checked by hand |');
    P('| `npm run flags -- --check` | real db: `Flags check: OK (0 indices ...; 1 warning)`; chain merged into a scratch registry by FL32: 86 errors | listed in FL32 section "New questions" (44 unknown kinds, 32 `requires/excludes` and 7 `pairsWith` as text, 2 scoped single D2 meanings, area `unused`, 5 overlapping D1 scopes); the apply pass fixes them |');
    P();
    P('### 8.3 Findings with the fix');
    P();
    P('**Q-A Spine flags still proposals.** `$00F8`, `$0138`, `$0185`, `$0512` have no record (FL31 left them for FL32; FL32 did not write them). Proposals disagree for `$0138`: FL11 and FL32 `sp_palace_entrance_open`, FL25 and FL30 `sp_mu_passage_door_open` (high). The code settles it: `UseItem_SeasidePalaceKey` (`item_use_system.asm:1052 {233821}`, `:1057 {233840}`) tests the player inside tiles (08,07)-(0A,08) of scene `$5A`, removes item `#10`, stages BG change `#38` and sets the flag; the door it opens is the passage to Mu (warp `#05` to scene `$5E`). Fix: FL41 proposal `$0138 sp_mu_passage_door_open`; FL32 rows that name `sp_palace_entrance_open` (`FL32_registry.json`, 1) follow. `$F8`: `gs_mystic_statue_ceremony_done`; `$0185`: `gs_ship_departure_started`; `$0512`: `sys_will_spin_dash_unlocked`; unchanged from the proposals, FL41 repeats them in `FL41_registry.json` so the apply pass can write the four records.');
    P();
    const QSPEC = { sc_town_player_south_strip_active: 'FL20-11', bt_light_elevator_player_pose_cue: 'FL29-01', sc_cave_statue_moved_ack: 'FL20-12', pr_text_fade_out_done: 'FL20-13', py_vader_barrier_busy: 'FL29-03', sc_cave_friends_idle: 'FL20-10', end_epilogue_first_half_done: 'FL29-07', py_trickle_orbs_a_fallen: 'FL29-04', py_trickle_orbs_b_fallen: 'FL29-05' };
    P('**Q-B Records without a queue id.** ' + Q.noQueueField.map((x) => `\`$${hx(x[0], 4)}\` ${x[1]} -> ${QSPEC[x[1]] ?? '(no item: ' + x[3].join(', ') + ')'}`).join('; ') + '. Each id is the item of that meaning (same flag and scope). Fix: patch rows in `FL41_registry.json` add the `queue` field (`expectOld` = the current name).');
    P();
    P('**Q-C D1.** (1) 0 records with `scope: null`. (2) Overlapping scopes: ' + Q.d1Overlap.map((x) => `\`$${hx(x[0], 4)}\` scene \`$${hx(x[1])}\` (${x[2].join(' + ')})`).join('; ') + '. The nine `$0000` overlaps are the layering of one generic engine record (`sys_player_alt_idle_active`) over nine scene-specific setters and are intended; the four scene-`$06` overlaps (`$0001-$0004`) are two phases of the same scene that `scope.scenes` cannot separate: the fix is an `actors` scope on each of the eight meanings (`sc_house_*` at the House intro versus the departure chain). (3) Six D1 row meanings have no name, area, kinds or grade (`' + Q.d1RowNoGrade.map((x) => '$' + hx(x[0], 4) + ' scenes ' + (x[1] ?? []).join(',')).join('`, `') + '`): rows are scene-level notes; the fix is to give them `grade: INFERRED` when the apply pass writes them.');
    P();
    P('**Q-D Names.**');
    P();
    P('Prefix versus area: ' + (Q.prefix.length ? `${Q.prefix.length} meanings. ` + [...new Set(Q.prefix.map((x) => `\`${x[1].split('_')[0]}_\` in area ${x[2]} (expected ${x[3]})`))].join('; ') + '. Examples: ' + Q.prefix.slice(0, 6).map((x) => `\`$${hx(x[0], 4)}\` ${x[1]}`).join(', ') : 'none') + '. Fix: area `ending` uses the prefix `end_` (rename the area to `end` or the names to `ed_`, one decision for the apply pass), and `$00F5 unused_mode7_boss_defeated` takes area `system` with a `sys_` name.');
    P();
    P('Names that do not state what is true when set (name -> fix):');
    P();
    const NAMEFIX = [
        [0x0000, 'av_waterfall_alt_idle_zone', 'av_waterfall_alt_idle_active', 'ends in `zone`, a place, not a state'],
        [0x0000, 'wa_watermia_alt_idle_zone', 'wa_watermia_alt_idle_active', 'same'],
        [0x0000, 'eu_dark_chapel_altar_alt_idle_zone', 'eu_dark_chapel_altar_alt_idle_active', 'same'],
        [0x0000, 'av_test_wind_room_alt_idle', 'av_test_wind_room_alt_idle_active', 'ends in `idle`, no state word'],
        [0x0002, 'wa_glass_game_start', 'wa_glass_game_started', 'imperative noun, not a state'],
        [0x0001, 'it_lily_house_moon_tribe_yes', 'it_lily_house_moon_tribe_yes_answered', 'ends in the answer, not the state'],
        [0x0001, 'wa_lukes_house_party_cue_and_stay_talk', 'wa_lukes_house_party_cue_given', 'two states in one name'],
        [0x0146, 'mu_bomb_wire_cut_a', 'mu_lair_gate_a_open', 'FL25 (medium): the flag is set right after both vampires die (`mu67_bomb.asm:64 {435312}`), before the wire answer; decision pending (FL25 question 1, queue FL25-06)'],
        [0x0147, 'mu_bomb_wire_cut_b', 'mu_lair_gate_b_open', 'same (`mu67_bomb.asm:65 {435316}`)'],
        [0x0020, 'sc_cave_friends_idle', '(keep, UNKNOWN)', 'states the effect only; the record says so'],
    ];
    P('| index | current name | proposed | why |');
    P('|---|---|---|---|');
    for (const [i, cur, nw, why] of NAMEFIX) {
        const ok = (reg.flags.get(i)?.meanings ?? []).some((m) => m.name === cur);
        P(`| \`$${hx(i, 4)}\` | ${cur}${ok ? '' : ' (NOT FOUND)'} | ${nw} | ${why} |`);
    }
    P();
    P('`$0146/$0147` are used by name in `specs/FL32_presets.json` (18 occurrences) and `FL32_registry.json` (2): the apply pass must rename them together if the user accepts the FL25 proposal; FL41 does not patch the name (a rename is a decision, not a gap) and does not edit those files.');
    P();
    P('**Q-E Citations.**');
    P();
    P('- Q-E1: `FL27_registry.json:5` and `FL27_20261104.md:225` cite `watermia/watermia/wa78_glass_game.asm:538 {498241}`; the tag `{498241}` is on line 539 (`STA $0AA6`), line 538 is `ORA #$0004` {498238}. Fix: `:539 {498241}`. This is the only real mismatch of the 42 files.');
    P('- Q-E6: the claim "the use gate refuses the melody when `$02` is already set" (`FL21_registry.json`, record `$0002`, scene `$11`, note) cites `item_use_system.asm:700 {232391}`, which is the `$0113` test; the `$02` test is `item_use_system.asm:701 {232398}`. Fix: patch row in `FL41_registry.json` (index `$0002`, `expectOld` `ec_doorway_melody_played_req`) adds `:701 {232398}` to the evidence and corrects the note.');
    P();
    P('**Q-F Grades.** `$0043 ec_prison_door_c_open` (UNKNOWN) has an empty `evidence`; its note holds the searches. Fix: patch row in `FL41_registry.json` sets evidence `extracted/edward_castle/castle_prison/ec0B_guard.asm:20 {318502}`. All VERIFIED-STATIC meanings carry at least one `{offset}` citation. 162 INFERRED + 2 UNKNOWN meanings; none was promoted by FL41.');
    P();
    P('**Q-G Records whose fragments disagree.** Index with different names across fragments (records and proposals), final name of the merged chain:');
    P();
    P('| index | names by fragment | final | verdict |');
    P('|---|---|---|---|');
    const VERD = { 0x138: 'open: FL41 proposal `sp_mu_passage_door_open`', 0x146: 'final is wrong: rename (Q-D)', 0x147: 'final is wrong: rename (Q-D)' };
    for (const [i, l, fin] of Q.disagree) P(`| \`$${hx(i, 4)}\` | ${l.map((x) => `${x[0]}: ${x[1]}${x[2] === 'proposal' ? ' (prop)' : ''}`).join('; ')} | ${fin || '(no record)'} | ${VERD[i] ?? 'later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix'} |`);
    P();
    P('Index reuses: `$0010` has two scoped meanings (`sc_school_lesson_done` scene `$08`, `sys_boot_logo_first_shown` scene `$FB`); D1 indices are reused by design in every scene; no other persistent index has two meanings. The 62 spine indices have one record each.');
    P();
    P('### 8.4 New queue items');
    P();
    P('See `queue/FL41_queue.json`: FL41-01 (write census over the 261 unreferenced bits and the D3 tail), FL41-02 (hazard: D3 bits `$019E-$01FF`), FL41-03 (tier-0 reads of `TestFlag_0300`), FL41-04 (read census for the dead write `$6D`).');
    P();
    // ---------------------------------------------------------------- appendix
    P('## 9. Appendix: status row per bit');
    P();
    P('Columns: index, byte.bit, domain, primary status, doc, ref, name or proposal, tags.');
    P();
    P('| index | byte.bit | dom | primary | doc | ref | name | tags |');
    P('|---|---|---|---|---|---|---|---|');
    const short = (s) => s.replace('overlaps inventory/ability/other state', 'overlaps').replace('literal COP both ways, no record', 'both, no record').replace('referenced by a direct read', 'direct read').replace('helper-only (no literal COP)', 'helper-only');
    for (const r of rows) {
        const nm = r.names.length ? r.names.map((n) => n.name).join(' / ') : r.proposals.length ? `(proposal) ${r.proposals[0]}` : '';
        const tags = r.tags.filter((t) => !t.startsWith('read by the ApplyAllEventBlocks scan') && !t.startsWith('overlaps abilityBitmask') && !t.startsWith('overlaps counter')).join('; ');
        P(`| \`$${hx(r.b, 4)}\` | \`${hx(r.byte, 4)}.${r.bit}\` | ${r.dom} | ${short(r.primary)} | ${r.doc} | ${r.ref} | ${nm} | ${tags} |`);
    }
}

// ------------------------------------------------------------------ ranked queue
function ranked() {
    const FRMAP = { FL20: 'FR20', FL21: 'FR20', FL22: 'FR21', FL23: 'FR21', FL24: 'FR22', FL25: 'FR22', FL26: 'FR23', FL27: 'FR23', FL28: 'FR24', FL29: 'FR24' };
    const AREA_FR = {
        prologue: 'FR20', south_cape: 'FR20', edward_castle: 'FR20', mansion: 'FR20', itory: 'FR21', incan_ruins: 'FR21', gold_ship: 'FR21', freejia: 'FR21',
        diamond_mine: 'FR22', great_wall: 'FR22', sky_garden: 'FR22', mountain_temple: 'FR22', seaside_palace: 'FR22', mu: 'FR22', angel_village: 'FR23', nazca: 'FR23',
        watermia: 'FR23', euro: 'FR23', native_village: 'FR24', dao: 'FR24', angkor_wat: 'FR24', pyramid: 'FR24', babel_tower: 'FR24', ending: 'FR24', system: 'FR30', unused: 'FR30',
    };
    const entryIds = new Set(['FL32-40', 'FL32-41']);
    const items = [];
    for (const q of queues) {
        const text = String(q.claim ?? '');
        const idn = parseInt(q.id.split('-')[1], 10);
        let kind = 'flag';
        if (q._iter === 'FL32' && /^Preset /.test(text)) kind = 'preset';
        else if (q._iter === 'FL32' && /^Scene entry/.test(text)) kind = 'scene-entry';
        else if (q._iter === 'FL32' && /^Milestone /.test(text)) kind = 'milestone';
        else if (/^Spine proposal/.test(text) || (q._iter === 'FL32' && idn >= 42 && idn <= 45)) kind = 'spine-proposal';
        else if (q.flag == null) kind = 'mechanism';
        const flag = typeof q.flag === 'number' ? q.flag : null;
        const gr = flag != null ? gradesOf(flag) : [];
        const worst = gr.includes('UNKNOWN') ? 'UNKNOWN' : gr.includes('INFERRED') ? 'INFERRED' : gr.includes('VERIFIED-STATIC') ? 'VERIFIED-STATIC' : 'none';
        const isSpine = flag != null && spine.has(flag);
        const entry = kind === 'scene-entry' || entryIds.has(q.id);
        // rank class
        let cls;
        if (worst === 'UNKNOWN' || isSpine || entry || q.priority === 'P0' || q.priority === 'P1') cls = 'P1';
        else if (worst === 'INFERRED' || kind === 'preset' || kind === 'milestone' || q.priority === 'P2' || (flag != null && worst === 'none')) cls = 'P2';
        else cls = 'P3';
        // an item of a still-INFERRED record is never below P2
        // sub order inside a class
        let sub = 5;
        if (q.priority === 'P0') sub = 0;
        else if (worst === 'UNKNOWN') sub = 1;
        else if (entry) sub = 2;
        else if (isSpine && worst === 'INFERRED') sub = 3;
        else if (q.priority === 'P1') sub = 3;
        else if (isSpine) sub = 4;
        // FR iteration
        let fr;
        const frNeed = (q.needs ?? []).filter((n) => /^FR\d\d$/.test(n) && n !== 'FR00');
        if (kind === 'preset') fr = 'FR50';
        else if (kind === 'scene-entry') fr = 'FR40';
        else if (kind === 'milestone') fr = idn >= 46 && idn <= 50 ? 'FR10' : 'FR50';
        else if (frNeed.length) fr = frNeed[0];
        else if (FRMAP[q._iter]) fr = FRMAP[q._iter];
        else if (['FL10', 'FL11', 'FL12', 'FL13', 'FL14', 'FL15'].includes(q._iter)) fr = 'FR30';
        else if (flag != null) {
            const ms = reg.flags.get(flag)?.meanings ?? [];
            const sc = q.scope?.scenes ?? [];
            const m = ms.find((x) => (x.scope?.scenes ?? []).some((s) => sc.includes(s))) ?? ms[0];
            fr = AREA_FR[m?.area] ?? 'FR30';
            if (flag < 16 && sc.length) { const g = groups.scenes.get(sc[0])?.group; fr = AREA_FR[g] ?? fr; }
        } else if (q.scope?.scenes?.length) fr = AREA_FR[groups.scenes.get(q.scope.scenes[0])?.group] ?? 'FR30';
        else fr = 'FR30';
        items.push({ q, kind, flag, worst, isSpine, entry, cls, sub, fr, grade_basis: gr });
    }
    // A spine flag has several items (area iteration, FL30, FL31, FL32): only the lead item of each spine flag keeps the spine
    // rule; the others fall back to the grade rules (their `lead` field names the lead item).
    const srcRank = { P0: 0, P1: 1, P2: 2, P3: 3 };
    const leadOf = new Map();
    for (const it of items.filter((x) => x.isSpine)) {
        const cur = leadOf.get(it.flag);
        const better = (a, b) => (srcRank[a.q.priority] - srcRank[b.q.priority]) || ((a.worst === 'INFERRED' ? 0 : 1) - (b.worst === 'INFERRED' ? 0 : 1)) || a.q.id.localeCompare(b.q.id, 'en', { numeric: true });
        if (!cur || better(it, cur) < 0) leadOf.set(it.flag, it);
    }
    for (const it of items) {
        if (!it.isSpine || leadOf.get(it.flag) === it) continue;
        it.lead = leadOf.get(it.flag).q.id;
        const keepP1 = it.worst === 'UNKNOWN' || it.entry || it.q.priority === 'P0' || it.q.priority === 'P1';
        if (!keepP1) {
            it.cls = it.worst === 'INFERRED' || it.kind === 'preset' || it.kind === 'milestone' || it.q.priority === 'P2' ? 'P2' : 'P3';
            it.sub = 5;
        }
    }
    const clsRank = { P1: 1, P2: 2, P3: 3 };
    items.sort((a, b) => clsRank[a.cls] - clsRank[b.cls] || a.sub - b.sub || a.q.id.localeCompare(b.q.id, 'en', { numeric: true }));
    // sample one in five of the P3 items
    let p3 = 0;
    const outItems = items.map((it, k) => {
        let sampled = true;
        let why = '';
        if (it.cls === 'P3' && it.worst === 'VERIFIED-STATIC') { sampled = p3 % 5 === 0; p3++; if (!sampled) why = 'VERIFIED-STATIC confirmation not sampled (one trial in five); runs only if a sampled trial of the same area refutes'; }
        const o = {
            rank: k + 1, id: it.q.id, fr: it.fr, priority: it.cls, source_priority: it.q.priority, kind: it.kind,
            flag: it.flag, flag_hex: it.flag != null ? H4(it.flag) : null, name: it.flag != null ? nameOf(it.flag) || null : null,
            record_grades: it.grade_basis, spine: it.isSpine, entry: it.entry, sampled,
            reason: [it.worst === 'UNKNOWN' ? 'UNKNOWN record' : '', it.isSpine ? 'spine flag' : '', it.entry ? 'scene-entry flag' : '', it.q.priority === 'P0' || it.q.priority === 'P1' ? `source ${it.q.priority}` : '', it.worst === 'INFERRED' ? 'INFERRED record' : '', it.cls === 'P3' ? 'VERIFIED-STATIC confirmation' : ''].filter(Boolean).join('; ') || 'source P2',
            claim: it.q.claim, needs: it.q.needs ?? [],
        };
        if (it.lead) o.lead_item = it.lead;
        if (why) o.deferred = why;
        return o;
    });
    // coverage proof: every INFERRED/UNKNOWN meaning has a queue id among the items that are sampled or P1/P2
    const live = new Set(outItems.filter((o) => o.sampled).map((o) => o.id));
    const missing = [];
    for (const [i, r] of reg.flags) for (const m of r.meanings) if (m.grade === 'INFERRED' || m.grade === 'UNKNOWN') {
        const ids = queueFor(i);
        if (!ids.some((x) => live.has(x))) missing.push([i, m.name]);
    }
    if (missing.length) throw new Error('INFERRED/UNKNOWN records without a live ranked item: ' + JSON.stringify(missing));
    // FL41 own items are appended by the caller of this function through the queue file (loaded in loadQueues)
    return outItems;
}

if (cmd === 'coverage') { coverage(); console.log(out.join('\n')); }
else if (cmd === 'ranked') {
    const o = ranked();
    // copied queue text keeps its meaning; the wording avoids the word the project reserves for flag bits
    const plain = (t) => t.replace(/arrival is free/g, 'arrival is not locked').replace(/a free slot/g, 'an empty slot').replace(/joypad free/g, 'joypad unlocked').replace(/does not free him/g, 'does not release him');
    console.log(plain(JSON.stringify(o, null, 2)));
} else if (cmd === 'stats') {
    const o = ranked();
    const c = {};
    for (const x of o) { c[x.priority] = (c[x.priority] ?? 0) + 1; }
    console.log('priority', c, 'sampled', o.filter((x) => x.sampled).length, 'of', o.length);
    const f = {};
    for (const x of o) if (x.sampled) f[x.fr] = (f[x.fr] ?? 0) + 1;
    console.log('FR (sampled items)', f);
    const fa = {};
    for (const x of o) fa[x.fr] = (fa[x.fr] ?? 0) + 1;
    console.log('FR (all items)', fa);
    const k = {};
    for (const x of o) k[x.kind] = (k[x.kind] ?? 0) + 1;
    console.log('kind', k);
    const Q = quality();
    console.log('quality', { dup: Q.dupNames.length, prefix: Q.prefix.length, d1Overlap: Q.d1Overlap.length, noQ: Q.noQueueField.length, noEv: Q.noEvidence.length, grades: Q.grades, disagree: Q.disagree.length });
    console.log('set-only', SET_ONLY.length, 'test-only', TEST_ONLY.length, 'spine', spine.size);
}
