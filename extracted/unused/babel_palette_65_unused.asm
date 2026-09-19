; Unreferenced thinker that would loop palette animation #65 each frame unless flag byte $F5 is set.
; 
; Likely intended for a Babel Tower area palette effect. Never spawned in any scene or cutscene.
---------------------------------------------

---------------------------------------------

babel_palette_65_unused [
  thinker-def < #00, #08, {

  code_00B783:
    COP [ExitIfFlagByte] ( #F5, #01 )
    COP [SetEntryContinue]
    COP [PaletteStart] ( #65 )
    COP [PaletteStep]
    RTL 
} >
]