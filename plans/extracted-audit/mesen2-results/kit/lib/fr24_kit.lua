-- description: FR24 area-trial helpers on top of fr23_kit (Native Village / Dao / Angkor Wat / Pyramid / Babel Tower / ending trials).
-- requires: fr23_kit
--
-- Load with run_script includes=["fr24_kit"] (the server resolves "requires": fr23_kit, fr22_kit, fr21_kit, fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Writes use emu.write (they do not fire memory callbacks).
--
--   fr24.byId(lo, hi)        first live actor whose entry pc low word is in [lo, hi] (same as fr21.find) or nil
--   fr24.names(files)        placeholder (actor file names are decoded on the Python side from the entry offset)
--   fr24.flag(n)             1 or 0: global flag index n (byte 0x0A00 + (n >> 3), bit n & 7)
--   fr24.rec(n)              compact observation row: scene, mask, dialog window flag, player tile, $0AA6 ... (used by `rec` rows)
fr24 = fr24 or {}

function fr24.byId(lo, hi) return fr21.find(lo, hi) end

function fr24.flag(n) return (kit.r8(0x0A00 + (n >> 3)) >> (n & 7)) & 1 end

function fr24.rec(n)
  return { n = n, sc = kit.r16(0x0644), mask = kit.r16(0x065A), dlg = fr22.dlg() and 1 or 0, tile = { kit.r16(0x09A6), kit.r16(0x09A8) },
           p = { kit.r16(0x1014), kit.r16(0x1016) } }
end

-- read the collision byte of a cell (tx, ty) through the paged layout; returns the full byte (low nibble = base type, high nibble = dynamic mark)
function fr24.cell(tx, ty) return gaia.coll.get(tx, ty) end
