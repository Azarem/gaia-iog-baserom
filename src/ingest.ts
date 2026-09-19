/**
 * Notes Ingestion Module
 * 
 * Parses extracted .asm files and ingests block notes, part notes, and inline
 * comments into the notes/ JSON directory structure. This eliminates the need
 * for agents to manually edit JSON files — the most error-prone step in the
 * documentation workflow.
 * 
 * Workflow:
 *   1. Run `npm run extract:lt` to produce address-tagged .asm output
 *   2. Edit the .asm files: add/update block notes, part notes, and inline
 *      comments (keeping {address} tags for inline comments)
 *   3. Run `npm run ingest` to parse the edits and write to notes/ JSON
 *   4. Run `npm run extract` to verify the final output
 * 
 * Inline comment format in extract:lt output:
 *   With existing comment:  `    LDA $00B2             ; {39414} existing comment`
 *   Without comment:        `    PLA                   ; {39419}`
 *   Agent adds comment:     `    PLA                   ; {39419} new comment text`
 * 
 * The ingest script MERGES with existing JSON — it never removes entries.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from 'fs';
import { join, basename, extname, dirname, relative } from 'path';

export interface IngestOptions {
    dryRun?: boolean;
    verbose?: boolean;
}

export interface IngestStats {
    filesProcessed: number;
    filesSkipped: number;
    blockNotesFound: number;
    blockNotesNew: number;
    blockNotesUpdated: number;
    partNotesFound: number;
    partNotesNew: number;
    partNotesUpdated: number;
    commentsFound: number;
    commentsNew: number;
    commentsUpdated: number;
    hasLineTracking: boolean;
}

interface ParsedAnnotations {
    blockNote?: { name: string; text: string };
    partNotes: Map<string, string>;
    comments: Map<number, string>;
    bank: number | null;
    hasLineTracking: boolean;
}

/**
 * Build a name → bank lookup from names.json for bank detection fallback.
 */
function loadNamesBankLookup(namesPath: string): Map<string, number> {
    const lookup = new Map<string, number>();
    if (!existsSync(namesPath)) return lookup;
    try {
        const names: Record<string, string> = JSON.parse(readFileSync(namesPath, 'utf-8'));
        for (const [addr, name] of Object.entries(names)) {
            const address = parseInt(addr, 10);
            if (!isNaN(address)) {
                lookup.set(name, Math.floor(address / 65536));
            }
        }
    } catch { /* ignore parse errors */ }
    return lookup;
}

/**
 * Detect the ROM bank for a file using multiple strategies.
 */
function detectBank(lines: string[], fileName: string, namesLookup: Map<string, number>): number | null {
    // Strategy 1: ?BANK directive
    for (const line of lines) {
        const match = line.match(/^\?BANK\s+([0-9A-Fa-f]+)/);
        if (match) return parseInt(match[1], 16);
    }

    // Strategy 2: code_XXXXXX or loc_XXXXXX labels (hex address in label name)
    for (const line of lines) {
        const match = line.match(/\b(?:code|loc)_([0-9A-Fa-f]{6})\b/);
        if (match) {
            const addr = parseInt(match[1], 16);
            return Math.floor(addr / 0x10000);
        }
    }

    // Strategy 3: {address} tags from extract:lt
    for (const line of lines) {
        const match = line.match(/;\s*\{(\d+)\}/);
        if (match) {
            return Math.floor(parseInt(match[1], 10) / 65536);
        }
    }

    // Strategy 4: File name or top-level label in names.json
    if (namesLookup.has(fileName)) {
        return namesLookup.get(fileName)!;
    }

    // Strategy 5: First top-level label found in names.json
    for (const line of lines) {
        const match = line.match(/^(\w+)\s+[\[{]/);
        if (match && namesLookup.has(match[1])) {
            return namesLookup.get(match[1])!;
        }
    }

    return null;
}

/**
 * Extract the block note from the top of a file.
 * Block notes are ; -prefixed lines before the first ----- separator.
 */
function parseBlockNote(lines: string[]): { text: string; endIndex: number } | null {
    const noteLines: string[] = [];
    let endIndex = -1;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.startsWith('-----')) {
            endIndex = i;
            break;
        }
        if (line.startsWith('; ')) {
            noteLines.push(line.slice(2));
        } else if (line === ';') {
            noteLines.push('');
        }
    }

    if (noteLines.length === 0 || endIndex < 0) return null;

    // Trim trailing empty lines
    while (noteLines.length > 0 && noteLines[noteLines.length - 1] === '') {
        noteLines.pop();
    }

    if (noteLines.length === 0) return null;

    return { text: noteLines.join('\n'), endIndex };
}

