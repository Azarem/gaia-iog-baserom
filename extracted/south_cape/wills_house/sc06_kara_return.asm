!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

sc06_kara_return [
  actor-def < #1B, #00, #10, {

  code_04A5B2:
    COP [BranchIfFlagByte] ( #26, #01, &code_04A693 )
    COP [BranchIfFlagByte] ( #25, #01, &code_04A695 )
    COP [BranchIfFlagByte] ( #21, #00, &code_04A734 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$0008
    STA $0014, Y
    COP [SpawnAfterFlags] ( @e_sc06_actor_04AF48, #$2000 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_04A746 )
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04A766 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04A7A8 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [SetTilePos] ( #03, #08 )
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1C, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #28 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_04A7E1 )
    COP [SetOnInteract] ( &code_04A736 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_04A945 )
    COP [ClearFlagByte] ( #02 )
    COP [SetFlagByte] ( #25 )
    COP [ClearFlagWord] ( #$0119 )
    COP [SetOnInteract] ( &code_04A73E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04A693 {
    COP [Die]
}

code_04A695 {
    COP [SetTilePos] ( #0C, #1B )
    COP [SetOnInteract] ( &code_04A73E )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04A9F8 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteMoveX] ( #20, #14 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04AA0D )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #20, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetFlagByte] ( #26 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04AA20 )
    COP [DialogueOptions] ( #02, #00, &code_list_04A6F7 )
}

code_list_04A6F7 [
  &code_04A703   ;00
  &code_04A6FD   ;01
  &code_04A703   ;02
]

code_04A6FD {
    COP [PrintDialogString] ( &dialogstring_04AA7D )
    BRA loc_04A707
}

code_04A703 {
    COP [PrintDialogString] ( &dialogstring_04AAAD )

  loc_04A707:
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$00D4, #$03A4, #00, #03 )
    COP [QueueMapChange] ( #15, #$02D8, #$0370, #00, #$4500 )
    COP [SetEntryContinue]
    RTL 
}

code_04A734 {
    COP [Die]
}

code_04A736 {
    COP [PrintDialogString] ( &dialogstring_04A81F )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_04A73E {
    COP [PrintDialogString] ( &dialogstring_04A9D7 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_04A746 `[TPL:A][TPL:0]Will: What![N]What's happened...[PAL:0][END]`

dialogstring_04A766 `[TPL:A][TPL:1]Kara: It's awful! Who[N]would do such a thing...[FIN][TPL:0]Will: [N]My Grandparents?![PAL:0][END]`

dialogstring_04A7A8 `[DLG:3,6][SIZ:D,3][TPL:1]Kara: [N]Grandpa Bill![FIN][TPL:0]Will: [N]Grandma Lola![FIN][TPL:1]Kara: [N]I'll look upstairs![PAL:0][END]`

dialogstring_04A7E1 `[TPL:E][TPL:1]Kara: Ooooh!!! Will!! [N]Come here! Quick![N]It's terrible, terrible![PAL:0][END]`

dialogstring_04A81F `[TPL:E][TPL:0]Will: What happened?![FIN][TPL:1]Kara: Look at the wall![FIN]This mark, a jackal...[N]The Jackal's here![FIN][TPL:0]Will: [N]Jackal...?[FIN][TPL:1]Kara: He's the[N]hunter hired by[N]my mother!![FIN]An evil man who will[N]stop at nothing![FIN]Once he starts after you,[N]there's no stopping him.[FIN]He has no regard[N]for human life![FIN][TPL:0]Will: My Grandpa[N]and Grandma....[PAL:0][END]`

dialogstring_04A945 `[TPL:E][TPL:1]Kara: [N]Who are you?![FIN][TPL:2]Lilly: [N]I'm Will's friend.[FIN][TPL:0]Will: Lilly, do you know[N]anything about this?[FIN][TPL:2]Lilly: It's OK.[N]Your Grandpa and[N]Grandma are safe.[FIN]They're in my village.[FIN][TPL:1]Kara: Your village?[PAL:0][END]`

dialogstring_04A9D7 `[TPL:E][TPL:1]I think something good[N]is going to happen.[PAL:0][END]`

dialogstring_04A9F8 `[TPL:A][TPL:1]Kara: [N]You're nitpicking.[END]`

dialogstring_04AA0D `[TPL:A][TPL:1]Kara: [N]Crazy girl![END]`

dialogstring_04AA20 `[TPL:B][TPL:1]Kara: Hey, Will, [N]aren't you my friend,[N]too!?[FIN][PAL:0] Yes, of course.[N] I, umm,  I'm going [N] to the village.`

dialogstring_04AA7D `[CLR][TPL:1]Kara: [N]I'm glad, Will. Let's[N]go hand in hand.[FIN][JMP:&sc06_kara_return.dialogstring_04AAAD+M]`

dialogstring_04AAAD `[TPL:2][CLR]Lilly:[N]I'm going with you.[N]Let's go.[FIN][::][SFX:10][PAL:0]Together,[N]the three set off for[N]Lilly's village.[END]`
---------------------------------------------

e_sc06_actor_04AF48 {
    COP [SolidHighAbs] ( #05, #1D )
    COP [SolidHighAbs] ( #06, #1D )

  code_04AF50:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #25, #01, &code_04AF75 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #1C, #07, #1D, &code_04AF61 )
    RTL 
}

code_04AF61 {
    COP [BranchIfButton] ( #$0400, &code_04AF6C )
    COP [SetEntryExitNow] ( @code_04AF50 )
}

code_04AF6C {
    COP [PrintDialogString] ( &dialogstring_04AF7F )
    COP [SetEntryExitNow] ( @code_04AF50 )
}

code_04AF75 {
    COP [ClearLowAbs] ( #05, #1D )
    COP [ClearLowAbs] ( #06, #1D )
    COP [Die]
}

dialogstring_04AF7F `[TPL:A][TPL:0]Will: [N](I suspect there's a[N] clue in the house...)[PAL:0][END]`