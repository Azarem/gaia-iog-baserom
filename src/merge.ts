/**
 * Notes Merge
 *
 * Applies a JSON edit spec straight to the `notes/` JSON files: block notes,
 * part notes and inline comments can each be set, replaced or removed. It
 * replaces the annotate -> ingest round-trip (edit the .asm, parse it back into
 * JSON): the spec already says what to write and where, so the .asm is never
 * touched.
 *
 * The extracted .asm is only READ, to validate the spec before anything is
 * written: every label must exist exactly once, every comment address must
 * exist (and match an optional "expect" guard), every file must exist. One bad
 * entry aborts the whole run with nothing written.
 *
 * Workflow:
 *   1. `npm run extract:lt`                      (labels + address tags to validate against)
 *   2. Write an edit spec (JSON), e.g. plans/extracted-audit/edits/I021.json
 *   3. `npm run merge -- <spec.json> [--dry-run]`  validate, write notes/*.json, verify
 *   4. `npm run extract:lt`                      the extractor re-reads notes/ -> check the output
 *
 * Spec format: identical to `annotate` (paths relative to extracted/):
 *   {
 *     "system/engine/smooth_follow.asm": {
 *       "blockNote": "text, \n separates lines"  | ["line", "line"] | null,
 *       "partNotes": { "LabelName": "text" | [lines] | null },
 *       "comments":  {
 *         "59011": "inline comment",
 *         "59015": { "text": "comment", "expect": "LDA $0A" },
 *         "59020": null
 *       }
 *     }
 *   }
 *
 * Where each entry lands (same keys and banks as ingest, so the JSON is identical):
 *   - block note  -> notes/blockNotes/bankNN.json, key = file name without .asm
 *   - part note   -> notes/partNotes/bankNN.json,  key = label (bank = the file's bank, or the
 *                    bank that already holds that label, so a note is never duplicated)
 *   - comment     -> notes/comments/bankNN.json,   key = decimal address (bank = address / 65536)
 *
 * Because the .asm is not edited, `extracted/` is stale until the next extract. Never run
 * `npm run ingest` on it in between: ingest would read the old text back over the new notes.
 */

import { readFileSync, existsSync, readdirSync } from 'fs';
import { join, resolve, relative, sep } from 'path';
import { detectBank, loadNamesBankLookup, loadJsonFile, saveJsonFile, bankFileName } from './ingest.ts';
import {
    TOP_LABEL, SUB_LABEL, TAG, normalizeNote, noteIsEmpty, loadTransformPatterns, resolveAsmPath,
    type NoteValue, type CommentValue, type FileEdit,
} from './annotate.ts';

export interface MergeOptions {
    dryRun?: boolean;
}

export interface MergeResult {
    ok: boolean;
    errors: string[];
    warnings: string[];
    notesFilesChanged: string[];
}

type Kind = 'blockNotes' | 'partNotes' | 'comments';
const KINDS: Kind[] = ['blockNotes', 'partNotes', 'comments'];

interface Counts { set: number; updated: number; removed: number; unchanged: number }
const newCounts = (): Counts => ({ set: 0, updated: 0, removed: 0, unchanged: 0 });

/** In-memory copy of every notes/<kind>/bankNN.json, with a key -> bank index. */
class NoteStore {
    banks = new Map<number, Record<string, string>>();
    original = new Map<number, Record<string, string>>();
    index = new Map<string, number>();
    dir: string;

    constructor(dir: string) {
        this.dir = dir;
        if (!existsSync(dir)) return;
        for (const f of readdirSync(dir)) {
            const m = f.match(/^bank([0-9A-Fa-f]{2})\.json$/);
            if (!m) continue;
            const bank = parseInt(m[1], 16);
            const data = loadJsonFile(join(dir, f));
            this.banks.set(bank, data);
            this.original.set(bank, { ...data });
            for (const k of Object.keys(data)) if (!this.index.has(k)) this.index.set(k, bank);
        }
    }

    get(key: string): string | undefined {
        const bank = this.index.get(key);
        return bank === undefined ? undefined : this.banks.get(bank)![key];
    }

    bankOf(key: string): number | undefined {
        return this.index.get(key);
    }

    set(key: string, bank: number, value: string) {
        if (!this.banks.has(bank)) { this.banks.set(bank, {}); this.original.set(bank, {}); }
        this.banks.get(bank)![key] = value;
        this.index.set(key, bank);
    }

