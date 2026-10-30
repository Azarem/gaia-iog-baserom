/**
 * Exports for external tools (Mesen2 MCP server, Lua kit).
 *
 *   npm run export -- labels [--out-dir=<dir>]
 *   npm run export -- scenes [--out=<file>]
 *
 * Documented in `docs/mesen2-exports.md`.
 */
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join, resolve } from 'path';

function readJson<T>(path: string): T {
    return JSON.parse(readFileSync(path, 'utf-8')) as T;
}

function ensureDirFor(file: string) {
    mkdirSync(dirname(file), { recursive: true });
}

/** Mesen2 label names: letters, digits and `_`. Anything else is replaced; a leading digit gets a `_` prefix. */
function sanitizeLabel(name: string): string {
    let text = name.replace(/[^A-Za-z0-9_]/g, '_');
    if (/^[0-9]/.test(text)) text = '_' + text;
    return text;
}

function hex(value: number, width = 6): string {
    return value.toString(16).toUpperCase().padStart(width, '0');
}

export interface ExportLabelsOptions {
    /** Output folder (default `artifacts/labels`). */
    outDir?: string;
    /** `db-us/names` folder (default: inside the package root). */
    namesDir?: string;
    /** `artifacts/master-lookup.json` (default: inside the package root). */
    masterLookupPath?: string;
}

export interface ExportLabelsResult {
    originalPath: string;
    rebuiltPath: string;
    names: number;
    original: number;
    rebuilt: number;
    /** Names without an entry in master-lookup.json (not written to the rebuilt file). */
    unresolvedInRebuilt: string[];
    renamedForMesen: number;
}

/**
 * Writes two Mesen2 `.mlb` files from `db-us/names/bankNN.json` (decimal ROM offset -> name):
 *   - `iog-original.mlb`: each name at its own offset (the offsets of the original ROM);
 *   - `iog-rebuilt.mlb`: each name at the offset the last `npm run rebuild --artifacts` gave it
 *     (`artifacts/master-lookup.json`: upper-cased name -> hex offset).
 * Lines are `SnesPrgRom:<hex offset>:<label>`.
 */
export function exportLabels(pkgRoot: string, options: ExportLabelsOptions = {}): ExportLabelsResult {
    const namesDir = options.namesDir ?? join(pkgRoot, 'db-us', 'names');
    const lookupPath = options.masterLookupPath ?? join(pkgRoot, 'artifacts', 'master-lookup.json');
    const outDir = resolve(pkgRoot, options.outDir ?? join('artifacts', 'labels'));

    if (!existsSync(namesDir)) throw new Error(`names folder not found: ${namesDir}`);
    if (!existsSync(lookupPath)) throw new Error(`master lookup not found: ${lookupPath} (run: npm run rebuild)`);

    const entries: Array<{ offset: number; name: string }> = [];
    for (const file of readdirSync(namesDir).filter(f => /^bank[0-9A-Fa-f]{2}\.json$/.test(f)).sort()) {
        const bank = readJson<Record<string, string>>(join(namesDir, file));
        for (const [key, name] of Object.entries(bank)) {
            const offset = Number(key);
            if (!Number.isInteger(offset) || offset < 0) throw new Error(`${file}: bad offset key '${key}'`);
            entries.push({ offset, name });
        }
    }
    entries.sort((a, b) => a.offset - b.offset || a.name.localeCompare(b.name));

    const lookup = readJson<Record<string, string>>(lookupPath);
    const lookupUpper = new Map<string, number>();
    for (const [name, location] of Object.entries(lookup)) {
        lookupUpper.set(name.toUpperCase(), parseInt(location, 16));
    }

    let renamed = 0;
    const originalLines: string[] = [];
    const rebuiltRows: Array<{ offset: number; label: string }> = [];
    const unresolved: string[] = [];

    for (const entry of entries) {
        const label = sanitizeLabel(entry.name);
        if (label !== entry.name) renamed++;
        originalLines.push(`SnesPrgRom:${hex(entry.offset)}:${label}`);

        const rebuiltOffset = lookupUpper.get(entry.name.toUpperCase());
        if (rebuiltOffset === undefined || Number.isNaN(rebuiltOffset)) {
            unresolved.push(entry.name);
        } else {
            rebuiltRows.push({ offset: rebuiltOffset, label });
        }
    }
    rebuiltRows.sort((a, b) => a.offset - b.offset || a.label.localeCompare(b.label));
    const rebuiltLines = rebuiltRows.map(row => `SnesPrgRom:${hex(row.offset)}:${row.label}`);

    const originalPath = join(outDir, 'iog-original.mlb');
    const rebuiltPath = join(outDir, 'iog-rebuilt.mlb');
    ensureDirFor(originalPath);
    writeFileSync(originalPath, originalLines.join('\n') + '\n', 'utf-8');
    writeFileSync(rebuiltPath, rebuiltLines.join('\n') + '\n', 'utf-8');

    return {
        originalPath, rebuiltPath,
        names: entries.length,
        original: originalLines.length,
        rebuilt: rebuiltLines.length,
        unresolvedInRebuilt: unresolved,
        renamedForMesen: renamed,
    };
}

