/**
 * Flag registry tool (`npm run flags`).
 *
 *   npm run flags -- <fragment.json> [--dry-run]       merge flag records into db-us/flags.json
 *   npm run flags -- --check [--strict]                validate flags.json, scene-flags.json, flag-presets.json against each other
 *   npm run flags -- export [--out-dir=<dir>]          artifacts/flags.json + artifacts/flag-presets.json
 *   npm run flags -- docs [--out-dir=<dir>]            docs/flags/README.md + one page per area
 *   npm run flags -- scene-flags <spec.json> [--dry-run]   merge entries into db-us/scene-flags.json
 *   npm run flags -- presets <spec.json> [--dry-run]       merge into db-us/flag-presets.json
 *   npm run flags -- inventory [--dry-run] [--compare=<old.json>]   scan extracted/ (line-tracked) into plans/flags/inventory.json (FL01, src/flag-inventory.ts)
 *
 * Common options: --db-dir=<dir> (default db-us; use a copy to test), --inventory=<file> (default plans/flags/inventory.json).
 *
 * Conventions follow `merge` and `names`: a spec file goes in, `--dry-run` reports without writing, everything is validated
 * before any write and one error aborts the whole run (nothing written), and a file is rewritten only when its content changed.
 * Documented in `docs/flags/README.md` (source: `docs/flags/_intro.md`) and `docs/mesen2-exports.md`.
 *
 * Flag index convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit (n & 7), mask 1 << (n & 7). The registry is keyed by
 * decimal global index. The array has 180 bytes (`$0A00`-`$0AB3`), so valid indices are 0-1439.
 */
import { existsSync, mkdirSync, readFileSync, readdirSync, unlinkSync, writeFileSync } from 'fs';
import { dirname, join, relative, resolve, sep } from 'path';
import { runInventory } from './flag-inventory.ts';

// ------------------------------------------------------------------------------------------------------------
// Vocabularies
// ------------------------------------------------------------------------------------------------------------

export const SCHEMA = 1;
/** Bits in the flag array `$0A00`-`$0AB3`. */
export const FLAG_COUNT = 1440;
export const KINDS = ['once-latch', 'quest-guard', 'quest-done', 'gate-open', 'handshake', 'cutscene-stage', 'puzzle-state', 'reward-claimed', 'form-latch', 'engine', 'idiom', 'unknown'] as const;
export const GRADES = ['VERIFIED-RUNTIME', 'VERIFIED-STATIC', 'INFERRED', 'UNKNOWN'] as const;
export const LEVELS = ['full', 'row'] as const;
export const CONFIDENCE = ['low', 'medium', 'high'] as const;
export const ENTRY_CLASSES = ['free', 'locked-until-flag', 'cutscene', 'unreachable', 'unknown'] as const;
export const FORMS = ['Will', 'Freedan', 'Shadow'] as const;
export const PERSISTENCE = ['scene', 'save', 'dungeon', 'none'] as const;

const NAME_RE = /^[a-z][a-z0-9]*(_[a-z0-9]+)+$/;
const STAGE_RE = /^[a-z0-9_]+(\.[a-z0-9_]+)*$/;
const SOURCE_RE = /^[A-Za-z][A-Za-z0-9_-]*$/;
const PRESET_RE = /^[a-z][a-z0-9_]*$/;
const DOMAIN_RE = /^D\d+$/;

const MEANING_KEYS = ['name', 'level', 'area', 'scope', 'summary', 'stage', 'kinds', 'grade', 'effects', 'requires', 'excludes', 'pairsWith', 'evidence', 'runtime', 'queue', 'proposedBy', 'notes'];
const PROPOSAL_KEYS = ['source', 'scope', 'name', 'summary', 'kinds', 'roles', 'confidence', 'notes'];
const SCENE_FLAG_KEYS = ['flags', 'names', 'entry', 'grade', 'note', 'source'];
const PRESET_KEYS = ['after', 'flags', 'flagNames', 'items', 'form', 'gems', 'abilities', 'verifyScene', 'grade', 'evidence', 'note'];

// ------------------------------------------------------------------------------------------------------------
// Types
// ------------------------------------------------------------------------------------------------------------

type Obj = Record<string, unknown>;
type Ref = number | string;

export interface Scope { scenes: number[]; actors?: string[] }

export interface Meaning {
    name?: string;
    level?: string;
    area?: string;
    scope: Scope | null;
    summary?: string;
    stage?: string;
    kinds?: string[];
    grade?: string;
    effects?: { set?: string; clear?: string };
    requires?: Ref[];
    excludes?: Ref[];
    pairsWith?: Ref[];
    evidence?: string[];
    runtime?: { result: string; trial?: string; rom?: string };
    queue?: string[];
    proposedBy?: string[];
    notes?: string;
}

export interface DomainDef {
    name: string;
    ranges: Array<[number, number]>;
    persistence: string;
    indexed: boolean;
    lifecycle?: string;
    access?: string;
}

export interface FlagRecord { hex: string; address: string; mask: string; domain: string; meanings: Meaning[] }

export interface Proposal {
    source: string;
    scope: Scope | null;
    name: string;
    summary: string;
    kinds?: string[];
    roles?: string[];
    confidence: string;
    notes?: string;
}

export interface Registry {
    schema: number;
    domains: Record<string, DomainDef>;
    flags: Record<string, FlagRecord>;
    proposals?: Record<string, Proposal[]>;
}

export interface SceneFlagEntry { flags: number[]; names?: string[]; entry?: string; grade?: string; note?: string; source?: string }

export interface PresetItem { id: number; slot: number }
export interface Preset {
    after?: string;
    flags: number[];
    flagNames?: string[];
    items?: PresetItem[];
    form?: string;
    gems?: number;
    abilities?: string[];
    verifyScene?: number;
    grade?: string;
    evidence?: string[];
    note?: string;
}

export interface Context {
    sceneIds: Set<number>;
    sceneGroup: Map<number, string>;
    groupPrefix: Map<string, string>;
    groupOrder: string[];
}

export interface Paths { root: string; dbDir: string; flags: string; sceneFlags: string; presets: string; groups: string }

export interface FlagsOptions {
    dryRun?: boolean;
    strict?: boolean;
    /** Folder holding flags.json, scene-flags.json, flag-presets.json, groups.json (default `<root>/db-us`). */
    dbDir?: string;
    outDir?: string;
    /** Inventory file joined into the export and the docs (default `plans/flags/inventory.json`). */
    inventory?: string;
}

// ------------------------------------------------------------------------------------------------------------
// Small helpers
// ------------------------------------------------------------------------------------------------------------

const isObj = (v: unknown): v is Obj => typeof v === 'object' && v !== null && !Array.isArray(v);
const isInt = (v: unknown): v is number => typeof v === 'number' && Number.isInteger(v);
const isStr = (v: unknown): v is string => typeof v === 'string' && v.trim() !== '';
const hex = (n: number, width: number) => n.toString(16).toUpperCase().padStart(width, '0');
const clip = (s: string, n = 80) => (s.length > n ? s.slice(0, n - 3) + '...' : s);
const toPosix = (p: string) => p.split(sep).join('/');

export function flagLocation(index: number) {
    const address = 0x0A00 + (index >> 3);
    const mask = 1 << (index & 7);
    return { index, address, mask, hex: '$' + hex(index, 4), addressHex: '$' + hex(address, 4), maskHex: '$' + hex(mask, 2) };
}

/** Canonical JSON: sorted object keys, arrays of primitives sorted (equality of sets). */
function canon(v: unknown): string {
    if (v === null || v === undefined || typeof v !== 'object') return JSON.stringify(v ?? null);
    if (Array.isArray(v)) {
        const parts = v.map(canon);
        if (v.every(x => x === null || typeof x !== 'object')) parts.sort();
        return '[' + parts.join(',') + ']';
    }
    return '{' + Object.keys(v).sort().map(k => JSON.stringify(k) + ':' + canon((v as Obj)[k])).join(',') + '}';
}

export class Report {
    errors: Array<{ key: string; msg: string }> = [];
    warnings: string[] = [];
    error(key: string, msg: string) { this.errors.push({ key, msg }); }
    warn(msg: string) { if (!this.warnings.includes(msg)) this.warnings.push(msg); }
    get ok() { return this.errors.length === 0; }
    /** Distinct records that carry at least one error. */
    get rejected() { return new Set(this.errors.map(e => e.key)).size; }
}

function rangeText(ranges: Array<[number, number]>): string {
    return ranges.map(([lo, hi]) => `$${hex(lo, 4)}-$${hex(hi, 4)}`).join(', ');
}

function byteRangeText(ranges: Array<[number, number]>): string {
    return ranges.map(([lo, hi]) => `$${hex(flagLocation(lo).address, 4)}-$${hex(flagLocation(hi).address, 4)}`).join(', ');
}

export function dbPaths(root: string, dbDir?: string): Paths {
    const dir = dbDir ? resolve(dbDir) : join(root, 'db-us');
    return { root, dbDir: dir, flags: join(dir, 'flags.json'), sceneFlags: join(dir, 'scene-flags.json'), presets: join(dir, 'flag-presets.json'), groups: join(dir, 'groups.json') };
}

export function loadContext(paths: Paths): Context {
    if (!existsSync(paths.groups)) throw new Error(`groups.json not found: ${paths.groups}`);
    const groups = JSON.parse(readFileSync(paths.groups, 'utf-8')) as Record<string, { prefix?: string; scenes?: Record<string, { id: number }> }>;
    const ctx: Context = { sceneIds: new Set(), sceneGroup: new Map(), groupPrefix: new Map(), groupOrder: [] };
    for (const [group, def] of Object.entries(groups)) {
        ctx.groupOrder.push(group);
        if (def.prefix) ctx.groupPrefix.set(group, def.prefix);
        for (const scene of Object.values(def.scenes ?? {})) {
            ctx.sceneIds.add(scene.id);
            ctx.sceneGroup.set(scene.id, group);
        }
    }
    return ctx;
}

// ------------------------------------------------------------------------------------------------------------
// Canonical JSON text (the form the tool writes; `--check` compares files against it)
// ------------------------------------------------------------------------------------------------------------

function nest(v: unknown): number {
    if (v === null || typeof v !== 'object') return 0;
    const children = Array.isArray(v) ? v : Object.values(v as Obj);
    return 1 + children.reduce<number>((m, c) => Math.max(m, nest(c)), 0);
}

function inline(v: unknown): string {
    if (v === null || typeof v !== 'object') return JSON.stringify(v);
    if (Array.isArray(v)) return '[' + v.map(inline).join(', ') + ']';
    const entries = Object.entries(v as Obj).filter(([, x]) => x !== undefined);
    if (entries.length === 0) return '{}';
    return '{ ' + entries.map(([k, x]) => JSON.stringify(k) + ': ' + inline(x)).join(', ') + ' }';
}

function pretty(v: unknown, level: number): string {
    if (v === null || typeof v !== 'object') return JSON.stringify(v);
    if (nest(v) <= 2) {
        const flat = inline(v);
        if (flat.length + level * 2 <= 100) return flat;
    }
    const pad = '  '.repeat(level + 1);
    const end = '  '.repeat(level);
    if (Array.isArray(v)) {
        if (v.length === 0) return '[]';
        return '[\n' + v.map(x => pad + pretty(x, level + 1)).join(',\n') + '\n' + end + ']';
    }
    const entries = Object.entries(v as Obj).filter(([, x]) => x !== undefined);
    if (entries.length === 0) return '{}';
    return '{\n' + entries.map(([k, x]) => pad + JSON.stringify(k) + ': ' + pretty(x, level + 1)).join(',\n') + '\n' + end + '}';
}

export function canonicalText(v: unknown): string {
    return pretty(v, 0) + '\n';
}

const lf = (s: string) => s.replace(/\r\n/g, '\n');

/** Writes `text`, keeping the CRLF of an existing file. Returns false when nothing changed. */
function writeIfChanged(path: string, text: string): boolean {
    let out = text;
    if (existsSync(path)) {
        const old = readFileSync(path, 'utf-8');
        if (lf(old) === lf(text)) return false;
        if (old.includes('\r\n')) out = lf(text).replace(/\n/g, '\r\n');
    }
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, out, 'utf-8');
    return true;
}

// ------------------------------------------------------------------------------------------------------------
// Domains
// ------------------------------------------------------------------------------------------------------------

