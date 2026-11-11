#!/usr/bin/env python3
"""FR10 validation of the natural states and the standing positive controls (writes raw/FR10_verify.json only).

  python fr10_verify.py

Per natural state orig_N01 / N02 / N03: load, advance 120 frames with a persistent `$36` write counter, then k in $80-$CF, sp in $0100-$01FF, scene as
saved (H1), the flag array at that point and the key-item slots. Then the NMI exec mark (offset 33528) and the `$36` write count over 300
frames (control), and the standing control scene $0A with and without flag 63 (`run_recipe warp`, the mask must reach 0000 only with 63).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import RAW, STATE_DIR  # noqa: E402
from fr10 import open_o, set_flags  # noqa: E402

STATES = [("N01", "orig_N01_sc_first_free.mss", 1), ("N02", "orig_N02_wills_house_after_feast.mss", 6), ("N03", "orig_N03_castle_gate.mss", 0x0A)]

H1 = (
    "local n = 0\n"
    "emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then n = n + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)\n"
    "local marks = gaia.execMarks{ nmi = 33528 }\n"
    "local f = 0\n"
    "kit.onFrame(function()\n"
    "  f = f + 1\n"
    "  if f == 120 then\n"
    "    local s = emu.getState()\n"
    "    kit.finish({ k = s['cpu.k'], sp = s['cpu.sp'], pc = s['cpu.pc'], scene = kit.r16(0x644), w36 = n, nmi = marks.n.nmi, frame = s.frameCount })\n"
    "  end\n"
    "end)\n"
)


def main():
    out = {"states": {}, "controls": {}}
    m, info = open_o()
    try:
        out["rom"] = {"sha1": info["fileSha1"], "size": info.get("fileSize"), "path": info.get("path")}
        out["romInfo"] = m.call("get_rom_info")
        for tag, fn, scene in STATES:
            path = os.path.join(STATE_DIR, fn)
            runs = []
            for _ in range(2):
                m.call("load_state_file", path=path)
                r = m.run_script_checked(H1, includes=["gaia_kit"], frames=125, turbo=True, name=f"FR10_h1_{tag}")
                res = r["result"]
                res["ok"] = (0x80 <= res["k"] <= 0xCF) and (0x0100 <= res["sp"] <= 0x01FF) and res["scene"] == scene and res["w36"] > 0 and res["nmi"] > 0
                runs.append(res)
            raw = m.mem(0x0A00, 180)
            out["states"][tag] = {"file": fn, "h1": runs, "flags": set_flags(raw), "bytes0A00": {f"{0x0A00 + i:04X}": f"{b:02X}" for i, b in enumerate(raw) if b},
                                  "inventory0AB4": m.mem(0x0AB4, 24).hex()}
        # standing control: scene $0A with and without flag 63, from N02 (flag 63 clear there; N03 already holds flag 63)
        for tag, flags in (("with63", [63]), ("without", [])):
            m.call("load_state_file", path=os.path.join(STATE_DIR, STATES[1][1]))
            r = m.call("run_recipe", name="warp", args={"scene": 10, "flags": flags}, frames=1500)
            m.call("advance_frame", frames=60)
            out["controls"][tag] = {"recipe": r.get("result"), "stop": r.get("stopReason"), "framesAdvanced": r.get("framesAdvanced"),
                                    "maskAfter60": m.u16(0x065A), "scene": m.u16(0x0644), "flag63": (m.u8(0x0A07) >> 7) & 1}
    finally:
        m.close()
    with open(os.path.join(RAW, "FR10_verify.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1, default=str)
    for tag, v in out["states"].items():
        print(tag, [(x["k"], x["sp"], x["scene"], x["w36"], x["nmi"], x["ok"]) for x in v["h1"]], "flags", len(v["flags"]))
    print(json.dumps(out["controls"], default=str)[:800])


if __name__ == "__main__":
    main()
