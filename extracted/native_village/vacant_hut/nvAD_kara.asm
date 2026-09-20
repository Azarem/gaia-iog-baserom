; Kara in the vacant hut — suggests resting.
; 
; Multi-dialog NPC. "No one here... The village looks abandoned.
; Erik: That's good. We can rest." Later: "Let's rest today."
; Party decision to recuperate in the empty hut.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

nvAD_kara [
  actor-def < #0B, #00, #10, {

  code_088ACA:
    COP [BranchIfFlagByte] ( #B2, #01, &code_088B18 )
    COP [BranchIfFlagByte] ( #AE, #01, &code_088B06 )
    COP [BranchIfFlagByte] ( #AD, #00, &code_088B18 )
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$0008
    STA $0014, Y
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_088B32 )
    LDA #$CFF0
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
    COP [SetOnInteract] ( &code_088B1A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
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