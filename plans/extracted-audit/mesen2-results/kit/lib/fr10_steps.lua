-- description: FR10 common step conditions for fr10.bot programs (free-control test, busy test, scene tests, position test, flag test, any-of combiner).
-- requires: fr10_kit
--
--   fr10s.free(n)            untilFn: the player is free (joypadMaskStd == 0, banner byte == 0, no dialogue mode, no script lock, scene loaded: flag $FF set, no scene change queued) for n polls in a row (default 20)
--   fr10s.busy()             untilFn: the player is not free right now (joypad mask, banner, dialogue mode or script lock)
--   fr10s.scene(id)          untilFn: sceneCurrent == id and sceneNext == 0
--   fr10s.leaves(id)         untilFn: sceneCurrent ~= id or a scene change is queued
--   fr10s.at(px, py, tol)    untilFn: the player point ($09A2/$09A4) is within tol (default 0) of (px, py)
--   fr10s.flag(n)            untilFn: global flag n is set
--   fr10s.any(f1, f2, ...)   untilFn: true when any of the functions is true (all are evaluated every poll, so stateful ones such as free(n) keep counting)
fr10s = fr10s or {}

local function isFreeNow()
  -- a running dialog clears joypadMaskStd while it is on screen: displayModeFlags bit 13 (dialogue mode) and playerFlags bit 11 (script lock) are part of the test
  -- flag $FF ($0A1F bit 7) is cleared when a scene starts to load and set again by the scene's first actor once the scene runs: part of the test so a half-loaded scene is not "free"
  return kit.r16(0x065A) == 0 and kit.r8(0x00B4) == 0 and (kit.r16(0x09EC) & 0x2000) == 0 and (kit.r16(0x09AE) & 0x0800) == 0
    and (kit.r8(0x0A1F) & 0x80) ~= 0 and kit.r16(0x0642) == 0
end

function fr10s.free(n)
  n = n or 20
  local run = 0
  return function()
    if isFreeNow() then run = run + 1 else run = 0 end
    return run >= n
  end
end

function fr10s.busy()
  return function() return not isFreeNow() end
end

function fr10s.scene(id)
  return function() return kit.r16(0x0644) == id and kit.r16(0x0642) == 0 end
end

function fr10s.leaves(id)
  return function() return kit.r16(0x0644) ~= id or kit.r16(0x0642) ~= 0 end
end

function fr10s.at(px, py, tol)
  tol = tol or 0
  return function() return math.abs(kit.r16(0x09A2) - px) <= tol and math.abs(kit.r16(0x09A4) - py) <= tol end
end

function fr10s.atX(px, tol)
  tol = tol or 0
  return function() return math.abs(kit.r16(0x09A2) - px) <= tol end
end

function fr10s.flag(n)
  return function() return gaia.flags.get(n) == 1 end
end

-- step-list helpers ---------------------------------------------------------------------------------

-- concatenate step lists
function fr10s.cat(...)
  local out = {}
  for _, l in ipairs { ... } do for _, s in ipairs(l) do out[#out + 1] = s end end
  return out
end

-- walk to the doorstep cell (cx, cy) below a town door, hold Up (the door opens after 8 frames), dismiss narrations with A, and continue up until the scene is left.
-- `from` = the scene the door is in, `to` = the destination scene. side = -1 / 1: the doorstep cell can be solid (the door's solid mark can cover it), but the door also opens for a
-- player one cell to the west (-1) or east (1) of the doorstep: wait there with Up held, then step onto the doorstep column.
function fr10s.enterDoor(cx, cy, from, to, pass, side)
  local approach
  if side then
    approach = {
      { walk = { (cx + side) * 16, cy * 16 }, pass = pass, max = 2500, tol = 1 },
      { hold = { "up" }, n = 30 },
      { dir = side < 0 and "right" or "left", untilFn = fr10s.atX(cx * 16, 1), max = 400 },
    }
  else
    approach = { { walk = { cx * 16, cy * 16 }, pass = pass, max = 2500 } }
  end
  return fr10s.cat(approach, {
    { dir = "up", untilFn = fr10s.any(fr10s.busy(), fr10s.leaves(from)), max = 240 },
    { mash = "a", down = 2, gap = 20, untilFn = fr10s.any(fr10s.free(30), fr10s.leaves(from)), max = 900, onlyDialog = true },
    { dir = "up", untilFn = fr10s.leaves(from), max = 160 },
    { waitUntil = fr10s.scene(to), max = 600 },
    { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(30), max = 600, onlyDialog = true },
  })
end

-- walk to the exit warp cell at pixel (px, py) of the current scene `from` and wait for scene `to` to load and the player to be free
function fr10s.leaveRoom(px, py, from, to, pass)
  return {
    { walk = { px, py }, pass = pass, max = 900 },
    { dir = "down", untilFn = fr10s.leaves(from), max = 60, soft = true },
    { waitUntil = fr10s.scene(to), max = 600 },
    { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(30), max = 600, onlyDialog = true },
  }
end

function fr10s.any(...)
  local fns = { ... }
  return function()
    local r = false
    for _, f in ipairs(fns) do if f() then r = true end end
    return r
  end
end
