?INCLUDE 'oneshot_palette_flash_1C'
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
    COP [AddPosition] ( #00, #FC )
    COP [SetOnInteract] ( &code_0584A9 )
    COP [BranchIfFlagByte] ( #4F, #01, &code_058498 )
    COP [ExitIfFlagByte] ( #4C, #01 )
    COP [SpawnAfterFlags] ( @code_05857A, #$2000 )
    LDA #$2000
    TRB $10
    COP [ExitIfFlagByte] ( #4F, #01 )
    LDA #$EFF0
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
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
    COP [WaitByte] ( #BF )
    SEP #$20
    LDA #$22
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0584FB )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_058498 {
    LDA #$2000
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryContinue]
    RTL 
}

code_0584A9 {
    COP [BranchIfFlagByte] ( #4F, #01, &code_0584B7 )
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
    COP [SetEntryContinue]
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$A1
    STA $CGADSUB
    LDA #$E0
    STA $COLDATA
    REP #$20
    COP [BranchIfFlagByte] ( #4F, #01, &code_058596 )
    RTL 
}

code_058596 {
    COP [Die]
}