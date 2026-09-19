; Seaside Palace fountain room effect for Kara's fountain scene.
; 
; Each loop sets CGADSUB ($2131) to #$03, enabling color-math addition of the subscreen onto the main screen for a luminous water glow. Alternates palette bundles #1A and #25 based on flags #70 and #0F, stepping one palette frame per tick to animate the fountain's shimmering colors. Flag #0F triggers an exit branch; flag #FF gates loop restart after each palette step.
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
    COP [BranchIfFlagByte] ( #0F, #01, &PalaceFountainPaletteRestore )
    COP [BranchIfFlagByte] ( #70, #00, &PalaceFountainPaletteAlt )
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
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B72C )
    BRA loc_00B720
}

PalaceFountainPaletteRestore {
    COP [ExitIfFlagByte] ( #0F, #00 )
    BRA code_00B72C
}