---------------------------------------------

daC3_training_man [
  actor-def < #1F, #00, #10, {

  code_08AD92:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_08ADF3, #$FFE0, #$0020, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_08ADF3, #$FFF0, #$0020, #$1000 )
    LDA #$0008
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08ADF3, #$0000, #$0020, #$1000 )
    LDA #$0010
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08ADF3, #$0010, #$0020, #$1000 )
    LDA #$0018
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08ADF3, #$0020, #$0020, #$1000 )
    LDA #$0020
    STA $0008, Y
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AE09 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08ADF3 {
    COP [StageSprAndHitbox] ( #20 )
    COP [SolidHighHere]

  loc_08ADF8:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_08ADF8
}

code_08AE09 {
    COP [PrintDialogString] ( &dialogstring_08AE0E )
    RTL 
}

dialogstring_08AE0E `[DEF]Have you ever played[N]Snake Panic? I'm still[N]in training for it.[END]`