; Festival palette thinker for Watermia events.
; 
; Controls palette cycling during the Watermia festival or
; Russian Glass night event. Creates the moonlit atmosphere
; with color shifts.
---------------------------------------------

!animScratch2                   7F000E

---------------------------------------------

watermia_festival_palette [
  thinker-def < #00, #08, {

  code_00B756:
    COP [BranchOnFlagByte] ( #96, #01, &WatermiaFestivalPaletteFlash )

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