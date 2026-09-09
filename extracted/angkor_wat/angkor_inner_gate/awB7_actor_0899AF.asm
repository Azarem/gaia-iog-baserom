---------------------------------------------

awB7_actor_0899AF [
  actor-def < #03, #00, #00, {

  code_0899B2:
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    LDA #$0010
    TRB $10
    COP [BranchIfPlayerInAbsTiles] ( #08, #12, #0A, #14, &code_0899CE )
    COP [BranchIfPlayerInAbsTiles] ( #03, #10, #07, #18, &code_0899D4 )
    RTL 
} >
]

code_0899CE {
    LDA #$0010
    TSB $10
    RTL 
}

code_0899D4 {
    LDA #$0010
    TSB $10
    COP [SolidHighAbs] ( #05, #0F )
    COP [SolidHighAbs] ( #06, #0F )
    COP [SpawnAfterFlags] ( @code_0899FB, #$2000 )
    COP [StageSpriteMoveX] ( #85, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    RTL 
}

code_0899FB {
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    COP [WaitByte] ( #01 )
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    ORA #$0200
    STA $000E, Y
    COP [WaitByte] ( #01 )
    BRA code_0899FB
}