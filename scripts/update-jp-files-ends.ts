/**
 * Updates jp/files.json with computed "end" values for each file record.
 *
 * For each file:
 * - Find the file with the nearest subsequent 'start' (across all groups/scenes).
 * - Set this file's 'end' to min(next_start, next_bank_boundary).
 * - Bank boundaries are every 0x8000 bytes; a file must not cross a bank.
 *
 * Output: jp/files.json with each file record on its own line.
 */

import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

const BANK_SIZE = 0x8000;

type FileRecord = {
  start: number;
  end: number;
  type: string;
  compressed?: boolean;
  upper?: boolean;
};

type FilesJson = Record<string, Record<string, Record<string, FileRecord>>>;

/** Next 0x8000 boundary after (or at) address. */
function nextBankBoundary(address: number): number {
  return Math.floor(address / BANK_SIZE + 1) * BANK_SIZE;
}

/** Collect all file records with their start, and sort starts for lookup. */
function collectRecords(files: FilesJson): { record: FileRecord; start: number }[] {
  const entries: { record: FileRecord; start: number }[] = [];
  for (const group of Object.values(files)) {
    for (const scene of Object.values(group)) {
      for (const record of Object.values(scene)) {
        if (typeof record.start === 'number') {
          entries.push({ record, start: record.start });
        }
      }
    }
  }
  return entries;
}

/** Sorted unique start addresses (ascending). */
function sortedStarts(entries: { start: number }[]): number[] {
  const set = new Set(entries.map((e) => e.start));
  return [...set].sort((a, b) => a - b);
}

/** For a given start, return the next start in the list, or null if last. */
function nextStart(start: number, sorted: number[]): number | null {
  const i = sorted.indexOf(start);
  if (i < 0 || i === sorted.length - 1) return null;
  return sorted[i + 1];
}

/** Compute end for a record: min(next start, next bank boundary). */
function computeEnd(start: number, next: number | null): number {
  const boundary = nextBankBoundary(start);
  if (next === null) return boundary;
  return Math.min(next, boundary);
}

/** Format files.json with each file record on a single line. */
function formatFilesJson(files: FilesJson): string {
  const lines: string[] = ['{'];
  const locKeys = Object.keys(files);
  locKeys.forEach((locKey, locIndex) => {
    lines.push(`    "${locKey}": {`);
    const sub = files[locKey];
    const subKeys = Object.keys(sub);
    subKeys.forEach((subKey, subIndex) => {
      lines.push(`        "${subKey}": {`);
      const records = sub[subKey];
      const recordKeys = Object.keys(records);
      recordKeys.forEach((name, recIndex) => {
        const record = records[name];
        const recordJson = JSON.stringify(record);
        const comma = recIndex < recordKeys.length - 1 ? ',' : '';
        lines.push(`            "${name}": ${recordJson}${comma}`);
      });
      const subComma = subIndex < subKeys.length - 1 ? ',' : '';
      lines.push(`        }${subComma}`);
    });
    const locComma = locIndex < locKeys.length - 1 ? ',' : '';
    lines.push(`    }${locComma}`);
  });
  lines.push('}');
  return lines.join('\n');
}

function main(): void {
  const root = process.cwd();
  const jpFilesPath = join(root, 'jp', 'files.json');

  const files: FilesJson = JSON.parse(readFileSync(jpFilesPath, 'utf-8'));
  const entries = collectRecords(files);
  const sorted = sortedStarts(entries);

  for (const { record, start } of entries) {
    const next = nextStart(start, sorted);
    record.end = computeEnd(start, next);
  }

  writeFileSync(jpFilesPath, formatFilesJson(files) + '\n');

  console.log(`Updated jp/files.json: set end for ${entries.length} file records (bank size 0x${BANK_SIZE.toString(16)}).`);
}

main();
