#!/usr/bin/env node
// fl32_guards.mjs - READ-ONLY guard (prerequisite) analysis of the extracted actor scripts for FL32.
//
// This script WRITES NOTHING: it reads extracted/**/*.asm and plans/flags/inventory.json and prints to stdout. It
// never touches extracted/, db-us/, notes/, docs/, src/ or any other file.
//
// Method. Each script file is split into instruction nodes in file order (ROM order: a block that does not end in a
// terminator falls into the next block). Roots are the first node of every `actor-def` / thinker body and every
// label that a non-branch COP names with `&label` (SetInteractHandler, spawns, ...). A MUST analysis (intersection over
// all paths from a root) computes, for every node, which flag conditions hold on every path:
//   - `COP [BranchOnFlagByte|Word] ( #id, #sense, &target )`: sense 00 jumps when the flag is CLEAR, nonzero when SET.
//     The taken edge adds (flag, !sense), the fall-through edge adds (flag, sense) ... see cond() below.
//   - `COP [WaitOnFlagByte|Word] ( #id, #sense )`: afterwards the flag has the sense state (and the actor yielded).
//   - SetFlag/ClearFlag of a flag change its condition in the OUT state.
//   - any other COP or asm branch is neutral; conditional asm branches add no condition; terminators (RTL RTS RTI BRA
//     BRL JMP JML, COP Die, JumpAfterDelay, JumpNextFrame) end the path (jumps go to their label).
//   - nodes that no root reaches are treated as roots (empty condition set), so the result never invents a guard.
// "Halt" COPs (waits, yields, animation loops) mark the path as delayed: a lock reached with no halt before it is an
// ARRIVAL lock (it fires on the first frame the actor runs).
//
// Usage (run from the repo root):
//   node plans/flags/tools/fl32_guards.mjs sites <file-or-dir-prefix>     # every flag Set/Clear site with its guard set
//   node plans/flags/tools/fl32_guards.mjs locks <file-or-dir-prefix>     # every $joypadMaskStd write with its guard set
//   node plans/flags/tools/fl32_guards.mjs edges                          # per persistent flag: requires / excludes from ALL its literal setter sites
//   node plans/flags/tools/fl32_guards.mjs scenelocks [hexSceneId,...]   # per scene: lock sites of the placed actor files with guards
//   node plans/flags/tools/fl32_guards.mjs json                           # everything as JSON on stdout (used by fl32_build.mjs)
import fs from 'node:fs';
import { hex, loadInventory, asmFiles, readLines, loadGroups, labelIndex, loadSceneActors } from './fl32_lib.mjs';

const HALT = new Set(['CameraPanDown', 'CameraPanUp', 'CameraPanRight', 'CameraPanLeft', 'DrawMetatileStream', 'DrawMetatileStreamDelay', 'PaletteRestart', 'PaletteStart', 'PaletteStartLoop', 'WaitOnFlagByte', 'WaitOnFlagWord', 'SetEntryHereAndYield', 'JumpAfterDelay', 'JumpNextFrame', 'CallNearDeferred', 'AdhocVramDma', 'WaitByte', 'WaitWord', 'WaitWhileOffscreen', 'HaltIfMaxFrames', 'PaletteStep', 'PaletteStepLoop', 'AnimOnce', 'AnimLoop', 'SetEntryHere']);
const JUMPS = new Set(['JumpAfterDelay', 'JumpNextFrame']);
const TERM_ASM = new Set(['RTL', 'RTS', 'RTI', 'BRA', 'BRL', 'JMP', 'JML']);
const COND_ASM = new Set(['BEQ', 'BNE', 'BCC', 'BCS', 'BMI', 'BPL', 'BVC', 'BVS']);

