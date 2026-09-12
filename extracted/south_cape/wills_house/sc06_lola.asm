?INCLUDE 'f_inventory_full'

!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

sc06_lola [
  actor-def < #0B, #00, #10, {

  code_049865:
    COP [BranchIfFlagByte] ( #21, #01, &code_0499B9 )
    COP [BranchIfFlagByte] ( #1C, #01, &code_049968 )
    COP [BranchIfFlagByte] ( #3E, #01, &code_04995B )
    COP [BranchIfFlagByte] ( #1B, #01, &code_049934 )
    COP [BranchIfFlagByte] ( #16, #01, &code_04988C )
    COP [SetOnInteract] ( &code_0499BB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04988C {
    COP [SetTilePos] ( #07, #09 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0499C0 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #0D, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_049A3F )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [WaitByte] ( #0B )
    COP [StageSpriteLoop] ( #0D, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [SetOnInteract] ( #$0000 )
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$0800
    TSB $10
    COP [WaitByte] ( #3F )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [SetTilePos] ( #03, #19 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #1B, #01 )
    LDA #$1000
    TSB $12
    COP [StageSpriteLoopMoveX] ( #11, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #02, #11 )
    COP [AnimLoop]
}

code_049934 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SetTilePos] ( #0C, #1B )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0499C5 )
    COP [ExitIfFlagByte] ( #0B, #01 )
    COP [PrintDialogString] ( &dialogstring_049B82 )
    COP [SetFlagByte] ( #3E )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_049954:
    COP [SetOnInteract] ( &code_0499D3 )
    COP [SetEntryContinue]
    RTL 
}

code_04995B {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SetTilePos] ( #0C, #1B )
    COP [SolidHighHere]
    BRA loc_049954
}

code_049968 {
    COP [SetTilePos] ( #0C, #1B )
    COP [SetOnInteract] ( &code_0499D8 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #35, #01, &code_0499B6 )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #09, &code_049985 )
    RTL 
}

code_049985 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #35 )
    COP [StartMusic] ( #19 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_049D29 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_0499AA
    RTL 

  loc_0499AA:
    COP [StartMusic] ( #1C )
    COP [WaitByte] ( #59 )
    LDA #$FFF0
    TRB $joypadMaskStd
}

code_0499B6 {
    COP [SetEntryContinue]
    RTL 
}

code_0499B9 {
    COP [Die]
}

code_0499BB {
    COP [PrintDialogString] ( &dialogstring_0499F1 )
    RTL 
}

code_0499C0 {
    COP [PrintDialogString] ( &dialogstring_049ABB )
    RTL 
}

code_0499C5 {
    COP [PrintDialogString] ( &dialogstring_049B18 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #0A )
    RTL 
}

code_0499D3 {
    COP [PrintDialogString] ( &dialogstring_049B82+M )
    RTL 
}

code_0499D8 {
    COP [BranchIfFlagByte] ( #35, #01, &code_0499E8 )
    COP [PrintDialogString] ( &dialogstring_049BE5 )
    COP [GiveItem] ( #09, &code_0499ED )
    RTL 
}

code_0499E8 {
    COP [PrintDialogString] ( &dialogstring_049D94 )
    RTL 
}

code_0499ED {
    JML $@f_inventory_full.InventoryFullMessage
}

dialogstring_0499F1 `[DEF][TPL:3]Lola: Welcome home,[N]Will. Dinner isn't ready[N]yet. Go outside and[N]play for a while.[PAL:0][END]`

dialogstring_049A3F `[TPL:A][TPL:3]Lola:  Ah ha ha.[N]Oh, you!! Bringing up[N]a thing like that![FIN]Will, you shouldn't be[N]surprised to hear that.[FIN]The girl who was singing[N]with me a minute ago...[PAL:0][END]`

dialogstring_049ABB `[TPL:B][TPL:3]Lola: Welcome home,[N]Will. When I sing opera,[N]I lose track of[N]the time...[FIN]Dinner's not ready yet.[PAL:0][END]`

dialogstring_049B18 `[TPL:A][TPL:3]Lola: Edward Castle...[N]There's a big viaduct[N]under the castle.[FIN]Your grandfather designed[N]it.[FIN][TPL:0]Will: [N]What! Really?[PAL:0][END]`

dialogstring_049B82 `[PAU:40][::][TPL:A][TPL:3]Lola:[N]Enough serious talk.[N]Let's eat dinner.[FIN]I've made a delicious[N]pie. Let's sit at the[N]table upstairs.[PAL:0][END]`

dialogstring_049BE5 `[TPL:B][TPL:3]Lola: [N]Good morning, Will.[N]A letter has come for[N]you from King Edward.[FIN][PAL:0][DLG:3,6][SIZ:D,4]This is what is written[N]in the letter.[FIN][TPL:B][TPL:4]Bring the Crystal Ring[N]from Olman's things[N]to Edward Castle.[N]           King Edward[FIN][TPL:3]Lola: I've been in a[N]bad mood ever since I[N]saw this letter.[FIN]Oh, Will. I'll teach[N]you a spell. When I'm[N]upset, humming this tune[N]makes me feel better.[FIN]Lola hummed a strange[N]melody.[PAL:0][END]`

dialogstring_049D29 `[TPL:A][TPL:0][SFX:0][DLY:5]That's pretty.[N][PAU:78][CLR]Even though Will had[N]never heard it before,[N]it seemed oddly familiar.[PAU:F0][CLR][PAL:0]You've learned[N]Lola's melody![PAU:FF][CLD]`

dialogstring_049D94 `[TPL:B][TPL:3]Lola:[N]Be careful.[PAL:0][END]`