export interface ExportScenesOptions {
    /** Output file (default `artifacts/scenes.json`). */
    out?: string;
}

interface GroupsFile {
    [group: string]: { prefix?: string; scenes?: Record<string, { id: number; description?: string }> };
}

interface SceneFlagsFile {
    [sceneId: string]: { flags: number[]; note?: string; source?: string };
}

export interface ExportScenesResult {
    path: string;
    sceneCount: number;
    withFlags: number;
    duplicateIds: number[];
}

/**
 * Writes one JSON file with every scene id of `db-us/groups.json` (id, key, group, prefix, description) and,
 * where known, the event flags a scene needs (`db-us/scene-flags.json`: `{ "<id>": { "flags": [n, ...], "note", "source" } }`).
 * Event flag `#n` lives in WRAM byte `0x0A00 + (n >> 3)`, bit `n & 7`.
 */
export function exportScenes(pkgRoot: string, options: ExportScenesOptions = {}): ExportScenesResult {
    const groups = readJson<GroupsFile>(join(pkgRoot, 'db-us', 'groups.json'));
    const flagsPath = join(pkgRoot, 'db-us', 'scene-flags.json');
    const flagsFile: SceneFlagsFile = existsSync(flagsPath) ? readJson<SceneFlagsFile>(flagsPath) : {};

    const scenes: Array<Record<string, unknown>> = [];
    const seen = new Map<number, number>();
    const duplicates = new Set<number>();

    for (const [group, groupDef] of Object.entries(groups)) {
        for (const [key, scene] of Object.entries(groupDef.scenes ?? {})) {
            const id = scene.id;
            seen.set(id, (seen.get(id) ?? 0) + 1);
            if (seen.get(id)! > 1) duplicates.add(id);
            const requirement = flagsFile[String(id)];
            const row: Record<string, unknown> = {
                id,
                idHex: '$' + hex(id, 2),
                key,
                group,
                prefix: groupDef.prefix ?? null,
                description: scene.description ?? null,
                requiredFlags: requirement?.flags ?? [],
            };
            if (requirement) {
                row.requiredFlagBytes = requirement.flags.map(n => ({ flag: n, address: 0x0A00 + (n >> 3), mask: 1 << (n & 7) }));
                if (requirement.note) row.flagNote = requirement.note;
                if (requirement.source) row.flagSource = requirement.source;
            }
            scenes.push(row);
        }
    }
    scenes.sort((a, b) => (a.id as number) - (b.id as number));

    const ids = scenes.map(s => s.id as number);
    const idSet = new Set(ids);
    const missing: number[] = [];
    for (let id = 0; id <= 255; id++) if (!idSet.has(id)) missing.push(id);

    for (const key of Object.keys(flagsFile)) {
        if (!idSet.has(Number(key))) throw new Error(`db-us/scene-flags.json: scene id ${key} is not in db-us/groups.json`);
    }

    const output = {
        game: 'Illusion of Gaia (US)',
        source: 'db-us/groups.json, db-us/scene-flags.json',
        sceneIdAddress: '0x0642 (sceneNext, word); sceneCurrent is 0x0644',
        eventFlagConvention: 'flag #n = WRAM byte 0x0A00 + (n >> 3), bit (n & 7)',
        count: scenes.length,
        ids,
        idsWithoutScene: missing,
        scenes,
    };

    const path = resolve(pkgRoot, options.out ?? join('artifacts', 'scenes.json'));
    ensureDirFor(path);
    //Keep the two id lists on one line each.
    const text = JSON.stringify(output, null, 2).replace(/\[\s*(\d[\d,\s]*)\]/g, (_match, body: string) => '[' + body.replace(/\s+/g, ' ').trim() + ']');
    writeFileSync(path, text + '\n', 'utf-8');

    return {
        path,
        sceneCount: scenes.length,
        withFlags: scenes.filter(s => (s.requiredFlags as number[]).length > 0).length,
        duplicateIds: [...duplicates],
    };
}
