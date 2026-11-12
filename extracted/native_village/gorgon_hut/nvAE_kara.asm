; Kara in the Gorgon Hut (scene $AE). $B6 set: dies. $CF set: stands with the travel handler. Otherwise she waits for $BF, $C0 and $C1 (the three petals placed by UseItem_GorgonFlower), locks the player ($CFFC), waits 60 ticks (WaitByte #3B), clears bit $2000 of her flags $10, walks up three rows, becomes solid, prints 'I used sign language to talk to the villagers. The animals have returned to the forest. They no longer prey on each other.', sets $CF, unlocks and installs the handler. With $CF set at load she stands at tile (07,0A) with the same handler.
; 
; Handler: 'Labor traders came from a town in the northwest. They took many villagers... Travel to the labor trader's village?' Yes: 'Let's get going!', stores $0D60 = 0, $0D62 = 1 and $0D64 = 4, stages a world-map move and queues scene $C4 at (0078,00A0). No: 'Then make preparations and come back.'.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

nvAE_kara [
  actor-def < #0B, #00, #30, {

  code_089521:
    COP [BranchOnFlagByte] ( #B6, #01, &code_08956C )
    COP [BranchOnFlagByte] ( #CF, #01, &code_08956E )
    COP [WaitOnFlagByte] ( #BF, #01 )
    COP [WaitOnFlagByte] ( #C0, #01 )
    COP [WaitOnFlagByte] ( #C1, #01 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_0895C9 )
    COP [SetFlagByte] ( #CF )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [SetInteractHandler] ( &code_089585 )
    COP [SetEntryHere]
    RTL 
} >
]

code_08956C {
    COP [Die]
}

code_08956E {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #07, #0A )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_089585 )
    COP [SetEntryHere]
    RTL 
}

code_089585 {
    COP [PrintDialogString] ( &dialogstring_08963C )
    COP [DialogueOptions] ( #02, #02, &code_list_08958F )
}

code_list_08958F [
  &code_089595   ;00
  &code_08959A   ;01
  &code_089595   ;02
]

code_089595 {
    COP [PrintDialogString] ( &dialogstring_0896F9 )
    RTL 
}

code_08959A {
    COP [PrintDialogString] ( &dialogstring_08971E )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0004
    STA $0D64
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0124, #$01A4, #00, #1D )
    COP [QueueMapChange] ( #C4, #$0078, #$00A0, #00, #$1100 )
    RTL 
}

dialogstring_0895C9 `[DEF][TPL:1]Kara:[N]I used sign language to[N]talk to the villagers.[FIN]The animals have[N]returned to the forest.[N]They no longer prey[N]on each other.[PAL:0][END]`

dialogstring_08963C `[DEF][TPL:1]Labor traders came [N]from a town in [N]the northwest. They [N]took many villagers. [FIN]I can't believe they [N]would take advantage [N]of people stricken [N]with famine! [FIN]Travel to the labor [N]trader's village? [N] Yes, let's go! [N] Wait a while. `

dialogstring_0896F9 `[CLR][TPL:1]Then make preparations[N]and come back.[PAL:0][END]`

dialogstring_08971E `[CLR][TPL:1]Let's get going![PAL:0][END]`