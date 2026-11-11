-- description: FR10 early-game capture helpers: segment logger (flag rows, scene changes, input-lock changes), state snapshot, and an input bot (step program, collision-grid walker, run-length recording of the buttons it pressed).
-- requires: gaia_kit
--
-- Load with run_script / load_script  includes=["fr10_kit"]   (the server resolves "requires": gaia_kit, mesen_kit, iog_kit).
-- All addresses are WRAM offsets. Nothing here writes game memory.
--
--   fr10.snap()                          {f, sc, next, mask, banner, x, y, ax, ay, hp, flags10}   (x, y = $09A2/$09A4, ax, ay = actor position)
--   fr10.start{cap=200, sceneCap=120, maskCap=60, minMaskFrames=1}
--        -> handle h with h:summary(): starts gaia.flagwatch over $0A00-$0AB3 with its own log (rows past `cap` are counted),
--           a SCENE row at every change of sceneCurrent and a MASK row at every change of joypadMaskStd between zero and nonzero.
--   fr10.bot{ steps = {...}, maxFrames = N, onDone = fn(result) }   input program (below); the run ends with kit.finish(result)
--        steps (each ends when its condition holds or `max` frames pass; `max` defaults to 600):
--          {hold = {"a"}, n = 10}                     hold the buttons for n frames
--          {wait = 30}                                no buttons for n frames
--          {waitUntil = fn, max = 600}                no buttons until fn() is true (false after `max` frames)
--          {dir = "right", untilFn = fn, max = 300}   hold a direction until untilFn() is true
--          {mash = "a", down = 2, gap = 6, untilFn = fn, max = 600, onlyDialog = false}   press `mash` for `down` frames, release for `gap`, until untilFn()
--                                                    (onlyDialog = true presses only while a dialog or the scene banner is up)
--          {walk = {px, py}, tol = 1, max = 900, pass = {[0]=true}, ledge = true, soft = false, dismiss = false}   walk the player point ($09A2/$09A4, the top-left
--                                                    corner of a 16 x 16 hitbox) to (px, py): BFS over the collision cells (low nibble in
--                                                    `pass`, default {0}; high nibble must be 0), replanned whenever the player enters a new
--                                                    cell (tol = 0 for an exact trigger position; the final tolerance is 1 px by default, the
--                                                    intermediate one 1 px as well). Cells with low nibble 8 are ledges (stepping on one locks
--                                                    the joypad and moves the player to another level): they are never crossed by the plan, but
--                                                    when the target is unreachable the walker steps onto the nearest reachable ledge (ledge =
--                                                    false disables). Slope cells (5, 6, 9) are walked with both axes pressed (vertical-only
--                                                    presses do nothing on them). A joypad lock pauses the walk; with dismiss = true a dialog that
--                                                    opens on the way is dismissed with A (without it the walk keeps pressing directions). A scene change ends the step as ok; 40 frames without movement or `max`
--                                                    frames fail it, and a failed step ends the whole program (reason step_failed) unless `soft`.
--          {call = fn}                                run fn(snap) once (log or record something), no input for that frame
--        result: {rle = "frames:button+button ...", totalFrames, steps = {rows}, reason, final}
fr10 = fr10 or {}

local function r16(a) return kit.r16(a) end

function fr10.snap()
  return {
    f = emu.getState().frameCount, sc = r16(0x0644), next = r16(0x0642), mask = r16(0x065A), banner = kit.r8(0x00B4),
    x = r16(0x09A2), y = r16(0x09A4), ax = r16(0x1014), ay = r16(0x1016), hp = r16(0x0ACE), flags10 = r16(0x1010),
  }
end

