!CGADSUB                        2131

---------------------------------------------

palace_fountain_palette [
  thinker-def < #00, #08, {

  loc_00B720:
    COP [SetFlagByte] ( #FF )
    SEP #$20
    LDA #$03
    STA $CGADSUB
    REP #$20

  code_00B72C:
    COP [BranchIfFlagByte] ( #0F, #01, &code_00B74E )
    COP [BranchIfFlagByte] ( #70, #00, &code_00B73F )
    COP [PaletteStart] ( #1A )
    COP [PaletteStep]
    BRA loc_00B746
} >
]

code_00B73F {
    COP [PaletteStart] ( #25 )
    COP [PaletteStep]
    BRA loc_00B746

  loc_00B746:
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B72C )
    BRA loc_00B720
}

code_00B74E {
    COP [ExitIfFlagByte] ( #0F, #00 )
    BRA code_00B72C
}