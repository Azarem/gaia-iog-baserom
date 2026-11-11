#!/usr/bin/env node
// fl15_query.mjs - READ-ONLY query tool for the FL15 analysis (boss reward flags $0500-$0507 and ability flags $0510+, domain D7).
//
// This script WRITES NOTHING. It prints to stdout; the caller redirects the output into plans/flags/results/.
// It reads only:
//   rebuilt/Illusion of Gaia.smc                   (2 MB original image, no header; decimal file offsets) to decode and cross-check table rows
//   extracted/actors/boss_clear_reward_handler.asm (boss_reward_range_table rows, TestWramFlag_Offset100 / SetWramFlag_Offset100 sites)
//   extracted/system/dark_space/sE6_gaia.asm       (AbilitySceneTable, ability names)
//   extracted/tables/enemy_clear_reward_table.asm  (tier per scene, for the reward per boss range)
//   extracted/tables/scene_actors.asm              (placements of the handler, the lair actors and the Dark Space portals)
//   extracted/**/*.asm                             (scan for abilityBitmask / $0AA2 and the three flag helpers)
//   db-us/groups.json                              (scene id -> group, scene name)
//   plans/flags/inventory.json                     (FL01 inventory: helper calls)
// It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl15_query.mjs bosses     # boss index -> flag -> boss -> reward (table, ROM cross-check of the range table, lair test sites)
//   node plans/flags/tools/fl15_query.mjs abilities  # AbilitySceneTable (asm vs ROM), form / slot / flag / byte / bit / name per ability, mapping check
//   node plans/flags/tools/fl15_query.mjs darkspace  # every Dark Space portal spawn row: scene, spawn byte, variant, ability (if variant 2)
//   node plans/flags/tools/fl15_query.mjs sites      # every abilityBitmask / $0AA2 / $0AA3 / TestFlag_0510 / Offset100 site in extracted/, with line, offset and read/write
//   node plans/flags/tools/fl15_query.mjs scan       # independent absence scans (other accesses to $0AA0-$0AA3, literal COP indices 0500-051F)
import fs from 'node:fs';
import path from 'node:path';

const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const sceneInfo = new Map();
for (const [g, v] of Object.entries(groups)) for (const [name, s] of Object.entries(v.scenes)) sceneInfo.set(s.id, { group: g, prefix: v.prefix, name });
const sceneTxt = s => { const i = sceneInfo.get(s); return `$${hex(s)} ${i ? i.group + '/' + i.name : '(no scene record)'}`; };
const readLines = f => fs.readFileSync(f, 'utf8').split(/\r?\n/);

const HANDLER = 'extracted/actors/boss_clear_reward_handler.asm';
const SE6 = 'extracted/system/dark_space/sE6_gaia.asm';
const TABLE_FILE = 'extracted/tables/enemy_clear_reward_table.asm';
const ACTORS_FILE = 'extracted/tables/scene_actors.asm';
const TABLE_ROM = 109278;          // enemy_clear_reward_table, bank $01
const RANGE_ROM = 49938;           // boss_reward_range_table: the byte after the last tagged instruction of the handler (RTL at 49937), 11 rows x 4
const ACTOR_PTR_TABLE = 819200;    // scene_actors: 256 words, records in bank $0C
const ACTOR_BANK_BASE = 786432;
const TIER_NAME = ['none', 'Max HP +1', 'STR +1', 'DEF +1'];

