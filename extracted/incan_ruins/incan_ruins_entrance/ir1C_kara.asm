; Kara at the Incan Ruins entrance — chases after the party.
; 
; Before flag $4B: waits for player to reach tiles (1A,0F)-(1B,11),
; then locks joypad, plays music #1B, Kara walks in from the side
; and scolds Will for leaving her behind. Two dialog states: initial
; scolding, then asks if he found what he was looking for.
; After flag $4B: repositions and waits with different dialog.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

ir1C_kara [
  actor-def < #12, #00, #10, {

  code_09CEA6:
    COP [BranchOnFlagByte] ( #4B, #01, &code_09CF07 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #1A, #0F, #1B, #11, &code_09CEB7 )
    RTL 
} >
]

code_09CEB7 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #01 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_09CF19 )
    COP [StartMusic] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #03 )
    COP [WaitOnFlagByte] ( #02, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteLoopMoveX] ( #18, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
}

code_09CF07 {
    COP [SetTilePos] ( #15, #13 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_09CF14 )
    COP [SetEntryHere]
    RTL 
}

code_09CF14 {
    COP [PrintDialogString] ( &dialogstring_09CF59 )
    RTL 
}

dialogstring_09CF19 `[DLG:3,6][SIZ:D,3][TPL:1]Kara: You're so mean!! [N]Leaving me behind! How [N]could you do that![PAL:0][END]`

dialogstring_09CF59 `[DLG:3,6][SIZ:D,3][TPL:1]Kara: Well? Did you [N]find what you were [N]looking for?[PAL:0][END]`