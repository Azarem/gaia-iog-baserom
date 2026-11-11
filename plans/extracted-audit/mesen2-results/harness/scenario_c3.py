#!/usr/bin/env python3
"""C3 (boot, reset, MEMSEL, warmboot byte, event flag $10): one fresh server session per case, ROM O, module kit/lib/c3_boot.lua.

usage: python scenario_c3.py --list | [--only cold_a,soft_83,...]
Cases (see CASES): cold boots (power) and soft-reset cases (pokes before `reset {mode:"soft"}`, WRAM kept).
Writes raw/C3_<case>_<yyyymmdd>.json (replies, Lua text, ROM identity, pokes, WRAM read back after the reset) and screenshots
under raw/screenshots/. Edits nothing outside mesen2-results/.
"""
import argparse
import datetime
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
LABELS_O = os.path.join(BASEROM, "artifacts", "labels", "iog-original.mlb")
RAW = os.path.join(RESULTS, "raw")
DATE = datetime.date.today().strftime("%Y%m%d")
NMI = 33528

# decimal PRG offsets (db-us/names keys; the instruction offsets inside SystemInit from get_disassembly of $80:8014)
MARKS = {
    "ResetVector": 32768,
    "SystemInit": 32788,
    "StaMemsel1": 32807,            # $80:8027 STA $420D (the first MEMSEL write, value 1)
    "InitHardwareRegisters": 171825,
    "InitSystemVariables": 171588,
    "SpcLoadBuiltinEngine": 168078,
    "SpcBlockTransfer": 168091,
    "AfterSpcLoad": 32822,          # $80:8036 JSL EnterForcedBlank (the instruction after the SPC upload returns)
    "EnterForcedBlank": 164284,
    "AfterForcedBlank": 32826,      # $80:803A SEC
    "LdaWarm": 32830,               # $80:803E LDA $000100
    "BeqWarm": 32839,               # $80:8047 BEQ (taken when the byte is $83)
    "LdyNonWarm": 32841,            # $80:8049 LDY #$0000 (skipped when the BEQ is taken)
    "TyaJoin": 32844,               # $80:804C TYA
    "StaSceneNext": 32845,          # $80:804D STA $0642
    "ExecuteSceneTransition": 252406,
    "AfterSceneTransition": 32852,  # $80:8054 STZ $0654
    "BootLogoInit": 772285,
    "BootLogoNtsc": 772330,
    "BootLogoSecondPhase": 772367,
    "NmiHandler": 33528,
}
MARKS_LUA = "{" + ", ".join(f"{k}={v}" for k, v in MARKS.items()) + "}"
LUA = f"c3.run{{frames=%d, nmi={NMI}, marks={MARKS_LUA}}}"

# case -> dict(kind, phases (cumulative-free list of frame counts of each run), shots (label per phase or None), pre, pokes)
CASES = {
    "cold_a": dict(kind="cold", phases=[120, 160, 160], shots=["C3_cold_f120", "C3_cold_f280", "C3_cold_f440"],
                   desc="cold boot (power), no input: 120 / 280 / 440 frames, screenshots"),
    "cold_b": dict(kind="cold", phases=[120, 160, 160], shots=[None, None, None], desc="cold boot repeat (determinism)"),
    "cold_fast": dict(kind="cold", phases=[120], shots=[None], patch4B=1,
                      desc="disposable ROM patch: PpuRegisterInitTable entry 4B (MEMSEL) value 0 -> 1 in memory; cold boot"),
    "soft_ctl": dict(kind="soft", pre=450, pokes=[], phases=[130, 300], shots=["C3_soft_ctl_f130", None],
                     desc="title (frame 450), no poke, reset soft"),
    "soft_83": dict(kind="soft", pre=450, pokes=[("w0100", 0x0100, [0x83])], phases=[130, 300], shots=["C3_soft_83_f130", None],
                    desc="title, $0100 = $83, reset soft"),
    "soft_00": dict(kind="soft", pre=450, pokes=[("w0100", 0x0100, [0x00])], phases=[130, 300], shots=[None, None],
                    desc="title, $0100 = $00, reset soft"),
    "soft_5A": dict(kind="soft", pre=450, pokes=[("w0100", 0x0100, [0x5A])], phases=[130, 300], shots=[None, None],
                    desc="title, $0100 = $5A, reset soft"),
    "flag_poke": dict(kind="soft", pre=450, pokes=[("flag10", 0x0A02, [0x01])], phases=[130, 300], shots=["C3_flag_poke_f130", None],
                      desc="title, event flag $10 (byte $0A02 bit 0) set, reset soft"),
    "flag_natural": dict(kind="soft", pre=260, pokes=[], phases=[130, 300], shots=["C3_flag_natural_f130", None],
                         desc="reset soft during the second logo (flag $10 set by the game), no poke"),
}


def lua_for(frames):
    return LUA % frames