function checkDomains(raw: unknown, r: Report): Record<string, DomainDef> | undefined {
    if (!isObj(raw)) { r.error('domains', "'domains' must be an object { \"D1\": { ... } }"); return undefined; }
    const out: Record<string, DomainDef> = {};
    const owner: Array<{ id: string; lo: number; hi: number }> = [];
    const ids = Object.keys(raw).sort((a, b) => parseInt(a.slice(1), 10) - parseInt(b.slice(1), 10));
    for (const id of ids) {
        const key = `domain ${id}`;
        const d = raw[id];
        if (!DOMAIN_RE.test(id)) { r.error(key, `domain id must look like D1, D2, ... (got '${id}')`); continue; }
        if (!isObj(d)) { r.error(key, 'must be an object'); continue; }
        for (const k of Object.keys(d)) if (!['name', 'ranges', 'persistence', 'indexed', 'lifecycle', 'access'].includes(k)) r.error(key, `unknown key '${k}'`);
        if (!isStr(d.name)) r.error(key, "'name' is required");
        if (typeof d.indexed !== 'boolean') r.error(key, "'indexed' must be true or false");
        if (!isStr(d.persistence) || !(PERSISTENCE as readonly string[]).includes(d.persistence)) r.error(key, `'persistence' must be one of ${PERSISTENCE.join(', ')}`);
        const ranges: Array<[number, number]> = [];
        if (!Array.isArray(d.ranges)) r.error(key, "'ranges' must be a list of [low, high] global indices");
        else {
            for (const rg of d.ranges) {
                if (!Array.isArray(rg) || rg.length !== 2 || !isInt(rg[0]) || !isInt(rg[1]) || rg[0] < 0 || rg[1] < rg[0] || rg[1] >= FLAG_COUNT) {
                    r.error(key, `bad range ${JSON.stringify(rg)}: need [low, high] with 0 <= low <= high < ${FLAG_COUNT}`);
                    continue;
                }
                ranges.push([rg[0], rg[1]]);
                for (const o of owner) if (rg[0] <= o.hi && rg[1] >= o.lo) r.error(key, `range ${rangeText([[rg[0], rg[1]]])} overlaps ${o.id}`);
                owner.push({ id, lo: rg[0], hi: rg[1] });
            }
            if (d.indexed === true && ranges.length === 0) r.error(key, "an indexed domain needs at least one range");
            if (d.indexed === false && ranges.length > 0) r.error(key, "a domain with indexed:false (no bit index) must have empty ranges");
        }
        for (const k of ['lifecycle', 'access']) if (d[k] !== undefined && typeof d[k] !== 'string') r.error(key, `'${k}' must be text`);
        out[id] = {
            name: String(d.name ?? ''),
            ranges,
            persistence: String(d.persistence ?? ''),
            indexed: d.indexed === true,
            ...(typeof d.lifecycle === 'string' && d.lifecycle ? { lifecycle: d.lifecycle } : {}),
            ...(typeof d.access === 'string' && d.access ? { access: d.access } : {}),
        };
    }
    return out;
}

export function domainOf(domains: Record<string, DomainDef>, index: number): string | null {
    for (const [id, d] of Object.entries(domains)) {
        if (d.indexed && d.ranges.some(([lo, hi]) => index >= lo && index <= hi)) return id;
    }
    return null;
}

const isPersistent = (d: DomainDef) => d.persistence !== 'scene';

// ------------------------------------------------------------------------------------------------------------
// Scope
// ------------------------------------------------------------------------------------------------------------

function normalizeScope(raw: unknown, ctx: Context, key: string, where: string, r: Report): Scope | null | undefined {
    if (raw === null) return null;
    if (!isObj(raw)) { r.error(key, `${where}: scope must be null or { "scenes": [ids], "actors": [...] }`); return undefined; }
    let ok = true;
    for (const k of Object.keys(raw)) if (k !== 'scenes' && k !== 'actors') { r.error(key, `${where}: unknown scope key '${k}'`); ok = false; }
    if (!Array.isArray(raw.scenes) || raw.scenes.length === 0) { r.error(key, `${where}: scope.scenes must be a non-empty list of scene ids (use scope null for "everywhere")`); return undefined; }
    const scenes: number[] = [];
    for (const s of raw.scenes) {
        if (!isInt(s)) { r.error(key, `${where}: scene id ${JSON.stringify(s)} is not an integer (decimal id from db-us/groups.json)`); ok = false; continue; }
        if (!ctx.sceneIds.has(s)) { r.error(key, `${where}: scene id ${s} is not in db-us/groups.json`); ok = false; }
        if (!scenes.includes(s)) scenes.push(s);
    }
    let actors: string[] | undefined;
    if (raw.actors !== undefined) {
        if (!Array.isArray(raw.actors) || raw.actors.some(a => !isStr(a))) { r.error(key, `${where}: scope.actors must be a list of non-empty strings`); ok = false; }
        else actors = [...new Set(raw.actors as string[])].sort();
    }
    if (!ok) return undefined;
    scenes.sort((a, b) => a - b);
    return actors && actors.length > 0 ? { scenes, actors } : { scenes };
}

function scopesOverlap(a: Scope | null, b: Scope | null): boolean {
    if (a === null || b === null) return true;
    if (!a.scenes.some(s => b.scenes.includes(s))) return false;
    if (!a.actors || !b.actors) return true;
    return a.actors.some(x => b.actors!.includes(x));
}

const scopeText = (s: Scope | null) => (s === null ? 'everywhere' : `scenes ${s.scenes.map(x => '$' + hex(x, 2)).join(',')}${s.actors ? ' actors ' + s.actors.join(',') : ''}`);

// ------------------------------------------------------------------------------------------------------------
// Meaning records
// ------------------------------------------------------------------------------------------------------------

interface DomainInfo { id: string; def: DomainDef }

function stringList(raw: unknown, key: string, where: string, field: string, r: Report): string[] | undefined {
    if (raw === undefined) return undefined;
    if (!Array.isArray(raw) || raw.some(x => !isStr(x))) { r.error(key, `${where}: '${field}' must be a list of non-empty strings`); return undefined; }
    return [...new Set((raw as string[]).map(x => x.trim()))];
}

function refList(raw: unknown, key: string, where: string, field: string, r: Report): Ref[] | undefined {
    if (raw === undefined) return undefined;
    if (!Array.isArray(raw)) { r.error(key, `${where}: '${field}' must be a list of flag indices (decimal) or flag names`); return undefined; }
    const out: Ref[] = [];
    for (const x of raw) {
        if (isInt(x) && x >= 0 && x < FLAG_COUNT) out.push(x);
        else if (typeof x === 'string' && NAME_RE.test(x)) out.push(x);
        else r.error(key, `${where}: '${field}' entry ${JSON.stringify(x)} is neither a flag index (0-${FLAG_COUNT - 1}) nor a registry name`);
    }
    return out;
}

function checkMeaning(raw: unknown, where: string, key: string, dom: DomainInfo, ctx: Context, r: Report): Meaning | undefined {
    const before = r.errors.length;
    if (!isObj(raw)) { r.error(key, `${where}: must be an object`); return undefined; }
    for (const k of Object.keys(raw)) {
        if (MEANING_KEYS.includes(k)) continue;
        const hint = ['hex', 'address', 'mask'].includes(k) ? ' (derived from the index by the tool, do not write it)'
            : ['expectOld', 'patch', 'remove'].includes(k) ? ' (control key, only valid in a fragment)'
            : k === 'domain' ? ' (domain belongs on the index record, not on a meaning)' : '';
        r.error(key, `${where}: unknown key '${k}'${hint}`);
    }

    const levelRaw = raw.level ?? 'full';
    if (!(LEVELS as readonly string[]).includes(levelRaw as string)) r.error(key, `${where}: level must be one of ${LEVELS.join(', ')}`);
    const level = levelRaw === 'row' ? 'row' : 'full';
    if (level === 'row' && isPersistent(dom.def)) r.error(key, `${where}: level 'row' is for scene-scratch flags only; ${dom.id} (${dom.def.name}) is persistent and needs a full record`);

    // scope
    let scope: Scope | null | undefined;
    if (!('scope' in raw)) r.error(key, `${where}: 'scope' is required (null = same meaning everywhere)`);
    else scope = normalizeScope(raw.scope, ctx, key, where, r);
    if (scope === null && !isPersistent(dom.def)) r.error(key, `${where}: ${dom.id} (${dom.def.name}) is cleared at every scene load: a record needs a scope { "scenes": [...] } because the same index means different things in different scenes`);
    if (scope === null && level === 'row') r.error(key, `${where}: a row needs a scope`);

    // name
    let name: string | undefined;
    if (raw.name === undefined || raw.name === null || raw.name === '') {
        if (level === 'full') r.error(key, `${where}: 'name' is required (lower snake_case <area>_<subject>_<state>)`);
    } else if (typeof raw.name !== 'string' || !NAME_RE.test(raw.name)) {
        r.error(key, `${where}: name ${JSON.stringify(raw.name)} must be lower snake_case with at least two parts (<area>_<subject>_<state>)`);
    } else name = raw.name;

    // area
    let area: string | undefined;
    if (raw.area !== undefined && raw.area !== null && raw.area !== '') {
        if (typeof raw.area !== 'string' || !ctx.groupOrder.includes(raw.area)) r.error(key, `${where}: area '${String(raw.area)}' is not a group of db-us/groups.json (${ctx.groupOrder.join(', ')})`);
        else area = raw.area;
    } else if (scope) {
        const groups = new Set(scope.scenes.map(s => ctx.sceneGroup.get(s)));
        if (groups.size === 1) area = [...groups][0];
        else r.error(key, `${where}: 'area' is required (the scenes span ${groups.size} groups)`);
    } else r.error(key, `${where}: 'area' is required (a group of db-us/groups.json, or 'system' for engine flags)`);
    if (name && area) {
        const prefixes = new Set<string>();
        const p = ctx.groupPrefix.get(area);
        if (p) prefixes.add(p);
        if (area === 'system') prefixes.add('sys');
        if (prefixes.size > 0 && !prefixes.has(name.split('_')[0])) r.warn(`${key} ${name}: name prefix '${name.split('_')[0]}' differs from area '${area}' (${[...prefixes].join(' or ')})`);
    }

    // summary, stage, notes
    let summary: string | undefined;
    if (raw.summary === undefined || raw.summary === '') {
        r.error(key, `${where}: 'summary' is required (one sentence: what is true when the flag is set)`);
    } else if (!isStr(raw.summary)) r.error(key, `${where}: 'summary' must be text`);
    else summary = raw.summary.trim();
    let stage: string | undefined;
    if (raw.stage !== undefined) {
        if (typeof raw.stage !== 'string' || !STAGE_RE.test(raw.stage)) r.error(key, `${where}: stage must look like act1.edward_castle (lowercase, dots between parts)`);
        else stage = raw.stage;
    }
    let notes: string | undefined;
    if (raw.notes !== undefined && raw.notes !== '') {
        if (!isStr(raw.notes)) r.error(key, `${where}: 'notes' must be text`);
        else notes = raw.notes.trim();
    }

    // kinds, grade
    let kinds: string[] | undefined;
    if (raw.kinds !== undefined) {
        if (!Array.isArray(raw.kinds)) r.error(key, `${where}: 'kinds' must be a list`);
        else {
            kinds = [];
            for (const k of raw.kinds) {
                if (typeof k !== 'string' || !(KINDS as readonly string[]).includes(k)) r.error(key, `${where}: unknown kind ${JSON.stringify(k)} (allowed: ${KINDS.join(', ')})`);
                else if (!kinds.includes(k)) kinds.push(k);
            }
        }
    }
    if (level === 'full' && (raw.kinds === undefined || (Array.isArray(raw.kinds) && raw.kinds.length === 0))) r.error(key, `${where}: 'kinds' needs at least one entry (${KINDS.join(', ')})`);
    let grade: string | undefined;
    if (raw.grade !== undefined) {
        if (typeof raw.grade !== 'string' || !(GRADES as readonly string[]).includes(raw.grade)) r.error(key, `${where}: unknown grade ${JSON.stringify(raw.grade)} (allowed: ${GRADES.join(', ')}; CONTRADICTED is a verdict, not a grade)`);
        else grade = raw.grade;
    } else if (level === 'full') r.error(key, `${where}: 'grade' is required (${GRADES.join(', ')})`);

    // effects
    let effects: Meaning['effects'];
    if (raw.effects !== undefined) {
        if (!isObj(raw.effects)) r.error(key, `${where}: 'effects' must be { "set": text, "clear": text }`);
        else {
            effects = {};
            for (const k of Object.keys(raw.effects)) {
                if (k !== 'set' && k !== 'clear') { r.error(key, `${where}: unknown effects key '${k}' (set, clear)`); continue; }
                const v = raw.effects[k];
                if (!isStr(v)) r.error(key, `${where}: effects.${k} must be non-empty text`);
                else effects[k] = v.trim();
            }
            if (!effects.set && !effects.clear) effects = undefined;
        }
    }

    const requires = refList(raw.requires, key, where, 'requires', r);
    const excludes = refList(raw.excludes, key, where, 'excludes', r);
    const pairsWith = refList(raw.pairsWith, key, where, 'pairsWith', r);
    const evidence = stringList(raw.evidence, key, where, 'evidence', r);
    const queue = stringList(raw.queue, key, where, 'queue', r);
    const proposedBy = stringList(raw.proposedBy, key, where, 'proposedBy', r);
    for (const e of evidence ?? []) {
        if (!/[^\s:]+:\d+/.test(e) && !/\{\d+\}/.test(e)) r.warn(`${key} ${name ?? ''}: evidence '${clip(e, 60)}' has no file:line or {ROM offset}`);
    }

    // runtime
    let runtime: Meaning['runtime'];
    if (raw.runtime !== undefined) {
        if (!isObj(raw.runtime)) r.error(key, `${where}: 'runtime' must be { "result": id, "trial": text }`);
        else {
            for (const k of Object.keys(raw.runtime)) if (!['result', 'trial', 'rom'].includes(k)) r.error(key, `${where}: unknown runtime key '${k}' (result, trial, rom)`);
            if (!isStr(raw.runtime.result)) r.error(key, `${where}: runtime.result is required (the FR result id)`);
            else {
                runtime = { result: raw.runtime.result.trim() };
                if (isStr(raw.runtime.trial)) runtime.trial = raw.runtime.trial.trim();
                if (isStr(raw.runtime.rom)) runtime.rom = raw.runtime.rom.trim();
            }
        }
    }

    // grade rules
    if (grade === 'VERIFIED-RUNTIME' && !runtime) r.error(key, `${where}: VERIFIED-RUNTIME needs runtime.result (the FR result that proves it)`);
    if (grade && grade !== 'UNKNOWN' && (!evidence || evidence.length === 0)) r.error(key, `${where}: grade ${grade} needs evidence (file:line {ROM offset})`);
    if (grade === 'UNKNOWN' && (!evidence || evidence.length === 0) && !notes) r.warn(`${key} ${name ?? ''}: UNKNOWN with neither evidence nor notes (say what was tried)`);
    if ((grade === 'INFERRED' || grade === 'UNKNOWN') && (!queue || queue.length === 0)) r.warn(`${key} ${name ?? ''}: ${grade} without a runtime-queue id in 'queue'`);

    if (r.errors.length > before) return undefined;
    const m: Meaning = { scope: scope ?? null };
    const ordered: Meaning = {
        ...(name ? { name } : {}),
        ...(level === 'row' ? { level } : {}),
        ...(area ? { area } : {}),
        scope: m.scope,
        ...(summary ? { summary } : {}),
        ...(stage ? { stage } : {}),
        ...(kinds && kinds.length > 0 ? { kinds } : {}),
        ...(grade ? { grade } : {}),
        ...(effects ? { effects } : {}),
        ...(requires && requires.length > 0 ? { requires } : {}),
        ...(excludes && excludes.length > 0 ? { excludes } : {}),
        ...(pairsWith && pairsWith.length > 0 ? { pairsWith } : {}),
        ...(evidence && evidence.length > 0 ? { evidence } : {}),
        ...(runtime ? { runtime } : {}),
        ...(queue && queue.length > 0 ? { queue } : {}),
        ...(proposedBy && proposedBy.length > 0 ? { proposedBy: [...proposedBy].sort() } : {}),
        ...(notes ? { notes } : {}),
    };
    return ordered;
}

