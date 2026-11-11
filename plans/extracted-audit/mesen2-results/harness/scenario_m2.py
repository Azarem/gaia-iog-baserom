#!/usr/bin/env python3
"""M2 (title, boot, diary): one fresh server session per case; modules kit/lib/m2_kit.lua (+ m1_kit, gaia_kit).

usage: python scenario_m2.py --list | CASE [CASE ...]
Writes raw/M2_<case>_<yyyymmdd>.json (replies, Lua text, ROM identity) and screenshots under raw/screenshots/.
Edits nothing outside mesen2-results/ and rebuilt/states/.
"""
import argparse
import base64
import datetime
import json, hashlib
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM = {
    "O": os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc"),
    "R": os.path.join(BASEROM, "rebuilt", "Illusion of Gaia - Rebuilt.smc"),
}
LABELS_O = os.path.join(BASEROM, "artifacts", "labels", "iog-original.mlb")
STATES = os.path.join(BASEROM, "rebuilt", "states")
RAW = os.path.join(RESULTS, "raw")
DATE = datetime.date.today().strftime("%Y%m%d")
INCL = ["gaia_kit", "m1_kit", "m2_kit"]

# decimal PRG offsets of the O ROM (the `; {n}` tags of extract:lt)
O = dict(
    nmi=33528,
    BootLogoInit=772285, BootLogoNtsc=772330, Stage1=772346, Anim1=772350, SetFlag10=772352, Qmc1=772355,
    Stage2=772367, Anim2=772371, ClearFlag10=772373, Qmc2=772376,
    Obj0Start=47169, Obj0Kill=47184, Obj1Start=47189, Obj1Kill=47204, Obj2Start=47209, Obj2Kill=47224,
    TitleInit=772391, TitleWait180=772446, TitleWait120=772454, TitleWaitIdle=772462, TitleQmc=772475,
    CometSpawn=772420, CometLoop1=772491, CometLoop2=772497, CometWait60=772504, CometTm=772509,
)


def r_offsets():
    """R-plain offsets from artifacts/master-lookup.json (hex PRG offset by upper-case label); the boot-logo block is contiguous so tags keep their delta."""
    d = json.load(open(os.path.join(BASEROM, "artifacts", "master-lookup.json")))
    h = lambda k: int(d[k], 16)  # noqa: E731
    out = {"nmi": h("NMIHANDLER")}
    delta = h("BOOTLOGOINIT") - O["BootLogoInit"]
    for k in ("BootLogoInit", "BootLogoNtsc", "Stage1", "Anim1", "SetFlag10", "Qmc1", "Stage2", "Anim2", "ClearFlag10", "Qmc2"):
        out[k] = O[k] + delta
    for i in (0, 1, 2):
        base = h(f"BOOTLOGOENIXOBJ{i}ENTRY")
        out[f"Obj{i}Start"] = base
        out[f"Obj{i}Kill"] = base + (O[f"Obj{i}Kill"] - O[f"Obj{i}Start"])
    return out


def offs(tag):
    return O if tag == "O" else r_offsets()


def lua_marks(m):
    return "{" + ", ".join(f"{k}={v}" for k, v in m.items() if k != "nmi") + "}"


def start():
    return Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"])


def identity(m, tag, paused=True):
    r = m.call("load_rom", path=ROM[tag], paused=paused)
    rom = r.get("rom") or {}
    info = {"tag": tag, "path": ROM[tag], "size": rom.get("fileSizeBytes"), "sha1": rom.get("fileSha1"), "crc32": rom.get("fileCrc32")}
    return info


def h1(m, state_path, expect_scene, frames=120):
    """H1 validity test on a loaded state: run `frames`, then cpu.k / sp / scene. The OAM-clear routine ($83:CEE1 in R: TCS to $0621 then PHA x N, a stack-fill) moves SP
    out of $01xx for a few instructions per frame, so up to 10 one-frame samples are taken until sp is in $0100-$01FF; all samples are recorded."""
    rep = m.call("advance_frame", frames=frames, turbo=True)
    samples = []
    ok = False
    scene = None
    for _ in range(10):
        cpu = rep.get("cpu") or {}
        scene = m.u16(0x0644)
        samples.append({"k": cpu.get("k"), "sp": cpu.get("sp")})
        ok = (cpu.get("k") in range(0x80, 0xD0)) and (0x0100 <= cpu.get("sp", 0) <= 0x01FF) and (expect_scene is None or scene == expect_scene)
        if ok:
            break
        rep = m.call("advance_frame", frames=1, turbo=True)
    return {"state": os.path.basename(state_path), "samples": samples, "scene": scene, "ok": ok}


def load_state(m, name, settle=2):
    p = os.path.join(STATES, name)
    r = m.call("load_state_file", path=p)
    if settle:
        m.call("advance_frame", frames=settle, turbo=True)
    return r


def dump(out, name):
    path = os.path.join(RAW, f"M2_{name}_{DATE}.json")
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1)
    return path


