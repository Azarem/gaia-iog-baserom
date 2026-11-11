// Convert dmap_inventory_bg.dmp into standard gaia-mapper assets:
//   one shared tileset (.set) built from all four screens + one 1x1-block tilemap (.map) per screen.
//
// Usage (from the gaia-iog-baserom root):
//   node scripts/dmap-to-tilemaps.ts [--in <file.dmp>] [--out <dir>]
//
//   --in   default extracted/system/inventory/dmap_inventory_bg.dmp
//   --out  default temp/dmap-inventory-bg   (NOT extracted/: extract wipes that folder)
//
// Outputs in <out>:
//   set_inventory_bg.set                shared tileset (2048 bytes)
//   map_inventory_bg_status.map         screen 0, BG1 Status      (VRAM word $0000)
//   map_inventory_bg_items.map          screen 1, BG1 Items       (VRAM word $0400)
//   map_inventory_bg_statue.map         screen 2, BG1 statue scene(VRAM word $0800)
//   map_inventory_bg_water.map          screen 3, BG2 water       (VRAM word $0C00)
//   dmap_inventory_bg.layout.json       header bytes + screen order, read by tilemaps-to-dmap.ts
//
// The conversion is lossless: the result is rebuilt in memory from the files just written and
// must match the input byte for byte, otherwise the script fails.
// Reverse: node scripts/tilemaps-to-dmap.ts. Format: docs/dmap-inventory-bg.md.

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import {
  bytesEqual,
  decodeTilemap,
  decodeTileset,
  encodeTilemap,
  encodeTileset,
  hex,
  joinScreens,
  parseDmap,
  serializeDmap,
  splitScreens,
  SCREEN_ROLES,
} from './lib/dmap-tilemaps.ts';
import type { LayoutFile } from './lib/dmap-tilemaps.ts';

const ROOT = resolve(import.meta.dirname, '..');
const MAP_NAMES = ['status', 'items', 'statue', 'water'];
const TILESET_NAME = 'set_inventory_bg.set';
const LAYOUT_NAME = 'dmap_inventory_bg.layout.json';

function parseArgs(argv: string[]): { input: string; out: string } {
  let input = join(ROOT, 'extracted', 'system', 'inventory', 'dmap_inventory_bg.dmp');
  let out = join(ROOT, 'temp', 'dmap-inventory-bg');
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--in') input = resolve(argv[++i] ?? '');
    else if (arg === '--out') out = resolve(argv[++i] ?? '');
    else throw new Error(`Unknown argument "${arg}" (use --in <file.dmp> --out <dir>)`);
  }
  return { input, out };
}

function mapFileName(index: number): string {
  return `map_inventory_bg_${MAP_NAMES[index] ?? `screen${index}`}.map`;
}

function main(): void {
  const { input, out } = parseArgs(process.argv.slice(2));
  const original = new Uint8Array(readFileSync(input));
  const dmap = parseDmap(original);

  const { metatiles, maps } = splitScreens(dmap.screens);
  mkdirSync(out, { recursive: true });

  const layout: LayoutFile = {
    source: basename(input),
    header: hex(dmap.header),
    tileset: TILESET_NAME,
    screens: maps.map((_, index) => ({
      index,
      vramWord: `$${(index * 0x400).toString(16).toUpperCase().padStart(4, '0')}`,
      role: SCREEN_ROLES[index] ?? `screen ${index}`,
      map: mapFileName(index),
    })),
  };

  const tileset = encodeTileset(metatiles);
  writeFileSync(join(out, TILESET_NAME), tileset);
  maps.forEach((block, index) => writeFileSync(join(out, mapFileName(index)), encodeTilemap(block)));
  writeFileSync(join(out, LAYOUT_NAME), JSON.stringify(layout, null, 2) + '\n');

  // Self-check: rebuild from the files on disk and compare with the input.
  const diskSet = decodeTileset(new Uint8Array(readFileSync(join(out, TILESET_NAME))));
  const diskMaps = layout.screens.map((s) => decodeTilemap(new Uint8Array(readFileSync(join(out, s.map))), s.map));
  const rebuilt = serializeDmap(dmap.header, joinScreens(diskSet, diskMaps, layout.screens.map((s) => s.map)));
  if (!bytesEqual(rebuilt, original)) {
    throw new Error('Round-trip mismatch: the rebuilt dmap differs from the input (this is a bug)');
  }

  console.log(`Input  : ${input} (${original.length} bytes, header ${layout.header}, ${maps.length} screens)`);
  console.log(`Output : ${out}`);
  console.log(`  ${TILESET_NAME}: ${metatiles.length} of 256 metatiles used (index 0 = empty)`);
  layout.screens.forEach((s) => {
    const used = new Set(maps[s.index]).size;
    console.log(`  ${s.map}: ${used} distinct metatiles  [${s.role}, VRAM word ${s.vramWord}]`);
  });
  console.log('Round trip: rebuilt dmap is byte-identical to the input.');
}

try {
  main();
} catch (error) {
  console.error(`Error: ${(error as Error).message}`);
  process.exitCode = 1;
}
