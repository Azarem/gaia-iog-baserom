/**
 * One-off: rewrite a files.json so each file record is on a single line
 * (same style as us/files.json). Default input/output: jp/files.json
 */

import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

type FileRecord = { start: number; end: number; type: string; compressed?: boolean; upper?: boolean };
type FilesJson = Record<string, Record<string, Record<string, FileRecord>>>;

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
  const path = process.argv[2] ?? join(process.cwd(), 'jp', 'files.json');
  const files: FilesJson = JSON.parse(readFileSync(path, 'utf-8'));
  writeFileSync(path, formatFilesJson(files) + '\n');
  console.log(`Formatted ${path} (one line per file record).`);
}

main();