# --------------------------------------------------------------------------------------------------
# case: boot (O or R): 800 frames, shot every 8 frames for the first 400 then every 40, OAM / OBJ-only shots at chosen frames
# --------------------------------------------------------------------------------------------------
BOOT_LUA = "m2.boot{{frames={frames}, nmi={nmi}, out='M2_boot_{tag}.txt', marks={marks}, palettes={{0,1,2,3,4}}}}"


def case_boot(tag):
    m = start()
    out = {"case": f"boot_{tag}", "date": DATE, "serverInfo": m.server_info}
    try:
        out["rom"] = identity(m, tag)
        if tag == "O":
            m.call("load_labels", path=LABELS_O, replace=True)
        of = offs(tag)
        total = 800
        code = BOOT_LUA.format(frames=total, nmi=of["nmi"], tag=tag, marks=lua_marks(of))
        out["lua"] = code
        shots = []
        oams = {}
        want_oam = {120, 136, 232, 248, 392, 480, 560, 600, 640, 680, 720, 760}
        f = 0
        # load_rom paused leaves the console power-cycled at frame 0 (nothing has run): the script sees the whole boot
        m.call("load_script", code=code, name="m2_boot", includes=INCL)
        while f < total:
            step = 8 if f < 400 else 40
            m.call("advance_frame", frames=step, turbo=True)
            f += step
            shots.append(m.shot(f"M2_boot_{tag}_f{f:03d}"))
            if f in (120, 248):
                vram = m.mem(0, 65536, "snesVideoRam")
                binf = open(os.path.join(BASEROM, "extracted", "system", "boot_logos", "gfx_boot_logos.bin"), "rb").read()
                out.setdefault("vramFind", {})[str(f)] = {"binSize": len(binf), "firstMatch": vram.find(binf), "firstMatchSkip2": vram.find(binf[2:]) if len(binf) > 2 else -1,
                                                       "probe64": vram.find(binf[2:66])}
            if tag == "O" and f in want_oam:
                oams[f] = m.call("get_oam", onlyOnScreen=True)
                m.shot(f"M2_boot_{tag}_obj_f{f:03d}", layers=["obj"])
        m.call("advance_frame", frames=2, turbo=True)
        out["result"] = m.call("get_script_result", name="m2_boot")
        out["oam"] = oams
        out["shots"] = [s.get("path") for s in shots]
    finally:
        m.close()
    return out


def cgram_obj(m):
    b = m.mem(256, 256, "snesCgRam")
    return {f"pal{p}": [f"{b[p*32+2*i] | (b[p*32+2*i+1] << 8):04X}" for i in range(16)] for p in range(8)}


def case_logo_poke(tag="O"):
    """Poke the palette-4 colours (CGRAM staging $7F:0A00 + $180) red in the second logo and screenshot: shows which sprites use OBJ palette 4. Also dump OBJ palettes."""
    m = start()
    out = {"case": "logo_poke", "date": DATE, "serverInfo": m.server_info}
    try:
        out["rom"] = identity(m, tag)
        code = BOOT_LUA.format(frames=1200, nmi=O["nmi"], tag=tag, marks=lua_marks({k: v for k, v in O.items() if k in ("Stage2",)}))
        m.call("load_script", code=code, name="m2_boot", includes=INCL)
        m.call("advance_frame", frames=250, turbo=True)
        out["cgram_f250"] = cgram_obj(m)
        m.shot("M2_logo2_before_poke")
        stg = 0x10A00 + 0x180
        out["staging_before"] = m.mem(stg, 32).hex()
        m.poke(stg + 2, [0x1F, 0x00] * 15)
        m.call("advance_frame", frames=2, turbo=True)
        out["poke_shot"] = m.shot("M2_logo2_pal4_red")
        out["poke_obj_shot"] = m.shot("M2_logo2_pal4_red_obj", layers=["obj"])
        out["staging_after"] = m.mem(stg, 32).hex()
    finally:
        m.close()
    return out


def case_title_boot(tag="O"):
    """Cold boot to frame 1000 on the boot recorder; screenshots and OAM through the comet hold and the sweep; CGRAM OBJ palettes at the title."""
    m = start()
    out = {"case": f"title_{tag}", "date": DATE, "serverInfo": m.server_info, "oam": {}, "shots": {}}
    try:
        out["rom"] = identity(m, tag)
        of = offs(tag)
        total = 1000
        code = BOOT_LUA.format(frames=total, nmi=of["nmi"], tag="T" + tag, marks=lua_marks(of))
        out["lua"] = code
        m.call("load_script", code=code, name="m2_boot", includes=INCL)
        f = 0
        pts = [540, 560, 600, 660, 700, 740, 766, 770, 772, 776, 780, 790, 800, 810, 820, 830, 834, 840, 850, 880, 940, 1000]
        for t in pts:
            m.call("advance_frame", frames=t - f, turbo=True)
            f = t
            out["shots"][t] = m.shot(f"M2_title_{tag}_f{t:04d}").get("path")
            out["oam"][t] = m.call("get_oam", onlyOnScreen=True)
            if t in (700, 800, 1000):
                out.setdefault("cgram", {})[t] = cgram_obj(m)
                m.shot(f"M2_title_{tag}_obj_f{t:04d}", layers=["obj"])
        m.call("advance_frame", frames=2, turbo=True)
        out["result"] = m.call("get_script_result", name="m2_boot")
    finally:
        m.close()
    return out


