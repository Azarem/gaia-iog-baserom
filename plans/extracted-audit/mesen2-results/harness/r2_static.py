#!/usr/bin/env python3
"""R2 static prelude (read-only): decode ROM O tables that the scene sweep questions refer to.

Reads `rebuilt/Illusion of Gaia.smc` (ROM O, offsets = decimal keys of db-us/names/bankNN.json) and writes
`raw/R2_static.txt` (one table per section). Nothing is written outside the results folder.

  scene_warps  (98868, 255 word pointers, bank 01)  -> lists of 12-byte scene warps and 13-byte forced-walk warps
  scene script (884736-897022, bank 0D)             -> records [scene id word][commands][$00]; the commands are decoded with the
                                                       operand sizes of extracted/tables/scene_meta.asm (display preset, bitmap modes, tilemap layers)
  scene_actors (819200, 256 word pointers, bank 0C) -> the ids that share the default record (scene_default_actors, 819712)
  forced_walk_pan_table                              -> total of every pan list (looked up by label offset)

usage: python r2_static.py            (from this folder)
"""
import json
import os
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
RAW = os.path.join(REPO, "plans", "extracted-audit", "mesen2-results", "raw")
ROM = open(os.path.join(REPO, "rebuilt", "Illusion of Gaia.smc"), "rb").read()

OUT = []


def say(s=""):
    OUT.append(s)


def u8(o):
    return ROM[o]


def u16(o):
    return ROM[o] | (ROM[o + 1] << 8)


def names():
    d = {}
    for f in sorted(os.listdir(os.path.join(REPO, "db-us", "names"))):
        if f.startswith("bank") and f.endswith(".json"):
            d.update(json.load(open(os.path.join(REPO, "db-us", "names", f))))
    return {int(k): v for k, v in d.items()}


NAMES = names()
BYNAME = {v: k for k, v in NAMES.items()}

# ---------------------------------------------------------------------------------------------------------------- scene_warps
SW = 98868
SW_END = 108893  # inclusive end of the block (10026 bytes)
lists = {}   # pointer -> dict
scene_ptr = [u16(SW + 2 * i) for i in range(255)]
for sid, p in enumerate(scene_ptr):
    off = 0x10000 + p
    if p in lists:
        continue
    pos = off
    scene_warps = []
    while u8(pos) != 0xFF:
        e = ROM[pos:pos + 12]
        scene_warps.append({"off": pos, "b": list(e)})
        pos += 12
    pos += 1
    forced = []
    while u8(pos) != 0xFF:
        e = ROM[pos:pos + 13]
        forced.append({"off": pos, "b": list(e)})
        pos += 13
    pos += 1
    lists[p] = {"off": off, "end": pos, "scene_warps": scene_warps, "forced": forced, "scenes": []}
for sid, p in enumerate(scene_ptr):
    lists[p]["scenes"].append(sid)

nl = len(lists)
nsw = sum(len(l["scene_warps"]) for l in lists.values())
nfw = sum(len(l["forced"]) for l in lists.values())
say("## scene_warps parse (ROM O, 98868)")
say(f"lists {nl}  scene warps {nsw}  forced-walk warps {nfw}  bytes {nsw*12 + nfw*13 + 2*nl + 510} (block 10026)")
last = max(l["end"] for l in lists.values())
say(f"last list ends at {last} (block end {SW_END + 1})")

# --- OQ-30: byte 9 bit 7
say()
say("## OQ-30: scene warps with byte 9 (facing) bit 7 set (save warp)")
say("src_scenes | list_off | entry_off | rect(x,y,w,h) | dest | destXY | facing | camera")
save_entries = []
for p, l in sorted(lists.items(), key=lambda kv: kv[1]["scenes"][0]):
    for e in l["scene_warps"]:
        b = e["b"]
        if b[9] & 0x80:
            dest = b[4]
            dx, dy = b[5] | (b[6] << 8), b[7] | (b[8] << 8)
            save_entries.append({"src": l["scenes"], "off": e["off"], "rect": b[0:4], "dest": dest, "dx": dx, "dy": dy, "facing": b[9], "cam": b[10] | (b[11] << 8)})
            say("%s | %d | %d | %s | %02X | %d,%d | %02X | %04X" % (",".join("%02X" % s for s in l["scenes"]), l["off"], e["off"], b[0:4], dest, dx, dy, b[9], b[10] | (b[11] << 8)))
