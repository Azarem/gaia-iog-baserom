; Ship departure sequence — the Gold Ship leaves the cave (scene $2C).
; 
; Flag $4C clear: sets the joypad lock ($EFFC), sets the word flag $0185, writes TM = $15, CGADSUB = $B1 and COLDATA = $FF, places Will at pixel (D0,20) and starts player_character.loc_02C63B on him, then tests each frame (SetEntryHere) whether Will is at (D0,240). There it sets the joypad lock again, spawns oneshot_backdrop_fade_out_1C, waits 192 ticks (WaitByte #BF), sets $4C, prints 'This is the Incan Gold Ship?!', releases the joypad lock and dies.
; 
; Flag $4C set: the actor dies at once (code_0581FD). No music command is run by this actor.
---------------------------------------------

?INCLUDE 'oneshot_backdrop_fade_out_1C'
?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerActor                    09AA
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132

---------------------------------------------

gs2C_descent [
  actor-def < #00, #00, #20, {

  code_05817C:
    COP [BranchOnFlagByte] ( #4C, #01, &code_0581FD )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [SetFlagWord] ( #$0185 )
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$B1
    STA $CGADSUB
    LDA #$FF
    STA $COLDATA
    REP #$20
    LDY $playerActor
    LDA #$00D0
    STA $0014, Y
    LDA #$0020
    STA $0016, Y
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$^player_character.loc_02C63B
    STA $0002, Y
    REP #$20
    LDA #$&player_character.loc_02C63B
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    COP [SetEntryHere]
    COP [BranchIfPlayerAt] ( #$00D0, #$0240, &code_0581DD )
    RTL 
} >
]

code_0581DD {
    COP [LoopStart] ( #3C )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [LoopEnd]
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
    COP [WaitByte] ( #BF )
    COP [SetFlagByte] ( #4C )
    COP [PrintDialogString] ( &dialogstring_0581FF )
    LDA #$EFFC
    TRB $joypadMaskStd
}

code_0581FD {
    COP [Die]
}

dialogstring_0581FF `[DLG:3,12][SIZ:D,2][TPL:0]Will: This is the [N]Incan Gold Ship?! [FIN]What?! I feel like[N]someone's there...[PAL:0][END]`