function compareMeanings(a: Meaning, b: Meaning): number {
    if (a.scope === null && b.scope !== null) return -1;
    if (a.scope !== null && b.scope === null) return 1;
    if (a.scope && b.scope) {
        const d = a.scope.scenes[0] - b.scope.scenes[0];
        if (d !== 0) return d;
    }
    return canon(a.scope).localeCompare(canon(b.scope));
}

function makeRecord(index: number, domain: string, meanings: Meaning[]): FlagRecord {
    const loc = flagLocation(index);
    return { hex: loc.hex, address: loc.addressHex, mask: loc.maskHex, domain, meanings: [...meanings].sort(compareMeanings) };
}

// ------------------------------------------------------------------------------------------------------------
// Proposals
// ------------------------------------------------------------------------------------------------------------

function checkProposal(raw: unknown, where: string, key: string, dom: DomainInfo, ctx: Context, r: Report): Proposal | undefined {
    const before = r.errors.length;
    if (!isObj(raw)) { r.error(key, `${where}: must be an object`); return undefined; }
    for (const k of Object.keys(raw)) if (!PROPOSAL_KEYS.includes(k)) r.error(key, `${where}: unknown key '${k}' (${PROPOSAL_KEYS.join(', ')})`);
    if (typeof raw.source !== 'string' || !SOURCE_RE.test(raw.source)) r.error(key, `${where}: 'source' is required (the iteration id, for example FL21)`);
    const scope = 'scope' in raw ? normalizeScope(raw.scope, ctx, key, where, r) : null;
    if (scope === null && !isPersistent(dom.def)) r.error(key, `${where}: ${dom.id} is scene scratch: a proposal needs a scope`);
    if (typeof raw.name !== 'string' || !NAME_RE.test(raw.name)) r.error(key, `${where}: 'name' must be lower snake_case with at least two parts`);
    if (!isStr(raw.summary)) r.error(key, `${where}: 'summary' is required`);
    if (typeof raw.confidence !== 'string' || !(CONFIDENCE as readonly string[]).includes(raw.confidence)) r.error(key, `${where}: 'confidence' must be one of ${CONFIDENCE.join(', ')}`);
    let kinds: string[] | undefined;
    if (raw.kinds !== undefined) {
        if (!Array.isArray(raw.kinds) || raw.kinds.some(k => typeof k !== 'string' || !(KINDS as readonly string[]).includes(k))) r.error(key, `${where}: 'kinds' must be a list from ${KINDS.join(', ')}`);
        else kinds = [...new Set(raw.kinds as string[])];
    }
    const roles = stringList(raw.roles, key, where, 'roles', r);
    if (raw.notes !== undefined && !isStr(raw.notes)) r.error(key, `${where}: 'notes' must be text`);
    if (r.errors.length > before) return undefined;
    return {
        source: raw.source as string,
        scope: scope ?? null,
        name: raw.name as string,
        summary: (raw.summary as string).trim(),
        ...(kinds && kinds.length > 0 ? { kinds } : {}),
        ...(roles && roles.length > 0 ? { roles } : {}),
        confidence: raw.confidence as string,
        ...(isStr(raw.notes) ? { notes: raw.notes.trim() } : {}),
    };
}

const proposalId = (p: Proposal) => p.source + '|' + canon(p.scope);

// ------------------------------------------------------------------------------------------------------------
// Registry: validation of a whole state (stored file, or the result of a merge)
// ------------------------------------------------------------------------------------------------------------

export function validateRegistry(raw: unknown, ctx: Context, r: Report, opts: { refsStrict: boolean }): Registry | undefined {
    if (!isObj(raw)) { r.error('registry', 'must be a JSON object { schema, domains, flags }'); return undefined; }
    for (const k of Object.keys(raw)) if (!['schema', 'domains', 'flags', 'proposals'].includes(k)) r.error('registry', `unknown top-level key '${k}'`);
    if (raw.schema !== SCHEMA) r.error('registry', `schema must be ${SCHEMA}`);
    const domains = checkDomains(raw.domains, r);
    if (!domains) return undefined;
    if (!isObj(raw.flags)) { r.error('registry', "'flags' must be an object keyed by decimal index"); return undefined; }

    const flags: Record<string, FlagRecord> = {};
    for (const key of Object.keys(raw.flags).sort((a, b) => Number(a) - Number(b))) {
        const label = `index ${key}`;
        const rec = raw.flags[key];
        if (!/^\d+$/.test(key) || String(Number(key)) !== key) { r.error(label, `key must be a decimal global index (no hex, no leading zeros)${/^\$|^0x/i.test(key) ? `; ${key} is hex = ${parseInt(key.replace('$', ''), 16)}` : ''}`); continue; }
        const index = Number(key);
        if (index >= FLAG_COUNT) { r.error(label, `outside the flag array (valid: 0-${FLAG_COUNT - 1}, bytes $0A00-$0AB3)`); continue; }
        if (!isObj(rec)) { r.error(label, 'must be an object'); continue; }
        for (const k of Object.keys(rec)) if (!['hex', 'address', 'mask', 'domain', 'meanings'].includes(k)) r.error(label, `unknown key '${k}'`);
        const dom = checkDomainOfIndex(index, rec.domain, domains, label, r);
        const loc = flagLocation(index);
        if (rec.hex !== undefined && rec.hex !== loc.hex) r.error(label, `hex ${JSON.stringify(rec.hex)} does not match the index (expected ${loc.hex})`);
        if (rec.address !== undefined && rec.address !== loc.addressHex) r.error(label, `address ${JSON.stringify(rec.address)} does not match the index (expected ${loc.addressHex})`);
        if (rec.mask !== undefined && rec.mask !== loc.maskHex) r.error(label, `mask ${JSON.stringify(rec.mask)} does not match the index (expected ${loc.maskHex})`);
        if (!dom) continue;
        if (!Array.isArray(rec.meanings) || rec.meanings.length === 0) { r.error(label, "'meanings' must be a non-empty list"); continue; }
        const meanings: Meaning[] = [];
        rec.meanings.forEach((m, i) => {
            const norm = checkMeaning(m, `meaning #${i + 1}`, label, dom, ctx, r);
            if (norm) meanings.push(norm);
        });
        if (meanings.length === rec.meanings.length) {
            checkIndexRules(index, dom, meanings, label, r);
            flags[key] = makeRecord(index, dom.id, meanings);
        }
    }

    checkNameRules(flags, domains, r);

    const registry: Registry = { schema: SCHEMA, domains, flags };
    if (raw.proposals !== undefined) {
        const proposals = checkProposals(raw.proposals, flags, domains, ctx, r);
        if (proposals && Object.keys(proposals).length > 0) registry.proposals = proposals;
    }
    checkRefs(registry, r, opts.refsStrict);
    return registry;
}

function checkDomainOfIndex(index: number, domainRaw: unknown, domains: Record<string, DomainDef>, label: string, r: Report): DomainInfo | undefined {
    const expected = domainOf(domains, index);
    if (!isStr(domainRaw)) { r.error(label, `'domain' is required${expected ? ` (${expected})` : ''}`); return undefined; }
    const def = domains[domainRaw];
    if (!def) { r.error(label, `unknown domain '${domainRaw}' (${Object.keys(domains).join(', ')})`); return undefined; }
    if (!def.indexed) { r.error(label, `${domainRaw} (${def.name}) has no bit index: state gates are not stored here yet (FL40 extends the tool)`); return undefined; }
    if (expected !== domainRaw) {
        r.error(label, `index ${index} ($${hex(index, 4)}) is outside ${domainRaw} ${rangeText(def.ranges)}${expected ? `; it belongs to ${expected}` : '; no domain covers it'}`);
        return undefined;
    }
    return { id: domainRaw, def };
}

/** Rules between the meanings of one index. */
function checkIndexRules(index: number, dom: DomainInfo, meanings: Meaning[], label: string, r: Report) {
    const seen = new Set<string>();
    for (const m of meanings) {
        const k = canon(m.scope);
        if (seen.has(k)) r.error(label, `two meanings share the scope ${scopeText(m.scope)}`);
        seen.add(k);
    }
    for (let i = 0; i < meanings.length; i++) {
        for (let j = i + 1; j < meanings.length; j++) {
            if (canon(meanings[i].scope) === canon(meanings[j].scope)) continue;
            if (meanings[i].scope === null || meanings[j].scope === null) continue;   //global next to scoped: reported below for persistent flags
            if (scopesOverlap(meanings[i].scope, meanings[j].scope)) {
                r.error(label, `scopes overlap (${scopeText(meanings[i].scope)} and ${scopeText(meanings[j].scope)}): the same index in the same scene has one meaning`);
            }
        }
    }
    if (isPersistent(dom.def)) {
        const global = meanings.filter(m => m.scope === null);
        const scoped = meanings.filter(m => m.scope !== null);
        if (global.length > 0 && scoped.length > 0) r.error(label, `${dom.id} is persistent: a global meaning (scope null) cannot coexist with scoped meanings; index reuse needs every meaning scoped (re-scope the global one with expectOld)`);
        if (global.length === 0 && scoped.length === 1) r.error(label, `${dom.id} is persistent and this meaning is global: use scope null (a scope is only for an index reused with a different meaning, which needs at least two scoped meanings)`);
    }
}

/** Persistent names are unique registry-wide; a D1 name repeats only at the same index and never equals a persistent name. */
function checkNameRules(flags: Record<string, FlagRecord>, domains: Record<string, DomainDef>, r: Report) {
    const uses = new Map<string, Array<{ index: number; persistent: boolean; scope: string }>>();
    for (const [key, rec] of Object.entries(flags)) {
        const persistent = isPersistent(domains[rec.domain]);
        for (const m of rec.meanings) {
            if (!m.name) continue;
            const list = uses.get(m.name) ?? [];
            list.push({ index: Number(key), persistent, scope: canon(m.scope) });
            uses.set(m.name, list);
        }
    }
    for (const [name, list] of uses) {
        if (list.length < 2) continue;
        const persistentUse = list.find(u => u.persistent);
        const first = list[0];
        for (const u of list.slice(1)) {
            if (persistentUse) {
                r.error(`index ${u.index}`, `duplicate name '${name}': also used by index ${first.index === u.index ? list.find(x => x !== u)!.index : first.index} (persistent names are unique across the registry, and no scratch name may equal one)`);
            } else if (u.index !== first.index) {
                r.error(`index ${u.index}`, `duplicate name '${name}': scratch names may repeat only at the same index (also at index ${first.index})`);
            } else if (u.scope === first.scope) {
                r.error(`index ${u.index}`, `duplicate name '${name}' within the same index and scope`);
            }
        }
    }
}

function checkProposals(raw: unknown, flags: Record<string, FlagRecord>, domains: Record<string, DomainDef>, ctx: Context, r: Report): Record<string, Proposal[]> | undefined {
    if (!isObj(raw)) { r.error('proposals', "'proposals' must be an object keyed by decimal index"); return undefined; }
    const out: Record<string, Proposal[]> = {};
    for (const key of Object.keys(raw).sort((a, b) => Number(a) - Number(b))) {
        const label = `proposals ${key}`;
        if (!/^\d+$/.test(key) || String(Number(key)) !== key || Number(key) >= FLAG_COUNT) { r.error(label, `key must be a decimal index 0-${FLAG_COUNT - 1}`); continue; }
        const index = Number(key);
        const domainId = domainOf(domains, index);
        if (!domainId) { r.error(label, `index ${index} is outside every domain`); continue; }
        if (flags[key]) r.error(label, `index ${index} already has a record: proposals are consumed when a record is merged (edit the record instead)`);
        const list = raw[key];
        if (!Array.isArray(list) || list.length === 0) { r.error(label, 'must be a non-empty list'); continue; }
        const dom = { id: domainId, def: domains[domainId] };
        const norm: Proposal[] = [];
        const ids = new Set<string>();
        list.forEach((p, i) => {
            const n = checkProposal(p, `proposal #${i + 1}`, label, dom, ctx, r);
            if (!n) return;
            if (ids.has(proposalId(n))) r.error(label, `two proposals from ${n.source} for the same scope`);
            ids.add(proposalId(n));
            norm.push(n);
        });
        norm.sort((a, b) => a.source.localeCompare(b.source) || canon(a.scope).localeCompare(canon(b.scope)));
        out[key] = norm;
    }
    return out;
}

