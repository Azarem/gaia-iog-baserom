!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

nvAE_kara [
  actor-def < #0B, #00, #30, {

  code_089521:
    COP [BranchIfFlagByte] ( #B6, #01, &code_08956C )
    COP [BranchIfFlagByte] ( #CF, #01, &code_08956E )
    COP [ExitIfFlagByte] ( #BF, #01 )
    COP [ExitIfFlagByte] ( #C0, #01 )
    COP [ExitIfFlagByte] ( #C1, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0895C9 )
    COP [SetFlagByte] ( #CF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_089585 )
    COP [SetEntryContinue]
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
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_089585 )
    COP [SetEntryContinue]
    RTL 
}

code_089585 {
    COP [PrintWideString] ( &widestring_08963C )
    COP [DialogueOptions] ( #02, #02, &code_list_08958F )
}

code_list_08958F [
  &code_089595   ;00
  &code_08959A   ;01
  &code_089595   ;02
]

code_089595 {
    COP [PrintWideString] ( &widestring_0896F9 )
    RTL 
}

code_08959A {
    COP [PrintWideString] ( &widestring_08971E )
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

widestring_0895C9 `[DEF][TPL:1]Kara:[N]I used sign language to[N]talk to the villagers.[FIN]The animals have[N]returned to the forest.[N]They no longer prey[N]on each other.[PAL:0][END]`

widestring_08963C `[DEF][TPL:1]Labor traders came [N]from a town in [N]the northwest. They [N]took many villagers. [FIN]I can't believe they [N]would take advantage [N]of people stricken [N]with famine! [FIN]Travel to the labor [N]trader's village? [N] Yes, let's go! [N] Wait a while. `

widestring_0896F9 `[CLR][TPL:1]Then make preparations[N]and come back.[PAL:0][END]`

widestring_08971E `[CLR][TPL:1]Let's get going![PAL:0][END]`