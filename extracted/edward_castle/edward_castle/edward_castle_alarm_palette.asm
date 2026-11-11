; Red-alert palette thinker of Edward Castle (scene $0A; the second record of thinker list 0CE821).
; 
; At spawn it tests flags once: $22 set (Kara escaped) or $21 clear (the throne scene has not happened) kills the thinker at once. The tests are not repeated, so the alert shows only when the scene loads with $21 set and $22 clear (the castle after the prison). Then it loops: PaletteStart #05 / PaletteStep (a cycling emergency palette), writes COLDATA $24 and $42 (red tint), sets the scene-setup latch $FF and waits for the engine to clear it before the next cycle.
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

edward_castle_alarm_palette [
  thinker-def < #00, #08, {

  code_00B633:
    COP [BranchOnFlagByte] ( #22, #01, &EdwardCastleAlarmPaletteKill )
    COP [BranchOnFlagByte] ( #21, #00, &EdwardCastleAlarmPaletteKill )

  loc_00B63F:
    COP [PaletteStart] ( #05 )
    COP [PaletteStep]
    SEP #$20
    LDA #$24
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    COP [SetFlagByte] ( #FF )
    COP [WaitOnFlagByte] ( #FF, #00 )
    BRA loc_00B63F
} >
]

EdwardCastleAlarmPaletteKill {
    COP [KillThinker]
    RTL 
}