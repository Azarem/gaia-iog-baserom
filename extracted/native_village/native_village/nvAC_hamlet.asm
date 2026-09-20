; Hamlet the pig in the Native Village — emotional subplot.
; 
; Major subplot NPC (~162 lines). Erik: "Poor Hamlet... To eat
; or not to eat...?" Kara: "Hamlet...! (Sob)" The party faces
; the moral dilemma of whether to eat their pet pig to
; survive. One of the game's most memorable emotional scenes.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!joypadMaskStd                  065A
!spritesetPtr                   7F0006

---------------------------------------------

nvAC_hamlet [
  actor-def < #14, #00, #10, {

  code_08865C:
    LDA #$0200
    TSB $12
    COP [BranchOnFlagByte] ( #B3, #01, &code_0886BD )
    COP [BranchOnFlagByte] ( #CF, #01, &code_0886BD )
    COP [BranchOnFlagByte] ( #B2, #01, &code_08873E )
    COP [BranchOnFlagByte] ( #AF, #01, &code_0886BF )
    COP [BranchOnFlagByte] ( #AD, #01, &code_0886BD )
    COP [BranchOnFlagByte] ( #AC, #01, &code_0886A5 )
    COP [WaitOnFlagByte] ( #AC, #01 )
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #18, #10, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #0B, #02 )
    COP [AnimLoop]
} >
]

code_0886A5 {
    COP [SetTilePos] ( #0B, #0F )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #AD, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #17, #07, #02 )
    COP [AnimLoop]
}

code_0886BD {
    COP [Die]
}

code_0886BF {
    COP [WriteApuIo0] ( #01 )
    LDA #$0800
    TSB $10
    COP [SetTilePos] ( #0B, #12 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoopMoveX] ( #18, #0A, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #02 )
    COP [WaitOnFlagByte] ( #02, #00 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #02, #01 )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$2121 )
    COP [StageSpriteLoop] ( #AB, #28 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #03 )
    COP [StageSpriteLoop] ( #AC, #3C )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #AD )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #03, #00 )
    LDA #$0800
    TRB $10
    COP [StartMusic] ( #11 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_08885C )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_088755, #$1002 )
    COP [SetInteractHandler] ( &code_088750 )
    COP [SetEntryHere]
    RTL 
}

code_08873E {
    COP [SetTilePos] ( #08, #13 )
    COP [StageSpriteFrame] ( #AD )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_088750 )
    COP [SetEntryHere]
    RTL 
}

code_088750 {
    COP [PrintDialogString] ( &dialogstring_0888AD )
    RTL 
}

code_088755 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$4000
    STA $spritesetPtr, X
    SEP #$20
    LDA #$7E
    STA $7F0008, X
    REP #$20
    COP [StageSpriteMoveY] ( #2A, #14 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #04 )
    COP [StageSpriteMoveY] ( #2A, #14 )
    COP [AnimOnce]
    COP [SpawnBeforeFlags] ( @code_0887BA, #$2000 )
    LDA #$0800
    TSB $10

  loc_08878F:
    COP [BranchOnFlagByte] ( #05, #01, &code_08879C )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    BRA loc_08878F
}

code_08879C {
    COP [StageSpriteMoveY] ( #2A, #14 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2A, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #2A, #08, #02 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #B2 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_0887BA {
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08890E )
    COP [SetFlagByte] ( #05 )
    COP [Die]
}
---------------------------------------------

dialogstring_08885C `[TPL:A][TPL:3]Erik: Poor Hamlet... [N]To eat or not to eat...?[FIN][TPL:1]Kara: [N]Hamlet...! [N](Sob).....[PAL:0][END]`

dialogstring_0888AD `[TPL:A][TPL:0]Sniff sniff.[FIN]I'll never hear that [N]snort again... [FIN]The air is filled with[N]the aroma of roasting[N]Hamlet.[PAL:0][END]`

dialogstring_08890E `[TPL:A][TPL:0]A familiar voice echoed[N]in their heads.[FIN][TPL:2][DLY:0]Listen, everyone. It was[N]Hamlet's wish to be [N]food for these people. [FIN]One baby pig could save[N]many villagers.[FIN][TPL:0]Will: [N]Mother...? [FIN][TPL:2]Will... and everyone [N]in this place... [FIN]Darkness is approaching[N]the world. [FIN]You must combine your [N]strength to save [N]the planet.[FIN]So, Will, find the [N]Mystic Statues and go[N]to the Tower of Babel...[PAL:0][END]`