# --------------------------------------------------------------------------------------------------
# states: title and seeded diary per ROM
# --------------------------------------------------------------------------------------------------
STATE_NAMES = {
    "O": dict(title="orig_S06_title.mss", diary="orig_M2_diary_seeded.mss"),
    "R": dict(title="R-0cfcb558_S06_title.mss", diary="R-0cfcb558_M2_diary_seeded.mss"),
}


def sram_page(base, fields):
    """508-byte slot data (copy of WRAM $0A00-$0BFB with `fields` {wramAddr: word}) + the two checksum words (sum, xor, seed $3652)."""
    d = bytearray(base)
    for a, v in fields.items():
        d[a - 0x0A00] = v & 0xFF
        d[a - 0x0A00 + 1] = (v >> 8) & 0xFF
    s = x = 0x3652
    for i in range(0, 508, 2):
        w = d[i] | (d[i + 1] << 8)
        s = (s + w) & 0xFFFF
        x ^= w
    return bytes(d) + bytes([s & 0xFF, s >> 8, x & 0xFF, x >> 8])


def seed_slots(m, base, slots):
    """slots = [fields0, fields1, None...]: write SRAM pages ($30:6200 + n*512 = save RAM offset 0x200 + n*512); None = zeroed (empty)."""
    out = []
    for n in range(4):
        f = slots[n] if n < len(slots) else None
        page = sram_page(base, f) if f else bytes(512)
        m.poke(0x200 + n * 512, page, "snesSaveRam")
        out.append(bool(f))
    m.poke(0x000, [0, 0], "snesSaveRam")  # $306000 last-used slot = 0
    return out


SLOT_FIELDS = [
    {0x0B12: 0x0001, 0x0B06: 0x0001, 0x0B24: 0, 0x0B26: 0, 0x0ACA: 0x0020, 0x0ACE: 0x0020, 0x0ADC: 3, 0x0ADE: 5},   # slot 0: South Cape, stereo, Type 1
    {0x0B12: 0x0015, 0x0B06: 0x0015, 0x0B24: 1, 0x0B26: 1, 0x0ACA: 0x0028, 0x0ACE: 0x0028, 0x0ADC: 4, 0x0ADE: 6},   # slot 1: Itory, mono, Type 2
]


def hold(m, buttons, frames):
    return m.call("set_input", port=0, buttons=buttons, frames=frames, turbo=True)


def adv(m, n):
    return m.call("advance_frame", frames=n, turbo=True)


def wram_words(m, addrs):
    return {a: m.u16(a) for a in addrs}


def case_mkstates(tag):
    m = start()
    out = {"case": f"mkstates_{tag}", "date": DATE, "serverInfo": m.server_info, "log": []}
    names = STATE_NAMES[tag]
    try:
        out["rom"] = identity(m, tag)
        sha = out["rom"]["sha1"]
        if tag == "R":
            adv(m, 450)
            out["title_save"] = m.call("save_state_file", path=os.path.join(STATES, names["title"]),
                                       note="M2: cold boot, 450 frames, title scene $FC (R-plain)", meta={"scene": 0xFC, "frame": 450, "tag": "R-plain"})
        else:
            load_state(m, names["title"])
        out["h1_title"] = h1(m, os.path.join(STATES, names["title"]), 0xFC, 120)
        out["title_frame"] = m.call("get_emulator_state").get("frame") if False else None
        # reload so the seeded state starts exactly at the saved title frame
        load_state(m, names["title"])
        out["sram_before"] = m.mem(0, 16, "snesSaveRam").hex()
        base = m.mem(0x0A00, 508)
        out["seeded"] = seed_slots(m, base, SLOT_FIELDS)
        out["sram_after_hdr"] = m.mem(0x200, 32, "snesSaveRam").hex()
        t_press = None
        n = 0
        while n < 1200:
            hold(m, ["start"], 4)
            adv(m, 2)
            n += 6
            sc, nx = m.u16(0x0644), m.u16(0x0642)
            if sc == 0xFA or nx == 0xFA:
                t_press = n
                break
        out["start_to_diary_frames"] = t_press
        out["n36_at_diary"] = m.u16(0x36)
        adv(m, 700)
        st = {hex(a): v for a, v in wram_words(m, [0x0644, 0x0642, 0x0D74, 0x0D76, 0x0D78, 0x0D7A, 0x0D7C, 0x0D92, 0x0D94, 0x0D96, 0x0D98, 0x0D8C, 0x0D8E, 0x0D90]).items()}
        out["diary_idle"] = st
        out["diary_shot"] = m.shot(f"M2_diary_seeded_{tag}")
        out["diary_save"] = m.call("save_state_file", path=os.path.join(STATES, names["diary"]),
                                   note="M2: title state + SRAM slots 0 (South Cape, Type 1, stereo) and 1 (Itory, Type 2, mono) seeded, slot 2 empty; Start held until scene $FA, 700 frames",
                                   meta={"scene": 0xFA, "tag": tag})
        out["h1_diary"] = None
        load_state(m, names["diary"])
        out["h1_diary"] = h1(m, os.path.join(STATES, names["diary"]), 0xFA, 120)
    finally:
        m.close()
    return out


