#!/usr/bin/env node
// fl12_query.mjs - READ-ONLY query and builder for the FL12 analysis (chests, hidden Red Jewels, domain D4 $0200-$02FF).
//
// This script WRITES NOTHING. It prints to stdout; the caller redirects the output into plans/flags/results/.
// It reads only:
//   rebuilt/Illusion of Gaia.smc            (2 MB original image, no header; offsets are decimal file offsets) to decode and cross-check the table rows
//   extracted/tables/scene_chest_table.asm  (chest lists: file:line of every record)
//   extracted/tables/scene_actors.asm       (hidden_red_jewel placements: file:line)
//   extracted/tables/system_strings.asm     (item_name_table text)
//   db-us/groups.json                       (scene id -> group, scene name, prefix)
//   plans/flags/inventory.json              (FL01 inventory: helper calls, literal COP sites, direct accesses)
//   notes/comments/bank02.json, bank03.json (stored inline comments, read-only, for the contradiction checks)
// It never touches extracted/, db-us/, notes/, docs/ or src/.
//
// Usage (repo root):
//   node plans/flags/tools/fl12_query.mjs chests        # one row per chest record: scene, tile, item, flag, fanfare, offset, file:line
//   node plans/flags/tools/fl12_query.mjs jewels        # one row per hidden_red_jewel placement: scene, tile, attribute, $0E, flag, offset, file:line
//   node plans/flags/tools/fl12_query.mjs verify        # cross-check: asm rows vs ROM bytes (chest lists and scene_actors rows), note-table check, counts
//   node plans/flags/tools/fl12_query.mjs gaps          # indices of $0200-$02FF that no table or actor can reach, and the searches over the inventory
//   node plans/flags/tools/fl12_query.mjs reach         # per chest/jewel scene: scene_warps destination count and literal QueueMapChange operands (partial reachability hint)
//   node plans/flags/tools/fl12_query.mjs notecheck     # the CONTENT table of the scene_chest_table block note against the decoded rows (prints mismatches)
//   node plans/flags/tools/fl12_query.mjs tables        # the two markdown tables of the report
//   node plans/flags/tools/fl12_query.mjs registry      # FL12 registry fragment (JSON)
//   node plans/flags/tools/fl12_query.mjs queue         # FL12 runtime queue (JSON)
import fs from 'node:fs';

const ROM = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
const groups = JSON.parse(fs.readFileSync('db-us/groups.json', 'utf8'));
const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const sceneInfo = new Map();
for (const [g, v] of Object.entries(groups)) for (const [name, s] of Object.entries(v.scenes)) sceneInfo.set(s.id, { group: g, prefix: v.prefix, name, description: s.description });

const CHEST_FILE = 'extracted/tables/scene_chest_table.asm';
const ACTORS_FILE = 'extracted/tables/scene_actors.asm';
const PTR_TABLE = 109992;            // scene_chest_table: 255 words
const HJ_LABEL = 'hidden_red_jewel';
const ACTOR_PTR_TABLE = 819200;      // scene_actors: 256 words, records in bank $0C
const ACTOR_BANK_BASE = 786432;      // 0xC0000

// ---------------------------------------------------------------- items
function itemNames() {
    const lines = fs.readFileSync('extracted/tables/system_strings.asm', 'utf8').split(/\r?\n/);
    const text = new Map();
    for (const l of lines) { const m = /^consolestring_([0-9A-F]{6}) \|(.*)\|\s*$/.exec(l); if (m) text.set(m[1], m[2]); }
    const names = new Map();
    let inTable = false;
    for (const l of lines) {
        if (/^item_name_table \[/.test(l)) { inTable = true; continue; }
        if (inTable && /^\]/.test(l)) break;
        const m = inTable && /^\s+&consolestring_([0-9A-F]{6})\s+;([0-9A-F]{2})/.exec(l);
        if (m) {
            const t = (text.get(m[1]) ?? '?').replace(/\[N\]/g, ' ').replace(/\[LU:C\]/g, 'Statue').replace(/\s+/g, ' ').trim();
            names.set(parseInt(m[2], 16), t);
        }
    }
    return names;
}
const ITEMS = itemNames();
const itemName = id => (id === 0 ? 'flag only (shows "It is empty!")' : ITEMS.get(id) ?? '?');