/**
 * Parse a single .asm file for block notes, part notes, and inline comments.
 */
function parseFile(filePath: string, namesLookup: Map<string, number>): ParsedAnnotations {
    const content = readFileSync(filePath, 'utf-8');
    const lines = content.split(/\r?\n/);
    const fileName = basename(filePath, extname(filePath));

    const result: ParsedAnnotations = {
        partNotes: new Map(),
        comments: new Map(),
        bank: null,
        hasLineTracking: false,
    };

    // Detect bank
    result.bank = detectBank(lines, fileName, namesLookup);

    // Parse block note (top of file before first -----)
    const blockNoteResult = parseBlockNote(lines);
    if (blockNoteResult) {
        result.blockNote = { name: fileName, text: blockNoteResult.text };
    }

    // Detect line tracking mode (has ; {address} tags)
    result.hasLineTracking = lines.some(l => /;\s*\{\d+\}/.test(l));

    // Parse part notes and inline comments
    const startIdx = blockNoteResult ? blockNoteResult.endIndex + 1 : 0;
    let commentBuffer: string[] = [];

    for (let i = startIdx; i < lines.length; i++) {
        const line = lines[i];

        // ----- separator resets comment buffer
        if (line.startsWith('-----')) {
            commentBuffer = [];
            continue;
        }

        // Empty line: preserve the comment buffer (notes can span empty ; lines)
        if (line.trim() === '') {
            continue;
        }

        // Non-indented comment line → potential part note content
        // Indented comments (4+ spaces) are instruction-level and handled below
        if ((line.startsWith('; ') || line === ';') && !line.match(/^\s{4,}/)) {
            const text = line === ';' ? '' : line.slice(2);
            commentBuffer.push(text);
            continue;
        }

        // Top-level label: "Name {" or "Name ["
        const topLevelMatch = line.match(/^(\w+)\s+[\[{]/);
        // Internal label: "  Label:"
        const internalMatch = line.match(/^\s{2}(\w+):$/);

        const labelName = topLevelMatch?.[1] || internalMatch?.[1];

        if (labelName && commentBuffer.length > 0) {
            // Trim trailing empty lines from buffer
            const trimmed = [...commentBuffer];
            while (trimmed.length > 0 && trimmed[trimmed.length - 1] === '') {
                trimmed.pop();
            }
            if (trimmed.length > 0) {
                result.partNotes.set(labelName, trimmed.join('\n'));
            }
            commentBuffer = [];
            continue;
        }

        // Check for inline comment with {address} tag (extract:lt format)
        // Pattern: anything ; {address} comment text
        // The address tag MUST be present — standard comments without tags are
        // already in JSON and don't need ingestion.
        const commentMatch = line.match(/;\s*\{(\d+)\}\s+(.+)/);
        if (commentMatch) {
            const address = parseInt(commentMatch[1], 10);
            const commentText = commentMatch[2].trim();
            if (commentText.length > 0) {
                result.comments.set(address, commentText);
            }
        }

        // Non-comment, non-empty, non-separator, non-label line → reset buffer
        // (instructions, directives, data, etc.)
        if (!line.startsWith('; ') && line !== ';') {
            commentBuffer = [];
        }
    }

    return result;
}

/**
 * Generate a bank file name from a bank number: "bank00.json", "bank03.json", etc.
 */
function bankFileName(bank: number): string {
    return `bank${bank.toString(16).toUpperCase().padStart(2, '0')}.json`;
}

/**
 * Load a JSON file as a string→string record.
 */
function loadJsonFile(filePath: string): Record<string, string> {
    if (!existsSync(filePath)) return {};
    try {
        return JSON.parse(readFileSync(filePath, 'utf-8'));
    } catch {
        return {};
    }
}

/**
 * Save a string→string record as formatted JSON.
 * Numeric keys are sorted numerically; string keys are sorted alphabetically.
 * Skips writing if the content is unchanged.
 */
function saveJsonFile(filePath: string, data: Record<string, string>): boolean {
    const dir = dirname(filePath);
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });

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

    const newContent = JSON.stringify(sorted, null, 4) + '\n';

    // Avoid rewriting unchanged files (prevents spurious git diffs)
    if (existsSync(filePath)) {
        const existingContent = readFileSync(filePath, 'utf-8');
        if (newContent === existingContent) return false;
    }

    writeFileSync(filePath, newContent, 'utf-8');
    return true;
}

