// fl41_lib.mjs - shared READ-ONLY model builder of the FL41 gap analysis (bit matrix of the flag array $0A00-$0AB3).
//
// This module WRITES NOTHING. It reads plans/flags/inventory.json, plans/flags/results/registry/FL*_registry.json,
// plans/flags/results/queue/FL*_queue.json, db-us/groups.json and the ROM image rebuilt/Illusion of Gaia.smc (through fl32_lib.mjs
// loaders and node:fs) and returns data to its importer. It never touches extracted/, db-us/, notes/, docs/, src/ or any other
// file. Run the importers from the repository root (c:\Work\gaia-iog-baserom).
import fs from 'node:fs';
import path from 'node:path';
import { loadInventory, loadRegistry, fragmentFiles, readJson, hex, loadGroups } from './fl32_lib.mjs';

export { hex, readJson, loadGroups };
export const BITS = 1440; // flag indices $0000-$059F = bytes $0A00-$0AB3
export const H4 = (n) => '$' + n.toString(16).toUpperCase().padStart(4, '0');
export const byteOf = (b) => 0xa00 + (b >> 3);

export function domainOf(b) {
    if (b < 16) return 'D1';
    if (b < 256) return 'D2';
    if (b < 512) return 'D3';
    if (b < 768) return 'D4';
    if (b < 1024) return 'D5';
    if (b < 1280) return 'D6';
    if (b < 1288) return 'D7b'; // boss reward $0500-$0507 (byte $0AA0)
    if (b < 1296) return 'U'; // byte $0AA1: no owner
    if (b < 1312) return 'D7a'; // ability flags $0510-$051F (abilityBitmask $0AA2-$0AA3)
    return 'S'; // bytes $0AA4-$0AB3: other state words (not flag storage)
}

export const DOMAIN_TEXT = {
    D1: 'D1 scene scratch',
    D2: 'D2 story',
    D3: 'D3 event triggers',
    D4: 'D4 chests/jewels',
    D5: 'D5 scene reward',
    D6: 'D6 kill flags',
    D7b: 'D7 boss reward',
    U: 'unassigned byte',
    D7a: 'D7 ability',
    S: 'state words',
};

// Traces whose index comes from a constant, an actor parameter or a computed form/slot (helper-addressed), versus a dedicated table.
export const HELPER_TRACES = new Set([
    'wram_offset_constant_callers', 'dark_space_portal_death_flags', 'diamond_mine_laborer_flags', 'necklace_stone_flags', 'statue_reward_flags',
    'hidden_red_jewel_flags', 'falling_orb_flags', 'hit_switch_flags', 'gold_tile_flags', 'inventory_ability_flags',
]);
export const TABLE_TRACES = new Set(['enemy_clear_reward_flags', 'boss_reward_wram_flags', 'barrier_chest_flags', 'enemy_death_action_flags', 'dungeon_kill_wram_flags']);

export function loadQueues() {
    const dir = 'plans/flags/results/queue';
    const items = [];
    for (const f of fs.readdirSync(dir).filter((x) => /^FL\d+b?_queue\.json$/.test(x)).sort((a, b) => parseInt(a.slice(2), 10) - parseInt(b.slice(2), 10))) {
        const j = readJson(path.join(dir, f));
        for (const q of j) items.push({ ...q, _file: f, _iter: f.slice(0, f.indexOf('_')) });
    }
    return items;
}

/** FL10..FL40 fragments (FL41's own fragment is excluded so the audit sees the chain it audits) */
const chainFiles = () => fragmentFiles(true).filter((f) => !/FL41/.test(path.basename(f)));

/** raw (unmerged) fragments with their names, for cross-fragment comparisons */
export function loadRawFragments() {
    return chainFiles().map((f) => ({ file: path.basename(f), json: readJson(f) }));
}

