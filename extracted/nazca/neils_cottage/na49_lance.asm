!gfxCacheIdxB                   064A

---------------------------------------------

na49_lance [
  actor-def < #03, #00, #10, {

  code_05E145:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E1E9 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #05, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05E1EE )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighOffset] ( #00, #01 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05E227 )
    COP [SetFlagByte] ( #6D )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0003
    STA $0D66
    LDA #$0004
    STA $0D68
    LDA #$0005
    STA $0D6A
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0274, #$0264, #00, #0D )
    COP [QueueMapChange] ( #4B, #$0120, #$0080, #00, #$4400 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E1E9 {
    COP [PrintDialogString] ( &dialogstring_05E1EE )
    RTL 
}

dialogstring_05E1EE `[TPL:A][TPL:4]Lance: I've only had mine [N]on for three weeks.[N]I guess I lose![END]`

dialogstring_05E227 `[TPL:A][TPL:4]Lance: We're going, too![FIN]We don't want Will to be[N]the only one having [N]a good time. [FIN][PAL:0]The group went to the [N]Nazca Desert...[END]`