#!/usr/bin/env python3
"""Shared helpers for Campaign A (actor flag bits). Drives the server through mcp_client.Mesen.

Every state-changing helper returns plain data; nothing here edits the baserom. Writes go to
mesen2-results/ (raw/, screenshots/) and rebuilt/states/ only.
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
LABELS_O = os.path.join(BASEROM, "artifacts", "labels", "iog-original.mlb")
STATE_DIR = os.path.join(BASEROM, "rebuilt", "states")
RAW = os.path.join(RESULTS, "raw")
S01R = os.path.join(STATE_DIR, "orig_S01r_south-cape-ready.mss")

SLOT_BASE, SLOT_STRIDE, SLOT_COUNT = 0x1000, 0x30, 84   # 84 slots of $30 bytes (InitActorPool), not $40


def open_session(rom=ROM_O, labels=LABELS_O):
    m = Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"])
    info = m.call("load_rom", path=rom)["rom"]
    m.call("pause")
    if labels:
        m.call("load_labels", path=labels, replace=True)
    return m, info


def wait_banner(m, tries=40):
    for _ in range(tries):
        if m.u8(0xB4) == 0:
            return True
        m.call("set_input", buttons=["a"], frames=2)
        m.call("advance_frame", frames=4)
    return m.u8(0xB4) == 0


def quick_warp(m, scene, frames=300, banner=True, settle=30):
    """sceneNext ($0642) = scene, advance until sceneCurrent == scene, dismiss the banner, settle."""
    m.poke(0x642, scene)
    done = 0
    while done < frames and m.u16(0x644) != scene:
        m.call("advance_frame", frames=20)
        done += 20
    ok = m.u16(0x644) == scene
    m.call("advance_frame", frames=20)
    if banner:
        wait_banner(m)
    m.call("advance_frame", frames=settle)
    return ok


def rom_bank_to_entry_bank(bank):
    """The entry bank byte of an actor (+2) is the HiROM mirror: ROM bank $08 reads $88, $0A -> $8A, $00 -> $80, $03 -> $83.
    Compare entries against this value, never against the plain bank (a first Dark Space run found no portal that way)."""
    return bank | 0x80


def actor_table(m, live_only=True):
    """Actors of the current scene as dicts. A freed slot is NOT cleared (InitActorPool / UnlinkActor only relink it),
    so "entry word != 0" counts dead actors: by default only slots reachable from the list head $56 through +6 are returned
    (in list order). `live_only=False` returns every slot that was ever used (stale ones carry `live=False`)."""
    raw = m.mem(SLOT_BASE, SLOT_STRIDE * SLOT_COUNT)

    def field(slot, off):
        i = slot - SLOT_BASE + off
        return raw[i] | (raw[i + 1] << 8)

    chain, s, guard = [], m.u16(0x56), 0
    while s and guard < 120 and SLOT_BASE <= s < SLOT_BASE + SLOT_STRIDE * SLOT_COUNT:
        chain.append(s)
        s = field(s, 6)
        guard += 1
    live = set(chain)
    order = chain if live_only else chain + [SLOT_BASE + k * SLOT_STRIDE for k in range(SLOT_COUNT)
                                              if SLOT_BASE + k * SLOT_STRIDE not in live]
    out = []
    for slot in order:
        i = slot - SLOT_BASE
        entry = field(slot, 0) | (raw[i + 2] << 16)
        if not live_only and slot not in live and entry == 0 and field(slot, 4) == 0 and field(slot, 6) == 0:
            continue
        out.append(dict(slot=slot, live=slot in live, entry=entry, prev=field(slot, 4), next=field(slot, 6), wait=field(slot, 8),
                        oam=field(slot, 0xE), f10=field(slot, 0x10), f12=field(slot, 0x12), x=field(slot, 0x14), y=field(slot, 0x16),
                        spr=field(slot, 0x28)))
    return out


def player_slot(m):
    return m.u16(0x09AA)


def hexs(v):
    return f"${v:04X}"


def save(m, name, meta, note):
    path = os.path.join(STATE_DIR, name)
    m.call("save_state_file", path=path, note=note, meta=meta)
    return path


def load_lua(name):
    with open(os.path.join(RESULTS, "kit", "lib", name), encoding="utf-8") as f:
        return f.read()


def stamp():
    return time.strftime("%Y%m%d")


def run_experiment(m, info, name, code, frames, prefix, state=S01R, includes=("a_census", "a_actors"), pre=None, screenshot=True,
                   timeout_ms=900000, ok_stop=("script_done",)):
    """Load `state`, apply `pre(m)` (for example a poke), run the Lua `code` atomically and store everything under raw/.

    Returns the result dict (also written to raw/<prefix>_<name>_<date>.json with the ROM info, the Lua text and the screenshot
    reply), or raises ScriptRunError (Lua error, unfinished run, no result). One place for what every scenario needs.
    """
    m.call("load_state_file", path=state)
    if pre:
        pre(m)
    t = time.time()
    r = m.run_script_checked(code, ok_stop=ok_stop, name=f"{prefix}_{name}", includes=list(includes), frames=frames + 20, turbo=True,
                             timeoutMs=timeout_ms)
    res = r["result"]
    res["experiment"] = name
    res["rom"] = info
    res["lua"] = code
    res["scriptWarnings"] = r.get("__warnings__", [])
    if screenshot:
        res["screenshot"] = m.shot(f"{prefix}_{name}")
    out = os.path.join(RAW, f"{prefix}_{name}_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    res["__seconds__"] = round(time.time() - t, 1)
    return res


def label_addresses(m, names):
    """CPU addresses of labels from the loaded .mlb; a missing label raises (a silent miss makes an exec counter read 0)."""
    out = {}
    for n in names:
        r = m.try_call("get_label_address", label=n)
        if "__error__" in r:
            raise KeyError(f"label not found: {n} ({r['__error__']})")
        out[n] = r["cpuAddress"]
    return out
