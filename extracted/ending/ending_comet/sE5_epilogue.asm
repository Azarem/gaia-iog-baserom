?INCLUDE 'actor_pool'
?INCLUDE 'sE6_gaia'
?INCLUDE 'table_0EDA00'
?INCLUDE 'table_0EE000'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!cgramPalette                   7F0A00

---------------------------------------------

sE5_epilogue [
  actor-def < #1B, #00, #10, {

  code_0BD309:
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$4001
    TSB $displayModeFlags
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker )
    LDA #$1062
    STA $cgramPalette
    COP [BranchIfFlagByte] ( #DB, #01, &code_0BD374 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_0BD558 )
    COP [SpawnAfterAbsFlags] ( @code_0BD4DE, #$0088, #$0080, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0BD5A0 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0BD70E )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @code_0BD539, #$00A0, #$FFF0, #$1800 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [PrintDialogString] ( &dialogstring_0BD740 )
    COP [SetFlagByte] ( #DB )
    LDA #$0202
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #90, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BD374 {
    COP [SpawnAfterAbsFlags] ( @code_0BD4F7, #$0078, #$0080, #$1800 )
    COP [SpawnAfterAbsFlags] ( @code_0BD4F7, #$0098, #$0080, #$1800 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_0BD9FA )
    COP [SetFlagByte] ( #03 )
    COP [FadeThenStartMusic] ( #13 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [WaitByte] ( #EF )
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDY $playerActor
    SEP #$20
    LDA #$^loc_0BD494
    STA $0002, Y
    REP #$20
    LDA #$&loc_0BD494
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags
    COP [WaitByte] ( #4F )
    COP [PrintDialogString] ( &dialogstring_0BDC95 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #04, #00 )
    COP [PrintDialogString] ( &dialogstring_0BDD34 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0BDDE5 )
    COP [StageSpriteMoveX] ( #21, #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_0BDE02 )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F5F9
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F5F9
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [WaitByte] ( #77 )
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #1F, #01 )
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0BD437
    RTL 

  loc_0BD437:
    LDY $playerActor
    LDA #$*code_0BD4B7
    STA $0002, Y
    LDA #$&code_0BD4B7
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0BD45D
    RTL 

  loc_0BD45D:
    COP [WaitByte] ( #77 )
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetTilePos] ( #08, #01 )
    COP [StageSpriteLoopMoveY] ( #02, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #B3 )
    LDA #$0808
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #89, #$0000, #$0000, #00, #$1100 )
    COP [Die]

  loc_0BD494:
    COP [StagePlayerSprite] ( #02 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StagePlayerMoveX] ( #0A, #12 )
    COP [AnimOnce]
    COP [StagePlayerSprite] ( #02 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StagePlayerSprite] ( #01 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BD4B7 {
    LDA #$0008
    TRB $10
    COP [StagePlayerSprite] ( #1C )
    COP [AnimOnce]
    COP [ToggleVFlip]

  loc_0BD4C3:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0BD4C3
    LDA #$0800
    TRB $playerFlags
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

code_0BD4DE {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
}

code_0BD4F7 {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_0BD51F )
    COP [BranchIfFlagByte] ( #02, #01, &code_0BD512 )
    RTL 
}

code_0BD512 {
    COP [StageSpriteMoveX] ( #04, #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_0BD51F {
    COP [StageSpriteLoopMoveY] ( #04, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #04, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #04, #08, #02 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #03 )
    COP [Die]
}

code_0BD539 {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [StageSpriteLoopMoveY] ( #04, #06, #01 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_0BD51F )
    RTL 
}

dialogstring_0BD558 `[DLG:3,4][SIZ:D,3][SFX:0][TPL:13][SFX:0][DLY:6]Kara: [N]What's happened to [N]the comet...? [PAU:78][CLR]That glowing[N]green planet?[PAU:B4][CLD]`

dialogstring_0BD5A0 `[DLG:3,4][SIZ:D,3][TPL:15][SFX:0][DLY:6]Will's father: [N]The comet's power [N]has disappeared. [PAU:78][CLR]The evil star has flown[N]off to the other side[N]of the universe...[PAU:B4][CLR][TPL:15][SFX:0][DLY:6]Will. [N][PAU:28]Do you know what[N]planet that is, glowing[N]there in the darkness?[PAU:B4][CLR][TPL:12][SFX:0]Will: [N]Our Earth...?[PAU:78][CLR][TPL:15][SFX:0]Will's father: [N]That's right. Our Earth.[N][PAU:78][CLR]Doesn't it look like a[N]desert oasis?[PAU:B4][CLR][TPL:13][SFX:0]Kara: [N]It's never seemed [N]so beautiful.[PAU:B4][CLR]But it looks lonely[N]shining in the dark...[PAU:B4][CLD]`

dialogstring_0BD70E `[DLG:3,4][SIZ:D,2][SFX:0][DLY:6][TPL:14][SFX:0]Strange Voice: Yes.[N]The world is awakened.[PAU:B4][CLD]`

dialogstring_0BD740 `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][CLR][TPL:12][SFX:0]Will: [N]Mother?![PAU:B4][CLR][TPL:14][SFX:0]Will's mother:[N]The Earth.[N][PAU:3C]A mother with millions [N]of children.[PAU:B4][CLR]I'm sure you think [N]about us sometimes, [N]and Kara often [N]thinks about her parents.[PAU:B4][CLR]The Earth is the same[N]way. She gets lonely if[N]her children forget[N]about her.[PAU:B4][CLR][TPL:15][SFX:0]Will's father: How is it,[N]you two? [N][PAU:3C]Looking at the world[N]you live in from[N]the outside?[PAU:B4][CLR][TPL:13][SFX:0]Kara: [N]It's as if we'd [N]become spirits...[PAU:B4][CLR][TPL:12][SFX:0]Will: I want to show [N]all of our group...[PAU:78][CLR]No, I want to show[N]everyone in the world...[PAU:B4][CLR][TPL:15][SFX:0]Will's father: Someday [N]people will build ships [N]to travel the universe.[PAU:B4][CLR]Then they will see[N]this green Earth with[N]their own eyes.[PAU:B4][CLR]See how lonely the[N]Earth looks, just like[N]the two of you.[PAU:B4][CLR]Will's father: Look [N]carefully at your [N]map of the world.[PAU:B4][CLR][TPL:12][SFX:0]Will:[N]Ah! The map has started[N]to change![PAU:B4][CLD]`

dialogstring_0BD9FA `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][CLR][TPL:12][SFX:0]Will: [N]Why do you two [N]know the future?[PAU:B4][CLR][TPL:15][SFX:0]Will's father: [N]When I lost my body, I [N]started seeing everything.[PAU:B4][CLR]The past. The future. [N]Humanity's progress.[PAU:B4][CLR]Maybe people would[N]call this kind of body[N]a spirit.[PAU:B4][CLR][TPL:14][SFX:0]Will's mother:[N]Now you and Kara can [N]become ordinary [N]children again.[PAU:B4][CLR]Don't be afraid.[PAU:B4][CLR][TPL:13][SFX:0]Kara: When we [N]return to Earth, will [N]we be separated?[PAU:B4][CLR][TPL:15][SFX:0]Will's father: Yes... [N][PAU:28]The world is changing. [N]Humanity and history, [N]have started down a [N]new path.[PAU:B4][CLR]You two thought [N]nothing of it when you [N]met each other in [N]South Cape. [PAU:B4][CLR]But when the Earth[N]needed the Light and[N]Dark Knights, you[N]met again unexpectedly.[PAU:B4][CLR]Let's look at the world[N]before the power of the[N]comet is extinguished.[PAU:B4][CLR][TPL:14][SFX:0]Will's mother: [N]We hope you two [N]have a bright future...[PAU:B4][CLD]`

dialogstring_0BDC95 `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][TPL:13][SFX:0]Kara: Will... [N][PAU:28]Come here....[N][PAU:50]Show me your face...[PAU:B4][CLR]I want to burn you[N]into my memory.[PAU:B4][CLR]Your eyes [PAU:1E]Your nose [N][PAU:1E]Your mouth [PAU:28]Your hair [N][PAU:1E]Your voice [N][PAU:28]The warmth of[N]your hand....[PAU:B4][CLD]`

dialogstring_0BDD34 `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][TPL:12][SFX:0]Will: Don't worry. [N][PAU:3C]I will search you out.[PAU:B4][CLR]No matter how long[N]it takes.[N][PAU:3C]Hundreds of years...[N][PAU:1E]Thousands of years...[N][PAU:1E]I will come to you.[PAU:B4][CLR]So take care...[N][PAU:5A]Close your eyes...[PAU:78][CLD]`

dialogstring_0BDDE5 `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][TPL:13][SFX:0]Kara: [N]Will....[PAU:78][CLD]`

dialogstring_0BDE02 `[DLG:3,4][SIZ:D,3][SFX:0][DLY:6][TPL:12][SFX:0]Will: [N]Let's go. [N]To Earth....[PAU:B4][CLR][TPL:13][SFX:0]Kara: [N]Mmmm....[PAU:B4][CLD]`