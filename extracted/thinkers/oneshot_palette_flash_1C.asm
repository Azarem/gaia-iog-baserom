---------------------------------------------

oneshot_palette_flash_1C [
  thinker-def < #00, #08, {

  code_00B7EC:
    COP [PaletteStart] ( #1C )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]