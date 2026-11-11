// Shared model for converting dmap_inventory_bg.dmp (preformatted BG tilemap screens)
// to and from gaia-mapper's standard tileset (.set) and tilemap (.map) assets.
//
// See docs/dmap-inventory-bg.md for the dmap format.
//
// dmap file : [00 W 00 H] header, then W*H screens of 32x32 hardware tilemap words
//             (2048 bytes each, little-endian u16, row-major: index = row * 32 + col).
//             Entry bits: 0-9 tile, 10-12 palette, 13 priority, 14 H-flip, 15 V-flip.
// .set file : 2048 bytes = 1024 u16 entries = 256 metatiles x [TL, TR, BL, BR].
//             Entry bits: 0-8 tile, 9 block flag, 10-12 palette, 13 priority, 14 H, 15 V.
// .map file : [u8 width][u8 height] then width*height blocks of 256 bytes; a block is a
//             16x16 grid of metatile indices (row-major). One block = 256x256 px = one
//             dmap screen, so every screen becomes a 1x1 map.
//
// A dmap entry and a tileset entry differ only in bit 9 (tile bit vs block flag), so
// entries are copied verbatim as long as bit 9 is clear.

export const HEADER_SIZE = 4;
export const SCREEN_TILES = 32;
export const SCREEN_ENTRIES = SCREEN_TILES * SCREEN_TILES;
export const SCREEN_BYTES = SCREEN_ENTRIES * 2;

export const METATILE_COUNT = 256;
export const TILESET_BYTES = METATILE_COUNT * 4 * 2;
export const MAP_BLOCK_BYTES = 256;
export const MAP_FILE_BYTES = 2 + MAP_BLOCK_BYTES;

/** Entry bit 9: tile bit in a dmap, block (collision) flag in a mapper tileset. */
const BIT9 = 0x0200;

/** Top-left, top-right, bottom-left, bottom-right entries of one 16x16 metatile. */
export type Metatile = [number, number, number, number];

export interface Dmap {
  /** The 4 raw header bytes, preserved verbatim. */
  header: Uint8Array;
  screens: Uint16Array[];
}

/** Number of screens the engine derives from a header: (b0|b3) * (b1|b2). */
export function headerScreenCount(header: Uint8Array): number {
  return (header[0] | header[3]) * (header[1] | header[2]);
}

export function hex(bytes: Uint8Array): string {
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}

export function parseHex(text: string): Uint8Array {
  const clean = text.replace(/[\s$]/g, '');
  if (!/^([0-9a-fA-F]{2})+$/.test(clean)) throw new Error(`Invalid hex string "${text}"`);
  const out = new Uint8Array(clean.length / 2);
  for (let i = 0; i < out.length; i++) out[i] = parseInt(clean.substr(i * 2, 2), 16);
  return out;
}

export function parseDmap(buf: Uint8Array): Dmap {
  if (buf.length < HEADER_SIZE) throw new Error('dmap is shorter than its 4-byte header');
  const header = buf.slice(0, HEADER_SIZE);
  const count = headerScreenCount(header);
  const expected = HEADER_SIZE + count * SCREEN_BYTES;
  if (count === 0 || buf.length !== expected) {
    throw new Error(
      `dmap header ${hex(header)} describes ${count} screen(s) = ${expected} bytes, file is ${buf.length} bytes`,
    );
  }
  const view = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  const screens: Uint16Array[] = [];
  for (let s = 0; s < count; s++) {
    const screen = new Uint16Array(SCREEN_ENTRIES);
    const base = HEADER_SIZE + s * SCREEN_BYTES;
    for (let i = 0; i < SCREEN_ENTRIES; i++) screen[i] = view.getUint16(base + i * 2, true);
    screens.push(screen);
  }
  return { header, screens };
}

export function serializeDmap(header: Uint8Array, screens: Uint16Array[]): Uint8Array {
  if (header.length !== HEADER_SIZE) throw new Error('dmap header must be 4 bytes');
  const count = headerScreenCount(header);
  if (screens.length !== count) {
    throw new Error(`dmap header ${hex(header)} needs ${count} screen(s), got ${screens.length} map(s)`);
  }
  const out = new Uint8Array(HEADER_SIZE + count * SCREEN_BYTES);
  out.set(header, 0);
  const view = new DataView(out.buffer);
  screens.forEach((screen, s) => {
    const base = HEADER_SIZE + s * SCREEN_BYTES;
    for (let i = 0; i < SCREEN_ENTRIES; i++) view.setUint16(base + i * 2, screen[i], true);
  });
  return out;
}

function patternKey(m: Metatile): string {
  return m.join(',');
}

export interface SplitResult {
  /** Distinct aligned 2x2 patterns; index 0 is always the all-zero (empty) pattern. */
  metatiles: Metatile[];
  /** One 256-byte metatile-index block per screen. */
  maps: Uint8Array[];
}

/**
 * Cut every screen into aligned 2x2 patterns and build one shared metatile list.
 * Patterns are numbered in first-seen order (screens in order, row-major), with the
 * empty pattern fixed at index 0.
 */
