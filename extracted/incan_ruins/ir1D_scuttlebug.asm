; Scuttlebug enemy — fast insect with erratic multi-direction movement.
; 
; Waits offscreen. When player is within 4 tiles, activates and
; enters an aggressive chase loop. Uses DirToPlayer for 4-way
; movement with random directional variation. Alternates between
; pursuing and random patrol. Faster movement speed than Slugger.
---------------------------------------------

---------------------------------------------

ir1D_scuttlebug [
  actor-def < #11, #00, #00, {

  code_0A8EB9:
    COP [SetSpritePalette] ( #0A )
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8EBF:
    COP [SetEntryExit]

  code_0A8EC1:
    COP [DirToPlayer]
    CMP #$0000
    BNE loc_0A8ECB
    JMP $&code_0A8FB0

  loc_0A8ECB:
    CMP #$0002
    BNE loc_0A8ED3
    JMP $&code_0A8F74

  loc_0A8ED3:
    CMP #$0004
    BNE loc_0A8EDB
    JMP $&code_0A8FEB

  loc_0A8EDB:
    CMP #$0006
    BNE code_0A8EE3
    JMP $&code_0A8F38

  code_0A8EE3:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8F26
    BEQ loc_0A8F14
    DEC 
    BEQ loc_0A8EF2
    BRA loc_0A8F03

  loc_0A8EF2:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0A8EBF )
    COP [StageSpriteMoveX] ( #13, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0A8EC1

  loc_0A8F03:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0A8EBF )
    COP [StageSpriteMoveX] ( #93, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0A8EC1

  loc_0A8F14:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0A8EBF )
    COP [StageSpriteMoveY] ( #12, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0A8EC1

  loc_0A8F26:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0A8EBF )
    COP [StageSpriteMoveY] ( #11, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0A8EC1
} >
]

code_0A8F38 {
    COP [BranchIfSolidWest] ( &code_0A8EE3 )
    COP [StageSpriteLoop] ( #16, #04 )
    COP [AnimLoop]

  loc_0A8F42:
    COP [BranchIfSolidWest] ( &code_0A8F53 )
    COP [BranchIfPlayerNear] ( #02, &code_0A8F5C )
    COP [StageSpriteMoveX] ( #16, #04 )
    COP [AnimOnce]
    BRA loc_0A8F42
}

code_0A8F53 {
    COP [StageSpriteLoop] ( #10, #10 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8F5C {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0A8F53 )
    BRA loc_0A8F64

  loc_0A8F64:
    COP [StageSpriteMoveXY] ( #22, #04, #38 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #10, #20 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8F74 {
    COP [BranchIfSolidEast] ( &code_0A8EE3 )
    COP [StageSpriteLoop] ( #96, #04 )
    COP [AnimLoop]

  loc_0A8F7E:
    COP [BranchIfSolidEast] ( &code_0A8F8F )
    COP [BranchIfPlayerNear] ( #02, &code_0A8F98 )
    COP [StageSpriteMoveX] ( #96, #03 )
    COP [AnimOnce]
    BRA loc_0A8F7E
}

code_0A8F8F {
    COP [StageSpriteLoop] ( #90, #10 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8F98 {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0A8F8F )
    BRA loc_0A8FA0

  loc_0A8FA0:
    COP [StageSpriteMoveXY] ( #A2, #03, #38 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #90, #20 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8FB0 {
    COP [BranchIfSolidNorth] ( &code_0A8EE3 )
    COP [StageSpriteLoop] ( #15, #04 )
    COP [AnimLoop]

  loc_0A8FBA:
    COP [BranchIfSolidNorth] ( &code_0A8FCB )
    COP [BranchIfPlayerNear] ( #02, &code_0A8FD4 )
    COP [StageSpriteMoveY] ( #15, #04 )
    COP [AnimOnce]
    BRA loc_0A8FBA
}

code_0A8FCB {
    COP [StageSpriteLoop] ( #0F, #10 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8FD4 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0A8FCB )
    BRA loc_0A8FDC

  loc_0A8FDC:
    COP [StageSpriteMoveY] ( #21, #39 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0F, #20 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A8FEB {
    COP [BranchIfSolidSouth] ( &code_0A8EE3 )
    COP [StageSpriteLoop] ( #14, #04 )
    COP [AnimLoop]

  loc_0A8FF5:
    COP [BranchIfSolidSouth] ( &code_0A9006 )
    COP [BranchIfPlayerNear] ( #02, &code_0A900F )
    COP [StageSpriteMoveY] ( #14, #03 )
    COP [AnimOnce]
    BRA loc_0A8FF5
}

code_0A9006 {
    COP [StageSpriteLoop] ( #0E, #10 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}

code_0A900F {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0A9006 )
    BRA loc_0A9017

  loc_0A9017:
    COP [StageSpriteMoveY] ( #20, #3A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0E, #20 )
    COP [AnimLoop]
    JMP $&code_0A8EBF
}