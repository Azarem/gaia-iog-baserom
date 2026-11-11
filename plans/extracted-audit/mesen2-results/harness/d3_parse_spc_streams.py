#!/usr/bin/env python3
"""D3 static transfer parse (read-only): OQ-I022-2.

Reads the original ROM (rebuilt/Illusion of Gaia.smc, tag O) and reproduces what
SpcBlockTransfer (ROM offset 168091) does with each music stream, without running
an emulator and without writing anything except stdout:

  * music_pointer_array (ROM offset 117670, 30 x [addr lo, addr hi, bank]) ->
    stream offsets ((bank & $3F) << 16 | addr);
  * session 1 records [size][ARAM dest][size bytes] up to the size-0 terminator
    (SpcIplHandshake); the terminator's destination word is the $2E seed;
  * session 2: count byte, count index bytes (bit 7 = empty slot), chunk library
    at $C5:0000 walked exactly like SpcFindChunk (size word, skip by size, wrap of
    the pointer $4A at $8000 into the next bank); running destination
    $2E += previous chunk size ($2C) before each non-empty chunk;
  * checks: terminator word vs the highest end of the song records, vs the word
    stored in the $0FFE record, and vs the ARAM sample directory (entries at
    $1038 / $1000: start words must equal the computed chunk destinations).

Usage: python d3_parse_spc_streams.py [--rom PATH] [--verbose]
"""
import argparse
import hashlib
import sys

ROM_DEFAULT = r"C:\Work\gaia-iog-baserom\rebuilt\Illusion of Gaia.smc"
PTR_ARRAY = 117670
PTR_COUNT = 30
LIB_BANK = 0xC5

# files.json starts of the Music files that the pointer array does not reference
EXTRA = {
    "bgm_illusion_of_gaia": 1118771,
    "bgm_restart": 1514668,
    "bgm_1D4F6B": 1920875,
}

NAMES = {  # music_pointer_array order (extracted/system/music_pointer_array.asm), entry = ID - 1
    0: "lively_city", 1: "lively_city", 2: "blessing_of_nature", 3: "ominous_whispers",
    4: "royal_anthem", 5: "descent_into_darkness", 6: "awakening_the_wind",
    7: "secret_of_nazca", 8: "legendary_sunken_continent", 9: "golden_road",
    10: "unexplored_temple", 11: "great_pyramid", 12: "lively_city",
    13: "longing_for_the_past", 14: "guardians", 15: "threat_of_dark_gaia",
    16: "deep_sadness", 17: "beautiful_world", 18: "bittersweet_victory", 19: "rebirth",
    20: "drifting_endlessly", 21: "space_beyond_time", 22: "lively_city",
    23: "important_item", 24: "lolas_melody", 25: "lost_incan_melody", 26: "no_music",
    27: "lively_city_by_the_sea", 28: "waterfall", 29: "melody_of_memories",
}


def w(rom, off):
    return rom[off] | (rom[off + 1] << 8)


def lib_off(bank, addr):
    return ((bank - 0xC0) << 16) | addr


LIB_CHUNKS = 61  # indices 0-60 (header comment of spc_transfer.asm; the walk below confirms it)


def walk_library(rom):
    """Sequential walk of the library as laid out: [size][data] back to back in 32 KB pages.
    Returns list of (index, size, dataBank, dataAddr) for the LIB_CHUNKS chunks."""
    out = []
    a4a, bank = 0, LIB_BANK
    for idx in range(0, LIB_CHUNKS):
        size = w(rom, lib_off(bank, a4a))
        a4a += 2
        out.append((idx, size, bank, a4a))
        a4a = (a4a + size) & 0xFFFF
        if a4a & 0x8000:
            a4a &= 0x7FFF
            bank += 1
    return out


