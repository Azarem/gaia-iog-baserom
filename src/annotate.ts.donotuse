/**
 * Annotation Editor
 *
 * SUPERSEDED for everyday use by `npm run merge` (src/merge.ts), which takes the same spec
 * but writes notes/*.json directly instead of editing the .asm and ingesting it back.
 * Kept for the case where the extracted .asm itself should be edited.
 *
 * Applies a JSON edit spec to extracted .asm files: block notes, part notes and
 * inline comments can each be set, replaced or removed. It replaces hand-written
 * one-off edit scripts. Every edit is validated against the file before anything
 * is written, so a typo in a label or address aborts the whole run instead of
 * silently doing nothing.
 *
 * Workflow:
 *   1. `npm run extract:lt`            (address tags are needed for comments)
 *   2. Write an edit spec (JSON), e.g. plans/extracted-audit/edits/I015.json
 *   3. `npm run annotate -- <spec.json> --dry-run`   preview, writes nothing
 *   4. `npm run annotate -- <spec.json>`             edit .asm, ingest, verify
 *   5. `npm run extract` and `npm run rebuild`       final check
 *
 * Spec format (paths are relative to extracted/):
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
 *   - string / array  = set (add or replace)
 *   - null or ""      = remove
 *   - "expect"        = optional guard: the instruction on that line must contain it
 *
 * Part-note labels may be top-level parts (`Name {`, `Name [`, `Name #hex`,
 * `Name \`text`, `Name ~text`, `Name |text`) or sub-labels (`  Name:`).
 */

import { readFileSync, writeFileSync, existsSync, readdirSync } from 'fs';
import { join, resolve, relative, isAbsolute, sep } from 'path';
import { ingest } from './ingest.ts';

export interface AnnotateOptions {
    dryRun?: boolean;
    noIngest?: boolean;
    verbose?: boolean;
}

export interface AnnotateResult {
    ok: boolean;
    errors: string[];
    warnings: string[];
    filesChanged: string[];
}

export type NoteValue = string | string[] | null;
export type CommentValue = string | null | { text: string | null; expect?: string };

export interface FileEdit {
    blockNote?: NoteValue;
    partNotes?: Record<string, NoteValue>;
    comments?: Record<string, CommentValue>;
}

