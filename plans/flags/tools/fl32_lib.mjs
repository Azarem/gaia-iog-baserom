// fl32_lib.mjs - shared READ-ONLY loaders for the FL32 iteration tools (progression graph).
//
// This module WRITES NOTHING. It reads plans/flags/inventory.json, plans/flags/results/registry/FL*_registry.json,
// db-us/groups.json, db-us/scene-flags.json and extracted/**/*.asm (tables and actor files) and returns data to its
// importer. It never touches extracted/, db-us/, notes/, docs/, src/ or any other file. Run the importers from the
// repository root (c:\Work\gaia-iog-baserom).
import fs from 'node:fs';
import path from 'node:path';

export const hex = (n, w = 4) => '$' + Number(n).toString(16).toUpperCase().padStart(w, '0');
export const readJson = (f) => JSON.parse(fs.readFileSync(f, 'utf8'));
export const readLines = (f) => fs.readFileSync(f, 'utf8').split(/\r?\n/);

/** scene id -> { id, group, key, desc, prefix }; also `order` (group names in file order). */
export function loadGroups() {
    const g = readJson('db-us/groups.json');
    const scenes = new Map();
    const order = [];
    for (const [group, v] of Object.entries(g)) {
        order.push(group);
        for (const [key, s] of Object.entries(v.scenes)) scenes.set(s.id, { id: s.id, group, key, desc: s.description, prefix: v.prefix });
    }
    return { scenes, order };
}

export const loadInventory = () => readJson('plans/flags/inventory.json');

/** Fragments in apply order: FL10..FL31, FL31b, FL32 (FL32 excluded unless `withSelf`). */
export function fragmentFiles(withSelf = false) {
    const dir = 'plans/flags/results/registry';
    return fs
        .readdirSync(dir)
        .filter((x) => /^FL\d+b?_registry\.json$/.test(x) && (withSelf || !/^FL32/.test(x)))
        .sort((a, b) => {
            const na = parseInt(a.slice(2), 10), nb = parseInt(b.slice(2), 10);
            return na - nb || a.localeCompare(b);
        })
        .map((x) => path.join(dir, x));
}

/**
 * Merged view of every fragment's `flags` (patches applied by expectOld) and `proposals`.
 * Returns { flags: Map<index, {domain, meanings[]}>, proposals: Map<index, [{source,...}]> }.
 * A meaning is { ...fields, _from: fragment file name }.
 */
