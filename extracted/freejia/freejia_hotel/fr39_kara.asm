; Kara at the Freejia hotel — reunites with Lilly, reflects on events.
; 
; Multi-dialog NPC. Initial: "Lilly? Is it Lilly?!" — emotional
; reunion with the spirit companion. Later: "I am glad everyone
; is safe, but..." — hints at lingering concerns about the
; slave trade.
---------------------------------------------

?BANK 05

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

fr39_kara [
  actor-def < #1B, #00, #10, {

  code_05C459:
    COP [BranchOnFlagByte] ( #65, #01, &code_05C4B7 )
    COP [BranchOnFlagByte] ( #58, #01, &code_05C4B7 )
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC #$0008
    STA $0014, Y
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SetFlagByte] ( #58 )
    COP [PrintDialogString] ( &dialogstring_05C4CD )
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #21, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]

  loc_05C4A9:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05C4BD )
    COP [SetEntryHere]
    RTL 
} >
]

code_05C4B7 {
    COP [SetTilePos] ( #14, #1A )
    BRA loc_05C4A9
}

code_05C4BD {
    COP [BranchOnFlagByte] ( #68, #01, &code_05C4C8 )
    COP [PrintDialogString] ( &dialogstring_05C571 )
    RTL 
}

code_05C4C8 {
    COP [PrintDialogString] ( &dialogstring_05C597 )
    RTL 
}

dialogstring_05C4CD `[TPL:A][TPL:1]Kara: [N]Lilly?[N]Is it Lilly?! [FIN][TPL:2]Lilly: I was worried![N]It's been almost a month[N]since we separated![FIN]I've been working and[N]living in this hotel.[FIN][TPL:A][TPL:2]Lance is in the room[N]on the right,[N]go in there...[PAL:0][END]`

dialogstring_05C571 `[TPL:A][TPL:1]Kara: [N]I am glad everyone [N]is safe, but...[PAL:0][END]`

dialogstring_05C597 `[TPL:A][TPL:1]Kara: What's wrong? [N]You're crying.[PAL:0][END]`