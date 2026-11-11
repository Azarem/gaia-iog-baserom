; Prize Kruk of the Russian Glass game (scene $78, four placements).
; 
; The actor dies at spawn when $94 is set (the party has left for Euro) or when $97 is clear (the game is not won yet). In between it is a solid Kruk that waits while off screen, shows sprite frame #1C and says "These are the Kruks I was given. I have to let everyone know.".
---------------------------------------------

---------------------------------------------

wa78_prize_kruk [
  actor-def < #1A, #00, #10, {

  code_079B09:
    COP [BranchOnFlagByte] ( #94, #01, &code_079B29 )
    COP [BranchOnFlagByte] ( #97, #00, &code_079B29 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_079B2B )
    COP [MarkSolidHere]
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    RTL 
} >
]

code_079B29 {
    COP [Die]
}

code_079B2B {
    COP [PrintDialogString] ( &dialogstring_079B30 )
    RTL 
}

dialogstring_079B30 `[DEF][TPL:0]These are the Kruks I [N]was given. I have to [N]let everyone know.[PAL:0][END]`