-- segment logger ------------------------------------------------------------------------------------
function fr10.start(opts)
  opts = opts or {}
  local cap, sceneCap, maskCap = opts.cap or 200, opts.sceneCap or 120, opts.maskCap or 60
  local nflag, nscene, nmask = 0, 0, 0
  local function flagLog(fmt, ...)
    if nflag < cap then nflag = nflag + 1; emu.log(string.format(fmt, ...)) end
  end
  local h = { fw = gaia.flagwatch{ cap = cap, log = flagLog, actor = true }, scenes = 0, masks = 0 }
  local lastScene, lastMaskNz = r16(0x0644), r16(0x065A) ~= 0
  kit.onFrame(function()
    local sc = r16(0x0644)
    if sc ~= lastScene then
      h.scenes = h.scenes + 1
      if nscene < sceneCap then
        nscene = nscene + 1
        local s = fr10.snap()
        emu.log(string.format("SCENE f=%d $%02X>$%02X next=%04X mask=%04X banner=%02X pos=%d,%d", s.f, lastScene & 0xFF, sc & 0xFF, s.next, s.mask, s.banner, s.ax, s.ay))
      end
      lastScene = sc
    end
    local nz = r16(0x065A) ~= 0
    if nz ~= lastMaskNz then
      h.masks = h.masks + 1
      if nmask < maskCap then
        nmask = nmask + 1
        local s = fr10.snap()
        emu.log(string.format("MASK f=%d sc=%02X %s mask=%04X pos=%d,%d", s.f, sc & 0xFF, nz and "LOCK" or "FREE", s.mask, s.ax, s.ay))
      end
      lastMaskNz = nz
    end
  end)
  function h:summary()
    local s = self.fw:summary()
    s.sceneChanges, s.maskChanges = self.scenes, self.masks
    return s
  end
  return h
end

