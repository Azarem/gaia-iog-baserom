; Slugger enemy — slug creature on Larai Cliff with 4-direction chase AI.
; 
; Waits offscreen, then uses DirToPlayer to pick a cardinal direction
; toward the player. Moves in that direction with animated sprite
; movement, periodically reassessing direction and checking wall
; collisions (BranchIfSolid*). If direction is ambiguous, picks
; randomly. Used in the Larai Cliff area (map $1B).
---------------------------------------------

---------------------------------------------

ir1B_slugger [
  actor-def < #11, #00, #00, {

  code_0A8DBA:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8DBD:
    COP [SetEntryHereAndYield]

  code_0A8DBF:
    COP [DirToPlayer]
    CMP #$0000
    BNE loc_0A8DC9
    JMP $&code_0A8E78

  loc_0A8DC9:
    CMP #$0002
    BNE loc_0A8DD1
    JMP $&code_0A8E59

  loc_0A8DD1:
    CMP #$0004
    BNE loc_0A8DD9
    JMP $&code_0A8E97

  loc_0A8DD9:
    CMP #$0006
    BNE code_0A8DE1
    JMP $&code_0A8E3A

  code_0A8DE1:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8E27
    BEQ loc_0A8E14
    DEC 
    BEQ loc_0A8DF0
    BRA loc_0A8E02

  loc_0A8DF0:
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidWest] ( &code_0A8DBD )
    COP [StageSpriteLoopMoveX] ( #13, #02, #14 )
    COP [AnimLoop]
    COP [LoopEnd]
    BRA code_0A8DBF

  loc_0A8E02:
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidEast] ( &code_0A8DBD )
    COP [StageSpriteLoopMoveX] ( #93, #02, #13 )
    COP [AnimLoop]
    COP [LoopEnd]
    BRA code_0A8DBF

  loc_0A8E14:
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0A8DBD )
    COP [StageSpriteLoopMoveY] ( #12, #02, #14 )
    COP [AnimLoop]
    COP [LoopEnd]
    JMP $&code_0A8DBF

  loc_0A8E27:
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0A8DBD )
    COP [StageSpriteLoopMoveY] ( #11, #02, #13 )
    COP [AnimLoop]
    COP [LoopEnd]
    JMP $&code_0A8DBF
} >
]

code_0A8E3A {
    COP [BranchIfSolidWest] ( &code_0A8DE1 )
    COP [StageSpriteLoop] ( #16, #04 )
    COP [AnimLoop]

  loc_0A8E44:
    COP [BranchIfSolidWest] ( &code_0A8E50 )
    COP [StageSpriteMoveX] ( #16, #04 )
    COP [AnimOnce]
    BRA loc_0A8E44
}

code_0A8E50 {
    COP [StageSpriteLoop] ( #10, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DBD
}

code_0A8E59 {
    COP [BranchIfSolidEast] ( &code_0A8DE1 )
    COP [StageSpriteLoop] ( #96, #04 )
    COP [AnimLoop]

  loc_0A8E63:
    COP [BranchIfSolidEast] ( &code_0A8E6F )
    COP [StageSpriteMoveX] ( #96, #03 )
    COP [AnimOnce]
    BRA loc_0A8E63
}

code_0A8E6F {
    COP [StageSpriteLoop] ( #90, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DBD
}

code_0A8E78 {
    COP [BranchIfSolidNorth] ( &code_0A8DE1 )
    COP [StageSpriteLoop] ( #15, #04 )
    COP [AnimLoop]

  loc_0A8E82:
    COP [BranchIfSolidNorth] ( &code_0A8E8E )
    COP [StageSpriteMoveY] ( #15, #04 )
    COP [AnimOnce]
    BRA loc_0A8E82
}

code_0A8E8E {
    COP [StageSpriteLoop] ( #0F, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DBD
}

code_0A8E97 {
    COP [BranchIfSolidSouth] ( &code_0A8DE1 )
    COP [StageSpriteLoop] ( #14, #04 )
    COP [AnimLoop]

  loc_0A8EA1:
    COP [BranchIfSolidSouth] ( &code_0A8EAD )
    COP [StageSpriteMoveY] ( #14, #03 )
    COP [AnimOnce]
    BRA loc_0A8EA1
}

code_0A8EAD {
    COP [StageSpriteLoop] ( #0E, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DBD
}