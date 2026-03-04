/**
 * Generates jp/files.json from us/files.json with start addresses from the JP ROM
 * (decoded from binary_* labels in jp/groups.json), and replaces binary_* refs
 * in jp/groups.json with the matching US file names.
 *
 * 1. Load us/files.json and clone as base for jp/files.json
 * 2. Load jp/groups.json and us/groups.json
 * 3. For each JP asset with data starting with 'binary_*', find the matching US
 *    asset in the same scene (same type + meta, ignoring data and spritemap size)
 * 4. Map each binary_* -> US data label (file name) and decoded start address
 * 5. Replace all binary_* occurrences in jp groups with the file name
 * 6. Update jp files.json: set start to the decoded hex for each resolved file
 * 7. Write jp/files.json and jp/groups.json
 */

import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

interface Asset {
  type: string;
  data?: string;
  meta: Record<string, unknown>;
}

interface Scene {
  id: number;
  description: string;
  assets: Asset[];
}

interface Group {
  prefix: string;
  scenes: Record<string, Scene>;
}

type Groups = Record<string, Group>;

type FilesJson = Record<string, Record<string, Record<string, { start: number; end: number; type: string; compressed?: boolean; upper?: boolean }>>>;

const BINARY_PREFIX = 'binary_';

function isBinaryLabel(data: string | undefined): data is string {
  return typeof data === 'string' && data.startsWith(BINARY_PREFIX);
}

function decodeBinaryStart(binaryLabel: string): number {
  const hex = binaryLabel.slice(BINARY_PREFIX.length);
  return parseInt(hex, 16);
}

/** Normalize asset for comparison: type + meta, omitting data and spritemap size. */
function assetSignature(asset: Asset): string {
  const meta = { ...asset.meta };
  if (asset.type === 'spritemap' && 'size' in meta) {
    const { size: _, ...rest } = meta as { size?: number; [k: string]: unknown };
    return JSON.stringify({ type: asset.type, meta: rest });
  }
  return JSON.stringify({ type: asset.type, meta });
}

/** Build mapping: binary_* -> { usName, start } by matching JP/US scene assets. */
function buildBinaryToFileMapping(
  jpGroups: Groups,
  usGroups: Groups
): Map<string, { usName: string; start: number }> {
  const map = new Map<string, { usName: string; start: number }>();

  for (const groupKey of Object.keys(jpGroups)) {
    const usGroup = usGroups[groupKey];
    if (!usGroup) continue;

    const jpScenes = jpGroups[groupKey].scenes;
    const usScenes = usGroup.scenes;

    for (const sceneKey of Object.keys(jpScenes)) {
      const usScene = usScenes[sceneKey];
      if (!usScene) continue;

      const jpAssets = jpScenes[sceneKey].assets;
      const usAssets = usScene.assets;

      // JP assets with binary_* and their signatures
      const jpWithBinary: { index: number; binary: string; sig: string; type: string }[] = [];
      jpAssets.forEach((a, i) => {
        if (isBinaryLabel(a.data)) {
          jpWithBinary.push({ index: i, binary: a.data, sig: assetSignature(a), type: a.type });
        }
      });

      // US assets with resolved data (not binary_*) and their signatures
      const usWithData: { index: number; data: string; sig: string; type: string }[] = [];
      usAssets.forEach((a, i) => {
        if (a.data && !a.data.startsWith(BINARY_PREFIX)) {
          usWithData.push({ index: i, data: a.data, sig: assetSignature(a), type: a.type });
        }
      });

      // Track which US indices have been assigned (for fallback)
      const usUsed = new Set<number>();

      // First pass: exact signature match, pair by order within each signature group
      const bySig = new Map<string, { jp: typeof jpWithBinary; us: typeof usWithData }>();
      for (const j of jpWithBinary) {
        let entry = bySig.get(j.sig);
        if (!entry) {
          entry = { jp: [], us: [] };
          bySig.set(j.sig, entry);
        }
        entry.jp.push(j);
      }
      for (const u of usWithData) {
        let entry = bySig.get(u.sig);
        if (!entry) continue;
        entry.us.push(u);
      }

      for (const [, entry] of bySig) {
        entry.jp.sort((a, b) => a.index - b.index);
        entry.us.sort((a, b) => a.index - b.index);
        const len = Math.min(entry.jp.length, entry.us.length);
        for (let i = 0; i < len; i++) {
          const { binary } = entry.jp[i];
          const { index: usIdx, data: usName } = entry.us[i];
          if (map.has(binary)) continue;
          map.set(binary, { usName, start: decodeBinaryStart(binary) });
          usUsed.add(usIdx);
        }
      }

      // Second pass: for any JP binary_ still unmapped, match by type only (first unused US asset of same type)
      for (const j of jpWithBinary.sort((a, b) => a.index - b.index)) {
        if (map.has(j.binary)) continue;
        const candidate = usWithData.find((u) => u.type === j.type && !usUsed.has(u.index));
        if (candidate) {
          map.set(j.binary, { usName: candidate.data, start: decodeBinaryStart(j.binary) });
          usUsed.add(candidate.index);
        }
      }
    }
  }

  return map;
}

