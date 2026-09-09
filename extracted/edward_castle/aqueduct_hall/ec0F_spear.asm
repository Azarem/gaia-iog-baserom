---------------------------------------------

ec0F_spear [
  actor-def < #38, #02, #23, {

  code_0A87C6:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0A87D9 )
    RTL 
} >
]

ec0F_spear2 [
  actor-def < #38, #02, #23, {

  code_0A87D1:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_0A87D9 )
    RTL 
} >
]

code_0A87D9 {
    COP [RngByte]
    AND #$003F
    STA $08
    COP [SetEntryExit]
    COP [SpawnMarkedAfter] ( @code_0A882D, #$0301 )
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #13 )
    COP [StageSpriteMoveY] ( #39, #0F )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [PlaySoundCh1] ( #1E )
    COP [CollPriorityClearMax]
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0100
    TSB $10
    COP [WaitByte] ( #EF )
    COP [LoopInit] ( #20 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [ClearLowHere]
    COP [Die]
}

code_0A882D {
    COP [StageSpriteFrame] ( #3B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}