const num = (s) => parseInt(String(s).replace(/^#?\$?/, ''), 16);

function parseFile(file) {
    const lines = readLines('extracted/' + file);
    const nodes = [];
    const labels = new Map();
    const roots = new Set();
    const entryRoots = new Set();
    const entryNames = new Map();
    let pendingLabels = [];
    let inData = false;
    let first = true;
    lines.forEach((raw, li) => {
        const line = raw.replace(/\r$/, '');
        // block opener at column 0
        let m = line.match(/^([A-Za-z_][A-Za-z0-9_]*) \{\s*$/);
        if (m) { pendingLabels.push(m[1]); inData = false; return; }
        m = line.match(/^([A-Za-z_][A-Za-z0-9_]*) \[\s*$/);
        if (m) { pendingLabels.push(m[1]); inData = true; return; }
        if (/^\s*actor-def </.test(line) || /^\s*thinker-def </.test(line)) { inData = false; pendingLabels.push('@entry'); return; }
        if (/^[\]}]/.test(line) || /^\}\s*>/.test(line.trim())) { if (/^\}\s*>/.test(line.trim())) inData = false; return; }
        m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*):\s*(;.*)?$/);
        if (m && !inData) { pendingLabels.push(m[1]); return; }
        if (inData && !/actor-def|thinker-def/.test(line)) return;
        const t = line.trim();
        if (!t || t.startsWith(';') || t.startsWith('---') || t.startsWith('!') || t.startsWith('?') || t.startsWith('dialogstring') || t.startsWith('`')) return;
        const code = t.replace(/;.*$/, '').trim();
        if (!code) return;
        const tag = t.match(/\{(\d+)\}/);
        const node = { i: nodes.length, line: li + 1, offset: tag ? Number(tag[1]) : null, code, kind: 'op', succ: [] };
        let mc = code.match(/^COP \[([A-Za-z0-9_]+)\]\s*(?:\((.*)\))?/);
        if (mc) {
            node.kind = 'cop';
            node.cop = mc[1];
            node.ops = (mc[2] ?? '').trim();
            const targets = [...node.ops.matchAll(/&([A-Za-z_][A-Za-z0-9_.]*)/g)].map((x) => x[1]);
            node.targets = targets;
            const args = node.ops.split(',').map((x) => x.trim());
            if (/^(Set|Clear)Flag(Byte|Word)$/.test(node.cop)) { node.flagOp = node.cop.startsWith('Set') ? 'set' : 'clear'; node.flag = num(args[0]); }
            else if (/^BranchOnFlag(Byte|Word)$/.test(node.cop)) { node.flagOp = 'branch'; node.flag = num(args[0]); node.sense = num(args[1]) !== 0; }
            else if (/^WaitOnFlag(Byte|Word)$/.test(node.cop)) { node.flagOp = 'wait'; node.flag = num(args[0]); node.sense = num(args[1]) !== 0; }
        } else {
            const op = code.split(/\s+/)[0];
            node.op = op;
            node.operand = code.slice(op.length).trim();
            if (/\$joypadMaskStd\b/.test(code)) {
                if (op === 'TSB' || op === 'ORA') node.lock = 'lock';
                else if (op === 'TRB') node.lock = 'unlock';
                else if (op === 'STA') node.lock = 'write';
            }
        }
        for (const l of pendingLabels) {
            if (l === '@entry') { roots.add(node.i); entryRoots.add(node.i); entryNames.set(node.i, pendingLabels.filter((x) => x !== '@entry')); }
            else { if (!labels.has(l)) labels.set(l, node.i); }
        }
        if (first && pendingLabels.length === 0) roots.add(node.i);
        first = false;
        pendingLabels = [];
        nodes.push(node);
    });
    if (entryRoots.size === 0 && nodes.length > 0) entryRoots.add(0);
    return { nodes, labels, roots, entryRoots, entryNames };
}