/** requires / excludes / pairsWith: names must exist, indices should have a record. */
function checkRefs(reg: Registry, r: Report, strict: boolean) {
    const nameIndex = buildNameIndex(reg);
    for (const [key, rec] of Object.entries(reg.flags)) {
        for (const m of rec.meanings) {
            for (const field of ['requires', 'excludes', 'pairsWith'] as const) {
                for (const ref of m[field] ?? []) {
                    const here = `index ${key}${m.name ? ' ' + m.name : ''}`;
                    if (typeof ref === 'number') {
                        if (ref === Number(key)) r.error(`index ${key}`, `${field} refers to the flag itself`);
                        else if (!reg.flags[String(ref)]) r.warn(`${here}: ${field} index ${ref} has no record yet`);
                    } else {
                        const hit = nameIndex.get(ref);
                        if (!hit) {
                            if (strict) r.error(`index ${key}`, `${field} name '${ref}' is not in the registry`);
                            else r.warn(`${here}: ${field} name '${ref}' is not in the registry yet`);
                        } else if (hit.length === 1 && hit[0].index === Number(key)) r.error(`index ${key}`, `${field} refers to the flag itself ('${ref}')`);
                    }
                }
            }
        }
    }
}

export function buildNameIndex(reg: Registry): Map<string, Array<{ index: number; meaning: Meaning }>> {
    const map = new Map<string, Array<{ index: number; meaning: Meaning }>>();
    for (const [key, rec] of Object.entries(reg.flags)) {
        for (const m of rec.meanings) {
            if (!m.name) continue;
            const list = map.get(m.name) ?? [];
            list.push({ index: Number(key), meaning: m });
            map.set(m.name, list);
        }
    }
    return map;
}

export function serializeRegistry(reg: Registry): string {
    const flags: Record<string, unknown> = {};
    for (const key of Object.keys(reg.flags).sort((a, b) => Number(a) - Number(b))) {
        const rec = reg.flags[key];
        flags[key] = { hex: rec.hex, address: rec.address, mask: rec.mask, domain: rec.domain, meanings: [...rec.meanings].sort(compareMeanings) };
    }
    const domains: Record<string, unknown> = {};
    for (const id of Object.keys(reg.domains).sort((a, b) => parseInt(a.slice(1), 10) - parseInt(b.slice(1), 10))) {
        const d = reg.domains[id];
        domains[id] = { name: d.name, ranges: d.ranges, persistence: d.persistence, indexed: d.indexed, ...(d.lifecycle ? { lifecycle: d.lifecycle } : {}), ...(d.access ? { access: d.access } : {}) };
    }
    const out: Record<string, unknown> = { schema: reg.schema, domains, flags };
    if (reg.proposals && Object.keys(reg.proposals).length > 0) {
        const proposals: Record<string, unknown> = {};
        for (const key of Object.keys(reg.proposals).sort((a, b) => Number(a) - Number(b))) proposals[key] = reg.proposals[key];
        out.proposals = proposals;
    }
    return canonicalText(out);
}

// ------------------------------------------------------------------------------------------------------------
// Loading
// ------------------------------------------------------------------------------------------------------------

function readJson(path: string, label: string, r: Report): unknown | undefined {
    if (!existsSync(path)) { r.error(label, `file not found: ${path}`); return undefined; }
    try { return JSON.parse(readFileSync(path, 'utf-8')); } catch (e) { r.error(label, `not valid JSON: ${e instanceof Error ? e.message : e}`); return undefined; }
}

function loadRegistry(paths: Paths, ctx: Context, r: Report, refsStrict: boolean, label = 'flags.json'): { reg: Registry; text: string } | undefined {
    const raw = readJson(paths.flags, label, r);
    if (raw === undefined) return undefined;
    const reg = validateRegistry(raw, ctx, r, { refsStrict });
    if (!reg) return undefined;
    return { reg, text: readFileSync(paths.flags, 'utf-8') };
}

// ------------------------------------------------------------------------------------------------------------
// Generic "expectOld" editing (shared by flags, scene-flags and presets; same idea as `merge`)
// ------------------------------------------------------------------------------------------------------------

/** null when `stored` matches `old`; otherwise the reason. A string must equal `stringField`; an object compares field by field (text = substring, case-insensitive). */
function matchOld(stored: Obj, old: unknown, stringField: string | null): string | null {
    if (typeof old === 'string') {
        if (stringField === null) return 'expectOld must be an object { field: text or value }';
        return stored[stringField] === old ? null : `${stringField} is '${clip(String(stored[stringField]))}', expectOld says '${clip(old)}'`;
    }
    if (!isObj(old) || Object.keys(old).length === 0) return `expectOld must be ${stringField ? 'the current ' + stringField + ' or ' : ''}a non-empty object { field: text or value }`;
    for (const [k, v] of Object.entries(old)) {
        const sv = stored[k];
        if (typeof v === 'string' && typeof sv === 'string') {
            if (!sv.toLowerCase().includes(v.toLowerCase())) return `${k} is '${clip(sv)}', which does not contain '${clip(v)}'`;
        } else if (canon(sv ?? null) !== canon(v)) return `${k} is ${clip(canon(sv ?? null))}, expectOld says ${clip(canon(v))}`;
    }
    return null;
}

/** Patch: listed fields replace; null removes a field (for `scope`, null means "everywhere"). */
function applyPatch(existing: Obj, patch: Obj): Obj {
    const out: Obj = { ...existing };
    for (const [k, v] of Object.entries(patch)) {
        if (v === null && k !== 'scope') delete out[k];
        else out[k] = v;
    }
    return out;
}

function controlKeys(entry: Obj, label: string, key: string, r: Report): { fields: Obj; expectOld?: unknown; patch: boolean; remove: boolean; bad: boolean } {
    const { expectOld, patch, remove, ...fields } = entry;
    const before = r.errors.length;
    if (patch !== undefined && typeof patch !== 'boolean') r.error(key, `${label}: 'patch' must be true or false`);
    if (remove !== undefined && typeof remove !== 'boolean') r.error(key, `${label}: 'remove' must be true or false`);
    const p = patch === true, rm = remove === true;
    if ((p || rm) && expectOld === undefined) r.error(key, `${label}: ${p ? 'patch' : 'remove'} requires expectOld (the guard that proves you edit the record you think you do)`);
    if (p && rm) r.error(key, `${label}: patch and remove cannot be combined`);
    return { fields, expectOld, patch: p, remove: rm, bad: r.errors.length > before };
}

// ------------------------------------------------------------------------------------------------------------
// Merge: flag fragments
// ------------------------------------------------------------------------------------------------------------

export interface MergeResult {
    ok: boolean;
    added: number;
    changed: number;
    unchanged: number;
    removed: number;
    rejected: number;
    errors: string[];
    warnings: string[];
    filesChanged: string[];
}

/** `note` lines are printed but not counted. */
interface Op { kind: 'add' | 'change' | 'unchanged' | 'remove' | 'note'; text: string }

function newResult(): MergeResult {
    return { ok: false, added: 0, changed: 0, unchanged: 0, removed: 0, rejected: 0, errors: [], warnings: [], filesChanged: [] };
}

function finish(result: MergeResult, r: Report, ops: Op[], head: string, fileLabels: string[], options: FlagsOptions, write: () => string[]): MergeResult {
    for (const op of ops) {
        if (op.kind === 'add') result.added++;
        else if (op.kind === 'change') result.changed++;
        else if (op.kind === 'unchanged') result.unchanged++;
        else if (op.kind === 'remove') result.removed++;
    }
    result.rejected = r.rejected;
    result.warnings = r.warnings;
    result.errors = r.errors.map(e => `${e.key}: ${e.msg}`);
    if (!r.ok) {
        //Nothing is applied when anything is rejected: do not print the speculative adds and changes.
        result.added = result.changed = result.unchanged = result.removed = 0;
        console.log(`${head}: +0 added, ~0 changed, =0 unchanged, x${result.rejected} rejected`);
    } else {
        console.log(`${head}: +${result.added} added, ~${result.changed} changed, =${result.unchanged} unchanged${result.removed ? `, -${result.removed} removed` : ''}, x0 rejected`);
        for (const op of ops) if (op.kind !== 'unchanged') console.log(`  ${op.kind.padEnd(6)} ${op.text}`);
    }
    for (const w of r.warnings) console.warn(`  ! ${w}`);
    if (!r.ok) {
        console.error('\nNothing written (fix the errors and re-run).\n\nErrors:');
        for (const e of result.errors) console.error(`  X ${e}`);
        return result;
    }
    const changedFiles = options.dryRun ? fileLabels : write();
    result.filesChanged = changedFiles;
    result.ok = true;
    if (options.dryRun) console.log(`\n[DRY RUN] ${fileLabels.length} file(s) would change; nothing written.`);
    else if (changedFiles.length > 0) console.log(`\nWrote ${changedFiles.join(', ')}.\n\nNext: npm run flags -- --check`);
    else console.log('\nNothing to change.');
    return result;
}

