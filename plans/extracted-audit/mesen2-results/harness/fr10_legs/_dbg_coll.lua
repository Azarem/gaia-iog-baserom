-- debug (not a leg): flood-fill the collision layer from the player cell and print the map ('o' = reachable with the pass set, '.' = free-looking but unreachable, others raw low nibble, '*' = high nibble set)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true }
local s = fr10.snap()
local stride, rows = kit.r8(0x0693), kit.r8(0x0697)
local w, h = stride * 16, rows * 16
emu.log(string.format("scene=%02X cells=%dx%d p09A2=%d,%d", s.sc, w, h, s.x, s.y))
local function free(x, y) if x < 0 or y < 0 or x >= w or y >= h then return false end local v = gaia.coll.get(x, y); return PASS[v & 15] and (v >> 4) == 0 end
local seen, q, qi = {}, { { s.x >> 4, s.y >> 4 } }, 1
seen[(s.y >> 4) * w + (s.x >> 4)] = true
while qi <= #q do
  local c = q[qi]; qi = qi + 1
  for _, d in ipairs { {1,0}, {-1,0}, {0,1}, {0,-1} } do
    local nx, ny = c[1] + d[1], c[2] + d[2]
    if free(nx, ny) and not seen[ny * w + nx] then seen[ny * w + nx] = true; q[#q + 1] = { nx, ny } end
  end
end
local maxRow = math.min(h - 1, 63)
for ty = 0, maxRow do
  local t = {}
  for tx = 0, math.min(w - 1, 63) do
    local v = gaia.coll.get(tx, ty)
    local c = string.format("%X", v & 15)
    if (v >> 4) ~= 0 then c = "*" elseif seen[ty * w + tx] then c = "o" elseif free(tx, ty) then c = "." end
    t[#t + 1] = c
  end
  emu.log(string.format("%02d %s", ty, table.concat(t)))
end
kit.finish({ ok = true })