export function loadRegistry(withSelf = false) {
    const flags = new Map();
    const proposals = new Map();
    for (const file of fragmentFiles(withSelf)) {
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

// every .asm file under extracted/ (relative paths, forward slashes)
export function asmFiles() {
    const out = [];
    const walk = (d) => {
        for (const e of fs.readdirSync(path.join('extracted', d), { withFileTypes: true })) {
            const rel = d ? d + '/' + e.name : e.name;
            if (e.isDirectory()) walk(rel);
            else if (e.name.endsWith('.asm')) out.push(rel);
        }
    };
    walk('');
    return out;
}

/** label at column 0 (`Name [` or `Name {`) -> relative file. Last definition wins only if the first is missing. */
export function labelIndex() {
    const idx = new Map();
    for (const f of asmFiles()) {
        for (const l of readLines('extracted/' + f)) {
            const m = l.match(/^([A-Za-z_][A-Za-z0-9_]*) [\[{]\s*$/);
            if (m && !idx.has(m[1])) idx.set(m[1], f);
        }
    }
    return idx;
}

/** Parse `scene_<id>_actors [ ... ]` blocks of tables/scene_actors.asm: id -> [{label, tx, ty, row}] */
export function loadSceneActors() {
    const lines = readLines('extracted/tables/scene_actors.asm');
    const pointer = new Map();
    const ps = lines.findIndex((l) => l.startsWith('scene_actors ['));
    for (let i = ps + 1; i < lines.length && !lines[i].startsWith(']'); i++) {
        const m = lines[i].match(/&?([A-Za-z0-9_]+)\s*;([0-9A-F]{2})\s*$/);
        if (m) pointer.set(parseInt(m[2], 16), m[1]);
    }
    const blocks = new Map();
    for (let i = 0; i < lines.length; i++) {
        const m = lines[i].match(/^([A-Za-z0-9_]+) \[\s*$/);
        if (!m) continue;
        const rows = [];
        let j = i + 1;
        for (; j < lines.length && !lines[j].startsWith(']'); j++) rows.push({ text: lines[j], line: j + 1 });
        blocks.set(m[1], rows);
    }
    const out = new Map();
    for (const [id, label] of pointer) {
        const rows = blocks.get(label) ?? [];
        const actors = [];
        for (const r of rows) {
            const m = r.text.match(/actor-spawn < #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), @([A-Za-z0-9_.]+)/);
            if (m) actors.push({ tx: m[1], ty: m[2], attr: m[3], label: m[4], line: r.line, text: r.text.trim() });
            else if (/enemy-spawn|spawn </.test(r.text)) {
                const m2 = r.text.match(/@([A-Za-z0-9_.]+)/);
                if (m2) actors.push({ tx: '', ty: '', attr: '', label: m2[1], line: r.line, text: r.text.trim(), kind: 'other' });
            }
        }
        out.set(id, { label, actors });
    }
    return out;
}

/** thinker list per scene: id -> [labels] */
export function loadSceneThinkers() {
    const lines = readLines('extracted/tables/scene_thinkers.asm');
    const pointer = new Map();
    const ps = lines.findIndex((l) => l.startsWith('scene_thinkers ['));
    for (let i = ps + 1; i < lines.length && !lines[i].startsWith(']'); i++) {
        const m = lines[i].match(/&?([A-Za-z0-9_+$]+)\s*;([0-9A-F]{2})\s*$/);
        if (m) pointer.set(parseInt(m[2], 16), m[1]);
    }
    const blocks = new Map();
    for (let i = 0; i < lines.length; i++) {
        const m = lines[i].match(/^([A-Za-z0-9_]+) \[\s*$/);
        if (!m) continue;
        const rows = [];
        for (let j = i + 1; j < lines.length && !lines[j].startsWith(']'); j++) {
            const t = lines[j].match(/thinker-spawn < #[0-9A-F]{2}, @([A-Za-z0-9_.]+)/);
            if (t) rows.push(t[1]);
        }
        blocks.set(m[1], rows);
    }
    const out = new Map();
    for (const [id, ptr] of pointer) out.set(id, blocks.get(ptr.split('+')[0]) ?? []);
    return out;
}

/** scene-warps: id -> [{x,y,w,h,dest}] (change-scene warps only) */
export function loadSceneWarps() {
    const lines = readLines('extracted/tables/scene_warps.asm');
    const pointer = new Map();
    const ps = lines.findIndex((l) => l.startsWith('scene_warps ['));
    for (let i = ps + 1; i < lines.length && !lines[i].startsWith(']'); i++) {
        const m = lines[i].match(/&?([A-Za-z0-9_]+)\s*;([0-9A-F]{2})\s*$/);
        if (m) pointer.set(parseInt(m[2], 16), m[1]);
    }
    const blocks = new Map();
    let cur = null;
    lines.forEach((l, i) => {
        const h = l.match(/^(warp_def_[0-9A-Za-z]+) \[/);
        if (h) { cur = h[1]; blocks.set(cur, []); return; }
        const w = l.match(/scene-warp < #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}), #([0-9A-F]{2}),/);
        if (w && cur) blocks.get(cur).push({ x: w[1], y: w[2], w: w[3], h: w[4], dest: parseInt(w[5], 16), line: i + 1 });
    });
    const out = new Map();
    for (const [id, ptr] of pointer) out.set(id, blocks.get(ptr) ?? []);
    return out;
}

/** scene_meta branch gates: id -> [{flag, line}] (flag decimal). */
export function loadSceneMetaGates(inv) {
    const out = new Map();
    for (const s of inv.sites.filter((x) => x.kind === 'scene_gate')) {
        for (const sc of s.scenes ?? []) {
            if (!out.has(sc)) out.set(sc, []);
            out.get(sc).push({ flag: s.index, line: s.line, offset: s.offset, sense: s.sense });
        }
    }
    return out;
}