    remove(key: string) {
        const bank = this.index.get(key);
        if (bank === undefined) return;
        delete this.banks.get(bank)![key];
        this.index.delete(key);
    }

    /** Banks whose content differs from what was loaded. */
    dirtyBanks(): number[] {
        const out: number[] = [];
        for (const [bank, data] of this.banks) {
            const orig = this.original.get(bank)!;
            const a = Object.keys(data), b = Object.keys(orig);
            if (a.length !== b.length || a.some(k => data[k] !== orig[k])) out.push(bank);
        }
        return out.sort((x, y) => x - y);
    }

    pathFor(bank: number): string {
        return join(this.dir, bankFileName(bank));
    }
}

function suggest(names: string[], wanted: string): string {
    const w = wanted.toLowerCase();
    const hits = names.filter(n => n.toLowerCase().includes(w) || w.includes(n.toLowerCase())).slice(0, 5);
    return hits.length > 0 ? ` Did you mean: ${hits.join(', ')}?` : '';
}

/** Labels (top-level parts and indented sub-labels) in an extracted file, with their line numbers. */
function collectLabels(lines: string[]): Map<string, number[]> {
    const labels = new Map<string, number[]>();
    lines.forEach((line, i) => {
        if (/^[?!]/.test(line)) return;
        const m = line.match(TOP_LABEL) || line.match(SUB_LABEL);
        if (!m) return;
        if (!labels.has(m[1])) labels.set(m[1], []);
        labels.get(m[1])!.push(i + 1);
    });
    return labels;
}

/** Address tag -> source lines (extract:lt output). */
function collectTags(lines: string[]): Map<string, number[]> {
    const tags = new Map<string, number[]>();
    lines.forEach((line, i) => {
        const m = line.match(TAG);
        if (!m) return;
        if (!tags.has(m[1])) tags.set(m[1], []);
        tags.get(m[1])!.push(i);
    });
    return tags;
}

function tally(c: Counts, existed: boolean, changed: boolean, removing: boolean) {
    if (removing) { if (existed) c.removed++; else c.unchanged++; return; }
    if (!changed) c.unchanged++;
    else if (existed) c.updated++;
    else c.set++;
}

function fmt(c: Counts): string {
    return `+${c.set} ~${c.updated} -${c.removed} =${c.unchanged}`;
}

