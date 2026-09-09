---------------------------------------------

boot_logo_palette_quintet [
  thinker-def < #00, #08, {

  code_00B855:
    COP [PaletteStart] ( #51 )
    COP [PaletteStep]
    COP [PaletteStart] ( #53 )
    COP [PaletteStep]
    COP [PaletteStart] ( #55 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]