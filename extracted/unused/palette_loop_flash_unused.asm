---------------------------------------------

palette_loop_flash_unused [
  thinker-def < #00, #08, {

  code_00B80A:
    COP [PaletteStartLoop] ( #14, #07 )
    COP [PaletteStepLoop]
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]