// ---------------------------------------------------------------- chest table
function parseChestAsm() {
    const lines = fs.readFileSync(CHEST_FILE, 'utf8').split(/\r?\n/);
    const ptr = new Map();     // scene -> list label
    const lists = new Map();   // label -> { records: [{x,y,item,flagByte,line}], line }
    let cur = null;
    lines.forEach((l, i) => {
        let m = /^\s+&(chest_list_\w+)\s+;([0-9A-F]{2})\s*$/.exec(l);
        if (m) { ptr.set(parseInt(m[2], 16), m[1]); return; }
        m = /^(chest_list_\w+) \[/.exec(l);
        if (m) { cur = { label: m[1], line: i + 1, records: [] }; lists.set(m[1], cur); return; }
        if (/^\]/.test(l)) { cur = null; return; }
        m = /^\s+chest-entry < #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}) >/.exec(l);
        if (m && cur) cur.records.push({ x: parseInt(m[1], 16), y: parseInt(m[2], 16), item: parseInt(m[3], 16), flagByte: parseInt(m[4], 16), line: i + 1 });
    });
    // offsets: pointer table, shared empty list ($FF), then the lists in asm order, each followed by one $FF
    let cursor = PTR_TABLE + 255 * 2;
    const order = [...lists.keys()];
    for (const label of order) {
        const L = lists.get(label);
        L.start = cursor;
        L.records.forEach((r, k) => { r.offset = cursor + 4 * k; });
        cursor += 4 * L.records.length + 1;
    }
    return { ptr, lists, end: cursor };
}
const CH = parseChestAsm();

function chestRows() {
    const rows = [];
    for (const [scene, label] of [...CH.ptr.entries()].sort((a, b) => a[0] - b[0])) {
        if (label === 'chest_list_none') continue;
        const L = CH.lists.get(label);
        L.records.forEach((r, k) => {
            const flag = r.flagByte & 0x7F;
            rows.push({
                scene, label, rec: k, ...r, flag, global: 0x200 + flag, fanfare: !!(r.flagByte & 0x80),
                itemName: itemName(r.item), si: sceneInfo.get(scene),
            });
        });
    }
    return rows;
}

