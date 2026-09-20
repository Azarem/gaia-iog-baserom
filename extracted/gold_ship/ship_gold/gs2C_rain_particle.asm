; Individual rain drop particle during the storm sequence.
; 
; Tiny actor that spawns at (-8, 0) offset from the spawner
; and falls. Idle loop — no movement logic of its own;
; position is set by the spawner.
---------------------------------------------

---------------------------------------------

gs2C_rain_particle [
  actor-def < #1E, #02, #10, {

  code_058172:
    COP [NudgePosition] ( #F8, #00 )
    COP [SetEntryHere]
    RTL 
} >
]