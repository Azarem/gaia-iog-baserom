; Floating platform controller for the Sky Garden main area.
; 
; Manages the moving platforms that the player rides between
; garden sections (~116 lines). Handles platform spawn,
; movement paths, player attachment/detachment, and the
; rhythmic movement cycle of each platform.
---------------------------------------------

---------------------------------------------

sg4C_platform1 [
  actor-def < #35, #01, #03, {

  code_05F507:
    COP [SpawnAfterAbsFlags] ( @code_05F522, #$0168, #$00E0, #$2301 )
    COP [BranchOnFlagByte] ( #60, #01, &code_05F556 )
    COP [NudgePosition] ( #08, #00 )
    COP [WaitOnFlagByte] ( #60, #01 )
    BRA loc_05F54F
} >
]

code_05F522 {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #60, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_platform2 [
  actor-def < #35, #01, #03, {

  code_05F536:
    COP [SpawnAfterAbsFlags] ( @code_05F560, #$0168, #$0120, #$2301 )
    COP [BranchOnFlagByte] ( #61, #01, &code_05F556 )
    COP [NudgePosition] ( #08, #00 )
    COP [WaitOnFlagByte] ( #61, #01 )

  loc_05F54F:
    COP [StageSpriteLoopMoveX] ( #35, #80, #12 )
    COP [AnimLoop]
} >
]

code_05F556 {
    LDA #$0100
    STA $14
    COP [ClearCollisionHere]
    COP [SetEntryHere]
    RTL 
}

code_05F560 {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #61, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_platform3 [
  actor-def < #35, #01, #03, {

  code_05F574:
    COP [SpawnAfterAbsFlags] ( @code_05F58F, #$0098, #$00C0, #$2301 )
    COP [BranchOnFlagByte] ( #62, #01, &code_05F5C3 )
    COP [NudgePosition] ( #08, #00 )
    COP [WaitOnFlagByte] ( #62, #01 )
    BRA loc_05F5BC
} >
]

code_05F58F {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #62, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_platform4 [
  actor-def < #35, #01, #03, {

  code_05F5A3:
    COP [SpawnAfterAbsFlags] ( @code_05F5CD, #$0098, #$0100, #$2301 )
    COP [BranchOnFlagByte] ( #63, #01, &code_05F5C3 )
    COP [NudgePosition] ( #08, #00 )
    COP [WaitOnFlagByte] ( #63, #01 )

  loc_05F5BC:
    COP [StageSpriteLoopMoveX] ( #35, #80, #11 )
    COP [AnimLoop]
} >
]

code_05F5C3 {
    LDA #$0100
    STA $14
    COP [ClearCollisionHere]
    COP [SetEntryHere]
    RTL 
}

code_05F5CD {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #63, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}