export function mergeFlags(root: string, fragmentPath: string, options: FlagsOptions = {}): MergeResult {
    const paths = dbPaths(root, options.dbDir);
    const result = newResult();
    const r = new Report();
    const ops: Op[] = [];
    const bail = (): MergeResult => finish(result, r, ops, 'Flags', [], options, () => []);

    let ctx: Context;
    try { ctx = loadContext(paths); } catch (e) { r.error('db', String(e instanceof Error ? e.message : e)); return bail(); }
    const pre = new Report();
    const loaded = loadRegistry(paths, ctx, pre, false);
    if (!loaded) { for (const e of pre.errors) r.error(e.key, e.msg); return bail(); }
    if (!pre.ok) {
        r.error('flags.json', 'the registry is invalid before this merge: run `npm run flags -- --check` and fix it first');
        for (const e of pre.errors) r.error(e.key, e.msg);
        return bail();
    }

    const specAbs = resolve(fragmentPath);
    const fragment = readJson(specAbs, 'fragment', r);
    if (fragment === undefined) return bail();
    if (!isObj(fragment)) { r.error('fragment', "must be a JSON object { \"flags\": { \"<index>\": { \"domain\", \"meanings\": [...] } }, \"proposals\": {...}, \"domains\": {...} }"); return bail(); }
    for (const k of Object.keys(fragment)) {
        if (k.startsWith('_') || k.startsWith('$')) continue;
        if (!['flags', 'proposals', 'domains'].includes(k)) r.error('fragment', `unknown top-level key '${k}' (flags, proposals, domains; keys starting with _ or $ are ignored)`);
    }

    const work: Registry = JSON.parse(JSON.stringify(loaded.reg));

    // ---- domains
    if (fragment.domains !== undefined) {
        if (!isObj(fragment.domains)) r.error('domains', "'domains' must be an object");
        else {
            const merged: Obj = { ...work.domains };
            for (const [id, def] of Object.entries(fragment.domains)) merged[id] = def;
            const dr = new Report();
            const checked = checkDomains(merged, dr);
            for (const e of dr.errors) r.error(e.key, e.msg);
            if (checked && dr.ok) {
                for (const id of Object.keys(fragment.domains)) {
                    const same = canon(work.domains[id]) === canon(checked[id]);
                    ops.push({ kind: same ? 'unchanged' : (work.domains[id] ? 'change' : 'add'), text: `domain ${id} ${checked[id].name} ${rangeText(checked[id].ranges)}` });
                }
                work.domains = checked;
            }
        }
    }

    // ---- flag records
    const touched = new Map<number, Set<string>>();   // index -> scope keys of the meanings added or changed in this run
    const markTouched = (index: number, scope: Scope | null) => touched.set(index, (touched.get(index) ?? new Set<string>()).add(canon(scope)));
    const claimed = new Set<string>();
    if (fragment.flags !== undefined && !isObj(fragment.flags)) r.error('flags', "'flags' must be an object keyed by decimal index");
    const flagEntries = isObj(fragment.flags) ? Object.entries(fragment.flags) : [];
    for (const [key, entryRaw] of flagEntries) {
        const label = `index ${key}`;
        if (!/^\d+$/.test(key) || String(Number(key)) !== key) { r.error(label, `key must be a decimal global index${/^\$|^0x/i.test(key) ? ` (${key} is hex: use ${parseInt(key.replace(/^\$|^0x/i, ''), 16)})` : ''}`); continue; }
        const index = Number(key);
        if (index >= FLAG_COUNT) { r.error(label, `outside the flag array (valid: 0-${FLAG_COUNT - 1}, bytes $0A00-$0AB3)`); continue; }
        if (!isObj(entryRaw)) { r.error(label, 'must be an object { "domain", "meanings": [...] }'); continue; }
        for (const k of Object.keys(entryRaw)) if (k !== 'domain' && k !== 'meanings') r.error(label, `unknown key '${k}' (domain, meanings${['hex', 'address', 'mask'].includes(k) ? '; hex/address/mask are derived by the tool' : ''})`);
        const dom = checkDomainOfIndex(index, entryRaw.domain, work.domains, label, r);
        if (!dom) continue;
        if (!Array.isArray(entryRaw.meanings) || entryRaw.meanings.length === 0) { r.error(label, "'meanings' must be a non-empty list"); continue; }

        const list: Meaning[] = (work.flags[key]?.meanings ?? []).map(m => JSON.parse(JSON.stringify(m)) as Meaning);
        entryRaw.meanings.forEach((raw, k) => {
            const where = `meaning #${k + 1}`;
            const mkey = label;
            if (!isObj(raw)) { r.error(mkey, `${where}: must be an object`); return; }
            const ctl = controlKeys(raw, where, mkey, r);
            if (ctl.bad) return;
            if ('proposedBy' in ctl.fields) { r.error(mkey, `${where}: 'proposedBy' is written by the tool when proposals are consumed`); return; }

            let target: Meaning | undefined;
            let sameScope: Meaning | undefined;
            if (ctl.expectOld !== undefined) {
                if (list.length === 0) { r.error(mkey, `${where}: expectOld given but this index has no record to edit`); return; }
                const reasons: string[] = [];
                const hits = list.filter(m => {
                    const why = matchOld(m as unknown as Obj, ctl.expectOld, 'name');
                    if (why) reasons.push(`${m.name ?? '(row)'}: ${why}`);
                    return why === null;
                });
                if (hits.length === 0) { r.error(mkey, `${where}: expectOld does not match any stored meaning (${reasons.join('; ')})`); return; }
                if (hits.length > 1) { r.error(mkey, `${where}: expectOld matches ${hits.length} meanings; add 'scope' to expectOld`); return; }
                target = hits[0];
            } else if ('scope' in ctl.fields) {
                const sk = canon(ctl.fields.scope);
                sameScope = list.find(m => canon(m.scope) === sk);
            }

            if (ctl.remove) {
                list.splice(list.indexOf(target!), 1);
                ops.push({ kind: 'remove', text: `${key} ${target!.name ?? '(row)'} [${scopeText(target!.scope)}]` });
                return;
            }

            const base = target ?? sameScope;
            let candidate: Obj;
            if (ctl.patch) candidate = applyPatch(base as unknown as Obj, ctl.fields);
            else {
                candidate = { ...ctl.fields };
                if (base?.proposedBy) candidate.proposedBy = base.proposedBy;
            }
            const norm = checkMeaning(candidate, where, mkey, dom, ctx, r);
            if (!norm) return;
            const claim = `${index}|${canon(norm.scope)}`;
            if (claimed.has(claim)) { r.error(mkey, `${where}: index ${index} with ${scopeText(norm.scope)} appears twice in this fragment`); return; }
            claimed.add(claim);

            const text = `${key} ${norm.name ?? '(row)'} [${scopeText(norm.scope)}] ${dom.id}${norm.grade ? ' ' + norm.grade : ''}`;
            if (target) {
                const same = canon(target) === canon(norm);
                list[list.indexOf(target)] = norm;
                ops.push({ kind: same ? 'unchanged' : 'change', text });
                if (!same) markTouched(index, norm.scope);
            } else if (sameScope) {
                if (canon(sameScope) === canon(norm)) ops.push({ kind: 'unchanged', text });
                else r.error(mkey, `${where}: ${scopeText(norm.scope)} already has a meaning ('${sameScope.name ?? '(row)'}'); add "expectOld" (the stored name, or { field: text }) to replace it, or "patch": true to change single fields`);
            } else {
                list.push(norm);
                ops.push({ kind: 'add', text });
                markTouched(index, norm.scope);
            }
        });
        if (list.length === 0) delete work.flags[key];
        else work.flags[key] = makeRecord(index, dom.id, list);
    }

    // ---- proposals
    let proposalsAdded = 0, proposalsChanged = 0;
    if (fragment.proposals !== undefined) {
        if (!isObj(fragment.proposals)) r.error('proposals', "'proposals' must be an object keyed by decimal index");
        else {
            const pr = new Report();
            const checked = checkProposals(fragment.proposals, work.flags, work.domains, ctx, pr);
            for (const e of pr.errors) r.error(e.key, e.msg);
            if (checked && pr.ok) {
                work.proposals ??= {};
                for (const [key, list] of Object.entries(checked)) {
                    const stored: Proposal[] = work.proposals[key] ?? [];
                    for (const p of list) {
                        const at = stored.findIndex(x => proposalId(x) === proposalId(p));
                        const text = `${key} proposal ${p.source} ${p.name} (${p.confidence})`;
                        if (at < 0) { stored.push(p); proposalsAdded++; ops.push({ kind: 'add', text }); }
                        else if (canon(stored[at]) === canon(p)) ops.push({ kind: 'unchanged', text });
                        else { stored[at] = p; proposalsChanged++; ops.push({ kind: 'change', text }); }
                    }
                    work.proposals[key] = stored;
                }
            }
        }
    }

    // ---- promotion: a record at an index consumes that index's proposals
    let consumed = 0;
    for (const [index, scopes] of touched) {
        const key = String(index);
        const list = work.proposals?.[key];
        if (!list || list.length === 0) continue;
        const sources = [...new Set(list.map(p => p.source))].sort();
        const rec = work.flags[key];
        for (const m of rec.meanings) {
            if (scopes.has(canon(m.scope))) m.proposedBy = [...new Set([...(m.proposedBy ?? []), ...sources])].sort();
        }
        consumed += list.length;
        delete work.proposals![key];
        ops.push({ kind: 'note', text: `${key} proposals consumed: ${list.map(p => `${p.source}:${p.name}`).join(', ')}` });
    }
    if (work.proposals && Object.keys(work.proposals).length === 0) delete work.proposals;

    // ---- whole-state rules (reuse rule, scope overlap, names, references)
    let finalReg: Registry | undefined;
    if (r.ok) {
        const sr = new Report();
        finalReg = validateRegistry(JSON.parse(JSON.stringify(work)), ctx, sr, { refsStrict: false });
        for (const e of sr.errors) r.error(e.key, e.msg);
        for (const w of sr.warnings) if (!pre.warnings.includes(w)) r.warn(w);
    }

    const rel = toPosix(relative(root, paths.flags));
    const head = `Flags: ${flagEntries.length} index record(s)${proposalsAdded + proposalsChanged > 0 || consumed > 0 ? `, proposals +${proposalsAdded} ~${proposalsChanged} consumed ${consumed}` : ''}`;
    const nextText = finalReg ? serializeRegistry(finalReg) : '';
    const willChange = finalReg ? lf(nextText) !== lf(loaded.text) : false;
    return finish(result, r, ops, head, willChange ? [rel] : [], options, () => {
        const changed = writeIfChanged(paths.flags, nextText);
        const check = new Report();
        const again = loadRegistry(paths, ctx, check, false);
        if (!again || !check.ok || lf(serializeRegistry(again.reg)) !== lf(nextText)) throw new Error('verification failed: flags.json does not read back as written');
        return changed ? [rel] : [];
    });
}

// ------------------------------------------------------------------------------------------------------------
// Scene flags (db-us/scene-flags.json)
// ------------------------------------------------------------------------------------------------------------

function nameLookup(reg: Registry | null) {
    const index = reg ? buildNameIndex(reg) : null;
    return (name: string) => index?.get(name);
}

/**
 * Checks one scene-flags entry. With `spec` true the entry may omit `flags` (derived from `names`).
 * `reg` null = no registry: names are not checked (the exporter's behavior before a registry exists).
 */
export function checkSceneFlagEntry(sceneKey: string, raw: unknown, reg: Registry | null, r: Report, spec: boolean): SceneFlagEntry | undefined {
    const key = `scene ${sceneKey}`;
    const before = r.errors.length;
    if (!isObj(raw)) { r.error(key, 'must be an object { flags, names, entry, grade, note, source }'); return undefined; }
    for (const k of Object.keys(raw)) if (!SCENE_FLAG_KEYS.includes(k)) r.error(key, `unknown key '${k}' (${SCENE_FLAG_KEYS.join(', ')})`);

    let names: string[] | undefined;
    const derived: number[] = [];
    if (raw.names !== undefined) {
        if (!Array.isArray(raw.names) || raw.names.some(n => typeof n !== 'string' || !NAME_RE.test(n))) r.error(key, "'names' must be a list of registry names");
        else {
            names = [...new Set(raw.names as string[])];
            if (reg) {
                const find = nameLookup(reg);
                for (const n of names) {
                    const hit = find(n);
                    if (!hit) { r.error(key, `name '${n}' is not in the registry`); continue; }
                    const dom = reg.domains[reg.flags[String(hit[0].index)].domain];
                    if (!isPersistent(dom)) { r.error(key, `name '${n}' is a scene-scratch flag (${reg.flags[String(hit[0].index)].domain}): it is cleared at every scene load and cannot be an entry requirement`); continue; }
                    derived.push(hit[0].index);
                }
            }
        }
    }

    let flags: number[] | undefined;
    if (raw.flags === undefined) {
        if (spec && names && reg) flags = [...new Set(derived)].sort((a, b) => a - b);
        else r.error(key, `'flags' is required${spec ? ' (or give names: they are looked up in the registry)' : ''}`);
    } else if (!Array.isArray(raw.flags) || raw.flags.some(f => !isInt(f) || f < 0 || f >= FLAG_COUNT)) {
        r.error(key, `'flags' must be a list of global flag indices 0-${FLAG_COUNT - 1} (decimal)`);
    } else {
        flags = [...new Set(raw.flags as number[])].sort((a, b) => a - b);
        for (const f of flags) {
            if (!reg) continue;
            const dId = domainOf(reg.domains, f);
            if (!dId) { r.error(key, `flag ${f} ($${hex(f, 4)}) is outside every domain`); continue; }
            if (!isPersistent(reg.domains[dId])) { r.error(key, `flag ${f} ($${hex(f, 4)}) is ${dId} scene scratch: cleared at every scene load, it cannot be an entry requirement`); continue; }
            if (!reg.flags[String(f)]) r.warn(`${key}: flag ${f} ($${hex(f, 4)}) is not in the registry yet`);
        }
    }
    if (flags && names && reg) {
        for (const i of derived) if (!flags.includes(i)) r.error(key, `names refers to index ${i}, which is not in 'flags'`);
    }

    let entry: string | undefined;
    if (raw.entry !== undefined) {
        if (typeof raw.entry !== 'string' || !(ENTRY_CLASSES as readonly string[]).includes(raw.entry)) r.error(key, `entry must be one of ${ENTRY_CLASSES.join(', ')}`);
        else entry = raw.entry;
    }
    if (entry === 'locked-until-flag' && flags && flags.length === 0) r.error(key, "entry 'locked-until-flag' needs at least one flag");
    if (entry === 'free' && flags && flags.length > 0) r.error(key, "entry 'free' cannot list required flags");
    let grade: string | undefined;
    if (raw.grade !== undefined) {
        if (typeof raw.grade !== 'string' || !(GRADES as readonly string[]).includes(raw.grade)) r.error(key, `grade must be one of ${GRADES.join(', ')}`);
        else grade = raw.grade;
    }
    for (const k of ['note', 'source']) if (raw[k] !== undefined && typeof raw[k] !== 'string') r.error(key, `'${k}' must be text`);

    if (r.errors.length > before || !flags) return undefined;
    return {
        flags,
        ...(names && names.length > 0 ? { names } : {}),
        ...(entry ? { entry } : {}),
        ...(grade ? { grade } : {}),
        ...(typeof raw.note === 'string' && raw.note ? { note: raw.note } : {}),
        ...(typeof raw.source === 'string' && raw.source ? { source: raw.source } : {}),
    };
}

function checkSceneFlagsFile(raw: unknown, reg: Registry | null, ctx: Context, r: Report): Record<string, SceneFlagEntry> | undefined {
    if (!isObj(raw)) { r.error('scene-flags.json', 'must be an object keyed by decimal scene id'); return undefined; }
    const out: Record<string, SceneFlagEntry> = {};
    for (const key of Object.keys(raw).sort((a, b) => Number(a) - Number(b))) {
        if (!/^\d+$/.test(key) || String(Number(key)) !== key) { r.error(`scene ${key}`, 'key must be a decimal scene id'); continue; }
        if (!ctx.sceneIds.has(Number(key))) { r.error(`scene ${key}`, `scene id ${key} is not in db-us/groups.json`); continue; }
        const e = checkSceneFlagEntry(key, raw[key], reg, r, false);
        if (e) out[key] = e;
    }
    return out;
}

export function serializeSceneFlags(entries: Record<string, SceneFlagEntry>): string {
    const out: Record<string, unknown> = {};
    for (const key of Object.keys(entries).sort((a, b) => Number(a) - Number(b))) {
        const e = entries[key];
        out[key] = { flags: e.flags, ...(e.names ? { names: e.names } : {}), ...(e.entry ? { entry: e.entry } : {}), ...(e.grade ? { grade: e.grade } : {}), ...(e.note ? { note: e.note } : {}), ...(e.source ? { source: e.source } : {}) };
    }
    return canonicalText(out);
}

/** For `export scenes`: the validated scene-flags entries (names checked against the registry when `flags.json` exists). Throws with every problem. */
export function loadSceneFlagsForExport(dbDir: string, raw: unknown): Record<string, SceneFlagEntry> {
    const paths = dbPaths('', dbDir);
    const ctx = loadContext(paths);
    const r = new Report();
    let reg: Registry | null = null;
    if (existsSync(paths.flags)) {
        const loaded = loadRegistry(paths, ctx, r, false);
        if (!loaded || !r.ok) throw new Error(`${paths.flags} is invalid (run: npm run flags -- --check):\n  ` + r.errors.map(e => `${e.key}: ${e.msg}`).join('\n  '));
        reg = loaded.reg;
    }
    const entries = checkSceneFlagsFile(raw, reg, ctx, r);
    if (!r.ok || !entries) throw new Error('scene-flags.json is invalid:\n  ' + r.errors.map(e => `${e.key}: ${e.msg}`).join('\n  '));
    return entries;
}

