-- description: G3 pool-full, hit-stun and knockback: actor-list and thinker-list consistency walkers (endFrame), pool fill (leaked free-list entries popped at a safe point), exec/write hooks, trial driver with a walker self-test.
-- requires: mesen_kit, iog_kit, gaia_kit, a_actors, g1_kit
--
--   g3.trial{ frames=N, tag="x", out="G3_x.txt",
--             setup=function(S) end,                       -- t == 0, before the first scheduled input
--             sched=function(t, S) return {"right"} end,   -- buttons held at run clock t (NMI frames since the first callback)
--             tick=function(t, S) end,                     -- every frame after the scheduler and the walkers (disclosed pokes, samples)
--             hooks=function(S) end,                       -- register extra callbacks (S:ex / S:wr / S:rd)
--             fillActors=keepFree | nil, fillAt=t,         -- pop the free list down to keepFree entries at the first safe point at or after t
--             fillThinkers=keepFree | nil,
--             selftest=true }                              -- last frame: inject a dangling link and a cycle, require the walker to report them
--
-- Offsets are decimal PRG offsets (ROM file offsets = the "; {n}" tags of extracted/). Callbacks run BEFORE the instruction.
-- Safe point for the fill = exec 244708 (RunCombatCollision entry, called by the main loop between actors, never inside an allocator).
g3 = g3 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local FIRST, LAST, STRIDE = 0x1000, 0x1F90, 0x30
local FREE_END = 0x0EA8      -- sentinel word of the actor free list ($FFFF), 84 entries from $0E00
local TFREE_BASE, TFREE_END = 0x3000, 0x3020   -- thinker free list $7E:3000, sentinel at $3020

local function s16(v) v = v & 0xFFFF; if v >= 0x8000 then return v - 0x10000 end return v end
local function validActor(s) return s >= FIRST and s <= LAST and ((s - FIRST) % STRIDE) == 0 end
local function validThinker(s) return s >= 0x0F00 and s <= 0x0FF0 and (s % 0x10) == 0 end

g3.s16 = s16

-- set of free actor slots (entries from ($4E) to the sentinel)
function g3.freeActors()
  local p, free, n = kit.r16(0x4E), {}, 0
  while p < FREE_END and n < 100 do
    local e = kit.r16(p)
    if e ~= 0 and e < 0x8000 then free[e] = true; n = n + 1 end
    p = p + 2
  end
  return free, n
end

function g3.freeThinkers()
  local p, free, n = kit.r16(0x52), {}, 0
  while p < TFREE_END and n < 40 do
    local e = kit.r16(p)
    if e ~= 0 and e < 0x8000 then free[e] = true; n = n + 1 end
    p = p + 2
  end
  return free, n
end

-- consistency walk of the actor list (head $56, links +04 prev / +06 next, tail $58)
-- returns { n=length, codes={code=true}, detail={code="text"}, tail=real tail, nfree=free entries }
function g3.walk()
  local r = { n = 0, codes = {}, detail = {} }
  local function bad(code, text) if not r.codes[code] then r.codes[code] = true; r.detail[code] = text end end
  local free, nfree = g3.freeActors()
  r.nfree = nfree
  local head, tailW = kit.r16(0x56), kit.r16(0x58)
  r.head, r.tailW = head, tailW
  if head == 0 then bad("empty", string.format("head 0 tail %04X", tailW)) end
  local s, prev, seen = head, 0, {}
  while s ~= 0 and r.n < 120 do
    if seen[s] then bad("cycle", string.format("revisit %04X after %d", s, r.n)); break end
    if not validActor(s) then bad("badslot", string.format("link %04X after %04X", s, prev)); break end
    seen[s] = true
    if free[s] then bad("freeLinked", string.format("%04X is in the free list", s)) end
    local p = kit.r16(s + 4)
    if p ~= prev then bad("prevMismatch", string.format("%04X.prev=%04X expected %04X", s, p, prev)) end
    r.n = r.n + 1
    prev = s
    s = kit.r16(s + 6)
  end
  if r.n >= 120 then bad("tooLong", "120 steps") end
  r.tail = prev
  if head ~= 0 and prev ~= tailW then bad("tailStale", string.format("$58=%04X real tail=%04X", tailW, prev)) end
  if head ~= 0 and kit.r16(head + 4) ~= 0 then bad("headPrev", string.format("head %04X prev=%04X", head, kit.r16(head + 4))) end
  local cnt = kit.r16(0x0DBC)
  r.count = cnt
  if cnt ~= r.n then bad("countMismatch", string.format("activeActorCount=%d list=%d allocated=%d", cnt, r.n, 84 - nfree)) end
  if (84 - nfree) ~= cnt then bad("poolMismatch", string.format("allocated=%d count=%d", 84 - nfree, cnt)) end
  return r
