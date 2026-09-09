---------------------------------------------

oneshot_palette_flash_19 [
  thinker-def < #00, #08, {

  code_00B7D8:
    COP [PaletteStart] ( #19 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]