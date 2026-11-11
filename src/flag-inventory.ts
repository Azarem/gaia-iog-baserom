/**
 * Flag-site inventory (`npm run flags -- inventory`, iteration FL01).
 *
 *   npm run flags -- inventory [--out=<file>] [--md=<file>] [--extracted=<dir>] [--dry-run]
 *                              [--compare=<old inventory.json>] [--compare-out=<file>]
 *
 * Scans the line-tracked extraction (`npm run extract:lt`, every instruction line ends in `; {decimal ROM offset}`) and writes
 * `plans/flags/inventory.json` plus `plans/flags/inventory.md`. Site identity is the decimal ROM offset, never a label or a path.
 * Nothing in the output depends on the date, the machine or the working folder, so a second run over the same tree reproduces
 * both files byte for byte. A tree without tags is refused (run `npm run extract:lt`, then `npm run extract` again afterwards).
 *
 * What is scanned (all of it read-only; the tool never touches `extracted/`, `notes/`, `db-us/` or `baserom/`):
 *   - the 8 flag COPs ($CC-$D3), byte and word operands                                  -> `sites` (kind `cop`)
 *   - `$13 branch` commands of the scene_meta command streams, decoded to scene -> flag  -> `sites` (kind `scene_gate`)
 *   - calls to `flag_helpers.*`, with the 16 dynamic traces re-derived from the tables   -> `helper_calls`, `traces`
 *     (a call that resolves to exactly one global index also appears in `sites`, kind `helper_call`)
 *   - item COPs $D4-$D7 with item ids                                                    -> `item_sites`
 *   - `SwitchCase` with an operand other than $0000                                      -> `switch_sites`
 *   - direct accesses to $0A00-$0BFB (hex operand or `!symbol` alias), incl. $eventFlags/$wramFlags -> `direct_accesses`
 *
 * Index convention: global flag index n = byte $0A00 + (n >> 3), bit n & 7 (plan section 2.1). WRAM-relative indices (the
 * `wramFlags` slice, global = relative + $0400) are given as `wram` where relevant.
 */
import { createHash } from 'crypto';
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'fs';
import { dirname, join, resolve } from 'path';

// ------------------------------------------------------------------------------------------------------------
// Types
// ------------------------------------------------------------------------------------------------------------

export const INVENTORY_SCHEMA = 1;
const FLAG_COUNT = 1440;
const ROLES = ['set', 'clear', 'branch', 'wait', 'helper call', 'table reference', 'direct read', 'direct write'] as const;
type Role = typeof ROLES[number];
type Width = 'byte' | 'word' | 'unknown';
type SceneSource = 'placement' | 'directory' | 'prefix' | 'scene_meta' | 'none';

interface Line { n: number; text: string; code: string; tag: number | null }
interface AsmFile { rel: string; stem: string; dirs: string[]; lines: Line[]; symbols: Map<string, number> }
interface Scenes { scenes: number[]; source: SceneSource }
interface Ev { file: string; line: number; text: string }

interface SpawnRow {
    scene: number; kind: 'actor' | 'enemy'; line: number; x: number; y: number; attr: number; ref: string; file: string | null;
    stats?: number; enemyNum?: number; eventBlock?: number;
}

interface CopSite {
    offset: number; file: string; line: number; kind: 'cop'; opcode: string; operands: string; index: number; wram?: number;
    width: Width; sense?: 'set' | 'clear'; role: Role; scenes: number[]; sceneSource: SceneSource;
}
interface GateSite {
    offset: number; file: string; line: number; kind: 'scene_gate'; opcode: 'branch'; operands: string; index: number; width: Width;
    sense: 'set'; role: Role; record: number; label: number; scenes: number[]; sceneSource: SceneSource;
}
interface HelperCall {
    offset: number; file: string; line: number; call: string; helper: string; action: 'test' | 'set' | 'clear'; role: Role; width: Width;
    resolution: 'constant' | 'trace' | 'cop-operand' | 'block' | 'none'; trace: string | null; alsoIn: string[]; indices: number[];
    wram: number[]; range?: [number, number]; scenes: number[]; sceneSource: SceneSource; input?: number;
}
interface HelperSite {
    offset: number; file: string; line: number; kind: 'helper_call'; opcode: string; operands: string; index: number; wram?: number;
    width: Width; role: Role; resolution: string; trace: string | null; scenes: number[]; sceneSource: SceneSource;
}
interface ItemSite {
    offset: number; file: string; line: number; opcode: string; operands: string; itemId: number; role: Role; scenes: number[]; sceneSource: SceneSource;
}
interface SwitchSite {
    offset: number; file: string; line: number; opcode: 'SwitchCase'; operands: string; operand: number; operandHex: string;
    target: string; region: string; role: Role; scenes: number[]; sceneSource: SceneSource;
}
interface DirectAccess {
    offset: number; file: string; line: number; opcode: string; operands: string; address: number; addressHex: string; symbol?: string;
    region: string; flags?: [number, number]; indexed: boolean; access: 'read' | 'write' | 'rmw'; role: Role; width: Width;
    scope: 'flag_helpers' | 'save_code' | 'other'; flagSymbol: boolean; scenes: number[]; sceneSource: SceneSource;
}

interface Cand { index: number; wram?: number; scenes?: number[]; rows?: number; evidence: Ev[] }
interface TraceResult { candidates: Cand[]; warnings: string[]; assumptions: string[] }
interface TraceDef {
    id: string; previousId?: string; helpers: string[]; description: string; method: string;
    matches: (c: HelperCall) => boolean;
    derive: (ctx: Ctx) => TraceResult;
}

interface Ctx {
    files: AsmFile[];
    byRel: Map<string, AsmFile>;
    byStem: Map<string, AsmFile>;
    labelFile: Map<string, string>;
    spawns: SpawnRow[];
    placements: Map<string, Set<number>>;
    sceneIds: Set<number>;
    groupScenes: Map<string, Map<string, number>>;
    calls: HelperCall[];
    gates: GateSite[];
}

export interface InventoryOptions {
    extracted?: string;
    out?: string;
    md?: string;
    dryRun?: boolean;
    compare?: string;
    compareOut?: string;
    dbDir?: string;
}

// ------------------------------------------------------------------------------------------------------------
// Small helpers
// ------------------------------------------------------------------------------------------------------------

const hex = (n: number, w: number) => n.toString(16).toUpperCase().padStart(w, '0');
const sortNum = (a: number[]) => [...a].sort((x, y) => x - y);
const uniqSorted = (a: Iterable<number>) => sortNum([...new Set(a)]);
const cmpSite = (a: { offset: number; file: string; line: number }, b: { offset: number; file: string; line: number }) =>
    a.offset - b.offset || a.file.localeCompare(b.file) || a.line - b.line;
const lf = (s: string) => s.replace(/\r\n/g, '\n');

function parseByteToken(tok: string): number | null {
    const m = /^#\$?([0-9A-Fa-f]{1,4})$/.exec(tok.trim());
    return m ? parseInt(m[1], 16) : null;
}

const TAG_RE = /;\s*\{(\d+)\}/;

function walk(dir: string, base: string, out: string[]) {
    for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0))) {
        const full = join(dir, entry.name);
        if (entry.isDirectory()) walk(full, base, out);
        else if (entry.isFile() && entry.name.endsWith('.asm')) out.push(full.slice(base.length + 1).split('\\').join('/'));
    }
}

// ------------------------------------------------------------------------------------------------------------
// Loading the extracted tree
// ------------------------------------------------------------------------------------------------------------

const SYMBOL_RE = /^!([A-Za-z_]\w*)\s+([0-9A-Fa-f]+)\s*$/;

function loadTree(root: string): { files: AsmFile[]; sha256: string; taggedFiles: number } {
    const rels: string[] = [];
    walk(root, root, rels);
    rels.sort();
    const hash = createHash('sha256');
    const files: AsmFile[] = [];
    let taggedFiles = 0;
    for (const rel of rels) {
        const raw = readFileSync(join(root, rel));
        hash.update(rel); hash.update('\0'); hash.update(raw); hash.update('\0');
        const text = lf(raw.toString('utf-8').replace(/^\uFEFF/, ''));
        const lines: Line[] = [];
        const symbols = new Map<string, number>();
        let tagged = false;
        text.split('\n').forEach((t, i) => {
            const tm = TAG_RE.exec(t);
            const semi = t.indexOf(';');
            const code = (semi < 0 ? t : t.slice(0, semi)).trimEnd();
            const sm = SYMBOL_RE.exec(t);
            if (sm) symbols.set(sm[1], parseInt(sm[2], 16));
            if (tm) tagged = true;
            lines.push({ n: i + 1, text: t, code, tag: tm ? parseInt(tm[1], 10) : null });
        });
        if (tagged) taggedFiles++;
        const parts = rel.split('/');
        const name = parts[parts.length - 1];
        files.push({ rel, stem: name.replace(/\.asm$/, '').replace(/\.sprite$/, ''), dirs: parts.slice(0, -1), lines, symbols });
    }
    return { files, sha256: hash.digest('hex'), taggedFiles };
}

