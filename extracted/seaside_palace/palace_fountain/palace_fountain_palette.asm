; Fountain palette animation for the Seaside Palace.
; 
; Thinker that cycles palette colors for the demon fountain's
; water effect. Creates the shimmering water visual.
---------------------------------------------

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
    COP [BranchOnFlagByte] ( #0F, #01, &PalaceFountainPaletteRestore )
    COP [BranchOnFlagByte] ( #70, #00, &PalaceFountainPaletteAlt )
    COP [PaletteStart] ( #1A )
    COP [PaletteStep]
    BRA loc_00B746
} >
]

PalaceFountainPaletteAlt {
    COP [PaletteStart] ( #25 )
    COP [PaletteStep]
    BRA loc_00B746

  loc_00B746:
    COP [BranchOnFlagByte] ( #FF, #01, &code_00B72C )
    BRA loc_00B720
}

PalaceFountainPaletteRestore {
    COP [WaitOnFlagByte] ( #0F, #00 )
    BRA code_00B72C
}