---------------------------------------------

oneshot_palette_flash_18 [
  thinker-def < #00, #08, {

  code_00B7CE:
    COP [PaletteStart] ( #18 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]