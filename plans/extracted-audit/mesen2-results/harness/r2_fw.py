#!/usr/bin/env python3
"""R2 forced-walk probe driver (OQ-I068-4): put the player on a forced-walk warp rectangle of ROM O and watch the ForcedWalk* actor.

usage (from this folder):  timeout 600 python r2_fw.py --tag O_forcedwalk --scenes 3,4,6 [--observe 300]
Entries are read from the ROM (scene_warps, 98868); ForcedWalkSouth/North/West hooks = the instruction after the first ReadDirSprite call.
"""
import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from r2_sweep import ARGS, RAW, ROMS  # noqa: E402

ROM = open(ROMS["O"]["rom"], "rb").read()
SW = 98868
HOOKS = {"south": 60334, "north": 60418, "west": 60502}


def u16(o):
    return ROM[o] | (ROM[o + 1] << 8)


def forced_entries(sid):
    off = 0x10000 + u16(SW + 2 * sid)
    while ROM[off] != 0xFF:
        off += 12
    off += 1
    out = []
    while ROM[off] != 0xFF:
        out.append((off, list(ROM[off:off + 13])))
        off += 13
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", default="O_forcedwalk")
    ap.add_argument("--scenes", required=True)
    ap.add_argument("--observe", type=int, default=300)
    ap.add_argument("--only", default="", help="entry indexes, comma separated (default all)")
    a = ap.parse_args()
    only = {int(x) for x in a.only.split(",")} if a.only else None
    cfg = ROMS["O"]
    m = Mesen(args=ARGS)
    hooks = "{" + ", ".join("%s=%d" % (k, v) for k, v in HOOKS.items()) + "}"
    try:
        m.call("load_rom", path=cfg["rom"])
        m.call("pause")
        m.call("load_labels", path=cfg["labels"], replace=True)
        with open(os.path.join(RAW, f"R2_{a.tag}.jsonl"), "w") as fj:
            for sid in [int(x, 16) for x in a.scenes.split(",")]:
                for k, (off, e) in enumerate(forced_entries(sid)):
                    if only is not None and k not in only:
                        continue
                    m.call("load_state_file", path=cfg["state"])
                    x, y = e[0] * 16 + 8, e[1] * 16 + 16
                    code = "r2w.fw{scene=%d, x=%d, y=%d, hooks=%s, observe=%d, cwr=174459}" % (sid, x, y, hooks, a.observe)
                    try:
                        row = m.run_script_checked(code, frames=1500, includes=["gaia_kit", "r2w_kit"], turbo=True, timeoutMs=120000, maxLog=3, name="r2fw").get("result", {})
                    except Exception as ex:  # noqa: BLE001
                        row = {"why": "error %s" % str(ex)[:160]}
                    row.update({"src": sid, "k": k, "off": off, "entry": e})
                    fj.write(json.dumps(row) + "\n")
                    fj.flush()
                    h = (row.get("hits") or [{}])[0]
                    print("%02X #%d off=%d rect=%s b6=%02X stream=%s -> %s hit=%s" % (sid, k, off, e[:4], e[6], e[7:13], row.get("why"),
                          {kk: (hex(v) if isinstance(v, int) and kk != "nf" else v) for kk, v in h.items()}), flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
