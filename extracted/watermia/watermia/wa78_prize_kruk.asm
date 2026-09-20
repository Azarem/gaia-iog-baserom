; Prize Kruk display in Watermia — Russian Glass reward.
; 
; NPC: "These are the Kruks I was given. I have to let everyone
; know." Displays the Kruk birds won from the Russian Glass
; game. Shows the game's reward/stakes.
---------------------------------------------

---------------------------------------------

wa78_prize_kruk [
  actor-def < #1A, #00, #10, {

  code_079B09:
    COP [BranchIfFlagByte] ( #94, #01, &code_079B29 )
    COP [BranchIfFlagByte] ( #97, #00, &code_079B29 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_079B2B )
    COP [SolidHighHere]
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