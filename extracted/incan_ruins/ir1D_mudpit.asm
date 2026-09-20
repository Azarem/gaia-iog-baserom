; Mud Pit enemy — underground hazard that emerges to attack.
; 
; Waits offscreen, then determines nearest axis to player. Picks
; a direction (N/S/E/W) with random fallback, emerges with sprite
; animation, moves toward the player in the chosen direction with
; solid collision checks, then dives back underground. Repeats
; the emerge-attack-submerge cycle.
---------------------------------------------

---------------------------------------------

ir1D_mudpit [
  actor-def < #00, #00, #00, {

  code_0A8B1E:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8B21:
    COP [SetEntryExit]

  code_0A8B23:
    COP [BranchNearerAxis] ( &code_0A8B29, &code_0A8B33 )
} >
]

code_0A8B29 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A8B56, &code_0A8B33, &code_0A8B71 )
}

code_0A8B33 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A8B8C, &code_0A8B3D, &code_0A8BA8 )
}

code_0A8B3D {
    RTL 
}

code_0A8B3E {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A8B4E )
}

code_list_0A8B4E [
  &code_0A8B56   ;00
  &code_0A8B71   ;01
  &code_0A8B8C   ;02
  &code_0A8BA8   ;03
]

code_0A8B56 {
    COP [BranchIfPlayerNear] ( #03, &code_0A8BC4 )
    COP [BranchIfSolidWest] ( &code_0A8B3E )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A8B3E )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    BRA code_0A8B23
}

code_0A8B71 {
    COP [BranchIfPlayerNear] ( #03, &code_0A8BEF )
    COP [BranchIfSolidEast] ( &code_0A8B3E )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A8B3E )
    COP [StageSpriteMoveX] ( #88, #11 )
    COP [AnimOnce]
    BRA code_0A8B23
}

code_0A8B8C {
    COP [BranchIfPlayerNear] ( #03, &code_0A8C1A )
    COP [BranchIfSolidNorth] ( &code_0A8B3E )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A8B3E )
    COP [StageSpriteMoveY] ( #06, #12 )
    COP [AnimOnce]
    JMP $&code_0A8B23
}

code_0A8BA8 {
    COP [BranchIfPlayerNear] ( #03, &code_0A8C45 )
    COP [BranchIfSolidSouth] ( &code_0A8B3E )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A8B3E )
    COP [StageSpriteMoveY] ( #04, #11 )
    COP [AnimOnce]
    JMP $&code_0A8B23
}

code_0A8BC4 {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveX] ( #07, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #25, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B21
}

code_0A8BEF {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveX] ( #87, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #88, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A5, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B21
}

code_0A8C1A {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveY] ( #05, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #24, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B21
}

code_0A8C45 {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveY] ( #03, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #23, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B21
}