export function merge(projectRoot: string, specPath: string, options: MergeOptions = {}): MergeResult {
    const result: MergeResult = { ok: false, errors: [], warnings: [], notesFilesChanged: [] };

    const specAbs = resolve(specPath);
    if (!existsSync(specAbs)) {
        result.errors.push(`spec file not found: ${specPath}`);
        return report(result);
    }
    let spec: Record<string, FileEdit>;
    try {
        spec = JSON.parse(readFileSync(specAbs, 'utf-8'));
    } catch (e) {
        result.errors.push(`spec is not valid JSON: ${e}`);
        return report(result);
    }
    for (const k of Object.keys(spec)) {
        if (k.startsWith('$') || k.startsWith('_')) delete spec[k]; // metadata keys
    }

    const notesDir = join(projectRoot, 'notes');
    const stores: Record<Kind, NoteStore> = {
        blockNotes: new NoteStore(join(notesDir, 'blockNotes')),
        partNotes: new NoteStore(join(notesDir, 'partNotes')),
        comments: new NoteStore(join(notesDir, 'comments')),
    };
    const namesLookup = loadNamesBankLookup(join(projectRoot, 'db-us', 'names'));
    const transformPatterns = loadTransformPatterns(projectRoot);

    // What the notes JSON must contain afterwards (null = absent); checked again after the write.
    const expected: Record<Kind, Map<string, string | null>> = {
        blockNotes: new Map(), partNotes: new Map(), comments: new Map(),
    };
    const claimed: Record<Kind, Map<string, string>> = {
        blockNotes: new Map(), partNotes: new Map(), comments: new Map(),
    };

    for (const [fileKey, edit] of Object.entries(spec)) {
        const abs = resolveAsmPath(projectRoot, fileKey);
        if (!abs) { result.errors.push(`${fileKey}: not an .asm file under extracted/`); continue; }
        if (!existsSync(abs)) { result.errors.push(`${fileKey}: file does not exist (run npm run extract:lt?)`); continue; }
        if (/MenuSelectionHandler\.asm$/.test(abs)) {
            result.errors.push(`${fileKey}: MenuSelectionHandler.asm is a transforms artifact; never merge notes for it`);
            continue;
        }
        let badKey = false;
        for (const k of Object.keys(edit)) {
            if (!['blockNote', 'partNotes', 'comments'].includes(k)) {
                result.errors.push(`${fileKey}: unknown key '${k}' (expected blockNote, partNotes, comments)`);
                badKey = true;
            }
        }
        if (badKey) continue;

        const label = relative(join(projectRoot, 'extracted'), abs).split(sep).join('/');
        const lines = readFileSync(abs, 'utf-8').split(/\r?\n/);
        const baseName = label.split('/').pop()!.replace(/\.asm$/, '');
        const fileBank = detectBank(lines, baseName, namesLookup);
        const err = (msg: string) => result.errors.push(`${label}: ${msg}`);
        const warn = (msg: string) => result.warnings.push(`${label}: ${msg}`);

        const claim = (kind: Kind, key: string): boolean => {
            const prev = claimed[kind].get(key);
            if (prev !== undefined) {
                err(`${kind} '${key}' is also set by ${prev} in this spec`);
                return false;
            }
            claimed[kind].set(key, label);
            return true;
        };

        const cBlock = newCounts(), cPart = newCounts(), cComment = newCounts();

        // ---- block note ----
        if (edit.blockNote !== undefined) {
            if (claim('blockNotes', baseName)) {
                const removing = noteIsEmpty(edit.blockNote);
                if (!removing && fileBank === null) {
                    err('block note: cannot determine the ROM bank of this file');
                } else {
                    const store = stores.blockNotes;
                    const cur = store.get(baseName);
                    if (removing) {
                        tally(cBlock, cur !== undefined, false, true);
                        store.remove(baseName);
                        expected.blockNotes.set(baseName, null);
                    } else {
                        const text = normalizeNote(edit.blockNote as string | string[]);
                        const bank = store.bankOf(baseName) ?? fileBank!;
                        tally(cBlock, cur !== undefined, cur !== text, false);
                        store.set(baseName, bank, text);
                        expected.blockNotes.set(baseName, text);
                    }
                }
            }
        }

        // ---- part notes ----
        const labels = collectLabels(lines);
        for (const [name, value] of Object.entries(edit.partNotes ?? {} as Record<string, NoteValue>)) {
            const hits = labels.get(name);
            if (!hits) {
                err(`label '${name}' not found.${suggest([...labels.keys()], name)}`);
                continue;
            }
            if (hits.length > 1) {
                err(`label '${name}' appears ${hits.length} times (lines ${hits.join(', ')}); ambiguous`);
                continue;
            }
            if (!claim('partNotes', name)) continue;

            const store = stores.partNotes;
            const cur = store.get(name);
            if (noteIsEmpty(value)) {
                tally(cPart, cur !== undefined, false, true);
                store.remove(name);
                expected.partNotes.set(name, null);
                continue;
            }
            if (fileBank === null && store.bankOf(name) === undefined) {
                err(`part note '${name}': cannot determine the ROM bank of this file`);
                continue;
            }
            const text = normalizeNote(value as string | string[]);
            const existingBank = store.bankOf(name);
            if (existingBank !== undefined && fileBank !== null && existingBank !== fileBank) {
                warn(`part note '${name}' already lives in bank${existingBank.toString(16).toUpperCase().padStart(2, '0')} ` +
                    `but the file resolves to bank${fileBank.toString(16).toUpperCase().padStart(2, '0')}; keeping the existing bank`);
            }
            const bank = existingBank ?? fileBank!;
            tally(cPart, cur !== undefined, cur !== text, false);
            store.set(name, bank, text);
            expected.partNotes.set(name, text);
        }

        // ---- comments ----
        const tags = collectTags(lines);
        for (const [addr, raw] of Object.entries(edit.comments ?? {} as Record<string, CommentValue>)) {
            if (!/^\d+$/.test(addr)) { err(`comment key '${addr}' must be a decimal address`); continue; }
            let text: string | null;
            let expect: string | undefined;
            if (raw !== null && typeof raw === 'object') { text = raw.text ?? null; expect = raw.expect; }
            else text = raw;
            if (text !== null) text = text.trim();
            if (text === '') text = null;

            const hits = tags.get(addr);
            if (!hits) {
                err(`comment {${addr}}: address tag not found` +
                    (tags.size === 0 ? ' (file has no ; {address} tags; run `npm run extract:lt` first)' : ''));
                continue;
            }
            if (hits.length > 1) {
                err(`comment {${addr}}: tag appears on ${hits.length} lines (${hits.map(h => h + 1).join(', ')}); ambiguous`);
                continue;
            }
            const line = lines[hits[0]];
            const tagMatch = line.match(TAG)!;
            const codePart = line.slice(0, tagMatch.index!).trim();
            if (expect !== undefined && !codePart.toLowerCase().includes(expect.toLowerCase())) {
                err(`comment {${addr}}: expected '${expect}' on line ${hits[0] + 1} but found '${codePart}'`);
                continue;
            }
            if (text !== null) {
                if (/[\r\n]/.test(text)) { err(`comment {${addr}}: must be a single line`); continue; }
                if (/\{\d+\}/.test(text)) { err(`comment {${addr}}: must not contain a {digits} tag`); continue; }
                if (text.length > 160) warn(`comment {${addr}}: ${text.length} chars; consider moving detail to a part note`);
                for (const re of transformPatterns) {
                    re.lastIndex = 0;
                    if (re.test(text)) {
                        warn(`comment {${addr}}: text matches a transforms.json pattern (${re.source.slice(0, 50)}...); extraction may rewrite it`);
                        break;
                    }
                }
            }
            if (!claim('comments', addr)) continue;

            const store = stores.comments;
            const cur = store.get(addr);
            if (text === null) {
                tally(cComment, cur !== undefined, false, true);
                store.remove(addr);
                expected.comments.set(addr, null);
            } else {
                const bank = Math.floor(parseInt(addr, 10) / 65536);
                tally(cComment, cur !== undefined, cur !== text, false);
                store.set(addr, bank, text);
                expected.comments.set(addr, text);
            }
        }

        console.log(`${label}: block ${fmt(cBlock)}, parts ${fmt(cPart)}, comments ${fmt(cComment)}   (+new ~updated -removed =unchanged)`);
    }

    if (result.errors.length > 0) {
        console.log('\nNothing written (fix the errors and re-run).');
        return report(result);
    }

    // ---- write ----
    for (const kind of KINDS) {
        const store = stores[kind];
        for (const bank of store.dirtyBanks()) {
            const path = store.pathFor(bank);
            result.notesFilesChanged.push(relative(projectRoot, path).split(sep).join('/'));
            if (!options.dryRun) saveJsonFile(path, store.banks.get(bank)!);
        }
    }

    if (options.dryRun) {
        console.log(`\n[DRY RUN] ${result.notesFilesChanged.length} notes file(s) would change; nothing written.`);
        for (const f of result.notesFilesChanged) console.log(`  ${f}`);
        result.ok = true;
        return report(result);
    }
    console.log(`\nWrote ${result.notesFilesChanged.length} notes file(s):`);
    for (const f of result.notesFilesChanged) console.log(`  ${f}`);

    // ---- verify against disk ----
    for (const kind of KINDS) {
        const onDisk = new NoteStore(join(notesDir, kind));
        const seen = new Map<string, number>();
        for (const [key, want] of expected[kind]) {
            const got = onDisk.get(key);
            if (want === null) {
                if (got !== undefined) result.errors.push(`verify: ${kind} '${key}' still present on disk`);
            } else if (got !== want) {
                result.errors.push(`verify: ${kind} '${key}' on disk does not match the spec`);
            }
            if (want !== null) seen.set(key, (seen.get(key) ?? 0) + 1);
        }
        // A key must live in exactly one bank file.
        const counts = new Map<string, number>();
        for (const data of onDisk.banks.values()) for (const k of Object.keys(data)) counts.set(k, (counts.get(k) ?? 0) + 1);
        for (const key of seen.keys()) {
            if ((counts.get(key) ?? 0) > 1) result.errors.push(`verify: ${kind} '${key}' exists in more than one bank file`);
        }
    }

    result.ok = result.errors.length === 0;
    if (result.ok) console.log('\nNext: npm run extract:lt  (the extractor re-reads notes/; check the output)');
    return report(result);
}

function report(result: MergeResult): MergeResult {
    if (result.warnings.length > 0) {
        console.log('\nWarnings:');
        for (const w of result.warnings) console.log(`  ! ${w}`);
    }
    if (result.errors.length > 0) {
        console.log('\nErrors:');
        for (const e of result.errors) console.log(`  X ${e}`);
    } else if (result.ok) {
        console.log('\nOK');
    }
    return result;
}
