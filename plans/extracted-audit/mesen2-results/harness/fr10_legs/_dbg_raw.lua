-- debug (not a leg): print the raw collision low nibble of a rectangle of cells (x 18..34, y 12..20)
for ty = 12, 20 do
  local t = {}
  for tx = 18, 34 do t[#t + 1] = string.format("%02X", gaia.coll.get(tx, ty)) end
  emu.log(string.format("%02d %s", ty, table.concat(t, " ")))
end
kit.finish({ ok = true })