// ------------------------------------------------------------------------------------------------------------
// Presets (db-us/flag-presets.json)
// ------------------------------------------------------------------------------------------------------------

function checkPreset(name: string, raw: unknown, reg: Registry | null, ctx: Context, r: Report): Preset | undefined {
    const key = `preset ${name}`;
    const before = r.errors.length;
    if (!PRESET_RE.test(name)) r.error(key, 'preset name must be lower snake_case');
    if (!isObj(raw)) { r.error(key, `must be an object { ${PRESET_KEYS.join(', ')} }`); return undefined; }
    for (const k of Object.keys(raw)) if (!PRESET_KEYS.includes(k)) r.error(key, `unknown key '${k}' (${PRESET_KEYS.join(', ')})`);

    let after: string | undefined;
    if (raw.after !== undefined) {
        if (typeof raw.after !== 'string' || !PRESET_RE.test(raw.after)) r.error(key, "'after' must be the name of another preset");
        else if (raw.after === name) r.error(key, "'after' cannot be the preset itself");
        else after = raw.after;
    }

    const derived: number[] = [];
    let flagNames: string[] | undefined;
    if (raw.flagNames !== undefined) {
        if (!Array.isArray(raw.flagNames) || raw.flagNames.some(n => typeof n !== 'string' || !NAME_RE.test(n))) r.error(key, "'flagNames' must be a list of registry names");
        else {
            flagNames = [...new Set(raw.flagNames as string[])];
            if (reg) {
                const find = nameLookup(reg);
                for (const n of flagNames) {
                    const hit = find(n);
                    if (!hit) { r.error(key, `flag name '${n}' is not in the registry`); continue; }
                    if (!isPersistent(reg.domains[reg.flags[String(hit[0].index)].domain])) { r.error(key, `flag name '${n}' is a scene-scratch flag: a preset only sets persistent flags`); continue; }
                    derived.push(hit[0].index);
                }
            }
        }
    }

    let flags: number[] | undefined;
    if (!Array.isArray(raw.flags) || raw.flags.some(f => !isInt(f) || f < 0 || f >= FLAG_COUNT)) r.error(key, `'flags' is required: a list of global flag indices 0-${FLAG_COUNT - 1} (the full state at this checkpoint, may be empty)`);
    else {
        flags = [...new Set(raw.flags as number[])].sort((a, b) => a - b);
        for (const f of flags) {
            if (!reg) continue;
            const dId = domainOf(reg.domains, f);
            if (!dId) { r.error(key, `flag ${f} ($${hex(f, 4)}) is outside every domain`); continue; }
            if (!isPersistent(reg.domains[dId])) { r.error(key, `flag ${f} ($${hex(f, 4)}) is ${dId} scene scratch: a preset only sets persistent flags`); continue; }
            if (!reg.flags[String(f)]) r.warn(`${key}: flag ${f} ($${hex(f, 4)}) is not in the registry yet`);
        }
        if (reg) for (const i of derived) if (!flags.includes(i)) r.error(key, `flagNames refers to index ${i}, which is not in 'flags'`);
    }

    let items: PresetItem[] | undefined;
    if (raw.items !== undefined) {
        if (!Array.isArray(raw.items)) r.error(key, "'items' must be a list of { id, slot }");
        else {
            items = [];
            const slots = new Set<number>();
            for (const it of raw.items) {
                if (!isObj(it) || !isInt(it.id) || it.id < 0 || it.id > 255 || !isInt(it.slot) || it.slot < 0 || it.slot > 15 || Object.keys(it).some(k => k !== 'id' && k !== 'slot')) {
                    r.error(key, `bad item ${JSON.stringify(it)}: need { "id": 0-255, "slot": 0-15 } (slots are $0AB4-$0AC3)`);
                    continue;
                }
                if (slots.has(it.slot)) r.error(key, `inventory slot ${it.slot} appears twice`);
                slots.add(it.slot);
                items.push({ id: it.id, slot: it.slot });
            }
            items.sort((a, b) => a.slot - b.slot);
        }
    }
    let form: string | undefined;
    if (raw.form !== undefined) {
        if (typeof raw.form !== 'string' || !(FORMS as readonly string[]).includes(raw.form)) r.error(key, `form must be one of ${FORMS.join(', ')}`);
        else form = raw.form;
    }
    let gems: number | undefined;
    if (raw.gems !== undefined) {
        if (!isInt(raw.gems) || raw.gems < 0) r.error(key, "'gems' must be a non-negative integer");
        else gems = raw.gems;
    }
    const abilities = stringList(raw.abilities, key, 'preset', 'abilities', r);
    const evidence = stringList(raw.evidence, key, 'preset', 'evidence', r);
    let verifyScene: number | undefined;
    if (raw.verifyScene !== undefined) {
        if (!isInt(raw.verifyScene) || !ctx.sceneIds.has(raw.verifyScene)) r.error(key, `verifyScene ${JSON.stringify(raw.verifyScene)} is not a scene id of db-us/groups.json`);
        else verifyScene = raw.verifyScene;
    } else r.warn(`${key}: no verifyScene (FR50 needs a scene to replay the preset in)`);
    let grade: string | undefined;
    if (raw.grade === undefined) r.error(key, `'grade' is required (${GRADES.join(', ')})`);
    else if (typeof raw.grade !== 'string' || !(GRADES as readonly string[]).includes(raw.grade)) r.error(key, `grade must be one of ${GRADES.join(', ')}`);
    else grade = raw.grade;
    if (raw.note !== undefined && typeof raw.note !== 'string') r.error(key, "'note' must be text");

    if (r.errors.length > before || !flags) return undefined;
    return {
        ...(after ? { after } : {}),
        flags,
        ...(flagNames && flagNames.length > 0 ? { flagNames } : {}),
        ...(items && items.length > 0 ? { items } : {}),
        ...(form ? { form } : {}),
        ...(gems !== undefined ? { gems } : {}),
        ...(abilities && abilities.length > 0 ? { abilities } : {}),
        ...(verifyScene !== undefined ? { verifyScene } : {}),
        ...(grade ? { grade } : {}),
        ...(evidence && evidence.length > 0 ? { evidence } : {}),
        ...(typeof raw.note === 'string' && raw.note ? { note: raw.note } : {}),
    };
}

/** Presets in dependency order (a preset after the one it follows), alphabetical otherwise. */
function orderPresets(presets: Record<string, Preset>): string[] {
    const out: string[] = [];
    const state = new Map<string, number>();
    const visit = (n: string) => {
        if (state.get(n)) return;
        state.set(n, 1);
        const a = presets[n].after;
        if (a && presets[a]) visit(a);
        out.push(n);
    };
    for (const n of Object.keys(presets).sort()) visit(n);
    return out;
}

function checkPresetRelations(presets: Record<string, Preset>, r: Report) {
    for (const [name, p] of Object.entries(presets)) {
        if (!p.after) continue;
        const key = `preset ${name}`;
        const prev = presets[p.after];
        if (!prev) { r.error(key, `'after' preset '${p.after}' does not exist`); continue; }
        const seen = new Set<string>([name]);
        let cur: string | undefined = p.after;
        while (cur) {
            if (seen.has(cur)) { r.error(key, `'after' chain loops through '${cur}'`); break; }
            seen.add(cur);
            cur = presets[cur]?.after;
        }
        const missing = prev.flags.filter(f => !p.flags.includes(f));
        if (missing.length > 0) r.warn(`${key}: flags of '${p.after}' not in this preset (presets are full snapshots): ${missing.map(f => '$' + hex(f, 4)).join(', ')}`);
    }
}

function checkPresetsFile(raw: unknown, reg: Registry | null, ctx: Context, r: Report): Record<string, Preset> | undefined {
    if (!isObj(raw)) { r.error('flag-presets.json', 'must be { "schema": 1, "presets": { ... } }'); return undefined; }
    for (const k of Object.keys(raw)) if (k !== 'schema' && k !== 'presets') r.error('flag-presets.json', `unknown top-level key '${k}'`);
    if (raw.schema !== SCHEMA) r.error('flag-presets.json', `schema must be ${SCHEMA}`);
    if (!isObj(raw.presets)) { r.error('flag-presets.json', "'presets' must be an object keyed by preset name"); return undefined; }
    const out: Record<string, Preset> = {};
    for (const [name, p] of Object.entries(raw.presets)) {
        const n = checkPreset(name, p, reg, ctx, r);
        if (n) out[name] = n;
    }
    checkPresetRelations(out, r);
    return out;
}

export function serializePresets(presets: Record<string, Preset>): string {
    const body: Record<string, unknown> = {};
    for (const name of orderPresets(presets)) body[name] = presets[name];
    return canonicalText({ schema: SCHEMA, presets: body });
}

// ------------------------------------------------------------------------------------------------------------
// Merge: scene-flags and presets specs
// ------------------------------------------------------------------------------------------------------------

function mergeKeyed<T extends object>(
    existing: Record<string, T>, spec: Obj, noun: string, r: Report, ops: Op[],
    keyOk: (key: string) => string | null,
    check: (key: string, raw: Obj) => T | undefined,
    describe: (key: string, value: T) => string,
): Record<string, T> {
    const result: Record<string, T> = { ...existing };
    for (const [key, entryRaw] of Object.entries(spec)) {
        if (key.startsWith('_') || key.startsWith('$')) continue;
        const label = `${noun} ${key}`;
        const keyProblem = keyOk(key);
        if (keyProblem) { r.error(label, keyProblem); continue; }
        if (!isObj(entryRaw)) { r.error(label, 'must be an object'); continue; }
        const ctl = controlKeys(entryRaw, noun, label, r);
        if (ctl.bad) continue;
        const stored = result[key] as unknown as Obj | undefined;
        if (ctl.expectOld !== undefined) {
            if (!stored) { r.error(label, `expectOld given but there is no stored ${noun} to edit`); continue; }
            const why = matchOld(stored, ctl.expectOld, null);
            if (why) { r.error(label, `expectOld does not match: ${why}`); continue; }
        }
        if (ctl.remove) {
            ops.push({ kind: 'remove', text: describe(key, stored as unknown as T) });
            delete result[key];
            continue;
        }
        const candidate = ctl.patch ? applyPatch(stored!, ctl.fields) : ctl.fields;
        const norm = check(key, candidate);
        if (!norm) continue;
        if (!stored) { result[key] = norm; ops.push({ kind: 'add', text: describe(key, norm) }); continue; }
        if (canon(stored) === canon(norm)) { ops.push({ kind: 'unchanged', text: describe(key, norm) }); continue; }
        if (ctl.expectOld === undefined) { r.error(label, `${noun} already exists and differs: add "expectOld" ({ field: text or value }) to replace it, or "patch": true with expectOld to change single fields`); continue; }
        result[key] = norm;
        ops.push({ kind: 'change', text: describe(key, norm) });
    }
    return result;
}

function loadSpec(path: string, r: Report): Obj | undefined {
    const raw = readJson(resolve(path), 'spec', r);
    if (raw === undefined) return undefined;
    if (!isObj(raw)) { r.error('spec', 'must be a JSON object'); return undefined; }
    return raw;
}

export function mergeSceneFlags(root: string, specPath: string, options: FlagsOptions = {}): MergeResult {
    const paths = dbPaths(root, options.dbDir);
    const result = newResult();
    const r = new Report();
    const ops: Op[] = [];
    const bail = () => finish(result, r, ops, 'Scene flags', [], options, () => []);

    let ctx: Context;
    try { ctx = loadContext(paths); } catch (e) { r.error('db', String(e instanceof Error ? e.message : e)); return bail(); }
    let reg: Registry | null = null;
    if (existsSync(paths.flags)) {
        const pre = new Report();
        const loaded = loadRegistry(paths, ctx, pre, false);
        if (!loaded || !pre.ok) { r.error('flags.json', 'the registry is invalid: run `npm run flags -- --check`'); return bail(); }
        reg = loaded.reg;
    }
    const pre = new Report();
    const currentRaw = existsSync(paths.sceneFlags) ? readJson(paths.sceneFlags, 'scene-flags.json', pre) : {};
    const current = currentRaw === undefined ? undefined : checkSceneFlagsFile(currentRaw, reg, ctx, pre);
    if (!current || !pre.ok) { for (const e of pre.errors) r.error(e.key, e.msg); r.error('scene-flags.json', 'the file is invalid before this merge: run `npm run flags -- --check`'); return bail(); }
    const spec = loadSpec(specPath, r);
    if (!spec) return bail();

    const merged = mergeKeyed<SceneFlagEntry>(current, spec, 'scene', r, ops,
        key => (!/^\d+$/.test(key) || String(Number(key)) !== key ? 'key must be a decimal scene id' : (!ctx.sceneIds.has(Number(key)) ? `scene id ${key} is not in db-us/groups.json` : null)),
        (key, raw) => checkSceneFlagEntry(key, raw, reg, r, true),
        (key, e) => `scene ${key} ($${hex(Number(key), 2)}) ${e ? `flags [${e.flags.join(', ')}]${e.entry ? ' ' + e.entry : ''}${e.grade ? ' ' + e.grade : ''}` : ''}`);

    const nextText = serializeSceneFlags(merged);
    const rel = toPosix(relative(root, paths.sceneFlags));
    const willChange = existsSync(paths.sceneFlags) ? lf(readFileSync(paths.sceneFlags, 'utf-8')) !== lf(nextText) : true;
    return finish(result, r, ops, `Scene flags: ${Object.keys(spec).filter(k => !k.startsWith('_') && !k.startsWith('$')).length} entr(ies)`, willChange ? [rel] : [], options, () => (writeIfChanged(paths.sceneFlags, nextText) ? [rel] : []));
}

