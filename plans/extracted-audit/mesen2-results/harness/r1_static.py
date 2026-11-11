#!/usr/bin/env python3
"""R1 static half (R3 method, read-only): for each label of the UNREF method group, byte-search the O ROM for a 24-bit pointer
(word LE + bank byte, bank in {b, b|$80, b|$C0}) and for the 16-bit word (same bank only, with the three bytes before it), at the label
start K and at K+3 (an actor-def has a 3-byte header before its first instruction). Prints one line per pattern. Writes raw/R1_static.txt.
Read-only: the ROM file, nothing else.
"""
import os
import re
import subprocess
import json

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
RAW = os.path.join(HERE, "..", "raw")
ROM = open(os.path.join(REPO, "rebuilt", "Illusion of Gaia.smc"), "rb").read()

T = [
    ("I034-3", "idle_sprite_display", 589055), ("I038-4", "camera_delta_oscillator", 570743), ("I045-4", "unused_particle_rain_spawner", 774827),
    ("I048-4", "dialog_string_scanner", 778693), ("I049-1", "debug_man", 781856), ("I050-5", "camera_drift_offsets", 53352),
    ("I050-5", "camera_drift_offsets+16 (word 8)", 53368), ("I057-5", "TitlePaletteStep_noref", 772519),
    ("I057-2", "DiaryCursorNav_noref", 781318), ("I057-2", "DiaryJoypadFilter_noref", 782712), ("I057-2", "DiaryResetCounter_noref", 782754),
    ("I057-2", "DiaryIncCounter_noref", 782758), ("I057-2", "DiaryDigitDisplay_noref", 782762), ("I057-2", "DiaryUnused24B_noref", 782923),
    ("I057-2", "DiaryReadJoy2_noref", 782937), ("I057-2", "DiaryNullHandler_noref", 782944), ("I057-2", "DiaryAwaitButtonRelease_noref", 782945),
    ("I049-7", "CameraDeadBoundsX", 60232), ("I049-7", "CameraDeadBoundsY", 60276), ("I039-4", "NorthProbeRedirect", 184888),
    ("I072-3", "thinker_spawn_0CE8E6", 846054), ("I072-3", "thinker_spawn_0CE9EA", 846314), ("I072-3", "thinker_spawn_0CEA45", 846405),
    ("I072-3", "consolestring_01E82B", 0x1E82B), ("I072-3", "consolestring_01E834", 0x1E834), ("I072-3", "consolestring_01E83D", 0x1E83D),
    ("I072-3", "consolestring_01E846", 0x1E846), ("I072-3", "consolestring_01E851", 0x1E851), ("I072-3", "consolestring_01E85C", 0x1E85C),
    ("I042-1", "SpawnItemSparkleEffect", 56579),
]


def find_all(pat):
    out, i = [], 0
    while True:
        j = ROM.find(pat, i)
        if j < 0:
            return out
        out.append(j)
        i = j + 1


def rg_refs(name):
    base = name.split(" ")[0].split("+")[0]
    r = subprocess.run(["rg", "-n", "-w", "--no-heading", base, "extracted", "baserom", "db-us/files.json", "db-us/overrides.json"], cwd=REPO, capture_output=True, text=True)
    lines = [ln for ln in r.stdout.splitlines() if ln.strip()]
    return lines


lines = []
for id_, name, k in T:
    for delta, tag in ((0, "K"), (3, "K+3")):
        a = k + delta
        word, bank = a & 0xFFFF, a >> 16
        lo, hi = word & 0xFF, word >> 8
        h24 = []
        for b in sorted({bank, bank | 0x80, bank | 0xC0}):
            h24 += [(x, f"3B bank {b:02X}") for x in find_all(bytes([lo, hi, b]))]
        h16 = [x for x in find_all(bytes([lo, hi])) if (x >> 16) == bank and x not in (a,)]
        ctx = lambda x: " ".join(f"{ROM[y]:02X}" for y in range(x - 3, x + 3))
        lines.append(f"{id_} {name} {tag}={a} (${bank:02X}:{word:04X}) 24-bit hits: {len(h24)}  same-bank 16-bit hits: {len(h16)}")
        for x, t in h24[:8]:
            lines.append(f"    24b @{x} ({t}) ctx {ctx(x)}")
        if len(h16) <= 6:
            for x in h16:
                lines.append(f"    16b @{x} ctx {ctx(x)}")
    refs = rg_refs(name)
    lines.append(f"    rg -w {name.split(' ')[0].split('+')[0]} extracted baserom db-us/files.json db-us/overrides.json: {len(refs)} lines")
    for ln in refs[:3]:
        lines.append("        " + ln[:170])
open(os.path.join(RAW, "R1_static.txt"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
print("\n".join(lines))