// entryOnly: the analysis starts only at the actor-def entry (the code that runs when the actor spawns and
// when it re-runs its own script); handler roots (SetInteractHandler targets) are not roots, so a node that only a
// handler reaches stays unreached. Token 'C' = every path to the node passed a non-flag conditional (position, item,
// proximity, button), i.e. the node is not unconditional even when no persistent flag guards it.
function analyse(file, entryOnly = false, only = null) {
    const parsed = parseFile(file);
    const { nodes, labels } = parsed;
    // `only` (entry-only mode): the block labels of the placed actor-def(s); other actor-defs of the file are not roots
    const roots = entryOnly ? (only ? new Set([...parsed.entryRoots].filter((r) => (parsed.entryNames.get(r) ?? []).some((l) => only.includes(l)))) : parsed.entryRoots) : parsed.roots;
    if (nodes.length === 0) return { nodes: [], file };
    // successors
    const isCondCop = (n) => n.kind === 'cop' && n.targets.length > 0 && !JUMPS.has(n.cop) && (/^Branch|^LoopEnd$|^GiveItem$/.test(n.cop));
    const rootLabelNames = new Set();
    for (const n of nodes) {
        if (n.kind === 'cop' && n.targets.length && !JUMPS.has(n.cop) && !isCondCop(n)) for (const t of n.targets) rootLabelNames.add(t);
    }
    if (!entryOnly) for (const l of rootLabelNames) if (labels.has(l)) roots.add(labels.get(l));
    for (const n of nodes) {
        const next = n.i + 1 < nodes.length ? n.i + 1 : null;
        const tgt = (name) => (labels.has(name) ? labels.get(name) : null);
        if (n.kind === 'cop') {
            if (n.cop === 'Die') { n.term = true; continue; }
            if (JUMPS.has(n.cop)) { const t = tgt(n.targets[0]); n.succ.push({ to: t, add: [], delay: true }); n.term = true; continue; }
            if (n.flagOp === 'branch') {
                const t = tgt(n.targets[0]);
                // taken: sense 00 jumps when CLEAR ; nonzero jumps when SET
                n.succ.push({ to: t, add: [[n.flag, n.sense]] });
                if (next !== null) n.succ.push({ to: next, add: [[n.flag, !n.sense]] });
                continue;
            }
            if (isCondCop(n)) {
                const t = tgt(n.targets[0]);
                n.succ.push({ to: t, add: [], tok: "C" });
                if (next !== null) n.succ.push({ to: next, add: [], tok: "C" });
                continue;
            }
            if (next !== null) n.succ.push({ to: next, add: n.flagOp === 'wait' ? [[n.flag, n.sense]] : [], delay: HALT.has(n.cop) });
        } else {
            const op = n.op;
            if (TERM_ASM.has(op)) {
                n.term = true;
                if (['BRA', 'BRL', 'JMP', 'JML'].includes(op)) {
                    const lab = n.operand.match(/^([A-Za-z_][A-Za-z0-9_.]*)/);
                    if (lab && !/^\(/.test(n.operand)) { const t = tgt(lab[1].replace(/^[$&@]/, '')); n.succ.push({ to: t, add: [] }); }
                }
                continue;
            }
            if (COND_ASM.has(op)) {
                const lab = n.operand.match(/^([A-Za-z_][A-Za-z0-9_.]*)/);
                if (lab) n.succ.push({ to: tgt(lab[1]), add: [] });
                if (next !== null) n.succ.push({ to: next, add: [] });
                continue;
            }
            if (next !== null) n.succ.push({ to: next, add: [] });
        }
    }
    // must analysis. state: Set of "flag:1|0" plus the token "H" (delayed). null = TOP (not yet reached).
    const IN = nodes.map(() => null);
    const queue = [];
    const meet = (a, b) => (a === null ? new Set(b) : new Set([...a].filter((x) => b.has(x))));
    const eq = (a, b) => a !== null && b !== null && a.size === b.size && [...a].every((x) => b.has(x));
    for (const r of roots) { IN[r] = new Set(); queue.push(r); }
    const out = (n, inSet) => {
        const s = new Set(inSet);
        if (n.flagOp === 'set' || n.flagOp === 'clear') {
            // the actor's own Set/Clear ends what the earlier test said about this flag; it is an effect, not a guard
            s.delete(n.flag + ':1'); s.delete(n.flag + ':0');
        }
        if (n.kind === 'cop' && HALT.has(n.cop)) s.add('H');
        return s;
    };
    let guard = 0;
    while (queue.length && guard++ < 2_000_000) {
        const i = queue.shift();
        const n = nodes[i];
        const o = out(n, IN[i]);
        for (const e of n.succ) {
            if (e.to === null || e.to === undefined) continue;
            const s = new Set(o);
            for (const [f, state] of e.add) { s.delete(f + ':1'); s.delete(f + ':0'); s.add(f + ':' + (state ? 1 : 0)); }
            if (e.delay) s.add('H');
            if (e.tok) s.add(e.tok);
            const prev = IN[e.to];
            const merged = roots.has(e.to) ? new Set() : meet(prev, s);
            if (prev === null || !eq(prev, merged)) { IN[e.to] = merged; queue.push(e.to); }
        }
    }
    // unreached nodes become roots with an empty set (conservative); in entryOnly mode they stay unreached (null)
    if (!entryOnly) nodes.forEach((n, i) => { if (IN[i] === null) IN[i] = new Set(); });
    return { file, nodes, IN };
}

const parse = (set) => {
    const req = [], exc = [];
    let delayed = false, cond = false;
    for (const x of set) {
        if (x === 'H') { delayed = true; continue; }
        if (x === 'C') { cond = true; continue; }
        const [f, s] = x.split(':');
        (s === '1' ? req : exc).push(Number(f));
    }
    return { req: req.sort((a, b) => a - b), exc: exc.sort((a, b) => a - b), delayed, cond };
};

const cache = new Map();
const analyseCached = (f, entryOnly = false, only = null) => { const k = f + (entryOnly ? '#entry' : '') + (only ? '#' + only.join(',') : ''); if (!cache.has(k)) cache.set(k, analyse(f, entryOnly, only)); return cache.get(k); };

export function siteGuards(file) {
    const a = analyseCached(file);
    const out = [];
    for (const n of a.nodes) {
        if (n.flagOp === 'set' || n.flagOp === 'clear') out.push({ file, line: n.line, offset: n.offset, flag: n.flag, op: n.flagOp, ...parse(a.IN[n.i]) });
    }
    return out;
}
export function lockGuards(file, entryOnly = false, only = null) {
    const a = analyseCached(file, entryOnly, only);
    const out = [];
    for (const n of a.nodes) if (n.lock && a.IN[n.i] !== null) out.push({ file, line: n.line, offset: n.offset, lock: n.lock, ...parse(a.IN[n.i]) });
    return out;
}

const inv = loadInventory();
const filesWithFlags = [...new Set(inv.sites.filter((s) => s.kind === 'cop' && s.file !== undefined && !s.file.startsWith('unused/')).map((s) => s.file))];
const lockFilesAll = () => asmFiles().filter((f) => !f.startsWith('tables/') && fs.readFileSync('extracted/' + f, 'utf8').includes('$joypadMaskStd'));

const fmt = (g) => `req[${g.req.map((x) => hex(x, 2)).join(' ')}] exc[${g.exc.map((x) => hex(x, 2)).join(' ')}]${g.delayed ? ' delayed' : ' no-halt-before'}${g.cond ? ' cond' : ''}`;

export function computeEdges() {
    const setters = new Map(); // flag -> [site guards]
    for (const f of filesWithFlags) {
        for (const r of siteGuards(f)) {
            if (r.op !== 'set') continue;
            if (!setters.has(r.flag)) setters.set(r.flag, []);
            setters.get(r.flag).push(r);
        }
    }
    const edges = new Map();
    for (const [flag, sites] of setters) {
        if (flag < 16) continue;
        let req = null, exc = null;
        for (const s of sites) {
            const r = new Set(s.req.filter((x) => x >= 16 && x !== flag));
            const e = new Set(s.exc.filter((x) => x >= 16 && x !== flag));
            req = req === null ? r : new Set([...req].filter((x) => r.has(x)));
            exc = exc === null ? e : new Set([...exc].filter((x) => e.has(x)));
        }
        edges.set(flag, { flag, sites, requires: [...req].sort((a, b) => a - b), excludes: [...exc].sort((a, b) => a - b) });
    }
    return edges;
}

const cmd = process.argv[2];
if (cmd === 'sites' || cmd === 'locks') {
    const prefix = process.argv[3] ?? '';
    const files = (cmd === 'sites' ? filesWithFlags : lockFilesAll()).filter((f) => f.startsWith(prefix)).sort();
    for (const f of files) {
        const rows = cmd === 'sites' ? siteGuards(f) : lockGuards(f);
        for (const r of rows) console.log(`${f}:${r.line} {${r.offset}} ${cmd === 'sites' ? r.op + ' ' + hex(r.flag, 4) : r.lock} ${fmt(r)}`);
    }
} else if (cmd === 'scenelocks') {
    // per scene: every lock write of the actor files the scene places, with its guard set
    const { scenes } = loadGroups();
    const labels = labelIndex();
    const placed = loadSceneActors();
    const only = process.argv[3] ? new Set(process.argv[3].split(',').map((x) => parseInt(x, 16))) : null;
    const fileOf = (lab) => { const p = lab.split('.'); return labels.get(p[p.length - 1]) ?? labels.get(p[0]) ?? null; };
    for (const [id, sc] of scenes) {
        if (only && !only.has(id)) continue;
        const files = [...new Set((placed.get(id)?.actors ?? []).map((a) => fileOf(a.label)).filter(Boolean))];
        const out = [];
        for (const f of files) {
            for (const r of lockGuards(f, true)) {
                if (!f.startsWith('actors/') && (r.lock === 'lock' || r.lock === 'write')) out.push(`    ${f}:${r.line} {${r.offset}} ${r.lock} ${fmt(r)}`);
            }
        }
        console.log(hex(id, 2) + ' ' + (sc.group ?? '') + ' ' + (sc.desc ?? '') + (out.length ? '' : '  (no lock)'));
        for (const o of out) console.log(o);
    }
} else if (cmd === 'edges' || cmd === 'json') {
    const edges = computeEdges();
    if (cmd === 'edges') {
        for (const e of [...edges.values()].sort((a, b) => a.flag - b.flag)) {
            console.log(`${hex(e.flag, 4)} setters=${e.sites.length} requires[${e.requires.map((x) => hex(x, 2)).join(' ')}] excludes[${e.excludes.map((x) => hex(x, 2)).join(' ')}]`);
        }
    } else {
        const locks = [];
        for (const f of lockFilesAll()) for (const r of lockGuards(f)) locks.push(r);
        console.log(JSON.stringify({ edges: [...edges.values()], locks }, null, 1));
    }
}
