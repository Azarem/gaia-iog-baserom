!chatPtr                        7F000A
!orbitAngle                     7F0010
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sg51_plasma_snake1 [
  actor-def < #3B, #00, #02, {

  code_0ACCD7:
    COP [SpawnAfterFlags] ( @code_0ACDCE, #$0200 )
    COP [SpawnAfterFlags] ( @code_0ACDCE, #$0200 )
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $chatPtr, X
    BRA loc_0ACD0C
} >
]

sg4E_plasma_snake2 [
  actor-def < #3B, #00, #02, {

  code_0ACCF4:
    COP [SpawnAfterFlags] ( @code_0ACDCE, #$0200 )
    COP [SpawnAfterFlags] ( @code_0ACDCE, #$0200 )
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0001
    STA $chatPtr, X

  loc_0ACD0C:
    LDY $06
    LDA #$0000
    STA $0024, Y
    LDA $0006, Y
    TAY 
    LDA #$0000
    STA $0024, Y

  code_0ACD1E:
    COP [BranchIfSolidOffset] ( #00, #01, &code_0ACD4A )
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0ACDA2 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ACD76 )
    LDA $chatPtr, X
    BNE loc_0ACD40
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #12, #11 )
    COP [AnimLoop]
    BRA code_0ACD1E

  loc_0ACD40:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #02, #01 )
    COP [AnimLoop]
    BRA code_0ACD1E
} >
]

code_0ACD4A {
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0ACD76 )
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0ACD1E )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0ACDA2 )
    LDA $chatPtr, X
    BNE loc_0ACD6C
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #12, #12 )
    COP [AnimLoop]
    BRA code_0ACD4A

  loc_0ACD6C:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #02, #02 )
    COP [AnimLoop]
    BRA code_0ACD4A
}

code_0ACD76 {
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0ACDA2 )
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ACD4A )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ACD1E )
    LDA $chatPtr, X
    BNE loc_0ACD98
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #11, #12 )
    COP [AnimLoop]
    BRA code_0ACD76

  loc_0ACD98:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #01, #02 )
    COP [AnimLoop]
    BRA code_0ACD76
}

code_0ACDA2 {
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ACD1E )
    COP [BranchIfSolidOffset] ( #00, #01, &code_0ACD76 )
    COP [BranchIfSolidOffset] ( #01, #01, &code_0ACD4A )
    LDA $chatPtr, X
    BNE loc_0ACDC4
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #11, #11 )
    COP [AnimLoop]
    BRA code_0ACDA2

  loc_0ACDC4:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #01, #01 )
    COP [AnimLoop]
    BRA code_0ACDA2
}

code_0ACDCE {
    COP [StageSprAndHitbox] ( #3B )
    LDA #$0000
    STA $moveXAlt, X
    STA $moveXAlt, X
    STA $2C
    STA $2E
    STA $2A
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0ACDE9
    RTL 

  loc_0ACDE9:
    LDY $04
    LDA $0028, Y
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA $moveXAlt, X
    PHA 
    LDA $moveYAlt, X
    PHA 
    LDA $sprTimer, X
    PHA 
    TXA 
    TYX 
    TAY 
    PLA 
    STA $sprTimer, X
    PLA 
    STA $7F100E, X
    PLA 
    STA $7F100C, X
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimLoop]
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    LDA $orbitAngle, X
    STA $28
    BRA loc_0ACDE9
}