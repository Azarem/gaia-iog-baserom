; Boot-sequence thinker that steps palette animations #50, #52, and #54 in order, then exits.
; 
; Spawned on scene $FB (boot logo scene) as the first of three logo palette thinkers. Animates the Enix logo colors during the opening publisher screen.
---------------------------------------------

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