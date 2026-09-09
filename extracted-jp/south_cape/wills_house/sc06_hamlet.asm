!joypadMaskStd                  065A
!decelStepCounter               09B8

---------------------------------------------

h_sc06_hamlet [
  actor-def < #23, #00, #10, {

  code_049F8B:
    COP [BranchIfFlagByte] ( #1B, #01, &code_04A08C )
    COP [BranchIfFlagByte] ( #3D, #01, &code_04A08E )
    COP [BranchIfFlagByte] ( #16, #00, &code_04A08C )
    COP [SetOnInteract] ( &code_04A0AD )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #27, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04A0B2 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0038, #$01A0, &code_049FD9 )
    COP [BranchIfPlayerAt] ( #$0038, #$019F, &code_049FD9 )
    COP [BranchIfPlayerAt] ( #$0038, #$019E, &code_049FD9 )
    RTL 
} >
]

code_049FD9 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [LoopInit] ( #1E )
    LDY $decelStepCounter
    LDA #$0038
    STA $0014, Y
    LDA #$01A0
    STA $0016, Y
    COP [LoopNext]
    COP [StageSpriteMoveY] ( #26, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #28, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #29, #04 )
    COP [AnimLoop]
    COP [SpawnAfterFlags] ( @code_04A09A, #$2000 )
    COP [StageSpriteLoopMoveX] ( #29, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #01 )
    LDA #$0800
    TSB $10

  code_04A029:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #02, #00, &code_04A029 )
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #26, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [SolidHighHere]

  code_04A056:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #04, #00, &code_04A056 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #1A )

  code_04A067:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #09, #00, &code_04A067 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #28, #10, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
}

code_04A08C {
    COP [Die]
}

code_04A08E {
    COP [SetTilePos] ( #0B, #19 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04A0AD )
    BRA code_04A056
}

code_04A09A {
    COP [LoopInit] ( #40 )
    LDY $decelStepCounter
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_04A0AD {
    COP [PrintWideString] ( &widestring_04A0E5 )
    RTL 
}

widestring_04A0B2 `[TPL:9][TPL:0]ブタが 部屋の中をあらしているっ![FIN]しかし なんで ぼくの家に[N]ブタが···[END]`

widestring_04A0E5 `[TPL:8]ブヒ ブヒッ[END]`