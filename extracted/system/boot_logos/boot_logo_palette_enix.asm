---------------------------------------------

boot_logo_palette_enix [
  thinker-def < #00, #08, {

  code_00B841:
    COP [PaletteStart] ( #50 )
    COP [PaletteStep]
    COP [PaletteStart] ( #52 )
    COP [PaletteStep]
    COP [PaletteStart] ( #54 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]