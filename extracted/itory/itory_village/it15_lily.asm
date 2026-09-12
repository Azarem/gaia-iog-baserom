?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'

!joypadMaskStd                  065A
!cameraTargetY                  06C2
!cameraBoundsY                  06DC
!playerActor                    09AA
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

it15_lily [
  actor-def < #1A, #00, #10, {

  code_04E2A6:
    COP [BranchIfFlagByte] ( #2B, #00, &code_04E2B9 )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04E3CC )
    COP [SetTilePos] ( #41, #26 )
    JMP $&code_04E398
} >
]

code_04E2B9 {
    COP [BranchIfFlagByte] ( #26, #00, &code_04E3CC )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04E3D5 )
    LDA #$6000
    TRB $joypadMaskStd
    LDA #$1000
    TRB $10

  code_04E2D7:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #40, #01, &code_04E2E6 )
    COP [BranchIfButton] ( #$0F01, &code_04E3CE )
    RTL 
}

code_04E2E6 {
    LDA #$1000
    TSB $10
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$80
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @oneshot_palette_flash_18.code_00B7CE )
    COP [WaitByte] ( #7F )
    COP [SetFlagByte] ( #01 )
    COP [LoopInit] ( #10 )
    LDA $cameraTargetY
    SEC 
    SBC #$0010
    STA $cameraTargetY
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $0016, Y
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [LoopNext]
    LDA #$0300
    STA $cameraBoundsY
    COP [ClearFlagByte] ( #01 )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_palette_flash_19.code_00B7D8 )
    COP [WaitByte] ( #9D )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_04E46F )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #2B )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1E, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #21, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
}

code_04E398 {
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$0001
    JSL $@InitPlayerScriptVariant
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04E53C )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveY] ( #1F, #04, #12 )
    COP [AnimLoop]
}

code_04E3CC {
    COP [Die]
}

code_04E3CE {
    COP [PrintDialogString] ( &dialogstring_04E440 )
    JMP $&code_04E2D7
}

dialogstring_04E3D5 `[TPL:F][TPL:2]Lilly: This is my[N]village, but you're[N]probably surprised that[N]there are no houses.[FIN]Will, try playing the [N]melody that called to me [N]under Edward Castle.[PAL:0][END]`

dialogstring_04E440 `[TPL:E][TPL:2]Lilly: Will. Where [N]are you going? [N]Play the melody here.[PAL:0][END]`

dialogstring_04E46F `[TPL:F][TPL:2]Lilly:[N]Were you surprised?[FIN]There's a barrier around [N]this village. Most [N]people can't see it. [FIN]The princess is [N]getting to be [N]a bother.... [FIN]On the road, all I heard [N]was "My feet hurt, I'm [N]thirsty.ˮ I'm tired [N]of hearing it.[PAL:0][END]`

dialogstring_04E53C `[TPL:F][TPL:2]Lilly: We didn't ask her[N]to come along.[FIN]Will. This is my house. [N]You can look around [N]the village, but then [N]come back here.[PAL:0][END]`