def case_h1all():
    out = {"case": "h1all", "date": DATE, "rows": []}
    for tag in ("O", "R"):
        m = start()
        try:
            ident = identity(m, tag)
            for key, scene in (("title", 0xFC), ("diary", 0xFA)):
                nm = STATE_NAMES[tag][key]
                load_state(m, nm)
                out["rows"].append({"tag": tag, "sha1": ident["sha1"], **h1(m, os.path.join(STATES, nm), scene, 120)})
        finally:
            m.close()
    return out


# --------------------------------------------------------------------------------------------------
# OQ-I057-1: physical button sweeps (title, diary stages)
# --------------------------------------------------------------------------------------------------
BTNS = ["b", "y", "select", "start", "up", "down", "left", "right", "a", "x", "l", "r"]
FX_TITLE = 'function() return string.format("%04X/%04X", kit.r16(0x644), kit.r16(0x642)) end'
FX_DIARY = ('function() return string.format("tab=%04X cur=%04X edit=%04X tgt=%04X sc=%04X/%04X", kit.r16(0xD98), kit.r16(0xD92), kit.r16(0xD94), '
            'kit.r16(0xD96), kit.r16(0x644), kit.r16(0x642)) end')


def sweep_code(btns, tag, fx, hold=8, rel=5, out="M2_sweep.txt"):
    bl = "{" + ",".join(f'"{b}"' for b in btns) + "}"
    return f'm2.sweepRun{{btns={bl}, hold={hold}, rel={rel}, tag="{tag}", fx={fx}, out="{out}", pre=2}}'


def run_sweep(m, btns, tag, fx):
    rep = m.run_script_checked(sweep_code(btns, tag, fx), ok_stop=("script_done", "done"), frames=len(btns) * 20 + 60, includes=INCL, turbo=True, name="m2_sweep", maxLog=60)
    return (rep.get("result") or {}).get("rows"), rep.get("result")


def press(m, buttons, hold_frames=2, after=12):
    hold(m, buttons, hold_frames)
    adv(m, after)


def prep_stage(m, tag, stage):
    if stage.startswith("title"):
        load_state(m, STATE_NAMES[tag]["title"])
        return
    load_state(m, STATE_NAMES[tag]["diary"])
    if stage == "diary_main":
        return
    if stage == "diary_slots":
        press(m, ["a"], 2, 40)
    elif stage == "diary_erase":
        press(m, ["down"], 2, 12)
        press(m, ["a"], 2, 40)
    elif stage == "diary_copy":
        press(m, ["down"], 2, 12)
        press(m, ["down"], 2, 12)
        press(m, ["a"], 2, 40)
    elif stage == "diary_snd":
        for _ in range(3):
            press(m, ["down"], 2, 12)
        press(m, ["a"], 2, 40)
    else:
        raise ValueError(stage)


def case_sweep(tag):
    m = start()
    out = {"case": f"sweep_{tag}", "date": DATE, "serverInfo": m.server_info, "stages": {}}
    try:
        out["rom"] = identity(m, tag)
        # title, early (Start gated), then late (Start accepted)
        prep_stage(m, tag, "title")
        rows, res = run_sweep(m, BTNS, f"{tag}/title-early", FX_TITLE)
        out["stages"]["title_early"] = rows
        prep_stage(m, tag, "title")
        adv(m, 440)
        late = [b for b in BTNS if b != "start"] + ["start"]
        rows, res = run_sweep(m, late, f"{tag}/title-late", FX_TITLE)
        out["stages"]["title_late"] = rows
        for st in ("diary_main", "diary_slots", "diary_erase", "diary_copy", "diary_snd"):
            allrows = []
            for b in BTNS:
                prep_stage(m, tag, st)
                rows, res = run_sweep(m, [b], f"{tag}/{st}", FX_DIARY)
                allrows += rows or []
            out["stages"][st] = allrows
    finally:
        m.close()
    return out


