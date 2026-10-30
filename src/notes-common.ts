/**
 * Shared helpers for the two supported note/name tools:
 *
 *   npm run merge -- <spec.json>   notes and comments   (src/merge.ts)
 *   npm run names -- <spec.json>   names                (src/names-merge.ts)
 *
 * Bank detection, JSON file handling, note normalisation and extracted-file lookup.
 * There is no `ingest` or `annotate` command: they were removed because they read the
 * extracted .asm back into notes/ and overwrite notes when extracted/ is stale.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from 'fs';
import { join, dirname, resolve, relative, isAbsolute } from 'path';

export type NoteValue = string | string[] | null;
export type CommentValue = string | null | { text: string | null; expect?: string; expectOld?: string };

export interface FileEdit {
    blockNote?: NoteValue;
    partNotes?: Record<string, NoteValue>;
    comments?: Record<string, CommentValue>;
}

/** Top-level label: "Name {", "Name [", or data parts ("Name #hex", "Name `string", "Name ~string", "Name |string"). */
export const TOP_LABEL = /^(\w+)\s+[\[{#`~|]/;
/** Internal (sub) label: "  Label:". */
export const SUB_LABEL = /^\s{2}(\w+):$/;
/** Address tag emitted by `extract:lt`: "; {39414}". */
export const TAG = /;\s*\{(\d+)\}/;

/**
 * Build a name -> bank lookup from the per-bank names files
 * (db-us/names/bankNN.json) for bank detection fallback.
 */
export function loadNamesBankLookup(namesDir: string): Map<string, number> {
    const lookup = new Map<string, number>();
    if (!existsSync(namesDir)) return lookup;
    for (const file of readdirSync(namesDir)) {
        if (!file.endsWith('.json')) continue;
        try {
            const names: Record<string, string> = JSON.parse(readFileSync(join(namesDir, file), 'utf-8'));
            for (const [addr, name] of Object.entries(names)) {
                const address = parseInt(addr, 10);
                if (!isNaN(address)) {
                    lookup.set(name, Math.floor(address / 65536));
                }
            }
        } catch { /* ignore parse errors */ }
    }
    return lookup;
}

/**
 * Build a block/file name -> ROM bank lookup from db-us/blocks.json and db-us/files.json.
 *
 * blocks.json is group -> block -> { start, end, type } or { parts: { part: { start, ... } } };
 * files.json is group -> scene -> file -> { start, end, type } (sprite maps, tilemaps, ...).
 * The bank is floor(start / 65536) of the block (lowest part start when the block only has parts).
 * It does not depend on the `?BANK` directive: the extractor only writes `?BANK` for blocks
 * that are not `movable`, but every block has a start address in the database.
 */
export function loadDbBankLookup(dbDir: string): Map<string, number> {
    const lookup = new Map<string, number>();
    const add = (name: string, entry: any) => {
        if (!entry || typeof entry !== 'object') return;
        let start: number | undefined = typeof entry.start === 'number' ? entry.start : undefined;
        if (start === undefined && entry.parts && typeof entry.parts === 'object') {
            const starts = Object.values<any>(entry.parts)
                .map(p => p?.start)
                .filter((v): v is number => typeof v === 'number');
            if (starts.length > 0) start = Math.min(...starts);
        }
        if (start !== undefined && !lookup.has(name)) lookup.set(name, Math.floor(start / 65536));
    };
    const blocksPath = join(dbDir, 'blocks.json');
    if (existsSync(blocksPath)) {
        try {
            const groups = JSON.parse(readFileSync(blocksPath, 'utf-8'));
            for (const group of Object.values<any>(groups))
                for (const [name, entry] of Object.entries<any>(group)) add(name, entry);
        } catch { /* ignore parse errors */ }
    }
    const filesPath = join(dbDir, 'files.json');
    if (existsSync(filesPath)) {
        try {
            const groups = JSON.parse(readFileSync(filesPath, 'utf-8'));
            for (const group of Object.values<any>(groups))
                for (const scene of Object.values<any>(group))
                    for (const [name, entry] of Object.entries<any>(scene)) add(name, entry);
        } catch { /* ignore parse errors */ }
    }
    return lookup;
}

/**
 * Detect the ROM bank for a file using multiple strategies.
 *
 * `dbLookup` (from loadDbBankLookup) makes the block's location in blocks.json / files.json the
 * second strategy; without it the later strategies are the only fallback.
 */
export function detectBank(
    lines: string[],
    fileName: string,
    namesLookup: Map<string, number>,
    dbLookup?: Map<string, number>,
): number | null {
    // Strategy 1: ?BANK directive (optional)
    for (const line of lines) {
        const match = line.match(/^\?BANK\s+([0-9A-Fa-f]+)/);
        if (match) return parseInt(match[1], 16);
    }

    // Strategy 2: the block's start address in db-us/blocks.json or db-us/files.json
    // (file name = block name; sprite maps are `<name>.sprite.asm`)
    if (dbLookup) {
        const key = fileName.replace(/\.sprite$/, '');
        const bank = dbLookup.get(fileName) ?? dbLookup.get(key);
        if (bank !== undefined) return bank;
    }

    // Strategy 3: code_XXXXXX or loc_XXXXXX labels (hex address in label name)
    for (const line of lines) {
        const match = line.match(/\b(?:code|loc)_([0-9A-Fa-f]{6})\b/);
        if (match) {
            const addr = parseInt(match[1], 16);
            return Math.floor(addr / 0x10000);
        }
    }

    // Strategy 4: {address} tags from extract:lt
    for (const line of lines) {
        const match = line.match(/;\s*\{(\d+)\}/);
        if (match) {
            return Math.floor(parseInt(match[1], 10) / 65536);
        }
    }

    // Strategy 5: File name in db-us/names/
    if (namesLookup.has(fileName)) {
        return namesLookup.get(fileName)!;
    }

    // Strategy 6: First top-level label found in db-us/names/
    for (const line of lines) {
        const match = line.match(/^(\w+)\s+[\[{]/);
        if (match && namesLookup.has(match[1])) {
            return namesLookup.get(match[1])!;
        }
    }

    return null;
}

/** Bank file name from a bank number: "bank00.json", "bank0C.json", etc. */
export function bankFileName(bank: number): string {
    return `bank${bank.toString(16).toUpperCase().padStart(2, '0')}.json`;
}

/** Load a JSON file as a string -> string record (missing or unparsable file gives {}). */
export function loadJsonFile(filePath: string): Record<string, string> {
    if (!existsSync(filePath)) return {};
    try {
        return JSON.parse(readFileSync(filePath, 'utf-8'));
    } catch {
        return {};
    }
}

/**
 * Format a string -> string record as the JSON text used by notes/ and db-us/names/:
 * numeric keys are sorted numerically, string keys alphabetically; 4-space indent, trailing newline.
 */
export function serializeJson(data: Record<string, string>): string {
    const keys = Object.keys(data);
    const allNumeric = keys.every(k => /^\d+$/.test(k));

    if (allNumeric) {
        keys.sort((a, b) => parseInt(a, 10) - parseInt(b, 10));
    } else {
        keys.sort((a, b) => a.localeCompare(b));
    }

    const sorted: Record<string, string> = {};
    for (const key of keys) {
        sorted[key] = data[key];
    }

    return JSON.stringify(sorted, null, 4) + '\n';
}

/** Save a string -> string record as formatted JSON (see serializeJson). Returns false when unchanged. */
export function saveJsonFile(filePath: string, data: Record<string, string>): boolean {
    const dir = dirname(filePath);
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });

    const newContent = serializeJson(data);

    // Avoid rewriting unchanged files (prevents spurious git diffs)
    if (existsSync(filePath)) {
        const existingContent = readFileSync(filePath, 'utf-8');
        if (newContent === existingContent) return false;
    }

    writeFileSync(filePath, newContent, 'utf-8');
    return true;
}

/** Normalise a note value to its stored form (what is written to notes/*.json). */
export function normalizeNote(value: string | string[]): string {
    const text = Array.isArray(value) ? value.join('\n') : value;
    const lines = text.replace(/\r\n/g, '\n').split('\n').map(l => l.trimEnd());
    while (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
    while (lines.length > 0 && lines[0] === '') lines.shift();
    return lines.join('\n');
}

export function noteIsEmpty(value: NoteValue | undefined): boolean {
    if (value === null || value === undefined) return true;
    return normalizeNote(value) === '';
}

/** Regexes from db-us/transforms.json (a comment edit's `expect` text is matched against transformed output). */
export function loadTransformPatterns(projectRoot: string): RegExp[] {
    const p = join(projectRoot, 'db-us', 'transforms.json');
    if (!existsSync(p)) return [];
    const out: RegExp[] = [];
    try {
        const json = JSON.parse(readFileSync(p, 'utf-8')) as Record<string, { key: string }[]>;
        for (const rules of Object.values(json)) {
            for (const r of rules) {
                try { out.push(new RegExp(r.key, 'g')); } catch { /* skip invalid */ }
            }
        }
    } catch { /* ignore */ }
    return out;
}

/** Resolve a merge-spec file key to an absolute path under extracted/ (null if outside or not .asm). */
export function resolveAsmPath(projectRoot: string, key: string): string | null {
    const extracted = join(projectRoot, 'extracted');
    let p = isAbsolute(key) ? key : resolve(extracted, key.replace(/^extracted[\\/]/, ''));
    p = resolve(p);
    const rel = relative(extracted, p);
    if (rel.startsWith('..') || isAbsolute(rel) || !p.endsWith('.asm')) return null;
    return p;
}
