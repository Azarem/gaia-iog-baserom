!orbitAngle                     7F0010

---------------------------------------------

h_ec_actor_04FCFB [
  actor-def < #18, #00, #23, {

  code_04FCFE:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_04FD06 )
    RTL 
} >
]

code_04FD06 {
    LDA #$0000
    STA $orbitAngle, X
    BRA loc_04FD16

  code_04FD0F:
    LDA #$0001
    STA $orbitAngle, X

  loc_04FD16:
    COP [AddPosition] ( #08, #00 )
    COP [SpawnAfterFlags] ( @code_04FD5E, #$0301 )
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
    BNE loc_04FD59
    COP [SolidHighHere]
    BRA loc_04FD5B

  loc_04FD59:
    COP [ClearAllHere]

  loc_04FD5B:
    COP [SetEntryContinue]
    RTL 
}

code_04FD5E {
    COP [StageSpriteLoop] ( #1F, #03 )
    COP [AnimLoop]
    COP [Die]
}