# --------------------------------------------------------------------------------------------------
# OQ-I057-1 flows: start a game with each button type, read the remap words, sweep the physical buttons in the game scene
# --------------------------------------------------------------------------------------------------
REMAP_ADDRS = [0x0DA6, 0x0DA8, 0x0DAA, 0x0DAC, 0x0DAE, 0x0DB0, 0x0DB2, 0x0DB4]
REMAP_NAMES = ["remapR", "remapL", "remapB", "remapA", "remapY", "remapX", "remapStart", "remapSelect"]
FX_GAME = 'function() return string.format("sc=%04X/%04X", kit.r16(0x644), kit.r16(0x642)) end'


def remaps(m):
    b = m.mem(0x0DA6, 16)
    return {n: f"{b[2*i] | (b[2*i+1] << 8):04X}" for i, n in enumerate(REMAP_NAMES)}


def dstate(m):
    g = lambda a: f"{m.u16(a):04X}"  # noqa: E731
    return {"scene": g(0x644), "next": g(0x642), "tab": g(0xD98), "cur": g(0xD92), "edit": g(0xD94), "tgt": g(0xD96), "sound": g(0xD90), "btn": g(0xD8E),
            "b24": g(0xB24), "b26": g(0xB26), "slots": [g(0xD74), g(0xD76), g(0xD78)]}


def flow_game(m, tag, kind):
    """kind: load0 (Type 1 slot), load1 (Type 2 slot), new1 (new game, Type 1), new2 (new game, Type 2). Returns log + remap words + sweep rows."""
    log = []
    load_state(m, STATE_NAMES[tag]["diary"])
    log.append(("diary", dstate(m), remaps(m)))
    press(m, ["a"], 2, 40)                      # Start Journey -> slot list
    log.append(("slot list", dstate(m), remaps(m)))
    # the slot cursor move starts DiaryCameraPan (input is ignored while it runs): 90 frames per step
    if kind == "load1":
        press(m, ["down"], 2, 90)
    if kind in ("new1", "new2"):
        press(m, ["down"], 2, 90)
        press(m, ["down"], 2, 90)
    log.append(("slot cursor", dstate(m), remaps(m)))
    shots = {}
    if kind.startswith("new"):
        press(m, ["a"], 2, 60)                  # empty slot -> arrangement screen
        log.append(("arrangement", dstate(m), remaps(m)))
        shots["arrangement_default"] = m.shot(f"M2_arrange_{tag}_{kind}_default").get("path")
        if kind == "new2":
            press(m, ["down"], 2, 12)
            press(m, ["down"], 2, 12)
            press(m, ["a"], 2, 20)              # toggle Button Type
            log.append(("button type toggled", dstate(m), remaps(m)))
            shots["arrangement_type2"] = m.shot(f"M2_arrange_{tag}_{kind}_type2").get("path")
            press(m, ["up"], 2, 12)
            press(m, ["up"], 2, 12)
        press(m, ["a"], 2, 4)                   # Start Journey row
    else:
        press(m, ["a"], 2, 4)                   # load the slot
    log.append(("started +4", dstate(m), remaps(m)))
    adv(m, 600)
    log.append(("scene +600", dstate(m), remaps(m)))
    shots["game"] = m.shot(f"M2_game_{tag}_{kind}").get("path")
    rows, res = run_sweep(m, BTNS, f"{tag}/{kind}", FX_GAME)
    return {"kind": kind, "log": log, "sweep": rows, "shots": shots, "rawReads": (res or {}).get("rawReads")}


def case_flows(tag):
    m = start()
    out = {"case": f"flows_{tag}", "date": DATE, "serverInfo": m.server_info, "flows": []}
    try:
        out["rom"] = identity(m, tag)
        for kind in ("load0", "load1", "new1", "new2"):
            out["flows"].append(flow_game(m, tag, kind))
    finally:
        m.close()
    return out


# --------------------------------------------------------------------------------------------------
# OQ-I057-6: erase flow with watchers
# --------------------------------------------------------------------------------------------------
def erase_marks(tag):
    """Exec marks inside DiaryEraseExecute: label offset L (PlaySoundCh2) + 0 / 3 / 5 / 8 / 12 / 15 / 17 / 19 / 21 / 24 / 27 (O: 781165)."""
    if tag == "O":
        L = 781165
        dec = 781132
        conf = 781040
    else:
        d = json.load(open(os.path.join(BASEROM, "artifacts", "master-lookup.json")))
        L = int(d["DIARYERASEEXECUTE"], 16)
        dec = int(d["DIARYERASEDECLINE"], 16)
        conf = None
    names = {"Exec_PlaySound": 0, "Exec_SetEntryHere": 3, "Exec_LdaD94": 5, "Exec_ClearSlot": 8, "Exec_WaitByte": 12, "Exec_LdaActor1C": 15,
             "Exec_StaActor1A": 17, "Exec_StzActor1C": 19, "Exec_ClearVram": 21, "Exec_Scan": 24, "Exec_Loop": 27}
    return {k: L + v for k, v in names.items()}, L, dec


def lua_marks_dict(d):
    return "{" + ", ".join(f"{k}={v}" for k, v in d.items()) + "}"


