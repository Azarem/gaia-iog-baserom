; Thinker of the Shira dream (scene $2A) — palette animation #35.
; 
; Loops PaletteStart #35 plus PaletteStep, then sets the scene-setup latch $FF and waits until $FF is cleared outside this block (WaitOnFlagByte(#FF, #00)), then branches back to the start. The loop has no exit in this block; the KillThinker at loc_00B6E2 is not reached from it.
---------------------------------------------

---------------------------------------------

dream_palette_loop [
  thinker-def < #00, #08, {

  loc_00B6D4:
    COP [PaletteStart] ( #35 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [WaitOnFlagByte] ( #FF, #00 )
    BRA loc_00B6D4

  loc_00B6E2:
    COP [KillThinker]
    RTL 
} >
]