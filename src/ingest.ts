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
 *   2. Edit the .asm files: add/update/remove block notes, part notes, and
 *      inline comments (keeping {address} tags for inline comments)
 *   3. Run `npm run ingest` to parse the edits and write to notes/ JSON
 *   4. Run `npm run extract` to verify the final output
 *
 * Inline comment format in extract:lt output:
 *   With existing comment:  `    LDA $00B2             ; {39414} existing comment`
 *   Without comment:        `    PLA                   ; {39419}`
 *   Agent adds comment:     `    PLA                   ; {39419} new comment text`
 *   Agent removes comment:  `    LDA $00B2             ; {39414}`  (delete text after tag)
 *
 * The ingest script supports additions, updates, AND deletions:
 *   - Additions: new annotations found in the .asm file are added to JSON
 *   - Updates:   changed annotations overwrite the existing JSON entry
 *   - Deletions: annotations present in JSON but absent from the .asm file
 *                are removed (scoped to the processed file's labels/addresses)
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
    blockNotesDeleted: number;
    partNotesFound: number;
    partNotesNew: number;
    partNotesUpdated: number;
    partNotesDeleted: number;
    commentsFound: number;
    commentsNew: number;
    commentsUpdated: number;
    commentsDeleted: number;
    hasLineTracking: boolean;
}

