; Dream-sequence palette cycler for Tim's Gold Ship dream aboard the ship.
; 
; Continuously steps through palette bundle #35 with PaletteStart/PaletteStep, maintaining the surreal dream color grading. Sets thinker flag #FF each iteration; when that flag is externally cleared, ExitIfFlagByte falls through to KillThinker and the dream palette loop terminates. No direct PPU register writes — the effect is entirely driven by the engine palette bundle system.
---------------------------------------------

---------------------------------------------

dream_palette_loop [
  thinker-def < #00, #08, {

  loc_00B6D4:
    COP [PaletteStart] ( #35 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B6D4

  loc_00B6E2:
    COP [KillThinker]
    RTL 
} >
]