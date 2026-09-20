; Kara in the Angel Village annex — compares to a floating city.
; 
; NPC. Says: "In the Floating City, many houses are built
; on rafts. Kind of like Watermia." Draws connections between
; the locations the party has visited.
---------------------------------------------

---------------------------------------------

av6A_kara [
  actor-def < #1A, #00, #30, {

  code_06C385:
    COP [BranchIfFlagByte] ( #8D, #01, &av6A_kara_destroy )
    COP [ExitIfFlagByte] ( #8C, #01 )
    LDA #$2000
    TRB $10
    COP [SetOnInteract] ( &code_06C3AC )
    COP [ExitIfFlagByte] ( #A9, #01 )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C3AC {
    COP [PrintDialogString] ( &dialogstring_06C417 )
    RTL 
}
---------------------------------------------

av6A_kara_destroy {
    COP [Die]
}
---------------------------------------------

dialogstring_06C417 `[TPL:A][TPL:1]Kara: In the Floating [N]City, many houses [N]are built on rafts. [FIN]Kind of romantic.[N]I like it.[PAL:0][END]`