end

function g3.twalk()
  local r = { n = 0, codes = {}, detail = {} }
  local function bad(code, text) if not r.codes[code] then r.codes[code] = true; r.detail[code] = text end end
  local free, nfree = g3.freeThinkers()
  r.nfree = nfree
  local head, tailW = kit.r16(0x5A), kit.r16(0x5C)
  r.head, r.tailW = head, tailW
  if head == 0 then bad("empty", string.format("head 0 tail %04X", tailW)) end
  local s, prev, seen = head, 0, {}
  while s ~= 0 and r.n < 40 do
    if seen[s] then bad("cycle", string.format("revisit %04X after %d", s, r.n)); break end
    if not validThinker(s) then bad("badslot", string.format("link %04X after %04X", s, prev)); break end
    seen[s] = true
    if free[s] then bad("freeLinked", string.format("%04X is in the free list", s)) end
    local p = kit.r16(s + 4)
    if p ~= prev then bad("prevMismatch", string.format("%04X.prev=%04X expected %04X", s, p, prev)) end
    r.n = r.n + 1
    prev = s
    s = kit.r16(s + 6)
  end
  r.tail = prev
  if head ~= 0 and prev ~= tailW then bad("tailStale", string.format("$5C=%04X real tail=%04X", tailW, prev)) end
  if head == 0 and tailW ~= 0 then bad("tailStale", string.format("empty list, $5C=%04X", tailW)) end
  if (16 - nfree) ~= r.n then bad("poolMismatch", string.format("allocated=%d list=%d", 16 - nfree, r.n)) end
  return r
end

