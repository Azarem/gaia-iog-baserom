!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

sc06_hamlet [
  actor-def < #23, #00, #10, {

  code_04A1DA:
    COP [BranchIfFlagByte] ( #1B, #01, &code_04A2EB )
    COP [BranchIfFlagByte] ( #3D, #01, &code_04A2ED )
    COP [BranchIfFlagByte] ( #16, #00, &code_04A2EB )
    COP [SetOnInteract] ( &code_04A30C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #27, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04A311 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0038, #$01A0, &code_04A238 )
    COP [BranchIfPlayerAt] ( #$0038, #$019F, &code_04A238 )
    COP [BranchIfPlayerAt] ( #$0038, #$019E, &code_04A238 )
    COP [BranchIfPlayerAt] ( #$0038, #$019D, &code_04A238 )
    COP [BranchIfPlayerAt] ( #$0038, #$019C, &code_04A238 )
    RTL 
} >
]

code_04A238 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [LoopInit] ( #1E )
    LDY $playerActor
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
    COP [SpawnAfterFlags] ( @code_04A2F9, #$2000 )
    COP [StageSpriteLoopMoveX] ( #29, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #01 )
    LDA #$0800
    TSB $10

  code_04A288:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #02, #00, &code_04A288 )
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

  code_04A2B5:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #04, #00, &code_04A2B5 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #1A )

  code_04A2C6:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #09, #00, &code_04A2C6 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #28, #10, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
}

code_04A2EB {
    COP [Die]
}

code_04A2ED {
    COP [SetTilePos] ( #0B, #19 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04A30C )
    BRA code_04A2B5
}

code_04A2F9 {
    COP [LoopInit] ( #40 )
    LDY $playerActor
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_04A30C {
    COP [PrintDialogString] ( &dialogstring_04A356 )
    RTL 
}

dialogstring_04A311 `[TPL:9][TPL:0]The pig's wrecking[N]the room![FIN]But why is there[N]a pig in my house?[END]`

dialogstring_04A356 `[TPL:8]Oink  oink[END]`