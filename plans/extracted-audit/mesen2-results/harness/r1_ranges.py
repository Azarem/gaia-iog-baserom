#!/usr/bin/env python3
"""R1 range table (ROM O). Writes raw/R1_ranges.json: [{name, start, end, id, kind, note}] with decimal ROM offsets, `end` inclusive
(get_access_summary convention). Read-only on the baserom: db-us/names, db-us/blocks.json, extracted/ (tags) and the O ROM file.

Every start comes from a decimal key of db-us/names/bankNN.json, a block/part of db-us/blocks.json, an explicit `; {n}` tag of the
extracted .asm, or is computed from the O ROM bytes (sprite-set pointer tables, label hexadecimal in a generated name).
usage: python r1_ranges.py            (writes raw/R1_ranges.json and prints the row count per id)
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
RAW = os.path.join(HERE, "..", "raw")
ROM = open(os.path.join(REPO, "rebuilt", "Illusion of Gaia.smc"), "rb").read()
assert len(ROM) == 2097152

NAMES = {}
for f in glob.glob(os.path.join(REPO, "db-us", "names", "bank*.json")):
    for k, v in json.load(open(f, encoding="utf-8")).items():
        NAMES[int(k)] = v
KEYS = sorted(NAMES)
BYNAME = {}
for k, v in NAMES.items():
    BYNAME.setdefault(v, k)

ROWS = []


def add(id_, name, start, end, kind, note=""):
    assert 0 <= start <= end < len(ROM), (id_, name, start, end)
    ROWS.append(dict(id=id_, name=name, start=start, end=end, kind=kind, note=note))


def nxt(k):
    """Start of the next name key after k (end exclusive of the label under test)."""
    for x in KEYS:
        if x > k:
            return x
    return len(ROM)


def label(id_, lab, kind="code", end=None, note=""):
    k = BYNAME[lab]
    add(id_, lab, k, (end if end is not None else nxt(k) - 1), kind, note)


def w(off):
    return ROM[off] | (ROM[off + 1] << 8)


# ------------------------------------------------------------------------------------------------ code actors and routines
# UNREF members (block extents from db-us/blocks.json: start, end exclusive)
add("I034-3", "idle_sprite_display", 589055, 589077, "actor-def")
add("I038-4", "camera_delta_oscillator", 570743, 570769, "actor-def")
add("I045-4", "unused_particle_rain_spawner", 774827, 774917, "actor-def")
add("I045-4", "UnusedRainSpawnerLoop", 774830, 774858, "code", "entry loop of the spawner")
add("I045-4", "UnusedRainDropChild", 774859, 774917, "code", "child actor")
add("I048-4", "dialog_string_scanner", 778693, 778806, "actor-def")
add("I049-1", "debug_man", 781856, 782711, "actor-def")
add("I049-1", "DebugManEntry", 781859, 781867, "code")
add("I049-1", "DebugManInteract", 781868, 781880, "code", "first 13 bytes of the interact handler")
add("I049-7", "CameraDeadBoundsX", 60232, 60236, "code")
add("I049-7", "CameraDeadBoundsY", 60276, 60280, "code")
add("I049-7", "camera_scroll_controller (control)", 60141, 60231, "actor-def", "the live part of the same actor")
add("I039-4", "NorthProbeRedirect", 184888, 184894, "code", "JSR MapCellDown, JSR ReadCollisionNibble, BRA")
add("I039-4", "DispatchNorthMove JMP #1 (control)", 184445, 184447, "code", "JMP NorthProbeRedirect (X flush)")
add("I039-4", "DispatchNorthMove JMP #2 (control)", 184478, 184480, "code", "JMP NorthProbeRedirect (east cell)")
add("I050-5", "camera_drift_offsets words 0-7", 53352, 53367, "data")
add("I050-5", "camera_drift_offsets words 8-15", 53368, 53383, "data")
# diary nine _noref labels and the BG3 cursor engine (blocks.json parts, end exclusive)
for nm, a, b in [("DiaryCursorNav_noref", 781318, 781374), ("DiaryJoypadFilter_noref", 782712, 782754), ("DiaryResetCounter_noref", 782754, 782758),
                 ("DiaryIncCounter_noref", 782758, 782762), ("DiaryDigitDisplay_noref", 782762, 782811), ("DiaryUnused24B_noref", 782923, 782937),
                 ("DiaryReadJoy2_noref", 782937, 782944), ("DiaryNullHandler_noref", 782944, 782945), ("DiaryAwaitButtonRelease_noref", 782945, 783014)]:
    add("I057-2", nm, a, b - 1, "code", "nine _noref entries")
for nm, a, b in [("DiaryCursorApplyMove", 781374, 781489), ("DiaryDrawCursorHighlight", 781489, 781529), ("DiaryClearCursor", 781529, 781563),
                 ("DiaryClearAllCursors", 781563, 781628)]:
    add("I057-2", nm, a, b - 1, "code", "cursor-engine helper")
add("I057-2", "diary_cursor_menu_table", 781628, 781667, "data", "read only by the cursor engine")
add("I057-2", "DiaryMainMenuEntry (control)", 778956, 779890, "code")
add("I057-2", "FormatBcdNumber (control, shared helper)", 782811, 782922, "code")
add("I057-5", "TitlePaletteStep_noref", 772519, 772525, "actor-def")
add("I057-5", "TitleCometSpriteActor (control)", 772488, 772518, "actor-def")
# DrawMetatileStream pair (COP #4D / #4E)
add("I023-5", "DrawMetatileStream", 38659, 38771, "code", "COP #4D handler")
add("I023-5", "DrawMetatileStream bit-2 SFX branch", 38718, 38736, "code", "extendedFlags bit 2 test and the sfx queue store")
add("I023-5", "DrawMetatileStreamDelay", 38772, nxt(38772) - 1, "code", "COP #4E handler")
if "TileQueryGate" in BYNAME:
    add("I023-5", "TileQueryGate (control)", BYNAME["TileQueryGate"], BYNAME["TileQueryGate"] + 9, "code", "shared by the metatile COP handlers")
# hit sparkle
label("I042-1", "SpawnItemSparkleEffect", end=56604)
label("I042-1", "AppendSparkleOamEntries")
add("I042-1", "GiveItemToPlayer heal branch: COP SpawnListAppend", 258009, 258018, "code", "the only spawn site of the sparkle")
add("I042-1", "GiveItemToPlayer entry (control)", BYNAME["GiveItemToPlayer"], BYNAME["GiveItemToPlayer"] + 8, "code")
# I065-4: LoadBgTiles mode 3 and FullGraphics tileset-only path
add("I065-4", "SceneCmd_LoadBgTiles mode 3 entry", 165107, 165115, "code")
add("I065-4", "SceneCmd_LoadBgTiles mode 0 entry (control)", 165005, 165010, "code")
label("I065-4", "Load4bppPage")
add("I065-4", "FullGraphics: JMP DmaLowVramTileset (no layer bit)", 165943, 165945, "code")
label("I065-4", "DmaLowVramTileset")
# I068-5: forced walk
add("I068-5", "ForcedWalkWest", 60483, 60566, "code")
add("I068-5", "ForcedWalkEast", 60567, 60650, "code")
label("I068-5", "StartForcedWalk")
label("I068-5", "ExecuteForcedWalkWarp")
add("I068-5", "ExecuteForcedWalkWarp: bit 5 branch (West)", 174922, 174924, "code")
# I063-1 shared words
SW = 125711
for n in range(15):
    add("I063-1", f"shared_word_table[{n:02X}] pointer", SW + 2 * n, SW + 2 * n + 1, "data")
starts = sorted(set(0x10000 | w(SW + 2 * n) for n in range(15)))
for n in range(15):
    s = 0x10000 | w(SW + 2 * n)
    e = nxt_s = [x for x in starts if x > s]
    end = (e[0] - 1) if e else s + 12
    add("I063-1", f"shared word string [{n:02X}] @{s}", s, end, "data")
add("I063-1", "ConsoleCmd_InsertSharedWord", BYNAME["ConsoleCmd_InsertSharedWord"], BYNAME["ConsoleCmd_InsertSharedWord"] + 12, "code")
# I062-4: 85 movement chains (pointer table, one word per chain; AnimFrameLookup reads entry = table + 2*index)
MC = 110726
for n in range(85):
    add("I062-4", f"move_chain_table[{n:02X}] pointer", MC + 2 * n, MC + 2 * n + 1, "data")
# I060-5: palette bundle table entries (the E2 run has the sub-entry lists and data)
PB = 1474560
for n in range(128):
    add("I060-5", f"palette_bundles[{n:02X}] pointer", PB + 2 * n, PB + 2 * n + 1, "data")
# I072-3: unreferenced strings and thinker lists
sysstr = open(os.path.join(REPO, "extracted", "tables", "system_strings.asm"), encoding="utf-8").read()
cs = sorted(set(int(m, 16) for m in re.findall(r"^consolestring_([0-9A-F]{6}) ", sysstr, re.M)))


def cslen(a):
    nxts = [x for x in cs if x > a]
    return (nxts[0] - 1) if nxts else a + 12


for h in ["01E82B", "01E834", "01E83D", "01E846", "01E851", "01E85C"]:
    a = int(h, 16)
    add("I072-3", f"consolestring_{h}", a, cslen(a), "data", "six unreferenced HUD strings")
for h in ["01E641", "01E64B", "01E655", "01E6C0", "01E6CA", "01E6D4"]:
    a = int(h, 16)
    add("I072-3", f"consolestring_{h} (Shadow placeholder)", a, cslen(a), "data")
for h in ["01E7B9", "01E7BE", "01E7C3", "01E7C8"]:
    a = int(h, 16)
    add("I072-3", f"consolestring_{h} ('Dark 1', ability description)", a, cslen(a), "data")
for h in ["01E614", "01E6F6", "01E73C"]:
    a = int(h, 16)
    add("I072-3", f"consolestring_{h} (control: Spin Dash name / description)", a, cslen(a), "data")
for tbl, base, n in [("ability_menu_table", 124396, 12), ("ability_name_table", 124509, 13), ("ability_description_table", 124636, 13)]:
    for i in range(n):
        add("I072-3", f"{tbl}[{i:02X}] pointer", base + 2 * i, base + 2 * i + 1, "data")
thk = open(os.path.join(REPO, "extracted", "tables", "scene_thinkers.asm"), encoding="utf-8").read()
tl = sorted(set(((int(h[:2], 16) & 0x3F) << 16) | int(h[2:], 16) for h in re.findall(r"^thinker_spawn_([0-9A-F]{6}) \[", thk, re.M)))
for h in ["0CE8E6", "0CE9EA", "0CEA45"]:
    a = ((int(h[:2], 16) & 0x3F) << 16) | int(h[2:], 16)
    nx = [x for x in tl if x > a]
    add("I072-3", f"thinker_spawn_{h}", a, (nx[0] - 1) if nx else a + 40, "data", "unreferenced thinker list")

# ------------------------------------------------------------------------------------------------ sprite sets (anim index rows)
SETS = {
    "spriteset_transform_poses": ("I067-4", 1032192, [4, 0xC, 0x11]),
    "spriteset_npc_props": ("I068-2", 973312, [3, 9]),
    "spriteset_shadow_fx": ("I069-1", 1552384, None),
    "spriteset_pickups_effects": ("I069-2", 974848, None),
    "spriteset_will_abilities": ("I072-6", 1015808, [8, 9, 0xA, 0xB, 0x1E, 0x21, 0x23, 0x24, 0x25, 0x26]),
    "spriteset_will": ("I064-4", 1409024, [4, 5, 6, 7, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17]),
    "spriteset_freedan": ("I063-2", 950272, [4, 5, 6, 7, 0x14, 0x15, 0x16, 0x17] + list(range(0x1C, 0x2A)) + [0x3E, 0x3F, 0x40, 0x41, 0x4A, 0x4B]),
    "spriteset_shadow": ("I066-5", 1343488, [0x19, 0x1A, 0x1B, 0x1C] + list(range(0x1D, 0x26)) + [0x2E, 0x2F, 0x30, 0x31, 0x34, 0x35]),
}
SETINFO = {}
for nm, (id_, start, only) in SETS.items():
    bank = start & ~0xFFFF
    p0 = w(start)
    n = (p0 - (start & 0xFFFF)) // 2
    SETINFO[nm] = dict(start=start, anims=n)
    for i in range(n):
        lp = w(start + 2 * i)
        lo = bank | lp
        o = lo
        while w(o) < 0x8000:
            o += 4
        end = o + 1
        sel = "target" if (only is None or i in only) else "control"
        add(id_, f"{nm}[{i:02X}] ptr", start + 2 * i, start + 2 * i + 1, "anim-ptr", sel)
        add(id_, f"{nm}[{i:02X}] list@{lo}", lo, end, "anim-list", sel)
# B001-1 / I056-7: spm_darkspace_sprites is stored compressed (files.json 1910209..1910775): only the compressed bytes are visible to ROM counters
add("B001-1", "spm_darkspace_sprites (compressed)", 1910209, 1910775, "data", "compressed stream: ROM reads show only that the file was loaded")

add("CTRL", "NmiHandler (positive control)", BYNAME["NmiHandler"], BYNAME["NmiHandler"] + 3, "code", "executed every frame")
add("CTRL", "RunActors entry (positive control)", BYNAME["RunActors"], BYNAME["RunActors"] + 3, "code", "executed every frame") if "RunActors" in BYNAME else None
for i, r in enumerate(ROWS):
    r["req"] = f"r{i:04d}"
json.dump([dict(name=r["req"], start=r["start"], end=r["end"]) for r in ROWS], open(os.path.join(RAW, "R1_ranges_req.json"), "w"))
out = os.path.join(RAW, "R1_ranges.json")
json.dump(dict(rows=ROWS, sets=SETINFO), open(out, "w"), indent=0)
by = {}
for r in ROWS:
    by[r["id"]] = by.get(r["id"], 0) + 1
print(len(ROWS), "ranges", by)
print(SETINFO)
