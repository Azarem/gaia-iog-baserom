!orbitAngle                     7F0010

---------------------------------------------

ec_actor_09C2D0 [
  actor-def < #18, #00, #23, {

  code_09C2D3:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_09C2DB )
    RTL 
} >
]

code_09C2DB {
    LDA #$0000
    STA $orbitAngle, X
    BRA loc_09C2EB

  code_09C2E4:
    LDA #$0001
    STA $orbitAngle, X

  loc_09C2EB:
    COP [AddPosition] ( #08, #00 )
    COP [SpawnAfterFlags] ( @code_09C333, #$0301 )
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [CollPrioritySetMax]
    COP [StageSpriteLoopMoveY] ( #18, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [CollPriorityClearMax]
    LDA #$0100
    TRB $10
    COP [StageSpriteMoveY] ( #18, #35 )
    COP [AnimOnce]
    LDA #$0100
    TSB $10
    COP [CollPrioritySetMin]
    LDA $orbitAngle, X
    BNE loc_09C32E
    COP [SolidHighHere]
    BRA loc_09C330

  loc_09C32E:
    COP [ClearAllHere]

  loc_09C330:
    COP [SetEntryContinue]
    RTL 
}

code_09C333 {
    COP [StageSpriteLoop] ( #1F, #03 )
    COP [AnimLoop]
    COP [Die]
}