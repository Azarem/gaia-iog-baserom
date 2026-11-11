-- description: E3 diary pan: open Start Journey in the diary menu (S07), poke the scene id of slot 0, let DiaryCameraPan settle, record the camera target.
-- requires: mesen_kit
--
-- e3diary.go{ scenes={0x01,...}, openAt=5, startAt=40, maxStage=160, holdStable=4, stopAfter=nil }
-- Frame c counts from the load. A is pressed at c = openAt .. openAt+1 (the main menu's first row is Start Journey). From c = startAt stage i pokes
-- $0D74 (slot 0 scene) := scenes[i] and $0D92 (cursor) := 0, then waits until cameraTargetX/Y ($06BE/$06C2) stay unchanged for holdStable frames.
-- Result rows: scene, start camera, final camera, frames to settle, BG1 scroll registers at the end, stage index.
e3diary = e3diary or {}

local WR = emu.memType.snesWorkRam
local function r16(a) return emu.read(a, WR) | (emu.read(a + 1, WR) << 8) end
local function w16(a, v) emu.write(a, v & 0xFF, WR); emu.write(a + 1, (v >> 8) & 0xFF, WR) end

function e3diary.go(o)
  local f0 = emu.getState().frameCount
  local st = { i = 0, since = 0, same = 0, lx = -1, ly = -1, startX = 0, startY = 0 }
  local rows = {}
  local done = false
  local w36 = 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then w36 = w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  emu.addEventCallback(function()
    local c = emu.getState().frameCount - f0
    if c >= o.openAt and c <= o.openAt + 1 then emu.setInput({ a = true }, 0) end
  end, emu.eventType.inputPolled)
  emu.addEventCallback(function()
    if done then return end
    local s = emu.getState()
    local c = s.frameCount - f0
    if c < o.startAt then return end
    local x, y = r16(0x6BE), r16(0x6C2)
    if st.i == 0 or st.same >= o.holdStable or (c - st.since) >= o.maxStage then
      if st.i > 0 then
        rows[#rows + 1] = string.format("scene=%02X start=(%d,%d) final=(%d,%d) frames=%d bg1scroll=(%d,%d) scene_var=%02X cursor=%d slot0=%02X%s",
          o.scenes[st.i], st.startX, st.startY, x, y, c - st.since, s["ppu.layers[0].hscroll"] or -1, s["ppu.layers[0].vscroll"] or -1, r16(0x644), r16(0xD92), r16(0xD74),
          (c - st.since) >= o.maxStage and " TIMEOUT" or "")
        if o.stopAfter and o.scenes[st.i] == o.stopAfter then
          done = true
          emu.mcp.result({ rows = rows, w36 = w36, frame = s.frameCount, c = c })
          emu.mcp.done()
          return
        end
      end
      st.i = st.i + 1
      if st.i > #o.scenes then
        done = true
        local lines = {}
        for _, l in ipairs(rows) do lines[#lines + 1] = l end
        emu.mcp.result({ rows = rows, w36 = w36, frame = s.frameCount, c = c })
        emu.mcp.done()
        return
      end
      w16(0xD74, o.scenes[st.i]); w16(0xD92, 0)
      st.since = c; st.same = 0; st.lx, st.ly = x, y; st.startX, st.startY = x, y
      return
    end
    if x == st.lx and y == st.ly and (c - st.since) >= 2 then st.same = st.same + 1 else st.same = 0 end
    st.lx, st.ly = x, y
  end, emu.eventType.endFrame)
end
