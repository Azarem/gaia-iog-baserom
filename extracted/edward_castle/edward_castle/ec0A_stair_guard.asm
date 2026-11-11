; Stairway guard NPC in Edward Castle (scene $0A).
; 
; $21 clear: solid, blocking the stairs. Talk: 'King Edward is having breakfast. Wait a while, then enter.' The wait is on flag $19 (Will has met Kara; set by ec0A_kara), not on time: once $19 is set the guard clears his solid mark, steps aside, becomes solid again beside the stairs and says 'The interview room is before you. Climb the stairs to meet the king.'
; 
; $21 set (after the throne scene): asleep ('Zzzzzz...').
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