/** Same merge as fl32_lib.loadRegistry(true) (patch rows by expectOld) without the FL41 fragment. */
export function loadChain() {
    const flags = new Map();
    const proposals = new Map();
    for (const file of chainFiles()) {
        const j = readJson(file);
        const base = path.basename(file);
        for (const [k, v] of Object.entries(j.flags ?? {})) {
            const idx = Number(k);
            const rec = flags.get(idx) ?? { domain: v.domain, meanings: [] };
            for (const m of v.meanings) {
                const { expectOld, patch, ...fields } = m;
                if (patch) {
                    const hit = rec.meanings.find((x) => (typeof expectOld === 'string' ? x.name === expectOld : true));
                    if (hit) Object.assign(hit, fields);
                    continue;
                }
                const sk = JSON.stringify(fields.scope ?? null);
                const at = rec.meanings.findIndex((x) => JSON.stringify(x.scope ?? null) === sk);
                const entry = { ...fields, _from: base };
                if (at >= 0) rec.meanings[at] = entry;
                else rec.meanings.push(entry);
            }
            flags.set(idx, rec);
        }
        const pr = j.proposals;
        if (pr) {
            const list = Array.isArray(pr) ? pr.map((p) => [Number(p.index ?? p.flag), p]) : Object.entries(pr).flatMap(([k, arr]) => (Array.isArray(arr) ? arr : [arr]).map((p) => [Number(k), p]));
            for (const [idx, p] of list) {
                if (!proposals.has(idx)) proposals.set(idx, []);
                proposals.get(idx).push({ ...p, _from: base });
            }
        }
    }
    return { flags, proposals };
}

/** Per-index tally of literal COP sites, scene gates and helper references. */
export function tally(inv) {
    const t = new Map();
    const get = (i) => {
        let r = t.get(i);
        if (!r) t.set(i, (r = { S: 0, C: 0, T: 0, W: 0, G: 0, sites: [], scenes: new Set(), word: false }));
        return r;
    };
    for (const s of inv.sites) {
        if (s.kind === 'cop') {
            const r = get(s.index);
            r[{ set: 'S', clear: 'C', branch: 'T', wait: 'W' }[s.role]]++;
            r.sites.push(s);
            for (const sc of s.scenes ?? []) r.scenes.add(sc);
            if (s.width === 'word') r.word = true;
        } else if (s.kind === 'scene_gate') {
            const r = get(s.index);
            r.G++;
            r.sites.push(s);
            for (const sc of s.scenes ?? []) r.scenes.add(sc);
        }
    }
    return t;
}

/** index -> { helper: [traceIds], table: [traceIds], generic: [traceIds] } from the 17 traces */
export function traceMap(inv) {
    const m = new Map();
    for (const tr of inv.traces) {
        const kind = HELPER_TRACES.has(tr.id) ? 'helper' : TABLE_TRACES.has(tr.id) ? 'table' : tr.id === 'scene_meta_gates' ? 'gate' : 'generic';
        for (const i of tr.candidate_indices ?? []) {
            const r = m.get(i) ?? { helper: [], table: [], gate: [], generic: [] };
            r[kind].push(tr.id);
            m.set(i, r);
        }
    }
    return m;
}

export function loadAll() {
    const inv = loadInventory();
    const reg = loadChain();
    const queues = loadQueues();
    const raw = loadRawFragments();
    return { inv, reg, queues, raw, cop: tally(inv), traces: traceMap(inv) };
}

/** Compact range text: [1,2,3,5] -> "$0001-$0003 $0005" */
export function ranges(list) {
    const a = [...list].sort((x, y) => x - y);
    const out = [];
    for (let i = 0; i < a.length; ) {
        let j = i;
        while (j + 1 < a.length && a[j + 1] === a[j] + 1) j++;
        out.push(i === j ? H4(a[i]) : j === i + 1 ? `${H4(a[i])} ${H4(a[j])}` : `${H4(a[i])}-${H4(a[j])}`);
        i = j + 1;
    }
    return out.join(' ');
}
