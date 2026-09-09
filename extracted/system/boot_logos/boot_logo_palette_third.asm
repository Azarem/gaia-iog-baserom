---------------------------------------------

boot_logo_palette_third [
  thinker-def < #00, #08, {

  code_00B869:
    COP [PaletteStart] ( #56 )
    COP [PaletteStep]
    COP [PaletteStart] ( #57 )
    COP [PaletteStep]
    COP [PaletteStart] ( #58 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]