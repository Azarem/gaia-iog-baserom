; Thinker for the dream sequence palette cycling.
; 
; Loops palette animation #35 using PaletteStart/PaletteStep.
; Sets flag $FF on each cycle and self-terminates when flag $FF
; is cleared externally (by the dream controller ending).
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