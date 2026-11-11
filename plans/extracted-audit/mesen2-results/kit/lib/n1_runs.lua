-- description: N1 experiment bodies (one function per scene/question). Each takes the m1 driver `m` and runs inside m1.run.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit
n1r = n1r or {}

-- poll helper: log when any watched WRAM word changes (name -> address)
local function watcher(map)
  local last = {}
  for k, a in pairs(map) do last[k] = kit.r16(a) end
  return function(tag)
    for k, a in pairs(map) do
      local v = kit.r16(a)
      if v ~= last[k] then
        m1.log("%s t=%d %s %04X -> %04X", tag or "W", n1.t, k, last[k], v)
        last[k] = v
      end
    end
  end
end
n1r.watcher = watcher

-- text collector: unique dialogue rows seen
local function textSet()
  local seen, order = {}, {}
  return function()
    for _, row in ipairs(m1.dialogText()) do
      local t = row:sub(5)
      if not seen[t] then seen[t] = true; order[#order + 1] = t; m1.log("TEXT t=%d %s", n1.t, t) end
    end
  end
end
n1r.textSet = textSet

-- talk to the actor at slot `s`: teleport south of it (dx, dy offset), face it, press A and pulse A through the dialogue.
function n1r.talk(m, s, dx, dy, dir, nframes, o)
  o = o or {}
  local ax, ay = kit.r16(s + 0x14), kit.r16(s + 0x16)
  n1.teleport(ax + dx, ay + dy)
  m.wait(10)
  n1.face(dir, 8)
  m.wait(4)
  local w = o.watch and watcher(o.watch) or function() end
  local txt = textSet()
  m1.log("TALK start t=%d player=(%d,%d) a28=%04X pflags=%04X mask=%04X", n1.t, kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1028), kit.r16(0x09AE), kit.r16(0x065A))
  for i = 1, nframes do
    if i % 8 == 1 then gaia.hold({ o.btn or "b" }) elseif i % 8 == 3 then gaia.release() elseif o.btn2 and i % 8 == 5 then gaia.hold({ o.btn2 }) elseif o.btn2 and i % 8 == 7 then gaia.release() end
    m.wait(1)
    w("TALK")
    if i % 6 == 0 then txt() end
  end
  gaia.release()
end
