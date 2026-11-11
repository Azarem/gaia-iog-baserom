; Kara in the vacant hut (scene $AD). $B2 set or $AD clear: dies. $AE clear (first visit): adds 8 to the player's actor word $14, locks the player, prints 'No one here... The village looks abandoned.' / Erik: 'That's good. We can rest if we want.', unlocks, sets $AE, walks and stops at tile (07,08). $AE set: stands at tile (07,08), solid, with the handler 'Let's rest today.': the handler sets $B0 first and then queues scene $AC at (00B0,00A0), where nvAC_kara plays the sleep scene.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

nvAD_kara [
  actor-def < #0B, #00, #10, {

  code_088ACA:
    COP [BranchOnFlagByte] ( #B2, #01, &code_088B18 )
    COP [BranchOnFlagByte] ( #AE, #01, &code_088B06 )
    COP [BranchOnFlagByte] ( #AD, #00, &code_088B18 )
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$0008
    STA $0014, Y
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_088B32 )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #AE )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
} >
]

code_088B06 {
    COP [SetTilePos] ( #07, #08 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_088B1A )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_088B18 {
    COP [Die]
}

code_088B1A {
    COP [SetFlagByte] ( #B0 )
    COP [PrintDialogString] ( &dialogstring_088B8B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #AC, #$00B0, #$00A0, #00, #$2200 )
    RTL 
}

dialogstring_088B32 `[TPL:A][TPL:1]Kara: [N]No one here... The [N]village looks abandoned. [FIN][TPL:3]Erik: [N]That's good. We can [N]rest if we want.[PAL:0][END]`

dialogstring_088B8B `[TPL:A][TPL:1]Kara: [N]Let's rest today.[PAL:0][END]`