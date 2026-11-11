#!/usr/bin/env python3
"""C2: disassemble the callers and the three $4200 writers of the O ROM with get_disassembly (read only).
usage: python c2_disasm.py   -> raw/C2_disasm_<date>.json and a printed table"""
import datetime
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
DATE = datetime.date.today().strftime("%Y%m%d")


def cpu(off):
    return ((0x80 | (off >> 16)) << 16) | (off & 0xFFFF)


callers = set()
for p in glob.glob(os.path.join(RESULTS, "raw", f"C2_*_{DATE}.json")):
    d = json.load(open(p, encoding="utf-8"))
    if "reply" not in d:
        continue
    for key in d["reply"]["result"]["entries"]:
        callers.add(int(key.split(" <- ")[1].split()[0], 16))

m = Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"])
out = {"callers": {}, "writers": {}}
try:
    m.call("load_rom", path=ROM_O)
    m.call("pause")
    for off in sorted(callers):
        r = m.call("get_disassembly", address=cpu(off), rowCount=2)
        out["callers"][off] = r
    # writers: the store ends at 164255 / 164268 / 171847 (offsets of the next instruction)
    out["writers"]["EnableNmiAndJoypad"] = m.call("get_disassembly", address=cpu(164241), rowCount=9)
    out["writers"]["DisableNmiKeepJoypad"] = m.call("get_disassembly", address=cpu(164258), rowCount=8)
    out["writers"]["InitHardwareRegisters"] = m.call("get_disassembly", address=cpu(171825), rowCount=16)
finally:
    m.close()
path = os.path.join(RESULTS, "raw", f"C2_disasm_{DATE}.json")
json.dump(out, open(path, "w", encoding="utf-8"), indent=1)
print(json.dumps(next(iter(out["callers"].values())))[:600])
print("->", path)
