; Shrubber enemy — plant creature in Angkor Wat (~118 lines).
; 
; Camouflaged enemy that hides in vegetation and attacks
; when the player walks nearby. Surprise attack pattern
; with brief visibility before striking.
---------------------------------------------

---------------------------------------------

awB0_shrubber [
  actor-def < #0A, #00, #01, {

  code_0BB1B7:
    LDA #$0018
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SetHitCallback] ( &code_0BB1C9 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BB1C9 {
    COP [ClearLowHere]
    LDA #$0100
    TRB $10
    LDA #$0110
    TRB $12
    BRA code_0BB1E9
}

awB0_shrubber2 [
  actor-def < #0A, #00, #00, {

  code_0BB1DA:
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [WaitWhileOffscreen] ( #15 )
    COP [BranchIfPlayerNear] ( #05, &code_0BB1E9 )
    BRA code_0BB1DA
} >
]

code_0BB1E9 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BB1F9, &code_0BB237 )
}

code_0BB1F9 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB203, &code_0BB203, &code_0BB218 )
}

code_0BB203 {
    COP [BranchIfSolidWest] ( &code_0BB20F )
    COP [StageSpriteMoveX] ( #0E, #04 )
    COP [AnimOnce]
    BRA code_0BB203
}

code_0BB20F {
    COP [StageSpriteMoveXY] ( #0B, #4B, #49 )
    COP [AnimOnce]
    BRA code_0BB1DA
}

code_0BB218 {
    COP [BranchIfSolidEast] ( &code_0BB224 )
    COP [StageSpriteMoveX] ( #0E, #03 )
    COP [AnimOnce]
    BRA code_0BB218
}

code_0BB224 {
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveXY] ( #0B, #4B, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    BRA code_0BB1DA
}

code_0BB237 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB241, &code_0BB241, &code_0BB256 )
}

code_0BB241 {
    COP [BranchIfSolidNorth] ( &code_0BB24D )
    COP [StageSpriteMoveY] ( #0D, #04 )
    COP [AnimOnce]
    BRA code_0BB241
}

code_0BB24D {
    COP [StageSpriteMoveY] ( #0B, #4B )
    COP [AnimOnce]
    JMP $&code_0BB1DA
}

code_0BB256 {
    COP [BranchIfSolidSouth] ( &code_0BB262 )
    COP [StageSpriteMoveY] ( #0D, #03 )
    COP [AnimOnce]
    BRA code_0BB256
}

code_0BB262 {
    LDA #$2000
    TSB $12
    COP [StageSpriteMoveY] ( #0B, #4B )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    JMP $&code_0BB1DA
}