def case_erase(tag):
    m = start()
    out = {"case": f"erase_{tag}", "date": DATE, "serverInfo": m.server_info, "steps": []}
    try:
        out["rom"] = identity(m, tag)
        marks, L, dec = erase_marks(tag)
        out["label"] = L
        marks["Decline"] = dec
        load_state(m, STATE_NAMES[tag]["diary"])
        code = f"m2.diaryWatch{{slot=0x1000, marks={lua_marks_dict(marks)}}}"
        out["lua"] = code
        m.call("load_script", code=code, name="m2_erase", includes=INCL)
        adv(m, 2)

        def snap(label):
            out["steps"].append({"label": label, "dstate": dstate(m), "remaps": remaps(m), "actor": {hex(a): f"{m.u16(0x1000 + a):04X}" for a in (0x18, 0x1A, 0x1C, 0x1E)},
                                 "d94": f"{m.u16(0xD94):04X}", "d92": f"{m.u16(0xD92):04X}", "frame": m.u16(0x36)})
        snap("diary main")
        press(m, ["down"], 2, 12)
        press(m, ["a"], 2, 40)
        snap("erase list")
        press(m, ["down"], 2, 90)               # slot 1 (Itory, used)
        snap("erase list cursor 1")
        press(m, ["a"], 2, 60)                  # prompt
        snap("prompt")
        m.shot(f"M2_erase_{tag}_prompt")
        press(m, ["down"], 2, 20)               # Yes
        snap("prompt Yes")
        press(m, ["a"], 2, 20)
        snap("exec +20")
        adv(m, 60)
        snap("exec +80")
        adv(m, 120)
        snap("after")
        m.shot(f"M2_erase_{tag}_after")
        # leave the erase list and use the slot list to see later reads of $0D94
        press(m, ["b"], 2, 40)
        snap("back to main")
        press(m, ["a"], 2, 40)
        snap("slot list")
        press(m, ["down"], 2, 90)
        snap("slot list cursor 1 (erased, empty)")
        press(m, ["a"], 2, 60)
        snap("empty slot chosen (arrangement)")
        m.shot(f"M2_erase_{tag}_arrangement")
        press(m, ["b"], 2, 60)
        snap("arrangement B")
        out["result"] = m.call("get_script_result", name="m2_erase")
        out["slot1_sram_hdr"] = m.mem(0x200 + 512, 8, "snesSaveRam").hex()
    finally:
        m.close()
    return out


def sram_page_bytes(m, n):
    return m.mem(0x200 + n * 512, 512, "snesSaveRam")


def case_copy(tag):
    m = start()
    out = {"case": f"copy_{tag}", "date": DATE, "serverInfo": m.server_info, "steps": []}
    try:
        out["rom"] = identity(m, tag)
        load_state(m, STATE_NAMES[tag]["diary"])
        code = "m2.diaryWatch{slot=0x1000, marks={}}"
        out["lua"] = code
        m.call("load_script", code=code, name="m2_copy", includes=INCL)
        adv(m, 2)

        def snap(label):
            out["steps"].append({"label": label, "dstate": dstate(m), "d94": f"{m.u16(0xD94):04X}", "d96": f"{m.u16(0xD96):04X}", "d92": f"{m.u16(0xD92):04X}",
                                 "slots": [f"{m.u16(0xD74 + 2 * i):04X}" for i in range(3)], "frame": m.u16(0x36)})
        snap("diary main")
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90)   # Copy tab (tab 2)
        snap("tab cursor")
        press(m, ["a"], 2, 60)
        snap("copy source list")
        m.shot(f"M2_copy_{tag}_source")
        p0, p1, p2 = (sram_page_bytes(m, i) for i in range(3))
        out["before"] = {"p0==p2": p0 == p2, "p0_sha1": hashlib.sha1(p0).hexdigest(), "p2_sha1": hashlib.sha1(p2).hexdigest(), "p2_all00": set(p2) == {0}}
        press(m, ["a"], 2, 60)
        snap("copy target list (source slot 0)")
        m.shot(f"M2_copy_{tag}_target")
        press(m, ["a"], 2, 30)
        snap("copy executed +30")
        adv(m, 90)
        snap("copy executed +120")
        m.shot(f"M2_copy_{tag}_after")
        p0, p1, p2 = (sram_page_bytes(m, i) for i in range(3))
        out["after"] = {"p0==p2": p0 == p2, "p0_sha1": hashlib.sha1(p0).hexdigest(), "p2_sha1": hashlib.sha1(p2).hexdigest(),
                        "diff_bytes": sum(1 for a, b in zip(p0, p2) if a != b)}
        # source list again; leave with B, then try the erase tab on an EMPTY slot (erase slot 2 first = a used slot, then slot 2 is empty again)
        press(m, ["b"], 2, 60)
        snap("back at main")
        out["result"] = m.call("get_script_result", name="m2_copy")
    finally:
        m.close()
    return out