/** Replace every asset.data that is a key in the mapping with the corresponding usName. */
function replaceBinaryLabelsInGroups(jpGroups: Groups, mapping: Map<string, { usName: string; start: number }>): void {
  for (const group of Object.values(jpGroups)) {
    for (const scene of Object.values(group.scenes)) {
      for (const asset of scene.assets) {
        if (asset.data && mapping.has(asset.data)) {
          asset.data = mapping.get(asset.data)!.usName;
        }
      }
    }
  }
}

/** Format files.json with each file record on a single line (same style as us/files.json). */
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

/** Update every file record whose key matches fileName to use the given start. */
function setFileStart(files: FilesJson, fileName: string, start: number): void {
  for (const loc of Object.values(files)) {
    for (const sub of Object.values(loc)) {
      if (fileName in sub && typeof sub[fileName].start === 'number') {
        sub[fileName].start = start;
      }
    }
  }
}

/** Format groups JSON with one asset per line (same style as generate-jp-groups). */
function formatGroupsJson(groups: Groups): string {
  const lines: string[] = ['{'];

  const groupKeys = Object.keys(groups);
  groupKeys.forEach((groupKey, gIndex) => {
    const group = groups[groupKey];
    lines.push(`  "${groupKey}": {`);
    lines.push(`    "prefix": "${group.prefix}",`);
    lines.push(`    "scenes": {`);

    const sceneKeys = Object.keys(group.scenes);
    sceneKeys.forEach((sceneKey, sIndex) => {
      const scene = group.scenes[sceneKey];
      lines.push(`      "${sceneKey}": {`);
      lines.push(`        "id": ${scene.id},`);
      lines.push(`        "description": "${scene.description}",`);
      lines.push(`        "assets": [`);

      scene.assets.forEach((asset, aIndex) => {
        const assetJson = JSON.stringify(asset);
        const comma = aIndex < scene.assets.length - 1 ? ',' : '';
        lines.push(`          ${assetJson}${comma}`);
      });

      const sceneComma = sIndex < sceneKeys.length - 1 ? ',' : '';
      lines.push(`        ]`);
      lines.push(`      }${sceneComma}`);
    });

    const groupComma = gIndex < groupKeys.length - 1 ? ',' : '';
    lines.push(`    }`);
    lines.push(`  }${groupComma}`);
  });

  lines.push('}');
  return lines.join('\n');
}

function main(): void {
  const root = process.cwd();
  const usFilesPath = join(root, 'us', 'files.json');
  const usGroupsPath = join(root, 'us', 'groups.json');
  const jpGroupsPath = join(root, 'jp', 'groups.json');
  const jpFilesPath = join(root, 'jp', 'files.json');

  const usFiles: FilesJson = JSON.parse(readFileSync(usFilesPath, 'utf-8'));
  const usGroups: Groups = JSON.parse(readFileSync(usGroupsPath, 'utf-8'));
  const jpGroups: Groups = JSON.parse(readFileSync(jpGroupsPath, 'utf-8'));

  const mapping = buildBinaryToFileMapping(jpGroups, usGroups);

  const jpFiles: FilesJson = JSON.parse(JSON.stringify(usFiles));
  const fileStarts = new Map<string, number>();
  for (const [, { usName, start }] of mapping) {
    if (!fileStarts.has(usName)) fileStarts.set(usName, start);
  }
  for (const [usName, start] of fileStarts) {
    setFileStart(jpFiles, usName, start);
  }

  replaceBinaryLabelsInGroups(jpGroups, mapping);

  writeFileSync(jpFilesPath, formatFilesJson(jpFiles) + '\n');
  writeFileSync(jpGroupsPath, formatGroupsJson(jpGroups));

  console.log('Generated jp/files.json (same structure as US, start values from JP binary_* labels).');
  console.log('Updated jp/groups.json (binary_* replaced with file names).');
  console.log(`Resolved ${mapping.size} binary labels.`);
}

main();
