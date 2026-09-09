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