def case_erase_empty(tag):
    """Erase tab on an empty slot (slot 2 of the seeded diary): prompt or immediate erase?"""
    m = start()
    out = {"case": f"erase_empty_{tag}", "date": DATE, "serverInfo": m.server_info, "steps": []}
    try:
        out["rom"] = identity(m, tag)
        load_state(m, STATE_NAMES[tag]["diary"])
        code = "m2.diaryWatch{slot=0x1000, marks={}}"
        out["lua"] = code
        m.call("load_script", code=code, name="m2_eempty", includes=INCL)
        adv(m, 2)

        def snap(label):
            out["steps"].append({"label": label, "dstate": dstate(m), "d94": f"{m.u16(0xD94):04X}", "d92": f"{m.u16(0xD92):04X}",
                                 "slots": [f"{m.u16(0xD74 + 2 * i):04X}" for i in range(3)], "frame": m.u16(0x36), "remaps": remaps(m)})
        press(m, ["down"], 2, 90)
        press(m, ["a"], 2, 60)
        snap("erase list")
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90)
        snap("erase list cursor 2 (empty)")
        m.shot(f"M2_eraseempty_{tag}_before")
        press(m, ["a"], 2, 60)
        snap("A on empty slot")
        m.shot(f"M2_eraseempty_{tag}_after")
        adv(m, 90)
        snap("+90")
        out["result"] = m.call("get_script_result", name="m2_eempty")
    finally:
        m.close()
    return out


def case_natural(tag):
    """Natural-flow re-confirmation: camera pan targets of the Start Journey list (OQ-I056-8) and consecutive-frame screenshots of the copy-source band (OQ-I057-3)."""
    m = start()
    out = {"case": f"natural_{tag}", "date": DATE, "serverInfo": m.server_info, "pan": [], "frames": []}
    try:
        out["rom"] = identity(m, tag)
        load_state(m, STATE_NAMES[tag]["diary"])
        adv(m, 2)
        press(m, ["a"], 2, 120)                       # Start Journey list (tab 0), cursor = last slot $0D8C
        def cam(label):
            out["pan"].append({"label": label, "cursor": f"{m.u16(0xD92):04X}", "slots": [f"{m.u16(0xD74 + 2 * i):04X}" for i in range(3)],
                               "cameraTargetX": f"{m.u16(0x6BE):04X}", "cameraTargetY": f"{m.u16(0x6C2):04X}", "cameraX": f"{m.u16(0x6BA):04X}" if False else None})
        cam("start list, first settle")
        press(m, ["down"], 2, 120); cam("cursor down (slot 1, Itory)")
        press(m, ["down"], 2, 120); cam("cursor down (slot 2, empty)")
        press(m, ["down"], 2, 120); cam("cursor down (wrap to slot 0)")
        press(m, ["up"], 2, 120); cam("cursor up (wrap to slot 2)")
        press(m, ["up"], 2, 120); cam("cursor up (slot 1)")
        press(m, ["up"], 2, 120); cam("cursor up (slot 0)")
        m.shot(f"M2_natpan_{tag}")
        press(m, ["b"], 2, 80)
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90)
        press(m, ["a"], 2, 90)                         # copy source list
        out["copy_source"] = {"cursor": f"{m.u16(0xD92):04X}", "d96": f"{m.u16(0xD96):04X}"}
        ctrl = []
        for i in range(6):                              # source loop, no target set: the band must be steady
            ctrl.append(m.shot(f"M2_natband_{tag}_source{i}")); adv(m, 1)
        out["frames_source_loop"] = ctrl
        press(m, ["a"], 2, 60)                          # target loop: source 0, target cursor = first empty slot
        out["copy_target"] = {"d92": f"{m.u16(0xD92):04X}", "d96": f"{m.u16(0xD96):04X}"}
        shots = []
        for i in range(6):
            shots.append(m.shot(f"M2_natband_{tag}_target{i}")); adv(m, 1)
        out["frames"] = shots
        out["raw_first"] = shots[0]
    finally:
        m.close()
    return out


def case_flicker(tag):
    m = start()
    out = {"case": f"flicker_{tag}", "date": DATE, "rows": []}
    try:
        out["rom"] = identity(m, tag)
        load_state(m, STATE_NAMES[tag]["diary"])
        adv(m, 2)
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90); press(m, ["a"], 2, 90); press(m, ["a"], 2, 120)
        out["cursors"] = {"d92": f"{m.u16(0xD92):04X}", "d96": f"{m.u16(0xD96):04X}", "d98": f"{m.u16(0xD98):04X}"}
        for i in range(16):
            r = m.shot(f"M2_flick_{tag}_{i}")
            out["rows"].append({"frame": r["frame"], "n36": m.u16(0x36), "hdma66": f"{m.u16(0x66) & 0xFF:02X}", "sha1": r["sha1"][:8]})
            adv(m, 1)
    finally:
        m.close()
    return out


