; Stairway guard NPC in Edward Castle.
; 
; Two-state dialog: tells Will to wait during breakfast, then directs
; him to climb the stairs to the interview room.
---------------------------------------------

---------------------------------------------

ec0A_stair_guard [
  actor-def < #1A, #00, #10, {

  code_04C301:
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #21, #01, &code_04C32A )
    COP [SetInteractHandler] ( &code_04C336 )
    COP [WaitOnFlagByte] ( #19, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_04C32A {
    COP [SetInteractHandler] ( &code_04C346 )
    LDA #$0200
    TSB $12
    COP [SetEntryHere]
    RTL 
}

code_04C336 {
    COP [BranchOnFlagByte] ( #19, #01, &code_04C341 )
    COP [PrintDialogString] ( &dialogstring_04C34B )
    RTL 
}

code_04C341 {
    COP [PrintDialogString] ( &dialogstring_04C379 )
    RTL 
}

code_04C346 {
    COP [PrintDialogString] ( &dialogstring_04C3B4 )
    RTL 
}

dialogstring_04C34B `[DEF]King Edward is having[N]breakfast. Wait a while,[N]then enter.[END]`

dialogstring_04C379 `[DEF]The interview room is[N]before you. Climb the[N]stairs to meet the king.[END]`

dialogstring_04C3B4 `[DEF]Zzzzzz...Zzzzzz...[END]`