; Girlfriend NPC in the Adequacy Manor — matching comic scene.
; 
; Counterpart to the boyfriend NPC. Says: "He had something in
; his eye... Ha ha ha." Both give excuses when found together.
---------------------------------------------

---------------------------------------------

fr38_girlfriend [
  actor-def < #0D, #00, #10, {

  code_05BA90:
    COP [SetInteractHandler] ( &code_05BABD )
    COP [NudgePosition] ( #04, #00 )
    COP [WaitWhileOffscreen] ( #01 )
    COP [WaitByte] ( #1D )
    COP [StageSprAndHitbox] ( #10 )
    COP [StageMoveX] ( #14 )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    COP [StageMoveX] ( #00 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05BABD {
    COP [PrintDialogString] ( &dialogstring_05BAC2 )
    RTL 
}

dialogstring_05BAC2 `[DEF]He had something [N]in his eye... [N]Ha ha ha. [END]`