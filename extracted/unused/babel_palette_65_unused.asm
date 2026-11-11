; Unreferenced thinker that waits for flag byte $F5 to be set and then runs palette animation #65 every frame. $F5 is set only by unused_mode7_boss. Never spawned in any scene or cutscene.
---------------------------------------------

---------------------------------------------

babel_palette_65_unused [
  thinker-def < #00, #08, {

  code_00B783:
    COP [WaitOnFlagByte] ( #F5, #01 )
    COP [SetEntryHere]
    COP [PaletteStart] ( #65 )
    COP [PaletteStep]
    RTL 
} >
]