// ---------------------------------------------------------------- scene_actors
function sceneActors() {
    const lines = readLines(ACTORS_FILE);
    const scenes = new Map();
    let cur = null;
    lines.forEach((l, i) => {
        let m = /^scene_([0-9A-F]{2})_actors \[/.exec(l);
        if (m) { cur = { scene: parseInt(m[1], 16), line: i + 1, rows: [] }; scenes.set(cur.scene, cur); return; }
        if (/^scene_default_actors \[/.test(l) || /^\]/.test(l)) { cur = null; return; }
        m = /^\s+(enemy|actor)-spawn < (.*) >\s+;([0-9A-F]+)\s*$/.exec(l);
        if (m && cur) {
            const ops = m[2].split(',').map(s => s.trim());
            const row = { kind: m[1], row: parseInt(m[3], 16), line: i + 1, x: parseInt(ops[0].slice(1), 16), y: parseInt(ops[1].slice(1), 16), attr: parseInt(ops[2].slice(1), 16), actor: ops[3].replace(/^@/, '') };
            if (m[1] === 'enemy') { row.stats = parseInt(ops[4].slice(1), 16); row.enemyNum = parseInt(ops[5].slice(1), 16); row.evt = parseInt(ops[6].slice(1), 16); }
            cur.rows.push(row);
        }
    });
    for (const [sc, S] of scenes) {
        const ptr = ROM[ACTOR_PTR_TABLE + sc * 2] | (ROM[ACTOR_PTR_TABLE + sc * 2 + 1] << 8);
        let o = ACTOR_BANK_BASE + ptr, k = 0;
        while (ROM[o] !== 0xFF) {
            const stats = ROM[o + 6];
            const r = S.rows[k];
            if (r) { r.offset = o; r.romMatch = r.x === ROM[o] && r.y === ROM[o + 1] && r.attr === ROM[o + 2] && (r.kind === 'enemy') === (stats !== 0); }
            o += stats ? 9 : 7; k++;
        }
        S.romRows = k;
    }
    return scenes;
}

function tierTable() {
    const rows = [];
    readLines(TABLE_FILE).forEach((l, i) => {
        const m = /^\s+#([0-9A-F]{2})\s+;([0-9A-F]{2})\s*$/.exec(l);
        if (m) rows.push({ scene: parseInt(m[2], 16), tier: parseInt(m[1], 16), line: i + 1, offset: TABLE_ROM + parseInt(m[2], 16) });
    });
    return rows;
}

// boss_reward_range_table rows from the asm: boss-reward-range < #scene, #first, #last >   ;NN
function rangeRows() {
    const out = [];
    readLines(HANDLER).forEach((l, i) => {
        const m = /boss-reward-range < #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}) >\s+;([0-9A-F]{2})/.exec(l);
        if (m) {
            const n = parseInt(m[4], 16);
            const o = RANGE_ROM + 4 * n;
            out.push({ n, scene: parseInt(m[1], 16), first: parseInt(m[2], 16), last: parseInt(m[3], 16), line: i + 1, offset: o, rom: [ROM[o], ROM[o + 1], ROM[o + 2], ROM[o + 3]] });
        }
    });
    return out;
}

// every call of one of the three flag helpers in extracted/, with the preceding immediate LDA (the constant index) and the {offset} tag
function walk(dir, out = []) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        if (e.isDirectory()) walk(p, out); else if (e.name.endsWith('.asm')) out.push(p.replace(/\\/g, '/'));
    }
    return out;
}
const ASM = walk('extracted');
function helperCalls() {
    const res = [];
    for (const f of ASM) {
        if (f.endsWith('system/engine/flag_helpers.asm')) continue;
        const L = readLines(f);
        L.forEach((l, i) => {
            const m = /JSL \$@flag_helpers\.(TestWramFlag_Offset100|SetWramFlag_Offset100|TestFlag_0510)\b.*?\{(\d+)\}/.exec(l);
            if (m && !/^\s*;/.test(l)) {
                let imm = null;
                for (let k = i - 1; k >= Math.max(0, i - 4); k--) { const q = /^\s*LDA #\$([0-9A-F]{4})/.exec(L[k]); if (q) { imm = parseInt(q[1], 16); break; } if (/^\s*(JSR|JSL|COP|BRA|BCC|BCS|BNE|BEQ)/.test(L[k])) break; }
                // label of the enclosing top-level block
                let label = null;
                for (let k = i; k >= 0; k--) { const q = /^([A-Za-z0-9_]+) [\[{]/.exec(L[k]); if (q) { label = q[1]; break; } }
                res.push({ file: f.replace(/^extracted\//, ''), line: i + 1, offset: parseInt(m[2], 10), helper: m[1], imm, label });
            }
        });
    }
    return res;
}

// ---------------------------------------------------------------- bosses
function cmdBosses() {
    const SA = sceneActors();
    const T = new Map(tierTable().map(r => [r.scene, r]));
    const rr = rangeRows();
    const calls = helperCalls();
    console.log('# boss_reward_range_table (handler file, data starts at ROM offset ' + RANGE_ROM + ', 4 bytes per row)');
    for (const r of rr) {
        const romOk = r.rom[0] === r.scene && r.rom[1] === r.first && r.rom[2] === r.last;
        console.log(`row ${r.n}\tscene $${hex(r.scene)}\tfirst $${hex(r.first)} last(excl) $${hex(r.last)}\tflag $${hex(0x500 + (r.n & 7), 4)} = ${0x500 + (r.n & 7)}\tbyte $0AA0 bit ${r.n & 7}\tasm:${r.line} offset ${r.offset}\t${romOk ? 'rom-ok' : 'ROM-MISMATCH ' + r.rom.map(b => hex(b)).join(' ')}`);
    }
    console.log('\n# per real row (0-4): boss scene, placements, rooms paid by the catch-up');
    for (const r of rr.filter(r => r.n < 5)) {
        const S = SA.get(r.scene);
        const boss = S.rows.filter(x => x.kind === 'enemy' && /ir29_castoth|sg55_viper|mu67_|gw8A_sand_fanger|pyDD_mummy_queen/.test(x.actor));
        const handler = S.rows.filter(x => /boss_clear_reward_handler/.test(x.actor));
        const rooms = [];
        const count = [0, 0, 0, 0];
        for (let s = r.first; s < r.last; s++) { const t = T.get(s)?.tier ?? 0; if (t) { rooms.push(s); count[Math.min(t, 3)]++; } }
        console.log(`\nrow ${r.n} ${sceneTxt(r.scene)}  flag $${hex(0x500 + r.n, 4)}`);
        console.log(`  scene list asm:${S.line}; boss rows: ${boss.map(x => `${x.actor} #${hex(x.row)} stats $${hex(x.stats)} enemy# $${hex(x.enemyNum)} evt $${hex(x.evt)} asm:${x.line} off ${x.offset}`).join('; ')}`);
        console.log(`  handler rows: ${handler.map(x => `#${hex(x.row)} attr $${hex(x.attr)} asm:${x.line} off ${x.offset} ${x.romMatch ? 'rom-ok' : 'ROM-MISMATCH'}`).join('; ')}`);
        console.log(`  rooms with a nonzero tier in [$${hex(r.first)}, $${hex(r.last)}): ${rooms.length} = Max HP ${count[1]}, STR ${count[2]}, DEF ${count[3]}; tier of the end scene $${hex(r.last)}: ${T.get(r.last)?.tier ?? '?'}`);
        console.log(`  scenes: ${rooms.map(s => '$' + hex(s)).join(' ')}`);
    }
    console.log('\n# where every placement of the handler lives (all 256 scene lists)');
    for (const [sc, S] of SA) for (const x of S.rows) if (/boss_clear_reward_handler/.test(x.actor)) console.log(`  ${sceneTxt(sc)} row #${hex(x.row)} asm:${x.line} off ${x.offset}`);
    console.log('\n# helper calls (Offset100 / 0510) found by scanning extracted/ (file:line {offset}; constant LDA before the JSL; enclosing top-level label)');
    for (const c of calls) console.log(`  ${c.helper}\t${c.file}:${c.line} {${c.offset}}\timm ${c.imm === null ? 'computed' : '$' + hex(c.imm, 4)}\tin ${c.label}`);
    console.log('\n# FL01 inventory helper calls (cross-check)');
    for (const h of inv.helper_calls.filter(h => /Offset100|_0510/.test(h.helper))) console.log(`  ${h.helper}\t${h.file}:${h.line} {${h.offset}}\tindices ${h.indices.map(i => '$' + hex(i, 4)).join(',')}\tscenes(by file placement) ${h.scenes.map(s => '$' + hex(s)).join(',')}`);
    console.log('\n# scenes that place the labels of each lair file (neo variants live in scenes $F2-$F6 and have their own entry label)');
    const lairLabels = ['ir29_castoth.ir29_castoth', 'ir29_castoth.btF2_neo_castoth', 'sg55_viper.sg55_viper', 'sg55_viper.btF3_neo_viper', 'mu67_vampires.mu67_male_vampire', 'mu67_vampires.mu67_female_vampire', 'mu67_vampires.btF4_neo_male_vampire', 'mu67_vampires.btF4_neo_female_vampire', 'gw8A_sand_fanger.gw8A_sand_fanger', 'gw8A_sand_fanger.btF5_neo_fanger', 'pyDD_mummy_queen.pyDD_mummy_queen', 'pyDD_mummy_queen.btF6_neo_queen'];
    for (const lab of lairLabels) {
        const where = [];
        for (const [sc, S] of SA) for (const x of S.rows) if (x.actor === lab) where.push(`$${hex(sc)}#${hex(x.row)}`);
        console.log(`  ${lab}: ${where.join(' ') || '(not placed)'}`);
    }
}

// ---------------------------------------------------------------- abilities
function abilityTableAsm() {
    const L = readLines(SE6);
    for (let i = 0; i < L.length; i++) {
        const m = /^AbilitySceneTable #([0-9A-F]+)\s*$/.exec(L[i]);
        if (m) { const bytes = m[1].match(/../g).map(h => parseInt(h, 16)); return { line: i + 1, bytes }; }
    }
    return null;
}
function abilityNames() {
    const L = readLines(SE6);
    const names = [];
    const tbl = [];
    let inTbl = false;
    for (const l of L) {
        if (/^table_08EB8F \[/.test(l)) { inTbl = true; continue; }
        if (inTbl && /^\]/.test(l)) inTbl = false;
        const m = /^\s+&(dialogstring_[0-9A-F]+)\s+;([0-9A-F]+)/.exec(l);
        if (inTbl && m) tbl.push(m[1]);
    }
    for (const lab of tbl) { const q = L.find(l => l.startsWith(lab + ' `')); names.push(q ? q.replace(/^[^`]*`/, '').replace(/`$/, '') : '?'); }
    return names;
}
function cmdAbilities() {
    const t = abilityTableAsm();
    // offset of the table: LookupAbilityForm ends with RTS {584537}; the table follows (14 bytes)
    const off = 584538;
    const rom = [...ROM.subarray(off, off + t.bytes.length)];
    console.log(`AbilitySceneTable asm:${t.line} bytes ${t.bytes.map(b => hex(b)).join(' ')}`);
    console.log(`AbilitySceneTable rom@${off}: ${rom.map(b => hex(b)).join(' ')} ${rom.every((b, i) => b === t.bytes[i]) ? 'rom-ok' : 'ROM-MISMATCH'}`);
    const names = abilityNames();
    console.log('names (table_08EB8F by table position):', names.join(' | '));
    console.log('\nentry\tsource scene\tbit\tform\tslot\tflag\tbyte.bit\tname (sE6 dialog)\tstatus-tab row/name index (form*4+slot+1)');
    for (let i = 0; i * 2 < t.bytes.length; i++) {
        const sc = t.bytes[i * 2], bit = t.bytes[i * 2 + 1];
        if (!sc) break;
        const k = Math.log2(bit);
        const form = k >> 2, slot = k & 3;
        const flag = 0x510 + k;
        console.log(`${i}\t${sceneTxt(sc)}\t$${hex(bit)}\t${['Will', 'Freedan', 'Shadow'][form]}\t${slot}\t$${hex(flag, 4)} = ${flag}\t$${hex(0xA00 + (flag >> 3), 4)} bit ${flag & 7}\t${names[i]}\tindex ${form * 4 + slot + 1}`);
    }
    console.log('\nflags in use by TestAbilityFlag (inventory trace inventory_ability_flags):', JSON.stringify(inv.traces.find(t => t.id === 'inventory_ability_flags')?.candidate_indices ?? inv.traces['14']?.candidate_indices));
    console.log('all 16 bits of the word $0AA2:');
    for (let k = 0; k < 16; k++) {
        const form = k >> 2, slot = k & 3, bit = 1 << (k & 7), byte = 0xAA2 + (k >> 3);
        const inTable = (() => { for (let i = 0; i * 2 < t.bytes.length; i++) if (t.bytes[i * 2] && t.bytes[i * 2 + 1] === bit && (k >> 3) === 0) return true; return false; })();
        console.log(`  flag $${hex(0x510 + k, 4)}\tbyte $${hex(byte, 4)} bit ${k & 7} (mask $${hex(bit)})\tform ${['Will', 'Freedan', 'Shadow', 'form 3'][form]} slot ${slot}\t${inTable ? 'in AbilitySceneTable' : 'not in AbilitySceneTable'}`);
    }
}

// ---------------------------------------------------------------- dark space portals
function cmdDarkSpace() {
    const SA = sceneActors();
    const t = abilityTableAsm();
    const names = abilityNames();
    const abil = new Map();
    for (let i = 0; i * 2 < t.bytes.length && t.bytes[i * 2]; i++) abil.set(t.bytes[i * 2], { bit: t.bytes[i * 2 + 1], name: names[i], idx: i });
    console.log('scene\tlist row\tactor\tspawn byte\tvariant (byte >> 1)\tability table entry\tasm:line\trom offset');
    let n = 0, v2 = 0;
    for (const [sc, S] of SA) for (const x of S.rows) {
        if (!/^dark_space(\.dark_space2?)?$/.test(x.actor) && !/dark_space\.dark_space/.test(x.actor)) continue;
        n++;
        const variant = x.attr & 1 ? x.attr >> 1 : null;
        if (variant === 2) v2++;
        const a = abil.get(sc);
        console.log(`${sceneTxt(sc)}\t#${hex(x.row)}\t${x.actor}\t$${hex(x.attr)}\t${variant}\t${a ? `$${hex(a.bit)} ${a.name}` : '-'}\tasm:${x.line}\t${x.offset}${x.romMatch ? '' : ' ROM-MISMATCH'}`);
    }
    console.log(`# ${n} portal rows (dark_space / dark_space2), ${v2} with variant 2 (the ability layout)`);
    console.log('# direct spawners of DarkSpacePortalInit (variant set in the script): dm40_hidden_dark_space (1), ec12_aqueduct_dark_space (1), gw88_tomb_dark_space (1), pyCC_dark_space_portal (1 for $0E = $72, otherwise 3): none sets 2');
}

// ---------------------------------------------------------------- sites
function cmdSites() {
    const pat = /\$abilityBitmask|\$0AA[0-3]\b|\$7E0AA[0-3]\b|\$000AA[0-3]\b/;
    for (const f of ASM) {
        const L = readLines(f);
        L.forEach((l, i) => {
            if (/^\s*;/.test(l) || !pat.test(l.replace(/\s;.*$/, ''))) return;   // test the instruction text only, not the trailing comment
            const m = /^\s*([A-Z]{3})\s+(\S.*?)\s*;\s*\{(\d+)\}/.exec(l);
            if (!m) { if (/^\s*[A-Z]{3}\s/.test(l)) console.log(`${f.replace(/^extracted\//, '')}:${i + 1}\t(no tag)\t${l.trim()}`); return; }
            const rw = /^(STA|STX|STY|STZ|TSB|TRB|INC|DEC|ASL|LSR|ROL|ROR)$/.test(m[1]) ? 'write' : /^(ORA|AND|EOR|ADC|SBC|CMP|BIT)$/.test(m[1]) ? 'read' : /^(LDA|LDX|LDY)$/.test(m[1]) ? 'read' : '?';
            console.log(`${f.replace(/^extracted\//, '')}:${i + 1}\t{${m[3]}}\t${m[1]} ${m[2]}\t${rw}`);
        });
    }
}

// ---------------------------------------------------------------- scan (absence searches)
function cmdScan() {
    console.log('# 1. every instruction line that names an address $0AA0-$0AA5 or a long form (any addressing mode), comments excluded');
    const re = /(\$|#\$)(00|7E|7F)?0AA[0-5]\b|\$abilityBitmask\b/;
    const hits = [];
    for (const f of ASM) readLines(f).forEach((l, i) => { if (!/^\s*;/.test(l) && re.test(l.replace(/\s;.*$/, '')) && /^\s*[A-Z]{3}\s/.test(l)) hits.push(`${f.replace(/^extracted\//, '')}:${i + 1}: ${l.trim().slice(0, 110)}`); });
    const by = {};
    for (const h of hits) { const m = /0AA[0-5]/.exec(h)?.[0] ?? 'abilityBitmask (symbol = $0AA2)'; (by[m] = by[m] || []).push(h); }
    for (const k of Object.keys(by).sort()) console.log('  ' + (/^0AA/.test(k) ? '$' : '') + k + ': ' + by[k].length + ' lines');
    for (const h of hits.filter(h => !/abilityBitmask/.test(h) && !/0AA2/.test(h))) console.log('  ' + h);
    console.log('\n# 2. literal COP flag operands in $0500-$051F (byte and word forms), from the FL01 inventory and a text scan');
    const inInv = inv.sites.filter(s => s.kind === 'cop' && s.index >= 0x500 && s.index <= 0x5FF);
    console.log(`  inventory COP sites with index 0500-05FF: ${inInv.length}`);
    let txt = 0;
    for (const f of ASM) readLines(f).forEach(l => { if (/COP \[(Set|Clear|BranchOn|WaitOn)FlagWord\] \( #\$05[0-9A-F]{2}\b/.test(l)) txt++; });
    console.log(`  text scan, Flag...Word operands #$05xx: ${txt}`);
    console.log('\n# 3. scene-meta gates with index >= $0500: ' + inv.sites.filter(s => s.kind === 'scene_gate' && s.index >= 0x500).length);
    console.log('\n# 4. direct accesses of the inventory in $0AA0-$0AA5 by address');
    const dd = {};
    for (const d of inv.direct_accesses) if (d.address >= 0xAA0 && d.address <= 0xAA5) { const k = d.addressHex + ' ' + (d.symbol ?? ''); dd[k] = (dd[k] ?? 0) + 1; }
    console.log('  ' + JSON.stringify(dd));
    console.log('\n# 5. callers of ClearAllWramFlags / inline clears of wramFlags (range check: bytes $0A80-$0A9F only)');
    for (const h of inv.helper_calls.filter(h => /ClearAllWramFlags/.test(h.helper))) console.log(`  ${h.helper}\t${h.file}:${h.line} {${h.offset}}`);
    for (const d of inv.direct_accesses.filter(d => d.flagSymbol && /wramFlags/.test(d.operands) && d.access === 'write')) console.log(`  direct write ${d.file}:${d.line} {${d.offset}} ${d.opcode} ${d.operands}`);
}

const cmd = process.argv[2];
if (cmd === 'bosses') cmdBosses();
else if (cmd === 'abilities') cmdAbilities();
else if (cmd === 'darkspace') cmdDarkSpace();
else if (cmd === 'sites') cmdSites();
else if (cmd === 'scan') cmdScan();
else { console.error('usage: fl15_query.mjs bosses|abilities|darkspace|sites|scan'); process.exit(1); }
