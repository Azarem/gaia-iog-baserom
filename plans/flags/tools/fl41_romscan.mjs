#!/usr/bin/env node
// fl41_romscan.mjs - READ-ONLY independent scan of the ROM image for flag COP byte patterns.
//
// This script WRITES NOTHING: it reads plans/flags/inventory.json and the ROM image rebuilt/Illusion of Gaia.smc and prints
// to stdout. It never touches extracted/, db-us/, notes/, docs/, src/ or any other file.
//
// Usage (repository root):
//   node plans/flags/tools/fl41_romscan.mjs            summary: ROM matches of `02 CC..D3 <operands>` against the inventory COP sites
//   node plans/flags/tools/fl41_romscan.mjs list       the matches that are NOT inventory sites (candidates for a missed site or data coincidence)
//
// A COP flag instruction is `02 <op> <operands>` with op CC/CE (flag byte), CD/CF (flag word), D0 (flag byte, sense byte, address word),
// D1 (flag word, sense byte, address word), D2 (flag byte, sense byte), D3 (flag word, sense byte). The inventory site offset is the `02`.
import fs from 'node:fs';

const inv = JSON.parse(fs.readFileSync('plans/flags/inventory.json', 'utf8'));
const rom = fs.readFileSync('rebuilt/Illusion of Gaia.smc');
const sites = new Map(inv.sites.filter((s) => s.kind === 'cop').map((s) => [s.offset, s]));
const OPS = { 0xcc: 'SetFlagByte', 0xcd: 'SetFlagWord', 0xce: 'ClearFlagByte', 0xcf: 'ClearFlagWord', 0xd0: 'BranchOnFlagByte', 0xd1: 'BranchOnFlagWord', 0xd2: 'WaitOnFlagByte', 0xd3: 'WaitOnFlagWord' };
const hex = (n, w = 2) => n.toString(16).toUpperCase().padStart(w, '0');
let total = 0, inInv = 0;
const extra = [];
for (let o = 0; o < rom.length - 6; o++) {
    if (rom[o] !== 0x02 || !(rom[o + 1] in OPS)) continue;
    total++;
    if (sites.has(o)) { inInv++; continue; }
    const op = rom[o + 1];
    const word = op & 1 && op !== 0xd1 && op !== 0xd3 ? true : op === 0xd1 || op === 0xd3;
    const idx = word ? rom[o + 2] | (rom[o + 3] << 8) : rom[o + 2];
    extra.push({ o, op: OPS[op], idx, bytes: [...rom.subarray(o, o + 8)].map((b) => hex(b)).join(' ') });
}
console.log(`ROM bytes: ${rom.length}; pattern matches ${total}; inventory COP sites ${sites.size}; matches that are inventory sites ${inInv}; matches not in the inventory ${extra.length}`);
const byOp = {};
for (const e of extra) byOp[e.op] = (byOp[e.op] ?? 0) + 1;
console.log('not in inventory by opcode:', JSON.stringify(byOp));
const missingInROM = [...sites.keys()].filter((o) => !(rom[o] === 0x02 && rom[o + 1] in OPS));
console.log(`inventory sites whose ROM bytes are not 02 CC..D3: ${missingInROM.length}`);
if (process.argv[2] === 'list') for (const e of extra) console.log(`${e.o}\t${e.op}\t${e.idx >= 0 ? '$' + hex(e.idx, 4) : ''}\t${e.bytes}`);