def find_chunk(rom, wanted):
    """Exact SpcFindChunk: returns (size, bank, y_start, flags)."""
    a4a, bank, a2a = 0, LIB_BANK, wanted
    flags = []
    while True:
        if a4a >= 0x7FFF:
            flags.append("size word at page end")
        size = w(rom, lib_off(bank, a4a))
        a4a = (a4a + 2) & 0xFFFF
        if a2a == 0:
            if a4a & 0x8000:
                flags.append("Y >= $8000 at chunk start")
            return size, bank, a4a, flags
        a2a -= 1
        s = a4a + size
        if s > 0xFFFF:
            flags.append("$4A overflow")
        a4a = s & 0xFFFF
        if a4a & 0x8000:
            a4a &= 0x7FFF
            bank += 1


def parse_stream(rom, off):
    pos = off
    recs = []
    while True:
        size = w(rom, pos)
        dest = w(rom, pos + 2)
        pos += 4
        if size == 0:
            term = dest
            term_off = pos - 2
            break
        recs.append((size, dest, pos))
        pos += size
    count = rom[pos]
    idx = list(rom[pos + 1: pos + 1 + count])
    end = pos + 1 + count
    return recs, term, term_off, count, idx, pos, end


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default=ROM_DEFAULT)
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()
    rom = open(a.rom, "rb").read()
    print("ROM %s size %d sha1 %s" % (a.rom, len(rom), hashlib.sha1(rom).hexdigest()))

    import re, os
    fj = os.path.join(os.path.dirname(os.path.abspath(a.rom)), "..", "db-us", "files.json")
    nm_files = {}
    if os.path.exists(fj):
        for m in re.finditer(r'"bgm_(\w+)": \{"start":(\d+)', open(fj, encoding="utf-8").read()):
            nm_files[m.group(1)] = int(m.group(2))
    lib = walk_library(rom)
    print("LIBRARY C5:0000 = ROM 0x%X: %d chunks, last index %d, last chunk ends bank $%02X addr $%04X; sizes total %d"
          % (lib_off(LIB_BANK, 0), len(lib), lib[-1][0], lib[-1][2], (lib[-1][3] + lib[-1][1]) & 0xFFFF,
             sum(c[1] for c in lib)))
    # SpcFindChunk agrees with the sequential walk for every index
    bad = [i for i, s, b, ad in lib if find_chunk(rom, i)[:3] != (s, b, ad)]
    print("SpcFindChunk == sequential walk for all %d indices: %s" % (len(lib), "yes" if not bad else "NO %s" % bad))
    flagged = [(i, find_chunk(rom, i)[3]) for i, *_ in lib if find_chunk(rom, i)[3]]
    print("find_chunk edge flags: %s" % (flagged if flagged else "none"))
    nb = [(i, s) for i, s, b, ad in lib if s % 9]
    print("chunks whose size is not a multiple of 9 (BRR block size): %s" % (nb if nb else "none"))
    print()

    entries = []
    for i in range(PTR_COUNT):
        lo, hi, bk = rom[PTR_ARRAY + 3 * i: PTR_ARRAY + 3 * i + 3]
        entries.append(("%02X" % (i + 1), NAMES[i], ((bk & 0x3F) << 16) | (hi << 8) | lo))
    seen = set()
    todo = []
    for idn, nm, off in entries:
        if off in seen:
            continue
        seen.add(off)
        todo.append((idn, nm, off))
    for nm, off in EXTRA.items():
        if off not in seen:
            todo.append(("--", nm.replace("bgm_", ""), off))
    print("distinct streams: %d (%d from the pointer array, %d files not in the array)" % (
        len(todo), len(todo) - len(EXTRA), len(EXTRA)))
    print()
    hdr = ("ID  name                        stream     recs  highEnd  T(term)  FFE   T==highEnd  cnt  chunks(non-empty)  dir  dirStarts==dests  lastEnd  flags")
    print(hdr)
    allok = True
    used = set()
    for idn, nm, off in todo:
        recs, term, term_off, count, idx, cpos, end = parse_stream(rom, off)
        high_end = max(d + s for s, d, _ in recs)
        high_rec = max(recs, key=lambda r: r[1])
        ffe = None
        ffc = None
        dir_base = None
        dir_bytes = None
        for s, d, p in recs:
            if d == 0x0FFE and s == 2:
                ffe = w(rom, p)
            if d == 0x0FFC and s == 2:
                ffc = w(rom, p)
            if d in (0x1038, 0x1000):
                dir_base = d
                dir_bytes = rom[p:p + s]
        # session 2
        dest = term
        prev = 0
        chunks = []
        fl = []
        for j, ix in enumerate(idx):
            if ix & 0x80:
                chunks.append((j, ix, None, None))
                continue
            dest = dest + prev
            size, bank, y, f = find_chunk(rom, ix)
            fl += f
            chunks.append((j, ix, dest, size))
            prev = size
        real = [c for c in chunks if c[2] is not None]
        used.update(c[1] for c in real)
        last_end = (real[-1][2] + real[-1][3]) if real else term
        if last_end > 0x10000:
            fl.append("dest+size > $FFFF")
        # sample directory comparison
        dir_ok = "-"
        if dir_bytes is not None:
            starts = [dir_bytes[k] | (dir_bytes[k + 1] << 8) for k in range(0, len(dir_bytes), 4)]
            dests = [c[2] for c in real] if real else [term]  # no chunk sent: the lone entry points at T
            dir_ok = "yes" if starts == dests else ("set" if sorted(starts) == sorted(dests) else "NO")
            if dir_ok == "NO":
                fl.append("dirStarts=%s dests=%s" % (["%04X" % s for s in starts], ["%04X" % d for d in dests]))
        hi_rec_end = high_rec[1] + high_rec[0]
        if hi_rec_end != high_end:
            fl.append("highest-dest record end %04X != max end %04X" % (hi_rec_end, high_end))
        ffe_ok = "n/a" if ffe is None else ("yes" if ffe == (last_end & 0xFFFF) else "NO")
        ffc_ok = "n/a" if ffc is None else ("yes" if ffc == high_rec[1] else "NO(%04X)" % ffc)
        if ffe_ok == "NO" or ffc_ok.startswith("NO"):
            allok = False
        if nm_files.get(nm) not in (None, off):
            fl.append("files.json start %s != %d" % (nm_files.get(nm), off))
            allok = False
        t_eq = "yes" if term == high_end else ("T-high=%+d" % (term - high_end))
        if t_eq != "yes" or dir_ok not in ("yes", "-"):
            allok = False
        print("%-3s %-27s %7d  %3d   %04X     %04X    %s  %-10s  %3d  %2d(%2d)             %s  %-16s  %04X     FFE==lastEnd %s; FFC==seqDest %s; %s" % (
            idn, nm[:27], off, len(recs), high_end, term, ("%04X" % ffe) if ffe is not None else "----",
            t_eq, count, len(chunks), len(real), "%04X" % dir_base if dir_base else "----", dir_ok, last_end & 0xFFFF,
            ffe_ok, ffc_ok, "; ".join(fl) if fl else "none"))
        if a.verbose:
            print("      records: " + ", ".join("$%04X+%d" % (d, s) for s, d, _ in recs))
            print("      indices: " + " ".join("%02X" % i for i in idx))
            print("      chunk dests: " + ", ".join(
                "#%02X@%04X+%d" % (c[1], c[2], c[3]) if c[2] is not None else "#%02X(empty)" % c[1] for c in chunks))
    print()
    print("library chunk indices used by the %d streams: %d distinct, max $%02X; unused: %s" % (
        len(todo), len(used), max(used), ["%02X" % i for i in range(LIB_CHUNKS) if i not in used]))
    print("ALL streams (+ FFE == end of last chunk, FFC == sequence dest, files.json start): terminator == highest record end and dir starts == computed chunk dests: %s" % allok)


if __name__ == "__main__":
    sys.exit(main())