const SEPARATOR = '-'.repeat(45);
export const TOP_LABEL = /^(\w+)\s+[\[{#`~|]/;
export const SUB_LABEL = /^\s{2}(\w+):$/;
export const TAG = /;\s*\{(\d+)\}/;

interface Counts {
    blockSet: number; blockRemoved: number;
    partSet: number; partRemoved: number;
    commentSet: number; commentRemoved: number;
    unchanged: number;
}

function isNoteLine(line: string): boolean {
    return line === ';' || line.startsWith('; ');
}

function isSeparator(line: string): boolean {
    return line.startsWith('-----');
}

/** Normalise a note value to its stored form (what ingest writes to notes/*.json). */
export function normalizeNote(value: string | string[]): string {
    const text = Array.isArray(value) ? value.join('\n') : value;
    const lines = text.replace(/\r\n/g, '\n').split('\n').map(l => l.trimEnd());
    while (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
    while (lines.length > 0 && lines[0] === '') lines.shift();
    return lines.join('\n');
}

function toNoteLines(stored: string): string[] {
    return stored.split('\n').map(l => (l === '' ? '; ' : '; ' + l));
}

export function noteIsEmpty(value: NoteValue | undefined): boolean {
    if (value === null || value === undefined) return true;
    return normalizeNote(value) === '';
}

function suggest(names: string[], wanted: string): string {
    const w = wanted.toLowerCase();
    const hits = names.filter(n => n.toLowerCase().includes(w) || w.includes(n.toLowerCase())).slice(0, 5);
    return hits.length > 0 ? ` Did you mean: ${hits.join(', ')}?` : '';
}

class FileEditor {
    lines: string[];
    eol: string;
    trailingNewline: boolean;
    errors: string[] = [];
    warnings: string[] = [];
    counts: Counts = { blockSet: 0, blockRemoved: 0, partSet: 0, partRemoved: 0, commentSet: 0, commentRemoved: 0, unchanged: 0 };

    label: string;

    constructor(label: string, raw: string) {
        this.label = label;
        const crlf = (raw.match(/\r\n/g) || []).length;
        const bareLf = (raw.match(/(?<!\r)\n/g) || []).length;
        this.eol = crlf >= bareLf && crlf > 0 ? '\r\n' : (bareLf > 0 ? '\n' : '\r\n');
        this.trailingNewline = /\r?\n$/.test(raw);
        this.lines = raw.split(/\r?\n/);
        if (this.trailingNewline) this.lines.pop();
    }

    serialize(): string {
        return this.lines.join(this.eol) + (this.trailingNewline ? this.eol : '');
    }

    private err(msg: string) { this.errors.push(`${this.label}: ${msg}`); }
    private warn(msg: string) { this.warnings.push(`${this.label}: ${msg}`); }

    // ---- block note ----

    applyBlockNote(value: NoteValue) {
        const sepIdx = this.lines.findIndex(isSeparator);
        let noteEnd = 0;
        while (noteEnd < this.lines.length && isNoteLine(this.lines[noteEnd])) noteEnd++;
        const hasNote = noteEnd > 0;

        if (hasNote && (sepIdx < 0 || noteEnd !== sepIdx)) {
            this.err(`block note: unexpected layout (note lines 1-${noteEnd} are not directly followed by the first ----- separator); fix by hand`);
            return;
        }
        if (!hasNote && sepIdx >= 0) {
            // A leading ; line elsewhere before the separator would be parsed as a block note by ingest.
            const stray = this.lines.slice(0, sepIdx).findIndex(isNoteLine);
            if (stray >= 0) {
                this.err(`block note: line ${stray + 1} is a ';' line before the first separator but not at the top of the file; fix by hand`);
                return;
            }
        }

        if (noteIsEmpty(value)) {
            if (!hasNote) { this.counts.unchanged++; return; }
            // Remove note lines, the separator, and one following blank line.
            let removeTo = noteEnd + 1;
            if (this.lines[removeTo] === '') removeTo++;
            this.lines.splice(0, removeTo);
            this.counts.blockRemoved++;
            return;
        }

        const stored = normalizeNote(value as string | string[]);
        const newLines = toNoteLines(stored);
        if (hasNote) {
            const current = this.lines.slice(0, noteEnd);
            if (current.join('\n') === newLines.join('\n')) { this.counts.unchanged++; return; }
            this.lines.splice(0, noteEnd, ...newLines);
        } else {
            if (sepIdx < 0) {
                this.err('block note: file has no ----- separator, so ingest cannot read a block note from it');
                return;
            }
            this.lines.splice(0, 0, ...newLines, SEPARATOR, '');
        }
        this.counts.blockSet++;
    }

    // ---- part notes ----

    private findLabel(name: string): number {
        const hits: number[] = [];
        for (let i = 0; i < this.lines.length; i++) {
            const line = this.lines[i];
            if (/^[?!]/.test(line)) continue;
            const m = line.match(TOP_LABEL) || line.match(SUB_LABEL);
            if (m && m[1] === name) hits.push(i);
        }
        if (hits.length === 1) return hits[0];
        if (hits.length > 1) {
            this.err(`label '${name}' appears ${hits.length} times (lines ${hits.map(h => h + 1).join(', ')}); ambiguous`);
            return -2;
        }
        const all: string[] = [];
        for (const line of this.lines) {
            const m = line.match(TOP_LABEL) || line.match(SUB_LABEL);
            if (m && !/^[?!]/.test(line)) all.push(m[1]);
        }
        this.err(`label '${name}' not found.${suggest(all, name)}`);
        return -1;
    }

    applyPartNote(name: string, value: NoteValue) {
        const idx = this.findLabel(name);
        if (idx < 0) return;
        const topLevel = TOP_LABEL.test(this.lines[idx]);

        // Walk upward over blank lines and non-indented ';' lines (same rule as ingest).
        let j = idx - 1;
        while (j >= 0 && (this.lines[j] === '' || isNoteLine(this.lines[j]))) j--;
        let noteStart = -1, noteEnd = -1;
        for (let k = j + 1; k < idx; k++) {
            if (isNoteLine(this.lines[k])) {
                if (noteStart < 0) noteStart = k;
                noteEnd = k;
            }
        }
        const hasNote = noteStart >= 0;

        if (noteIsEmpty(value)) {
            if (!hasNote) { this.counts.unchanged++; return; }
            this.lines.splice(noteStart, noteEnd - noteStart + 1);
            // Top-level parts: the extractor only prints a ----- separator above a part that has a
            // note, so drop it too (never the file's first separator, which ends the header).
            if (topLevel) {
                let s = noteStart - 1;
                while (s >= 0 && this.lines[s] === '') s--;
                const firstSep = this.lines.findIndex(isSeparator);
                if (s >= 0 && isSeparator(this.lines[s]) && s !== firstSep) {
                    this.lines.splice(s, noteStart - s);
                    noteStart = s;
                }
            }
            // Collapse the doubled blank line the removal can leave behind.
            while (noteStart > 0 && this.lines[noteStart - 1] === '' && this.lines[noteStart] === '') {
                this.lines.splice(noteStart, 1);
            }
            this.counts.partRemoved++;
            return;
        }

        const stored = normalizeNote(value as string | string[]);
        const newLines = toNoteLines(stored);
        if (hasNote) {
            const current = this.lines.slice(noteStart, noteEnd + 1);
            if (current.join('\n') === newLines.join('\n')) { this.counts.unchanged++; return; }
            this.lines.splice(noteStart, noteEnd - noteStart + 1, ...newLines);
        } else {
            // Layout matches the extractor: blank, ----- (top-level parts only), note, blank, label.
            let s = idx - 1;
            while (s >= 0 && this.lines[s] === '') s--;
            const sepAbove = s >= 0 && isSeparator(this.lines[s]);
            const insert: string[] = [];
            if (this.lines[idx - 1] !== '' && !sepAbove) insert.push('');
            if (topLevel && !sepAbove) insert.push(SEPARATOR);
            insert.push(...newLines, '');
            this.lines.splice(idx, 0, ...insert);
        }
        this.counts.partSet++;
    }

    // ---- inline comments ----

    applyComment(addrKey: string, value: CommentValue, transformPatterns: RegExp[]) {
        if (!/^\d+$/.test(addrKey)) {
            this.err(`comment key '${addrKey}' must be a decimal address`);
            return;
        }
        let text: string | null;
        let expect: string | undefined;
        if (value !== null && typeof value === 'object') {
            text = value.text ?? null;
            expect = value.expect;
        } else {
            text = value;
        }
        if (text !== null) text = text.trim();
        if (text === '') text = null;

        const hits: number[] = [];
        for (let i = 0; i < this.lines.length; i++) {
            const m = this.lines[i].match(TAG);
            if (m && m[1] === addrKey) hits.push(i);
        }
        if (hits.length === 0) {
            const hasTags = this.lines.some(l => TAG.test(l));
            this.err(`comment {${addrKey}}: address tag not found${hasTags ? '' : ' (file has no ; {address} tags — run `npm run extract:lt` first)'}`);
            return;
        }
        if (hits.length > 1) {
            this.err(`comment {${addrKey}}: tag appears on ${hits.length} lines (${hits.map(h => h + 1).join(', ')}); ambiguous`);
            return;
        }
        const i = hits[0];
        const line = this.lines[i];
        const tagMatch = line.match(TAG)!;
        const tagEnd = tagMatch.index! + tagMatch[0].length;
        const codePart = line.slice(0, tagMatch.index!).trim();

        if (expect !== undefined && !codePart.toLowerCase().includes(expect.toLowerCase())) {
            this.err(`comment {${addrKey}}: expected '${expect}' on line ${i + 1} but found '${codePart}'`);
            return;
        }

        if (text !== null) {
            if (/[\r\n]/.test(text)) { this.err(`comment {${addrKey}}: must be a single line`); return; }
            if (/\{\d+\}/.test(text)) { this.err(`comment {${addrKey}}: must not contain a {digits} tag`); return; }
            if (text.length > 160) this.warn(`comment {${addrKey}}: ${text.length} chars; consider moving detail to a part note`);
            for (const re of transformPatterns) {
                re.lastIndex = 0;
                if (re.test(text)) {
                    this.warn(`comment {${addrKey}}: text matches a transforms.json pattern (${re.source.slice(0, 50)}...); extraction may rewrite it`);
                    break;
                }
            }
        }

        const existing = line.slice(tagEnd).trim();
        const next = text === null ? '' : text;
        if (existing === next) { this.counts.unchanged++; return; }
        const prefix = line.slice(0, tagEnd);
        this.lines[i] = text === null ? prefix : `${prefix} ${text}`;
        if (text === null) this.counts.commentRemoved++; else this.counts.commentSet++;
    }
}

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

export function resolveAsmPath(projectRoot: string, key: string): string | null {
    const extracted = join(projectRoot, 'extracted');
    let p = isAbsolute(key) ? key : resolve(extracted, key.replace(/^extracted[\\/]/, ''));
    p = resolve(p);
    const rel = relative(extracted, p);
    if (rel.startsWith('..') || isAbsolute(rel) || !p.endsWith('.asm')) return null;
    return p;
}

function readAllNotes(projectRoot: string, kind: 'blockNotes' | 'partNotes' | 'comments'): Map<string, string[]> {
    const dir = join(projectRoot, 'notes', kind);
    const all = new Map<string, string[]>();
    if (!existsSync(dir)) return all;
    for (const f of readdirSync(dir)) {
        if (!f.endsWith('.json')) continue;
        const json = JSON.parse(readFileSync(join(dir, f), 'utf-8')) as Record<string, string>;
        for (const [k, v] of Object.entries(json)) {
            if (!all.has(k)) all.set(k, []);
            all.get(k)!.push(v);
        }
    }
    return all;
}

/** After ingest, confirm each requested edit is present (or absent) in notes/*.json. */
function verifyIngest(projectRoot: string, spec: Record<string, FileEdit>, errors: string[]) {
    const blocks = readAllNotes(projectRoot, 'blockNotes');
    const parts = readAllNotes(projectRoot, 'partNotes');
    const comments = readAllNotes(projectRoot, 'comments');

    for (const [file, edit] of Object.entries(spec)) {
        const base = file.replace(/\\/g, '/').split('/').pop()!.replace(/\.asm$/, '');
        if (edit.blockNote !== undefined) {
            const got = blocks.get(base) ?? [];
            if (noteIsEmpty(edit.blockNote)) {
                if (got.length > 0) errors.push(`verify: block note for '${base}' still present in notes/blockNotes`);
            } else if (!got.includes(normalizeNote(edit.blockNote!))) {
                errors.push(`verify: block note for '${base}' did not reach notes/blockNotes`);
            }
        }
        for (const [label, value] of Object.entries(edit.partNotes ?? {})) {
            const got = parts.get(label) ?? [];
            if (noteIsEmpty(value)) {
                if (got.length > 0) errors.push(`verify: part note '${label}' still present in notes/partNotes`);
            } else if (!got.includes(normalizeNote(value!))) {
                errors.push(`verify: part note '${label}' did not reach notes/partNotes (ingest may not recognise this label form)`);
            }
        }
        for (const [addr, raw] of Object.entries(edit.comments ?? {})) {
            const text = raw !== null && typeof raw === 'object' ? raw.text : raw;
            const got = comments.get(addr) ?? [];
            const want = (text ?? '').trim();
            if (want === '') {
                if (got.length > 0) errors.push(`verify: comment {${addr}} still present in notes/comments`);
            } else if (!got.includes(want)) {
                errors.push(`verify: comment {${addr}} did not reach notes/comments`);
            }
        }
    }
}

export function annotate(projectRoot: string, specPath: string, options: AnnotateOptions = {}): AnnotateResult {
    const result: AnnotateResult = { ok: false, errors: [], warnings: [], filesChanged: [] };

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

    const transformPatterns = loadTransformPatterns(projectRoot);
    const pending: { abs: string; rel: string; editor: FileEditor; changed: boolean; original: string }[] = [];

    for (const [fileKey, edit] of Object.entries(spec)) {
        const abs = resolveAsmPath(projectRoot, fileKey);
        if (!abs) { result.errors.push(`${fileKey}: not an .asm file under extracted/`); continue; }
        if (!existsSync(abs)) { result.errors.push(`${fileKey}: file does not exist`); continue; }
        if (/MenuSelectionHandler\.asm$/.test(abs)) {
            result.errors.push(`${fileKey}: MenuSelectionHandler.asm is a transforms artifact; never annotate/ingest it`);
            continue;
        }
        for (const k of Object.keys(edit)) {
            if (!['blockNote', 'partNotes', 'comments'].includes(k)) {
                result.errors.push(`${fileKey}: unknown key '${k}' (expected blockNote, partNotes, comments)`);
            }
        }

        const original = readFileSync(abs, 'utf-8');
        const label = relative(join(projectRoot, 'extracted'), abs).split(sep).join('/');
        const editor = new FileEditor(label, original);

        // Comments never shift lines; part notes may; block note last.
        for (const [addr, v] of Object.entries(edit.comments ?? {})) editor.applyComment(addr, v, transformPatterns);
        for (const [name, v] of Object.entries(edit.partNotes ?? {})) editor.applyPartNote(name, v);
        if (edit.blockNote !== undefined) editor.applyBlockNote(edit.blockNote);

        result.errors.push(...editor.errors);
        result.warnings.push(...editor.warnings);
        const text = editor.serialize();
        pending.push({ abs, rel: label, editor, changed: text !== original, original });

        const c = editor.counts;
        console.log(
            `${label}: block +${c.blockSet}/-${c.blockRemoved}, parts +${c.partSet}/-${c.partRemoved}, ` +
            `comments +${c.commentSet}/-${c.commentRemoved}, unchanged ${c.unchanged}`
        );
    }

    if (result.errors.length > 0) {
        console.log('\nNothing written (fix the errors and re-run).');
        return report(result);
    }

    for (const p of pending) {
        if (!p.changed) continue;
        result.filesChanged.push(p.rel);
        if (!options.dryRun) writeFileSync(p.abs, p.editor.serialize(), 'utf-8');
    }

    if (options.dryRun) {
        console.log(`\n[DRY RUN] ${result.filesChanged.length} file(s) would change; nothing written.`);
        result.ok = true;
        return report(result);
    }
    console.log(`\nWrote ${result.filesChanged.length} file(s).`);

    if (!options.noIngest && result.filesChanged.length > 0) {
        const abs = pending.filter(p => p.changed).map(p => p.abs);
        console.log('\n--- ingest ---');
        ingest(projectRoot, abs, { verbose: options.verbose });
        console.log('\n--- ingest re-check (must report no changes) ---');
        const stats = ingest(projectRoot, abs, { dryRun: true });
        const residual = stats.blockNotesNew + stats.blockNotesUpdated + stats.blockNotesDeleted +
            stats.partNotesNew + stats.partNotesUpdated + stats.partNotesDeleted +
            stats.commentsNew + stats.commentsUpdated + stats.commentsDeleted;
        if (residual > 0) result.errors.push(`ingest re-check still reports ${residual} pending change(s)`);
        verifyIngest(projectRoot, spec, result.errors);
    }

    result.ok = result.errors.length === 0;
    return report(result);
}

function report(result: AnnotateResult): AnnotateResult {
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