local function liveStr()
  local out = {}
  for _, s in ipairs(aact.live()) do out[#out + 1] = string.format("%04X", s) end
  return table.concat(out, " ")
end
g3.liveStr = liveStr

function g3.fillActorsNow(keep)
  local p = kit.r16(0x4E)
  local popped = 0
  while (FREE_END - p) / 2 > keep do
    local e = kit.r16(p)
    if e == 0 or e >= 0x8000 then break end
    kit.w16(p, 0); p = p + 2; popped = popped + 1
  end
  kit.w16(0x4E, p)
  kit.w16(0x0DBC, kit.r16(0x0DBC) + popped)
  return popped
end

function g3.fillThinkersNow(keep)
  local p = kit.r16(0x52)
  local popped = 0
  while (TFREE_END - p) / 2 > keep do
    local e = kit.r16(p)
    if e == 0 or e >= 0x8000 then break end
    kit.w16(p, 0); p = p + 2; popped = popped + 1
  end
  kit.w16(0x52, p)
  return popped
end

function g3.trial(o)
  local S = {
    t = nil, ctl = 0, passes = 0, evl = {}, nEv = 0, cnt = {}, issues = {}, tissues = {}, wf = 0, tf = 0, maxLive = 0, minLive = 999,
    fillDone = false, tfillDone = false, popped = nil, tpopped = nil, last = {},
  }
  g3.S = S
  local function tstr() return S.t and ("t=" .. S.t) or "t=-" end
  S.tstr = tstr
  function S.ev(s) S.nEv = S.nEv + 1; if #S.evl < (o.maxEv or 400) then S.evl[#S.evl + 1] = s end end
  function S.inc(key, by) S.cnt[key] = (S.cnt[key] or 0) + (by or 1); return S.cnt[key] end
  function S.ex(off, fn) emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, CPU, P) end
  function S.wr(lo, hi, fn) emu.addMemoryCallback(fn, emu.callbackType.write, lo, hi, CPU, WR) end
  function S.rd(lo, hi, fn) emu.addMemoryCallback(fn, emu.callbackType.read, lo, hi, CPU, WR) end
  S.state = function() return emu.getState() end

  -- positive controls
  S.wr(0x36, 0x36, function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end)
  S.ex(244708, function()
    S.passes = S.passes + 1
    if o.fillActors and not S.fillDone and S.t and S.t >= (o.fillAt or 0) then
      local live0, nfree0 = #aact.live(), select(2, g3.freeActors())
      S.popped = g3.fillActorsNow(o.fillActors)
      S.fillDone = true
      S.ev(string.format("FILL %s popped=%d (free %d -> %d) live=%d count=%d $4E=%04X [$4E]=%04X", tstr(), S.popped, nfree0, select(2, g3.freeActors()), live0, kit.r16(0x0DBC), kit.r16(0x4E), kit.r16(kit.r16(0x4E))))
    end
    if o.fillThinkers and not S.tfillDone and S.t and S.t >= (o.fillThinkersAt or o.fillAt or 0) then
      local nfree0 = select(2, g3.freeThinkers())
      S.tpopped = g3.fillThinkersNow(o.fillThinkers)
      S.tfillDone = true
      S.ev(string.format("TFILL %s popped=%d (free %d -> %d) $52=%04X", tstr(), S.tpopped, nfree0, select(2, g3.freeThinkers()), kit.r16(0x52)))
    end
  end)
  if o.hooks then o.hooks(S) end

  local started = false
  local function noteIssues(w, store, tag)
    for code in pairs(w.codes) do
      local first = (store[code] == nil)
      store[code] = (store[code] or 0) + 1
      if first then S.ev(string.format("%s-ISSUE %s %s %s (list %d head %04X tail $%s=%04X)", tag, tstr(), code, w.detail[code], w.n, w.head or 0, tag == "A" and "58" or "5C", w.tailW or 0)) end
    end
  end
  local function finish()
    S.done = true
    local lines = {}
    for _, l in ipairs(S.evl) do lines[#lines + 1] = l end
    for _, l in ipairs(S.tail or {}) do lines[#lines + 1] = l end
    if o.out then emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", false) end
    local function copy(tb) local c = {} for k, v in pairs(tb) do if type(v) == "number" then c[k] = v end end return c end
    kit.finish({
      tag = o.tag, control36 = S.ctl, passes = S.passes, nEvents = S.nEv, events = { table.unpack(S.evl, 1, math.min(o.show or 20, #S.evl)) },
      issuesA = copy(S.issues), issuesT = copy(S.tissues), walkFrames = S.wf, maxLive = S.maxLive, minLive = S.minLive, popped = S.popped, tpopped = S.tpopped,
      cnt = copy(S.cnt), selftest = S.selftest, extra = S.extra, t = S.t, scene = kit.r16(0x0644), form = kit.r16(0x0AD4), hp = kit.r16(0x0ACE),
      frame = emu.getState()["frameCount"],
    })
  end
  S.finish = finish

  kit.onFrame(function()
    if S.done then return end
    local clock = kit.r16(0x36)
    if not started then started = true; S.n36 = clock; S.t = 0 else S.t = (clock - S.n36) & 0xFFFF end
    S.nf = (S.nf or 0) + 1   -- emulator frames seen by this callback ($36 can stall or restart across a scene change)
    if o.hardFrames and S.nf >= o.hardFrames and S.t < o.frames then S.ev(string.format("HARD-STOP after %d emulator frames, t=%d ($36 delta)", S.nf, S.t)); S.t = o.frames end
    if S.t == 0 and o.setup then o.setup(S) end
    local b = o.sched and o.sched(S.t, S) or nil
    if b then gaia.hold(b) else gaia.release() end
    -- walkers (after the frame's actor pass)
    local w = g3.walk()
    S.wf = S.wf + 1
    if w.n > S.maxLive then S.maxLive = w.n end
    if w.n < S.minLive then S.minLive = w.n end
    noteIssues(w, S.issues, "A")
    local tw = g3.twalk()
    noteIssues(tw, S.tissues, "T")
    S.last.w, S.last.tw = w, tw
    if o.tick then o.tick(S.t, S, w, tw) end
    if S.t >= o.frames then
      if o.selftest ~= false then
        -- positive control of the walker: inject a dangling link (free slot as next) then a cycle, require both reported
        local live = aact.live()
        local a = live[#live]
        local freeSlot = nil
        for slot in pairs(g3.freeActors()) do freeSlot = slot; break end
        freeSlot = freeSlot or 0x1FC0   -- pool full: no free slot to link to, the pool-end sentinel stands in (reported as badslot)
        local report = {}
        if a then
          local save6 = kit.r16(a + 6)
          kit.w16(a + 6, freeSlot)
          local w1 = g3.walk()
          report.dangling = w1.codes.freeLinked and "freeLinked" or (w1.codes.badslot and "badslot" or "MISSED")
          kit.w16(a + 6, a)
          local w2 = g3.walk()
          report.cycle = w2.codes.cycle and "cycle" or "MISSED"
          kit.w16(a + 6, save6)
        else
          report.skipped = "no free slot or no actor"
        end
        S.selftest = report
        S.ev(string.format("SELFTEST dangling=%s cycle=%s %s", tostring(report.dangling), tostring(report.cycle), tostring(report.skipped or "")))
      end
      finish()
    end
  end)
end