def run(name):
    sc = CASES[name]
    m = Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"])
    out = {"case": name, "desc": sc["desc"], "date": DATE, "serverInfo": m.server_info, "phases": []}
    try:
        out["status"] = m.call("get_server_status")
        r = m.call("load_rom", path=ROM_O, paused=True)
        out["rom"] = r.get("rom")
        out["boot"] = r.get("boot")
        m.call("load_labels", path=LABELS_O, replace=True)
        out["nmiLabel"] = m.call("get_label_address", label="NmiHandler")
        if sc.get("patch4B") is not None:
            tbl = m.call("get_label_address", label="PpuRegisterInitTable")
            out["tableLabel"] = tbl
            addr = tbl["address"] + 0x4B * 3
            before = m.call("read_memory", address=addr, length=3, type="snesPrgRom", format="bytes")
            out["entry4B_before"] = before
            if before["bytes"] != [0x0D, 0x42, 0x00]:
                raise RuntimeError(f"entry 4B is not [0D 42 00]: {before}")
            out["patch"] = m.call("write_memory", address=addr + 2, data=[sc["patch4B"]], type="snesPrgRom")
            out["entry4B_after"] = m.call("read_memory", address=addr, length=3, type="snesPrgRom", format="bytes")
        if sc["kind"] == "soft":
            pre = m.run_script_checked(lua_for(sc["pre"]), ok_stop=("script_done",), frames=sc["pre"] + 5, includes=["gaia_kit", "c3_boot"],
                                       turbo=True, maxLog=5, name="c3_boot")
            out["pre"] = {"frames": pre.get("framesAdvanced"), "result": pre.get("result")}
            for label, addr, data in sc["pokes"]:
                out.setdefault("pokes", []).append({"label": label, "address": addr, "data": data,
                                                    "write": m.call("write_memory", address=addr, data=data, type="workRam")})
            out["preReadback"] = {"w0100": m.u8(0x0100), "w0A02": m.u8(0x0A02)}
            rr = m.call("reset", mode="soft")
            out["reset"] = rr
            out["postResetReadback"] = {"w0100": m.u8(0x0100), "w0A02": m.u8(0x0A02), "w0644": m.u16(0x0644), "w0642": m.u16(0x0642)}
            out["postResetState"] = m.call("get_emulator_state")
        for i, fr in enumerate(sc["phases"]):
            rep = m.run_script_checked(lua_for(fr), ok_stop=("script_done",), frames=fr + 5, includes=["gaia_kit", "c3_boot"],
                                       turbo=True, maxLog=5, name="c3_boot")
            ph = {"frames": fr, "reply": {k: rep.get(k) for k in ("stopReason", "framesAdvanced", "frame", "cpu", "result", "log")}}
            lab = sc["shots"][i]
            if lab:
                ph["shot"] = m.shot(lab)
            out["phases"].append(ph)
        out["finalState"] = m.call("get_emulator_state")
    finally:
        m.close()
    path = os.path.join(RAW, f"C3_{name}_{DATE}.json")
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1)
    return out, path


def hx(v, w=2):
    return format(v, f"0{w}X") if isinstance(v, int) else str(v)


def summary(out):
    print(f"== {out['case']}: {out['desc']}")
    rom = out.get("rom") or {}
    print("  rom", rom.get("fileSha1"), rom.get("fileCrc32"), rom.get("fileSizeBytes"), "server", out["serverInfo"].get("version"))
    if "pre" in out:
        pr = (out["pre"].get("result") or {})
        print("  pre end", pr.get("endFrame"), "endState", pr.get("endState"))
    for k in ("pokes", "preReadback", "postResetReadback"):
        if k in out:
            print(" ", k, json.dumps(out[k])[:300])
    if "reset" in out:
        print("  reset cpu", json.dumps((out["reset"].get("cpu") or out["reset"]))[:200])
    for i, ph in enumerate(out["phases"]):
        res = ph["reply"].get("result") or {}
        print(f"  -- phase {i} frames {ph['frames']} stop {ph['reply'].get('stopReason')} adv {ph['reply'].get('framesAdvanced')} endFrame {res.get('endFrame')}")
        print("     start", res.get("start"))
        print("     control", res.get("control"), "endState", res.get("endState"))
        mk = res.get("marks") or {}
        print("     marks", {k: (v.get("n"), v.get("first"), v.get("last"), v.get("fast"), v.get("spd")) for k, v in sorted(mk.items(), key=lambda kv: (kv[1].get("first") is None, kv[1].get("first") or 0))})
        print("     seq", res.get("seq"))
        print("     memsel", res.get("memsel"))
        a = res.get("apuio") or {}
        print("     apuio n", a.get("n"), "first", a.get("first"), a.get("firstPc"), "last", a.get("last"), "frames", a.get("frames"), "fastHist", a.get("fastHist"), "spdHist", a.get("spdHist"))
        pf = a.get("perFrame") or {}
        print("     apuio perFrame", {k: pf[k] for k in sorted(pf, key=int) if int(k) <= 40} if i == 0 else "(see raw)")
        print("     marks mc", {k: v.get("mc") for k, v in sorted(mk.items(), key=lambda kv: (kv[1].get("mc") is None, kv[1].get("mc") or 0)) if v.get("mc") is not None})
        print("     inidisp", res.get("inidisp"), "firstOn", res.get("firstDisplayOn"))
        print("     wram", res.get("wram"))
        print("     fast", res.get("fast"))
        print("     scene", res.get("scene"))
        if res.get("curDelta"):
            print("     curDelta", res.get("curDelta"))
        if ph.get("shot"):
            print("     shot", ph["shot"].get("path"), ph["shot"].get("frame"))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    if a.list:
        for k, v in CASES.items():
            print(k, "-", v["desc"])
        sys.exit(0)
    names = [n for n in (a.only.split(",") if a.only else CASES) if n]
    for n in names:
        o, p = run(n)
        summary(o)
        print("  ->", p)