say(f"entries with bit 7: {len(save_entries)}; distinct source lists: {len(set(tuple(e['src']) for e in save_entries))}")
fc = Counter(e["facing"] for e in save_entries)
say("facing values with bit 7: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(fc.items())))
dest_save = Counter(e["dest"] for e in save_entries)
say("destination scenes of save warps: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(dest_save.items())))
nb7 = sum(1 for l in lists.values() for e in l["scene_warps"] if e["b"][9] & 0x80)
say(f"whole table: {nb7} entries with bit 7")

# --- all destinations
dests = defaultdict(list)
for p, l in lists.items():
    for e in l["scene_warps"]:
        dests[e["b"][4]].append((l["scenes"][0], e["off"]))
say()
say("## scene-warp destination ids (all 543 entries): count %d distinct" % len(dests))
say("destinations: " + " ".join("%02X" % d for d in sorted(dests)))

# --- OQ-I064-1: forced walk
say()
say("## OQ-I064-1: forced-walk warps (13 bytes): scene | entry_off | rect | window | byte6 | dir/pan | stream")
pan_label_off = BYNAME.get("forced_walk_pan_table")
say(f"forced_walk_pan_table label offset: {pan_label_off}")


def pan_lists():
    """Return {index: (pointer, [(delay, step) ...], total px)} from forced_walk_pan_table (16 word pointers, bank 01).

    A list is a run of words ended by a word whose high byte is 0: low byte = delay D, high byte = step S;
    the camera moves (S & 15) px on the call that loads the word and on each of the next D calls = (S & 15) * (D + 1) px.
    """
    if pan_label_off is None:
        return {}
    res = {}
    for i in range(16):
        ptr = u16(pan_label_off + 2 * i)
        o = 0x10000 + ptr
        words = []
        while u8(o + 1) != 0 and len(words) < 40:
            words.append((u8(o), u8(o + 1)))
            o += 2
        res[i] = (ptr, words, sum((s & 15) * (d + 1) for d, s in words))
    return res


PL = pan_lists()
fw_rows = []
for p, l in sorted(lists.items(), key=lambda kv: kv[1]["scenes"][0]):
    for k, e in enumerate(l["forced"]):
        b = e["b"]
        win = b[4] | (b[5] << 8)
        b6 = b[6]
        stream = b[7:13]
        dirb = "N" if b6 & 0x80 else ("E" if b6 & 0x10 else ("W" if b6 & 0x20 else "S"))
        xoff = stream[1] | (stream[2] << 8)
        yoff = stream[3] | (stream[4] << 8)
        sxo = xoff - 0x10000 if xoff & 0x8000 else xoff
        syo = yoff - 0x10000 if yoff & 0x8000 else yoff
        fw_rows.append({"scenes": l["scenes"], "k": k, "off": e["off"], "rect": b[0:4], "win": win, "b6": b6, "pan": b6 & 15, "dir": dirb, "stream": stream, "xoff": sxo, "yoff": syo})
        say("%s | #%d | %d | %s | %04X | %02X (%s pan %X) | %s" % (",".join("%02X" % s for s in l["scenes"]), k, e["off"], b[0:4], win, b6, dirb, b6 & 15, " ".join("%02X" % x for x in stream)))
say()
say("pan list index usage: " + ", ".join("%X x%d" % (k, v) for k, v in sorted(Counter(r["pan"] for r in fw_rows).items())))
say("stream first byte: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(Counter(r["stream"][0] for r in fw_rows).items())))
say("stream final byte: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(Counter(r["stream"][5] for r in fw_rows).items())))
say("byte 6 values: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(Counter(r["b6"] for r in fw_rows).items())))
say("byte 6 high nibble: " + ", ".join("%X x%d" % (k, v) for k, v in sorted(Counter(r["b6"] >> 4 for r in fw_rows).items())))
say("x offsets nonzero: %d" % sum(1 for r in fw_rows if r["xoff"]))
if PL:
    say()
    say("pan lists (index: pointer, words, total of the nonzero-terminated list)")
    for i, (ptr, words, tot) in PL.items():
        say("%X: ptr %04X words(D,S) %s total %d px" % (i, ptr, " ".join("%02X/%02X" % w for w in words), tot))
    say()
    say("forced walk | pan index | pan total | Y offset (signed) | |Y| - total | window")
    diffs = Counter()
    for r in fw_rows:
        ptr, words, tot = PL[r["pan"]]
        r["pan_total"] = tot
        d = abs(r["yoff"]) - tot
        diffs[d] += 1
        say("%s #%d | %X | %d | %d | %d | %04X" % (",".join("%02X" % s for s in r["scenes"]), r["k"], r["pan"], tot, r["yoff"], d, r["win"]))
    say("|Y offset| minus pan total, over the %d entries: %s" % (len(fw_rows), ", ".join("%d x%d" % (k, v) for k, v in sorted(diffs.items()))))
    say("pan list -> distinct (|Y|) values: " + "; ".join("%X: %s" % (i, ",".join(str(y) for y in sorted(set(abs(r["yoff"]) for r in fw_rows if r["pan"] == i)))) for i in range(16)))

# --- scene script records of bank 0D
say()
say("## scene script records (ROM O, 884736-897022)")
OPLEN = {0x02: 1, 0x03: 7, 0x04: 6, 0x05: 7, 0x06: 4, 0x0E: 3, 0x10: 6, 0x11: 5, 0x13: 2, 0x14: 1, 0x15: 1, 0x17: 4}
pos = 884736
END = 897022
records = {}
ncmd = 0
bad = None
while pos < END:
    sid = u16(pos)
    pos += 2
    cmds = []
    while True:
        op = u8(pos)
        pos += 1
        if op == 0 or pos - 1 >= END:  # the last record ends at the block end (the byte at END belongs to the next block)
            break
        n = OPLEN.get(op)
        if n is None:
            bad = (sid, op, pos - 1)
            break
        cmds.append((op, list(ROM[pos:pos + n]), pos))
        pos += n
        ncmd += 1
    if bad:
        break
    records[sid] = cmds
say(f"records {len(records)} commands {ncmd} end {pos} (block end {END + 1}) bad {bad}")
absent = [i for i in range(256) if i not in records]
say("ids without a record (%d): %s" % (len(absent), " ".join("%02X" % i for i in absent)))

preset_by_scene = {}
modes = Counter()
tmaplayers = Counter()
for sid, cmds in records.items():
    for op, args, o in cmds:
        if op == 0x02:
            preset_by_scene.setdefault(sid, []).append(args[0])
        if op == 0x03:
            modes[args[6]] += 1
        if op == 0x06:
            tmaplayers[args[0]] += 1
say("bitmap (op 3) mode operand counts: " + ", ".join("%d x%d" % (k, v) for k, v in sorted(modes.items())))
say("tilemap (op 6) layer operand counts: " + ", ".join("%02X x%d" % (k, v) for k, v in sorted(tmaplayers.items())))
by_preset = defaultdict(list)
for sid, ps in sorted(preset_by_scene.items()):
    for p in ps:
        by_preset[p].append(sid)
say("scenes with more than one op-2 command: " + (" ".join("%02X" % s for s, ps in preset_by_scene.items() if len(ps) > 1) or "none"))
say("scene records without an op-2 command: " + (" ".join("%02X" % s for s in records if s not in preset_by_scene) or "none"))
say()
say("display preset | scenes (first-record operand, static)")
for p in range(0x2F):
    say("%02X | %s" % (p, " ".join("%02X" % s for s in by_preset.get(p, [])) or "-"))
say("presets never named by a record: " + " ".join("%02X" % p for p in range(0x2F) if p not in by_preset))
say("mode-7 presets $19 and $2D: scenes " + " / ".join(" ".join("%02X" % s for s in by_preset.get(p, [])) or "-" for p in (0x19, 0x2D)))
json.dump({"preset_by_scene": {f"{k:02X}": v for k, v in preset_by_scene.items()}, "absent": absent,
           "save_entries": save_entries, "forced": [{**r, "scenes": r["scenes"]} for r in fw_rows], "dests": {f"{k:02X}": [f"{s:02X}" for s, _ in v] for k, v in dests.items()}},
          open(os.path.join(RAW, "R2_static.json"), "w"), indent=0)

# --- scene_actors default record
say()
say("## scene_actors pointer table (819200): ids sharing the default record")
SA = 819200
ptrs = [u16(SA + 2 * i) for i in range(256)]
cnt = Counter(ptrs)
dflt = [p for p, c in cnt.items() if c > 1]
for p in dflt:
    say("pointer %04X (file %d) shared by %d ids: %s" % (p, 0xC0000 + 0x8000 + (p - 0x8000) if False else (0x0C0000 + p), cnt[p], " ".join("%02X" % i for i, q in enumerate(ptrs) if q == p)))
say("ids with an empty list (record = FF, title CA only) are not decoded here")
open(os.path.join(RAW, "R2_static.txt"), "w").write("\n".join(OUT) + "\n")
print("\n".join(OUT[:10]))
print("wrote raw/R2_static.txt", len(OUT), "lines")
