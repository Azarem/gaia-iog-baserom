; Fountain palette animation of the Seaside Palace fountain room (scene $5D).
; 
; Thinker that sets scene setup flag $FF and then steps a palette every frame: palette #25 while the fountain is not purified (flag $70 clear), palette #1A once $70 is set. While scratch $0F is set (the fountain actor is fading the backdrop) it parks until $0F clears.
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