export function splitScreens(screens: Uint16Array[]): SplitResult {
  const metatiles: Metatile[] = [[0, 0, 0, 0]];
  const index = new Map<string, number>([[patternKey(metatiles[0]), 0]]);
  const maps: Uint8Array[] = [];

  screens.forEach((screen, s) => {
    const map = new Uint8Array(MAP_BLOCK_BYTES);
    for (let my = 0; my < 16; my++) {
      for (let mx = 0; mx < 16; mx++) {
        const tl = (my * 2) * SCREEN_TILES + mx * 2;
        const bl = tl + SCREEN_TILES;
        const m: Metatile = [screen[tl], screen[tl + 1], screen[bl], screen[bl + 1]];
        for (const entry of m) {
          if (entry & BIT9) {
            throw new Error(
              `screen ${s}: entry $${entry.toString(16).padStart(4, '0')} uses tile bit 9 ($0200), ` +
              'which a mapper tileset reads as the block flag; cannot convert losslessly',
            );
          }
        }
        const key = patternKey(m);
        let id = index.get(key);
        if (id === undefined) {
          id = metatiles.length;
          if (id >= METATILE_COUNT) {
            throw new Error(`more than ${METATILE_COUNT} distinct 2x2 patterns (screen ${s}); a tileset holds ${METATILE_COUNT}`);
          }
          metatiles.push(m);
          index.set(key, id);
        }
        map[my * 16 + mx] = id;
      }
    }
    maps.push(map);
  });

  return { metatiles, maps };
}

/** 2048-byte tileset; metatiles beyond the list are zero. */
export function encodeTileset(metatiles: Metatile[]): Uint8Array {
  if (metatiles.length > METATILE_COUNT) throw new Error(`tileset holds at most ${METATILE_COUNT} metatiles`);
  const out = new Uint8Array(TILESET_BYTES);
  const view = new DataView(out.buffer);
  metatiles.forEach((m, i) => {
    for (let q = 0; q < 4; q++) view.setUint16((i * 4 + q) * 2, m[q], true);
  });
  return out;
}

export function decodeTileset(buf: Uint8Array): Metatile[] {
  if (buf.length !== TILESET_BYTES) throw new Error(`tileset must be ${TILESET_BYTES} bytes, got ${buf.length}`);
  const view = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  const out: Metatile[] = [];
  for (let i = 0; i < METATILE_COUNT; i++) {
    out.push([0, 1, 2, 3].map((q) => view.getUint16((i * 4 + q) * 2, true)) as Metatile);
  }
  return out;
}

/** A 1x1-block tilemap file: [01][01] + 256 metatile indices. */
export function encodeTilemap(block: Uint8Array): Uint8Array {
  if (block.length !== MAP_BLOCK_BYTES) throw new Error(`tilemap block must be ${MAP_BLOCK_BYTES} bytes`);
  const out = new Uint8Array(MAP_FILE_BYTES);
  out[0] = 1;
  out[1] = 1;
  out.set(block, 2);
  return out;
}

export function decodeTilemap(buf: Uint8Array, name: string): Uint8Array {
  if (buf.length < 2) throw new Error(`${name}: tilemap is shorter than its 2-byte header`);
  if (buf[0] !== 1 || buf[1] !== 1) {
    throw new Error(
      `${name}: tilemap is ${buf[0]}x${buf[1]} blocks; a dmap screen is exactly 1x1 block (256x256 px)`,
    );
  }
  if (buf.length < MAP_FILE_BYTES) {
    throw new Error(`${name}: tilemap has ${buf.length - 2} data bytes, needs ${MAP_BLOCK_BYTES}`);
  }
  return buf.slice(2, MAP_FILE_BYTES);
}

/**
 * Expand each map block back into a 32x32 hardware tilemap screen. Only metatiles that a map
 * actually references are validated (an edited tileset may keep unrelated entries with the
 * block flag set).
 */
export function joinScreens(metatiles: Metatile[], blocks: Uint8Array[], names: string[]): Uint16Array[] {
  return blocks.map((block, s) => {
    const screen = new Uint16Array(SCREEN_ENTRIES);
    for (let my = 0; my < 16; my++) {
      for (let mx = 0; mx < 16; mx++) {
        const id = block[my * 16 + mx];
        const m = metatiles[id];
        for (const entry of m) {
          if (entry & BIT9) {
            throw new Error(
              `${names[s]}: metatile ${id} (cell ${mx},${my}) has the block flag / tile bit 9 set ` +
              `(entry $${entry.toString(16).padStart(4, '0')}); a dmap tilemap entry has no such flag`,
            );
          }
        }
        const tl = (my * 2) * SCREEN_TILES + mx * 2;
        const bl = tl + SCREEN_TILES;
        screen[tl] = m[0];
        screen[tl + 1] = m[1];
        screen[bl] = m[2];
        screen[bl + 1] = m[3];
      }
    }
    return screen;
  });
}

export function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

/** Display names for the four screens of dmap_inventory_bg. */
export const SCREEN_ROLES = ['BG1 Status', 'BG1 Items', 'BG1 Statue scene ($FD)', 'BG2 water'];

export interface LayoutFile {
  /** Name of the dmap the files were cut from. */
  source: string;
  /** The 4 header bytes as hex, e.g. "00020002". */
  header: string;
  tileset: string;
  screens: { index: number; vramWord: string; role: string; map: string }[];
}