export function mergePresets(root: string, specPath: string, options: FlagsOptions = {}): MergeResult {
    const paths = dbPaths(root, options.dbDir);
    const result = newResult();
    const r = new Report();
    const ops: Op[] = [];
    const bail = () => finish(result, r, ops, 'Presets', [], options, () => []);

    let ctx: Context;
    try { ctx = loadContext(paths); } catch (e) { r.error('db', String(e instanceof Error ? e.message : e)); return bail(); }
    let reg: Registry | null = null;
    if (existsSync(paths.flags)) {
        const pre = new Report();
        const loaded = loadRegistry(paths, ctx, pre, false);
        if (!loaded || !pre.ok) { r.error('flags.json', 'the registry is invalid: run `npm run flags -- --check`'); return bail(); }
        reg = loaded.reg;
    }
    const pre = new Report();
    let current: Record<string, Preset> | undefined = {};
    if (existsSync(paths.presets)) {
        const raw = readJson(paths.presets, 'flag-presets.json', pre);
        current = raw === undefined ? undefined : checkPresetsFile(raw, reg, ctx, pre);
    }
    if (!current || !pre.ok) { for (const e of pre.errors) r.error(e.key, e.msg); r.error('flag-presets.json', 'the file is invalid before this merge: run `npm run flags -- --check`'); return bail(); }
    const spec = loadSpec(specPath, r);
    if (!spec) return bail();

    const merged = mergeKeyed<Preset>(current, spec, 'preset', r, ops,
        key => (PRESET_RE.test(key) ? null : 'preset name must be lower snake_case'),
        (key, raw) => checkPreset(key, raw, reg, ctx, r),
        (key, p) => `preset ${key}${p ? ` flags [${p.flags.join(', ')}]${p.grade ? ' ' + p.grade : ''}` : ''}`);
    if (r.ok) checkPresetRelations(merged, r);

    const nextText = serializePresets(merged);
    const rel = toPosix(relative(root, paths.presets));
    const willChange = existsSync(paths.presets) ? lf(readFileSync(paths.presets, 'utf-8')) !== lf(nextText) : true;
    return finish(result, r, ops, `Presets: ${Object.keys(spec).filter(k => !k.startsWith('_') && !k.startsWith('$')).length} entr(ies)`, willChange ? [rel] : [], options, () => (writeIfChanged(paths.presets, nextText) ? [rel] : []));
}

// ------------------------------------------------------------------------------------------------------------
// Check
// ------------------------------------------------------------------------------------------------------------

export interface CheckResult {
    ok: boolean;
    report: Report;
    ctx?: Context;
    registry?: Registry;
    sceneFlags?: Record<string, SceneFlagEntry>;
    presets?: Record<string, Preset>;
}

function checkCanonical(path: string, expected: string, label: string, r: Report) {
    if (lf(readFileSync(path, 'utf-8')) !== lf(expected)) r.error(label, 'not in the canonical form the tool writes (sorted, fixed field order, 2-space indent): re-run it through `npm run flags` or fix by hand');
}

export function runCheck(root: string, options: FlagsOptions = {}, quiet = false): CheckResult {
    const paths = dbPaths(root, options.dbDir);
    const r = new Report();
    const result: CheckResult = { ok: false, report: r };
    let ctx: Context;
    try { ctx = loadContext(paths); } catch (e) { r.error('db', String(e instanceof Error ? e.message : e)); return report(result, options, quiet); }
    result.ctx = ctx;

    const loaded = loadRegistry(paths, ctx, r, true);
    let reg: Registry | null = null;
    if (loaded) {
        reg = loaded.reg;
        result.registry = loaded.reg;
        if (r.ok) checkCanonical(paths.flags, serializeRegistry(loaded.reg), 'flags.json', r);
    }

    if (existsSync(paths.sceneFlags)) {
        const raw = readJson(paths.sceneFlags, 'scene-flags.json', r);
        if (raw !== undefined) {
            const entries = checkSceneFlagsFile(raw, reg, ctx, r);
            if (entries) {
                result.sceneFlags = entries;
                if (r.ok) checkCanonical(paths.sceneFlags, serializeSceneFlags(entries), 'scene-flags.json', r);
            }
        }
    }
    if (existsSync(paths.presets)) {
        const raw = readJson(paths.presets, 'flag-presets.json', r);
        if (raw !== undefined) {
            const presets = checkPresetsFile(raw, reg, ctx, r);
            if (presets) {
                result.presets = presets;
                if (r.ok) checkCanonical(paths.presets, serializePresets(presets), 'flag-presets.json', r);
            }
        }
    }
    return report(result, options, quiet);
}

function report(result: CheckResult, options: FlagsOptions, quiet: boolean): CheckResult {
    const r = result.report;
    result.ok = r.ok && (!options.strict || r.warnings.length === 0);
    if (quiet) return result;
    for (const w of r.warnings) console.warn(`  ${options.strict ? 'X' : '!'} ${w}`);
    for (const e of r.errors) console.error(`  X ${e.key}: ${e.msg}`);
    const meanings = result.registry ? Object.values(result.registry.flags).reduce((n, f) => n + f.meanings.length, 0) : 0;
    const counts = `${result.registry ? Object.keys(result.registry.flags).length : 0} indices, ${meanings} meanings, ${Object.keys(result.sceneFlags ?? {}).length} scene entries, ${Object.keys(result.presets ?? {}).length} presets`;
    console.log(result.ok ? `Flags check: OK (${counts}${r.warnings.length > 0 ? `; ${r.warnings.length} warning(s)` : ''})` : `Flags check: ${r.errors.length} error(s)${options.strict && r.warnings.length > 0 ? `, ${r.warnings.length} warning(s) (--strict)` : ''} (${counts})`);
    return result;
}

// ------------------------------------------------------------------------------------------------------------
// Inventory join (plans/flags/inventory.json, written by FL01)
// ------------------------------------------------------------------------------------------------------------

export interface Site { index: number; offset?: number; file?: string; line?: number; opcode?: string; role?: string; scenes?: number[] }

/**
 * Expected shape: `{ "sites": [ { "index": <global decimal>, "offset": <decimal ROM offset>, "file", "line", "opcode", "role", "scenes": [ids] } ] }`.
 * `source` is accepted for `file` and `operation` for `opcode`. A site without `scenes` joins only meanings with `scope: null`.
 */
export function loadInventory(path: string): Site[] | null {
    if (!existsSync(path)) return null;
    const raw = JSON.parse(readFileSync(path, 'utf-8')) as unknown;
    if (!isObj(raw) || !Array.isArray(raw.sites)) {
        throw new Error(`${path}: expected { "sites": [ ... ] } (the format written by FL01); the old iog_flag_usage_inventory.json is not accepted`);
    }
    return raw.sites.map((s, i) => {
        if (!isObj(s) || !isInt(s.index)) throw new Error(`${path}: sites[${i}] needs an integer 'index' (global flag index)`);
        return {
            index: s.index,
            ...(isInt(s.offset) ? { offset: s.offset } : {}),
            ...(typeof (s.file ?? s.source) === 'string' ? { file: (s.file ?? s.source) as string } : {}),
            ...(isInt(s.line) ? { line: s.line } : {}),
            ...(typeof (s.opcode ?? s.operation) === 'string' ? { opcode: (s.opcode ?? s.operation) as string } : {}),
            ...(typeof s.role === 'string' ? { role: s.role } : {}),
            ...(Array.isArray(s.scenes) ? { scenes: s.scenes.filter(isInt) } : {}),
        };
    });
}

function sitesFor(sites: Site[] | null, index: number, scope: Scope | null): Site[] {
    if (!sites) return [];
    return sites
        .filter(s => s.index === index && (scope === null || (s.scenes !== undefined && s.scenes.some(x => scope.scenes.includes(x)))))
        .sort((a, b) => (a.offset ?? 0) - (b.offset ?? 0) || (a.file ?? '').localeCompare(b.file ?? '') || (a.line ?? 0) - (b.line ?? 0));
}

// ------------------------------------------------------------------------------------------------------------
// Export (artifacts/flags.json, artifacts/flag-presets.json)
// ------------------------------------------------------------------------------------------------------------

export interface ExportFlagsResult {
    flagsPath: string;
    presetsPath: string;
    indices: number;
    meanings: number;
    presets: number;
    sitesJoined: number;
    inventoryUsed: boolean;
}

function inventoryPath(root: string, options: FlagsOptions): string {
    return options.inventory ? resolve(options.inventory) : join(root, 'plans', 'flags', 'inventory.json');
}

export function exportFlags(root: string, options: FlagsOptions = {}): ExportFlagsResult {
    const check = runCheck(root, options, true);
    if (!check.ok || !check.registry) {
        throw new Error('flags are invalid, nothing exported (run: npm run flags -- --check):\n  ' + check.report.errors.map(e => `${e.key}: ${e.msg}`).join('\n  '));
    }
    const reg = check.registry;
    const sites = loadInventory(inventoryPath(root, options));
    const outDir = resolve(options.outDir ?? join(root, 'artifacts'));

    const rows: Array<Record<string, unknown>> = [];
    const nameToIndex: Record<string, number> = {};
    let joined = 0;
    for (const key of Object.keys(reg.flags).sort((a, b) => Number(a) - Number(b))) {
        const rec = reg.flags[key];
        const loc = flagLocation(Number(key));
        const dom = reg.domains[rec.domain];
        for (const m of [...rec.meanings].sort(compareMeanings)) {
            const joinedSites = sitesFor(sites, Number(key), m.scope);
            joined += joinedSites.length;
            if (m.name) nameToIndex[m.name] = Number(key);
            rows.push({
                index: loc.index,
                hex: loc.hex,
                address: loc.address,
                addressHex: loc.addressHex,
                mask: loc.mask,
                maskHex: loc.maskHex,
                domain: rec.domain,
                persistence: dom.persistence,
                name: m.name ?? null,
                level: m.level ?? 'full',
                area: m.area ?? null,
                scope: m.scope,
                grade: m.grade ?? null,
                summary: m.summary ?? null,
                stage: m.stage ?? null,
                kinds: m.kinds ?? [],
                effects: m.effects ?? null,
                requires: m.requires ?? [],
                excludes: m.excludes ?? [],
                pairsWith: m.pairsWith ?? [],
                evidence: m.evidence ?? [],
                runtime: m.runtime ?? null,
                queue: m.queue ?? [],
                proposedBy: m.proposedBy ?? [],
                notes: m.notes ?? null,
                ...(sites ? { sites: joinedSites } : {}),
            });
        }
    }
    const flagsOut = {
        game: 'Illusion of Gaia (US)',
        source: 'db-us/flags.json' + (sites ? ', plans/flags/inventory.json' : ''),
        convention: 'flag #n = WRAM byte 0x0A00 + (n >> 3), bit (n & 7), mask 1 << (n & 7); index is the global decimal index',
        domains: reg.domains,
        indices: Object.keys(reg.flags).length,
        count: rows.length,
        nameToIndex,
        flags: rows,
    };
    const flagsPath = join(outDir, 'flags.json');
    mkdirSync(outDir, { recursive: true });
    writeFileSync(flagsPath, jsonForExport(flagsOut), 'utf-8');

    const presets = check.presets ?? {};
    const presetRows = orderPresets(presets).map(name => {
        const p = presets[name];
        const bytes = new Map<number, number>();
        for (const f of p.flags) {
            const loc = flagLocation(f);
            bytes.set(loc.address, (bytes.get(loc.address) ?? 0) | loc.mask);
        }
        return {
            name,
            after: p.after ?? null,
            flags: p.flags,
            flagNames: p.flagNames ?? [],
            flagBytes: p.flags.map(f => { const l = flagLocation(f); return { flag: f, address: l.address, mask: l.mask }; }),
            byteMasks: [...bytes.entries()].sort((a, b) => a[0] - b[0]).map(([address, mask]) => ({ address, addressHex: '$' + hex(address, 4), setMask: mask, setMaskHex: '$' + hex(mask, 2) })),
            items: p.items ?? [],
            form: p.form ?? null,
            gems: p.gems ?? null,
            abilities: p.abilities ?? [],
            verifyScene: p.verifyScene ?? null,
            grade: p.grade ?? null,
            evidence: p.evidence ?? [],
            note: p.note ?? null,
        };
    });
    const presetsPath = join(outDir, 'flag-presets.json');
    writeFileSync(presetsPath, jsonForExport({
        game: 'Illusion of Gaia (US)',
        source: 'db-us/flag-presets.json',
        convention: 'flags are absolute (the full state at the checkpoint); write byteMasks with OR to $0A00+; items go to $0AB4+slot, form to $0AD4',
        count: presetRows.length,
        presets: presetRows,
    }), 'utf-8');

    return { flagsPath, presetsPath, indices: Object.keys(reg.flags).length, meanings: rows.length, presets: presetRows.length, sitesJoined: joined, inventoryUsed: sites !== null };
}

/** Pretty JSON where arrays of numbers stay on one line. */
function jsonForExport(v: unknown): string {
    return JSON.stringify(v, null, 2).replace(/\[\s*(-?\d[\d,\s]*)\]/g, (_m, body: string) => '[' + body.replace(/\s+/g, ' ').trim() + ']') + '\n';
}

// ------------------------------------------------------------------------------------------------------------
// Docs (docs/flags/README.md + one page per area)
// ------------------------------------------------------------------------------------------------------------

const GENERATED = '<!-- Generated by `npm run flags -- docs` from db-us/flags.json. Do not edit: change the registry through `npm run flags`. -->';

