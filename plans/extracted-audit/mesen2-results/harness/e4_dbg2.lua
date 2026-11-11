local st = emu.getState()
local t = {}
for k, v in pairs(st) do
  if k:sub(1,4) == "ppu." and not k:find("%[") and k:lower():find("[cmfw]") then t[#t+1] = k .. "=" .. tostring(v) end
end
table.sort(t)
emu.log(table.concat(t, " | "))
