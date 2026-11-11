; Crow's nest lookout of the Gold Ship. The phases are keyed on two event flags: $4C (set by gs2C_descent when the ship leaves the cave) and $4F (set by this actor's first interaction).
; 
; Flag $4F already set at spawn: no sequence runs; the actor clears bit $2000 of its flag word, sets musicRoomGroup to 2 and idles (SetEntryHere + RTL).
; 
; Flag $4F clear: the actor waits for flag $4C, spawns the child code_05857A and clears bit $2000 of its flag word. The child writes TM $15, CGADSUB $A1 and COLDATA $E0 every frame (dark cave tint) until flag $4F is set, then dies. The interaction handler code_0584A9 prints the guard's "the ship is coming out of the cave" line on the first talk and sets flag $4F; later talks print the closing line.
; 
; Flag $4F set while waiting: the lookout masks the joypad (joypadMaskStd), starts music $03, waits 2 ticks and a vblank, clears backdropColors, writes COLDATA $FF, TM $17 and CGADSUB $A2, waits 60 ticks, spawns oneshot_backdrop_fade_out_1C (the backdrop ramp), waits 192 ticks, writes CGADSUB $22, waits 120 ticks, prints the closing line and releases the joypad mask. vblank_joypad supplies the vblank wait.
---------------------------------------------

?INCLUDE 'oneshot_backdrop_fade_out_1C'
?INCLUDE 'vblank_joypad'

!joypadMaskStd                  065A
!musicRoomGroup                 06F6
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132
!backdropColors                 7F0C00

---------------------------------------------

gs2C_crow_crew [
  actor-def < #02, #00, #30, {

  code_058427:
    COP [NudgePosition] ( #00, #FC )
    COP [SetInteractHandler] ( &code_0584A9 )
    COP [BranchOnFlagByte] ( #4F, #01, &code_058498 )
    COP [WaitOnFlagByte] ( #4C, #01 )
    COP [SpawnAfterFlags] ( @code_05857A, #$2000 )
    LDA #$2000
    TRB $10
    COP [WaitOnFlagByte] ( #4F, #01 )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [StartMusic] ( #03 )
    COP [WaitByte] ( #01 )
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    LDA #$0000
    STA $7F0C01
    SEP #$20
    STA $backdropColors
    LDA #$FF
    STA $COLDATA
    LDA #$17
    STA $TM
    LDA #$A2
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
    COP [WaitByte] ( #BF )
    SEP #$20
    LDA #$22
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0584FB )
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]

code_058498 {
    LDA #$2000
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryHere]
    RTL 
}

code_0584A9 {
    COP [BranchOnFlagByte] ( #4F, #01, &code_0584B7 )
    COP [PrintDialogString] ( &dialogstring_0584BC )
    COP [SetFlagByte] ( #4F )
    RTL 
}

code_0584B7 {
    COP [PrintDialogString] ( &dialogstring_0584FB )
    RTL 
}

dialogstring_0584BC `[DEF]Guard: Oh short King,[N]look there. The ship is[N]coming out of the cave![END]`

dialogstring_0584FB `[DEF]Guard: After living in [N]darkness for so long, [N]the brightness is like [N]a new beginning. [FIN]How can invaders come[N]to destroy a world as[N]beautiful as this?[END]`

code_05857A {
    COP [SetEntryHere]
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$A1
    STA $CGADSUB
    LDA #$E0
    STA $COLDATA
    REP #$20
    COP [BranchOnFlagByte] ( #4F, #01, &code_058596 )
    RTL 
}

code_058596 {
    COP [Die]
}