const esc = (s: string) => s.replace(/\|/g, '\\|').replace(/\r?\n/g, ' ');
const md = (s: string | undefined | null) => esc(s ?? '');
const hx = (n: number) => '$' + hex(n, 4);
const refText = (ref: Ref) => (typeof ref === 'number' ? `${hx(ref)} (${ref})` : `\`${ref}\``);

export interface DocsResult { dir: string; written: string[]; removed: string[]; areas: number }

export function generateDocs(root: string, options: FlagsOptions = {}): DocsResult {
    const check = runCheck(root, options, true);
    if (!check.ok || !check.registry || !check.ctx) {
        throw new Error('flags are invalid, no docs written (run: npm run flags -- --check):\n  ' + check.report.errors.map(e => `${e.key}: ${e.msg}`).join('\n  '));
    }
    const reg = check.registry;
    const ctx = check.ctx;
    const sites = loadInventory(inventoryPath(root, options));
    const dir = resolve(options.outDir ?? join(root, 'docs', 'flags'));
    mkdirSync(dir, { recursive: true });

    // group meanings by area
    const byArea = new Map<string, Array<{ index: number; domain: string; meaning: Meaning }>>();
    for (const key of Object.keys(reg.flags).sort((a, b) => Number(a) - Number(b))) {
        const rec = reg.flags[key];
        for (const m of [...rec.meanings].sort(compareMeanings)) {
            const area = m.area ?? 'unassigned';
            const list = byArea.get(area) ?? [];
            list.push({ index: Number(key), domain: rec.domain, meaning: m });
            byArea.set(area, list);
        }
    }
    const areas = [...byArea.keys()].sort((a, b) => (ctx.groupOrder.indexOf(a) + 1 || 999) - (ctx.groupOrder.indexOf(b) + 1 || 999) || a.localeCompare(b));

    const files = new Map<string, string>();

    // ---- area pages
    for (const area of areas) {
        const list = byArea.get(area)!;
        const full = list.filter(x => x.meaning.level !== 'row');
        const rows = list.filter(x => x.meaning.level === 'row');
        const L: string[] = [GENERATED, '', `# Flags: ${area}`, '', `Back to the [overview](README.md). ${full.length} record(s), ${rows.length} scratch row(s). Prefix \`${ctx.groupPrefix.get(area) ?? '?'}\`.`, ''];
        if (full.length > 0) {
            L.push('| Index | Byte / mask | Dom | Name | Scope | Kinds | Grade | Summary |', '|---|---|---|---|---|---|---|---|');
            for (const x of full) {
                const loc = flagLocation(x.index);
                L.push(`| ${hx(x.index)} (${x.index}) | ${loc.addressHex} / ${loc.maskHex} | ${x.domain} | \`${x.meaning.name}\` | ${md(scopeText(x.meaning.scope))} | ${(x.meaning.kinds ?? []).join(', ')} | ${x.meaning.grade ?? ''} | ${md(x.meaning.summary)} |`);
            }
            L.push('');
        }
        if (rows.length > 0) {
            L.push('## Scratch rows', '', '| Index | Scope | Name | Role |', '|---|---|---|---|');
            for (const x of rows) L.push(`| ${hx(x.index)} (${x.index}) | ${md(scopeText(x.meaning.scope))} | ${x.meaning.name ? '`' + x.meaning.name + '`' : ''} | ${md(x.meaning.summary)} |`);
            L.push('');
        }
        for (const x of full) {
            const m = x.meaning;
            const loc = flagLocation(x.index);
            L.push(`## ${hx(x.index)} \`${m.name}\``, '', `Index ${x.index}, byte \`${loc.addressHex}\` mask \`${loc.maskHex}\`, ${x.domain} ${reg.domains[x.domain].name}, scope: ${scopeText(m.scope)}, grade **${m.grade}**${m.stage ? `, stage \`${m.stage}\`` : ''}.`, '', m.summary ?? '', '');
            if (m.effects?.set) L.push(`- **Set:** ${m.effects.set}`);
            if (m.effects?.clear) L.push(`- **Clear:** ${m.effects.clear}`);
            if (m.requires?.length) L.push(`- **Requires:** ${m.requires.map(refText).join(', ')}`);
            if (m.excludes?.length) L.push(`- **Excludes:** ${m.excludes.map(refText).join(', ')}`);
            if (m.pairsWith?.length) L.push(`- **Pairs with:** ${m.pairsWith.map(refText).join(', ')}`);
            if (m.proposedBy?.length) L.push(`- **Proposed by:** ${m.proposedBy.join(', ')}`);
            if (m.runtime) L.push(`- **Runtime:** ${m.runtime.result}${m.runtime.trial ? ': ' + m.runtime.trial : ''}${m.runtime.rom ? ` (${m.runtime.rom})` : ''}`);
            if (m.queue?.length) L.push(`- **Queue:** ${m.queue.join(', ')}`);
            if (m.evidence?.length) { L.push('- **Evidence:**'); for (const e of m.evidence) L.push(`  - ${e}`); }
            if (m.notes) L.push('', `Notes: ${m.notes}`);
            const joined = sitesFor(sites, x.index, m.scope);
            if (sites) {
                L.push('', `Sites (${joined.length}):`, '');
                if (joined.length > 0) {
                    L.push('| ROM offset | File:line | Opcode | Role |', '|---|---|---|---|');
                    for (const s of joined) L.push(`| ${s.offset ?? ''} | ${md(s.file)}${s.line ? ':' + s.line : ''} | ${md(s.opcode)} | ${md(s.role)} |`);
                }
            }
            L.push('');
        }
        files.set(`${area}.md`, L.join('\n'));
    }

    // ---- README
    const introPath = join(dir, '_intro.md');
    const intro = existsSync(introPath) ? lf(readFileSync(introPath, 'utf-8')).trimEnd() : '# IOG script flags\n\n(docs/flags/_intro.md is missing)';
    const R: string[] = [GENERATED, '', intro, '', '---', '', '# Registry overview (generated)', ''];

    R.push('## Domains', '', '| Dom | Name | Global indices | Bytes | Persistence | Records |', '|---|---|---|---|---|---:|');
    for (const [id, d] of Object.entries(reg.domains)) {
        const n = Object.values(reg.flags).filter(f => f.domain === id).length;
        R.push(`| ${id} | ${md(d.name)} | ${d.indexed ? rangeText(d.ranges) : 'n/a'} | ${d.indexed ? byteRangeText(d.ranges) : 'n/a'} | ${d.persistence} | ${n} |`);
    }
    R.push('', '## Lifecycle', '', '| Dom | Lifecycle | How it is accessed |', '|---|---|---|');
    for (const [id, d] of Object.entries(reg.domains)) R.push(`| ${id} | ${md(d.lifecycle)} | ${md(d.access)} |`);

    const meaningsAll = Object.values(reg.flags).flatMap(f => f.meanings);
    R.push('', '## Coverage', '', `${Object.keys(reg.flags).length} flag indices, ${meaningsAll.length} meanings (${meaningsAll.filter(m => m.level === 'row').length} scratch rows).`, '', '| Grade | Meanings |', '|---|---:|');
    for (const g of GRADES) R.push(`| ${g} | ${meaningsAll.filter(m => m.grade === g).length} |`);
    R.push(`| (row, no grade) | ${meaningsAll.filter(m => !m.grade).length} |`);

    R.push('', '## Areas', '');
    if (areas.length === 0) R.push('No records yet.');
    else {
        R.push('| Area | Records | Rows |', '|---|---:|---:|');
        for (const a of areas) {
            const l = byArea.get(a)!;
            R.push(`| [${a}](${a}.md) | ${l.filter(x => x.meaning.level !== 'row').length} | ${l.filter(x => x.meaning.level === 'row').length} |`);
        }
    }

    const sceneEntries = check.sceneFlags ?? {};
    R.push('', '## Scene entry', '');
    if (Object.keys(sceneEntries).length === 0) R.push('No entries in `db-us/scene-flags.json`.');
    else {
        R.push('| Scene | Entry | Flags | Names | Grade | Note |', '|---|---|---|---|---|---|');
        for (const key of Object.keys(sceneEntries).sort((a, b) => Number(a) - Number(b))) {
            const e = sceneEntries[key];
            R.push(`| $${hex(Number(key), 2)} (${key}) | ${e.entry ?? ''} | ${e.flags.map(hx).join(', ')} | ${(e.names ?? []).map(n => '`' + n + '`').join(', ')} | ${e.grade ?? ''} | ${md(e.note)} |`);
        }
    }

    const presets = check.presets ?? {};
    R.push('', '## Presets', '');
    if (Object.keys(presets).length === 0) R.push('No presets in `db-us/flag-presets.json`.');
    else {
        R.push('| Preset | After | Flags | Items | Form | Verify scene | Grade |', '|---|---|---:|---:|---|---|---|');
        for (const name of orderPresets(presets)) {
            const p = presets[name];
            R.push(`| \`${name}\` | ${p.after ? '`' + p.after + '`' : ''} | ${p.flags.length} | ${(p.items ?? []).length} | ${p.form ?? ''} | ${p.verifyScene !== undefined ? '$' + hex(p.verifyScene, 2) : ''} | ${p.grade ?? ''} |`);
        }
    }

    R.push('', '## Open proposals', '');
    const proposals = reg.proposals ?? {};
    if (Object.keys(proposals).length === 0) R.push('None.');
    else {
        R.push('| Index | Source | Proposed name | Confidence | Summary |', '|---|---|---|---|---|');
        for (const key of Object.keys(proposals).sort((a, b) => Number(a) - Number(b))) {
            for (const p of proposals[key]) R.push(`| ${hx(Number(key))} (${key}) | ${p.source} | \`${p.name}\` | ${p.confidence} | ${md(p.summary)} |`);
        }
    }
    R.push('');
    files.set('README.md', R.join('\n'));

    // ---- write; remove stale generated pages
    const written: string[] = [];
    for (const [name, text] of files) if (writeIfChanged(join(dir, name), text.replace(/\n*$/, '\n'))) written.push(name);
    const removed: string[] = [];
    for (const f of readdirSync(dir)) {
        if (!f.endsWith('.md') || f === '_intro.md' || files.has(f)) continue;
        const p = join(dir, f);
        if (readFileSync(p, 'utf-8').startsWith(GENERATED)) { unlinkSync(p); removed.push(f); }
    }
    return { dir, written, removed, areas: areas.length };
}

// ------------------------------------------------------------------------------------------------------------
// CLI
// ------------------------------------------------------------------------------------------------------------

export const FLAGS_USAGE = [
    'Usage:',
    '  flags <fragment.json> [--dry-run]            merge flag records (and proposals, domains) into db-us/flags.json',
    '  flags --check [--strict]                     validate flags.json, scene-flags.json, flag-presets.json against each other',
    '  flags export [--out-dir=<dir>]               artifacts/flags.json and artifacts/flag-presets.json',
    '  flags docs [--out-dir=<dir>]                 docs/flags/README.md and one page per area',
    '  flags scene-flags <spec.json> [--dry-run]    merge entries into db-us/scene-flags.json',
    '  flags presets <spec.json> [--dry-run]        merge into db-us/flag-presets.json',
    '  flags inventory [--out=<file>] [--md=<file>] [--extracted=<dir>] [--dry-run] [--compare=<old.json> [--compare-out=<file>]]',
    '                                               scan the line-tracked extraction (npm run extract:lt) into plans/flags/inventory.json + inventory.md',
    'Options: --db-dir=<dir> (default db-us), --inventory=<file> (export, docs; default plans/flags/inventory.json)',
].join('\n');

/** Runs one `flags` command. Returns false when the command failed (the caller exits non-zero). */
export function flagsCli(root: string, args: string[], flags: string[], values: Record<string, string>): boolean {
    const options: FlagsOptions = {
        dryRun: flags.includes('dry-run') || flags.includes('dryrun'),
        strict: flags.includes('strict'),
        dbDir: values['db-dir'],
        outDir: values['out-dir'],
        inventory: values['inventory'],
    };
    if (flags.includes('check')) return runCheck(root, options).ok;
    const sub = args[0];
    switch (sub) {
        case undefined:
            console.error(FLAGS_USAGE);
            return false;
        case 'export': {
            const res = exportFlags(root, options);
            console.log(`Flags: ${res.indices} indices, ${res.meanings} meanings -> ${res.flagsPath}`);
            console.log(`Presets: ${res.presets} -> ${res.presetsPath}`);
            console.log(res.inventoryUsed ? `Sites joined from the inventory: ${res.sitesJoined}` : 'No plans/flags/inventory.json: no sites joined');
            return true;
        }
        case 'docs': {
            const res = generateDocs(root, options);
            console.log(`Docs: ${res.areas} area page(s) + README in ${res.dir}`);
            console.log(res.written.length > 0 ? `  wrote ${res.written.join(', ')}` : '  nothing changed');
            if (res.removed.length > 0) console.log(`  removed stale ${res.removed.join(', ')}`);
            return true;
        }
        case 'inventory':
            return runInventory(root, {
                dryRun: options.dryRun,
                dbDir: options.dbDir,
                out: values['out'],
                md: values['md'],
                extracted: values['extracted'],
                compare: values['compare'],
                compareOut: values['compare-out'],
            });
        case 'scene-flags':
            if (!args[1]) { console.error('Usage: flags scene-flags <spec.json> [--dry-run]'); return false; }
            return mergeSceneFlags(root, args[1], options).ok;
        case 'presets':
            if (!args[1]) { console.error('Usage: flags presets <spec.json> [--dry-run]'); return false; }
            return mergePresets(root, args[1], options).ok;
        default:
            return mergeFlags(root, sub, options).ok;
    }
}
