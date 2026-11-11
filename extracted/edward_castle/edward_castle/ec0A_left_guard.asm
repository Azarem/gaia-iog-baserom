; Left guard at the castle entrance (scene $0A).
; 
; Three states, chosen at spawn by flag $21 (the throne scene is over) and flag $3F (the letter was shown):
; - $21 and $3F clear (first arrival): sets the joypad lock ($CFFC in joypadMaskStd), runs one walking loop, prints the intrusion dialog and the 'Will shows the letter to the guard' / 'you may pass' lines, sets $3F and releases the lock. The actor never checks for a letter item; the dialog is fixed, so the lock lasts only until this cutscene ends.
; - $3F set, $21 clear: patrols between two walking loops for good; talk: 'Go to the second floor if you want to meet King Edward.'
; - $21 set (after the throne scene): parked solid at tile (06,27); talk: 'Ah! It's you! You've escaped from the prison... Run from this castle.'
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

ec0A_left_guard [
  actor-def < #1D, #00, #10, {

  code_04BFE7:
    COP [BranchOnFlagByte] ( #21, #01, &code_04C04B )
    COP [SetInteractHandler] ( &code_04C05D )
    COP [BranchOnFlagByte] ( #3F, #01, &code_04BFFD )
    LDA #$CFFC
    TSB $joypadMaskStd
} >
]

code_04BFFD {
    COP [StageSpriteLoopMoveX] ( #21, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [BranchOnFlagByte] ( #3F, #01, &code_04C023 )
    COP [PrintDialogString] ( &dialogstring_04C115 )
    COP [SetFlagByte] ( #3F )
    LDA #$CFFC
    TRB $joypadMaskStd
}

code_04C023 {
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #1B, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #14, #11 )
    COP [AnimLoop]
    BRA code_04BFFD
}

code_04C04B {
    COP [SetInteractHandler] ( &code_04C062 )
    COP [SetTilePos] ( #06, #27 )
    COP [MarkSolidHere]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_04C05D {
    COP [PrintDialogString] ( &dialogstring_04C067 )
    RTL 
}

code_04C062 {
    COP [PrintDialogString] ( &dialogstring_04C0AF )
    RTL 
}

dialogstring_04C067 `[TPL:A]This is King Edward's[N]castle.[FIN]Go to the second[N]floor if you want to[N]meet King Edward.[END]`

dialogstring_04C0AF `[TPL:B]Ah! It's you![FIN]You've escaped[N]from the prison...[FIN]Trust what I say. Run[N]from this castle. It'd[N]be terrible if King[N]Edward found you here.[END]`

dialogstring_04C115 `[TPL:A]Soldier: This is King[N]Edward's castle. I must[N]report this intrusion.[FIN][DLG:3,6][SIZ:D,3][TPL:0]Will shows the letter[N]to the guard.[FIN][TPL:A][PAL:0]Soldier: A guest of the[N]King? I'm sorry, you[N]may pass.[END]`