// ---------------------------------------------------------------- hidden jewels (scene_actors)
function jewelRows() {
    const lines = fs.readFileSync(ACTORS_FILE, 'utf8').split(/\r?\n/);
    const out = [];
    let scene = null, idx = 0; const sceneRows = new Map();
    lines.forEach((l, i) => {
        let m = /^scene_([0-9A-F]{2})_actors \[/.exec(l);
        if (m) { scene = parseInt(m[1], 16); return; }
        if (/^scene_default_actors \[/.test(l)) { scene = null; return; }
        if (/^\]/.test(l)) { scene = null; return; }
        m = /^\s+(enemy|actor)-spawn < (.*) >\s+;([0-9A-F]+)\s*$/.exec(l);
        if (m && scene !== null) {
            const ops = m[2].split(',').map(s => s.trim());
            if (ops[3] === '@' + HJ_LABEL) {
                const x = parseInt(ops[0].slice(1), 16), y = parseInt(ops[1].slice(1), 16), attr = parseInt(ops[2].slice(1), 16);
                out.push({ scene, row: parseInt(m[3], 16), line: i + 1, x, y, attr, kind: m[1] });
            }
        }
    });
    // decode the ROM rows: walk each scene record; match by scene + row index
    const romRows = new Map();
    for (let sc = 0; sc < 256; sc++) {
        const ptr = ROM[ACTOR_PTR_TABLE + sc * 2] | (ROM[ACTOR_PTR_TABLE + sc * 2 + 1] << 8);
        let o = ACTOR_BANK_BASE + ptr, k = 0;
        while (ROM[o] !== 0xFF) {
            const stats = ROM[o + 6];
            romRows.set(sc + ':' + k, { offset: o, x: ROM[o], y: ROM[o + 1], attr: ROM[o + 2], code: ROM[o + 3] | (ROM[o + 4] << 8) | (ROM[o + 5] << 16), stats });
            o += stats ? 9 : 7; k++;
        }
    }
    for (const r of out) {
        const R = romRows.get(r.scene + ':' + r.row);
        r.rom = R;
        r.offset = R ? R.offset : null;
        r.romMatch = !!R && R.x === r.x && R.y === r.y && R.attr === r.attr && R.stats === 0;
        r.param = r.attr >> 1;                    // InitActorFromSceneData, attribute bit 0 set: $0E = byte >> 1
        r.mode1 = (r.attr & 1) === 1;
        r.flag = 0x80 + r.param;                  // HiddenRedJewelInteract: A = $0E + $80, base $0200
        r.global = 0x200 + r.flag;
        r.si = sceneInfo.get(r.scene);
    }
    return out.sort((a, b) => a.param - b.param);
}

// ---------------------------------------------------------------- output helpers
const sceneTxt = s => { const i = sceneInfo.get(s); return `$${hex(s)} ${i ? i.group + '/' + i.name : '?'}`; };

function printChests() {
    for (const r of chestRows()) {
        console.log([`$${hex(r.scene)}`, `${r.si.group}/${r.si.name}`, `rec ${r.rec}`, `(${hex(r.x)},${hex(r.y)})`, `item $${hex(r.item)} ${r.itemName}`, `flagbyte $${hex(r.flagByte)}`, `global $${hex(r.global, 4)} (${r.global})`, r.fanfare ? 'fanfare' : 'plain', `byte $${hex(0xA00 + (r.global >> 3), 4)} bit ${r.global & 7}`, `offset ${r.offset}`, `asm:${r.line}`].join('\t'));
    }
}
function printJewels() {
    for (const r of jewelRows()) {
        console.log([`$${hex(r.scene)}`, `${r.si.group}/${r.si.name}`, `row #${hex(r.row)}`, `(${hex(r.x)},${hex(r.y)})`, `attr $${hex(r.attr)}`, `$0E ${hex(r.param, 1)}`, `flag $${hex(r.global, 4)} (${r.global})`, `byte $${hex(0xA00 + (r.global >> 3), 4)} bit ${r.global & 7}`, `offset ${r.offset}`, `asm:${r.line}`, r.romMatch ? 'rom-ok' : 'ROM-MISMATCH'].join('\t'));
    }
}

function verify() {
    const rows = chestRows();
    let bad = 0;
    // pointer table in ROM vs asm
    for (let sc = 0; sc < 255; sc++) {
        const w = ROM[PTR_TABLE + sc * 2] | (ROM[PTR_TABLE + sc * 2 + 1] << 8);
        const label = CH.ptr.get(sc);
        const L = label === 'chest_list_none' ? null : CH.lists.get(label);
        const expect = label === 'chest_list_none' ? ((PTR_TABLE + 510) & 0xFFFF) : (L.start & 0xFFFF);
        if (w !== expect) { bad++; console.log(`pointer mismatch scene ${hex(sc)}: rom ${hex(w, 4)} asm ${hex(expect, 4)}`); }
    }
    for (const r of rows) {
        const o = r.offset;
        if (ROM[o] !== r.x || ROM[o + 1] !== r.y || ROM[o + 2] !== r.item || ROM[o + 3] !== r.flagByte) { bad++; console.log(`record mismatch scene ${hex(r.scene)} rec ${r.rec} at ${o}`); }
    }
    // terminators
    for (const L of CH.lists.values()) { const t = L.start + 4 * L.records.length; if (ROM[t] !== 0xFF) { bad++; console.log(`terminator missing after ${L.label} at ${t}`); } }
    console.log(`chest table: asm end offset ${CH.end} (expected ${PTR_TABLE + 734}); ${rows.length} records in ${new Set(rows.map(r => r.scene)).size} scenes; ROM mismatches ${bad}`);
    const flags = rows.map(r => r.flag).sort((a, b) => a - b);
    const dup = flags.filter((f, i) => flags.indexOf(f) !== i);
    console.log(`distinct chest flags ${new Set(flags).size}, min ${hex(flags[0])}, max ${hex(flags[flags.length - 1])}, duplicates ${dup.length ? dup.map(hex).join(',') : 'none'}`);
    console.log(`items: ` + [...rows.reduce((m, r) => m.set(r.itemName, (m.get(r.itemName) ?? 0) + 1), new Map())].map(([k, v]) => `${k} ${v}`).join(', '));
    console.log(`fanfare records ${rows.filter(r => r.fanfare).length}; fanfare on Herb/Red Jewel/flag-only: ${rows.filter(r => r.fanfare && [0, 1, 6].includes(r.item)).length}; non-fanfare items other than Herb/Red Jewel/flag-only: ${rows.filter(r => !r.fanfare && ![0, 1, 6].includes(r.item)).length}`);
    console.log(`flag-only chests: ${rows.filter(r => r.item === 0).map(r => `scene $${hex(r.scene)} flag $${hex(r.flag)}`).join('; ')}`);
    const jw = jewelRows();
    console.log(`hidden jewels: ${jw.length} placements in ${new Set(jw.map(r => r.scene)).size} scenes; ROM rows matched ${jw.filter(r => r.romMatch).length}; attribute bit 0 set on ${jw.filter(r => r.mode1).length}; params ${jw.map(r => hex(r.param, 1)).join('')}`);
    console.log(`jewel flags $${hex(Math.min(...jw.map(r => r.global)), 4)}-$${hex(Math.max(...jw.map(r => r.global)), 4)}; overlap with chest flags: ${jw.filter(j => rows.some(c => c.global === j.global)).length}`);
    // actor-def pointer of the jewel rows in ROM: all the same code pointer
    console.log(`jewel actor pointer in ROM: ${[...new Set(jw.map(r => hex(r.rom.code, 6)))].join(',')}`);
    // scenes: chest scenes that also hold a jewel
    console.log(`scenes with both a chest and a hidden jewel: ${jw.filter(j => rows.some(c => c.scene === j.scene)).map(j => hex(j.scene)).join(',') || 'none'}`);
}

function gaps() {
    const chest = chestRows(), jw = jewelRows();
    const used = new Set([...chest.map(r => r.global), ...jw.map(r => r.global)]);
    const un = [];
    for (let n = 0x200; n <= 0x2FF; n++) if (!used.has(n)) un.push(n);
    const ranges = [];
    for (const n of un) { const l = ranges[ranges.length - 1]; if (l && l[1] === n - 1) l[1] = n; else ranges.push([n, n]); }
    console.log(`referenced indices: ${used.size} (chest ${chest.length}, jewel ${jw.length}); unreferenced: ${un.length}`);
    console.log(ranges.map(([a, b]) => a === b ? `$${hex(a, 4)}` : `$${hex(a, 4)}-$${hex(b, 4)} (${b - a + 1})`).join('  '));
    // bytes
    const bytes = new Map();
    for (const n of used) bytes.set(0xA00 + (n >> 3), (bytes.get(0xA00 + (n >> 3)) ?? 0) | (1 << (n & 7)));
    console.log('bytes in use: ' + [...bytes.entries()].sort((a, b) => a[0] - b[0]).map(([a, m]) => `$${hex(a, 4)}=mask $${hex(m)}`).join(' '));
    // inventory searches (scope: plans/flags/inventory.json built from extracted/, 909 .asm)
    const lit = inv.sites.filter(s => s.index !== undefined && s.index >= 0x200 && s.index <= 0x2FF);
    console.log(`inventory sites (COP literal byte/word, helper calls, scene gates) with index $0200-$02FF: ${lit.filter(s => s.kind === 'cop').length} COP; helper-call rows: ${lit.filter(s => s.kind === 'helper_call').length}`);
    const hc = inv.helper_calls.filter(h => /_0200$/.test(h.helper));
    console.log(`helper calls with an _0200 wrapper: ${hc.length}: ` + hc.map(h => `${h.file}:${h.line} ${h.helper} {${h.offset}}`).join('; '));
    const other = inv.helper_calls.filter(h => (h.indices ?? []).some(i => i >= 0x200 && i <= 0x2FF) && !/_0200$/.test(h.helper));
    console.log(`other helper calls whose candidate set touches $0200-$02FF: ${other.length}`);
    const da = inv.direct_accesses.filter(d => d.address >= 0xA40 && d.address <= 0xA5F);
    console.log(`direct_accesses with an address in $0A40-$0A5F: ${da.length}`);
    const sc = inv.sites.filter(s => s.kind === 'scene_gate' && s.index >= 0x200);
    console.log(`scene_meta gates with index >= $0200: ${sc.length} (gates use TestFlagRaw: byte index, max $FF)`);
}

// scenes named as destination: scene_warps entries (ROM decode, 12-byte scene-warps until a byte 0 with bit 7) and literal COP QueueMapChange first operands (asm scan).
// Other routes (the world-map exit table, game-over reload, scene_meta, SpawnAfter chains) are NOT searched: "not named" is not "unreachable".
function destinations() {
    const warp = new Map(), qmc = new Map();
    for (let sc = 0; sc < 255; sc++) {
        const w = ROM[98868 + sc * 2] | (ROM[98868 + sc * 2 + 1] << 8);
        let o = 65536 + w;
        while (ROM[o] < 0x80) { const d = ROM[o + 4]; (warp.get(d) ?? warp.set(d, []).get(d)).push(sc); o += 12; }
    }
    const walk = d => fs.readdirSync(d, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(d + '/' + e.name) : e.name.endsWith('.asm') ? [d + '/' + e.name] : []);
    for (const f of walk('extracted')) {
        fs.readFileSync(f, 'utf8').split(/\r?\n/).forEach((l, i) => {
            const m = /COP \[QueueMapChange\] \( #([0-9A-F]{2}),/.exec(l.split(';')[0]);
            if (m) { const d = parseInt(m[1], 16); (qmc.get(d) ?? qmc.set(d, []).get(d)).push(`${f.replace('extracted/', '')}:${i + 1}`); }
        });
    }
    return { warp, qmc };
}
function reach() {
    const { warp, qmc } = destinations();
    const scenes = [...new Set([...chestRows().map(r => r.scene), ...jewelRows().map(r => r.scene)])].sort((a, b) => a - b);
    for (const s of scenes) {
        const w = warp.get(s) ?? [], q = qmc.get(s) ?? [];
        console.log(`$${hex(s)} ${sceneInfo.get(s).group}/${sceneInfo.get(s).name}\twarp destination of ${w.length} entries (from scenes ${[...new Set(w)].map(x => hex(x)).join(',') || '-'})\tQueueMapChange literal ${q.length}${q.length ? ' (' + q.slice(0, 2).join(', ') + ')' : ''}`);
    }
}

function tables() {
    console.log('| Scene | Group / name | Rec | Chest tile (x,y) | Contents | Global flag | Byte / bit | Fanfare | Offset | Row |');
    console.log('|---|---|---|---|---|---|---|---|---|---|');
    for (const r of chestRows()) {
        const contents = r.item === 0 ? 'flag only ("It is empty!")' : `$${hex(r.item)} ${r.itemName}`;
        console.log(`| $${hex(r.scene)} | ${r.si.group}/${r.si.name} | ${r.rec} | (${hex(r.x)},${hex(r.y)}) | ${contents} | $${hex(r.global, 4)} | $${hex(0xA00 + (r.global >> 3), 4)} bit ${r.global & 7} | ${r.fanfare ? 'yes' : 'no'} | ${r.offset} | scene_chest_table.asm:${r.line} |`);
    }
    console.log('');
    console.log('| Scene | Group / name | Row | Tile (x,y) | Attribute | Jewel number ($0E) | Global flag | Byte / bit | Offset | Row |');
    console.log('|---|---|---|---|---|---|---|---|---|---|');
    for (const r of jewelRows()) {
        console.log(`| $${hex(r.scene)} | ${r.si.group}/${r.si.name} | #${hex(r.row)} | (${hex(r.x)},${hex(r.y)}) | $${hex(r.attr)} | ${hex(r.param, 1)} | $${hex(r.global, 4)} | $${hex(0xA00 + (r.global >> 3), 4)} bit ${r.global & 7} | ${r.offset} | scene_actors.asm:${r.line} |`);
    }
}

function notecheck() {
    const lines = fs.readFileSync(CHEST_FILE, 'utf8').split(/\r?\n/);
    const rows = chestRows();
    // parse the block note CONTENT table: "| $0E | 04,1A -> Herb, $01 |", "| $A4, $A6, $A7 | 12,0B / 05,08 / 22,10 -> Mushroom Drop, $20 / $21 / $22 F |"
    const claims = [];
    for (const l of lines) {
        const m = /^; \| ((?:\$[0-9A-F]{2}(?:, )?)+) \| (.*) \|$/.exec(l);
        if (!m || /^; \| Scene/.test(l)) continue;
        const scenes = m[1].split(',').map(s => parseInt(s.trim().slice(1), 16));
        const body = m[2];
        if (scenes.length === 1) {
            for (const part of body.split('; ')) {
                const mm = /^([0-9A-F]{2}),([0-9A-F]{2}) -> (.*), \$([0-9A-F]{2})( F)?$/.exec(part.trim());
                const mf = /^([0-9A-F]{2}),([0-9A-F]{2}) -> flag only, \$([0-9A-F]{2})$/.exec(part.trim());
                if (mm) claims.push({ scene: scenes[0], x: parseInt(mm[1], 16), y: parseInt(mm[2], 16), item: mm[3].replace(/ \(\$[0-9A-F]+\)/, ''), flag: parseInt(mm[4], 16), fanfare: !!mm[5], raw: l });
                else if (mf) claims.push({ scene: scenes[0], x: parseInt(mf[1], 16), y: parseInt(mf[2], 16), item: 'flag only', flag: parseInt(mf[3], 16), fanfare: false, raw: l });
                else console.log('unparsed single-scene row: ' + part);
            }
        } else {
            const mm = /^(.*) -> (.*), (.*)$/.exec(body);
            const pos = mm[1].split(' / '), flags = mm[3].split(' / ').map(s => s.trim());
            scenes.forEach((s, k) => {
                const fm = /^\$([0-9A-F]{2})( F)?$/.exec(flags[k] ?? flags[0]);
                const [x, y] = pos[k].split(',').map(v => parseInt(v, 16));
                claims.push({ scene: s, x, y, item: mm[2], flag: parseInt(fm[1], 16), fanfare: !!fm[2], raw: l });
            });
        }
    }
    let bad = 0;
    for (const c of claims) {
        const r = rows.find(r => r.scene === c.scene && r.x === c.x && r.y === c.y);
        if (!r) { bad++; console.log(`note claims a chest at scene $${hex(c.scene)} (${hex(c.x)},${hex(c.y)}) that the table does not have`); continue; }
        const nm = r.itemName.replace(/^flag only.*/, 'flag only');
        if (nm !== c.item || r.flag !== c.flag || r.fanfare !== c.fanfare) { bad++; console.log(`MISMATCH scene $${hex(c.scene)} (${hex(c.x)},${hex(c.y)}): note ${c.item} $${hex(c.flag)}${c.fanfare ? ' F' : ''}; table ${nm} $${hex(r.flag)}${r.fanfare ? ' F' : ''}`); }
    }
    const missing = rows.filter(r => !claims.some(c => c.scene === r.scene && c.x === r.x && c.y === r.y));
    for (const r of missing) { bad++; console.log(`table record not in the note: scene $${hex(r.scene)} (${hex(r.x)},${hex(r.y)})`); }
    console.log(`note claims ${claims.length}, table records ${rows.length}, mismatches ${bad}`);
}

// ---------------------------------------------------------------- registry / queue
const snake = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
const WARPS = 'extracted/system/engine/warps_interaction.asm';
const RADAR = 'extracted/system/engine/radar_map_screen.asm';
const EVID = {
    chestTest: [`${WARPS}:169 {173575}`, `${RADAR}:277 {230045}`, 'extracted/system/engine/scene_lifecycle.asm:866 {253489}', 'extracted/system/inventory/inventory_overlay.asm:233 {192115}'],
    chestSetItem: `${WARPS}:405 {173994}`,
    chestSetEmpty: `${WARPS}:362 {173901}`,
    jewelTest: 'extracted/actors/hidden_red_jewel.asm:65 {50823}',
    jewelSet: 'extracted/actors/hidden_red_jewel.asm:72 {50844}',
};

function chestName(r) {
    const item = r.item === 0 ? 'empty' : snake(r.itemName);
    return `${r.si.prefix}_${snake(r.si.name)}_${item}_chest_opened`;
}
function jewelName(r) { return `${r.si.prefix}_${snake(r.si.name)}_hidden_jewel_taken`; }

function buildRegistry() {
    const flags = {};
    const names = new Set();
    for (const r of chestRows()) {
        const name = chestName(r);
        if (names.has(name)) throw new Error('duplicate name ' + name);
        names.add(name);
        const what = r.item === 0 ? 'a flag-only chest (it shows "It is empty!" and grants nothing)' : `the ${r.itemName} chest`;
        const where = `scene $${hex(r.scene)} (${r.si.name}) at tile (${hex(r.x)},${hex(r.y)})`;
        flags[r.global] = {
            domain: 'D4',
            meanings: [{
                scope: null, name, area: r.si.group,
                summary: `${what[0].toUpperCase()}${what.slice(1)} of ${where} has been opened.`,
                kinds: ['reward-claimed'],
                grade: 'VERIFIED-STATIC',
                effects: {
                    set: `PlaceOpenedChestTiles draws the opened 2x2 pattern ($FE/$FF over $FC/$FD) at the record position on every scene build and inventory close; HandleChestInteraction does not trigger because the tile in front is no longer $F8/$F9, and the radar map omits the chest from its icons and its unopened count.`,
                    clear: `The chest is drawn closed; pushing up into it opens it: ${r.item === 0 ? 'the flag-only chest shows "It is empty!"' : `GiveItemToPlayer gives item $${hex(r.item)} (${r.itemName})`}${r.fanfare ? ', with the fanfare (ChestOpeningActor)' : ', with the plain pickup dialogue (SFX #$2A)'}. A full inventory leaves the flag clear and the chest closed.`,
                },
                evidence: [
                    `${CHEST_FILE}:${r.line} {${r.offset}}`,
                    ...EVID.chestTest,
                    r.item === 0 ? EVID.chestSetEmpty : EVID.chestSetItem,
                ],
                notes: `Chest record ${r.rec} of the scene list ${r.label}; record bytes ${hex(r.x)} ${hex(r.y)} ${hex(r.item)} ${hex(r.flagByte)} (flag byte bit 7 ${r.fanfare ? 'set: fanfare' : 'clear'}). The flag is the record byte AND $7F plus $0200; the offset is decoded from the ROM (the asm rows carry no line-tracking tag). The name is derived from the table, not from dialog text. Whether the scene map holds a closed chest tile pair ($F8/$F9) at the record position was not decoded.`,
            }],
        };
    }
    for (const r of jewelRows()) {
        const name = jewelName(r);
        if (names.has(name)) throw new Error('duplicate name ' + name);
        names.add(name);
        flags[r.global] = {
            domain: 'D4',
            meanings: [{
                scope: null, name, area: r.si.group,
                summary: `The hidden Red Jewel of scene $${hex(r.scene)} (${r.si.name}) at tile (${hex(r.x)},${hex(r.y)}) has been picked up.`,
                kinds: ['reward-claimed'],
                grade: 'VERIFIED-STATIC',
                effects: {
                    set: 'HiddenRedJewelInteract returns without a message and gives nothing; the actor stays placed and idles.',
                    clear: 'Interacting gives item $01 (Red Jewel) through COP GiveItem and prints "You found a Red Jewel!", then sets the flag; a full inventory prints the full-inventory text and leaves the flag clear.',
                },
                evidence: [
                    `${ACTORS_FILE}:${r.line} {${r.offset}}`,
                    EVID.jewelTest, EVID.jewelSet,
                    'extracted/actors/hidden_red_jewel.asm:50 {50802}',
                    'extracted/system/engine/actor_execution.asm:962 {249662}',
                    'extracted/system/engine/actor_execution.asm:971 {249679}',
                    'extracted/system/engine/actor_execution.asm:972 {249680}',
                ],
                notes: `Placement row #${hex(r.row)} of scene $${hex(r.scene)}, attribute $${hex(r.attr)}: bit 0 set, so InitActorFromSceneData stores $0E = attribute >> 1 = $${hex(r.param, 1)} (actor_execution.asm:970-972, offsets 249676-249680); the interact handler adds $80 and uses base $0200. The name is derived from the placement, not from dialog text. Not tested at spawn: the actor is always placed. No other scene row places hidden_red_jewel, and no COP spawns it.`,
            }],
        };
    }
    const domains = {
        D4: {
            name: 'chests and hidden Red Jewels',
            ranges: [[512, 767]], indexed: true, persistence: 'save',
            lifecycle: 'Bytes $0A40-$0A5F of the save block; no scene load, world-map entry or game over clears them (ClearSceneState zeroes only $0A00-$0A01, ClearAllWramFlags only $0A80-$0A9F) and no clear wrapper exists for the _0200 base, so a set bit stays for the life of the save. Chests use $0201-$022E (the record byte AND $7F, so the table can address only $0200-$027F); hidden Red Jewels use $0280-$028F (actor attribute >> 1 plus $80); the two ranges cannot collide. The other 194 indices have no reader and no writer.',
            access: 'TestEventFlag_0200 (PlaceOpenedChestTiles, RadarPlotSceneMarkers, HiddenRedJewelInteract) and SetEventFlag_0200 (HandleChestInteraction twice, HiddenRedJewelInteract); no COP literal, no direct byte access and no other helper reaches $0200-$02FF.',
        },
    };
    return {
        _note: 'FL12 fragment. flags: one full record per index of D4 that a chest record or a hidden_red_jewel placement reaches (46 chest flags $0201-$022E, 16 jewel flags $0280-$028F). No spine flags: every index of the range has users in one scene only. The old trace barrier_chest_flags (46 candidates $0201-$022E) is the chest list; there is no barrier table.',
        domains, flags,
    };
}

const byteBit = g => `byte $${hex(0xA00 + (g >> 3), 4)} bit ${g & 7}`;

function buildQueue() {
    const q = [];
    const chest = chestRows(), jw = jewelRows();
    const pick = chest.find(r => r.scene === 0x0E);
    const fan = chest.find(r => r.scene === 0x2E);
    const empty = chest.find(r => r.scene === 0x60 && r.item === 0);
    const j0 = jw.find(r => r.scene === 0x03), jx = jw.find(r => r.scene === 0x01);
    const add = o => q.push({ id: `FL12-${String(q.length + 1).padStart(2, '0')}`, ...o });
    add({
        flag: pick.global, scope: null, priority: 'P2',
        claim: `Set: scene $0E draws the Herb chest at (${hex(pick.x)},${hex(pick.y)}) open on load and the radar omits it. Clear: closed chest, one radar icon.`,
        start: { scene: 0x0E, flags: [], form: 'Will', state: null },
        trial: {
            control: 'load scene $0E with flag $0201 (byte $0A40 bit 1) clear; read mapLayerTilemap ($7EA000) at the 2x2 cell block (04,19)-(05,1A) and open the Start-button radar map',
            forced: 'set byte $0A40 bit 1, load the same scene again; read the same cells and the radar map',
            observe: ['mapLayerTilemap cells ($F8/$F9/$FA/$FB closed, $FC/$FD/$FE/$FF open)', 'radar icon count digit', 'screenshot'],
        },
        confirms: 'closed tiles in the control, $FE/$FF over $FC/$FD in the forced load, and the radar icon missing in the forced load',
        refutes: 'the tiles or the radar do not change, or the map shows no chest at the record position (then the record has no chest tile in this scene)',
        needs: ['FR00'],
    });
    add({
        flag: fan.global, scope: null, priority: 'P2',
        claim: `Fanfare chest of scene $2E (Mystic Statue, flag $${hex(fan.global, 4)}): opening it plays the fanfare, gives item $38 and sets ${byteBit(fan.global)}; a full inventory leaves the flag clear.`,
        start: { scene: 0x2E, flags: [], form: 'Will', state: null },
        trial: {
            control: `stand under the chest at (${hex(fan.x)},${hex(fan.y)}) and push up with an empty inventory slot: record inventorySlots ($0AB4-$0AC3), byte $${hex(0xA00 + (fan.global >> 3), 4)}, music transition state`,
            forced: 'repeat with all inventory slots full (write item ids into $0AB4-$0AC3 in a disposable state)',
            observe: [`${byteBit(fan.global)}`, 'inventorySlots', 'dialogue text', 'musicTransitionState $FFFF seen'],
        },
        confirms: 'open run: flag set, item $38 in a slot, fanfare; full run: flag clear, chest drawn closed again',
        refutes: 'the flag is set although the inventory was full, or the fanfare does not play',
        needs: ['FR00'],
    });
    add({
        flag: empty.global, scope: null, priority: 'P3',
        claim: `Flag-only chest of scene $60 at (${hex(empty.x)},${hex(empty.y)}) (flag $${hex(empty.global, 4)}, ${byteBit(empty.global)}) shows "It is empty!" and sets its flag without an item.`,
        start: { scene: 0x60, flags: [], form: 'Will', state: null },
        trial: {
            control: `before opening: read ${byteBit(empty.global)} and inventorySlots`,
            forced: `push up into the chest at (${hex(empty.x)},${hex(empty.y)})`,
            observe: ['dialogue text', 'flag byte', 'inventorySlots unchanged'],
        },
        confirms: 'text "It is empty!", flag set, no new item',
        refutes: 'an item appears or the flag stays clear',
        needs: ['FR00'],
    });
    add({
        flag: j0.global, scope: null, priority: 'P2',
        claim: `Hidden jewel of scene $03 (attribute $${hex(j0.attr)}, $0E = ${j0.param}): interacting gives a Red Jewel once and sets flag $${hex(j0.global, 4)}.`,
        start: { scene: 0x03, flags: [], form: 'Will', state: null },
        trial: {
            control: 'interact at the tile (07,18) with the flag clear: record item $01 in inventorySlots, byte $0A50 bit 0',
            forced: 'interact a second time (flag set), then reload the scene and interact again',
            observe: ['inventorySlots', 'byte $0A50 bit 0', 'dialogue text'],
        },
        confirms: 'first interaction: Red Jewel +1 and flag set; later interactions: no text and no item',
        refutes: 'a second jewel is given, or a different byte/bit is set',
        needs: ['FR00'],
    });
    add({
        flag: jx.global, scope: null, priority: 'P3',
        claim: `Second jewel parameter ($0E = ${jx.param}, scene $01) maps to $${hex(jx.global, 4)} (byte $0A50 bit 1): checks that $0E = attribute >> 1 and not attribute.`,
        start: { scene: 0x01, flags: [], form: 'Will', state: null },
        trial: {
            control: 'interact at (08,0C) with byte $0A50 = 0',
            forced: 'record byte $0A50 afterwards',
            observe: ['byte $0A50 (expect $02)', 'byte $0A51 unchanged'],
        },
        confirms: 'byte $0A50 = $02',
        refutes: 'any other bit set',
        needs: ['FR00'],
    });
    add({
        flag: 0x200, scope: null, priority: 'P3',
        claim: 'No path reaches $0200 and $022F-$027F, $0290-$02FF: record the write census of bytes $0A40-$0A5F over a full chest/jewel route to catch a path the static search missed (dynamic address writes, save/load, MVN block copies).',
        start: { scene: 0x0E, flags: [], form: 'Will', state: null },
        trial: {
            control: 'write-callback census on $0A40-$0A5F with a positive control: open one chest and expect exactly one write at ROM offset 173994 or 173901',
            forced: 'play through several chest scenes and save/load once',
            observe: ['PC of every write to $0A40-$0A5F mapped to a ROM offset', 'changed bits'],
        },
        confirms: 'only bits of the 62 mapped indices change, only from the three set sites and the save load',
        refutes: 'a write with another PC or an unmapped bit',
        needs: ['FR00'],
    });
    return q;
}

const mode = process.argv[2];
if (mode === 'chests') printChests();
else if (mode === 'jewels') printJewels();
else if (mode === 'verify') verify();
else if (mode === 'gaps') gaps();
else if (mode === 'notecheck') notecheck();
else if (mode === 'reach') reach();
else if (mode === 'tables') tables();
else if (mode === 'registry') console.log(JSON.stringify(buildRegistry(), null, 2));
else if (mode === 'queue') console.log(JSON.stringify(buildQueue(), null, 2));
else { console.error('see the header of this file for the commands'); process.exit(1); }