-- bot ---------------------------------------------------------------------------------------------------
local function buttonsKey(t)
  local names = {}
  for k, v in pairs(t) do if v then names[#names + 1] = k end end
  table.sort(names)
  return table.concat(names, "+"), names
end

local function isFree(v, pass) return pass[v & 0x0F] and (v >> 4) == 0 end
local SLOPE = { [5] = true, [6] = true, [9] = true }
-- on a slope only horizontal buttons move the player: low nibble 9 = right goes down-right (left up-left), 6 = left goes down-left (right up-right); 5 is not probed yet
local SLOPE_VEC = { [9] = { 1, 1 }, [6] = { -1, 1 } }
local function isSlope(cx, cy) return SLOPE[gaia.coll.get(cx, cy) & 0x0F] == true end

-- BFS over the collision cells of the scene from cell (sx, sy) to (tx, ty); returns the list of cells (excluding the start) or nil.
-- Returns (path, kind): kind "target" = the path ends on the target cell; "ledge" = the target is unreachable and the path ends on the nearest ledge cell.
local function bfs(sx, sy, tx, ty, pass, ledge)
  local stride, rows = kit.r8(0x0693), kit.r8(0x0697)
  local w, h = stride * 16, rows * 16
  if sx < 0 or sy < 0 or sx >= w or sy >= h or tx < 0 or ty < 0 or tx >= w or ty >= h then return nil end
  local seen, prev, queue, qi = {}, {}, { sy * w + sx }, 1
  seen[sy * w + sx] = true
  local target = ty * w + tx
  local ledges = {}
  local function build(cur)
    local path, c = {}, cur
    while c ~= sy * w + sx do table.insert(path, 1, c); c = prev[c] end
    local out = {}
    for _, id in ipairs(path) do out[#out + 1] = { id % w, id // w } end
    return out
  end
  while qi <= #queue do
    local cur = queue[qi]; qi = qi + 1
    if cur == target then return build(cur), "target" end
    local cx, cy = cur % w, cur // w
    for _, d in ipairs { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local nx, ny = cx + d[1], cy + d[2]
      if nx >= 0 and ny >= 0 and nx < w and ny < h then
        local id = ny * w + nx
        if not seen[id] then
          local v = gaia.coll.get(nx, ny)
          if id == target or isFree(v, pass) then
            seen[id] = true; prev[id] = cur; queue[#queue + 1] = id
          elseif ledge and (v & 0x0F) == 8 and (v >> 4) == 0 then
            seen[id] = true; prev[id] = cur
            ledges[#ledges + 1] = id
          end
        end
      end
    end
  end
  -- unreachable target: use the reachable ledge whose landing (assumed 8 cells below the ledge, as at the church and the town streets) is nearest to the
  -- target, but only when that is nearer than the start cell (no ping-pong between levels)
  local best, bestScore = nil, math.abs(sx - tx) + math.abs(sy - ty)
  for _, id in ipairs(ledges) do
    -- stepping onto a ledge from above drops the player 8 cells down, from below it lifts the player 8 cells up (horizontal approaches are not used)
    local ly, fromY = id // w, prev[id] // w
    local landing = (fromY < ly) and (ly + 8) or ((fromY > ly) and (ly - 8) or nil)
    if landing then
      local score = math.abs(id % w - tx) + math.abs(landing - ty)
      if score < bestScore then best, bestScore = id, score end
    end
  end
  if best then return build(best), "ledge" end
  return nil
end

function fr10.bot(o)
  local steps = o.steps
  local rle, total = {}, 0
  local stepLog = {}
  local si, sf = 0, 0            -- current step index, frames in the step
  local cur, state = nil, {}
  local lastKey, lastNames
  local finished = false

  local function finish(reason)
    if finished then return end
    finished = true
    -- compact result (the tool reply is read by a person): rle as "frames:button+button" words ("-" = no button), steps as text rows
    local words = {}
    for _, e in ipairs(rle) do words[#words + 1] = e.frames .. ":" .. (#e.buttons > 0 and table.concat(e.buttons, "+") or "-") end
    local rows = {}
    for _, s in ipairs(stepLog) do
      local sn = s.snap or {}
      rows[#rows + 1] = string.format("step %s ok=%s %s frames=%s f=%s sc=%s pos=%s,%s mask=%04X", tostring(s.i), tostring(s.ok), s.reason or "", tostring(s.frames), tostring(sn.f), sn.sc and string.format("%02X", sn.sc) or "?", tostring(sn.ax), tostring(sn.ay), sn.mask or 0)
    end
    local fin = fr10.snap()
    local res = { rle = table.concat(words, " "), totalFrames = total, steps = rows, reason = reason,
                  final = string.format("f=%d sc=%02X next=%04X mask=%04X banner=%02X pos=%d,%d player09A2=%d,%d hp=%d", fin.f, fin.sc, fin.next, fin.mask, fin.banner, fin.ax, fin.ay, fin.x, fin.y, fin.hp) }
    if o.onDone then o.onDone(res) end
    kit.finish(res)
  end

  local function beginStep()
    si = si + 1
    sf = 0
    state = {}
    cur = steps[si]
    if not cur then finish("steps_done") end
  end

  local function endStep(ok)
    stepLog[#stepLog + 1] = { i = si, ok = ok, frames = sf, snap = fr10.snap() }
    -- a failed step ends the program (the later steps assume its result) unless it is marked soft = true
    if not ok and not (cur and cur.soft) then finish("step_failed"); cur = nil; return end
    beginStep()
  end

  beginStep()

  emu.addEventCallback(function()
    if finished then return end
    if o.maxFrames and total >= o.maxFrames then finish("maxFrames"); return end
    local t = {}
    local guard = 0
    -- a step that finishes without consuming a frame lets the next one decide in the same poll
    while cur and guard < 8 do
      guard = guard + 1
      local max = cur.max or 600
      if cur.hold then
        if sf >= cur.n then endStep(true)
        else for _, b in ipairs(cur.hold) do t[b] = true end; break end
      elseif cur.waitUntil then
        if cur.waitUntil() then endStep(true)
        elseif sf >= max then endStep(false)
        else break end
      elseif cur.wait then
        if sf >= cur.wait then endStep(true) else break end
      elseif cur.call then
        cur.call(fr10.snap()); endStep(true)
      elseif cur.dir then
        if cur.untilFn and cur.untilFn() then endStep(true)
        elseif sf >= max then endStep(false)
        else t[cur.dir] = true; break end
      elseif cur.mash then
        if cur.untilFn and cur.untilFn() then endStep(true)
        elseif sf >= max then endStep(false)
        else
          local period = (cur.down or 2) + (cur.gap or 6)
          -- onlyDialog: press only while a dialog (displayModeFlags bit 13) or the scene banner is up, so the press that closes a dialog is not repeated into a new interaction
          local active = (not cur.onlyDialog) or (r16(0x09EC) & 0x2000) ~= 0 or kit.r8(0x00B4) ~= 0
          if active and (sf % period) < (cur.down or 2) then t[cur.mash] = true end
          break
        end
      elseif cur.walk then
        local pass = cur.pass or { [0] = true }
        local tol = cur.tol or 1
        local px, py = cur.walk[1], cur.walk[2]
        local x, y = r16(0x09A2), r16(0x09A4)
        -- replan whenever the player enters a new cell (ledges move the player to another level); a locked joypad (ledge drop, dialog) pauses the walk
        local cellKey = (x >> 4) * 4096 + (y >> 4)
        state.scene = state.scene or r16(0x0644)
        if r16(0x0644) ~= state.scene or r16(0x0642) ~= 0 then endStep(true); break end   -- a warp fired on the way: the walk is over
        if cur.dismiss and (r16(0x09EC) & 0x2000) ~= 0 then
          -- dismiss = true: a dialog opened on the way (an NPC or a position trigger) is dismissed with A, then the walk carries on
          if sf >= max then endStep(false); break end
          if (sf % 22) < 2 then t.a = true end
          state.cellKey = nil; state.lastPos = nil
          break
        end
        if kit.r16(0x065A) ~= 0 then
          if sf >= max then endStep(false); break end
          state.cellKey = nil; state.lastPos = nil
          break
        end
        if state.cellKey ~= cellKey then
          state.cellKey = cellKey
          state.path, state.kind = bfs(x >> 4, y >> 4, px >> 4, py >> 4, pass, cur.ledge ~= false)
          if cur.trace then
            local p = state.path
            emu.log(string.format("walk plan from p=%d,%d cell=%d,%d kind=%s len=%s next=%s last=%s", x, y, x >> 4, y >> 4, tostring(state.kind), p and #p or "nil", p and p[1] and (p[1][1] .. "," .. p[1][2]) or "-", p and p[#p] and (p[#p][1] .. "," .. p[#p][2]) or "-"))
          end
        end
        if not state.path then
          -- right after a scene change the player point can still be stale: retry the plan for up to 90 frames before giving up
          state.noPath = (state.noPath or 0) + 1
          if state.noPath < 90 then
            state.cellKey = nil
            break
          end
          stepLog[#stepLog + 1] = { i = si, ok = false, reason = "no_path", snap = fr10.snap() }
          endStep(false)
        elseif sf >= max then endStep(false)
        else
          local path = state.path
          local wp = path[1]
          local gx, gy
          if wp then
            -- the player point ($09A2/$09A4) is the top-left corner of a 16 x 16 hitbox: a cell is occupied exactly when the point is a multiple of 16
            if #path == 1 and state.kind == "target" then gx, gy = px, py else gx, gy = wp[1] * 16, wp[2] * 16 end
          else
            gx, gy = px, py
          end
          local dx, dy = gx - x, gy - y
          local lastWp = (not wp) or (#path == 1 and state.kind == "target")
          local ttol = lastWp and tol or 1
          if math.abs(dx) <= ttol and math.abs(dy) <= ttol then
            if lastWp then endStep(true)
            else
              -- waypoint reached (the player can be within tolerance without having changed cell): advance along the plan, replan once it is used up
              table.remove(state.path, 1)
              if #state.path == 0 then state.cellKey = nil end
            end
          else
            if kit.r16(0x065A) == 0 then
              -- the hitbox is 16 x 16: to move along a row the player must first be aligned to that row (and to a column when moving along a column)
              local horizontal = wp and wp[2] == (y >> 4)
              local needX, needY = math.abs(dx) > ttol, math.abs(dy) > ttol
              -- on slope cells (low nibble 5, 6, 9) the engine moves the player along the slope: no alignment, press the direction of the next cell and replan on every cell change
              local slopeCell = wp and (isSlope(x >> 4, y >> 4) and gaia.coll.get(x >> 4, y >> 4) or isSlope((x + 15) >> 4, y >> 4) and gaia.coll.get((x + 15) >> 4, y >> 4)
                or isSlope(x >> 4, (y + 15) >> 4) and gaia.coll.get(x >> 4, (y + 15) >> 4) or isSlope((x + 15) >> 4, (y + 15) >> 4) and gaia.coll.get((x + 15) >> 4, (y + 15) >> 4))
              if wp and (slopeCell or isSlope(wp[1], wp[2])) then
                -- slope mode: no alignment; press both axes toward the first path cell at least 24 px away (a slope band is diagonal) and replan on every cell change
                local L = path[#path]
                for i = 1, #path do
                  local c = path[i]
                  if math.max(math.abs(c[1] * 16 - x), math.abs(c[2] * 16 - y)) >= 24 then L = c; break end
                end
                local ldx, ldy = L[1] * 16 - x, L[2] * 16 - y
                local pressedH = false
                if ldx >= 2 then t.right = true; pressedH = true elseif ldx <= -2 then t.left = true; pressedH = true end
                if ldy >= 2 then t.down = true elseif ldy <= -2 then t.up = true end
                local vec = slopeCell and SLOPE_VEC[slopeCell & 0x0F]
                if not pressedH and vec and (ldy >= 2 or ldy <= -2) then
                  -- a vertical step on a slope: only a horizontal button moves the player, along the slope vector (9: right = down-right, 6: left = down-left)
                  local dirX = (ldy > 0) and vec[1] or -vec[1]
                  t[dirX > 0 and "right" or "left"] = true
                end
              else
                if horizontal and needY then t[dy > 0 and "down" or "up"] = true
                elseif needX then t[dx > 0 and "right" or "left"] = true
                elseif needY then t[dy > 0 and "down" or "up"] = true end
                -- an odd offset of 1-2 px on the column cannot be closed by a single-axis press (2 px steps): carry the row movement along with it
                if needX and needY and math.abs(dx) <= 2 and not horizontal then t[dy > 0 and "down" or "up"] = true end
                -- fine alignment: a diagonal press moves the other axis by 1 or 2 px per frame (single-axis steps are 2 px, so an odd position never aligns);
                -- a small perpendicular offset is corrected together with the main direction (the main axis may be blocked by that 1-2 px overlap)
                if horizontal then
                  if dy ~= 0 and math.abs(dy) <= 2 and not t.up and not t.down then t[dy > 0 and "down" or "up"] = true end
                elseif wp then
                  if dx ~= 0 and math.abs(dx) <= 2 and not t.left and not t.right then
                    -- only when the cells the hitbox would enter are walkable: a diagonal press into a wall or slope blocks the main axis too
                    local nx = (dx > 0) and ((x + 17) >> 4) or ((x - 2) >> 4)
                    local ok = true
                    for _, yy in ipairs { y, y + 15 } do
                      local v = gaia.coll.get(nx, yy >> 4)
                      if not (pass[v & 15] and (v >> 4) == 0) or isSlope(nx, yy >> 4) then ok = false end
                    end
                    if ok then t[dx > 0 and "right" or "left"] = true end
                  end
                end
              end
            end
            -- stall guard: no movement for 40 frames while the joypad is not locked
            state.lastPos = state.lastPos or { x, y, sf }
            if state.lastPos[1] ~= x or state.lastPos[2] ~= y or kit.r16(0x065A) ~= 0 then state.lastPos = { x, y, sf } end
            if sf - state.lastPos[3] > 40 then stepLog[#stepLog + 1] = { i = si, ok = false, reason = "stalled", snap = fr10.snap() }; endStep(false) end
            break
          end
        end
      else
        endStep(false)
      end
    end
    emu.setInput(t, 0)
    if not cur then
      -- steps ended during this poll: record nothing further
      return
    end
    local key, names = buttonsKey(t)
    if key == lastKey and #rle > 0 then rle[#rle].frames = rle[#rle].frames + 1
    else rle[#rle + 1] = { frames = 1, buttons = names }; lastKey = key end
    total = total + 1
    sf = sf + 1
  end, emu.eventType.inputPolled)
end
