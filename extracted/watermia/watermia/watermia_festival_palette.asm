!animScratch2                   7F000E

---------------------------------------------

watermia_festival_palette [
  thinker-def < #00, #08, {

  code_00B756:
    COP [BranchIfFlagByte] ( #96, #01, &code_00B763 )

  loc_00B75C:
    COP [PaletteStart] ( #42 )
    COP [PaletteStep]
    BRA loc_00B75C
} >
]

code_00B763 {
    COP [SpawnThinker] ( @code_00B76F )

  loc_00B768:
    COP [PaletteStart] ( #48 )
    COP [PaletteStep]
    BRA loc_00B768
}

code_00B76F {
    LDA $animScratch2, X
    ORA #$0800
    STA $animScratch2, X

  loc_00B77A:
    COP [PaletteStart] ( #72 )
    COP [PaletteStep]
    BRA loc_00B77A
}