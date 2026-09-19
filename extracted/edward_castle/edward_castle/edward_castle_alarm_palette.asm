; Red-alert atmosphere thinker for Edward Castle during the alarm/infiltration sequence.
; 
; Runs an infinite loop on palette bundle #05 via PaletteStart/PaletteStep, producing a cycling emergency color scheme. Each frame also writes red tint bytes #$24 and #$42 to COLDATA ($2132), additively pulsing the screen red on top of the palette animation. Exits via KillThinker when flag #22 is set or flag #21 is clear, ending the alert state when the story beat resolves.
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

edward_castle_alarm_palette [
  thinker-def < #00, #08, {

  code_00B633:
    COP [BranchIfFlagByte] ( #22, #01, &EdwardCastleAlarmPaletteKill ) ; WRMPYB: axis distance byte for hardware multiply
    COP [BranchIfFlagByte] ( #21, #00, &EdwardCastleAlarmPaletteKill ) ; RDMPYL -> WRDIVL: multiply output feeds divider

  loc_00B63F:
    COP [PaletteStart] ( #05 )
    COP [PaletteStep]     ; RDDIVL: pixels-per-frame result
    SEP #$20              ; Store velocity in $0000
    LDA #$24
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B63F
} >
]

EdwardCastleAlarmPaletteKill {
    COP [KillThinker]
    RTL 
}