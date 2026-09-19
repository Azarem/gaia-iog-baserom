; Lance in the coastal cave -- card game and flute tutorial.
; 
; Multi-state dialog covering the card game with Seth, the flute
; tutorial (Melody of Wind), and the cave statue puzzle. Key
; gameplay tutorial sequence.
---------------------------------------------

?INCLUDE 'sc02_card'

!joypadMaskStd                  065A

---------------------------------------------

sc02_lance [
  actor-def < #32, #00, #10, {

  code_04B065:
    COP [BranchIfFlagByte] ( #4C, #01, &code_04B168 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #20, #01, &code_04B15C )
    COP [BranchIfFlagByte] ( #16, #01, &code_04B152 )
    COP [SetOnInteract] ( &code_04B18E )
    LDA #$0800
    TSB $10

  code_04B087:
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #00, &code_04B087 )
    LDA #$0800
    TRB $10
    LDA #$0200
    TRB $12
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [SetOnInteract] ( &code_04B196 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetOnInteract] ( &code_04B19B )
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [CallScript] ( &code_04B16A )
    COP [SetOnInteract] ( &code_04B1BB )
    COP [ExitIfFlagByte] ( #07, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #06, #03, #11 )
    COP [AnimLoop]
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #03, #1E )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @sc02_card.code_04AFBF, #$0000, #$FFF0, #$1001 )
    COP [PlaySoundCh2] ( #2C )
    COP [LoopNext]
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04B2F0 )
    COP [SetOnInteract] ( &code_04B1C3 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [PrintDialogString] ( &dialogstring_04B328 )
    COP [CallScript] ( &code_04B16A )
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04B344 )
    COP [StageSpriteLoop] ( #05, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04B386 )
    COP [SetFlagByte] ( #0B )
    COP [ClearFlagByte] ( #04 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04B152 {
    LDA #$0800
    TSB $10
    LDA #$0200
    TSB $12
}

code_04B15C {
    COP [SetOnInteract] ( &code_04B1A0 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    RTL 
}

code_04B168 {
    COP [Die]
}

code_04B16A {
    COP [StageSpriteLoopMoveY] ( #05, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04B18E {
    COP [SetFlagByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_04B1CB )
    RTL 
}

code_04B196 {
    COP [PrintDialogString] ( &dialogstring_04B210 )
    RTL 
}

code_04B19B {
    COP [PrintDialogString] ( &dialogstring_04B23F )
    RTL 
}

code_04B1A0 {
    COP [BranchIfFlagByte] ( #25, #01, &code_04B1B6 )
    COP [BranchIfFlagByte] ( #1C, #01, &code_04B1B1 )
    COP [PrintDialogString] ( &dialogstring_04B3AD )
    RTL 
}

code_04B1B1 {
    COP [PrintDialogString] ( &dialogstring_04B3DF )
    RTL 
}

code_04B1B6 {
    COP [PrintDialogString] ( &dialogstring_04B40D )
    RTL 
}

code_04B1BB {
    COP [PrintDialogString] ( &dialogstring_04B27E )
    COP [SetFlagByte] ( #07 )
    RTL 
}

code_04B1C3 {
    COP [PrintDialogString] ( &dialogstring_04B2F0 )
    COP [SetFlagByte] ( #07 )
    RTL 
}

dialogstring_04B1CB `[TPL:A][TPL:4]Lance: [N]What is it, Will?[N]It's late.[FIN]I'm playing cards[N]with Seth.[N]Wait a minute.[PAL:0][END]`

dialogstring_04B210 `[TPL:A][TPL:4]Lance: [N]Will, get over here and[N]sit next to Erik.[PAL:0][END]`

dialogstring_04B23F `[TPL:A][TPL:4]Lance: Draw it to you[N]by spinning the Flute[N]around like a baton.[PAL:0][END]`

dialogstring_04B27E `[TPL:B][TPL:4]Lance: [N]Next. Pick a[N]card, any card.[FIN]I'll put four cards face[N]down. Pick the one[N]you think is the[N]Ace of Diamonds.[PAL:0][END]`

dialogstring_04B2F0 `[TPL:A][TPL:4]Lance: Pick the one[N]you think is the[N]Ace of Diamonds.[PAL:0][END]`

dialogstring_04B328 `[TPL:A][TPL:4]Lance: [N]Ahhh! Right!![PAL:0][END]`

dialogstring_04B344 `[TPL:A][TPL:4]Lance: What Seth says[N]is too complicated for[N]me to understand.[PAL:0][END]`

dialogstring_04B386 `[TPL:A][TPL:4]Lance: [N]Seth. Let's play[N]one more game.[PAL:0][END]`

dialogstring_04B3AD `[TPL:A][TPL:4]Lance: One more[N]game with Seth[N]and I'm going home.[PAL:0][END]`

dialogstring_04B3DF `[TPL:A][TPL:4]Lance: It's a day off[N]from school.[N]Let's have some fun.[PAL:0][END]`

dialogstring_04B40D `[TPL:A][TPL:4]Lance: What happened,[N]Will?[N]You look so gloomy.[FIN]Something you can't[N]tell us about?[PAL:0][END]`