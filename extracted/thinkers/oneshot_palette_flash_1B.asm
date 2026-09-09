---------------------------------------------

oneshot_palette_flash_1B [
  thinker-def < #00, #08, {

  code_00B7E2:
    COP [PaletteStart] ( #1B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]