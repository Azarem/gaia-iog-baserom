; Watermia town palette controller for pre- and post-festival atmosphere.
; 
; Default state loops palette bundle #42 for normal town ambient coloring. When flag #96 is set (festival begins), spawns a child thinker that loops bundle #72 with priority bit #$0800 OR'd into animScratch2, while the parent switches to bundle #48. Both parent and child run independent PaletteStart/PaletteStep loops, layering the festive palette animation over the town transition.
---------------------------------------------

!animScratch2                   7F000E

---------------------------------------------

watermia_festival_palette [
  thinker-def < #00, #08, {

  code_00B756:
    COP [BranchIfFlagByte] ( #96, #01, &WatermiaFestivalPaletteFlash )

  loc_00B75C:
    COP [PaletteStart] ( #42 )
    COP [PaletteStep]
    BRA loc_00B75C
} >
]

WatermiaFestivalPaletteFlash {
    COP [SpawnThinker] ( @WatermiaFestivalPaletteWave )

  loc_00B768:
    COP [PaletteStart] ( #48 )
    COP [PaletteStep]
    BRA loc_00B768
}

WatermiaFestivalPaletteWave {
    LDA $animScratch2, X
    ORA #$0800
    STA $animScratch2, X

  loc_00B77A:
    COP [PaletteStart] ( #72 )
    COP [PaletteStep]
    BRA loc_00B77A
}