/**
 * Recursively find all .asm files in a directory.
 */
function findAsmFiles(dir: string): string[] {
    const files: string[] = [];
    if (!existsSync(dir)) return files;

    const entries = readdirSync(dir, { withFileTypes: true, recursive: true });
    for (const entry of entries) {
        if (entry.isFile() && entry.name.endsWith('.asm')) {
            const parentPath = (entry as any).parentPath || (entry as any).path || dir;
            files.push(join(parentPath, entry.name));
        }
    }
    return files;
}

/**
 * Main ingestion entry point.
 * 
 * Reads .asm files from extractedDir (or specific targetFiles),
 * parses block notes, part notes, and inline comments, then merges
 * them into the notes/ JSON directory structure.
 * 
 * @param projectRoot  Root of the baserom project (contains notes/, db-us/, extracted/)
 * @param targetFiles  Optional list of specific .asm file paths to ingest
 * @param options      Dry-run and verbosity options
 * @returns Statistics about what was found and changed
 */
export function ingest(projectRoot: string, targetFiles?: string[], options?: IngestOptions): IngestStats {
    const extractedDir = join(projectRoot, 'extracted');
    const notesDir = join(projectRoot, 'notes');
    const namesPath = join(projectRoot, 'db-us', 'names.json');

    const stats: IngestStats = {
        filesProcessed: 0,
        filesSkipped: 0,
        blockNotesFound: 0,
        blockNotesNew: 0,
        blockNotesUpdated: 0,
        partNotesFound: 0,
        partNotesNew: 0,
        partNotesUpdated: 0,
        commentsFound: 0,
        commentsNew: 0,
        commentsUpdated: 0,
        hasLineTracking: false,
    };

    // Load names.json for bank detection fallback
    const namesLookup = loadNamesBankLookup(namesPath);

    // Find files to process
    const asmFiles = targetFiles && targetFiles.length > 0
        ? targetFiles
        : findAsmFiles(extractedDir);

    if (asmFiles.length === 0) {
        console.error('No .asm files found. Run extract or extract:lt first.');
        return stats;
    }

    console.log(`Scanning ${asmFiles.length} .asm file(s)...\n`);

    // Phase 1: Parse all files
    const blockNotesByBank = new Map<number, Map<string, string>>();
    const partNotesByBank = new Map<number, Map<string, string>>();
    const commentsByBank = new Map<number, Map<number, string>>();

    for (const file of asmFiles) {
        let parsed: ParsedAnnotations;
        try {
            parsed = parseFile(file, namesLookup);
        } catch (err) {
            const relPath = relative(projectRoot, file);
            console.warn(`  Warning: Failed to parse ${relPath}: ${err}`);
            stats.filesSkipped++;
            continue;
        }

        if (parsed.hasLineTracking) stats.hasLineTracking = true;

        const bank = parsed.bank;

        // Block note
        if (parsed.blockNote && bank !== null) {
            if (!blockNotesByBank.has(bank)) blockNotesByBank.set(bank, new Map());
            blockNotesByBank.get(bank)!.set(parsed.blockNote.name, parsed.blockNote.text);
            stats.blockNotesFound++;
            if (options?.verbose) {
                console.log(`  Block note: ${parsed.blockNote.name} → bank${bank.toString(16).toUpperCase().padStart(2, '0')}`);
            }
        }

        // Part notes
        if (bank !== null) {
            for (const [name, text] of parsed.partNotes) {
                if (!partNotesByBank.has(bank)) partNotesByBank.set(bank, new Map());
                partNotesByBank.get(bank)!.set(name, text);
                stats.partNotesFound++;
                if (options?.verbose) {
                    console.log(`  Part note:  ${name} → bank${bank.toString(16).toUpperCase().padStart(2, '0')}`);
                }
            }
        } else if (parsed.partNotes.size > 0) {
            const relPath = relative(projectRoot, file);
            console.warn(`  Warning: Could not determine bank for ${relPath} — skipping ${parsed.partNotes.size} part note(s)`);
        }

        // Inline comments (bank determined per-address)
        for (const [addr, text] of parsed.comments) {
            const commentBank = Math.floor(addr / 65536);
            if (!commentsByBank.has(commentBank)) commentsByBank.set(commentBank, new Map());
            commentsByBank.get(commentBank)!.set(addr, text);
            stats.commentsFound++;
        }

        stats.filesProcessed++;
    }

    // Phase 2: Report what was found
    console.log(`\nParsed ${stats.filesProcessed} file(s)${stats.filesSkipped > 0 ? ` (${stats.filesSkipped} skipped)` : ''}:`);
    console.log(`  Block notes: ${stats.blockNotesFound}`);
    console.log(`  Part notes:  ${stats.partNotesFound}`);
    console.log(`  Comments:    ${stats.commentsFound}${stats.hasLineTracking ? '' : ' (no line tracking detected — run extract:lt for inline comments)'}`);

    if (options?.dryRun) {
        console.log('\n[DRY RUN] No files will be written.\n');
    }

    // Phase 3: Merge with existing JSON and write
    console.log('\nMerging with existing notes/...');

    // Block notes
    for (const [bank, notes] of blockNotesByBank) {
        const filePath = join(notesDir, 'blockNotes', bankFileName(bank));
        const existing = loadJsonFile(filePath);
        let newCount = 0, updatedCount = 0;

        for (const [name, text] of notes) {
            if (existing[name] === text) continue;
            if (existing[name] !== undefined) {
                updatedCount++;
                stats.blockNotesUpdated++;
            } else {
                newCount++;
                stats.blockNotesNew++;
            }
            existing[name] = text;
        }

        if (newCount === 0 && updatedCount === 0) continue;

        const relPath = relative(projectRoot, filePath);
        if (options?.dryRun) {
            console.log(`  [DRY] ${relPath}: ${newCount} new, ${updatedCount} updated`);
        } else {
            const written = saveJsonFile(filePath, existing);
            if (written) {
                console.log(`  ${relPath}: ${newCount} new, ${updatedCount} updated`);
            }
        }
    }

    // Part notes
    for (const [bank, notes] of partNotesByBank) {
        const filePath = join(notesDir, 'partNotes', bankFileName(bank));
        const existing = loadJsonFile(filePath);
        let newCount = 0, updatedCount = 0;

        for (const [name, text] of notes) {
            if (existing[name] === text) continue;
            if (existing[name] !== undefined) {
                updatedCount++;
                stats.partNotesUpdated++;
            } else {
                newCount++;
                stats.partNotesNew++;
            }
            existing[name] = text;
        }

        if (newCount === 0 && updatedCount === 0) continue;

        const relPath = relative(projectRoot, filePath);
        if (options?.dryRun) {
            console.log(`  [DRY] ${relPath}: ${newCount} new, ${updatedCount} updated`);
        } else {
            const written = saveJsonFile(filePath, existing);
            if (written) {
                console.log(`  ${relPath}: ${newCount} new, ${updatedCount} updated`);
            }
        }
    }

    // Comments
    for (const [bank, comments] of commentsByBank) {
        const filePath = join(notesDir, 'comments', bankFileName(bank));
        const existing = loadJsonFile(filePath);
        let newCount = 0, updatedCount = 0;

        for (const [addr, text] of comments) {
            const key = addr.toString();
            if (existing[key] === text) continue;
            if (existing[key] !== undefined) {
                updatedCount++;
                stats.commentsUpdated++;
            } else {
                newCount++;
                stats.commentsNew++;
            }
            existing[key] = text;
        }

        if (newCount === 0 && updatedCount === 0) continue;

        const relPath = relative(projectRoot, filePath);
        if (options?.dryRun) {
            console.log(`  [DRY] ${relPath}: ${newCount} new, ${updatedCount} updated`);
        } else {
            const written = saveJsonFile(filePath, existing);
            if (written) {
                console.log(`  ${relPath}: ${newCount} new, ${updatedCount} updated`);
            }
        }
    }

    // Phase 4: Summary
    const totalChanges = stats.blockNotesNew + stats.blockNotesUpdated
        + stats.partNotesNew + stats.partNotesUpdated
        + stats.commentsNew + stats.commentsUpdated;

    console.log('\nSummary:');
    if (totalChanges === 0) {
        console.log('  No changes detected — notes/ is up to date.');
    } else {
        if (stats.blockNotesNew + stats.blockNotesUpdated > 0) {
            console.log(`  Block notes: ${stats.blockNotesNew} new, ${stats.blockNotesUpdated} updated`);
        }
        if (stats.partNotesNew + stats.partNotesUpdated > 0) {
            console.log(`  Part notes:  ${stats.partNotesNew} new, ${stats.partNotesUpdated} updated`);
        }
        if (stats.commentsNew + stats.commentsUpdated > 0) {
            console.log(`  Comments:    ${stats.commentsNew} new, ${stats.commentsUpdated} updated`);
        }
    }

    console.log(`\nIngestion ${options?.dryRun ? '(dry run) ' : ''}complete.`);
    return stats;
}
