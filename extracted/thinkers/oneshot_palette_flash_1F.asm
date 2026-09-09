---------------------------------------------

oneshot_palette_flash_1F [
  thinker-def < #00, #08, {

  code_00B800:
    COP [PaletteStart] ( #1F )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]