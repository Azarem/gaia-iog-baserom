-- description: FR30 engine/table-domain trial helpers on top of fr24_kit: map-layer rectangle reads (paged map and collision layers), byte-range hex dumps, enemy-slot readers.
-- requires: fr24_kit
--
-- Load with run_script includes=["fr30_kit"] (the server resolves "requires": fr24_kit, fr23_kit, fr22_kit, fr21_kit, fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Writes use emu.write (they do not fire memory callbacks).
--
--   fr30.stride(layer)            page stride of the layer ($0693 layer 0, $0695 layer 1)
--   fr30.idx(tx, ty, layer)       paged map index (TileCoordsToMapIndex: ((ty>>4)*stride + (tx>>4)) << 8 | (ty&15) << 4 | (tx&15))
--   fr30.map(tx, ty, layer)       tile byte of mapLayerTilemap ($7EA000, layer 0) or effectLayerTilemap ($7EC000, layer 1)
--   fr30.rect(tx, ty, w, h, layer) { map = "FA FB/F8 F9", col = "00 00/00 00" } rows separated by "/" (col only for layer 0: collisionLayer $7FC000)
--   fr30.bytes(addr, n)           n bytes of WRAM from addr as one hex string
--   fr30.enemies()                live actors of the list whose stats/enemy slots look like enemies: { slot, pc, x, y, hp, deathIdx, orbit, ext } (HP word $7F0026, deathActionIdx $7F0024)
fr30 = fr30 or {}

function fr30.stride(layer) return kit.r8(layer == 1 and 0x0695 or 0x0693) end

function fr30.idx(tx, ty, layer)
  local stride = fr30.stride(layer)
  return (((((ty >> 4) * stride + (tx >> 4)) & 0xFF) << 8) | ((ty & 15) << 4) | (tx & 15)) & 0x1FFF
end

function fr30.map(tx, ty, layer)
  local base = (layer == 1) and 0xC000 or 0xA000
  return kit.r8(base + fr30.idx(tx, ty, layer))
end

function fr30.rect(tx, ty, w, h, layer)
  local mrows, crows = {}, {}
  for y = ty, ty + h - 1 do
    local m, c = {}, {}
    for x = tx, tx + w - 1 do
      m[#m + 1] = string.format("%02X", fr30.map(x, y, layer))
      if layer ~= 1 then c[#c + 1] = string.format("%02X", gaia.coll.get(x, y)) end
    end
    mrows[#mrows + 1] = table.concat(m, " ")
    crows[#crows + 1] = table.concat(c, " ")
  end
  return { map = table.concat(mrows, "/"), col = (layer ~= 1) and table.concat(crows, "/") or nil }
end

function fr30.bytes(addr, n)
  local t = {}
  for i = 0, n - 1 do t[#t + 1] = string.format("%02X", kit.r8(addr + i)) end
  return table.concat(t)
end

-- enemy-like rows of the live list: every actor with a nonzero HP word ($7F0026 + slot); deathActionIdx = $7F0024 + slot; orbitAngle = $7F0010 + slot (the remaining-enemies count a kill stores)
function fr30.enemies()
  local out = {}
  for _, a in ipairs(fr20.actors()) do
    local hp = emu.read16(0x10026 + a.slot, emu.memType.snesWorkRam, false)
    if hp ~= 0 and a.slot ~= kit.r16(0x09AA) then
      out[#out + 1] = { slot = a.slot, bank = a.bank, pc = a.pc, x = a.x, y = a.y, hp = hp,
                        death = emu.read16(0x10024 + a.slot, emu.memType.snesWorkRam, false),
                        orbit = emu.read16(0x10010 + a.slot, emu.memType.snesWorkRam, false),
                        ext = emu.read16(0x1002A + a.slot, emu.memType.snesWorkRam, false) }
    end
  end
  return out
end
