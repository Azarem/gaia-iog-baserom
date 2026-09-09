---------------------------------------------

oneshot_palette_flash_40 [
  thinker-def < #00, #08, {

  code_00B7F6:
    COP [PaletteStart] ( #40 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]