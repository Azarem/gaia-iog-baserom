#!/usr/bin/env node
// fl32_groupedges.mjs - READ-ONLY. Aggregates the scene edges printed by `fl32_scenes.mjs edges` (stdin) into
// area-group edges (db-us/groups.json groups). It WRITES NOTHING: it reads stdin and prints to stdout.
//   node plans/flags/tools/fl32_scenes.mjs edges | node plans/flags/tools/fl32_groupedges.mjs
import fs from 'node:fs';
import { loadGroups } from './fl32_lib.mjs';

const { scenes } = loadGroups();
const lines = fs.readFileSync(0, 'utf8').split(/\r?\n/).filter(Boolean);
const agg = new Map();
for (const l of lines) {
    const m = l.match(/^\$([0-9A-F]+) -> \$([0-9A-F]+) (\S+)/);
    if (!m) continue;
    const a = scenes.get(parseInt(m[1], 16))?.group;
    const b = scenes.get(parseInt(m[2], 16))?.group;
    if (!a || !b || a === b) continue;
    const k = `${a} -> ${b}`;
    if (!agg.has(k)) agg.set(k, []);
    agg.get(k).push(`${m[1]}>${m[2]}:${m[3] === 'QueueMapChange' ? 'Q' : 'W'}`);
}
for (const [k, v] of agg) console.log(k, '|', v.slice(0, 8).join(' '));
