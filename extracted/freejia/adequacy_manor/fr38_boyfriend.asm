; Boyfriend NPC in the Adequacy Manor — caught in a comic scene.
; 
; NPC with flag-gated dialog. Says: "She, uh, was just helping
; me... Ha ha ha." Part of the couple joke sequence with the
; girlfriend NPC.
---------------------------------------------

---------------------------------------------

fr38_boyfriend [
  actor-def < #04, #00, #10, {

  code_05BAEA:
    COP [NudgePosition] ( #FC, #00 )
    COP [SetInteractHandler] ( &code_05BB17 )
    COP [WaitWhileOffscreen] ( #01 )
    COP [WaitByte] ( #1D )
    COP [StageSprAndHitbox] ( #09 )
    COP [StageMoveX] ( #13 )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    COP [StageMoveX] ( #00 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05BB17 {
    COP [PrintDialogString] ( &dialogstring_05BB1C )
    RTL 
}

dialogstring_05BB1C `[DEF]She, uh, was just [N]helping me... [N]Ha ha ha. [END]`