const BLOCK_DEF_RE = /^\s*([A-Za-z_]\w*)\s*[\[{]\s*$/;
const COLON_DEF_RE = /^\s*([A-Za-z_]\w*):\s*(?:;.*)?$/;

function buildLabelIndex(files: AsmFile[]): Map<string, string> {
    const map = new Map<string, string>();
    for (const f of files) {
        for (const l of f.lines) {
            const m = BLOCK_DEF_RE.exec(l.text) ?? COLON_DEF_RE.exec(l.text);
            if (m && !map.has(m[1])) map.set(m[1], f.rel);
        }
    }
    return map;
}

// ------------------------------------------------------------------------------------------------------------
// Scene placement (scene_actors, scene_thinkers) and the scene of a file
// ------------------------------------------------------------------------------------------------------------

function parseOperands(s: string): string[] {
    return s.split(',').map(x => x.trim()).filter(x => x.length > 0);
}

function resolveRef(ref: string, ctx: Pick<Ctx, 'byStem' | 'labelFile'>): string | null {
    const name = ref.replace(/^[@&]/, '');
    if (name.includes('.')) {
        const [block, label] = name.split('.');
        return ctx.byStem.get(block)?.rel ?? ctx.labelFile.get(label) ?? null;
    }
    return ctx.labelFile.get(name) ?? ctx.byStem.get(name)?.rel ?? null;
}

function parseSpawns(file: AsmFile, ctx: Pick<Ctx, 'byStem' | 'labelFile'>): SpawnRow[] {
    const rows: SpawnRow[] = [];
    let scene: number | null = null;
    let inList = false;
    for (const l of file.lines) {
        const sm = /^scene_([0-9A-F]{2})_actors \[/.exec(l.text);
        if (sm) { scene = parseInt(sm[1], 16); inList = true; continue; }
        if (/^scene_default_actors \[/.test(l.text)) { scene = null; inList = true; continue; }
        if (inList && /^\]/.test(l.text)) { inList = false; scene = null; continue; }
        if (!inList || scene === null) continue;
        const m = /^\s+(actor|enemy)-spawn <\s*([^>]*?)\s*>/.exec(l.text);
        if (!m) continue;
        const ops = parseOperands(m[2]);
        const num = (i: number) => parseByteToken(ops[i] ?? '') ?? 0;
        const ref = (ops[3] ?? '').replace(/^@/, '');
        const row: SpawnRow = { scene, kind: m[1] as 'actor' | 'enemy', line: l.n, x: num(0), y: num(1), attr: num(2), ref, file: resolveRef(ref, ctx) };
        if (m[1] === 'enemy') { row.stats = num(4); row.enemyNum = num(5); row.eventBlock = num(6); }
        rows.push(row);
    }
    return rows;
}

function parseThinkerPlacements(file: AsmFile, ctx: Pick<Ctx, 'byStem' | 'labelFile'>): Array<{ scene: number; code: string | null }> {
    const lists = new Map<string, Array<string | null>>();
    const table: Array<{ scene: number; list: string; skip: number }> = [];
    let mode: 'none' | 'table' | 'list' = 'none';
    let current: string | null = null;
    for (const l of file.lines) {
        const bm = /^(\w+) \[\s*$/.exec(l.text);
        if (bm) {
            if (bm[1] === 'scene_thinkers') mode = 'table';
            else { mode = 'list'; current = bm[1]; lists.set(current, []); }
            continue;
        }
        if (/^\]/.test(l.text)) { mode = 'none'; current = null; continue; }
        if (mode === 'table') {
            const m = /^\s+&(\w+)(?:\+([0-9A-Fa-f]+))?\s+;([0-9A-F]{2})\s*$/.exec(l.text);
            if (m) table.push({ scene: parseInt(m[3], 16), list: m[1], skip: m[2] ? parseInt(m[2], 16) : 0 });
        } else if (mode === 'list' && current) {
            const m = /^\s+thinker-spawn <\s*[^,]*,\s*@([\w.]+)\s*>/.exec(l.text);
            if (m) lists.get(current)!.push(resolveRef(m[1], ctx));
        }
    }
    const out: Array<{ scene: number; code: string | null }> = [];
    for (const t of table) {
        const rows = lists.get(t.list);
        if (!rows) continue;
        for (const code of rows.slice(Math.floor(t.skip / 4))) out.push({ scene: t.scene, code });
    }
    return out;
}

function fileScenes(f: AsmFile, ctx: Ctx): Scenes {
    const placed = ctx.placements.get(f.rel);
    if (placed && placed.size > 0) return { scenes: uniqSorted(placed), source: 'placement' };
    if (f.dirs.length >= 2) {
        const id = ctx.groupScenes.get(f.dirs[0])?.get(f.dirs[1]);
        if (id !== undefined) return { scenes: [id], source: 'directory' };
    }
    const pm = /^[a-z]{1,3}([0-9A-F]{2})_/.exec(f.stem);
    if (pm) {
        const id = parseInt(pm[1], 16);
        if (ctx.sceneIds.has(id)) return { scenes: [id], source: 'prefix' };
    }
    return { scenes: [], source: 'none' };
}

// ------------------------------------------------------------------------------------------------------------
// Scene-meta command streams: `$13 branch < flag, label >` gates
// ------------------------------------------------------------------------------------------------------------

const META_SIZE: Record<string, number> = {
    'display-mode': 2, bitmap: 8, palette: 7, tileset: 8, tilemap: 5, spritemap: 7, music: 6, branch: 3, jump: 2, 'char-tiles': 5, label: 2,
};

interface MetaCmd { kind: string; ops: number[]; line: number; pos: number; label?: number }
interface MetaRecord { id: number; cmds: MetaCmd[]; start: number }

/**
 * ROM layout of the original: [scene id word][commands][$00] back to back from the block start (the extraction lifts the ids out
 * into scene_meta_list and hides the terminator). The computed end must equal the block end of blocks.json (checked) and was
 * verified byte for byte against the ROM when this tool was written (231 id words, 18 branch commands).
 */
function parseSceneMeta(file: AsmFile, blockStart: number, blockEnd: number, warnings: string[]): { records: Map<number, MetaRecord>; order: MetaRecord[]; sceneRecord: Map<number, number> } {
    const order: MetaRecord[] = [];
    const records = new Map<number, MetaRecord>();
    const sceneRecord = new Map<number, number>();
    let cur: MetaRecord | null = null;
    let inList = false;
    let pos = blockStart;
    for (const l of file.lines) {
        const rm = /^scene_meta_([0-9A-F]{4}) \[/.exec(l.text);
        if (rm) { cur = { id: parseInt(rm[1], 16), cmds: [], start: pos }; pos += 2; order.push(cur); records.set(cur.id, cur); continue; }
        if (/^scene_meta_list \[/.test(l.text)) { inList = true; continue; }
        if (/^\]/.test(l.text)) {
            if (cur) { pos += 1; cur = null; }
            inList = false;
            continue;
        }
        if (inList) {
            const m = /^\s+&scene_meta_([0-9A-F]{4})\s+;([0-9A-F]{2})\s*$/.exec(l.text);
            if (m) sceneRecord.set(parseInt(m[2], 16), parseInt(m[1], 16));
            continue;
        }
        if (!cur) continue;
        const lm = /^\s+meta_label_([0-9A-F]{2}):\s+;/.exec(l.text);
        if (lm) {
            cur.cmds.push({ kind: 'label', ops: [parseInt(lm[1], 16)], line: l.n, pos, label: parseInt(lm[1], 16) });
            pos += META_SIZE.label;
            continue;
        }
        const cm = /^\s+([a-z][a-z-]*) <\s*(.*?)\s*>(?:\s+;[0-9A-F]+)?\s*$/.exec(l.text);
        if (!cm) continue;
        const size = META_SIZE[cm[1]];
        if (size === undefined) { warnings.push(`scene_meta.asm:${l.n}: unknown command '${cm[1]}', record layout cannot be computed`); continue; }
        const ops = parseOperands(cm[2]).map(t => parseByteToken(t) ?? -1);
        cur.cmds.push({ kind: cm[1], ops, line: l.n, pos });
        pos += size;
    }
    if (pos !== blockEnd) warnings.push(`scene_meta: computed end ${pos} differs from blocks.json end ${blockEnd}; ROM offsets of the scene gates are not trustworthy`);
    return { records, order, sceneRecord };
}

function decodeGates(ctx: Pick<Ctx, 'byRel' | 'sceneIds'>, blocks: Record<string, unknown>, warnings: string[]): { gates: GateSite[]; reach: number } {
    const file = ctx.byRel.get('tables/scene_meta.asm');
    if (!file) { warnings.push('tables/scene_meta.asm not found: no scene gates decoded'); return { gates: [], reach: 0 }; }
    const block = findBlock(blocks, 'scene_meta');
    if (!block) { warnings.push('blocks.json has no scene_meta block: no scene gates decoded'); return { gates: [], reach: 0 }; }
    const { order, records, sceneRecord } = parseSceneMeta(file, block.start, block.end, warnings);
    const labelAt = new Map<number, { rec: MetaRecord; idx: number }>();
    for (const rec of order) rec.cmds.forEach((c, idx) => { if (c.kind === 'label') labelAt.set(c.ops[0], { rec, idx }); });

    // Scenes reaching a command: linear flow from the record start of every scene id; jump/branch follow the label.
    const reachedBy = new Map<string, Set<number>>();
    for (const [scene, recId] of sceneRecord) {
        const start = records.get(recId);
        if (!start) continue;
        const seen = new Set<string>();
        const stack: Array<{ rec: MetaRecord; idx: number }> = [{ rec: start, idx: 0 }];
        while (stack.length > 0) {
            const { rec, idx } = stack.pop()!;
            const key = `${rec.id}:${idx}`;
            if (seen.has(key) || idx >= rec.cmds.length) continue;
            seen.add(key);
            const c = rec.cmds[idx];
            if (c.kind === 'branch') {
                if (!reachedBy.has(key)) reachedBy.set(key, new Set());
                reachedBy.get(key)!.add(scene);
            }
            if (c.kind === 'jump') {
                const target = labelAt.get(c.ops[0]);
                if (target) stack.push(target); else warnings.push(`scene_meta.asm:${c.line}: jump to undefined label $${hex(c.ops[0], 2)}`);
                continue;
            }
            if (c.kind === 'branch') {
                const target = labelAt.get(c.ops[1]);
                if (target) stack.push(target); else warnings.push(`scene_meta.asm:${c.line}: branch to undefined label $${hex(c.ops[1], 2)}`);
            }
            stack.push({ rec, idx: idx + 1 });
        }
    }

    const gates: GateSite[] = [];
    for (const rec of order) {
        rec.cmds.forEach((c, idx) => {
            if (c.kind !== 'branch') return;
            const scenes = uniqSorted(reachedBy.get(`${rec.id}:${idx}`) ?? []);
            if (!scenes.includes(rec.id) && ctx.sceneIds.has(rec.id)) warnings.push(`scene_meta.asm:${c.line}: record $${hex(rec.id, 2)} does not reach its own branch`);
            gates.push({
                offset: c.pos, file: file.rel, line: c.line, kind: 'scene_gate', opcode: 'branch',
                operands: `#${hex(c.ops[0], 2)}, #${hex(c.ops[1], 2)}`, index: c.ops[0], width: 'byte', sense: 'set', role: 'branch',
                record: rec.id, label: c.ops[1], scenes, sceneSource: 'scene_meta',
            });
        });
    }
    gates.sort(cmpSite);
    return { gates, reach: reachedBy.size };
}

function findBlock(blocks: Record<string, unknown>, name: string): { start: number; end: number } | null {
    for (const scene of Object.values(blocks)) {
        const b = (scene as Record<string, { start?: number; end?: number }>)[name];
        if (b && typeof b.start === 'number' && typeof b.end === 'number') return { start: b.start, end: b.end };
    }
    return null;
}

// ------------------------------------------------------------------------------------------------------------
// COP scan: flag COPs, item COPs, SwitchCase
// ------------------------------------------------------------------------------------------------------------

const FLAG_COPS: Record<string, { role: Role; width: Width; sense: boolean }> = {
    SetFlagByte: { role: 'set', width: 'byte', sense: false },
    SetFlagWord: { role: 'set', width: 'word', sense: false },
    ClearFlagByte: { role: 'clear', width: 'byte', sense: false },
    ClearFlagWord: { role: 'clear', width: 'word', sense: false },
    BranchOnFlagByte: { role: 'branch', width: 'byte', sense: true },
    BranchOnFlagWord: { role: 'branch', width: 'word', sense: true },
    WaitOnFlagByte: { role: 'wait', width: 'byte', sense: true },
    WaitOnFlagWord: { role: 'wait', width: 'word', sense: true },
};
const ITEM_COPS: Record<string, Role> = { GiveItem: 'set', RemoveItem: 'clear', BranchIfHasItem: 'branch', BranchIfItemEquipped: 'branch' };
const COP_RE = /^\s*COP \[(\w+)\](?: \( (.*?) \))?\s*$/;

interface CopScan {
    cops: CopSite[];
    unresolved: Array<{ file: string; line: number; opcode: string; operands: string }>;
    items: ItemSite[];
    switches: SwitchSite[];
    switchZero: number;
    untagged: Array<{ file: string; line: number; text: string }>;
    dungeonKill: number;
}

function regionOf(addr: number): string {
    if (addr < 0x0A80) return 'flags:event';
    if (addr < 0x0AA0) return 'flags:wram';
    if (addr < 0x0AB4) return 'flags:tail';
    if (addr <= 0x0BFB) return 'state';
    return 'other';
}

function scanCops(ctx: Ctx, sceneOf: (f: AsmFile) => Scenes): CopScan {
    const res: CopScan = { cops: [], unresolved: [], items: [], switches: [], switchZero: 0, untagged: [], dungeonKill: 0 };
    for (const f of ctx.files) {
        let sc: Scenes | null = null;
        const scenes = () => (sc ??= sceneOf(f));
        for (const l of f.lines) {
            const m = COP_RE.exec(l.code);
            if (!m) continue;
            const name = m[1];
            const isFlag = name in FLAG_COPS;
            const isItem = name in ITEM_COPS;
            if (!isFlag && !isItem && name !== 'SwitchCase' && name !== 'SetDungeonKillFlag') continue;
            if (name === 'SetDungeonKillFlag') { res.dungeonKill++; continue; }
            const operands = m[2] ?? '';
            if (l.tag === null) { res.untagged.push({ file: f.rel, line: l.n, text: l.text.trim() }); continue; }
            const args = parseOperands(operands);
            const s = scenes();
            if (isFlag) {
                const spec = FLAG_COPS[name];
                const tok = args[0] ?? '';
                const wm = /^#\$([0-9A-Fa-f]{4})$/.exec(tok);
                const bm = /^#([0-9A-Fa-f]{2})$/.exec(tok);
                const index = wm ? parseInt(wm[1], 16) : bm ? parseInt(bm[1], 16) : null;
                if (index === null) { res.unresolved.push({ file: f.rel, line: l.n, opcode: name, operands }); continue; }
                const site: CopSite = {
                    offset: l.tag, file: f.rel, line: l.n, kind: 'cop', opcode: name, operands, index,
                    width: spec.width, role: spec.role, scenes: s.scenes, sceneSource: s.source,
                };
                if (index >= 0x400) site.wram = index - 0x400;
                if (spec.sense) {
                    const sv = parseByteToken(args[1] ?? '');
                    site.sense = sv === null ? undefined : sv === 0 ? 'clear' : 'set';
                }
                res.cops.push(site);
            } else if (isItem) {
                const id = parseByteToken(args[0] ?? '');
                if (id === null) { res.unresolved.push({ file: f.rel, line: l.n, opcode: name, operands }); continue; }
                res.items.push({ offset: l.tag, file: f.rel, line: l.n, opcode: name, operands, itemId: id, role: ITEM_COPS[name], scenes: s.scenes, sceneSource: s.source });
            } else {
                const opm = /^#\$([0-9A-Fa-f]{4})$/.exec(args[0] ?? '');
                if (!opm) { res.unresolved.push({ file: f.rel, line: l.n, opcode: name, operands }); continue; }
                const operand = parseInt(opm[1], 16);
                if (operand === 0) { res.switchZero++; continue; }
                res.switches.push({
                    offset: l.tag, file: f.rel, line: l.n, opcode: 'SwitchCase', operands, operand, operandHex: '$' + hex(operand, 4),
                    target: (args[1] ?? '').replace(/^&/, ''),
                    region: operand >= 0x0A00 && operand <= 0x0BFB ? regionOf(operand) : operand < 0x100 ? 'actor-dp' : 'other',
                    role: 'direct read', scenes: s.scenes, sceneSource: s.source,
                });
            }
        }
    }
    res.cops.sort(cmpSite);
    res.items.sort(cmpSite);
    res.switches.sort(cmpSite);
    return res;
}

// ------------------------------------------------------------------------------------------------------------
// Helper calls (flag_helpers.*)
// ------------------------------------------------------------------------------------------------------------

interface HelperSpec { action: 'test' | 'set' | 'clear' | 'block'; width: Width; toGlobal?: (a: number) => number; wramBase?: number; note: string }

const HELPERS: Record<string, HelperSpec> = {
    TestEventFlag: { action: 'test', width: 'word', toGlobal: a => a, note: 'index = A (16 bit), no base' },
    SetEventFlag: { action: 'set', width: 'word', toGlobal: a => a, note: 'index = A (16 bit), no base' },
    ClearEventFlag: { action: 'clear', width: 'word', toGlobal: a => a, note: 'index = A (16 bit), no base' },
    TestFlagRaw: { action: 'test', width: 'byte', toGlobal: a => a & 0xFF, note: 'A masked to 8 bits' },
    SetFlagRaw: { action: 'set', width: 'byte', toGlobal: a => a & 0xFF, note: 'A masked to 8 bits' },
    ClearFlagRaw: { action: 'clear', width: 'byte', toGlobal: a => a & 0xFF, note: 'A masked to 8 bits' },
    TestFlag_0100: { action: 'test', width: 'byte', toGlobal: a => 0x100 + (a & 0xFF), note: '$0100 + (A and $FF)' },
    SetFlag_0100: { action: 'set', width: 'byte', toGlobal: a => 0x100 + (a & 0xFF), note: '$0100 + (A and $FF)' },
    TestEventFlag_0200: { action: 'test', width: 'byte', toGlobal: a => 0x200 + (a & 0xFF), note: '$0200 + (A and $FF)' },
    SetEventFlag_0200: { action: 'set', width: 'byte', toGlobal: a => 0x200 + (a & 0xFF), note: '$0200 + (A and $FF)' },
    TestFlag_0300: { action: 'test', width: 'byte', toGlobal: a => 0x300 + (a & 0xFF), note: '$0300 + (A and $FF)' },
    SetFlag_0300: { action: 'set', width: 'byte', toGlobal: a => 0x300 + (a & 0xFF), note: '$0300 + (A and $FF)' },
    TestFlag_0510: { action: 'test', width: 'byte', toGlobal: a => 0x510 + (a & 0xFF), note: '$0510 + (A and $FF)' },
    TestWramFlag: { action: 'test', width: 'word', toGlobal: a => 0x400 + a, wramBase: 0, note: 'wramFlags index = A (16 bit); global = $0400 + A' },
    SetWramFlag: { action: 'set', width: 'word', toGlobal: a => 0x400 + a, wramBase: 0, note: 'wramFlags index = A (16 bit); global = $0400 + A' },
    TestWramFlag_Offset100: { action: 'test', width: 'byte', toGlobal: a => 0x500 + (a & 7), wramBase: 0x100, note: 'wramFlags $0100 + (A and 7); global = $0500 + (A and 7)' },
    SetWramFlag_Offset100: { action: 'set', width: 'byte', toGlobal: a => 0x500 + (a & 7), wramBase: 0x100, note: 'wramFlags $0100 + (A and 7); global = $0500 + (A and 7)' },
    ClearAllWramFlags: { action: 'block', width: 'unknown', note: 'zero-fills wramFlags ($0A80-$0A9F): global $0400-$04FF' },
};

const HELPER_CALL_RE = /^\s*(JSL|JSR|JML|JMP)\s+\$[@&]?flag_helpers\.(\w+)\s*$/;
const HELPER_REF_RE = /\bflag_helpers\.(\w+)/;

function previousCode(f: AsmFile, idx: number): string | null {
    for (let i = idx - 1; i >= 0 && i >= idx - 4; i--) {
        const c = f.lines[i].code.trim();
        if (c === '') continue;
        return c;
    }
    return null;
}

function scanHelperCalls(ctx: Ctx, sceneOf: (f: AsmFile) => Scenes): { calls: HelperCall[]; nonCalls: Ev[]; untagged: Ev[] } {
    const calls: HelperCall[] = [];
    const nonCalls: Ev[] = [];
    const untagged: Ev[] = [];
    for (const f of ctx.files) {
        let sc: Scenes | null = null;
        f.lines.forEach((l, idx) => {
            if (!HELPER_REF_RE.test(l.code) || /^\s*\?/.test(l.code)) return;
            const m = HELPER_CALL_RE.exec(l.code);
            if (!m) { nonCalls.push({ file: f.rel, line: l.n, text: l.text.trim() }); return; }
            if (l.tag === null) { untagged.push({ file: f.rel, line: l.n, text: l.text.trim() }); return; }
            sc ??= sceneOf(f);
            const spec = HELPERS[m[2]];
            const call: HelperCall = {
                offset: l.tag, file: f.rel, line: l.n, call: m[1], helper: m[2],
                action: spec && spec.action !== 'block' ? spec.action : 'set', role: 'helper call', width: spec?.width ?? 'unknown',
                resolution: 'none', trace: null, alsoIn: [], indices: [], wram: [], scenes: sc.scenes, sceneSource: sc.source,
            };
            const prev = previousCode(f, idx);
            const im = prev ? /^LDA #\$([0-9A-Fa-f]{4})$/.exec(prev) : null;
            if (im) call.input = parseInt(im[1], 16);
            calls.push(call);
        });
    }
    calls.sort(cmpSite);
    return { calls, nonCalls, untagged };
}

// ------------------------------------------------------------------------------------------------------------
// The dynamic traces (re-derived from the current tables)
// ------------------------------------------------------------------------------------------------------------

function fileOf(ctx: Ctx, rel: string): AsmFile | undefined { return ctx.byRel.get(rel); }

function stemOf(c: HelperCall): string { return c.file.replace(/^.*\//, '').replace(/\.asm$/, ''); }

function parseTableRows(f: AsmFile | undefined, label: string): Array<{ line: number; text: string; match: RegExpExecArray | null }> {
    if (!f) return [];
    const rows: Array<{ line: number; text: string; match: RegExpExecArray | null }> = [];
    let inside = false;
    for (const l of f.lines) {
        if (!inside) { if (new RegExp(`^${label} \\[`).test(l.text)) inside = true; continue; }
        if (/^\]/.test(l.text)) break;
        rows.push({ line: l.n, text: l.text.trim(), match: null });
    }
    return rows;
}

function byteTable(f: AsmFile | undefined, label: string): Array<{ value: number; line: number; text: string }> {
    return parseTableRows(f, label).flatMap(r => {
        const m = /^#([0-9A-Fa-f]{2})\b/.exec(r.text);
        return m ? [{ value: parseInt(m[1], 16), line: r.line, text: r.text }] : [];
    });
}

function mergeCands(list: Cand[]): Cand[] {
    const by = new Map<number, Cand>();
    for (const c of list) {
        const cur = by.get(c.index);
        if (!cur) { by.set(c.index, { ...c, scenes: c.scenes ? [...c.scenes] : undefined, rows: c.rows ?? 1, evidence: [...c.evidence] }); continue; }
        cur.rows = (cur.rows ?? 1) + (c.rows ?? 1);
        if (c.scenes) cur.scenes = uniqSorted([...(cur.scenes ?? []), ...c.scenes]);
        if (cur.evidence.length < 3) for (const e of c.evidence) if (cur.evidence.length < 3 && !cur.evidence.some(x => x.line === e.line && x.file === e.file)) cur.evidence.push(e);
    }
    return [...by.values()].sort((a, b) => a.index - b.index);
}

function spawnEv(r: SpawnRow, ctx: Ctx): Ev {
    const f = ctx.byRel.get('tables/scene_actors.asm');
    return { file: 'tables/scene_actors.asm', line: r.line, text: f ? f.lines[r.line - 1].text.trim().replace(/\s+;[0-9A-F]+$/, '') : '' };
}

function requirePattern(ctx: Ctx, stem: string, re: RegExp, what: string, out: TraceResult) {
    const f = ctx.byStem.get(stem);
    if (!f) { out.warnings.push(`${stem}.asm not found (${what})`); return; }
    const hit = f.lines.find(l => re.test(l.code));
    if (hit) out.assumptions.push(`${f.rel}:${hit.n} ${what}`);
    else out.warnings.push(`${f.rel}: expected '${re.source}' (${what}) not found, the trace assumption may be stale`);
}

type Transform = { kind: 'table'; label: string } | { kind: 'add'; n: number } | { kind: 'id' };

/** Actor-parameter trace: spawn byte 2 of the scene_actors rows (bit 0 set: $0E = byte >> 1), then the actor's own transform and the helper base. */
function actorParamTrace(ctx: Ctx, stem: string, tr: Transform, base: number, checks: Array<[RegExp, string]>): TraceResult {
    const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
    const f = ctx.byStem.get(stem);
    if (!f) { out.warnings.push(`${stem}.asm not found`); return out; }
    for (const [re, what] of checks) requirePattern(ctx, stem, re, what, out);
    const table = tr.kind === 'table' ? byteTable(f, tr.label) : [];
    const cands: Cand[] = [];
    const rows = ctx.spawns.filter(r => r.kind === 'actor' && r.file === f.rel);
    if (rows.length === 0) out.warnings.push(`${stem}: no spawn row in scene_actors.asm (dead or runtime-spawned actor)`);
    for (const r of rows) {
        if ((r.attr & 1) === 0) { out.warnings.push(`scene_actors.asm:${r.line}: ${stem} spawn byte $${hex(r.attr, 2)} has bit 0 clear (no parameter)`); continue; }
        const param = (r.attr & 0xFF) >> 1;
        let value: number;
        if (tr.kind === 'table') {
            const t = table[param];
            if (!t) { out.warnings.push(`scene_actors.asm:${r.line}: parameter ${param} is outside ${tr.label}`); continue; }
            value = t.value;
        } else if (tr.kind === 'add') value = (param + tr.n) & 0xFF;
        else value = param & 0xFF;
        cands.push({ index: base + value, scenes: [r.scene], rows: 1, evidence: [spawnEv(r, ctx)] });
    }
    out.candidates = mergeCands(cands);
    return out;
}

function tableTrace(ctx: Ctx): { clear: TraceResult; boss: TraceResult; chest: TraceResult; statue: TraceResult } {
    const clear: TraceResult = { candidates: [], warnings: [], assumptions: [] };
    const boss: TraceResult = { candidates: [], warnings: [], assumptions: [] };
    const chest: TraceResult = { candidates: [], warnings: [], assumptions: [] };
    const statue: TraceResult = { candidates: [], warnings: [], assumptions: [] };

    const cf = ctx.byStem.get('enemy_clear_reward_table');
    if (!cf) clear.warnings.push('enemy_clear_reward_table.asm not found');
    else {
        byteTable(cf, 'enemy_clear_reward_table').forEach((r, scene) => {
            if (r.value !== 0) clear.candidates.push({ index: 0x300 + scene, scenes: [scene], rows: 1, evidence: [{ file: cf.rel, line: r.line, text: r.text }] });
        });
        clear.assumptions.push(`${cf.rel}: one tier byte per scene id (row position = scene id), nonzero = reward configured`);
    }

    const bf = ctx.byStem.get('boss_clear_reward_handler');
    if (!bf) boss.warnings.push('boss_clear_reward_handler.asm not found');
    else {
        const seen = new Set<number>();
        parseTableRows(bf, 'boss_reward_range_table').forEach((r, row) => {
            const m = /^boss-reward-range <\s*#([0-9A-Fa-f]{2})/.exec(r.text);
            if (!m) return;
            const scene = parseInt(m[1], 16);
            if (seen.has(scene)) return; // the scene search stops at the first matching row
            seen.add(scene);
            boss.candidates.push({ index: 0x500 + (row & 7), wram: 0x100 + (row & 7), scenes: [scene], rows: 1, evidence: [{ file: bf.rel, line: r.line, text: r.text.replace(/\s+;[0-9A-F]+$/, '') }] });
        });
        boss.assumptions.push(`${bf.rel}: BossRewardFindScene takes the first row whose scene id matches; row number masked to 3 bits by the helper`);
    }

    const sf = ctx.byRel.get('tables/scene_chest_table.asm');
    if (!sf) chest.warnings.push('tables/scene_chest_table.asm not found');
    else {
        const cands: Cand[] = [];
        for (const l of sf.lines) {
            const m = /^\s+chest-entry <\s*([^>]*?)\s*>/.exec(l.text);
            if (!m) continue;
            const ops = parseOperands(m[1]);
            const flag = parseByteToken(ops[3] ?? '');
            if (flag === null) { chest.warnings.push(`scene_chest_table.asm:${l.n}: flag byte not literal`); continue; }
            cands.push({ index: 0x200 + (flag & 0x7F), rows: 1, evidence: [{ file: sf.rel, line: l.n, text: l.text.trim() }] });
        }
        chest.candidates = mergeCands(cands);
        chest.assumptions.push(`${sf.rel}: chest-entry byte 3, bits 0-6 = flag; callers mask with $7F then the helper adds $0200`);
    }

    const stf = ctx.byStem.get('statue_inventory_reward');
    if (!stf) statue.warnings.push('statue_inventory_reward.asm not found');
    else {
        for (const r of parseTableRows(stf, 'statue_reward_table')) {
            const m = /^statue-reward <\s*#([0-9A-Fa-f]{2})/.exec(r.text);
            if (m) statue.candidates.push({ index: parseInt(m[1], 16), rows: 1, evidence: [{ file: stf.rel, line: r.line, text: r.text.replace(/\s+;[0-9A-F]+$/, '') }] });
        }
        statue.candidates = mergeCands(statue.candidates);
        statue.assumptions.push(`${stf.rel}: statue-reward entry +0 is the raw event-flag index (TestFlagRaw / SetFlagRaw)`);
    }
    return { clear, boss, chest, statue };
}

function spawnTrace(ctx: Ctx, pick: (r: SpawnRow) => number, base: number, wramBase: number | null, label: string): TraceResult {
    const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
    const cands: Cand[] = [];
    for (const r of ctx.spawns) {
        if (r.kind !== 'enemy') continue;
        const v = pick(r);
        if (v === 0) continue;
        const c: Cand = { index: base + v, scenes: [r.scene], rows: 1, evidence: [spawnEv(r, ctx)] };
        if (wramBase !== null) c.wram = wramBase + v;
        cands.push(c);
    }
    out.candidates = mergeCands(cands);
    out.assumptions.push(`scene_actors.asm enemy-spawn rows: ${label}; zero = no flag`);
    return out;
}

const callsIn = (stem: string, helpers?: string[]) => (c: HelperCall) => stemOf(c) === stem && (!helpers || helpers.includes(c.helper));
const anyOf = (...helpers: string[]) => (c: HelperCall) => helpers.includes(c.helper);

function buildTraces(ctx: Ctx, tables: ReturnType<typeof tableTrace>): TraceDef[] {
    const offsetCalls = (c: HelperCall) => c.helper === 'TestWramFlag_Offset100' || c.helper === 'SetWramFlag_Offset100';
    const defs: TraceDef[] = [
        {
            id: 'wram_offset_constant_callers', helpers: ['TestWramFlag_Offset100'],
            description: 'Fixed boss-actor WRAM flag inputs observed at call sites; each helper masks the literal input to its low three bits.',
            method: 'Each candidate pairs the immediate `LDA` input with its `TestWramFlag_Offset100` call; the helper masks the input with `$0007` and adds `$0100`.',
            matches: c => c.helper === 'TestWramFlag_Offset100' && c.input !== undefined,
            derive: () => {
                const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
                const cands: Cand[] = [];
                for (const c of ctx.calls) {
                    if (c.helper !== 'TestWramFlag_Offset100' || c.input === undefined) continue;
                    const f = ctx.byRel.get(c.file)!;
                    cands.push({ index: 0x500 + (c.input & 7), wram: 0x100 + (c.input & 7), rows: 1, evidence: [{ file: c.file, line: c.line, text: f.lines[c.line - 1].text.trim().replace(/\s+;\s*\{\d+\}/, '') }] });
                }
                out.candidates = mergeCands(cands);
                return out;
            },
        },
        {
            id: 'dark_space_portal_death_flags', helpers: ['TestFlag_0100'],
            description: 'Actor-parameter-derived helper indices for `pyCC_dark_space_portal`.',
            method: 'The spawned actor parameter is decoded by the actor engine, then the actor-specific caller transform and helper offset select the index.',
            matches: callsIn('pyCC_dark_space_portal', ['TestFlag_0100']),
            derive: () => actorParamTrace(ctx, 'pyCC_dark_space_portal', { kind: 'id' }, 0x100, [[/LDA \$0E$/, 'flag index = actor $0E (spawn byte >> 1)']]),
        },
        {
            id: 'diamond_mine_laborer_flags', helpers: ['TestFlagRaw', 'SetFlagRaw'],
            description: 'Possible event-flag indices selected by spawned Diamond Mine laborer actor parameters and the actor\'s lookup table.',
            method: 'Only rows for `dm3F_laborer` actually spawned in `scene_actors.asm` are included. The actor parameter decodes to the byte-table X index; `extracted/diamond_mine/mine_main/dm3F_laborer.asm` uses that index to select a flag byte from `extracted/diamond_mine/mine_main/dm3F_laborer.asm`, then calls `TestFlagRaw / SetFlagRaw`. Unspawned entries in the actor\'s local table are excluded.',
            matches: callsIn('dm3F_laborer', ['TestFlagRaw', 'SetFlagRaw']),
            derive: () => actorParamTrace(ctx, 'dm3F_laborer', { kind: 'table', label: 'byte_0AA72F' }, 0, [[/LDA \$@byte_0AA72F, X$/, 'flag byte = byte_0AA72F[$0E]']]),
        },
        {
            id: 'necklace_stone_flags', helpers: ['TestFlagRaw', 'SetFlagRaw'],
            description: 'Possible event-flag indices selected by spawned necklace-stone actor parameters and the actor\'s lookup table.',
            method: 'Only rows for `gw82_necklace_stone` actually spawned in `scene_actors.asm` are included. The actor parameter decodes to the byte-table X index; `extracted/great_wall/gw82_necklace_stone.asm` uses that index to select a flag byte from `extracted/great_wall/gw82_necklace_stone.asm`, then calls `TestFlagRaw / SetFlagRaw`. Unspawned entries in the actor\'s local table are excluded.',
            matches: callsIn('gw82_necklace_stone', ['TestFlagRaw', 'SetFlagRaw']),
            derive: () => actorParamTrace(ctx, 'gw82_necklace_stone', { kind: 'table', label: 'byte_07B5F5' }, 0, [[/LDA \$@byte_07B5F5, X$/, 'flag byte = byte_07B5F5[$0E]']]),
        },
        {
            id: 'statue_reward_flags', helpers: ['TestFlagRaw', 'SetFlagRaw'],
            description: 'Possible event-flag indices selected from the statue-reward table.',
            method: 'The selected four-byte `statue-reward` row supplies the raw event-flag index to the claim test and flag set.',
            matches: c => ['inventory_statue_slot', 'statue_inventory_reward'].includes(stemOf(c)) && (c.helper === 'TestFlagRaw' || c.helper === 'SetFlagRaw'),
            derive: () => tables.statue,
        },
        {
            id: 'enemy_clear_reward_flags', helpers: ['TestFlag_0300', 'SetFlag_0300'],
            description: 'Possible event-flag indices used for per-scene enemy-clear reward/reveal state.',
            method: 'The helper adds `$0300` to a scene index; nonzero table rows bound scenes with configured enemy-clear reward behavior.',
            matches: anyOf('TestFlag_0300', 'SetFlag_0300'),
            derive: () => tables.clear,
        },
        {
            id: 'boss_reward_wram_flags', helpers: ['TestWramFlag_Offset100', 'SetWramFlag_Offset100'],
            description: 'WRAM indices selected by the matched boss-reward range row.',
            method: 'The caller matches the current scene to a boss-reward row; its row number is masked to 0-7 before `$0100` is added.',
            matches: c => stemOf(c) === 'boss_clear_reward_handler' && offsetCalls(c),
            derive: () => tables.boss,
        },
        {
            id: 'barrier_chest_flags', helpers: ['TestEventFlag_0200', 'SetEventFlag_0200'],
            description: 'Possible event-flag indices referenced by table-driven barrier and chest records.',
            method: 'The callers read the fourth record byte, mask it to seven bits, and pass it to the `$0200` helper.',
            matches: c => (c.helper === 'TestEventFlag_0200' || c.helper === 'SetEventFlag_0200') && stemOf(c) !== 'hidden_red_jewel',
            derive: () => tables.chest,
        },
        {
            id: 'hidden_red_jewel_flags', helpers: ['SetEventFlag_0200', 'TestEventFlag_0200'],
            description: 'Actor-parameter-derived helper indices for `hidden_red_jewel`.',
            method: 'The spawned actor parameter is decoded by the actor engine, then the actor-specific caller transform and helper offset select the index.',
            matches: callsIn('hidden_red_jewel', ['SetEventFlag_0200', 'TestEventFlag_0200']),
            derive: () => actorParamTrace(ctx, 'hidden_red_jewel', { kind: 'add', n: 0x80 }, 0x200, [[/ADC #\$0080$/, 'flag index = $0E + $80 on base $0200']]),
        },
        {
            id: 'falling_orb_flags', helpers: ['SetFlagRaw', 'TestFlagRaw'],
            description: 'Actor-parameter-derived helper indices for `pyD4_falling_orb`.',
            method: 'The spawned actor parameter is decoded by the actor engine, then the actor-specific caller transform and helper offset select the index.',
            matches: callsIn('pyD4_falling_orb', ['SetFlagRaw', 'TestFlagRaw']),
            derive: () => actorParamTrace(ctx, 'pyD4_falling_orb', { kind: 'add', n: 0x80 }, 0, [[/ADC #\$0080$/, 'flag index = $0E + $80']]),
        },
        {
            id: 'hit_switch_flags', previousId: 'floor_button_flags', helpers: ['SetFlagRaw'],
            description: 'Actor-parameter-derived helper indices for `hit_switch` (called `floor_button` in the old inventory).',
            method: 'The spawned actor parameter is decoded by the actor engine, then the actor-specific caller transform and helper offset select the index.',
            matches: callsIn('hit_switch', ['SetFlagRaw']),
            derive: () => actorParamTrace(ctx, 'hit_switch', { kind: 'id' }, 0, [[/LDA \$0E$/, 'flag number $24 := $0E (spawn byte >> 1)']]),
        },
        {
            id: 'gold_tile_flags', helpers: ['ClearFlagRaw', 'SetFlagRaw'],
            description: 'Actor-parameter-derived helper indices for `ir1F_gold_tile`.',
            method: 'The spawned actor parameter is decoded by the actor engine, then the actor-specific caller transform and helper offset select the index.',
            matches: callsIn('ir1F_gold_tile', ['ClearFlagRaw', 'SetFlagRaw']),
            derive: () => actorParamTrace(ctx, 'ir1F_gold_tile', { kind: 'id' }, 0, [[/LDA \$0E$/, 'flag index = actor $0E (spawn byte >> 1)']]),
        },
        {
            id: 'enemy_death_action_flags', helpers: ['TestFlag_0100', 'SetFlag_0100'],
            description: 'Event flags used to guard enemy death actions; zero-valued death-action indices are skipped by callers.',
            method: 'Enemy-spawn rows supply the death-action index, actor execution stores it, and the helper adds `$0100`.',
            matches: anyOf('TestFlag_0100', 'SetFlag_0100'),
            derive: () => spawnTrace(ctx, r => r.eventBlock ?? 0, 0x100, null, 'operand 7 (event-block index) is the death-action index'),
        },
        {
            id: 'dungeon_kill_wram_flags', helpers: ['SetWramFlag'],
            description: 'Possible WRAM indices set when a nonzero enemy number is defeated and tested to suppress defeated enemies on later scene loads.',
            method: 'Enemy-spawn rows supply the enemy number; actor execution stores it, the dungeon-kill COP handler passes it directly to `SetWramFlag`, and scene loading tests the same index in `wramFlags`.',
            matches: c => c.helper === 'SetWramFlag',
            derive: () => spawnTrace(ctx, r => r.enemyNum ?? 0, 0x400, 0, 'operand 6 (enemy number) is the wramFlags index'),
        },
        {
            id: 'inventory_ability_flags', helpers: ['TestFlag_0510'],
            description: 'Status-menu ability flags computed from the current character form and selected ability slot.',
            method: '`TestAbilityFlag` computes `4 * characterForm + slot`; `TestFlag_0510` then adds `$0510`.',
            matches: anyOf('TestFlag_0510'),
            derive: () => {
                const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
                const f = ctx.byStem.get('inventory_menu');
                if (!f) { out.warnings.push('inventory_menu.asm not found'); return out; }
                const slots = new Set<number>();
                const evidence: Ev[] = [];
                f.lines.forEach((l, i) => {
                    if (!/^\s*JSR \$&TestAbilityFlag\s*$/.test(l.code)) return;
                    const prev = previousCode(f, i);
                    const m = prev ? /^LDA #\$([0-9A-Fa-f]{4})$/.exec(prev) : null;
                    if (m) { slots.add(parseInt(m[1], 16)); evidence.push({ file: f.rel, line: l.n, text: `LDA #$${m[1]} ; JSR $&TestAbilityFlag` }); }
                });
                const formLine = f.lines.find(l => /characterForm \(\$0AD4\): Current character \(0=Will, 1=Freedan, 2=Shadow\)/.test(l.text));
                if (!formLine) out.warnings.push('inventory_menu.asm: the characterForm legend (0=Will, 1=Freedan, 2=Shadow) was not found');
                else out.assumptions.push(`${f.rel}:${formLine.n} characterForm 0=Will, 1=Freedan, 2=Shadow`);
                if (slots.size === 0) out.warnings.push('inventory_menu.asm: no immediate slot before TestAbilityFlag');
                out.assumptions.push(`${f.rel}: slots ${sortNum([...slots]).join(',')} from the immediates before TestAbilityFlag (the status cursor $22 walks the same rows 0-2)`);
                const cands: Cand[] = [];
                for (let form = 0; form <= 2; form++) for (const slot of sortNum([...slots])) cands.push({ index: 0x510 + form * 4 + slot, rows: 1, evidence: evidence.slice(0, 1) });
                out.candidates = mergeCands(cands);
                return out;
            },
        },
        {
            id: 'scene_meta_gates', helpers: ['TestFlagRaw'],
            description: 'Flag index of every `$13 branch` command in the scene_meta command streams (runtime operand of SceneCmd_Branch).',
            method: '`SceneCmd_Branch` reads its flag index with `ReadScriptByte` and calls `TestFlagRaw`; every operand sits in a literal `branch < flag, label >` command of `tables/scene_meta.asm`, decoded record by record (replaces the old unresolved input `SceneCmd_ConditionalLoad`).',
            matches: callsIn('scene_script', ['TestFlagRaw']),
            derive: () => {
                const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
                const f = ctx.byRel.get('tables/scene_meta.asm');
                out.candidates = mergeCands(ctx.gates.map(g => ({ index: g.index, scenes: g.scenes, rows: 1, evidence: [{ file: g.file, line: g.line, text: f ? f.lines[g.line - 1].text.trim().replace(/\s+;[0-9A-F]+$/, '') : '' }] })));
                out.assumptions.push('tables/scene_meta.asm: the scenes of a candidate are the scene ids that reach the branch (linear flow, jump and set-branch follow the label)');
                return out;
            },
        },
        {
            id: 'wram_offset_helper_domain', helpers: ['TestWramFlag_Offset100', 'SetWramFlag_Offset100'],
            description: 'The offset WRAM helper family can address exactly indices `$0100-$0107` after masking its input.',
            method: 'Helper implementation masks the caller value with `$0007`, then adds `$0100`.',
            matches: offsetCalls,
            derive: () => {
                const out: TraceResult = { candidates: [], warnings: [], assumptions: [] };
                const f = ctx.byStem.get('flag_helpers');
                const hit = f?.lines.find(l => /^\s*AND #\$0007$/.test(l.code));
                if (f && hit) out.assumptions.push(`${f.rel}:${hit.n} AND #$0007 (3-bit mask), then ADC #$0100`);
                else out.warnings.push('flag_helpers.asm: the AND #$0007 mask of TestWramFlag_Offset100 was not found');
                for (let i = 0; i < 8; i++) out.candidates.push({ index: 0x500 + i, wram: 0x100 + i, rows: 1, evidence: hit && f ? [{ file: f.rel, line: hit.n, text: 'AND #$0007' }] : [] });
                return out;
            },
        },
    ];
    return defs;
}

interface TraceOut {
    id: string; previousId?: string; helpers: string[]; description: string; method: string; assumptions: string[]; warnings: string[];
    call_sites: Array<{ file: string; line: number; offset: number; helper: string }>;
    candidate_indices: number[]; wram_indices?: number[]; candidates: Cand[];
}

function resolveCalls(ctx: Ctx, tables: ReturnType<typeof tableTrace>): { traces: TraceOut[]; unresolved: HelperCall[] } {
    const defs = buildTraces(ctx, tables);
    const traces: TraceOut[] = [];
    const results = new Map<string, TraceResult>();
    for (const d of defs) results.set(d.id, d.derive(ctx));

    // primary trace = first matching definition, in the order of `defs` (most specific first)
    for (const c of ctx.calls) {
        const matching = defs.filter(d => d.matches(c));
        const spec = HELPERS[c.helper];
        if (!spec) continue;
        if (spec.action === 'block') { c.resolution = 'block'; c.range = [0x400, 0x4FF]; continue; }
        if (stemOf(c) === 'cop_handlers_scene_flags') { c.resolution = 'cop-operand'; continue; }
        if (matching.length === 0) continue;
        const primary = matching[0];
        c.trace = primary.id;
        c.alsoIn = matching.slice(1).map(d => d.id).filter(id => id !== 'wram_offset_helper_domain');
        const res = results.get(primary.id)!;
        c.resolution = primary.id === 'wram_offset_constant_callers' ? 'constant' : 'trace';
        if (primary.id === 'wram_offset_constant_callers') {
            const idx = spec.toGlobal!(c.input!);
            c.indices = [idx];
            c.wram = spec.wramBase !== undefined ? [spec.wramBase + (c.input! & 7)] : [];
        } else {
            c.indices = uniqSorted(res.candidates.map(x => x.index));
            c.wram = uniqSorted(res.candidates.flatMap(x => (x.wram !== undefined ? [x.wram] : [])));
        }
    }

    for (const d of defs) {
        const res = results.get(d.id)!;
        const sites = ctx.calls.filter(c => c.trace === d.id || c.alsoIn.includes(d.id));
        const wram = uniqSorted(res.candidates.flatMap(x => (x.wram !== undefined ? [x.wram] : [])));
        const t: TraceOut = {
            id: d.id, ...(d.previousId ? { previousId: d.previousId } : {}), helpers: d.helpers, description: d.description, method: d.method,
            assumptions: res.assumptions, warnings: res.warnings,
            call_sites: sites.map(c => ({ file: c.file, line: c.line, offset: c.offset, helper: c.helper })).sort(cmpSite),
            candidate_indices: uniqSorted(res.candidates.map(x => x.index)),
            ...(wram.length > 0 ? { wram_indices: wram } : {}),
            candidates: res.candidates,
        };
        traces.push(t);
    }
    const unresolved = ctx.calls.filter(c => c.resolution === 'none');
    return { traces, unresolved };
}

// ------------------------------------------------------------------------------------------------------------
// Direct accesses to $0A00-$0BFB
// ------------------------------------------------------------------------------------------------------------

const READ_OPS = new Set(['LDA', 'LDX', 'LDY', 'CMP', 'CPX', 'CPY', 'BIT', 'AND', 'ORA', 'EOR', 'ADC', 'SBC']);
const WRITE_OPS = new Set(['STA', 'STX', 'STY', 'STZ']);
const RMW_OPS = new Set(['INC', 'DEC', 'ASL', 'LSR', 'ROL', 'ROR', 'TSB', 'TRB']);
const X_OPS = new Set(['LDX', 'LDY', 'CPX', 'CPY', 'STX', 'STY']);
const FLAG_SYMBOLS = new Set(['eventFlags', 'wramFlags', 'L_wramFlags']);
const OPERAND_RE = /^\$([A-Za-z_]\w*|[0-9A-Fa-f]{4,6})(?:\+([0-9A-Fa-f]+))?(?:\s*,\s*([XY]))?$/;

function roleOfAccess(op: string, access: 'read' | 'write' | 'rmw'): Role {
    if (op === 'TSB') return 'set';
    if (op === 'TRB') return 'clear';
    return access === 'read' ? 'direct read' : 'direct write';
}

function scanDirect(ctx: Ctx, sceneOf: (f: AsmFile) => Scenes, globalSymbols: Map<string, number>, warnings: string[]): DirectAccess[] {
    const out: DirectAccess[] = [];
    for (const f of ctx.files) {
        let sc: Scenes | null = null;
        let m: 8 | 16 | null = null;
        let x: 8 | 16 | null = null;
        for (const l of f.lines) {
            if (BLOCK_DEF_RE.test(l.text) || COLON_DEF_RE.test(l.text)) { m = null; x = null; continue; }
            if (l.tag === null) continue;
            const im = /^\s*([A-Z]{3})\s+(\S.*?)\s*$/.exec(l.code);
            if (!im) continue;
            const op = im[1];
            const operand = im[2];
            const flagImm = /^#\$([0-9A-Fa-f]{2})$/.exec(operand);
            if ((op === 'REP' || op === 'SEP') && flagImm) {
                const mask = parseInt(flagImm[1], 16);
                if (mask & 0x20) m = op === 'REP' ? 16 : 8;
                if (mask & 0x10) x = op === 'REP' ? 16 : 8;
                continue;
            }
            const imm = /^#\$([0-9A-Fa-f]+)$/.exec(operand);
            if (imm) {
                const w = imm[1].length === 4 ? 16 : imm[1].length === 2 ? 8 : null;
                if (w) { if (X_OPS.has(op)) x = w; else if (READ_OPS.has(op)) m = w; }
                continue;
            }
            const access = READ_OPS.has(op) ? 'read' : WRITE_OPS.has(op) ? 'write' : RMW_OPS.has(op) ? 'rmw' : null;
            if (!access) continue;
            const om = OPERAND_RE.exec(operand);
            if (!om) continue;
            let address: number | null = null;
            let symbol: string | undefined;
            if (/^[0-9A-Fa-f]{4,6}$/.test(om[1]) && !/^[A-Za-z_]/.test(om[1])) {
                const v = parseInt(om[1], 16);
                const bank = om[1].length === 6 ? v >> 16 : 0;
                if (bank === 0 || bank === 0x7E) address = v & 0xFFFF;
            } else {
                const name = om[1];
                const v = f.symbols.get(name) ?? globalSymbols.get(name);
                if (v === undefined) continue;
                const bank = v > 0xFFFF ? v >> 16 : 0;
                if (bank === 0 || bank === 0x7E) { address = v & 0xFFFF; symbol = name; }
            }
            if (address === null) continue;
            if (om[2]) address += parseInt(om[2], 16);
            if (address < 0x0A00 || address > 0x0BFB) continue;
            sc ??= sceneOf(f);
            const region = regionOf(address);
            const state = X_OPS.has(op) ? x : m;
            const scope = f.rel === 'system/engine/flag_helpers.asm' ? 'flag_helpers' : f.rel === 'system/engine/save_system.asm' ? 'save_code' : 'other';
            const row: DirectAccess = {
                offset: l.tag, file: f.rel, line: l.n, opcode: op, operands: operand, address, addressHex: '$' + hex(address, 4),
                ...(symbol ? { symbol } : {}), region,
                ...(region.startsWith('flags:') && !om[3] ? { flags: [(address - 0x0A00) * 8, (address - 0x0A00) * 8 + 7] as [number, number] } : {}),
                indexed: om[3] !== undefined, access, role: roleOfAccess(op, access),
                width: state === 16 ? 'word' : state === 8 ? 'byte' : 'unknown',
                scope, flagSymbol: symbol !== undefined && FLAG_SYMBOLS.has(symbol), scenes: sc.scenes, sceneSource: sc.source,
            };
            out.push(row);
        }
    }
    out.sort(cmpSite);
    void warnings;
    return out;
}

// ------------------------------------------------------------------------------------------------------------
// Assembling and writing
// ------------------------------------------------------------------------------------------------------------

export interface Inventory {
    schema: number;
    generator: string;
    source: { root: string; asm_files: number; tagged_files: number; sha256: string };
    roles: readonly string[];
    counts: Record<string, unknown>;
    sites: Array<CopSite | GateSite | HelperSite>;
    helper_calls: HelperCall[];
    traces: TraceOut[];
    unresolved_dynamic_helper_inputs: Array<{ offset: number; file: string; line: number; helper: string; reason: string }>;
    item_sites: ItemSite[];
    switch_sites: SwitchSite[];
    direct_accesses: DirectAccess[];
    unresolved_cop_sites: Array<{ file: string; line: number; opcode: string; operands: string }>;
    files_without_scenes: Array<{ file: string; sites: number }>;
    warnings: string[];
}

function tally<T>(rows: T[], key: (r: T) => string): Record<string, number> {
    const m = new Map<string, number>();
    for (const r of rows) m.set(key(r), (m.get(key(r)) ?? 0) + 1);
    return Object.fromEntries([...m.entries()].sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0)));
}

export function buildInventory(root: string, extractedDir: string, dbDir: string): { inv: Inventory; errors: string[] } {
    const errors: string[] = [];
    const warnings: string[] = [];
    const tree = loadTree(extractedDir);
    const files = tree.files;
    const byRel = new Map(files.map(f => [f.rel, f]));
    const byStem = new Map<string, AsmFile>();
    for (const f of files) if (!byStem.has(f.stem)) byStem.set(f.stem, f);
    const labelFile = buildLabelIndex(files);

    const groups = JSON.parse(readFileSync(join(dbDir, 'groups.json'), 'utf-8')) as Record<string, { scenes?: Record<string, { id: number }> }>;
    const groupScenes = new Map<string, Map<string, number>>();
    const sceneIds = new Set<number>();
    for (const [g, def] of Object.entries(groups)) {
        const m = new Map<string, number>();
        for (const [k, s] of Object.entries(def.scenes ?? {})) { m.set(k, s.id); sceneIds.add(s.id); }
        groupScenes.set(g, m);
    }
    const blocks = JSON.parse(readFileSync(join(dbDir, 'blocks.json'), 'utf-8')) as Record<string, unknown>;

    const ctx: Ctx = { files, byRel, byStem, labelFile, spawns: [], placements: new Map(), sceneIds, groupScenes, calls: [], gates: [] };

    // placements
    const sa = byRel.get('tables/scene_actors.asm');
    if (sa) {
        ctx.spawns = parseSpawns(sa, ctx);
        for (const r of ctx.spawns) {
            if (!r.file) { warnings.push(`scene_actors.asm:${r.line}: spawn reference '${r.ref}' does not resolve to a file`); continue; }
            if (!ctx.placements.has(r.file)) ctx.placements.set(r.file, new Set());
            ctx.placements.get(r.file)!.add(r.scene);
        }
    } else warnings.push('tables/scene_actors.asm not found: no actor placement');
    const st = byRel.get('tables/scene_thinkers.asm');
    if (st) {
        for (const t of parseThinkerPlacements(st, ctx)) {
            if (!t.code) continue;
            if (!ctx.placements.has(t.code)) ctx.placements.set(t.code, new Set());
            ctx.placements.get(t.code)!.add(t.scene);
        }
    } else warnings.push('tables/scene_thinkers.asm not found: no thinker placement');

    const sceneCache = new Map<string, Scenes>();
    const sceneOf = (f: AsmFile): Scenes => {
        let s = sceneCache.get(f.rel);
        if (!s) { s = fileScenes(f, ctx); sceneCache.set(f.rel, s); }
        return s;
    };

    const gateRes = decodeGates(ctx, blocks, warnings);
    ctx.gates = gateRes.gates;

    const cop = scanCops(ctx, sceneOf);
    for (const u of cop.untagged) errors.push(`${u.file}:${u.line}: no '; {n}' tag on '${u.text}' (run npm run extract:lt)`);

    const hc = scanHelperCalls(ctx, sceneOf);
    for (const u of hc.untagged) errors.push(`${u.file}:${u.line}: no '; {n}' tag on '${u.text}' (run npm run extract:lt)`);
    ctx.calls = hc.calls;
    for (const c of ctx.calls) if (!(c.helper in HELPERS)) warnings.push(`${c.file}:${c.line}: helper '${c.helper}' has no index rule`);

    const tables = tableTrace(ctx);
    const { traces, unresolved } = resolveCalls(ctx, tables);
    for (const t of traces) for (const w of t.warnings) warnings.push(`trace ${t.id}: ${w}`);

    // symbol table for $name operands that a file uses without declaring (global fallback)
    const globalSymbols = new Map<string, number>();
    for (const f of files) for (const [k, v] of f.symbols) if (!globalSymbols.has(k)) globalSymbols.set(k, v);
    const direct = scanDirect(ctx, sceneOf, globalSymbols, warnings);

    // sites (join-ready: every row has one integer global index)
    const helperSites: HelperSite[] = [];
    for (const c of ctx.calls) {
        if (c.indices.length !== 1) continue;
        const spec = HELPERS[c.helper];
        const s: HelperSite = {
            offset: c.offset, file: c.file, line: c.line, kind: 'helper_call', opcode: c.helper, operands: c.input !== undefined ? `A=#$${hex(c.input, 4)}` : '',
            index: c.indices[0], width: c.width, role: 'helper call', resolution: c.resolution, trace: c.trace, scenes: c.scenes, sceneSource: c.sceneSource,
        };
        if (spec?.wramBase !== undefined && c.wram.length === 1) s.wram = c.wram[0];
        helperSites.push(s);
    }
    const sites = [...cop.cops, ...ctx.gates, ...helperSites].sort(cmpSite);
    for (const s of sites) if (!Number.isInteger(s.offset)) errors.push(`${s.file}:${s.line}: site without a ROM offset`);
    for (const s of sites) if (s.index < 0 || s.index >= FLAG_COUNT) warnings.push(`${s.file}:${s.line}: index $${hex(s.index, 4)} is outside the flag array (0-${FLAG_COUNT - 1})`);

    for (const w of hc.nonCalls) warnings.push(`${w.file}:${w.line}: non-call reference to flag_helpers: ${w.text}`);
    for (const u of cop.unresolved) warnings.push(`${u.file}:${u.line}: ${u.opcode} operand is not a literal (${u.operands})`);

    const withSites = new Map<string, number>();
    const bump = (file: string, scenes: number[]) => { if (scenes.length === 0) withSites.set(file, (withSites.get(file) ?? 0) + 1); };
    for (const s of [...cop.cops, ...helperSites]) bump(s.file, s.scenes);
    for (const c of ctx.calls) if (c.indices.length !== 1) bump(c.file, c.scenes);
    for (const s of [...cop.items, ...cop.switches]) bump(s.file, s.scenes);
    for (const d of direct) bump(d.file, d.scenes);

    const unresolvedInputs = unresolved.map(c => ({ offset: c.offset, file: c.file, line: c.line, helper: c.helper, reason: 'no table, parameter or constant bounds the index' }));

    const copBy = tally(cop.cops, s => s.opcode);
    const counts = {
        asm_files: files.length,
        tagged_files: tree.taggedFiles,
        cop_sites: cop.cops.length,
        cop_by_opcode: copBy,
        cop_by_width: tally(cop.cops, s => s.width),
        cop_by_role: tally(cop.cops, s => s.role),
        literal_indices: new Set(cop.cops.map(s => s.index)).size,
        scene_gates: ctx.gates.length,
        scene_gate_indices: new Set(ctx.gates.map(g => g.index)).size,
        helper_calls: ctx.calls.length,
        helper_calls_by_helper: tally(ctx.calls, c => c.helper),
        helper_calls_by_resolution: tally(ctx.calls, c => c.resolution),
        helper_calls_in_sites: helperSites.length,
        sites_total: sites.length,
        sites_by_kind: tally(sites, s => s.kind),
        traces: traces.length,
        unresolved_dynamic_inputs: unresolvedInputs.length,
        item_sites: cop.items.length,
        item_by_opcode: tally(cop.items, s => s.opcode),
        switch_case_nonzero_operand: cop.switches.length,
        switch_case_zero_operand: cop.switchZero,
        set_dungeon_kill_flag_cops: cop.dungeonKill,
        direct_accesses: direct.length,
        direct_by_scope: tally(direct, d => d.scope),
        direct_by_region: tally(direct, d => d.region),
        direct_flag_symbol_refs: direct.filter(d => d.flagSymbol).length,
        direct_outside_helpers_and_save: direct.filter(d => d.scope === 'other').length,
        scene_source: tally([...cop.cops, ...ctx.gates, ...cop.items, ...cop.switches, ...direct, ...ctx.calls], s => s.sceneSource),
    };

    const inv: Inventory = {
        schema: INVENTORY_SCHEMA,
        generator: 'npm run flags -- inventory',
        source: { root: 'extracted', asm_files: files.length, tagged_files: tree.taggedFiles, sha256: tree.sha256 },
        roles: ROLES,
        counts,
        sites,
        helper_calls: ctx.calls,
        traces,
        unresolved_dynamic_helper_inputs: unresolvedInputs,
        item_sites: cop.items,
        switch_sites: cop.switches,
        direct_accesses: direct,
        unresolved_cop_sites: cop.unresolved,
        files_without_scenes: [...withSites.entries()].map(([file, n]) => ({ file, sites: n })).sort((a, b) => a.file.localeCompare(b.file)),
        warnings: [...new Set(warnings)].sort(),
    };
    void root;
    return { inv, errors };
}

/** One object per line for the arrays, so a diff of the file reads site by site. */
export function serializeInventory(inv: Inventory): string {
    const parts: string[] = [];
    for (const [key, value] of Object.entries(inv)) {
        if (Array.isArray(value) && value.length > 0 && value.every(v => v !== null && typeof v === 'object')) {
            parts.push(`  ${JSON.stringify(key)}: [\n` + value.map(v => '    ' + JSON.stringify(v)).join(',\n') + '\n  ]');
        } else {
            parts.push(`  ${JSON.stringify(key)}: ` + JSON.stringify(value, null, 2).replace(/\n/g, '\n  '));
        }
    }
    return '{\n' + parts.join(',\n') + '\n}\n';
}

// ------------------------------------------------------------------------------------------------------------
// Markdown summary
// ------------------------------------------------------------------------------------------------------------

function table(head: string[], rows: Array<Array<string | number>>): string {
    return ['| ' + head.join(' | ') + ' |', '|' + head.map(() => '---').join('|') + '|', ...rows.map(r => '| ' + r.join(' | ') + ' |')].join('\n');
}

const hx = (n: number, w = 4) => '`$' + hex(n, w) + '`';

export function renderMarkdown(inv: Inventory): string {
    const c = inv.counts as Record<string, Record<string, number> | number>;
    const num = (k: string) => c[k] as number;
    const rec = (k: string) => c[k] as Record<string, number>;
    const out: string[] = [];
    out.push('# Flag-site inventory (generated)');
    out.push('');
    out.push('> Generated by `npm run flags -- inventory` from the line-tracked extraction. Do not edit: re-run the command. Machine data: [`inventory.json`](inventory.json). Static evidence only, not a write-safety map: a flag absent here is **unobserved**, never "free".');
    out.push('');
    out.push(`Input: ${inv.source.asm_files} \`.asm\` files (${inv.source.tagged_files} with \`; {n}\` tags), SHA-256 \`${inv.source.sha256}\`. Site identity is the decimal ROM offset. Indices are global (byte $0A00 + (n >> 3), bit n & 7); \`wram\` is the wramFlags-relative index (global = relative + $0400).`);
    out.push('');
    out.push('## Counts');
    out.push('');
    out.push(table(['Category', 'Count', 'Where'], [
        ['Flag COP sites ($CC-$D3)', num('cop_sites'), '`sites` (kind `cop`)'],
        ['Distinct literal indices', num('literal_indices'), ''],
        ['Scene-meta `$13` branch gates', num('scene_gates'), `\`sites\` (kind \`scene_gate\`), ${num('scene_gate_indices')} distinct flags`],
        ['Helper calls (`flag_helpers.*`)', num('helper_calls'), '`helper_calls`'],
        ['  of which resolved to exactly one index', num('helper_calls_in_sites'), '`sites` (kind `helper_call`)'],
        ['Dynamic traces', num('traces'), '`traces`'],
        ['Unresolved dynamic helper inputs', num('unresolved_dynamic_inputs'), '`unresolved_dynamic_helper_inputs`'],
        ['Item COP sites ($D4-$D7)', num('item_sites'), '`item_sites`'],
        ['`SwitchCase` with operand other than $0000', num('switch_case_nonzero_operand'), `\`switch_sites\` (${num('switch_case_zero_operand')} sites use $0000)`],
        ['Direct accesses to $0A00-$0BFB', num('direct_accesses'), `\`direct_accesses\` (${num('direct_outside_helpers_and_save')} outside flag_helpers and the save code)`],
        ['  `$eventFlags` / `$wramFlags` symbol references', num('direct_flag_symbol_refs'), ''],
        ['`SetDungeonKillFlag` COPs (not indexed, enemy number)', num('set_dungeon_kill_flag_cops'), 'see trace `dungeon_kill_wram_flags`'],
        ['Join-ready `sites` rows', num('sites_total'), ''],
    ]));
    out.push('');
    out.push('### Flag COPs by opcode');
    out.push('');
    out.push(table(['Opcode', 'Sites'], Object.entries(rec('cop_by_opcode')).map(([k, v]) => [`\`${k}\``, v])));
    out.push('');
    out.push('### Helper calls');
    out.push('');
    out.push(table(['Helper', 'Calls'], Object.entries(rec('helper_calls_by_helper')).map(([k, v]) => [`\`${k}\``, v])));
    out.push('');
    out.push('Resolution: ' + Object.entries(rec('helper_calls_by_resolution')).map(([k, v]) => `${k} ${v}`).join(', ') + '.');
    out.push('');
    out.push('### Item COPs');
    out.push('');
    out.push(table(['Opcode', 'Sites'], Object.entries(rec('item_by_opcode')).map(([k, v]) => [`\`${k}\``, v])));
    out.push('');

    out.push('## Scene-meta branch gates (`$13`)');
    out.push('');
    out.push(table(['ROM offset', 'Record', 'Flag', 'Label', 'Scenes that run it'],
        inv.sites.filter((s): s is GateSite => s.kind === 'scene_gate').map(g => [g.offset, hx(g.record, 2), hx(g.index, 2), '`$' + hex(g.label, 2) + '`', g.scenes.map(s => '$' + hex(s, 2)).join(' ')])));
    out.push('');

    out.push('## Dynamic traces');
    out.push('');
    out.push(table(['Trace', 'Helpers', 'Candidates', 'Calls', 'Range', 'Warnings'],
        inv.traces.map(t => {
            const cs = t.candidate_indices;
            const range = cs.length === 0 ? '' : `${hx(cs[0])}-${hx(cs[cs.length - 1])}`;
            return [`\`${t.id}\``, t.helpers.map(h => `\`${h}\``).join(', '), cs.length, t.call_sites.length, range, t.warnings.length];
        })));
    out.push('');
    out.push('Candidates are possible values bounded by the tables and the spawn rows, not proof that each is reached at runtime. Full candidate lists, evidence rows and the method text of each trace are in `inventory.json` (`traces`).');
    out.push('');
    if (inv.unresolved_dynamic_helper_inputs.length === 0) out.push('Unresolved dynamic helper inputs: none.');
    else {
        out.push('Unresolved dynamic helper inputs:');
        out.push('');
        out.push(table(['ROM offset', 'Helper', 'File', 'Line'], inv.unresolved_dynamic_helper_inputs.map(u => [u.offset, `\`${u.helper}\``, `\`${u.file}\``, u.line])));
    }
    out.push('');

    out.push('## Direct accesses outside flag_helpers and the save code');
    out.push('');
    const other = inv.direct_accesses.filter(d => d.scope === 'other');
    const byAddr = new Map<number, DirectAccess[]>();
    for (const d of other) { if (!byAddr.has(d.address)) byAddr.set(d.address, []); byAddr.get(d.address)!.push(d); }
    out.push(table(['Address', 'Symbol', 'Region', 'Accesses', 'Reads', 'Writes', 'Files'],
        [...byAddr.entries()].sort((a, b) => a[0] - b[0]).map(([addr, rows]) => [
            hx(addr), rows.find(r => r.symbol)?.symbol ? '`' + rows.find(r => r.symbol)!.symbol + '`' : '', rows[0].region, rows.length,
            rows.filter(r => r.access === 'read').length, rows.filter(r => r.access !== 'read').length, new Set(rows.map(r => r.file)).size,
        ])));
    out.push('');
    out.push('Per-access rows (ROM offset, file, line, opcode, access, width) are in `inventory.json` (`direct_accesses`).');
    out.push('');

    out.push('## Files with sites but no scene');
    out.push('');
    out.push('Sites in these files have no scene ids (no actor/thinker placement, no scene directory, no scene prefix in the file name): engine code, tables and shared helpers. The count is the number of site rows.');
    out.push('');
    out.push(table(['File', 'Site rows'], inv.files_without_scenes.map(f => [`\`${f.file}\``, f.sites])));
    out.push('');

    if (inv.warnings.length > 0) {
        out.push('## Warnings');
        out.push('');
        for (const w of inv.warnings) out.push(`- ${w}`);
        out.push('');
    }
    return out.join('\n');
}

// ------------------------------------------------------------------------------------------------------------
// Comparison with the old inventory (tests/iog/iog_flag_usage_inventory.json of the other repo)
// ------------------------------------------------------------------------------------------------------------

interface OldSite { operation?: string; operand?: string; index?: number; source: string; line: number; text?: string; helper?: string; space?: string }
interface Item { key: string; file: string; line: number; text: string; cat: 'cop' | 'helper' | 'direct' }

const stripExt = (p: string) => p.replace(/^extracted\//, '');

function copKey(opcode: string, index: number, operands: string): string {
    const args = parseOperands(operands);
    const sense = /^(BranchOn|WaitOn)/.test(opcode) ? (args[1] ?? '').toUpperCase() : '-';
    return `${opcode}|${index}|${sense}`;
}

function lcsPairs(a: string[], b: string[]): Array<[number, number]> {
    const n = a.length, m = b.length;
    const dp: number[][] = Array.from({ length: n + 1 }, () => new Array<number>(m + 1).fill(0));
    for (let i = n - 1; i >= 0; i--) for (let j = m - 1; j >= 0; j--) dp[i][j] = a[i] === b[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
    const pairs: Array<[number, number]> = [];
    let i = 0, j = 0;
    while (i < n && j < m) {
        if (a[i] === b[j]) { pairs.push([i, j]); i++; j++; } else if (dp[i + 1][j] >= dp[i][j + 1]) i++; else j++;
    }
    return pairs;
}

function multisetOverlap(a: string[], b: string[]): number {
    const m = new Map<string, number>();
    for (const k of a) m.set(k, (m.get(k) ?? 0) + 1);
    let shared = 0;
    for (const k of b) { const n = m.get(k) ?? 0; if (n > 0) { shared++; m.set(k, n - 1); } }
    return shared;
}

export function compareInventories(inv: Inventory, oldPath: string): string {
    const old = JSON.parse(readFileSync(oldPath, 'utf-8')) as {
        source_sha256?: string; cop_site_count: number; helper_call_count: number; direct_symbol_reference_count: number;
        indices: Array<{ sites: OldSite[] }>; helper_sites: OldSite[]; direct_symbol_sites: OldSite[];
        dynamic_helper_traces: Array<{ name: string; candidate_indices: number[]; call_sites: Array<{ source: string; line: number }> }>;
        unresolved_dynamic_helper_inputs: Array<{ helper: string; source: string; line: number }>;
    };
    const oldItems: Item[] = [];
    for (const idx of old.indices) for (const s of idx.sites) oldItems.push({ key: copKey(s.operation ?? '', s.index ?? -1, s.operand ?? ''), file: stripExt(s.source), line: s.line, text: s.text ?? '', cat: 'cop' });
    for (const s of old.helper_sites) oldItems.push({ key: `H|${s.helper}`, file: stripExt(s.source), line: s.line, text: s.text ?? '', cat: 'helper' });
    for (const s of old.direct_symbol_sites) oldItems.push({ key: `D|${s.space}|${(s.text ?? '').replace(/\s+/g, ' ').trim()}`, file: stripExt(s.source), line: s.line, text: s.text ?? '', cat: 'direct' });

    const newItems: Item[] = [];
    for (const s of inv.sites) if (s.kind === 'cop') newItems.push({ key: copKey(s.opcode, s.index, s.operands), file: s.file, line: s.line, text: `COP [${s.opcode}] ( ${s.operands} )`, cat: 'cop' });
    for (const h of inv.helper_calls) newItems.push({ key: `H|${h.helper}`, file: h.file, line: h.line, text: `${h.call} ${h.helper}`, cat: 'helper' });
    for (const d of inv.direct_accesses) {
        if (!d.flagSymbol) continue;
        const space = d.symbol === 'eventFlags' ? 'eventFlags' : 'wramFlags';
        newItems.push({ key: `D|${space}|${d.opcode} $${d.symbol}${d.operands.replace(/^\$\w+/, '')}`.replace(/\s+/g, ' ').trim(), file: d.file, line: d.line, text: `${d.opcode} ${d.operands}`, cat: 'direct' });
    }

    const group = (items: Item[]) => {
        const m = new Map<string, Item[]>();
        for (const it of items) { if (!m.has(it.file)) m.set(it.file, []); m.get(it.file)!.push(it); }
        for (const l of m.values()) l.sort((a, b) => a.line - b.line);
        return m;
    };
    const oldBy = group(oldItems);
    const newBy = group(newItems);

    const lines: string[] = [];
    const catCount = (items: Item[], cat: string) => items.filter(i => i.cat === cat).length;
    lines.push('# FL01 comparison with the old inventory');
    lines.push('');
    lines.push('> Generated by `npm run flags -- inventory --compare=<old> --compare-out=<file>`. Sites are matched by their text (opcode, index, branch sense; helper name) and by neighbours (ordered per file), never by path or line.');
    lines.push('');
    lines.push(table(['Category', 'Old', 'New', 'Delta'], [
        ['Flag COP sites', catCount(oldItems, 'cop'), catCount(newItems, 'cop'), catCount(newItems, 'cop') - catCount(oldItems, 'cop')],
        ['Helper calls', catCount(oldItems, 'helper'), catCount(newItems, 'helper'), catCount(newItems, 'helper') - catCount(oldItems, 'helper')],
        ['`$eventFlags`/`$wramFlags` references', catCount(oldItems, 'direct'), catCount(newItems, 'direct'), catCount(newItems, 'direct') - catCount(oldItems, 'direct')],
    ]));
    lines.push('');

    // 1. same-path files
    const matchedNew = new Set<string>();
    const pairs: Array<{ oldFile: string; newFile: string; how: string; score: number }> = [];
    for (const f of oldBy.keys()) if (newBy.has(f)) { pairs.push({ oldFile: f, newFile: f, how: 'same path', score: 1 }); matchedNew.add(f); }
    // 2. old files that vanished -> best remaining new file by overlapping sequence
    const lostFiles = [...oldBy.keys()].filter(f => !newBy.has(f)).sort();
    const freeNew = [...newBy.keys()].filter(f => !matchedNew.has(f) && !oldBy.has(f)).sort();
    const cand: Array<{ o: string; n: string; shared: number; score: number }> = [];
    for (const o of lostFiles) for (const n of freeNew) {
        const a = oldBy.get(o)!.map(i => i.key), b = newBy.get(n)!.map(i => i.key);
        const shared = multisetOverlap(a, b);
        if (shared > 0) cand.push({ o, n, shared, score: shared / Math.max(a.length, b.length) });
    }
    cand.sort((x, y) => y.score - x.score || y.shared - x.shared || x.o.localeCompare(y.o) || x.n.localeCompare(y.n));
    const usedOld = new Set<string>(), usedNew = new Set<string>();
    for (const c of cand) {
        if (usedOld.has(c.o) || usedNew.has(c.n) || c.score < 0.5) continue;
        usedOld.add(c.o); usedNew.add(c.n);
        pairs.push({ oldFile: c.o, newFile: c.n, how: 'renamed', score: c.score });
    }

    interface Diff { file: string; lost: Item[]; gained: Item[]; same: number }
    const diffs: Diff[] = [];
    let identical = 0;
    for (const p of pairs.sort((a, b) => a.newFile.localeCompare(b.newFile))) {
        const a = oldBy.get(p.oldFile)!, b = newBy.get(p.newFile)!;
        const m = lcsPairs(a.map(i => i.key), b.map(i => i.key));
        const lostIdx = new Set(a.map((_, i) => i)), gainIdx = new Set(b.map((_, i) => i));
        for (const [i, j] of m) { lostIdx.delete(i); gainIdx.delete(j); }
        identical += m.length;
        diffs.push({ file: p.newFile, lost: [...lostIdx].map(i => a[i]), gained: [...gainIdx].map(j => b[j]), same: m.length });
    }
    // 3. leftovers: whole files lost or gained, then cross-file moves by key
    const leftoverOld: Item[] = [], leftoverNew: Item[] = [];
    for (const f of lostFiles) if (!usedOld.has(f)) leftoverOld.push(...oldBy.get(f)!);
    for (const f of newBy.keys()) if (!matchedNew.has(f) && !usedNew.has(f)) leftoverNew.push(...newBy.get(f)!);
    for (const d of diffs) { leftoverOld.push(...d.lost); leftoverNew.push(...d.gained); }
    const gainedPool = new Map<string, Item[]>();
    for (const g of leftoverNew) { if (!gainedPool.has(g.key)) gainedPool.set(g.key, []); gainedPool.get(g.key)!.push(g); }
    const moved: Array<{ from: Item; to: Item }> = [];
    const trulyLost: Item[] = [];
    for (const l of leftoverOld) {
        const pool = gainedPool.get(l.key);
        if (pool && pool.length > 0) moved.push({ from: l, to: pool.shift()! }); else trulyLost.push(l);
    }
    const trulyGained = [...gainedPool.values()].flat();

    lines.push('## Result');
    lines.push('');
    lines.push(table(['Outcome', 'Sites'], [
        ['Unchanged (same text, same neighbours; path may differ)', identical],
        ['Moved between files (same text, different neighbours)', moved.length],
        ['Lost (in the old inventory only)', trulyLost.length],
        ['Gained (in the new inventory only)', trulyGained.length],
    ]));
    lines.push('');
    lines.push('## Files of the old inventory that are not in the current tree');
    lines.push('');
    const rows: Array<Array<string | number>> = [];
    for (const f of lostFiles) {
        const p = pairs.find(x => x.oldFile === f);
        const n = oldBy.get(f)!.length;
        rows.push([`\`${f}\``, n, p ? `\`${p.newFile}\` (${Math.round(p.score * 100)}% of the sequence)` : 'not found: sites reported as lost or moved below']);
    }
    lines.push(rows.length === 0 ? 'None.' : table(['Old file', 'Sites', 'Current file'], rows));
    lines.push('');
    lines.push('## Files whose sites changed');
    lines.push('');
    const changed = diffs.filter(d => d.lost.length > 0 || d.gained.length > 0);
    if (changed.length === 0) lines.push('None.');
    else {
        lines.push(table(['File', 'Unchanged', 'Lost here', 'Gained here'], changed.map(d => [`\`${d.file}\``, d.same, d.lost.length, d.gained.length])));
    }
    lines.push('');
    if (moved.length > 0) {
        lines.push('## Moved sites');
        lines.push('');
        lines.push(table(['Old file:line', 'Current file:line', 'Text'], moved.map(m => [`\`${m.from.file}:${m.from.line}\``, `\`${m.to.file}:${m.to.line}\``, '`' + m.to.text.replace(/\|/g, '\\|') + '`'])));
        lines.push('');
    }
    if (trulyLost.length > 0) {
        lines.push('## Lost sites');
        lines.push('');
        lines.push(table(['Old file:line', 'Text'], trulyLost.map(m => [`\`${m.file}:${m.line}\``, '`' + m.text.replace(/\|/g, '\\|') + '`'])));
        lines.push('');
    }
    if (trulyGained.length > 0) {
        lines.push('## Gained sites');
        lines.push('');
        lines.push(table(['File:line', 'Text'], trulyGained.map(m => [`\`${m.file}:${m.line}\``, '`' + m.text.replace(/\|/g, '\\|') + '`'])));
        lines.push('');
    }

    lines.push('## Dynamic traces');
    lines.push('');
    const trows: Array<Array<string | number>> = [];
    for (const ot of old.dynamic_helper_traces) {
        const nt = inv.traces.find(t => t.id === ot.name) ?? inv.traces.find(t => t.previousId === ot.name);
        if (!nt) { trows.push([`\`${ot.name}\``, ot.candidate_indices.length, '-', 'missing in the new inventory', '']); continue; }
        const oldSet = new Set(ot.candidate_indices);
        const globalSet = new Set(nt.candidate_indices);
        const wramSet = new Set(nt.wram_indices ?? []);
        const useWram = [...oldSet].every(i => wramSet.has(i)) && wramSet.size > 0 && !(oldSet.size === globalSet.size && [...oldSet].every(i => globalSet.has(i)));
        const newSet = useWram ? wramSet : globalSet;
        const added = [...newSet].filter(i => !oldSet.has(i)).sort((a, b) => a - b);
        const removed = [...oldSet].filter(i => !newSet.has(i)).sort((a, b) => a - b);
        const verdict = added.length === 0 && removed.length === 0 ? 'identical' : 'differs';
        trows.push([
            `\`${nt.id}\`${nt.id !== ot.name ? ` (was \`${ot.name}\`)` : ''}`, ot.candidate_indices.length, newSet.size, verdict + (useWram ? ' (wram-relative)' : ''),
            [added.length ? `+${added.map(i => '$' + hex(i, 4)).join(' ')}` : '', removed.length ? `-${removed.map(i => '$' + hex(i, 4)).join(' ')}` : ''].filter(Boolean).join(' '),
        ]);
    }
    lines.push(table(['Trace', 'Old candidates', 'New candidates', 'Verdict', 'Difference'], trows));
    lines.push('');
    lines.push(`New traces without an old counterpart: ${inv.traces.filter(t => !old.dynamic_helper_traces.some(o => o.name === t.id || o.name === t.previousId)).map(t => '`' + t.id + '`').join(', ') || 'none'}.`);
    lines.push('');
    lines.push(`Old unresolved dynamic helper inputs: ${old.unresolved_dynamic_helper_inputs.length} (${old.unresolved_dynamic_helper_inputs.map(u => `\`${u.helper}\` at \`${stripExt(u.source)}:${u.line}\``).join(', ')}). New: ${inv.unresolved_dynamic_helper_inputs.length}.`);
    lines.push('');
    return lines.join('\n');
}

// ------------------------------------------------------------------------------------------------------------
// Command
// ------------------------------------------------------------------------------------------------------------

function writeIfChanged(path: string, text: string): 'new' | 'changed' | 'same' {
    const exists = existsSync(path);
    if (exists && lf(readFileSync(path, 'utf-8')) === text) return 'same';
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, text, 'utf-8');
    return exists ? 'changed' : 'new';
}

export function runInventory(root: string, options: InventoryOptions = {}): boolean {
    const extracted = options.extracted ? resolve(options.extracted) : join(root, 'extracted');
    const dbDir = options.dbDir ? resolve(options.dbDir) : join(root, 'db-us');
    const out = options.out ? resolve(options.out) : join(root, 'plans', 'flags', 'inventory.json');
    const md = options.md ? resolve(options.md) : join(dirname(out), 'inventory.md');
    if (!existsSync(extracted)) { console.error(`extracted folder not found: ${extracted}`); return false; }

    const { inv, errors } = buildInventory(root, extracted, dbDir);
    if (errors.length > 0) {
        console.error(`Inventory not written: ${errors.length} problem(s).`);
        for (const e of errors.slice(0, 20)) console.error('  ' + e);
        if (errors.length > 20) console.error(`  ... and ${errors.length - 20} more`);
        if (inv.source.tagged_files === 0) console.error('The extracted tree has no "; {n}" line-tracking tags. Run: npm run extract:lt (and npm run extract again when finished).');
        return false;
    }
    if (inv.source.tagged_files === 0 || inv.counts.cop_sites === 0) {
        console.error('The extracted tree has no flag sites or no "; {n}" tags. Run: npm run extract:lt (and npm run extract again when finished).');
        return false;
    }

    const json = serializeInventory(inv);
    const mdText = renderMarkdown(inv) + '\n';
    const c = inv.counts;
    console.log(`Source: ${inv.source.asm_files} asm files (${inv.source.tagged_files} tagged)`);
    console.log(`Flag COP sites: ${c.cop_sites} (${c.literal_indices} literal indices); scene gates: ${c.scene_gates}; helper calls: ${c.helper_calls} (${c.helper_calls_in_sites} single-index); traces: ${c.traces}; unresolved: ${c.unresolved_dynamic_inputs}`);
    console.log(`Item COPs: ${c.item_sites}; SwitchCase non-zero: ${c.switch_case_nonzero_operand}; direct accesses: ${c.direct_accesses} (${c.direct_outside_helpers_and_save} outside helpers/save, ${c.direct_flag_symbol_refs} flag-symbol refs)`);
    console.log(`Join-ready sites: ${c.sites_total}; warnings: ${inv.warnings.length}`);

    if (options.dryRun) {
        const state = (p: string, t: string) => (!existsSync(p) ? 'would be created' : lf(readFileSync(p, 'utf-8')) === t ? 'unchanged' : 'would change');
        console.log(`[dry-run] ${out}: ${state(out, json)}`);
        console.log(`[dry-run] ${md}: ${state(md, mdText)}`);
    } else {
        console.log(`${out}: ${writeIfChanged(out, json)}`);
        console.log(`${md}: ${writeIfChanged(md, mdText)}`);
    }

    if (options.compare) {
        const text = compareInventories(inv, resolve(options.compare)) + '\n';
        if (options.compareOut && !options.dryRun) console.log(`${resolve(options.compareOut)}: ${writeIfChanged(resolve(options.compareOut), text)}`);
        else console.log(text);
    }
    return true;
}