interface ParsedAnnotations {
    blockNote?: { name: string; text: string };
    partNotes: Map<string, string>;
    comments: Map<number, string>;
    // Deletion detection
    fileName: string;
    hasStructure: boolean;
    allLabels: Set<string>;
    uncommentedAddresses: Set<number>;
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
 * Also tracks labels without notes and addresses without comments for
 * deletion detection.
 */
function parseFile(filePath: string, namesLookup: Map<string, number>): ParsedAnnotations {
    const content = readFileSync(filePath, 'utf-8');
    const lines = content.split(/\r?\n/);
    const fileName = basename(filePath, extname(filePath));

    const result: ParsedAnnotations = {
        partNotes: new Map(),
        comments: new Map(),
        fileName,
        hasStructure: false,
        allLabels: new Set(),
        uncommentedAddresses: new Set(),
        bank: null,
        hasLineTracking: false,
    };

    // Detect structure (has ----- separators)
    result.hasStructure = lines.some(l => l.startsWith('-----'));

    // Detect bank
    result.bank = detectBank(lines, fileName, namesLookup);

    // Parse block note (top of file before first -----)
    const blockNoteResult = parseBlockNote(lines);
    if (blockNoteResult) {
        result.blockNote = { name: fileName, text: blockNoteResult.text };
    }

    // Detect line tracking mode (has ; {address} tags)
    result.hasLineTracking = lines.some(l => /;\s*\{\d+\}/.test(l));

    // Parse part notes, inline comments, and track all labels/addresses
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

        if (labelName) {
            // Always track the label for deletion detection
            result.allLabels.add(labelName);

            if (commentBuffer.length > 0) {
                // Trim trailing empty lines from buffer
                const trimmed = [...commentBuffer];
                while (trimmed.length > 0 && trimmed[trimmed.length - 1] === '') {
                    trimmed.pop();
                }
                if (trimmed.length > 0) {
                    result.partNotes.set(labelName, trimmed.join('\n'));
                }
            }
            commentBuffer = [];
            continue;
        }

        // Check for address tags (extract:lt format)
        // Match ; {address} with optional trailing text
        const addressTagMatch = line.match(/;\s*\{(\d+)\}\s*(.*)/);
        if (addressTagMatch) {
            const address = parseInt(addressTagMatch[1], 10);
            const commentText = addressTagMatch[2]?.trim();
            if (commentText && commentText.length > 0) {
                result.comments.set(address, commentText);
            } else {
                // Address tag without text → candidate for deletion
                result.uncommentedAddresses.add(address);
            }
        }

        // Non-comment, non-empty, non-separator, non-label line → reset buffer
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

/** Format a change summary string like "2 new, 1 updated, 3 deleted" */
function formatChanges(n: number, u: number, d: number): string {
    const parts: string[] = [];
    if (n > 0) parts.push(`${n} new`);
    if (u > 0) parts.push(`${u} updated`);
    if (d > 0) parts.push(`${d} deleted`);
    return parts.join(', ');
}

/**
 * Main ingestion entry point.
 *
 * Reads .asm files from extractedDir (or specific targetFiles),
 * parses block notes, part notes, and inline comments, then merges
 * them into the notes/ JSON directory structure.
 *
 * Supports additions, updates, AND deletions:
 *   - Block note deletion: file has structure but no block note → remove from JSON
 *   - Part note deletion:  label appears in file without a note → remove from JSON
 *   - Comment deletion:    address has ; {addr} tag but no text → remove from JSON
 *
 * Deletions are scoped to processed files only — entries from unprocessed
 * files are never touched.
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
        blockNotesDeleted: 0,
        partNotesFound: 0,
        partNotesNew: 0,
        partNotesUpdated: 0,
        partNotesDeleted: 0,
        commentsFound: 0,
        commentsNew: 0,
        commentsUpdated: 0,
        commentsDeleted: 0,
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

    // Phase 1: Parse all files and collect additions + deletion candidates
    // Additions/updates
    const blockNotesByBank = new Map<number, Map<string, string>>();
    const partNotesByBank = new Map<number, Map<string, string>>();
    const commentsByBank = new Map<number, Map<number, string>>();
    // Deletion candidates
    const blockNoteDeletions = new Map<number, Set<string>>();
    const partNoteDeletions = new Map<number, Set<string>>();
    const commentDeletions = new Map<number, Set<number>>();

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

        // --- Block note additions ---
        if (parsed.blockNote && bank !== null) {
            if (!blockNotesByBank.has(bank)) blockNotesByBank.set(bank, new Map());
            blockNotesByBank.get(bank)!.set(parsed.blockNote.name, parsed.blockNote.text);
            stats.blockNotesFound++;
            if (options?.verbose) {
                console.log(`  Block note: ${parsed.blockNote.name} → bank${bank.toString(16).toUpperCase().padStart(2, '0')}`);
            }
        }

        // --- Block note deletion candidate ---
        // File has structure but no block note → the block note was removed
        if (!parsed.blockNote && parsed.hasStructure && bank !== null) {
            if (!blockNoteDeletions.has(bank)) blockNoteDeletions.set(bank, new Set());
            blockNoteDeletions.get(bank)!.add(parsed.fileName);
        }

        // --- Part note additions ---
        if (bank !== null) {
            for (const [name, text] of parsed.partNotes) {
                if (!partNotesByBank.has(bank)) partNotesByBank.set(bank, new Map());
                partNotesByBank.get(bank)!.set(name, text);
                stats.partNotesFound++;
                if (options?.verbose) {
                    console.log(`  Part note:  ${name} → bank${bank.toString(16).toUpperCase().padStart(2, '0')}`);
                }
            }

            // --- Part note deletion candidates ---
            // Labels that appear in the file WITHOUT a preceding part note
            for (const label of parsed.allLabels) {
                if (!parsed.partNotes.has(label)) {
                    if (!partNoteDeletions.has(bank)) partNoteDeletions.set(bank, new Set());
                    partNoteDeletions.get(bank)!.add(label);
                }
            }
        } else if (parsed.partNotes.size > 0) {
            const relPath = relative(projectRoot, file);
            console.warn(`  Warning: Could not determine bank for ${relPath} — skipping ${parsed.partNotes.size} part note(s)`);
        }

        // --- Inline comment additions ---
        for (const [addr, text] of parsed.comments) {
            const commentBank = Math.floor(addr / 65536);
            if (!commentsByBank.has(commentBank)) commentsByBank.set(commentBank, new Map());
            commentsByBank.get(commentBank)!.set(addr, text);
            stats.commentsFound++;
        }

        // --- Inline comment deletion candidates ---
        // Addresses with ; {address} but no text (only in extract:lt mode)
        if (parsed.hasLineTracking) {
            for (const addr of parsed.uncommentedAddresses) {
                const commentBank = Math.floor(addr / 65536);
                if (!commentDeletions.has(commentBank)) commentDeletions.set(commentBank, new Set());
                commentDeletions.get(commentBank)!.add(addr);
            }
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

    // Phase 3: Merge additions/updates and apply deletions, then write
    console.log('\nMerging with existing notes/...');

    // Collect all bank numbers that need processing
    const allBanks = new Set<number>();
    for (const bank of blockNotesByBank.keys()) allBanks.add(bank);
    for (const bank of blockNoteDeletions.keys()) allBanks.add(bank);
    for (const bank of partNotesByBank.keys()) allBanks.add(bank);
    for (const bank of partNoteDeletions.keys()) allBanks.add(bank);
    for (const bank of commentsByBank.keys()) allBanks.add(bank);
    for (const bank of commentDeletions.keys()) allBanks.add(bank);

    for (const bank of [...allBanks].sort()) {
        // --- Block notes ---
        const bnAdds = blockNotesByBank.get(bank);
        const bnDels = blockNoteDeletions.get(bank);
        if (bnAdds || bnDels) {
            const filePath = join(notesDir, 'blockNotes', bankFileName(bank));
            const existing = loadJsonFile(filePath);
            let newCount = 0, updatedCount = 0, deletedCount = 0;

            // Additions/updates
            if (bnAdds) {
                for (const [name, text] of bnAdds) {
                    if (existing[name] === text) continue;
                    if (existing[name] !== undefined) { updatedCount++; stats.blockNotesUpdated++; }
                    else { newCount++; stats.blockNotesNew++; }
                    existing[name] = text;
                }
            }

            // Deletions: only delete if the name is NOT being added in this batch
            if (bnDels) {
                for (const name of bnDels) {
                    if (bnAdds?.has(name)) continue;
                    if (existing[name] !== undefined) {
                        if (options?.verbose) console.log(`  Delete block note: ${name}`);
                        delete existing[name];
                        deletedCount++;
                        stats.blockNotesDeleted++;
                    }
                }
            }

            if (newCount + updatedCount + deletedCount > 0) {
                const relPath = relative(projectRoot, filePath);
                const changes = formatChanges(newCount, updatedCount, deletedCount);
                if (options?.dryRun) {
                    console.log(`  [DRY] ${relPath}: ${changes}`);
                } else if (saveJsonFile(filePath, existing)) {
                    console.log(`  ${relPath}: ${changes}`);
                }
            }
        }

        // --- Part notes ---
        const pnAdds = partNotesByBank.get(bank);
        const pnDels = partNoteDeletions.get(bank);
        if (pnAdds || pnDels) {
            const filePath = join(notesDir, 'partNotes', bankFileName(bank));
            const existing = loadJsonFile(filePath);
            let newCount = 0, updatedCount = 0, deletedCount = 0;

            if (pnAdds) {
                for (const [name, text] of pnAdds) {
                    if (existing[name] === text) continue;
                    if (existing[name] !== undefined) { updatedCount++; stats.partNotesUpdated++; }
                    else { newCount++; stats.partNotesNew++; }
                    existing[name] = text;
                }
            }

            if (pnDels) {
                for (const name of pnDels) {
                    if (pnAdds?.has(name)) continue;
                    if (existing[name] !== undefined) {
                        if (options?.verbose) console.log(`  Delete part note: ${name}`);
                        delete existing[name];
                        deletedCount++;
                        stats.partNotesDeleted++;
                    }
                }
            }

            if (newCount + updatedCount + deletedCount > 0) {
                const relPath = relative(projectRoot, filePath);
                const changes = formatChanges(newCount, updatedCount, deletedCount);
                if (options?.dryRun) {
                    console.log(`  [DRY] ${relPath}: ${changes}`);
                } else if (saveJsonFile(filePath, existing)) {
                    console.log(`  ${relPath}: ${changes}`);
                }
            }
        }

        // --- Comments ---
        const cmAdds = commentsByBank.get(bank);
        const cmDels = commentDeletions.get(bank);
        if (cmAdds || cmDels) {
            const filePath = join(notesDir, 'comments', bankFileName(bank));
            const existing = loadJsonFile(filePath);
            let newCount = 0, updatedCount = 0, deletedCount = 0;

            if (cmAdds) {
                for (const [addr, text] of cmAdds) {
                    const key = addr.toString();
                    if (existing[key] === text) continue;
                    if (existing[key] !== undefined) { updatedCount++; stats.commentsUpdated++; }
                    else { newCount++; stats.commentsNew++; }
                    existing[key] = text;
                }
            }

            if (cmDels) {
                for (const addr of cmDels) {
                    const key = addr.toString();
                    if (cmAdds?.has(addr)) continue;
                    if (existing[key] !== undefined) {
                        if (options?.verbose) console.log(`  Delete comment: ${key}`);
                        delete existing[key];
                        deletedCount++;
                        stats.commentsDeleted++;
                    }
                }
            }

            if (newCount + updatedCount + deletedCount > 0) {
                const relPath = relative(projectRoot, filePath);
                const changes = formatChanges(newCount, updatedCount, deletedCount);
                if (options?.dryRun) {
                    console.log(`  [DRY] ${relPath}: ${changes}`);
                } else if (saveJsonFile(filePath, existing)) {
                    console.log(`  ${relPath}: ${changes}`);
                }
            }
        }
    }

    // Phase 4: Summary
    const totalChanges = stats.blockNotesNew + stats.blockNotesUpdated + stats.blockNotesDeleted
        + stats.partNotesNew + stats.partNotesUpdated + stats.partNotesDeleted
        + stats.commentsNew + stats.commentsUpdated + stats.commentsDeleted;

    console.log('\nSummary:');
    if (totalChanges === 0) {
        console.log('  No changes detected — notes/ is up to date.');
    } else {
        const bn = stats.blockNotesNew + stats.blockNotesUpdated + stats.blockNotesDeleted;
        const pn = stats.partNotesNew + stats.partNotesUpdated + stats.partNotesDeleted;
        const cm = stats.commentsNew + stats.commentsUpdated + stats.commentsDeleted;
        if (bn > 0) console.log(`  Block notes: ${formatChanges(stats.blockNotesNew, stats.blockNotesUpdated, stats.blockNotesDeleted)}`);
        if (pn > 0) console.log(`  Part notes:  ${formatChanges(stats.partNotesNew, stats.partNotesUpdated, stats.partNotesDeleted)}`);
        if (cm > 0) console.log(`  Comments:    ${formatChanges(stats.commentsNew, stats.commentsUpdated, stats.commentsDeleted)}`);
    }

    console.log(`\nIngestion ${options?.dryRun ? '(dry run) ' : ''}complete.`);
    return stats;
}
