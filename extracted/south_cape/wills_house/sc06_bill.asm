; Grandpa Bill NPC in Will's house -- multi-phase story actor.
; 
; Complex flag-gated dialog covering: initial homecoming, Lola's
; opera singing, the soldier/Kara arrest event, the kidnapping,
; and post-rescue states. One of the most story-critical NPCs
; in Will's house with screen fade and music change sequences.
---------------------------------------------

!gfxCacheIdxA                   0648
!joypadMaskStd                  065A
!joypadInject                   09AC
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

sc06_bill [
  actor-def < #02, #00, #10, {

  code_04927C:
    COP [BranchIfFlagByte] ( #21, #01, &code_0493EE )
    COP [BranchIfFlagByte] ( #1C, #01, &code_0493E1 )
    COP [BranchIfFlagByte] ( #3E, #01, &code_0493D9 )
    COP [BranchIfFlagByte] ( #1B, #01, &code_049349 )
    COP [BranchIfFlagByte] ( #16, #01, &code_0492A3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0493F0 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0492A3 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0493F5 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_04953E )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [WaitByte] ( #59 )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoop] ( #05, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #04, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04956D )
    COP [SetOnInteract] ( #$0000 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #06 )
    LDA #$0800
    TSB $10
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [SetTilePos] ( #03, #19 )
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #1B, #01 )
    LDA #$1000
    TSB $12
    COP [FadeThenStartMusic] ( #1C )
    COP [StageSpriteLoopMoveX] ( #09, #05, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_049349 {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_049413 )
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [PrintDialogString] ( &dialogstring_0495C9 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_0495EB )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #0B )

  loc_04937D:
    COP [SetOnInteract] ( &code_049418 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #03, #17, #04, #19, &code_04938C )
    RTL 
}

code_04938C {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0800
    TSB $10
    COP [LoopInit] ( #09 )
    LDA #$0800
    STA $joypadInject
    COP [LoopNext]
    LDA #$000F
    STA $orbitAngle, X

  code_0493A9:
    LDA $orbitAngle, X
    DEC 
    BMI loc_0493C2
    STA $orbitAngle, X
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [SetEntryDelayExit] ( @code_0493A9, #$0003 )

  loc_0493C2:
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #06, #$0000, #$0200, #00, #$3120 )
    LDA #$CFF0
    TRB $joypadMaskStd
    RTL 
}

code_0493D9 {
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    BRA loc_04937D
}

code_0493E1 {
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_049403 )
    COP [SetEntryContinue]
    RTL 
}

code_0493EE {
    COP [Die]
}

code_0493F0 {
    COP [PrintDialogString] ( &dialogstring_04941D )
    RTL 
}

code_0493F5 {
    COP [PrintDialogString] ( &dialogstring_0494B1 )
    COP [SetFlagByte] ( #03 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

code_049403 {
    COP [BranchIfFlagByte] ( #35, #01, &code_04940E )
    COP [PrintDialogString] ( &dialogstring_049828 )
    RTL 
}

code_04940E {
    COP [PrintDialogString] ( &dialogstring_04977F )
    RTL 
}

code_049413 {
    COP [PrintDialogString] ( &dialogstring_04958A )
    RTL 
}

code_049418 {
    COP [PrintDialogString] ( &dialogstring_049685 )
    RTL 
}

dialogstring_04941D `[TPL:B][TPL:4]Bill: Coming home[N]at this hour probably[N]means you had to stay[N]after school again.[FIN]Ha ha. Excellent! Even[N]if a boy can't study,[N]he should show a[N]little initiative.[PAL:0][END]`

dialogstring_0494B1 `[TPL:B][TPL:4]Bill: [N]Oh, my! I haven't sung [N]like this in a long time.[FIN]Your grandmother Lola[N]used to be a singer.[FIN]I fell in love with her[N]voice. That's why I[N]married her.[PAL:0][END]`

dialogstring_04953E `[TPL:8][TPL:1][DLY:0]No-o-o-o-o!!![FIN][PAL:0][SFX:10]A scream from downstairs![END]`

dialogstring_04956D `[TPL:9][TPL:4]Bill: It's that[N]girl screaming!![PAL:0][END]`

dialogstring_04958A `[TPL:A][TPL:4]Bill: So, that girl[N]likes to play practical[N]jokes. Heh heh heh.[PAL:0][END]`

dialogstring_0495C9 `[PAU:1E][TPL:A][TPL:4]Bill: I used to be[N]an architect.[PAL:0][END]`

dialogstring_0495EB `[TPL:B][TPL:4]There's a prison[N]under the castle.[FIN]It's built like a maze[N]to keep the prisoners[N]from escaping.[FIN]I feel bad that I built[N]a prison where people[N]disappear and are never[N]heard from again.[PAL:0][END]`

dialogstring_049685 `[TPL:B][TPL:4]Bill: Will, do you think[N]Lola's meals have been a[N]little strange lately?[FIN]Last night, licorice and[N]rice. Before that, mouse[N]fritters.[N]I can't stand it anymore![FIN]Sometimes old people,[N]if they're surrounded by[N]problems, get a little[N]forgetful. [FIN]Maybe there's something[N]bothering her that she[N]can't talk about...[PAL:0][END]`

dialogstring_04977F `[TPL:B][TPL:4]Bill:[N]A crystal ring...?[N]Never heard of it.[FIN]There was nothing[N]like that in the luggage[N]your father, Olman,[N]left behind.[FIN]Maybe we could go to[N]Edward Castle. We could[N]see the princess.[N]Heh heh.[PAL:0][END]`

dialogstring_049828 `[TPL:A][TPL:4]Bill: I had more snail[N]pie for breakfast.[N]I left you a slice.[PAL:0][END]`