def case_flicker_trace(tag):
    m = start()
    out = {"case": f"flicker_trace_{tag}", "date": DATE}
    try:
        out["rom"] = identity(m, tag)
        if tag == "O":
            base, ctl = 48049, 33663
        else:
            d = json.load(open(os.path.join(BASEROM, "artifacts", "master-lookup.json")))
            base = int(d["CODE_00BBB1"], 16)
            ctl = None
        # offsets inside the thinker (from O): start 0, LSR/BCC fall-through to the empty-table queue at +22, slot-band queue calls at +32 / +42 / +51 / +69
        marks = {"start": base, "emptyQueue": base + 22, "slot1": base + 32, "slot2": base + 43, "slot3": base + 51}
        load_state(m, STATE_NAMES[tag]["diary"])
        adv(m, 2)
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90); press(m, ["a"], 2, 90); press(m, ["a"], 2, 120)
        out["cursors"] = {"d92": f"{m.u16(0xD92):04X}", "d96": f"{m.u16(0xD96):04X}"}
        code = "m2.execCount{marks=" + lua_marks_dict(marks) + ", parityMark='start', frames=20}"
        out["lua"] = code
        m.call("load_script", code=code, name="m2_flick", includes=INCL)
        adv(m, 24)
        out["result"] = m.call("get_script_result", name="m2_flick")
    finally:
        m.close()
    return out


def case_dma(tag):
    """HDMA channel state in the copy target loop (O flickers, R does not show the target band)."""
    m = start()
    out = {"case": f"dma_{tag}", "date": DATE, "frames": []}
    try:
        out["rom"] = identity(m, tag)
        load_state(m, STATE_NAMES[tag]["diary"])
        adv(m, 2)
        press(m, ["down"], 2, 90); press(m, ["down"], 2, 90); press(m, ["a"], 2, 90); press(m, ["a"], 2, 120)
        for i in range(2):
            st = m.call("get_dma_state")
            out["frames"].append(st)
            adv(m, 1)
    finally:
        m.close()
    return out


def case_softreset(tag):
    """OQ-I055-3: flag $10 ($0A02 bit 0) set after the first logo; soft reset; which logo plays and what is $0A02."""
    m = start()
    out = {"case": f"softreset_{tag}", "date": DATE, "rows": []}
    try:
        out["rom"] = identity(m, tag)
        code = "m2.boot{frames=0, marks={}}" if False else None
        def row(label):
            out["rows"].append({"label": label, "frame": m.call("get_emulator_state").get("frameCount") if False else None, "A02": f"{m.u16(0xA02) & 0xFF:02X}", "scene": f"{m.u16(0x642) & 0xFF:02X}",
                                "n36": m.u16(0x36), "inidisp": f"{m.u16(0x1F8) & 0xFF:02X}" if False else None})
        adv(m, 240); row("boot +240 (first logo done, second logo running)")
        m.shot(f"M2_softreset_{tag}_before")
        out["reset"] = m.call("reset", mode="soft")
        adv(m, 2); row("reset +2")
        for k in (60, 100, 140, 200, 260):
            adv(m, k - (0 if k == 60 else prev)); prev = k
            row(f"reset +{k}")
            m.shot(f"M2_softreset_{tag}_{k}")
            if k == 60: prev = 60
    finally:
        m.close()
    return out


CASES = {
    "h1all": case_h1all,
    "soft_O": lambda: case_softreset("O"),
    "dma_O": lambda: case_dma("O"),
    "dma_R": lambda: case_dma("R"),
    "ftrace_O": lambda: case_flicker_trace("O"),
    "ftrace_R": lambda: case_flicker_trace("R"),
    "flicker_O": lambda: case_flicker("O"),
    "flicker_R": lambda: case_flicker("R"),
    "natural_O": lambda: case_natural("O"),
    "natural_R": lambda: case_natural("R"),
    "copy_O": lambda: case_copy("O"),
    "copy_R": lambda: case_copy("R"),
    "eempty_O": lambda: case_erase_empty("O"),
    "eempty_R": lambda: case_erase_empty("R"),
    "erase_O": lambda: case_erase("O"),
    "erase_R": lambda: case_erase("R"),
    "flows_O": lambda: case_flows("O"),
    "flows_R": lambda: case_flows("R"),
    "sweep_O": lambda: case_sweep("O"),
    "sweep_R": lambda: case_sweep("R"),
    "boot_O": lambda: case_boot("O"),
    "boot_R": lambda: case_boot("R"),
    "logo_poke": case_logo_poke,
    "mkstates_O": lambda: case_mkstates("O"),
    "mkstates_R": lambda: case_mkstates("R"),
    "title_O": lambda: case_title_boot("O"),
    "title_R": lambda: case_title_boot("R"),
}

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("cases", nargs="*")
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    if a.list:
        for k in CASES:
            print(k)
        sys.exit(0)
    for c in a.cases:
        o = CASES[c]()
        p = dump(o, c)
        print("wrote", p)
