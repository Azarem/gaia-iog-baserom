// Build dmap_inventory_bg.dmp from a mapper tileset (.set) and one 1x1-block tilemap (.map) per
// screen: the reverse of dmap-to-tilemaps.ts.
//
// Usage (from the gaia-iog-baserom root):
//   node scripts/tilemaps-to-dmap.ts [--dir <dir>] [--out <file.dmp>] [--verify <original.dmp>]
//                                    [--set <file.set>] [--maps <a.map,b.map,...>] [--header <hex8>]
//
//   --dir     folder with the converted files and dmap_inventory_bg.layout.json
//             (default temp/dmap-inventory-bg)
//   --out     output file (default <dir>/dmap_inventory_bg.dmp; NOT extracted/, which extract wipes)
//   --verify  compare the result with this dmp and exit non-zero when it differs
//   --set     tileset file, overrides the layout (relative paths are resolved against --dir)
//   --maps    comma separated tilemap files in screen order, overrides the layout
//   --header  the 4 dmap header bytes as hex (e.g. 00020002), overrides the layout; without a
//             layout file it is required. The header must describe exactly as many screens as
//             there are maps: (b0|b3) * (b1|b2).
//
// Each map must be exactly 1x1 block. An edited tileset is accepted as long as the metatiles the
// maps use leave tile bit 9 / the block flag clear (a dmap tilemap entry has no such flag).
// The output is the uncompressed extracted form: 4 header bytes + the screens. The rebuild
// recompresses it (or stores it raw with the MenuBGLoad patch). Format: docs/dmap-inventory-bg.md.

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, isAbsolute, join, resolve } from 'node:path';
import {
  bytesEqual,
  decodeTilemap,
  decodeTileset,
  hex,
  joinScreens,
  parseHex,
  serializeDmap,
} from './lib/dmap-tilemaps.ts';
import type { LayoutFile } from './lib/dmap-tilemaps.ts';

const ROOT = resolve(import.meta.dirname, '..');
const LAYOUT_NAME = 'dmap_inventory_bg.layout.json';

interface Options {
  dir: string;
  out: string | null;
  verify: string | null;
  set: string | null;
  maps: string[] | null;
  header: string | null;
}

function parseArgs(argv: string[]): Options {
  const opts: Options = {
    dir: join(ROOT, 'temp', 'dmap-inventory-bg'),
    out: null,
    verify: null,
    set: null,
    maps: null,
    header: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const value = (): string => {
      const v = argv[++i];
      if (v === undefined) throw new Error(`${arg} needs a value`);
      return v;
    };
    if (arg === '--dir') opts.dir = resolve(value());
    else if (arg === '--out') opts.out = resolve(value());
    else if (arg === '--verify') opts.verify = resolve(value());
    else if (arg === '--set') opts.set = value();
    else if (arg === '--maps') opts.maps = value().split(',').map((s) => s.trim()).filter(Boolean);
    else if (arg === '--header') opts.header = value();
    else throw new Error(`Unknown argument "${arg}"`);
  }
  return opts;
}

function main(): void {
  const opts = parseArgs(process.argv.slice(2));
  const at = (file: string): string => (isAbsolute(file) ? file : join(opts.dir, file));

  const layoutPath = join(opts.dir, LAYOUT_NAME);
  const layout: LayoutFile | null = existsSync(layoutPath)
    ? (JSON.parse(readFileSync(layoutPath, 'utf8')) as LayoutFile)
    : null;

  const setFile = opts.set ?? layout?.tileset;
  const mapFiles = opts.maps ?? layout?.screens.slice().sort((a, b) => a.index - b.index).map((s) => s.map);
  const headerHex = opts.header ?? layout?.header;
  if (!setFile || !mapFiles || !headerHex) {
    throw new Error(
      `No ${LAYOUT_NAME} in ${opts.dir}: give --set, --maps and --header (or run dmap-to-tilemaps.ts first)`,
    );
  }

  const header = parseHex(headerHex);
  const tileset = decodeTileset(new Uint8Array(readFileSync(at(setFile))));
  const blocks = mapFiles.map((f) => decodeTilemap(new Uint8Array(readFileSync(at(f))), f));
  const dmap = serializeDmap(header, joinScreens(tileset, blocks, mapFiles));

  const out = opts.out ?? join(opts.dir, 'dmap_inventory_bg.dmp');
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, dmap);

  console.log(`Tileset: ${at(setFile)}`);
  mapFiles.forEach((f, i) => console.log(`  screen ${i}: ${at(f)}`));
  console.log(`Output : ${out} (${dmap.length} bytes, header ${hex(header)}, ${blocks.length} screens)`);

  if (opts.verify) {
    const original = new Uint8Array(readFileSync(opts.verify));
    if (bytesEqual(original, dmap)) {
      console.log(`Verify : identical to ${opts.verify}`);
    } else {
      let first = -1;
      for (let i = 0; i < Math.min(original.length, dmap.length); i++) {
        if (original[i] !== dmap[i]) { first = i; break; }
      }
      console.error(
        `Verify : DIFFERS from ${opts.verify} (sizes ${original.length}/${dmap.length}, first differing byte ${first})`,
      );
      process.exitCode = 1;
    }
  }
}

try {
  main();
} catch (error) {
  console.error(`Error: ${(error as Error).message}`);
  process.exitCode = 1;
}
