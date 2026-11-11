#!/usr/bin/env python3
"""C3 probe: server identity, ROM identity, boot-state facts, disassembly of SystemInit, emulator state keys.

usage: python c3_probe.py   (starts a fresh 0.6.0 server through mcp_client.py; writes raw/C3_probe_<date>.json)
Edits nothing outside mesen2-results/.
"""
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

m = Mesen(args=[f"--mcp-lib-dir={os.path.join(RESULTS, 'kit', 'lib')}", f"--mcp-results-dir={RAW}"])
out = {"date": DATE, "serverInfo": m.server_info}
try:
    out["status"] = m.call("get_server_status")
    out["capsNoRom"] = m.try_call("get_capabilities")
    r = m.call("load_rom", path=ROM_O, paused=True)
    out["load_rom"] = r
    out["caps"] = m.call("get_capabilities")
    out["rom_info"] = m.call("get_rom_info")
    out["labels"] = m.call("load_labels", path=LABELS_O, replace=True)
    for name in ("ResetVector", "SystemInit", "NmiHandler", "InitHardwareRegisters", "InitSystemVariables",
                 "SpcLoadBuiltinEngine", "EnterForcedBlank", "ExecuteSceneTransition", "BootLogoInit",
                 "BootLogoNtsc", "BootLogoSecondPhase"):
        out.setdefault("labelAddr", {})[name] = m.try_call("get_label_address", label=name)
    out["disSystemInit"] = m.call("get_disassembly", address=0x808014, rowCount=45)
    out["stateAtBoot"] = m.call("get_emulator_state")
    probe = r"""
local st = emu.getState()
local keys = {}
for k, v in pairs(st) do
  local ks = tostring(k)
  if ks:lower():find('fast') or ks:lower():find('memsel') or ks:lower():find('rom') or ks:lower():find('speed') then
    keys[#keys + 1] = ks .. '=' .. tostring(v)
  end
end
table.sort(keys)
local all = 0
for _ in pairs(st) do all = all + 1 end
kit.onFrame(function() kit.finish({n = all, keys = keys, frame = st['frameCount']}) end)
"""
    out["stateKeys"] = m.run_script_checked(probe, frames=2, includes=["gaia_kit"], turbo=True, maxLog=20, name="c3_probe")
finally:
    m.close()
path = os.path.join(RAW, f"C3_probe_{DATE}.json")
with open(path, "w", encoding="utf-8") as fh:
    json.dump(out, fh, indent=1)
print("->", path)
print(json.dumps({k: out.get(k) for k in ("serverInfo", "status", "labelAddr")}, indent=1)[:3000])
print(json.dumps(out["load_rom"], indent=1)[:1500])
print(json.dumps(out["stateKeys"].get("result"), indent=1)[:3000])
print(json.dumps(out["disSystemInit"], indent=1)[:6000])
