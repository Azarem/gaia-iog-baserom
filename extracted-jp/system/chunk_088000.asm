?BANK 08

?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_068000'
?INCLUDE 'chunk_098000'
?INCLUDE 'chunk_0B8000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'scene_warps'
?INCLUDE 'table_0EE000'

!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!mapBoundsX                     0692
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!layerPriorityFlag              06EE
!musicParentActor               06F2
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!abilityBitmask                 0AA2
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132
!APUIO1                         2141
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

actor_def_088000 [
  actor-def < #00, #01, #10, {

  code_088003:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08801B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08801B {
    COP [PrintWideString] ( &widestring_088020 )
    RTL 
}

widestring_088020 `[DEF][TPL:0]まだ 風化していない···[N]最近 白骨化した死体のようだな.[PAL:0][END]`

actor_def_08804D [
  actor-def < #0C, #00, #10, {

  code_088050:
    LDA #$0220
    STA $cameraBoundsY
    COP [BranchIfFlagByte] ( #B6, #01, &code_0880CA )
    COP [BranchIfFlagByte] ( #CF, #01, &code_0880CA )
    COP [BranchIfFlagByte] ( #B2, #01, &code_0881B4 )
    COP [BranchIfFlagByte] ( #AF, #01, &code_088148 )
    COP [BranchIfFlagByte] ( #B0, #01, &code_0880CC )
    COP [BranchIfFlagByte] ( #AD, #01, &code_0880CA )
    COP [BranchIfFlagByte] ( #AC, #01, &code_0880AE )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0881D8 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #AC )
    COP [SetFlagByte] ( #01 )
    COP [StageSpriteLoopMoveXY] ( #10, #08, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #06, #02 )
    COP [AnimLoop]
} >
]

code_0880AE {
    COP [SetTilePos] ( #0B, #0E )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0881C6 )
    COP [ExitIfFlagByte] ( #AD, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
}

code_0880CA {
    COP [Die]
}

code_0880CC {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0882AC )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_0889D0, #$0158, #$0040, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_088A00, #$0018, #$00C0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_088A1F, #$00B8, #$0180, #$1000 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PrintWideString] ( &widestring_0882E0 )
    COP [LoopInit] ( #02 )
    COP [WaitByte] ( #27 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [LoopNext]
    COP [WaitByte] ( #27 )
    COP [LoopInit] ( #04 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [WaitByte] ( #18 )
    COP [LoopNext]
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #AC, #$0080, #$00F0, #03, #$2200 )
    COP [SetFlagByte] ( #AF )
    COP [SetEntryContinue]
    RTL 
}

code_088148 {
    COP [SpawnAfterAbsFlags] ( @code_08819B, #$0088, #$00FE, #$1002 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetTilePos] ( #06, #10 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_088367 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [PrintWideString] ( &widestring_08876A )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [PrintWideString] ( &widestring_0887B1 )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @code_0881A4, #$1002 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0881D3 )
    COP [SetEntryContinue]
    RTL 
}

code_08819B {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
}

code_0881A4 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [AddPosition] ( #00, #F6 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0881B4 {
    COP [SetTilePos] ( #12, #0C )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0881CE )
    COP [SetEntryContinue]
    RTL 
}

code_0881C6 {
    COP [PrintWideString] ( &widestring_088253 )
    COP [SetFlagByte] ( #AD )
    RTL 
}

code_0881CE {
    COP [PrintWideString] ( &widestring_088459 )
    RTL 
}

code_0881D3 {
    COP [PrintWideString] ( &widestring_0884AB )
    RTL 
}

widestring_0881D8 `[TPL:A][TPL:1]カレン:[N]熱带地方だけあって すごい[N]暑さよね···[FIN][TPL:3]エリック:[N]世界が ゆがんで見えるし 目も[N]かすんできちゃったよう···[FIN][TPL:0]テム: しかたないなあ.[N]今日は この村にとめてもらおうか.[PAL:0][END]`

widestring_088253 `[TPL:A][TPL:1]カレン: なんだか 不気味ね···[N]人っ子ー人いないし ガイコツが[N]転がっているし···[FIN]とりあえず 家の中へ 入って[N]みましょうか?[PAL:0][END]`

widestring_0882AC `[TPL:D][TPL:0]旅のつかれから ー行は 深い[N]ねむりに落ちた···[FIN]それから しばらくして···[PAL:0][END]`

widestring_0882E0 `[TPL:E][TPL:0][DLY:2]テム:[N]むにゃ··· ペギーかい···?[N]もう少し ねかせてくれないか··[FIN][TPL:1][DLY:1]カレン: ううん···[N]ちょっと テム···[N]変なとこ さわんないでよ···[FIN][CLD][PAU:3C][TPL:E][TPL:1][DLY:0]カレン: ハッ![N]だれっ? あなたたちっ?![PAL:0][END]`

widestring_088367 `[TPL:A][TPL:0][SFX:0]彼らは どうやら 人食い人種の[N]ようだった···[FIN][TPL:1][SFX:10]カレン: 見て. あの子供たち.[N]あんな ガリガリにやせちゃって··[FIN][TPL:0]テム: そうか···[N]花の都で ドレイの少年が[N]言ってたっけ.[FIN]こきょうでは[N]食料が 不足してるって···[FIN][TPL:1]カレン:[N]そのへんに 転がっていた骨は[N]食料になった人の亡きがらなのね.[FIN][TPL:3]エリック:[N]うわーん. やっぱり ぼくら[N]食べられちゃうんだあっ!![PAL:0][END]`

widestring_088459 `[TPL:E][TPL:1]カレン: 子供たちに[N]言葉を ーつ 教わっちゃった.[FIN]ラマポー っていうのが[N]この地域で こんにちはっていう[N]意味みたい.[PAL:0][END]`

widestring_0884AB `[TPL:E][TPL:1]カレン:[N]食べられるために 自分から[N]火に 飛びこむなんて···[FIN]ペギー···[N]なんて やさしい子なの···[PAL:0][END]`

actor_def_0884F2 [
  actor-def < #04, #00, #10, {

  code_0884F5:
    COP [BranchIfFlagByte] ( #B6, #01, &code_08854D )
    COP [BranchIfFlagByte] ( #CF, #01, &code_08854D )
    COP [BranchIfFlagByte] ( #B2, #01, &code_088571 )
    COP [BranchIfFlagByte] ( #AF, #01, &code_08854F )
    COP [BranchIfFlagByte] ( #AD, #01, &code_08854D )
    COP [BranchIfFlagByte] ( #AC, #01, &code_088535 )
    COP [ExitIfFlagByte] ( #AC, #01 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveXY] ( #08, #08, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #04, #02 )
    COP [AnimLoop]
} >
]

code_088535 {
    COP [SetTilePos] ( #0B, #11 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #AD, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #07, #05, #02 )
    COP [AnimLoop]
}

code_08854D {
    COP [Die]
}

code_08854F {
    COP [SetTilePos] ( #0A, #10 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @code_0881A4, #$1002 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_088583 )
    COP [SetEntryContinue]
    RTL 
}

code_088571 {
    COP [SetTilePos] ( #12, #0B )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088583 )
    COP [SetEntryContinue]
    RTL 
}

code_088583 {
    COP [PrintWideString] ( &widestring_088588 )
    RTL 
}

widestring_088588 `[TPL:E][TPL:3]エリック: 人食い人種って[N]人を見つけると 食べちゃう[N]おそろしい人たちかと 思ってた.[FIN]生きるためには 同じ種族でも[N]とも食いする··· 人間って[N]やっぱり 動物なんだなあ···[PAL:0][END]`

actor_def_0885FD [
  actor-def < #14, #00, #10, {

  code_088600:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #B6, #01, &code_088661 )
    COP [BranchIfFlagByte] ( #CF, #01, &code_088661 )
    COP [BranchIfFlagByte] ( #B2, #01, &code_0886E2 )
    COP [BranchIfFlagByte] ( #AF, #01, &code_088663 )
    COP [BranchIfFlagByte] ( #AD, #01, &code_088661 )
    COP [BranchIfFlagByte] ( #AC, #01, &code_088649 )
    COP [ExitIfFlagByte] ( #AC, #01 )
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

code_088649 {
    COP [SetTilePos] ( #0B, #0F )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #AD, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #17, #07, #02 )
    COP [AnimLoop]
}

code_088661 {
    COP [Die]
}

code_088663 {
    COP [WriteApuIo0] ( #01 )
    LDA #$0800
    TSB $10
    COP [SetTilePos] ( #0B, #12 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoopMoveX] ( #18, #0A, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
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
    COP [ExitIfFlagByte] ( #03, #00 )
    LDA #$0800
    TRB $10
    COP [StartMusic] ( #11 )
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_088802 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_0886F9, #$1002 )
    COP [SetOnInteract] ( &code_0886F4 )
    COP [SetEntryContinue]
    RTL 
}

code_0886E2 {
    COP [SetTilePos] ( #08, #13 )
    COP [StageSpriteFrame] ( #AD )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0886F4 )
    COP [SetEntryContinue]
    RTL 
}

code_0886F4 {
    COP [PrintWideString] ( &widestring_088862 )
    RTL 
}

code_0886F9 {
    COP [SetMetasprite] ( @table_0EE000 )
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
    COP [SpawnBeforeFlags] ( @code_08875E, #$2000 )
    LDA #$0800
    TSB $10

  loc_088733:
    COP [BranchIfFlagByte] ( #05, #01, &code_088740 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    BRA loc_088733
}

code_088740 {
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

code_08875E {
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_0888AB )
    COP [SetFlagByte] ( #05 )
    COP [Die]
}

widestring_08876A `[TPL:A][TPL:1][DLY:2]カレン: ペギー···[N]そんな 悲しそうな目をして···[FIN]もうすぐ あなたとも みんなとも[N]お别れなのよ···[PAL:0][END]`

widestring_0887B1 `[TPL:A][TPL:1][DLY:0]カレン:[N]きゃあああーーーーーーーーーっ!![N]ペギーっ! ペギーーーっ!![FIN][TPL:0][DLY:2]テム:[N]ペギー··· どうして···[PAL:0][END]`

widestring_088802 `[TPL:A][TPL:3]エリック: うわーん···[N]ペギー··· 自分だけ 先に[N]死んじゃって ずるいよ···[FIN][TPL:1]カレン:[N]ペギー···[N]ヒック·· ヒック····[PAL:0][END]`

widestring_088862 `[TPL:A][TPL:0]ブヒブヒッ[FIN]という声も もう 二度と[N]聞くことはできない···[FIN]ペギーからは こうばしい かおりが[N]ただよっている.[PAL:0][END]`

widestring_0888AB `[TPL:A][TPL:0]頭の中に 聞き覚えのある声が[N]話しかけてきた.[FIN][TPL:2]みんな お聞きなさい.[N]ペギーは 自らの意志で[N]村人たちの 食料となったのです.[FIN]いっぴきの子ブタが 数人の村人を[N]救うために 行動を 起こしました.[FIN][TPL:0]テム:[N]もしかして かあさん···?[FIN][TPL:2]テム···[N]そして この場にいる みんな···[FIN]世界に ヤミが せまっています.[N]今度は あなたたちが 力を合わせ[N]この星を 救う番なのですよ.[FIN]そして テム.[N]ミステリードールを 集め[N]バベルの塔へ むかいなさい···[PAL:0][END]`

code_0889D0 {
    COP [StageSpriteLoopMoveX] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoopMoveX] ( #20, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #01 )
    COP [Die]
}

code_088A00 {
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteLoopMoveX] ( #21, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [Die]
}

code_088A1F {
    COP [StageSpriteLoopMoveY] ( #1F, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [Die]
}

actor_def_088A37 [
  actor-def < #0B, #00, #10, {

  code_088A3A:
    COP [BranchIfFlagByte] ( #B2, #01, &code_088A88 )
    COP [BranchIfFlagByte] ( #AE, #01, &code_088A76 )
    COP [BranchIfFlagByte] ( #AD, #00, &code_088A88 )
    LDY $decelStepCounter
    LDA $0014, Y
    CLC 
    ADC #$0008
    STA $0014, Y
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_088AA2 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #AE )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
} >
]

code_088A76 {
    COP [SetTilePos] ( #07, #08 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_088A8A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088A88 {
    COP [Die]
}

code_088A8A {
    COP [SetFlagByte] ( #B0 )
    COP [PrintWideString] ( &widestring_088AF7 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #AC, #$00B0, #$00A0, #00, #$2200 )
    RTL 
}

widestring_088AA2 `[TPL:A][TPL:1]カレン:[N]だれも いないわね···[N]すてられた村なのかしら···?[FIN][TPL:3]エリック:[N]ちょうど いいじゃない.[N]勝手に 休ませてもらっちゃお.[PAL:0][END]`

widestring_088AF7 `[TPL:A][TPL:1]カレン:[N]今日は もう 休みましょ.[PAL:0][END]`

actor_def_088B15 [
  actor-def < #03, #00, #10, {

  code_088B18:
    COP [BranchIfFlagByte] ( #B2, #01, &code_088B47 )
    COP [BranchIfFlagByte] ( #AE, #01, &code_088B39 )
    COP [BranchIfFlagByte] ( #AD, #00, &code_088B47 )
    COP [SetOnInteract] ( &code_088B49 )
    COP [ExitIfFlagByte] ( #AE, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #04, #12 )
    COP [AnimLoop]
} >
]

code_088B39 {
    COP [SetTilePos] ( #07, #0A )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088B47 {
    COP [Die]
}

code_088B49 {
    COP [PrintWideString] ( &widestring_088B4E )
    RTL 
}

widestring_088B4E `[TPL:A][TPL:3]エリック: もう へとへとだあ.[N]ぼくは きっと 100時間くらい[N]起きないと思うよ.[PAL:0][END]`

actor_def_088B86 [
  actor-def < #13, #00, #10, {

  code_088B89:
    COP [BranchIfFlagByte] ( #B2, #01, &code_088BB8 )
    COP [BranchIfFlagByte] ( #AE, #01, &code_088BAA )
    COP [BranchIfFlagByte] ( #AD, #00, &code_088BB8 )
    COP [SetOnInteract] ( &code_088BBA )
    COP [ExitIfFlagByte] ( #AE, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #0C, #12 )
    COP [AnimLoop]
} >
]

code_088BAA {
    COP [SetTilePos] ( #08, #08 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088BB8 {
    COP [Die]
}

code_088BBA {
    COP [PrintWideString] ( &widestring_088BBF )
    RTL 
}

widestring_088BBF `[TPL:8]ブヒブヒッ[END]`

actor_def_088BC9 [
  actor-def < #31, #00, #18, {

  code_088BCC:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088BE3 )
    LDA #$1000
    TSB $12
    COP [StageSprAndHitbox] ( #31 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_088BE3 {
    COP [Die]
}

actor_def_088BE5 [
  actor-def < #1D, #00, #18, {

  code_088BE8:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088C3C )
    LDA #$1000
    TSB $12
    COP [SetOnInteract] ( &code_088C3E )

  loc_088BF7:
    COP [BranchIfFlagByte] ( #03, #01, &code_088C17 )
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    BRA loc_088BF7
} >
]

code_088C17 {
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088C3C {
    COP [Die]
}

code_088C3E {
    COP [PrintWideString] ( &widestring_088C58 )
    COP [DialogueOptions] ( #02, #01, &code_list_088C48 )
}

code_list_088C48 [
  &code_088C4E   ;00
  &code_088C53   ;01
  &code_088C4E   ;02
]

code_088C4E {
    COP [PrintWideString] ( &widestring_088CB3 )
    RTL 
}

code_088C53 {
    COP [PrintWideString] ( &widestring_088C89 )
    RTL 
}

widestring_088C58 `[TPL:E]男は おずおずと 手を[N]さしのべた···[FIN]手を にぎり返しますか?[N] はい[N] いいえ`

widestring_088C89 `[CLR]おたがい 言葉は わからないが[N]何かが 通じあったような気がした.[PAL:0][END]`

widestring_088CB3 `[CLR]男は さびしそうな顔をした···[PAL:0][END]`

actor_def_088CC9 [
  actor-def < #1C, #00, #18, {

  code_088CCC:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088D20 )
    LDA #$1000
    TSB $12
    COP [SetOnInteract] ( &code_088D22 )

  loc_088CDB:
    COP [BranchIfFlagByte] ( #03, #01, &code_088CFB )
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    BRA loc_088CDB
} >
]

code_088CFB {
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )

  code_088D0A:
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088D20 {
    COP [Die]
}

code_088D22 {
    COP [PrintWideString] ( &widestring_088D3C )
    COP [DialogueOptions] ( #02, #01, &code_list_088D2C )
}

code_list_088D2C [
  &code_088D32   ;00
  &code_088D37   ;01
  &code_088D32   ;02
]

code_088D32 {
    COP [PrintWideString] ( &widestring_088DB9 )
    RTL 
}

code_088D37 {
    COP [PrintWideString] ( &widestring_088D6E )
    RTL 
}

widestring_088D3C `[TPL:E]男は 何か ちっぽけな食べ物を[N]さしだした···[FIN]食べてみますか?[N] はい[N] いいえ`

widestring_088D6E `[CLR]虫を ダンゴ状にした 食べ物の[N]ようだった···[FIN]胸に こみ上げてくるものがあったが[N]何かが 通じあったような気がした.[PAL:0][END]`

widestring_088DB9 `[CLR]男は 悲しそうな顔をした···[PAL:0][END]`

actor_def_088DCF [
  actor-def < #1D, #00, #18, {

  code_088DD2:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088E09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088E0B )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_088E09 {
    COP [Die]
}

code_088E0B {
    COP [PrintWideString] ( &widestring_088E25 )
    COP [DialogueOptions] ( #02, #01, &code_list_088E15 )
}

code_list_088E15 [
  &code_088E1B   ;00
  &code_088E20   ;01
  &code_088E1B   ;02
]

code_088E1B {
    COP [PrintWideString] ( &widestring_088EA7 )
    RTL 
}

code_088E20 {
    COP [PrintWideString] ( &widestring_088E58 )
    RTL 
}

widestring_088E25 `[TPL:E]男は テムの目を じっと[N]見つめている···[FIN]見つめ返しますか?[N] はい[N] いいえ`

widestring_088E58 `[CLR]男は まるで ひとみの おくの[N]自分を 見つめているようだ···[FIN]おたがい 言葉は わからないが[N]何かが 芽生えたような気がした.[PAL:0][END]`

widestring_088EA7 `[CLR]男は さびしそうな顔をした···[PAL:0][END]`

actor_def_088EBD [
  actor-def < #24, #00, #18, {

  code_088EC0:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088EF7 )
    COP [SetOnInteract] ( &code_088EF9 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #26, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_088EF7 {
    COP [Die]
}

code_088EF9 {
    COP [PrintWideString] ( &widestring_088F16 )
    COP [DialogueOptions] ( #02, #01, &code_list_088F03 )
}

code_list_088F03 [
  &code_088F09   ;00
  &code_088F0E   ;01
  &code_088F09   ;02
]

code_088F09 {
    COP [PrintWideString] ( &widestring_088F98 )
    RTL 
}

code_088F0E {
    COP [PrintWideString] ( &widestring_088F4D )
    COP [SetFlagByte] ( #B1 )
    RTL 
}

widestring_088F16 `[TPL:E]少年は 北東の方角を[N]指さしている···[FIN]地図を 見せてみますか?[N] はい[N] いいえ`

widestring_088F4D `[CLR]少年は 地図に 寺院の絵を[N]書きこんだ![FIN]言葉は わからないが[N]少年は この寺院へ 行ってほしい[N]のだろう···[PAL:0][END]`

widestring_088F98 `[CLR]少年は さびしそうな顔をした···[PAL:0][END]`

actor_def_088FB0 [
  actor-def < #24, #00, #18, {

  code_088FB3:
    COP [BranchIfFlagByte] ( #AF, #00, &code_089028 )
    COP [SetOnInteract] ( &code_08902A )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #B2, #01, &code_088FE7 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SolidHighHere]
} >
]

code_088FE7 {
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TRB $10
    COP [ClearLowHere]
    LDA #$0148
    STA $moveXAlt, X
    LDA #$0120
    STA $moveYAlt, X
    COP [MoveToward] ( #29, #01 )
    LDA #$0188
    STA $moveXAlt, X
    LDA #$0140
    STA $moveYAlt, X
    COP [MoveToward] ( #29, #01 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_089047 )
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    RTL 
}

code_089028 {
    COP [Die]
}

code_08902A {
    COP [PrintWideString] ( &widestring_08904C )
    COP [DialogueOptions] ( #02, #01, &code_list_089034 )
}

code_list_089034 [
  &code_08903A   ;00
  &code_08903F   ;01
  &code_08903A   ;02
]

code_08903A {
    COP [PrintWideString] ( &widestring_0890A2 )
    RTL 
}

code_08903F {
    COP [PrintWideString] ( &widestring_08908A )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_089047 {
    COP [PrintWideString] ( &widestring_0890BA )
    RTL 
}

widestring_08904C `[TPL:E]少年は テムのそでを ひっぱった.[N]どこかへ 連れていきたいのだろう.[FIN]ついていきますか?[N] はい[N] いいえ`

widestring_08908A `[CLR]少年は ほほえんで 手まねきした.[PAL:0][END]`

widestring_0890A2 `[CLR]少年は さびしそうな顔をした···[PAL:0][END]`

widestring_0890BA `[TPL:9][TPL:0]少年は ガイ骨にむかって[N]目に なみだを ためている···[FIN]この ガイ骨は 肉親だったのか?[N]それとも 友達だったのだろうか?[PAL:0][END]`

actor_def_08910D [
  actor-def < #1A, #00, #18, {

  code_089110:
    COP [BranchIfFlagByte] ( #AF, #00, &code_089153 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088D22 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1E, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_089153 {
    COP [Die]
}

actor_def_089155 [
  actor-def < #1A, #00, #18, {

  code_089158:
    COP [BranchIfFlagByte] ( #AF, #00, &code_089167 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088C3E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_089167 {
    COP [Die]
}

actor_def_089169 [
  actor-def < #1A, #00, #18, {

  code_08916C:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088C3C )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088E0B )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1E, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_0891AF [
  actor-def < #36, #00, #10, {

  code_0891B2:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #BF, #01, &code_0891DB )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0891E7 )
    COP [ExitIfFlagByte] ( #BF, #01 )
    COP [LoopInit] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $12
} >
]

code_0891DB {
    COP [SetOnInteract] ( &code_0891EC )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0891E7 {
    COP [PrintWideString] ( &widestring_0891F1 )
    RTL 
}

code_0891EC {
    COP [PrintWideString] ( &widestring_08924A )
    RTL 
}

widestring_0891F1 `[DEF]少女の石像が ひっそりと[N]たたずんでいる.[END]`

widestring_08920C `[DEF]なんと 石像が[N]人間の 少女の姿に なった![FIN]少女は 目に うっすらと[N]なみだを うかべている···[END]`

widestring_08924A `[DEF]言葉が 通じないようだ···[END]`

actor_def_08925D [
  actor-def < #36, #00, #10, {

  code_089260:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C0, #01, &code_089289 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_089295 )
    COP [ExitIfFlagByte] ( #C0, #01 )
    COP [LoopInit] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $12
} >
]

code_089289 {
    COP [SetOnInteract] ( &code_08929A )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_089295 {
    COP [PrintWideString] ( &widestring_0892B5 )
    RTL 
}

code_08929A {
    COP [BranchIfFlagByte] ( #E6, #01, &code_0892B0 )
    COP [PrintWideString] ( &widestring_089321 )
    COP [GiveItem] ( #01, &code_0892AD )
    COP [SetFlagByte] ( #E6 )
    RTL 
}

code_0892AD {
    JMP $&code_08C7E3
}

code_0892B0 {
    COP [PrintWideString] ( &widestring_08930E )
    RTL 
}

widestring_0892B5 `[DEF]少女の石像が ひっそりと[N]たたずんでいる.[END]`

widestring_0892D0 `[DEF]なんと 石像が[N]人間の 少女の姿に なった![FIN]少女は 目に うっすらと[N]なみだを うかべている···[END]`

widestring_08930E `[DEF]言葉が 通じないようだ···[END]`

widestring_089321 `[DEF]少女は だまって 赤い宝石を[N]さしだした.[N]おれいの つもりなのだろう··[FIN]テムは 赤い宝石を 手に入れた![END]`

actor_def_089365 [
  actor-def < #36, #00, #10, {

  code_089368:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C1, #01, &code_089391 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08939D )
    COP [ExitIfFlagByte] ( #C1, #01 )
    COP [LoopInit] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $12
} >
]

code_089391 {
    COP [SetOnInteract] ( &code_0893A2 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_08939D {
    COP [PrintWideString] ( &widestring_0893A7 )
    RTL 
}

code_0893A2 {
    COP [PrintWideString] ( &widestring_089400 )
    RTL 
}

widestring_0893A7 `[DEF]少女の石像が ひっそりと[N]たたずんでいる.[END]`

widestring_0893C2 `[DEF]なんと 石像が[N]人間の 少女の姿に なった![FIN]少女は 目に うっすらと[N]なみだを うかべている···[END]`

widestring_089400 `[DEF]言葉が 通じないようだ···[END]`

actor_def_089413 [
  actor-def < #0B, #00, #30, {

  code_089416:
    COP [BranchIfFlagByte] ( #CF, #01, &code_089463 )
    COP [BranchIfFlagByte] ( #B6, #01, &code_089461 )
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
    COP [PrintWideString] ( &widestring_0894BE )
    COP [SetFlagByte] ( #CF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_08947A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_089461 {
    COP [Die]
}

code_089463 {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #07, #0A )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08947A )
    COP [SetEntryContinue]
    RTL 
}

code_08947A {
    COP [PrintWideString] ( &widestring_089527 )
    COP [DialogueOptions] ( #02, #02, &code_list_089484 )
}

code_list_089484 [
  &code_08948A   ;00
  &code_08948F   ;01
  &code_08948A   ;02
]

code_08948A {
    COP [PrintWideString] ( &widestring_0895BD )
    RTL 
}

code_08948F {
    COP [PrintWideString] ( &widestring_0895E1 )
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

widestring_0894BE `[DEF][TPL:1]カレン:[N]今さっき この村の人たちと[N]身ぶり手ぶりで お話してたのね.[FIN]そしたらね.[N]森に 動物がもどってきたみたい.[N]これで みんな 共食い することも[N]なくなるわよね.[PAL:0][END]`

widestring_089527 `[DEF][TPL:1]ドレイ商人たちは 北西の町から[N]やってきて 村人を 連れていく[N]みたいなの.[FIN]食べ物がなくて 困っているところに[N]つけこんで 子供たちを[N]買っていくなんて ゆるせない![FIN]ねえ そのドレイ商人の町へ[N]いってみない?[N] うん 行こう![N] ちょっとまって`

widestring_0895BD `[CLR][TPL:1]じゃあ 行く 準備ができたら[N]ここへ もどってきてね.[PAL:0][END]`

widestring_0895E1 `[CLR][TPL:1]さあ しゅっぱあつ!![PAL:0][END]`

actor_def_0895F2 [
  actor-def < #03, #00, #30, {

  code_0895F5:
    COP [BranchIfFlagByte] ( #CF, #01, &code_08961C )
    COP [BranchIfFlagByte] ( #B6, #01, &code_089633 )
    COP [ExitIfFlagByte] ( #BF, #01 )
    COP [ExitIfFlagByte] ( #C0, #01 )
    COP [ExitIfFlagByte] ( #C1, #01 )
    COP [WaitByte] ( #59 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #03, #02 )
    COP [AnimLoop]
} >
]

code_08961C {
    COP [SetTilePos] ( #08, #0A )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_089635 )
    COP [SetEntryContinue]
    RTL 
}

code_089633 {
    COP [Die]
}

code_089635 {
    COP [PrintWideString] ( &widestring_08963A )
    RTL 
}

widestring_08963A `[DEF][TPL:3]エリック:[N]この村が 食料不足なのにつけこんだ[N]ドレイ商人たちは 子供たちを[N]連れ去ったんだって.[FIN]ひどい話だよね.[PAL:0][END]`

actor_def_08968A [
  actor-def < #00, #00, #28, {

  code_08968D:
    COP [SetAnimScratch] ( @misc_fx_1CD380 )
    COP [SetMetasprite] ( @sprite_set_list_14C12C )
    COP [ResetSpriteInit] ( #00, #$2020 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]

actor_def_08969F [
  actor-def < #00, #00, #30, {

  code_0896A2:
    COP [BranchIfFlagByte] ( #BE, #01, &code_0896C4 )
    COP [BranchIfFlagByte] ( #B3, #01, &code_0896C4 )
    COP [SetFlagByte] ( #B3 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0896C6 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_0896C4 {
    COP [Die]
}

widestring_0896C6 `[TPL:A][TPL:0]原住民の村落から 3日ほど[N]ジャングルを 分け入ると そこには[N]きょ大な寺院が たたずんでいた.[PAL:0][END]`

actor_def_08970A [
  actor-def < #00, #00, #20, {

  code_08970D:
    PHX 
    LDX #$0000

  loc_089711:
    LDA $@loc_089754, X
    CMP #$FFFF
    BEQ loc_089751
    CMP $sceneCurrent
    BNE loc_089731
    LDA $@loc_089754+2, X
    CMP $playerWallType
    BNE loc_089731
    LDA $@loc_089754+4, X
    CMP $playerSpeedEw
    BEQ loc_089739

  loc_089731:
    TXA 
    CLC 
    ADC #$0006
    TAX 
    BRA loc_089711

  loc_089739:
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5C1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y

  loc_089751:
    PLX 
    COP [Die]

  loc_089754:
    TYX 
    BRK #$A0
    BRK #$20
    ORA ($BB, X)
    BRK #$10
    ORA ($20, X)
    ORA ($BB, X)
    BRK #$80
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00BB01, #$00F0, #$0210, #$00BD )
    PHA 
    COP #$F0
    ORA ($FF, X)
    SBC $230000, X
    COP [ExitIfFlagWord] ( #$016B, #01 )
    LDA #$000A
    STA $0E
    COP [JumpScript] ( @chunk_008000.code_00D2B3 )
} >
]

actor_def_089774 [
  actor-def < #00, #00, #23, {

  code_089777:
    COP [ExitIfFlagWord] ( #$016B, #01 )
    LDA #$000A
    STA $0E
    COP [JumpScript] ( @chunk_008000.code_00D2B3 )
} >
]

actor_def_089786 [
  actor-def < #00, #00, #30, {

  code_089789:
    COP [BranchIfFlagWord] ( #$016E, #01, &code_0897D4 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #6A, #0C, #6F, #0D, &code_08979B )
    RTL 
} >
]

code_08979B {
    COP [LoopInit] ( #14 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #6E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$016E )
    LDY $decelStepCounter
    SEP #$20
    LDA #$82
    STA $0002, Y
    REP #$20
    LDA #$D271
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $slopeCurvePtrB
}

code_0897D4 {
    COP [Die]
}

actor_def_0897D6 [
  actor-def < #00, #00, #30, {

  code_0897D9:
    COP [BranchIfPlayerAt] ( #$0578, #$0010, &code_0897E3 )
    BRA code_089834
} >
]

code_0897E3 {
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$82
    STA $0002, Y
    REP #$20
    LDA #$D28E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [BranchIfFlagByte] ( #B5, #01, &code_089834 )
    COP [SetFlagByte] ( #B5 )
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$A1
    STA $CGADSUB
    LDA #$FF
    STA $COLDATA
    REP #$20
    COP [WaitByte] ( #B3 )
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
}

code_089834 {
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0F01, &code_08983D )
    RTL 
}

code_08983D {
    COP [BranchIfPlayerInAbsTiles] ( #3D, #0C, #43, #1B, &code_08984E )
    COP [BranchIfPlayerInAbsTiles] ( #43, #06, #5D, #1B, &code_08984E )
    RTL 
}

code_08984E {
    LDA $0036
    AND #$0007
    BEQ loc_089857
    RTL 

  loc_089857:
    COP [PlaySoundCh2] ( #08 )
    RTL 
}

actor_def_08985B [
  actor-def < #03, #00, #00, {

  code_08985E:
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #03, #10, #07, #18, &code_08986D )
    RTL 
} >
]

code_08986D {
    LDA #$0010
    TSB $10
    COP [SolidHighAbs] ( #05, #0F )
    COP [SolidHighAbs] ( #06, #0F )
    COP [SpawnAfterFlags] ( @code_089894, #$2000 )
    COP [StageSpriteMoveX] ( #85, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    RTL 
}

code_089894 {
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    COP [WaitByte] ( #01 )
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    ORA #$0200
    STA $000E, Y
    COP [WaitByte] ( #01 )
    BRA code_089894
}

actor_def_0898B5 [
  actor-def < #00, #00, #30, {

  code_0898B8:
    COP [BranchIfFlagByte] ( #B7, #01, &code_0898D4 )
    COP [SetFlagByte] ( #B7 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0898FE )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_0898D4 {
    COP [BranchIfEquipped] ( #1C, &code_0898F4 )
    COP [WaitByte] ( #13 )

  loc_0898DC:
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitByte] ( #B3 )
    COP [SetEntryContinue]
    COP [BranchIfEquipped] ( #1C, &code_0898EC )
    RTL 
}

code_0898EC {
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    COP [WaitByte] ( #B3 )
}

code_0898F4 {
    COP [SetEntryContinue]
    COP [BranchIfEquipped] ( #1C, &code_0898FD )
    BRA loc_0898DC
}

code_0898FD {
    RTL 
}

widestring_0898FE `[DEF][TPL:0]この階に 足を ー歩ふみいれると[N]空中をふゆうしている クリスタルが[N]発光しはじめたっ!![PAL:0][END]`

actor_def_08993B [
  actor-def < #00, #00, #10, {

  code_08993E:
    COP [BranchIfFlagByte] ( #BE, #01, &code_089A04 )
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_089A06 )
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #BD, #01, &code_08996C )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08996C {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_089AD0 )
    SEP #$20
    LDA #$15
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitByte] ( #EF )
    LDA #$2000
    TSB $10
    COP [ClearLowAbs] ( #0F, #0A )
    COP [ClearLowAbs] ( #10, #0A )
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_089C4D )
    COP [GiveItem] ( #1D, &code_0899C0 )

  loc_0899A8:
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_089CDD )
    COP [SetFlagByte] ( #BE )

  code_0899B7:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_0899C0 {
    COP [BranchIfNoItem] ( #01, &code_0899CA )
    COP [BranchIfNoItem] ( #06, &code_0899ED )
}

code_0899CA {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_089CA5 )
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    COP [GiveItem] ( #1D, &code_0899B7 )
    BRA loc_0899A8
}

code_0899ED {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_089CF9 )
    COP [RemoveItem] ( #06 )
    COP [GiveItem] ( #1D, &code_0899B7 )
    BRA loc_0899A8
}

code_089A04 {
    COP [Die]
}

code_089A06 {
    COP [PrintWideString] ( &widestring_089A24 )
    COP [SetFlagByte] ( #BD )
    LDA #$0004
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #C0, #$0000, #$0000, #00, #$4400 )
    RTL 
}

widestring_089A24 `[DEF]テム···[N]私は そなたが くるのを[N]何千年もの間 まっていたのだよ.[FIN][TPL:0]テム:[N]君は··? だれだい···?[FIN][PAL:0]私は 夢を 見ているのさ.[N]夢を 続けているうちに 時が流れ[N]やがて こんな体になったんだよ.[FIN]これから そなたに 不思議な映像を[N]見せようと 思う.[N]目を とじなさい.[END]`

widestring_089AD0 `[DEF][TPL:0]テム:[N]今のは? いったい何?[FIN][TPL:2]新しい 世界だよ···[FIN][TPL:0]テム:[N]あの 世界は 灰色ばっかりじゃ[N]ないか···[FIN]世界っていうのは 青い水があって[N]緑の山があって 茶色の大地が[N]広がっている もんじゃないの?[FIN][TPL:2]あの世界は これから そなたが[N]もたらすのだ···[FIN][TPL:0]テム: ぼくが?[N]あんな ぶきみな 世界を?![FIN][TPL:2]木々が そびえたつ ビルの群れに[N]川の流れが 車の流れに かわった[N]だけのこと···[FIN]人は どんな世界にいても 自分が[N]幸せだと 思えば 幸せなのだよ.[FIN]さあ 原住民の村落へもどり[N]石に 変わってしまった人を もとに[N]もどしてあげなさい.[FIN]灰色に そまった人たちを[N]自然のままに 解放してあげなさい.[PAL:0][END]`

widestring_089C4D `[TPL:A][TPL:0]まばゆい光がやむと ぼくは[N]何ごとも なかったかのように[N]たたずんでいた.[FIN]そして 手には ゴーゴンの花が[N]しっかりと にぎられているの[N]だった···[PAL:0][END]`

widestring_089CA5 `[TPL:A]不思議な声が ひびいた···[N]お前の 赤い宝石を ーつばかり[N]あずからせてもらった···[END]`

widestring_089CDD `[TPL:A][SFX:0][DLY:9]ゴーゴンの花を 手に入れた![PAU:78][END]`

widestring_089CF9 `[TPL:A]不思議な声が ひびいた···[N]お前の 藥草を ーつばかり[N]あずからせてもらった···[END]`

actor_def_089D2E [
  actor-def < #31, #02, #0B, {

  code_089D31:
    COP [SpawnAfterFlags] ( @chunk_068000.code_0693AF, #$2800 )
    LDA #$FFFF
    STA $24
    STA $26
    COP [SetEntryContinue]
    LDA $14
    BMI loc_089D62
    CMP $cameraBoundsX
    BCS loc_089D69
    LDA $16
    BMI loc_089D70
    CMP $cameraBoundsY
    BCS loc_089D77

  loc_089D53:
    LDA $14
    CLC 
    ADC $24
    STA $14
    LDA $16
    CLC 
    ADC $26
    STA $16
    RTL 

  loc_089D62:
    LDA #$0001
    STA $24
    BRA loc_089D53

  loc_089D69:
    LDA #$FFFF
    STA $24
    BRA loc_089D53

  loc_089D70:
    LDA #$0001
    STA $26
    BRA loc_089D53

  loc_089D77:
    LDA #$FFFF
    STA $26
    BRA loc_089D53
} >
]

actor_def_089D7E [
  actor-def < #02, #01, #10, {

  code_089D81:
    COP [BranchIfFlagByte] ( #BA, #01, &code_089DB7 )
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetOnInteract] ( &code_089D9F )

  loc_089D95:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_089D95
} >
]

code_089D9F {
    COP [PrintWideString] ( &widestring_089DBD )
    COP [GiveItem] ( #1C, &code_089DB9 )
    COP [SetFlagByte] ( #BA )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_089DD8 )
}

code_089DB7 {
    COP [Die]
}

code_089DB9 {
    JML $@chunk_008000.code_00CAD3
}

widestring_089DBD `[DEF]地面に 何か 光る物が[N]うもれている.[FIN]`

widestring_089DD8 `[CLR][SFX:0][DLY:9]黒すいしょうのめがねを 見つけた![PAU:78][END]`

actor_def_089DF3 [
  actor-def < #2C, #01, #10, {

  code_089DF6:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_089E04 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_089E04 {
    COP [PrintWideString] ( &widestring_089E1E )
    COP [DialogueOptions] ( #02, #02, &code_list_089E0E )
}

code_list_089E0E [
  &code_089E19   ;00
  &code_089E14   ;01
  &code_089E19   ;02
]

code_089E14 {
    COP [PrintWideString] ( &widestring_089E84 )
    RTL 
}

code_089E19 {
    COP [PrintWideString] ( &widestring_089E82 )
    RTL 
}

widestring_089E1E `[DEF][TPL:0]失われた時の みりょくに[N]とりつかれた 探険家の なれの果て[N]だろうか···?[FIN]おや? 何か 手帳のようなものが[N]にぎられているようだ···[N] 読んでみる[N] やめておく[PAL:0]`

widestring_089E82 `[CLD]`

widestring_089E84 `[CLR]我々は ジャングルを 分けいり[N]原住民の村落へ たどりついた.[N][PAU:1E]言葉は通じないが 親切な 村人は[N]とまっていけと手招きしてくれる.[FIN]よく朝 目覚めてみると[N]私と 隊長のフリーゼルしか[N]いないではないか···[FIN]そこは 何と 人食い人種の村で[N]あったのだ![FIN]骨になった 仲間を 横目に[N]にげだした 隊長と 私は,[N]ジャングルを さまよい続け そして[N]アンコールワットを 発見した.[FIN]ここには 神がすみ 永遠の命が[N]手に入るという うわさだったが[N]目に うつったのは まものの姿[N]だけであった···[FIN]そして今 私も 仲間のもとへ[N]旅立とうとしている···[N]私が この世から いなくなって[N]悲しむ人は いるのだろうか··?[END]`

actor_def_089FFD [
  actor-def < #2C, #01, #10, {

  code_08A000:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A00E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A00E {
    COP [PrintWideString] ( &widestring_08A028 )
    COP [DialogueOptions] ( #02, #02, &code_list_08A018 )
}

code_list_08A018 [
  &code_08A023   ;00
  &code_08A01E   ;01
  &code_08A023   ;02
]

code_08A01E {
    COP [PrintWideString] ( &widestring_08A088 )
    RTL 
}

code_08A023 {
    COP [PrintWideString] ( &widestring_08A223 )
    RTL 
}

widestring_08A028 `[DEF][TPL:0]失われた時の みりょくに[N]とりつかれた 探険家の なれの果て[N]だろうか···?[FIN]わきに 何か 日記のようなものが[N]落ちている···[N] 読んでみる[N] やめておく[PAL:0]`

widestring_08A088 `[CLR][N]  アンコールワット 調査記録[N][N]      フリーゼル[FIN]アンコールワットは 神が住むと[N]うわさされる寺院である.[FIN]私は ついに 本堂まで たどりつき[N]その2階で 光の間に はばまれた.[FIN]最上階で 神に会見するには ここを[N]通らねばならないのだが あまりに[N]光が強く 通路がまったく見えない.[FIN]かつて 神に 会うために[N]黒すいしょうで作った メガネが[N]使われていたという言い伝えもある.[FIN]私は 本堂へと続く参道の 付近で[N]いっしゅん 地面に黒光りするものを[N]見かけたが まものに はばまれ[N]その場を後にせざるをえなかった.[FIN]もしかすると あれが 言い伝えの[N]メガネだったのかもしれない···[FIN]ここまで来ながら 残念だ···[N]私の子供が この意志をついで[N]くれることをいのって···[END]`

widestring_08A223 `[CLD]`

actor_def_08A225 [
  actor-def < #1A, #00, #10, {

  code_08A228:
    COP [BranchIfFlagByte] ( #D2, #01, &code_08A23D )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A23F )
    COP [BranchIfFlagByte] ( #B6, #00, &code_08A244 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A23D {
    COP [Die]
}

code_08A23F {
    COP [PrintWideString] ( &widestring_08A289 )
    RTL 
}

code_08A244 {
    COP [SetFlagByte] ( #B6 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08A25D )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

widestring_08A25D `[TPL:A][TPL:0]さばくの中に ぽつんとたたずむ町.[N]ぼくらは ダオに やってきた.[PAL:0][END]`

widestring_08A289 `[TPL:B][TPL:1]カレン:[N]ドレイ商人のアジトって言われるほど[N]悪名高い町のはずなのに 何だか[N]そんな 感じが しないわよね.[PAL:0][END]`

actor_def_08A2D5 [
  actor-def < #0A, #00, #10, {

  code_08A2D8:
    COP [BranchIfFlagByte] ( #D2, #01, &code_08A2E7 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A2E9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A2E7 {
    COP [Die]
}

code_08A2E9 {
    COP [PrintWideString] ( &widestring_08A2EE )
    RTL 
}

widestring_08A2EE `[TPL:A][TPL:3]エリック:[N]こんな 砂あらしじゃあ 目が[N]いたくって 外も あるけないよ.[PAL:0][END]`

actor_def_08A31F [
  actor-def < #12, #00, #10, {

  code_08A322:
    COP [BranchIfFlagByte] ( #D2, #01, &code_08A35E )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A360 )
    COP [BranchIfFlagByte] ( #B4, #01, &code_08A35B )
    COP [SetFlagByte] ( #B4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08A38E )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_08A35B {
    COP [SetEntryContinue]
    RTL 
}

code_08A35E {
    COP [Die]
}

code_08A360 {
    COP [BranchIfFlagByte] ( #D0, #01, &code_08A36B )
    COP [PrintWideString] ( &widestring_08A465 )
    RTL 
}

code_08A36B {
    COP [PrintWideString] ( &widestring_08A4AE )
    LDA #$000B
    STA $0D60
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0094, #$0114, #00, #21 )
    COP [QueueMapChange] ( #DC, #$0000, #$0000, #00, #$1100 )
    RTL 
}

widestring_08A38E `[TPL:A][TPL:6]ニール: テムっ!!![N]まさか こんなところで 会うとは[N]思わなかったよ![FIN][TPL:0]ニールっ! どうしたの?[N]社長に なったんじゃないの?![FIN][TPL:6]ニール: ははは.[N]ドレイ貿易のかわりに コショウを[N]輸入できないかと 思ってね.[FIN]こうして ダオまで[N]はるばる やってきたのさ.[FIN]この近くには ピラミッドがある.[N]ミステリードールとやらが そこに[N]あるんじゃないか?[PAL:0][END]`

widestring_08A465 `[TPL:B][TPL:6]ドレイ貿易のかわりに コショウを[N]輸入できないかと 思ってね.[N]こうして ダオまで[N]はるばる やってきたのさ.[PAL:0][END]`

widestring_08A4AE `[TPL:B][TPL:6]ニール:[N]そうか····[N]やっぱり どうしても 行くんだな?[FIN]お前は むかしから 言い出したら[N]きかないヤツだったからな.[FIN]わかった. じゃあ テムを[N]バベルの塔まで送って その足で[N]カレンとエリックを サウスケープへ[N]送ることにしよう.[FIN]今度は たぶん 落ちないはずだから[N]安心してくれ.[PAL:0][END]`

actor_def_08A561 [
  actor-def < #02, #00, #10, {

  code_08A564:
    COP [SetOnInteract] ( &code_08A57F )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_08A573:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_08A573
} >
]

code_08A57F {
    COP [PrintWideString] ( &widestring_08A584 )
    RTL 
}

widestring_08A584 `[DEF]ここは さばくの町 ダオ.[N]こんなところに ふつうの[N]子供がいるなんて めずらしいなあ.[END]`

widestring_08A5B7 `ぐが┌ぐ[END]`

widestring_08A5BC `[PAL:A5]ぐぢぐ[DLG:6B,2][BF][CLD][A5]ぅ[DEF]砂が 目にはいって[N]いたいの なんのって····[END]`

actor_def_08A5E4 [
  actor-def < #05, #00, #10, {

  code_08A5E7:
    COP [SetOnInteract] ( &code_08A5FB )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #08, #40, #12 )
    COP [AnimLoop]
    COP [Die]
} >
]

code_08A5FB {
    COP [PrintWideString] ( &widestring_08A600 )
    RTL 
}

widestring_08A600 `[DEF]商人:[N]今日は いい 買い物をしたなあ.[N]こんな すばらしい じゅうたんは[N]見たことがないよ. うん.[END]`

actor_def_08A63C [
  actor-def < #02, #00, #10, {

  code_08A63F:
    COP [SetOnInteract] ( &code_08A65A )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_08A64E:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_08A64E
} >
]

code_08A65A {
    COP [PrintWideString] ( &widestring_08A65F )
    RTL 
}

widestring_08A65F `[DEF]はるばる この町まで ドレイを[N]買いにきたものの···[FIN]いざ 明り引きとなると[N]なんだか ふんぎりがつかないんだ.[N]やっぱり 人に 値段は[N]つけられないよなあ···[END]`

actor_def_08A6BC [
  actor-def < #05, #00, #10, {

  code_08A6BF:
    COP [SetOnInteract] ( &code_08A6C8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A6C8 {
    COP [PrintWideString] ( &widestring_08A6CD )
    RTL 
}

widestring_08A6CD `[DEF]ピラミッドは きょだいな 石の[N]かたまりだっていうのに[N]なぜ 砂の中に しずまないのか··[N]おれは 不思議でしょうがねえよ.[END]`

actor_def_08A715 [
  actor-def < #02, #00, #10, {

  code_08A718:
    COP [SetOnInteract] ( &code_08A721 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A721 {
    COP [PrintWideString] ( &widestring_08A726 )
    RTL 
}

widestring_08A726 `[DEF]この地域には 不思議な言い伝えが[N]あるんだよ.[FIN]┌ピラミッドは 死者の場所.[N] 肉体を こえた者だけが その中に[N] 足をふみ入れる 資格がある┘[FIN]これが その言葉だそうだ···[N]ピラミッドは きょだいな墓.[N]死ななきゃ 中に入れないって[N]ことなのだろうか? うーむ.[END]`

actor_def_08A7CC [
  actor-def < #04, #00, #10, {

  code_08A7CF:
    COP [SetOnInteract] ( &code_08A7D8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A7D8 {
    COP [PrintWideString] ( &widestring_08A7DD )
    RTL 
}

widestring_08A7DD `[DEF]おれたちゃ 探険家さ.[N]ピラミッドに お宝が ねむっている[N]と聞いて やってきたんだが···[END]`

actor_def_08A814 [
  actor-def < #1A, #00, #10, {

  code_08A817:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08A841 )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [SpawnAfterFlags] ( @code_08A838, #$1001 )
    COP [StageSpriteLoopMoveXY] ( #1B, #40, #53, #54 )
    COP [AnimLoop]
    COP [Die]
} >
]

code_08A838 {
    COP [StageSpriteLoopMoveX] ( #1C, #40, #53 )
    COP [AnimLoop]
    COP [Die]
}

code_08A841 {
    COP [PrintWideString] ( &widestring_08A846 )
    RTL 
}

widestring_08A846 `[DEF]キューイ キューイ[END]`

actor_def_08A855 [
  actor-def < #05, #00, #10, {

  code_08A858:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A861 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A861 {
    COP [PrintWideString] ( &widestring_08A866 )
    RTL 
}

widestring_08A866 `[DEF]最近 ドレイ貿易廃止の 動きが[N]でているみたいだ.[FIN]なんでも ローレック株式会社の[N]社長が 自ら その運動を[N]はじめたようだぜ.[END]`

actor_def_08A8BC [
  actor-def < #04, #00, #10, {

  code_08A8BF:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A8C8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A8C8 {
    COP [PrintWideString] ( &widestring_08A8CD )
    RTL 
}

widestring_08A8CD `[DEF]ここは コショウなどの 調味料と[N]じゅうたんが 特産品の町さ.[FIN]エドワード城の じゅうたんも[N]この町で 40年の さい月をかけて[N]織られたっていう話だ.[END]`

actor_def_08A92C [
  actor-def < #1A, #00, #10, {

  code_08A92F:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08A941 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08A941 {
    COP [PrintWideString] ( &widestring_08A946 )
    RTL 
}

widestring_08A946 `[DEF]キューイ キューイ[END]`

actor_def_08A955 [
  actor-def < #1A, #00, #10, {

  code_08A958:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08A96A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08A96A {
    COP [PrintWideString] ( &widestring_08A96F )
    RTL 
}

widestring_08A96F `[DEF]キューイ キューイ[END]`

actor_def_08A97E [
  actor-def < #0A, #00, #10, {

  code_08A981:
    COP [SetOnInteract] ( &code_08A9BC )

  code_08A985:
    COP [BranchOnPlayerX] ( #$0008, &code_08A996, &code_08A98F, &code_08A9A9 )
} >
]

code_08A98F {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    BRA code_08A985
}

code_08A996 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_08A9A1 )
    COP [SetEntryExitNow] ( @code_08A985 )
}

code_08A9A1 {
    COP [StageSpriteMoveX] ( #0E, #12 )
    COP [AnimOnce]
    BRA code_08A985
}

code_08A9A9 {
    COP [BranchIfSolidOffset] ( #03, #00, &code_08A9B4 )
    COP [SetEntryExitNow] ( @code_08A985 )
}

code_08A9B4 {
    COP [StageSpriteMoveX] ( #0E, #11 )
    COP [AnimOnce]
    BRA code_08A985
}

code_08A9BC {
    COP [PrintWideString] ( &widestring_08A9C1 )
    RTL 
}

widestring_08A9C1 `[DEF][TPL:0]どうやら 言葉が 通じないようだ.[N]少年は 目で 何かを[N]うったえようと している···[PAL:0][END]`

actor_def_08A9FA [
  actor-def < #14, #00, #10, {

  code_08A9FD:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AA06 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08AA06 {
    COP [PrintWideString] ( &widestring_08AA15 )
    COP [WriteApuIo0] ( #7F )
    COP [PrintWideString] ( &widestring_08AA32 )
    COP [WriteApuIo0] ( #01 )
    RTL 
}

widestring_08AA15 `[DEF]少女は だまって[N]ー枚の紙を さしだした.[FIN]`

widestring_08AA32 `[CLR][DLY:4]そこには なんと[N]黒いヒョウの絵が えがかれている![FIN][DLY:2][TPL:0]ぼくは せすじが 寒くなった.[N]これは ぼくらを 追いつめたという[N]ブラックパンサーの けい告[N]だろうか···[PAL:0][END]`

actor_def_08AA97 [
  actor-def < #1F, #00, #10, {

  code_08AA9A:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_08AAFB, #$FFE0, #$0020, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_08AAFB, #$FFF0, #$0020, #$1000 )
    LDA #$0008
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08AAFB, #$0000, #$0020, #$1000 )
    LDA #$0010
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08AAFB, #$0010, #$0020, #$1000 )
    LDA #$0018
    STA $0008, Y
    COP [SpawnAfterRelFlags] ( @code_08AAFB, #$0020, #$0020, #$1000 )
    LDA #$0020
    STA $0008, Y
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AB11 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AAFB {
    COP [StageSprAndHitbox] ( #20 )
    COP [SolidHighHere]

  loc_08AB00:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_08AB00
}

code_08AB11 {
    COP [PrintWideString] ( &widestring_08AB16 )
    RTL 
}

widestring_08AB16 `[DEF]スネークパニックは やったかい?[N]ぼくは まだ 修行中の身なのさ.[END]`

actor_def_08AB3F [
  actor-def < #1F, #00, #10, {

  code_08AB42:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_08AD77, #$FFD0, #$0010, #$0300 )
    COP [SpawnAfterRelFlags] ( @code_08AD77, #$0000, #$0010, #$0300 )
    COP [SpawnAfterRelFlags] ( @code_08AD77, #$0030, #$0010, #$0300 )
    COP [SolidHighHere]

  code_08AB6A:
    COP [ClearFlagByte] ( #04 )
    COP [SetOnInteract] ( &code_08AB8F )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_08ABB5 )
    COP [SpawnAfterFlags] ( @code_08AC77, #$2000 )
    COP [ClearFlagByte] ( #03 )

  loc_08AB83:
    COP [BranchIfFlagByte] ( #04, #01, &code_08AB6A )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_08AB83
} >
]

code_08AB8F {
    COP [PrintWideString] ( &widestring_08ABBA )
    COP [DialogueOptions] ( #02, #02, &code_list_08AB99 )
}

code_list_08AB99 [
  &code_08AB9F   ;00
  &code_08ABA4   ;01
  &code_08AB9F   ;02
]

code_08AB9F {
    COP [PrintWideString] ( &widestring_08ABE4 )
    RTL 
}

code_08ABA4 {
    COP [PrintWideString] ( &widestring_08ABFE )
    COP [SetFlagByte] ( #01 )
    STZ $0AAC
    LDA #$0008
    TRB $slopeCurvePtrB
    RTL 
}

code_08ABB5 {
    COP [PrintWideString] ( &widestring_08AC5F )
    RTL 
}

widestring_08ABBA `[DEF]ヘビを使った 面白いゲームを[N]やっていかないか?[N] はい[N] いいえ`

widestring_08ABE4 `[CLR]それは 残念.[N]気がむいたら きてくれよ.[END]`

widestring_08ABFE `[CLR]ルールは かんたん.[N]出てくる ヘビを ー分間に[N]何ひき たたけるかを きそうんだ.[FIN]じゃあ どれでも 好きなツボを[N]たたいてくれ.[N]そのときが スタートだっ!![END]`

widestring_08AC5F `[DEF]おいおい.[N]ずいぶんと よゆうがあるんだな.[END]`

code_08AC77 {
    COP [ExitIfFlagByte] ( #02, #01 )
    PHX 
    LDX #$0000

  loc_08AC7F:
    STZ $0410, X
    INX 
    INX 
    CPX #$0010
    BNE loc_08AC7F
    PLX 
    LDA #$0055
    STA $041E
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]

  code_08AC9C:
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    STZ $24
    COP [SetEntryContinue]
    LDA $24
    CMP #$0E10
    BEQ loc_08ACB0
    INC $24
    RTL 

  loc_08ACB0:
    COP [BranchIfFlagByte] ( #E7, #01, &code_08ACBE )
    LDA $0AAC
    CMP #$0051
    BCS loc_08ACD3
}

code_08ACBE {
    COP [PrintWideString] ( &widestring_08ACE8 )

  loc_08ACC2:
    COP [ClearFlagByte] ( #01 )
    COP [ClearFlagByte] ( #02 )
    COP [SetFlagByte] ( #03 )
    LDA #$0008
    TSB $slopeCurvePtrB
    COP [Die]

  loc_08ACD3:
    COP [SetFlagByte] ( #E7 )
    COP [PrintWideString] ( &widestring_08AD1C )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0002
    STA $jewelsCollected
    CLD 
    BRA loc_08ACC2
}

widestring_08ACE8 `[TPL:A]はいっ! そこまでっ!![N]君の たたいた数は [BCD:3,AAC]ひき.[N]また ちょうせんしてくれよっ![END]`

widestring_08AD1C `[TPL:A]うひゃあ [BCD:3,AAC]ひきとは なかなか[N]強者だね.[FIN]じゃあ しょうひんとして[N]赤い宝石を2コあげることにしよう.[FIN]宝石商さんのところに[N]送っておくからね.[END]`

code_08AD77 {
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SolidHighHere]

  loc_08AD85:
    COP [StageSprAndHitbox] ( #24 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$0200
    TRB $10
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_08ADA0 )
    COP [ExitIfFlagByte] ( #02, #01 )
}

code_08ADA0 {
    COP [SetFlagByte] ( #02 )
    COP [SetHitCallback] ( &code_08ADDB )

  loc_08ADA7:
    COP [BranchIfFlagByte] ( #03, #01, &code_08ADD6 )
    LDA #$00FF
    STA $currentHp, X
    COP [RngByte]
    AND #$000F
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_08ADCA:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0200
    TSB $10
    BRA loc_08ADA7
}

code_08ADD6 {
    COP [SetFlagByte] ( #04 )
    BRA loc_08AD85
}

code_08ADDB {
    COP [PlaySoundCh1] ( #0D )
    SED 
    LDA $0AAC
    CLC 
    ADC #$0001
    STA $0AAC
    CLD 
    LDA #$0200
    TSB $10
    COP [SetHitCallback] ( &code_08ADDB )
    BRA loc_08ADCA
}

actor_def_08ADF5 [
  actor-def < #1F, #00, #10, {

  code_08ADF8:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AE0A )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AE0A {
    COP [BranchIfFlagByte] ( #B8, #00, &code_08AE15 )
    COP [PrintWideString] ( &widestring_08AE70 )
    RTL 
}

code_08AE15 {
    COP [PrintWideString] ( &widestring_08AE96 )
    COP [DialogueOptions] ( #02, #02, &code_list_08AE1F )
}

code_list_08AE1F [
  &code_08AE25   ;00
  &code_08AE2A   ;01
  &code_08AE25   ;02
]

code_08AE25 {
    COP [PrintWideString] ( &widestring_08AF18 )
    RTL 
}

code_08AE2A {
    COP [PrintWideString] ( &widestring_08AEB5 )
    SEP #$20
    STZ $0000
    LDY #$0000

  loc_08AE36:
    LDA $inventorySlots, Y
    BNE loc_08AE3E
    INC $0000

  loc_08AE3E:
    INY 
    CPY #$0010
    BNE loc_08AE36
    REP #$20
    LDA $0000
    AND #$00FF
    CMP #$0002
    BCC loc_08AE6B
    COP [GiveItem] ( #25, &code_08AE6A )
    COP [GiveItem] ( #26, &code_08AE6A )
    COP [SetFlagByte] ( #B8 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08AEF9 )
}

code_08AE6A {
    RTL 

  loc_08AE6B:
    COP [PrintWideString] ( &widestring_08AF40 )
    RTL 
}

widestring_08AE70 `[DEF]この家は 遠くから はるばる[N]やってくる 商人のための宿だよ.[END]`

widestring_08AE96 `[DEF]あんた ひょっとして[N]テムさんかい?[N] はい[N] いいえ`

widestring_08AEB5 `[CLR]こりゃ ちょうど よかった![N]ビルと ローラって人から[N]手紙と 荷物が 届いているんだ.[N]受けとってくんな.[FIN]`

widestring_08AEF9 `[CLR][SFX:0][DLY:9]手紙と 父の手帳を 手に入れた![PAU:78][END]`

widestring_08AF18 `[CLR]そうか···[N]荷物が 届いているんだがなあ.[N]困った 困った···[END]`

widestring_08AF40 `[DEF][CLR]どうやら 持ち物が いっぱいの[N]ようだな.[N]どこかで 荷物を へらしておいで.[END]`

actor_def_08AF6E [
  actor-def < #1D, #00, #10, {

  code_08AF71:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AF83 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AF83 {
    COP [PrintWideString] ( &widestring_08AF88 )
    RTL 
}

widestring_08AF88 `[DEF]おらおら.[N]見せ物じゃ ないんだぞっ!![N]あっちへ いった いった![END]`

actor_def_08AFAE [
  actor-def < #1D, #00, #10, {

  code_08AFB1:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AFC3 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AFC3 {
    COP [PrintWideString] ( &widestring_08AFC8 )
    RTL 
}

widestring_08AFC8 `[DEF]この近くには でっけえピラミッドが[N]たってるぜ.[FIN]探険家たちが 財宝を求めて[N]何人も やってきたが[N]まだ 見つけた者はいないようだ.[END]`

actor_def_08B019 [
  actor-def < #1D, #00, #10, {

  code_08B01C:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B02E )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B02E {
    COP [PrintWideString] ( &widestring_08B033 )
    RTL 
}

widestring_08B033 `[TPL:E]この女たちは じゅうたんを[N]織っているのさ.[FIN]これは 織り上がるまでに なんと[N]40年近い さい月が かかる.[FIN]子供のころから その作業を始め[N]遊ぶヒマもなく 働き続け[N]完成時には 中年を過ぎている女.[FIN]ぼうず 覚えておくんだな.[N]こんな 運命の下に 生まれる人も[N]いるってことを.[END]`

actor_def_08B0E1 [
  actor-def < #26, #00, #18, {

  code_08B0E4:
    LDA #$0200
    TSB $12
    LDA $0E
    AND #$0010
    STA $26
    JSL $@chunk_068000.code_06B7AB
    LDA $26
    BEQ loc_08B0FF
    LDA $0E
    ORA #$4000
    STA $0E

  loc_08B0FF:
    COP [SetOnInteract] ( &code_08B119 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RngByte]
    AND #$001F
    STA $08
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B119 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08B124 )
}

code_list_08B124 [
  &code_08B12C   ;00
  &code_08B131   ;01
  &code_08B136   ;02
  &code_08B13B   ;03
]

code_08B12C {
    COP [PrintWideString] ( &widestring_08B140 )
    RTL 
}

code_08B131 {
    COP [PrintWideString] ( &widestring_08B170 )
    RTL 
}

code_08B136 {
    COP [PrintWideString] ( &widestring_08B1A0 )
    RTL 
}

code_08B13B {
    COP [PrintWideString] ( &widestring_08B1D0 )
    RTL 
}

widestring_08B140 `[TPL:E][TPL:0]どうやら 言葉が 通じないようだ.[N]ただ もくもくと作業を続けている.[PAL:0][END]`

widestring_08B170 `[TPL:E][TPL:0]どうやら 言葉が 通じないようだ.[N]ただ もくもくと作業を続けている.[PAL:0][END]`

widestring_08B1A0 `[TPL:E][TPL:0]どうやら 言葉が 通じないようだ.[N]ただ もくもくと作業を続けている.[PAL:0][END]`

widestring_08B1D0 `[TPL:E][TPL:0]どうやら 言葉が 通じないようだ.[N]ただ もくもくと作業を続けている.[PAL:0][END]`

widestring_08B200 `がが ぐ[DLG:AD,BE]じ[8D][END]`

widestring_08B20A `じ[AD]VがIがぐ[F0]ご[EE][XXX]じぅ[SKP:C4]じぅ`

actor_def_08B21B [
  actor-def < #00, #00, #30, {

  code_08B21E:
    LDA #$0000
    STA $24
    LDA $0E
    STA $26
    BEQ loc_08B232
    COP [BranchIfFlagWord] ( #$0171, #01, &code_08B2EF )
    BRA loc_08B239

  loc_08B232:
    COP [BranchIfFlagWord] ( #$0170, #01, &code_08B2EF )

  loc_08B239:
    COP [SetEntryContinue]
    PHX 
    LDX $decelStepCounter
    LDA $7F0008, X
    AND #$00FF
    CMP #$0095
    BEQ loc_08B250
    CMP #$008E
    BNE loc_08B258

  loc_08B250:
    LDA $0028, X
    CMP #$001C
    BEQ loc_08B25A

  loc_08B258:
    PLX 
    RTL 

  loc_08B25A:
    PLX 
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08B263 )
    RTL 
} >
]

code_08B263 {
    LDA $24
    BNE loc_08B2A0
    INC $24
    LDA $14
    STA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $14
    LDA $16
    STA $orbitDiameter, X
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    STA $16
    COP [DrawMetatileHere] ( #E8 )
    INC $14
    COP [DrawMetatileHere] ( #E9 )
    LDA $orbitAngle, X
    STA $14
    LDA $orbitDiameter, X
    STA $16
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08B29F )
    BRA loc_08B239
}

code_08B29F {
    RTL 

  loc_08B2A0:
    COP [PlaySoundCh1] ( #15 )
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08B2AE )
}

code_list_08B2AE [
  &code_08B2B2   ;00
  &code_08B2BD   ;01
]

code_08B2B2 {
    COP [StageBgChange] ( #70 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0170 )
    BRA loc_08B2C8
}

code_08B2BD {
    COP [StageBgChange] ( #71 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0171 )
    BRA loc_08B2C8

  loc_08B2C8:
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$82
    STA $0002, Y
    REP #$20
    LDA #$D271
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
}

code_08B2EF {
    COP [Die]
}

actor_def_08B2F1 [
  actor-def < #00, #00, #23, {

  code_08B2F4:
    LDA $0E
    JSL $@chunk_008000.code_00B5A4
    BCS loc_08B307
    COP [SetEntryContinue]
    LDA $0E
    JSL $@chunk_008000.code_00B5A4
    BCS loc_08B307
    RTL 

  loc_08B307:
    COP [SpawnAfterFlags] ( @code_08D1C3, #$0B00 )
    LDA #$2000
    STA $000E, Y
    LDA $0E
    CMP #$0072
    BEQ loc_08B323
    LDA #$0003
    STA $0024, Y
    BRA loc_08B329

  loc_08B323:
    LDA #$0001
    STA $0024, Y

  loc_08B329:
    COP [Die]
} >
]

actor_def_08B32B [
  actor-def < #1C, #01, #10, {

  code_08B32E:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08B33A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08B33A {
    COP [PrintWideString] ( &widestring_08B396 )
    COP [DialogueOptions] ( #02, #02, &code_list_08B344 )
}

code_list_08B344 [
  &code_08B34A   ;00
  &code_08B34A   ;01
  &code_08B34F   ;02
]

code_08B34A {
    COP [PrintWideString] ( &widestring_08B3D1 )
    RTL 
}

code_08B34F {
    COP [PrintWideString] ( &widestring_08B3D1 )
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SpawnAfterFlags] ( @code_08B37D, #$1800 )
    LDA #$0303
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #CC, #$01F8, #$0130, #03, #$4400 )
    RTL 
}

code_08B37D {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [Die]
}

widestring_08B396 `[TPL:B]青い光の中には ピラミッドの入口が[N]ぼんやりと写っている···[N] やめておく[N] 中に飛びこむ`

widestring_08B3D1 `[CLD]`

actor_def_08B3D3 [
  actor-def < #1C, #00, #10, {

  code_08B3D6:
    LDA #$0100
    STA $cameraBoundsY
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #F8, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [PlaySoundBoth] ( #$1919 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D0E8, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    LDA #$0800
    TSB $10
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08B456, #$0004, #$FFF0, #$2800 )
    LDA #$0008
    STA $0026, Y
    COP [SetFlagByte] ( #03 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_08B423 [
  actor-def < #9C, #00, #10, {

  code_08B426:
    COP [StageSpriteFrame] ( #9C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #59 )
    LDA #$0800
    TSB $10
    COP [StageSpriteFrame] ( #9D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08B456, #$FFFC, #$FFF0, #$2800 )
    LDA #$FFF8
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
} >
]

code_08B456 {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterFlags] ( @code_08B48A, #$0B02 )
    COP [WaitByte] ( #03 )
    LDA $14
    CLC 
    ADC $26
    STA $14
    COP [LoopNext]
    COP [Die]

  code_08B46E:
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0020
    CLC 
    ADC $16
    STA $16
}

code_08B48A {
    COP [PlaySoundBoth] ( #$0505 )
    COP [AddPosition] ( #00, #FC )
    COP [StageSpriteLoop] ( #11, #02 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #04 )
    COP [StageSpriteLoop] ( #12, #10 )
    COP [AnimLoop]
    COP [Die]
}

actor_def_08B4A4 [
  actor-def < #0B, #00, #30, {

  code_08B4A7:
    COP [SetFlagByte] ( #0E )
    COP [ExitIfFlagByte] ( #C2, #01 )
    COP [ExitIfFlagByte] ( #C3, #01 )
    COP [ExitIfFlagByte] ( #C4, #01 )
    COP [ExitIfFlagByte] ( #C5, #01 )
    COP [ExitIfFlagByte] ( #C6, #01 )
    COP [ExitIfFlagByte] ( #C7, #01 )
    COP [BranchIfFlagByte] ( #BB, #01, &code_08B672 )
    COP [ClearFlagByte] ( #0E )
    COP [SetFlagByte] ( #0F )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #05, #09, #0A, #0B, &code_08B4D9 )
    RTL 
} >
]

code_08B4D9 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SolidHighAbs] ( #06, #0C )
    COP [SolidHighAbs] ( #07, #0C )
    COP [SolidHighAbs] ( #08, #0C )
    COP [SolidHighAbs] ( #09, #09 )
    COP [SolidHighAbs] ( #09, #0A )
    COP [PrintWideString] ( &widestring_08B697 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #03, #09, #04, #0D, &code_08B519 )
    COP [BranchIfButton] ( #$0501, &code_08B514 )
    RTL 
}

code_08B514 {
    COP [PrintWideString] ( &widestring_08B6B8 )
    RTL 
}

code_08B519 {
    COP [ClearLowAbs] ( #06, #0C )
    COP [ClearLowAbs] ( #07, #0C )
    COP [ClearLowAbs] ( #08, #0C )
    COP [ClearLowAbs] ( #09, #09 )
    COP [ClearLowAbs] ( #09, #0A )
    COP [SolidHighAbs] ( #05, #09 )
    COP [SolidHighAbs] ( #05, #0A )
    COP [PrintWideString] ( &widestring_08B6D8 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #0E, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08B6F9 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08B8B6 )
    LDA $characterForm
    BEQ loc_08B5A7
    CMP #$0001
    BEQ loc_08B592
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    BRA loc_08B5A7

  loc_08B592:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_08B5A7:
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$000F
    STA $musicParentActor
    COP [SetFlagByte] ( #0E )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #03, #01, &code_08B5DC )
    COP [BranchIfFlagByte] ( #0D, #01, &code_08B5D6 )
    LDY $decelStepCounter
    LDA $0014, Y
    CMP #$0048
    BEQ loc_08B5D0
    RTL 

  loc_08B5D0:
    COP [BranchIfButton] ( #$0101, &code_08B5D7 )
}

code_08B5D6 {
    RTL 
}

code_08B5D7 {
    COP [PrintWideString] ( &widestring_08B915 )
    RTL 
}

code_08B5DC {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearFlagByte] ( #0E )
    COP [WaitByte] ( #1D )
    COP [LoopInit] ( #0C )
    COP [SpawnAfterFlags] ( @code_08B46E, #$0B02 )
    COP [WaitByte] ( #09 )
    COP [LoopNext]
    LDA #$0800
    TSB $10
    COP [StageSprAndHitbox] ( #13 )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterFlags] ( @code_08B68A, #$2000 )
    COP [SetFlagByte] ( #04 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #13, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteMoveX] ( #14, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #16, #B4 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteMoveX] ( #17, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteMoveX] ( #18, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteLoop] ( #19, #40 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #78 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #11 )
    COP [WaitByte] ( #B3 )
    COP [ClearLowAbs] ( #05, #09 )
    COP [ClearLowAbs] ( #05, #0A )
    COP [SetFlagByte] ( #06 )
    COP [SetFlagByte] ( #BB )
    COP [ClearFlagByte] ( #0F )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_08B672 {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #09, #0B )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_08B68A {
    COP [PrintWideString] ( &widestring_08B949 )
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_08B971 )
    COP [Die]
}

widestring_08B697 `[TPL:9][TPL:4]おとなしく そこから[N]左へ向かって 歩けっ!![PAL:0][END]`

widestring_08B6B8 `[TPL:9][TPL:4]左へ向かって 歩けと[N]言っているんだっ!![PAL:0][END]`

widestring_08B6D8 `[TPL:9][TPL:4]ようし それでいい.[N]そのまま じっとしていろっ!![PAL:0][END]`

widestring_08B6F9 `[TPL:A][TPL:4]ブラックパンサー:[N]お前さんの 行動の ー部始終を[N]見せてもらったよ.[FIN]何千年も前に すい星の光を 使った[N]バイオ技術が あったと聞くが···[N]まさか お前が そうだとはな.[FIN]その 変身の力を もてば[N]どんなものでも 手に入る. そして[N]どんな人間でも ひれふすだろう.[FIN]エドワード国王が やっきになって[N]動くのも 無理はない···[FIN][TPL:1]カレン:[N]お父さまが そんなことを?![FIN][TPL:4]ブラックパンサー:[N]そうだ! 国王なんて しょせん[N]そんなもんさ.[FIN]力を 手に入れる ためには[N]手段を えらばない.[FIN]ひょっとすると おれのような[N]殺し屋よりも ざんこくかもな.[N]くっくっく.[FIN][TPL:1]カレン:[N]やめてよっ! そんな話!![FIN][TPL:4]ブラックパンサー:[N]まあ どちらにしろ おれは[N]金がもらえれば それでいいのさ.[FIN]さあ いっしょに エドワード城まで[N]きてもらおうか.[PAL:0][END]`

widestring_08B8B6 `[TPL:A][TPL:0]テムの頭の中で 声がささやく···[FIN]テム···[N]笛を 吹くんだ·· テム···[PAL:0][END]`

widestring_08B8EF `[TPL:A][TPL:4]ブラックパンサー:[N]ふっ とうとう 観念したか···[N][PAL:0][END]`

widestring_08B915 `[TPL:A][TPL:4]ブラックパンサー:[N]それ以上 前へ出ると このナイフが[N]動きだすぜ···[PAL:0][END]`

widestring_08B949 `[TPL:9][TPL:4][DLY:0]ブラックパンサー:[N]うおああああああああ!!!!!![PAU:3C][PAL:0][CLD]`

widestring_08B971 `[TPL:8][TPL:4][DLY:3]カレン··· カレ····[PAU:3C][PAL:0][CLD]`

actor_def_08B98E [
  actor-def < #03, #00, #30, {

  code_08B991:
    COP [BranchIfFlagByte] ( #D0, #01, &code_08BA6B )
    COP [ExitIfFlagByte] ( #C2, #01 )
    COP [ExitIfFlagByte] ( #C3, #01 )
    COP [ExitIfFlagByte] ( #C4, #01 )
    COP [ExitIfFlagByte] ( #C5, #01 )
    COP [ExitIfFlagByte] ( #C6, #01 )
    COP [ExitIfFlagByte] ( #C7, #01 )
    COP [BranchIfFlagByte] ( #BB, #01, &code_08BA6D )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$0800
    TSB $10
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #09, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [WaitByte] ( #0F )
    COP [LoopInit] ( #06 )
    COP [StageSpriteMoveX] ( #09, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    CLC 
    ADC #$000A
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BAC4 )
    COP [WaitByte] ( #3B )
    LDA #$0068
    STA $moveXAlt, X
    LDA #$00B0
    STA $moveYAlt, X
    COP [MoveToward] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BB03 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_08BABF )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08BA6B {
    COP [Die]
}

code_08BA6D {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #08, #0B )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08BABF )
    COP [ExitIfFlagByte] ( #FC, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BC10 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_08BD27 )
    COP [SetFlagByte] ( #D0 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #C8, #$0070, #$00A0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_08BABF {
    COP [PrintWideString] ( &widestring_08BBD6 )
    RTL 
}

widestring_08BAC4 `[TPL:9][TPL:1][DLY:2]カレン:[N]テム····[FIN]なんで みんな[N]殺しあわなくちゃならないの··?[FIN]あたし···[N]もう···[PAL:0][END]`

widestring_08BB03 `[TPL:A][TPL:1]カレン:[N]ごめんなさい···[N]とりみだしちゃって···[FIN]テムは 世界を 救うために[N]がんばって いるんだもんね.[FIN]最初 旅にでたときは お父さんを[N]さがしにいくはずだったのに···[FIN]何だか たいへんなことに[N]なって きちゃったわよね···[FIN]でも あたし.[N]この旅に ついてきたことを[N]こうかい してないよ.[FIN]さあ 行ってきて.[N]5つ目の ミステリードールを[N]さがしに····[PAL:0][END]`

widestring_08BBD6 `[TPL:A][TPL:1]さっきの テムの吹いた メロディが[N]ブラックパンサーの そう送曲に[N]なったのね···[PAL:0][END]`

widestring_08BC10 `[TPL:A]笛から 声が 聞こえてきた![N]エドワード城のろうやで 聞いた声と[N]同じだった···[FIN][TPL:4]笛:[N]これまで よく がんばったね.[N]テム.[FIN][TPL:0]テム:[N]とうさん?![FIN][TPL:4]笛:[N]私は 今 バベルの塔にいる.[N]5つの ミステリードールを もって[N]バベルの塔へ きなさい.[FIN]お前が これまで 集めてきた人形は[N]人類存亡の カギを にぎっている.[FIN]すい星が 近づいている···[N]テム·· はやく はや·く···[FIN][PAL:0][SFX:0]やがて 笛の声は 遠くなってゆき[N]聞こえなくなった···[PAL:0][END]`

widestring_08BD27 `[TPL:B][TPL:1]カレン:[N]あたしたちの 知らないところで[N]何か たいへんなことが[N]起きている みたいね····[FIN][TPL:0]テム: どうしよう···[N]いきなり バベルの塔へ こいって[N]いわれても あそこは 大海原の[N]小さい島だし···[FIN][TPL:1]カレン:[N]ニールってね また 飛行機を[N]作ったんですって.[FIN]さばくの町へは 飛行機で きてる[N]みたいなの.[N]まずは 町へ もどってみましょ.[PAL:0][END]`

actor_def_08BDFC [
  actor-def < #1F, #00, #10, {

  code_08BDFF:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08BE53 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C2, #01, &code_08BE4F )
    COP [BranchIfFlagByte] ( #C3, #01, &code_08BE4F )
    COP [BranchIfFlagByte] ( #C4, #01, &code_08BE4F )
    COP [BranchIfFlagByte] ( #C5, #01, &code_08BE4F )
    COP [BranchIfFlagByte] ( #C6, #01, &code_08BE4F )
    COP [BranchIfFlagByte] ( #C7, #01, &code_08BE4F )
    COP [BranchIfNoItem] ( #1E, &code_08BE4F )
    COP [BranchIfNoItem] ( #1F, &code_08BE4F )
    COP [BranchIfNoItem] ( #20, &code_08BE4F )
    COP [BranchIfNoItem] ( #21, &code_08BE4F )
    COP [BranchIfNoItem] ( #22, &code_08BE4F )
    COP [BranchIfNoItem] ( #23, &code_08BE4F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08BE4F {
    COP [ClearLowHere]
    COP [Die]
}

code_08BE53 {
    COP [PrintWideString] ( &widestring_08BE58 )
    RTL 
}

widestring_08BE58 `[DEF]探険家:[N]遺跡には 人の進入をこばもうとする[N]トラップが 点在する.[FIN]この部屋には 音に反応するしかけが[N]あるという話だ···[N]まちがっても 大きな音をたてるな.[END]`

actor_def_08BEBF [
  actor-def < #0F, #01, #01, {

  code_08BEC2:
    LDA #$0031
    TSB $12
    COP [ClearHighAbs] ( #34, #2B )
    COP [ClearHighAbs] ( #35, #2B )
    COP [ClearHighAbs] ( #36, #2B )
    COP [ClearHighAbs] ( #37, #2B )
    COP [ClearHighAbs] ( #38, #2B )
    COP [ClearHighAbs] ( #39, #2B )
    COP [ClearHighAbs] ( #34, #2C )
    COP [ClearHighAbs] ( #35, #2C )
    COP [ClearHighAbs] ( #36, #2C )
    COP [ClearHighAbs] ( #37, #2C )
    COP [ClearHighAbs] ( #38, #2C )
    COP [ClearHighAbs] ( #39, #2C )
    LDY #$1060
    LDA #$FE00
    STA $0026, Y
    LDA #$ACF0
    STA $statsPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighAbs] ( #34, #2B )
    COP [SolidHighAbs] ( #35, #2B )
    COP [SolidHighAbs] ( #36, #2B )
    COP [SolidHighAbs] ( #37, #2B )
    COP [SolidHighAbs] ( #38, #2B )
    COP [SolidHighAbs] ( #39, #2B )
    COP [SolidHighAbs] ( #34, #2C )
    COP [SolidHighAbs] ( #35, #2C )
    COP [SolidHighAbs] ( #36, #2C )
    COP [SolidHighAbs] ( #37, #2C )
    COP [SolidHighAbs] ( #38, #2C )
    COP [SolidHighAbs] ( #39, #2C )

  code_08BF43:
    COP [SetHitCallback] ( &code_08BF51 )
    COP [SetEntryContinue]
    LDA #$7FFF
    STA $currentHp, X
    RTL 
} >
]

code_08BF51 {
    COP [BranchIfFlagByte] ( #0F, #00, &code_08BF5C )
    COP [SetEntryExitNow] ( @code_08BF43 )
}

code_08BF5C {
    COP [SetFlagByte] ( #0F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [SolidHighAbs] ( #34, #4B )
    COP [SolidHighAbs] ( #35, #4B )
    COP [SolidHighAbs] ( #36, #4B )
    COP [SolidHighAbs] ( #37, #4B )
    COP [SolidHighAbs] ( #38, #4B )
    COP [SolidHighAbs] ( #39, #4B )
    COP [SolidHighAbs] ( #34, #4C )
    COP [SolidHighAbs] ( #35, #4C )
    COP [SolidHighAbs] ( #36, #4C )
    COP [SolidHighAbs] ( #37, #4C )
    COP [SolidHighAbs] ( #38, #4C )
    COP [SolidHighAbs] ( #39, #4C )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    BEQ loc_08BFA3
    INC 
    STA $0026, Y
    RTL 

  loc_08BFA3:
    COP [ClearLowAbs] ( #34, #2B )
    COP [ClearLowAbs] ( #35, #2B )
    COP [ClearLowAbs] ( #36, #2B )
    COP [ClearLowAbs] ( #37, #2B )
    COP [ClearLowAbs] ( #38, #2B )
    COP [ClearLowAbs] ( #39, #2B )
    COP [ClearLowAbs] ( #34, #2C )
    COP [ClearLowAbs] ( #35, #2C )
    COP [ClearLowAbs] ( #36, #2C )
    COP [ClearLowAbs] ( #37, #2C )
    COP [ClearLowAbs] ( #38, #2C )
    COP [ClearLowAbs] ( #39, #2C )
    COP [PlaySoundBoth] ( #$1515 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    JMP $&code_08BF43
}

actor_def_08BFE2 [
  actor-def < #0F, #01, #01, {

  code_08BFE5:
    LDA #$0031
    TSB $12
    COP [ClearHighAbs] ( #34, #4B )
    COP [ClearHighAbs] ( #35, #4B )
    COP [ClearHighAbs] ( #36, #4B )
    COP [ClearHighAbs] ( #37, #4B )
    COP [ClearHighAbs] ( #38, #4B )
    COP [ClearHighAbs] ( #39, #4B )
    COP [ClearHighAbs] ( #34, #4C )
    COP [ClearHighAbs] ( #35, #4C )
    COP [ClearHighAbs] ( #36, #4C )
    COP [ClearHighAbs] ( #37, #4C )
    COP [ClearHighAbs] ( #38, #4C )
    COP [ClearHighAbs] ( #39, #4C )
    LDA #$ACF0
    STA $statsPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  code_08C02D:
    COP [SetHitCallback] ( &code_08C03B )
    COP [SetEntryContinue]
    LDA #$7FFF
    STA $currentHp, X
    RTL 
} >
]

code_08C03B {
    COP [BranchIfFlagByte] ( #0F, #00, &code_08C046 )
    COP [SetEntryExitNow] ( @code_08C02D )
}

code_08C046 {
    COP [SetFlagByte] ( #0F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [SolidHighAbs] ( #34, #2B )
    COP [SolidHighAbs] ( #35, #2B )
    COP [SolidHighAbs] ( #36, #2B )
    COP [SolidHighAbs] ( #37, #2B )
    COP [SolidHighAbs] ( #38, #2B )
    COP [SolidHighAbs] ( #39, #2B )
    COP [SolidHighAbs] ( #34, #2C )
    COP [SolidHighAbs] ( #35, #2C )
    COP [SolidHighAbs] ( #36, #2C )
    COP [SolidHighAbs] ( #37, #2C )
    COP [SolidHighAbs] ( #38, #2C )
    COP [SolidHighAbs] ( #39, #2C )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    CMP #$FE00
    BEQ loc_08C090
    DEC 
    STA $0026, Y
    RTL 

  loc_08C090:
    COP [ClearLowAbs] ( #34, #4B )
    COP [ClearLowAbs] ( #35, #4B )
    COP [ClearLowAbs] ( #36, #4B )
    COP [ClearLowAbs] ( #37, #4B )
    COP [ClearLowAbs] ( #38, #4B )
    COP [ClearLowAbs] ( #39, #4B )
    COP [ClearLowAbs] ( #34, #4C )
    COP [ClearLowAbs] ( #35, #4C )
    COP [ClearLowAbs] ( #36, #4C )
    COP [ClearLowAbs] ( #37, #4C )
    COP [ClearLowAbs] ( #38, #4C )
    COP [ClearLowAbs] ( #39, #4C )
    COP [PlaySoundBoth] ( #$1515 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    JMP $&code_08C02D
}

actor_def_08C0CF [
  actor-def < #1D, #01, #03, {

  code_08C0D2:
    LDA #$0001
    STA $24

  code_08C0D7:
    COP [BranchIfPlayerAt] ( #$0378, #$04A0, &code_08C0E1 )
    BRA loc_08C0E9
} >
]

code_08C0E1 {
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_08C0E9:
    COP [AddPosition] ( #00, #FE )
    LDA $0E
    XBA 
    STA $orbitAngle, X
    LDA #$2000
    STA $0E
    JSL $@chunk_0B8000.code_0BD922

  loc_08C0FD:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08C10A )
    RTL 
}

code_08C10A {
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2C2C )
    JSR $&code_08C16F
    COP [CallScript] ( &code_08C12E )
    COP [SetEntryExit]
    JSL $@chunk_0B8000.code_0BD922
    COP [PlaySoundBoth] ( #$1515 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08C12D )
    BRA loc_08C0FD
}

code_08C12D {
    RTL 
}

code_08C12E {
    LDA $orbitAngle, X
    STA $26
    LDA $24
    BPL loc_08C149
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    DEC 
    STA $0026, Y
    DEC $26
    BEQ loc_08C15A
    RTL 

  loc_08C149:
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    INC 
    STA $0026, Y
    DEC $26
    BEQ loc_08C15A
    RTL 

  loc_08C15A:
    LDA $24
    EOR #$FFFF
    INC 
    STA $24
    COP [RestoreSavedPtr]
}

actor_def_08C164 [
  actor-def < #1D, #01, #03, {

  code_08C167:
    LDA #$FFFF
    STA $24
    JMP $&code_08C0D7
} >
]

code_08C16F {
    PHX 
    PHP 
    SEP #$20
    LDX #$0000
    LDA $0697
    DEC 
    STA $000E

  loc_08C17D:
    LDY #$000F

  loc_08C180:
    LDA #$0F
    STA $7FC103, X
    STA $7FC20C, X
    REP #$20
    TXA 
    CLC 
    ADC #$0010
    TAX 
    SEP #$20
    DEY 
    BPL loc_08C180
    DEC $000E
    BMI loc_08C1AC
    REP #$20
    TXA 
    CLC 
    ADC $mapBoundsX
    CLC 
    ADC #$FF00
    TAX 
    SEP #$20
    BRA loc_08C17D

  loc_08C1AC:
    PLP 
    PLX 
    RTS 
}

actor_def_08C1AF [
  actor-def < #00, #00, #30, {

  code_08C1B2:
    COP [SpawnAfterFlags] ( @code_08C1EC, #$2000 )

  loc_08C1B9:
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    CMP #$0060
    BEQ loc_08C1CE
    INC 
    STA $0026, Y
    RTL 

  loc_08C1CE:
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    BEQ loc_08C1E0
    DEC 
    STA $0026, Y
    RTL 

  loc_08C1E0:
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D149, #$2000 )
    BRA loc_08C1B9
} >
]

code_08C1EC {
    PHX 
    LDY $decelStepCounter
    LDA $0014, Y
    STA $0000
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $0002
    LDY #$1060
    LDA $0026, Y
    CLC 
    ADC $0002
    STA $0002
    LDX #$0000

  code_08C210:
    LDA $@code_08C2A1, X
    AND #$00FF
    CMP #$00FF
    BNE loc_08C21F
    JMP $&code_08C29F

  loc_08C21F:
    CMP $sceneCurrent
    BNE code_08C296
    LDA $@code_08C2A1+1, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCS code_08C296
    LDA $@code_08C2A1+2, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0002
    BCS code_08C296
    LDA $@code_08C2A1+3, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCC code_08C296
    LDA $@code_08C2A1+4, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0008
    CMP $0002
    BCC code_08C296
    TXA 
    TYX 
    TAY 
    PLX 
    PHY 
    COP [SpawnAfterFlags] ( @code_08C27C, #$0200 )
    PLY 
    PHX 
    TXA 
    TYX 
    TAY 
    JMP $&code_08C296
}

code_08C27C {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #00 )
    COP [WaitByte] ( #01 )
    COP [Die]
}

code_08C296 {
    TXA 
    CLC 
    ADC #$0005
    TAX 
    JMP $&code_08C210
}

code_08C29F {
    PLX 
    RTL 
}

code_08C2A1 {
    CMP $0120, Y
    PLP 
    ORA $30D9
    ORA ($38, X)
    TSB $40D9
    ORA ($44, X)
    ORA $50D9
    ORA ($5E, X)
    ORA $66D9
    ORA ($6A, X)
    ORA $1CDB
    ORA ($38, X)
    ORA $40DB
    ORA ($48, X)
    ORA $50DB
    ORA ($60, X)
    ORA ($DB), Y
    ROR $01
    JMP ($&code_08FF0F)
}

actor_def_08C2CF [
  actor-def < #00, #00, #30, {

  code_08C2D2:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #1B )
    COP [AddPosition] ( #08, #00 )
    LDA $24
    JSL $@chunk_008000.code_00B565
    BCC loc_08C2F2
    JMP $&code_08C34F

  loc_08C2F2:
    COP [SetEntryContinue]
    PHX 
    LDX $decelStepCounter
    LDA $7F0008, X
    AND #$00FF
    CMP #$0097
    BNE loc_08C30C
    LDA $0028, X
    CMP #$0001
    BEQ loc_08C30E

  loc_08C30C:
    PLX 
    RTL 

  loc_08C30E:
    PLX 
    LDA $characterForm
    CMP #$0001
    BEQ loc_08C318
    RTL 

  loc_08C318:
    COP [BranchIfPlayerNear] ( #0C, &code_08C31E )
    RTL 
} >
]

code_08C31E {
    LDA $24
    JSL $@chunk_008000.code_00B56C
    COP [WaitByte] ( #B3 )
    COP [RngByte]
    STA $08
    COP [SetEntryExit]
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [CollPrioritySetMax]
    COP [StageSpriteLoopMoveY] ( #1B, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [CollPriorityClearMax]
    COP [StageSpriteMoveY] ( #1B, #35 )
    COP [AnimOnce]
}

code_08C34F {
    LDA #$3000
    TRB $10
    LDA #$0300
    TSB $10
    COP [CollPrioritySetMin]
    COP [ClearAllHere]
    COP [SetEntryContinue]
    RTL 
}

actor_def_08C360 [
  actor-def < #00, #00, #30, {

  code_08C363:
    LDA #$0100
    STA $cameraBoundsY
    COP [BranchIfFlagByte] ( #C2, #01, &code_08C380 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C387 )
    COP [ExitIfFlagByte] ( #C2, #01 )
} >
]

code_08C380 {
    COP [StageBgChange] ( #94 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C387 {
    COP [BranchIfFlagByte] ( #C2, #01, &code_08C3A5 )
    COP [PrintWideString] ( &widestring_08C3AA )
    COP [GiveItem] ( #1E, &code_08C3A6 )
    COP [SetFlagByte] ( #C2 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C3A5 {
    RTL 
}

code_08C3A6 {
    JML $@chunk_008000.code_00CAD3
}

widestring_08C3AA `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

widestring_08C405 `[CLR][SFX:0][DLY:9]ヒエログリフの石版を 手に入れた![PAU:78][END]`

actor_def_08C424 [
  actor-def < #00, #00, #30, {

  code_08C427:
    COP [BranchIfFlagByte] ( #C3, #01, &code_08C43E )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C445 )
    COP [ExitIfFlagByte] ( #C3, #01 )
} >
]

code_08C43E {
    COP [StageBgChange] ( #95 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C445 {
    COP [BranchIfFlagByte] ( #C3, #01, &code_08C463 )
    COP [PrintWideString] ( &widestring_08C464 )
    COP [GiveItem] ( #1F, &code_08C3A6 )
    COP [SetFlagByte] ( #C3 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C463 {
    RTL 
}

widestring_08C464 `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

actor_def_08C4BF [
  actor-def < #00, #00, #30, {

  code_08C4C2:
    COP [BranchIfFlagByte] ( #C4, #01, &code_08C4D9 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C4E0 )
    COP [ExitIfFlagByte] ( #C4, #01 )
} >
]

code_08C4D9 {
    COP [StageBgChange] ( #96 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C4E0 {
    COP [BranchIfFlagByte] ( #C4, #01, &code_08C4FE )
    COP [PrintWideString] ( &widestring_08C4FF )
    COP [GiveItem] ( #20, &code_08C3A6 )
    COP [SetFlagByte] ( #C4 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C4FE {
    RTL 
}

widestring_08C4FF `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

actor_def_08C55A [
  actor-def < #00, #00, #30, {

  code_08C55D:
    COP [BranchIfFlagByte] ( #C5, #01, &code_08C574 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C57B )
    COP [ExitIfFlagByte] ( #C5, #01 )
} >
]

code_08C574 {
    COP [StageBgChange] ( #97 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C57B {
    COP [BranchIfFlagByte] ( #C5, #01, &code_08C599 )
    COP [PrintWideString] ( &widestring_08C59A )
    COP [GiveItem] ( #21, &code_08C3A6 )
    COP [SetFlagByte] ( #C5 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C599 {
    RTL 
}

widestring_08C59A `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

actor_def_08C5F5 [
  actor-def < #00, #00, #30, {

  code_08C5F8:
    COP [BranchIfFlagByte] ( #C6, #01, &code_08C60F )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C616 )
    COP [ExitIfFlagByte] ( #C6, #01 )
} >
]

code_08C60F {
    COP [StageBgChange] ( #98 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C616 {
    COP [BranchIfFlagByte] ( #C6, #01, &code_08C634 )
    COP [PrintWideString] ( &widestring_08C635 )
    COP [GiveItem] ( #22, &code_08C3A6 )
    COP [SetFlagByte] ( #C6 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C634 {
    RTL 
}

widestring_08C635 `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

actor_def_08C690 [
  actor-def < #00, #00, #30, {

  code_08C693:
    COP [BranchIfFlagByte] ( #C7, #01, &code_08C6AA )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C6B1 )
    COP [ExitIfFlagByte] ( #C7, #01 )
} >
]

code_08C6AA {
    COP [StageBgChange] ( #99 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C6B1 {
    COP [BranchIfFlagByte] ( #C7, #01, &code_08C6CF )
    COP [PrintWideString] ( &widestring_08C6D0 )
    COP [GiveItem] ( #23, &code_08C3A6 )
    COP [SetFlagByte] ( #C7 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08C405 )
}

code_08C6CF {
    RTL 
}

widestring_08C6D0 `[DEF][TPL:0]かべに おさめられた 石版がある.[N]これが ダオの町で 聞いた[N]ヒエログリフという 文字か··?[FIN]この石版は はずしてもっていく[N]ことにしよう.[PAL:0][FIN]`

widestring_08C72B `[84][85][86][8C][8D][8E]`

actor_def_08C731 [
  actor-def < #00, #00, #30, {

  code_08C734:
    PHX 
    LDY #$0000

  loc_08C738:
    LDA $0B28, Y
    BMI loc_08C751
    TAX 
    SEP #$20
    LDA $@widestring_08C72B, X
    PHX 
    PHA 
    TYA 
    LSR 
    TAX 
    PLA 
    STA $7EA065, X
    PLX 
    REP #$20

  loc_08C751:
    INY 
    INY 
    CPY #$000C
    BNE loc_08C738
    PLX 

  code_08C759:
    COP [BranchIfFlagByte] ( #D1, #01, &code_08C7A0 )
    COP [SetEntryContinue]
    LDY #$0000

  loc_08C764:
    LDA $0B28, Y
    BMI loc_08C772
    INY 
    INY 
    CPY #$000C
    BNE loc_08C764
    BRA loc_08C773

  loc_08C772:
    RTL 

  loc_08C773:
    LDY #$0000
    LDA #$0000

  loc_08C779:
    CMP $0B28, Y
    BNE loc_08C7A2
    INY 
    INY 
    INC 
    CMP #$0006
    BNE loc_08C779
    COP [SetFlagByte] ( #D1 )
    COP [PlaySoundBoth] ( #$0F0F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08C892 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_08C7A0 {
    COP [Die]

  loc_08C7A2:
    COP [PlaySoundCh1] ( #12 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08C85B )
    LDA $0B28
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCC loc_08C7C2
    JMP $&code_08C84E

  loc_08C7C2:
    LDA #$FFFF
    STA $0B28
    COP [DrawMetatileAbs] ( #05, #06, #87 )
    LDA $0B2A
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCS code_08C84E
    LDA #$FFFF
    STA $0B2A
    COP [DrawMetatileAbs] ( #06, #06, #87 )
    LDA $0B2C
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCS code_08C84E
    LDA #$FFFF
    STA $0B2C
    COP [DrawMetatileAbs] ( #07, #06, #87 )
    LDA $0B2E
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCS code_08C84E
    LDA #$FFFF
    STA $0B2E
    COP [DrawMetatileAbs] ( #08, #06, #87 )
    LDA $0B30
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCS code_08C84E
    LDA #$FFFF
    STA $0B30
    COP [DrawMetatileAbs] ( #09, #06, #87 )
    LDA $0B32
    CLC 
    ADC #$001E
    JSL $@chunk_3B7DD.code_03E458
    BCS code_08C84E
    LDA #$FFFF
    STA $0B32
    COP [DrawMetatileAbs] ( #0A, #06, #87 )
    LDA #$EFF0
    TRB $joypadMaskStd
    JMP $&code_08C759
}

code_08C84E {
    COP [PrintWideString] ( &widestring_08C8B4 )
    LDA #$EFF0
    TRB $joypadMaskStd
    JMP $&code_08C759
}

widestring_08C85B `[DEF]何も おこらない···[N]ならべ方を まちがえたんだろうか?[N]もうー度 最初から やってみよう.[END]`

widestring_08C892 `[DEF][TPL:0]むっ···[N]入口の向こうで 何か 音がしたぞ![PAL:0][END]`

widestring_08C8B4 `[DEF][CLR]しまった![N]持ち物が いっぱいで 全部[N]とりはずせないっ![END]`

actor_def_08C8D8 [
  actor-def < #1C, #01, #20, {

  code_08C8DB:
    COP [BranchIfFlagByte] ( #FC, #01, &code_08C8FF )
    COP [AddPosition] ( #08, #0C )
    COP [ExitIfFlagByte] ( #D1, #01 )
    LDA #$1000
    TSB $10
    LDA #$2000
    TRB $10
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08C901 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08C8FF {
    COP [Die]
}

code_08C901 {
    COP [PrintWideString] ( &widestring_08C946 )
    COP [DialogueOptions] ( #02, #02, &code_list_08C90B )
}

code_list_08C90B [
  &code_08C911   ;00
  &code_08C911   ;01
  &code_08C916   ;02
]

code_08C911 {
    COP [PrintWideString] ( &widestring_08C984 )
    RTL 
}

code_08C916 {
    COP [PrintWideString] ( &widestring_08C984 )
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SpawnAfterFlags] ( @code_08B37D, #$1800 )
    LDA #$0303
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #DD, #$00F8, #$01B0, #00, #$2200 )
    COP [SetEntryContinue]
    RTL 
}

widestring_08C946 `[DEF]青い光の中には ミイラ化した[N]ピラミッドの女王が 写っている··[N] やめておく[N] 中に飛びこむ`

widestring_08C984 `[CLD]`

actor_def_08C986 [
  actor-def < #00, #00, #30, {

  code_08C989:
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_08C991
    RTL 

  loc_08C991:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08C9D4 )
    LDA #$0004
    STA $0AAC
    LDA #$00CD
    STA $0B12
    LDA #$0007
    STA $0B08
    STA $0B0A
    LDA #$0009
    STA $0B0C
    STA $0B0E
    LDA #$0000
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    LDA #$0000
    STA $characterForm
    COP [Die]
} >
]

widestring_08C9D4 `[DEF][TPL:0]ピラミッドの 守り神を たおすと[N]しかばねから ミステリードールが[N]見つかった!![PAL:0][END]`

actor_def_08CA0A [
  actor-def < #02, #00, #10, {

  code_08CA0D:
    COP [BranchIfFlagByte] ( #E8, #01, &code_08CBFC )
    LDA $0E
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0002
    STA $28
    STZ $002A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$3000
    STA $0E
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08CA33 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08CA33 {
    COP [PrintWideString] ( &widestring_08CBFE )
    LDA $jewelsCollected
    BEQ code_08CA40
    COP [PrintWideString] ( &widestring_08CC20 )

  code_08CA40:
    COP [BranchIfFlagByte] ( #E9, #01, &code_08CA51 )
    LDA $jewelsCollected
    CMP #$0003
    BCC code_08CA51
    JMP $&code_08CB81
}

code_08CA51 {
    COP [BranchIfFlagByte] ( #EA, #01, &code_08CA62 )
    LDA $jewelsCollected
    CMP #$0005
    BCC code_08CA62
    JMP $&code_08CB94
}

code_08CA62 {
    COP [BranchIfFlagByte] ( #EB, #01, &code_08CA73 )
    LDA $jewelsCollected
    CMP #$0008
    BCC code_08CA73
    JMP $&code_08CBA1
}

code_08CA73 {
    COP [BranchIfFlagByte] ( #EC, #01, &code_08CA84 )
    LDA $jewelsCollected
    CMP #$0012
    BCC code_08CA84
    JMP $&code_08CBB4
}

code_08CA84 {
    COP [BranchIfFlagByte] ( #ED, #01, &code_08CA95 )
    LDA $jewelsCollected
    CMP #$0020
    BCC code_08CA95
    JMP $&code_08CBC1
}

code_08CA95 {
    COP [BranchIfFlagByte] ( #EE, #01, &code_08CAA6 )
    LDA $jewelsCollected
    CMP #$0030
    BCC code_08CAA6
    JMP $&code_08CBD1
}

code_08CAA6 {
    LDA $jewelsCollected
    CMP #$0050
    BCC loc_08CAB1
    JMP $&code_08CBE1

  loc_08CAB1:
    COP [PrintWideString] ( &widestring_08CC4C )

  code_08CAB5:
    COP [DialogueOptions] ( #03, #01, &code_list_08CABB )
}

code_list_08CABB [
  &code_08CAC3   ;00
  &code_08CAC3   ;01
  &code_08CAC8   ;02
  &code_08CB10   ;03
]

code_08CAC3 {
    COP [PrintWideString] ( &widestring_08CC8B )
    RTL 
}

code_08CAC8 {
    COP [BranchIfNoItem] ( #01, &code_08CAD2 )
    COP [PrintWideString] ( &widestring_08CD0F )
    RTL 
}

code_08CAD2 {
    SED 
    STZ $0000
    LDA #$0001
    SEP #$20
    LDY #$0000

  loc_08CADE:
    CMP $inventorySlots, Y
    BNE loc_08CAEE
    PHA 
    LDA $0000
    CLC 
    ADC #$01
    STA $0000
    PLA 

  loc_08CAEE:
    INY 
    CPY #$0010
    BNE loc_08CADE
    REP #$20
    LDA $0000
    CLC 
    ADC $jewelsCollected
    STA $jewelsCollected
    CLD 

  code_08CB01:
    COP [RemoveItem] ( #01 )
    COP [BranchIfNoItem] ( #01, &code_08CB01 )
    COP [PrintWideString] ( &widestring_08CD40 )
    JMP $&code_08CA40
}

code_08CB10 {
    COP [PrintWideString] ( &widestring_08CD96 )
    COP [PrintWideString] ( &widestring_08D11E )
    COP [BranchIfFlagByte] ( #E9, #00, &code_08CB22 )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB22 {
    COP [PrintWideString] ( &widestring_08D129 )
    COP [BranchIfFlagByte] ( #EA, #00, &code_08CB30 )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB30 {
    COP [PrintWideString] ( &widestring_08D13C )
    COP [BranchIfFlagByte] ( #EB, #00, &code_08CB3E )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB3E {
    COP [PrintWideString] ( &widestring_08D14F )
    COP [BranchIfFlagByte] ( #EC, #00, &code_08CB4C )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB4C {
    COP [PrintWideString] ( &widestring_08D162 )
    COP [BranchIfFlagByte] ( #ED, #00, &code_08CB5A )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB5A {
    COP [PrintWideString] ( &widestring_08D175 )
    COP [BranchIfFlagByte] ( #EE, #00, &code_08CB68 )
    COP [PrintWideString] ( &widestring_08D118 )
}

code_08CB68 {
    COP [PrintWideString] ( &widestring_08D187 )
    COP [PrintWideString] ( &widestring_08D199 )
    COP [PrintWideString] ( &widestring_08CC47 )
    JMP $&code_08CAB5
}

code_08CB77 {
    COP [PrintWideString] ( &widestring_08CDC5 )
    RTL 
}

code_08CB7C {
    COP [PrintWideString] ( &widestring_08CDD9 )
    RTL 
}

code_08CB81 {
    COP [PrintWideString] ( &widestring_08CDFE )
    COP [GiveItem] ( #06, &code_08CB7C )
    COP [PrintWideString] ( &widestring_08CE39 )
    COP [SetFlagByte] ( #E9 )
    JMP $&code_08CA51
}

code_08CB94 {
    INC $playerDef
    COP [SetFlagByte] ( #EA )
    COP [PrintWideString] ( &widestring_08CE4E )
    JMP $&code_08CA62
}

code_08CBA1 {
    INC $playerMaxHp
    LDA #$0001
    STA $damageFlashTimer
    COP [SetFlagByte] ( #EB )
    COP [PrintWideString] ( &widestring_08CEB0 )
    JMP $&code_08CA73
}

code_08CBB4 {
    INC $playerStr
    COP [SetFlagByte] ( #EC )
    COP [PrintWideString] ( &widestring_08CF0F )
    JMP $&code_08CA84
}

code_08CBC1 {
    LDA #$0001
    STA $0B16
    COP [SetFlagByte] ( #ED )
    COP [PrintWideString] ( &widestring_08CF71 )
    JMP $&code_08CA95
}

code_08CBD1 {
    LDA #$0002
    STA $0B1C
    COP [SetFlagByte] ( #EE )
    COP [PrintWideString] ( &widestring_08CFFC )
    JMP $&code_08CAA6
}

code_08CBE1 {
    COP [PrintWideString] ( &widestring_08D0C4 )
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E9, #$0330, #$03D0, #80, #$4400 )
    RTL 
}

code_08CBFC {
    COP [Die]
}

widestring_08CBFE `[DEF]私は 7つの海を またにかける[N]宝石商 ジェム.[FIN]`

widestring_08CC20 `君からは 今 [BCD:2,AB0]コの[N]赤い宝石を あずかっているよ.[FIN]`

widestring_08CC47 `[DEF][DLY:1][PAL:0]`

widestring_08CC4C `[CLR]今日は 何の用かな?[N][DLY:0] ふと 顔がみたくなった[N] 赤い宝石をあずけたい[N] 品物リストを見たい`

widestring_08CC8B `[CLR]そうかい.[N]それは ごきげんよう.[FIN]ちなみに 宝石を かかげると[N]私のところへ 飛んでくることに[N]なっているからね.[FIN]そして 何をかくそう.[N]私は へんそうの 名人なのだ.[N]他の町でも 会うだろうが[N]君は 気づかないかも知れないよ.[END]`

widestring_08CD0F `[CLR]でも 君は 宝石を もっていない.[N]その 気持ちだけ あずからせて[N]もらうとしよう.[END]`

widestring_08CD40 `[CLR]うーん···[N]これは 実に いい 宝石だね.[N]大切に あずからせてもらうよ.[FIN]これで 宝石の数は 全部で[N][BCD:2,AB0]コに なったわけだな.[FIN]`

widestring_08CD96 `[CLR]リストに 書かれた数だけ[N]宝石を 集めたとき その品物を[N]あげるからね.[END]`

widestring_08CDC5 `[CLD][DEF][CLR]では また.[N]きっと どこかで.[END]`

widestring_08CDD9 `[CLR]ありゃ もちものが いっぱい[N]みたいだ···[N]また 来てくれよなっ![END]`

widestring_08CDFE `[CLR]おっと 集めた宝石が 3コを[N]越えているじゃないかっ![N]リストの通り 藥草をあげなくては.[FIN]`

widestring_08CE39 `宝石商から 藥草をもらった![FIN]`

widestring_08CE4E `[CLR]おっと 集めた宝石が 5コを[N]越えているじゃないかっ![N]リストの通り 守りのフォースを[N]あげることにしよう.[FIN]これで 君の ぼうぎょ力は[N]ーつ 上がるはずだ.[FIN]`

widestring_08CEB0 `[CLR]おっと 集めた宝石が 8コを[N]越えているじゃないかっ![N]リストの通り 命のフォースを[N]あげることにしよう.[FIN]これで 君の 体力は[N]ーつ 上がるはずだ.[FIN]`

widestring_08CF0F `[CLR]おっと 集めた宝石が 12コを[N]越えているじゃないかっ![N]リストの通り 力のフォースを[N]あげることにしよう.[FIN]これで 君の こうげき力は[N]ーつ 上がるはずだ.[FIN]`

widestring_08CF71 `[CLR]おっと 集めた宝石が 20コを[N]越えているじゃないかっ![N]リストの通り サイコパワーを[N]あげることにしよう.[FIN]これは 私が たましいから[N]さずかった 世にも不思議な力.[FIN]何でも サイコダッシュの[N]こうげき力が 上がるらしいのだ.[FIN]`

widestring_08CFFC `[CLR]おっと 集めた宝石が 30コを[N]越えているじゃないかっ![N]リストの通り ダークパワーを[N]あげることにしよう.[FIN]これは 私が たましいから[N]さずかった 世にも不思議な力.[FIN]何でも ダークフライヤーの[N]パワーが 上がるらしいのだ.[FIN]自分の放った ダークフライヤーが[N]飛んでいる間に もうー度[N]こうげきボタンを おして[N]みるといい.[FIN]`

widestring_08D0C4 `[CLR]50コ····[N]ついに 赤い宝石が 50コ[N]集まったのか···[FIN]いよいよ 私の秘密を 話すときが[N]来たようだな.[FIN]さあ ついておいでっ!![END]`

widestring_08D118 `[PAL:4]`

widestring_08D11B `[PAL:0]`

widestring_08D11E `[DLG:3,B][SIZ:8,7,0][CLR][SFX:0]`

widestring_08D129 `[DLY:0][CLR]藥草       3[N][PAL:0]`

widestring_08D13C `[DLY:0]守りのフォース  5[N][PAL:0]`

widestring_08D14F `[DLY:0]命のフォース   8[N][PAL:0]`

widestring_08D162 `[DLY:0]力のフォース  12[N][PAL:0]`

widestring_08D175 `[DLY:0]サイコパワー  20[N][PAL:0]`

widestring_08D187 `[DLY:0]ダークパワー  30[N][PAL:0]`

widestring_08D199 `[DLY:0]私の秘密    50[END]`

actor_def_08D1A9 [
  actor-def < #24, #00, #0B, {

  code_08D1AC:
    LDA $0E
    STA $24
    LDA #$3000
    STA $0E
    BRA code_08D1C3
} >
]

actor_def_08D1B7 [
  actor-def < #24, #00, #0B, {

  code_08D1BA:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
} >
]

code_08D1C3 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #24 )
    COP [SolidHighHere]
    LDA #$0B00
    TSB $10
    COP [OrActorFlags] ( #$0200 )
    COP [SpawnAfterFlags] ( @code_08D217, #$2B00 )
    LDA $24
    STA $0024, Y

  loc_08D1E2:
    COP [StageSprAndHitbox] ( #24 )

  loc_08D1E5:
    COP [BranchIfPlayerNear] ( #05, &code_08D1F2 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D1E5
}

code_08D1F2 {
    LDA $10
    BIT #$4000
    BNE loc_08D1F9

  loc_08D1F9:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #20 )

  loc_08D201:
    COP [BranchIfPlayerNear] ( #05, &code_08D208 )
    BRA loc_08D210
}

code_08D208 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D201

  loc_08D210:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    BRA loc_08D1E2
}

code_08D217 {
    COP [SetEntryContinue]
    NOP 
    NOP 
    LDA $09FA
    BIT #$0080
    BEQ loc_08D224
    RTL 

  loc_08D224:
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #01, &code_08D22D )
    RTL 
}

code_08D22D {
    COP [BranchIfButton] ( #$0801, &code_08D234 )
    RTL 
}

code_08D234 {
    LDA #$CFF0
    TSB $joypadMaskStd
    PHX 
    LDX $decelStepCounter
    LDA $0010, X
    ORA #$2000
    STA $0010, X
    LDA $0014, X
    STA $14
    LDA $0016, X
    STA $16
    PLX 
    COP [PlaySoundBoth] ( #$0C0C )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    PHX 
    LDX $decelStepCounter
    LDY $04
    LDA $0014, Y
    STA $0014, X
    SEC 
    SBC #$0008
    STA $playerWallType
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerSpeedNs
    LDA $0016, Y
    STA $0016, X
    SEC 
    SBC #$0010
    STA $playerSpeedEw
    LSR 
    LSR 
    LSR 
    LSR 
    STA $slopeStepCounter
    PLX 
    LDA #$0101
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    LDA #$0200
    TSB $layerPriorityFlag
    LDA $24
    STA $0AAC
    COP [SetEntryContinue]
    RTL 
}

actor_def_08D2AC [
  actor-def < #00, #00, #23, {

  code_08D2AF:
    COP [SpawnAfterFlags] ( @code_08EF1A, #$2800 )
    COP [SpawnAfterAbsFlags] ( @chunk_098000.code_099E46, #$0080, #$0040, #$1800 )
    COP [SpawnAfterAbsFlags] ( @chunk_098000.code_099E4C, #$0080, #$0058, #$1800 )
    LDA $0AAC
    CMP #$0004
    BCC loc_08D2D7
    LDA #$0000

  loc_08D2D7:
    STA $0AB2
    STZ $0AAC
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D2E6 )
} >
]

code_list_08D2E6 [
  &code_08D35A   ;00
  &code_08D380   ;01
  &code_08D4D0   ;02
  &code_08D581   ;03
  &code_08F0A9   ;04
  $#0CFF   ;05
  $#065A   ;06
  &code_08B8AC   ;07
  &code_08B909   ;08
  $#0010   ;09
  $#0009   ;0A
  &code_089920   ;0B
  $#0010   ;0C
  $#14B9   ;0D
  &code_088500   ;0E
  &code_08B914   ;0F
  $#0016   ;10
  $#1685   ;11
  $#0802   ;12
  $#0C0C   ;13
  $#00A9   ;14
  $#1420   ;15
  $#0210   ;16
  $#0088   ;17
  &code_088EE0   ;18
  &code_088002   ;19
  $#021C   ;1A
  $#0289   ;1B
  $#1DDA   ;1C
  $#12AD   ;1D
  &code_088D0B   ;1E
  $#0642   ;1F
  $#08AD   ;20
  $#0A0B   ;21
  $#0A0A   ;22
  &code_088D0A   ;23
  $#064C   ;24
  $#0CAD   ;25
  $#1A0B   ;26
  $#0A1A   ;27
  $#0A0A   ;28
  &code_088D0A   ;29
  $#064E   ;2A
  $#03A9   ;2B
  &code_088D00   ;2C
  $#0650   ;2D
  $#10AD   ;2E
  &code_088D0B   ;2F
  $#0652   ;30
  &code_08AC9C   ;31
  &code_08A90A   ;32
  $#0101   ;33
  $#4A8D   ;34
  &code_08A906   ;35
  $#0002   ;36
  $#488D   ;37
  $#0206   ;38
  $#6BC1   ;39
]

code_08D35A {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D366 )
    BRA loc_08D367
}

code_08D366 {
    RTL 

  loc_08D367:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D37A )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D37A {
    COP [CallScript] ( &code_08D5F4 )
    BRA code_08D35A
}

code_08D380 {
    LDA $characterForm
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D38C )
}

code_list_08D38C [
  &code_08D392   ;00
  &code_08D3FE   ;01
  &code_08D46A   ;02
]

code_08D392 {
    COP [StageBgChange] ( #88 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchIfFlagByte] ( #B4, #00, &code_08D3AC )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

code_08D3AC {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D3C8 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D3C8 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D3C8 )
    BRA loc_08D3C9
}

code_08D3C8 {
    RTL 

  loc_08D3C9:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D3EC )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D3F2 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D3F8 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D3EC {
    COP [CallScript] ( &code_08D5F4 )
    BRA code_08D3AC
}

code_08D3F2 {
    COP [CallScript] ( &code_08E996 )
    BRA code_08D3AC
}

code_08D3F8 {
    COP [CallScript] ( &code_08ECD7 )
    BRA code_08D3AC
}

code_08D3FE {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchIfFlagByte] ( #B4, #00, &code_08D418 )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

code_08D418 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D434 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D434 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D434 )
    BRA loc_08D435
}

code_08D434 {
    RTL 

  loc_08D435:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D458 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D45E )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D464 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D458 {
    COP [CallScript] ( &code_08D5F4 )
    BRA code_08D418
}

code_08D45E {
    COP [CallScript] ( &code_08EBD3 )
    BRA code_08D418
}

code_08D464 {
    COP [CallScript] ( &code_08ECD7 )
    BRA code_08D418
}

code_08D46A {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8D )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]

  loc_08D47E:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D49A )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D49A )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D49A )
    BRA loc_08D49B
}

code_08D49A {
    RTL 

  loc_08D49B:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D4BE )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D4C4 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D4CA )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D4BE {
    COP [CallScript] ( &code_08D5F4 )
    BRA loc_08D47E
}

code_08D4C4 {
    COP [CallScript] ( &code_08EBD3 )
    BRA loc_08D47E
}

code_08D4CA {
    COP [CallScript] ( &code_08E996 )
    BRA loc_08D47E
}

code_08D4D0 {
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    PHX 
    LDX #$0000

  loc_08D4D9:
    LDA $@code_08E4BF, X
    BEQ loc_08D548
    AND #$00FF
    CMP $0B12
    BEQ loc_08D4EB
    INX 
    INX 
    BRA loc_08D4D9

  loc_08D4EB:
    LDA $@code_08E4BF+1, X
    AND #$00FF
    PLX 
    AND #$000F
    BEQ loc_08D520
    COP [StageBgChange] ( #86 )
    COP [ApplyBgChange]
    LDA #$0000
    STA $orbitAngle, X
    COP [SpawnLastRel] ( @code_08E339, #00, #00, #$3800 )
    LDA #$0040
    STA $0014, Y
    LDA #$006D
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08D549

  loc_08D520:
    COP [StageBgChange] ( #8B )
    COP [ApplyBgChange]
    LDA #$0001
    STA $orbitAngle, X
    COP [SpawnLastRel] ( @code_08E339, #00, #00, #$3800 )
    LDA #$0040
    STA $0014, Y
    LDA #$0054
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08D549

  loc_08D548:
    PLX 

  loc_08D549:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D555 )
    BRA loc_08D556
}

code_08D555 {
    RTL 

  loc_08D556:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D569 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D569 {
    COP [CallScript] ( &code_08D5F4 )
    BRA loc_08D549

  loc_08D56F:
    LDA $orbitAngle, X
    BNE loc_08D57B
    COP [CallScript] ( &code_08EBD3 )
    BRA loc_08D549

  loc_08D57B:
    COP [CallScript] ( &code_08E996 )
    BRA loc_08D549
}

code_08D581 {
    LDA #$0001
    STA $0AAC
    JMP $&code_08D380
}

code_08D58A {
    COP [StageBgChange] ( #8B )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #89 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [SpawnLastRel] ( @code_08E831, #00, #00, #$3800 )
    LDA #$00C0
    STA $0014, Y
    LDA #$0078
    STA $0016, Y
    LDA $06
    STA $0026, Y

  loc_08D5B8:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D5CC )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D5CC )
    BRA loc_08D5CD
}

code_08D5CC {
    RTL 

  loc_08D5CD:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D5E8 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D5EE )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &code_08D2EE )
    RTL 
}

code_08D5E8 {
    COP [CallScript] ( &code_08D5F4 )
    BRA loc_08D5B8
}

code_08D5EE {
    COP [CallScript] ( &code_08ECD7 )
    BRA loc_08D5B8
}

code_08D5F4 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    LDY $06
    LDA #$FFFF
    STA $0024, Y
    COP [BranchIfFlagByte] ( #DC, #01, &code_08D618 )
    COP [SetFlagByte] ( #DC )
    COP [PrintWideString] ( &widestring_08D80F )
}

code_08D618 {
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08D63B
    COP [PrintWideString] ( &widestring_08D926 )
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$0028
    STA $damageFlashTimer
    COP [SetEntryContinue]
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08D63B
    RTL 

  loc_08D63B:
    PHX 
    LDX #$0000

  loc_08D63F:
    LDA $@widestring_08D94B, X
    AND #$00FF
    BEQ loc_08D69E
    CMP $0B12
    BEQ loc_08D650
    INX 
    BRA loc_08D63F

  loc_08D650:
    STX $0000
    PLX 
    COP [SwitchCase] ( #$0000, &code_list_08D65A )
}

code_list_08D65A [
  &code_08D729   ;00
  &code_08D72C   ;01
  &code_08D733   ;02
  &code_08D73A   ;03
  &code_08D741   ;04
  &code_08D744   ;05
  &code_08D747   ;06
  &code_08D74A   ;07
  &code_08D74D   ;08
  &code_08D750   ;09
  &code_08D757   ;0A
  &code_08D75A   ;0B
  &code_08D75D   ;0C
  &code_08D760   ;0D
  &code_08D763   ;0E
  &code_08D766   ;0F
  &code_08D76D   ;10
  &code_08D774   ;11
  &code_08D777   ;12
  &code_08D77A   ;13
  &code_08D77D   ;14
  &code_08D784   ;15
  &code_08D787   ;16
  &code_08D78A   ;17
  &code_08D78D   ;18
  &code_08D794   ;19
  &code_08D797   ;1A
  &code_08D79A   ;1B
  &code_08D7A1   ;1C
  &code_08D7A8   ;1D
  &code_08D7AB   ;1E
  &code_08D7FE   ;1F
  &code_08D801   ;20
  &code_08D808   ;21
]

loc_08D69E {
    PLX 

  code_08D69F:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_08D8AC )
    COP [DialogueOptions] ( #02, #02, &code_list_08D6AF )
}

code_list_08D6AF [
  &code_08D6DE   ;00
  &code_08D6B5   ;01
  &code_08D6DE   ;02
]

code_08D6B5 {
    LDA $0D8C
    JSL $@chunk_3B7DD.code_03D61F
    COP [PlaySoundCh1] ( #29 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_08D8E2 )
    COP [DialogueOptions] ( #02, #01, &code_list_08D6D8 )
}

code_list_08D6D8 [
  &code_08D6EC   ;00
  &code_08D6DE   ;01
  &code_08D6EC   ;02
]

code_08D6DE {
    COP [PrintWideString] ( &widestring_08D91B )
    LDY $06
    LDA #$0000
    STA $0024, Y
    COP [RestoreSavedPtr]
}

code_08D6EC {
    COP [PrintWideString] ( &widestring_08D90A )
    LDY $06
    LDA #$0000
    STA $0024, Y
    LDA #$FFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #0E )
    COP [SetEntryContinue]
    RTL 
}

code_08D729 {
    JMP $&code_08D69F
}

code_08D72C {
    COP [PrintWideString] ( &widestring_08D9B0 )
    JMP $&code_08D69F
}

code_08D733 {
    COP [PrintWideString] ( &widestring_08DA31 )
    JMP $&code_08D69F
}

code_08D73A {
    COP [PrintWideString] ( &widestring_08DA98 )
    JMP $&code_08D69F
}

code_08D741 {
    JMP $&code_08D69F
}

code_08D744 {
    JMP $&code_08D69F
}

code_08D747 {
    JMP $&code_08D69F
}

code_08D74A {
    JMP $&code_08D69F
}

code_08D74D {
    JMP $&code_08D69F
}

code_08D750 {
    COP [PrintWideString] ( &widestring_08DC6F )
    JMP $&code_08D69F
}

code_08D757 {
    JMP $&code_08D69F
}

code_08D75A {
    JMP $&code_08D69F
}

code_08D75D {
    JMP $&code_08D69F
}

code_08D760 {
    JMP $&code_08D69F
}

code_08D763 {
    JMP $&code_08D69F
}

code_08D766 {
    COP [PrintWideString] ( &widestring_08DD3B )
    JMP $&code_08D69F
}

code_08D76D {
    COP [PrintWideString] ( &widestring_08DDD2 )
    JMP $&code_08D69F
}

code_08D774 {
    JMP $&code_08D69F
}

code_08D777 {
    JMP $&code_08D69F
}

code_08D77A {
    JMP $&code_08D69F
}

code_08D77D {
    COP [PrintWideString] ( &widestring_08DE39 )
    JMP $&code_08D69F
}

code_08D784 {
    JMP $&code_08D69F
}

code_08D787 {
    JMP $&code_08D69F
}

code_08D78A {
    JMP $&code_08D69F
}

code_08D78D {
    COP [PrintWideString] ( &widestring_08DEA9 )
    JMP $&code_08D69F
}

code_08D794 {
    JMP $&code_08D69F
}

code_08D797 {
    JMP $&code_08D69F
}

code_08D79A {
    COP [PrintWideString] ( &widestring_08DF19 )
    JMP $&code_08D69F
}

code_08D7A1 {
    COP [PrintWideString] ( &widestring_08DF5F )
    JMP $&code_08D69F
}

code_08D7A8 {
    JMP $&code_08D69F
}

code_08D7AB {
    LDA $0AAC
    BNE loc_08D7B3
    JMP $&code_08D69F

  loc_08D7B3:
    COP [BranchIfNoItem] ( #24, &code_08D7F0 )
    COP [GiveItem] ( #24, &code_08D7F7 )
    COP [PrintWideString] ( &widestring_08E03F )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_08E18F )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08D7E3
    RTL 

  loc_08D7E3:
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_08E0EE )
    JMP $&code_08D69F
}

code_08D7F0 {
    COP [PrintWideString] ( &widestring_08E0EE )
    JMP $&code_08D69F
}

code_08D7F7 {
    COP [PrintWideString] ( &widestring_08E1AB )
    JMP $&code_08D69F
}

code_08D7FE {
    JMP $&code_08D69F
}

code_08D801 {
    COP [PrintWideString] ( &widestring_08E201 )
    JMP $&code_08D69F
}

code_08D808 {
    COP [PrintWideString] ( &widestring_08E307 )
    JMP $&code_08D69F
}

widestring_08D80F `[DEF]私は 生命のみなもと ガイア.[N]今後 そなたの旅を 手助け[N]するもの.[FIN]この 空間が 見えるのは[N]ヤミの力が 宿った者だけ.[N]そなたは えらばれた 人間なのだ.[FIN]ヤミの空間では 冒険の記録を[N]行うことができる.[N]旅先では 必ず たちよるがいい.[FIN]`

widestring_08D8AC `[DEF][CLR]そろそろ 今までの 冒険を[N]記録して おいては どうだね?[N] 記録する[N] 記録しない`

widestring_08D8E2 `[CLR]記録は おわった···[FIN]まだ 旅を つづけるのかね?[N] はい[N] いいえ`

widestring_08D90A `[CLR]では ゆっくり 休むがよい.[END]`

widestring_08D91B `[CLR]では ゆくがよい.[END]`

widestring_08D926 `[DEF][CLR]きずついて いるようだね.[N]さあ 目を閉じて じっとして···[FIN]`

widestring_08D94B `ぎぢび,FHTうかくつぬはふみよりぇ9[85][86][99][A1][A3][A7][AC][B6][B8][BB][PAL:CC][E0][E3](がが[DEF][CLR]私は 生命のみなもと ガイア.[N]そなたに ひとつ 助言を[N]あたえようと思う.[FIN]`

widestring_08D9A1 `[DEF][CLR]ヒントのテスト[FIN]`

widestring_08D9B0 `[PRT]ゃ[DLY:88]ー定地域の敵を すべてたおすと[N]能力の上がる 宝石があらわれる.[N]そなたは それで 強くなってゆく.[FIN]敵の場所は スタートボタンをおせば[N]わかるはず.[N]まものは さがしだしてでも 残さず[N]たおしてゆくことだ···[FIN]`

widestring_08DA31 `[PRT]ゃ[DLY:88]テムの力 サイコダッシュは[N]カベや 障害物を はかいすることが[N]できる.[FIN]あたりには つねに 気をくばり[N]あやしい場所を 見つけたら[N]はかいできないか ためすことだ.[FIN]`

widestring_08DA98 `[PRT]ゃ[DLY:88]このあと そなたは とてつもなく[N]きょだいな敵と 戦うことになろう.[FIN]この敵は ダメージを受けると[N]頭から 何本もの 光のすじを[N]放ってくる.[FIN]ダメージをあたえたら すぐさま[N]敵の後方に ひなんすることだ.[FIN]`

widestring_08DB15 `[PRT]ゃ[DLY:88]黄金タイルの しきつめられた場所.[N]そこには 黄金の船へ向かうとびらが[N]かくされている.[FIN]インカの神の歌う メロディに[N]耳を かたむけてみるといい.[FIN]`

widestring_08DB76 `[PRT]ゃ[DLY:88]届かない場所にいる敵を たおすには[N]どうすればいいのか····[N]エドワード城の地下での できごとを[N]思いかえしてみるといい.[FIN]`

widestring_08DBC4 ``

widestring_08DBC5 `[PRT]ゃ[DLY:88]風のふきこむカベ···[N]それは 石が すきまだらけで[N]こわれやすい場所.[FIN]見つからなければ たたいて調べる[N]という方法もある.[N]そこだけ 音がちがうはずだ.[FIN]`

widestring_08DC24 `[PRT]ゃ[DLY:88]鉱山の 地面にある 鉄格子は[N]すべて カギが かかっている.[N]まずは カギを持つ ドレイを[N]さがしだすことだ.[FIN]`

widestring_08DC6F `[PRT]ゃ[DLY:88]フリーダンの力 ダークフライヤーは[N]つるぎの とどかない場所にいる敵を[N]たおすことが できるのだ.[FIN]敵を すべて たおしていけば[N]必ず 道は ひらけるものだ.[FIN]`

widestring_08DCCF ``

widestring_08DCD0 `[PRT]ゃ[DLY:88]表の障害物を ひっこめれば[N]裹が でっぱる.[N]じゃまな はしらは ひっこめる[N]ことだ.[FIN]`

widestring_08DD06 `[PRT]ゃ[DLY:88]地面にある スイッチ.[N]それは 人間の重さでは おしこむ[N]ことが できない.[FIN]`

widestring_08DD39 ``

widestring_08DD3A ``

widestring_08DD3B `[PRT]ゃ[DLY:88]ムー大陸は そなたが 旅をはじめる[N]と 同時に 海面へ ふじょうした.[FIN]しかし 大陸の 多くの部分には[N]まだ 海水がたまっている.[FIN]この水が すべて なくなったとき[N]そなたは ムー大陸の王 ラ·ムーの[N]ねむる場所へ たどりつくだろう.[FIN]`

widestring_08DDD2 `[PRT]ゃ[DLY:88]テムの力 サイコスライダーは[N]高さが低く せまい通路を[N]とおりぬけることができる.[::][FIN]とおれる 岩のすきまを[N]見落さないように あたりに[N]気をくばって歩くがいい.[FIN]`

widestring_08DE36 ``

widestring_08DE37 ``

widestring_08DE38 ``

widestring_08DE39 `[PRT]ゃ[DLY:88]テムの力 スピンダッシュは[N]その 反動を使って 坂をのぼったり[N]ジャンプしたりすることができる.[FIN]ここ 万里の長城は 坂が多い.[N]いろんな場所で ためしてみる[N]ことだ.[FIN]`

widestring_08DEA6 ``

widestring_08DEA7 ``

widestring_08DEA8 ``

widestring_08DEA9 `[PRT]ゃ[DLY:88]フリーダンの力 オーラバリアは[N]自分のまわりに オーラの板を[N]回転させることができる.[FIN]山の聖域の敵は 強い.[N]この力を使うことで たたかいは[N]だいぶ 楽になるはずだ.[FIN]`

widestring_08DF17 ``

widestring_08DF18 ``

widestring_08DF19 `[PRT]ゃ[DLY:88]フリーダンの力 アースクエイカーは[N]じしんをおこし あたりの敵を[N]しばらくの間 動けなくすることが[N]できるのだ.[FIN]`

widestring_08DF5F `[DEF][CLR]ここ アンコールワットは[N]さまよえる寺院.[FIN]ジャングルの中に ひっそりと[N]たたずみ 人が近づくと その姿を[N]かくすと 言われる···[FIN]そして この 最上階で そなたは[N]自分が なぜ 旅をしているのか[N]知ることになるだろう.[FIN]`

widestring_08DFE4 ``

widestring_08DFE5 `[PRT]ゃ[DLY:88]ピラミッドは 6つのブロックに[N]わかれている.[FIN]それぞれの地域を これまでに[N]手に入れた ヤミの力を 最大限に[N]利用して 進むがよい.[FIN]`

widestring_08E03F `[DEF][CLR]私は 生命のみなもと ガイア.[N]そなたの ヤミの力は[N]アンコールワットの寺院にて さらに[N]強いものとなった.[FIN]右がわの 石像の前に立てば[N]さらに 強力な ヤミの戦士[N]シャドウへと その姿を変えることが[N]できよう.[FIN]そして 私は そなたに[N]アイテムを ひとつ あたえたいと[N]思う.[FIN]`

widestring_08E0EE `[DEF][CLR]オーラのたまは シャドウの心.[N]シャドウが これを かかげると[N]その体は 水のように変化する.[FIN]現在 知られている ピラミッドは[N]地表の ほんの ー部分.[N]その ほとんどは 地下に ねむって[N]いるのだ.[FIN]さあ シャドウへと 姿を変え[N]地下へ 進むがよい.[FIN]`

widestring_08E18F `[DEF][CLR][DLY:9]オーラの玉を 手に入れた![PAU:78][DLY:1][FIN]`

widestring_08E1AB `[DEF][CLR]私は 生命のみなもと ガイア.[N]私は そなたに アイテムをひとつ[N]あたえたいと思う.[FIN]どこかで 持ち物をへらし[N]再び ここへ くるがよい.[FIN]`

widestring_08E200 ``

widestring_08E201 `[DEF][CLR]すい星が 近づいている···[N]そして 最後の たたかいの時が[N]近づいている···[FIN]そなたと こうして 話すのも[N]この場所が 最後になろう.[FIN]そなたの力は すい星ダークガイアに[N]戦いをいどめるまでに よみがえり,[N]すばらしい ヤミの戦士に成長した.[FIN]光の戦士と 心が ーつになったとき[N]シャドウのもつ ゆいいつの力[N]ファイアバードが よみがえる.[FIN]この星を もとの姿に もどせるのは[N]そなただけ.[N]私は すべての のぞみを そなたに[N]たくそう···[FIN]`

widestring_08E307 `[PRT]ゃ[DLY:88]そなたの姿は かりの姿.[N]となりに たたずむ 石像の前に[N]立ってみるがいい.[FIN]`

code_08E339 {
    PHX 
    LDX #$0000
    LDY #$0000

  loc_08E340:
    LDA $@code_08E4BF, X
    BEQ loc_08E353
    AND #$00FF
    CMP $0B12
    BEQ loc_08E356
    INX 
    INX 
    INY 
    BRA loc_08E340

  loc_08E353:
    PLX 
    COP [Die]

  loc_08E356:
    LDA $@code_08E4BF+1, X
    AND #$00FF
    STA $24
    AND $abilityBitmask
    BNE loc_08E353
    TYA 
    STA $0AAC
    PLX 
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08E380 )
    RTL 
}

code_08E380 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    JSR $&code_08E494
    CMP #$0000
    BEQ loc_08E3DD
    LDA $characterForm
    BEQ loc_08E3BD
    CMP #$0002
    BEQ loc_08E39D
    BRA loc_08E400

  loc_08E39D:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EB97
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    BRA loc_08E400

  loc_08E3BD:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EB62
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    BRA loc_08E400

  loc_08E3DD:
    LDA $characterForm
    BEQ loc_08E400
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_08E400:
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_08E40F
    RTL 

  loc_08E40F:
    COP [LoopInit] ( #08 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
    LDA $24
    ORA $abilityBitmask
    STA $abilityBitmask
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_08E4CD )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF

  loc_08E46F:
    BEQ loc_08E472
    RTL 

  loc_08E472:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintWideString] ( &widestring_08E4EE )
    LDY $26
    LDA #$0000
    STA $0024, Y
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_08E494 {
    PHX 
    LDX #$0000

  loc_08E498:
    LDA $@code_08E4BF, X
    BEQ loc_08E4BC
    AND #$00FF
    CMP $0B12
    BEQ loc_08E4AA
    INX 
    INX 
    BRA loc_08E498

  loc_08E4AA:
    LDA $@code_08E4BF+1, X
    AND #$00FF
    PLX 
    AND #$00F0
    BNE loc_08E4B8
    RTS 

  loc_08E4B8:
    LDA #$0001
    RTS 

  loc_08E4BC:
    PLX 
    SEC 
    RTS 
}

code_08E4BF {
    ORA $01, X
    PER loc_086AC6
    TSB $42
    BPL loc_08E46F
    JSR $40B8
    BRK #$00
}

widestring_08E4CD `[DEF][DLY:9]ヤミの力 [ADR:&chunk_088000.widestring_08E4F8,AAC]が[N]使えるようになった![PAU:78][FIN]`

widestring_08E4EE `[DEF][CLR][DLY:2][ADR:&chunk_088000.widestring_08E542,AAC][END]`

widestring_08E4F8 `ご[E5]ど[E5]ぱ[E5]C[E5]N[E5]W[E5]サイコダッシュ`

widestring_08E50E `サイコスライダー`

widestring_08E519 `スピンダッシュ`

widestring_08E523 `ダークフライヤー`

widestring_08E52E `オーラバリア`

widestring_08E537 `アースクエイカー`

widestring_08E542 `と[E5][DLG:E5,37][E6][BCD:3DE6,B8E7][E7]サイコダッシュは 少年テムだけが[N]使うことのできる ちから.[FIN]体当たりこうげきで 障害物や[N]くずれやすいカベを はかいする[N]ことができるのだ.[FIN]こうげきボタンで ちからをためて[N]使うがよい···`

widestring_08E5C1 `サイコスライダーは 少年テムだけが[N]使うことのできる ちから.[FIN]スライディングこうげきが できる[N]ようになる.[N]また せまい通路も通れるであろう.[FIN]走っている最中に こうげきボタンを[N]おすがよい···`

widestring_08E637 `スピンダッシュは 少年テムだけが[N]使うことのできる ちから.[FIN]自分が 高速回転し 敵を[N]はじき飛ばすことができる.[N]その反動を 利用して 坂を[N]かけあがることもできるであろう.[FIN]こうげきボタンで 力をため[N]LRを こうごにおすがよい···`

widestring_08E6C6 `ダークフライヤーは[N]ヤミの戦士フリーダンだけが 使える[N]ヤミのちから.[FIN]オーラのパワーを放ち 遠くはなれた[N]敵を 燒きつくすことができるのだ.[N]こうげきボタンで 力をためて[N]使うがよい···`

widestring_08E73D `オーラバリアは[N]ヤミの戦士フリーダンだけが 使える[N]ヤミのちから.[FIN]この力は 自分の まわりに[N]オーラでできた バリアをはることが[N]できる.[FIN]こうげきボタンで 力をため[N]LRを こうごにおすがよい···`

widestring_08E7B8 `アースクエイカーは[N]ヤミの戦士フリーダンだけが 使える[N]ヤミのちから.[FIN]これは じしんを おこして[N]敵を しばらくの間 動けなく[N]することできる.[FIN]飛びおりている最中に[N]こうげきボタンをおすがよい···`

code_08E831 {
    COP [BranchIfNoItem] ( #24, &code_08E8C6 )
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10

  code_08E83E:
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08E84D )
    RTL 
}

code_08E84D {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    COP [GiveItem] ( #24, &code_08E8C8 )
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_08E8EE )
    COP [WaitByte] ( #03 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08E8AC
    RTL 

  loc_08E8AC:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintWideString] ( &widestring_08E905 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    LDA #$FFF0
    TRB $joypadMaskStd
}

code_08E8C6 {
    COP [Die]
}

code_08E8C8 {
    LDA #$0800
    TRB $10
    COP [PrintWideString] ( &widestring_08E969 )
    LDA #$0800
    TSB $10
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08E8ED )
    JMP $&code_08E83E
}

code_08E8ED {
    RTL 
}

widestring_08E8EE `[DEF][DLY:9]オーラのたまを 手に入れた![FIN]`

widestring_08E905 `[DEF][CLR][DLY:2]オーラの玉は シャドウだけが使える[N]アイテム.[FIN]これを かかげれば[N]シャドウの体は 水のようになり[N]石のすきまを 通りぬけて 下の階へ[N]ゆくことができるのだ.[END]`

widestring_08E969 `[DEF]もちものが いっぱいのようだ···[N]どこかで へらして 再び[N]もどって くるがよい.[END]`

code_08E996 {
    LDA $characterForm
    CMP #$0001
    BEQ loc_08E9D8
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [BranchIfFlagByte] ( #F7, #01, &code_08E9DA )
    COP [SetFlagByte] ( #F7 )
    COP [PrintWideString] ( &widestring_08EA63 )
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EB29
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_08E9D8:
    COP [RestoreSavedPtr]
}

code_08E9DA {
    COP [PrintWideString] ( &widestring_08EA39 )
    COP [DialogueOptions] ( #02, #02, &code_list_08E9E4 )
}

code_list_08E9E4 [
  &code_08EA33   ;00
  &code_08E9EA   ;01
  &code_08EA33   ;02
]

code_08E9EA {
    COP [PrintWideString] ( &widestring_08EA61 )
    LDA $characterForm
    BNE loc_08EA13
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EB62
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]

  loc_08EA13:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EB97
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]
}

code_08EA33 {
    COP [PrintWideString] ( &widestring_08EA61 )
    COP [RestoreSavedPtr]
}

widestring_08EA39 `[TPL:B]ヤミの戦士 フリーダンに[N]変身しますか?[N] はい[N] いいえ`

widestring_08EA61 `[CLD]`

widestring_08EA63 `[TPL:B][CLR][TPL:0]テムの頭の中で,声がこだまする.[FIN][TPL:4]テムよ.[N]私は この時がくるのを ずっと[N]待ち続けていた.[FIN]私の名は フリーダン.[N]時をこえて 生き続けるもの.[FIN]今後 テムの旅を 手助けさせて[N]もらうつもりだ.[N]私のことは 時がくれば 自然と[N]わかるであろう···[FIN][PAL:0]やがて テムの 意識は[N]だんだん 遠のいていった···[N][END]`

widestring_08EB29 `ぐ[8E]ざぐ私ぐ[89]ぐぜEEぐ[84]ぐぐぐ[8A]ぐ[84]げぐぐ[8A]ぐあづ[XXX][B5]手[84]ぜぐぐ[8A]ぐ[84]ぞぐぐ[8A]ぐ必ぐ[89][A9]ぎが[8D]ダ╳ワ[EF]ゥグ[8E]ザグ旅グ[89]グゼeeグ手グ[89]グ助グ[89]グアヅ[XXX][B5]手行グ[89]グ先グ[89]グ場グ[89][A9]ギガ[8D]ダ╳ワ[EF]ゥグ[8E]ザグ能グ[89]グゼeeグ左グ[89]グ入グ[89]グ力グ[89][A9]ギガ[8D]ダグ[TPL:2]アヅ[XXX][B5]手行グ[89]グ先グ[89]グ場グ[89]╳ワ[EF]ゥ`

code_08EBD3 {
    LDA $characterForm
    BNE loc_08EBDA
    COP [RestoreSavedPtr]

  loc_08EBDA:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_08EC4B )
    COP [DialogueOptions] ( #02, #01, &code_list_08EBF3 )
}

code_list_08EBF3 [
  &code_08EC45   ;00
  &code_08EBF9   ;01
  &code_08EC45   ;02
]

code_08EBF9 {
    COP [PrintWideString] ( &widestring_08EC68 )
    LDA $characterForm
    CMP #$0001
    BNE loc_08EC25
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]

  loc_08EC25:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]
}

code_08EC45 {
    COP [PrintWideString] ( &widestring_08EC68 )
    COP [RestoreSavedPtr]
}

widestring_08EC4B `[TPL:B]少年テムに もどりますか?[N] はい[N] いいえ`

widestring_08EC68 `[CLD]`

widestring_08EC6A `ぐ[8E]ざぐ冒ぐ[89]ぐぜEEぐ先ぐ[89]ぐ行ぐ[89][9C]ダグ[TPL:2]アヂ[XXX][B5]手助グ[89]グ手グ[89]グ間グ[89]╳ワ[EF]ゥグ[8E]ザグ能グ[89]グゼeeグ左グ[89]グ入グ[89]グ力グ[89][9C]ダグ[TPL:2]アヂ[XXX][B5]手助グ[89]グ手グ[89]グ間グ[89]╳ワ[EF]ゥ`

code_08ECD7 {
    COP [BranchIfFlagByte] ( #B4, #00, &code_08ED08 )
    LDA $characterForm
    CMP #$0002
    BEQ code_08ED08
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [BranchIfFlagByte] ( #DD, #01, &code_08ED0A )
    COP [SetFlagByte] ( #DD )
    COP [PrintWideString] ( &widestring_08ED92 )
    LDA $characterForm
    BEQ loc_08ED23
    BRA loc_08ED43
}

code_08ED08 {
    COP [RestoreSavedPtr]
}

code_08ED0A {
    COP [PrintWideString] ( &widestring_08ED69 )
    COP [DialogueOptions] ( #02, #02, &code_list_08ED14 )
}

code_list_08ED14 [
  &code_08ED63   ;00
  &code_08ED1A   ;01
  &code_08ED63   ;02
]

code_08ED1A {
    COP [PrintWideString] ( &widestring_08ED90 )
    LDA $characterForm
    BNE loc_08ED43

  loc_08ED23:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]

  loc_08ED43:
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EECF
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [RestoreSavedPtr]
}

code_08ED63 {
    COP [PrintWideString] ( &widestring_08ED90 )
    COP [RestoreSavedPtr]
}

widestring_08ED69 `[TPL:B]ヤミの戦士 シャドウに[N]変身しますか?[N] はい[N] いいえ`

widestring_08ED90 `[CLD]`

widestring_08ED92 `[TPL:B]頭の中で 声がこだまする.[FIN][TPL:4]私は この時がくるのを ずっと[N]待ち続けていた.[FIN]私こそ すい星の光を 使って[N]作り出された 究極の戦士シャドウ.[FIN]私の体には 形がない···[N]人の 意識だけが 進化すると[N]この体になると 思えばいい.[FIN]今 地球に 近づいている すい星も[N]形を もたない 意識体.[FIN]はめつをもたらす すい星に[N]立ち向かえるのは この私の体だけで[N]あろう.[FIN]さあ 目を閉じるがいい···[PAL:0][END]`

widestring_08EE8C `ぐ[8E]ざぐ私ぐ[89]ぐぜEEぐ手ぐ[89]ぐ助ぐ[89]ぐあぇ[XXX][B5]手力ぐ[89]ぐ入ぐ[89]ぐ[A5]ぴ[BF]明ががH[A9]ぐが[8D]ダグ左グ[89]グ石グ[89]╳ワ[EF]ゥグ[8E]ザグ険グ[89]グゼeeグ先グ[89]グ行グ[89]グアェ[XXX][B5]手力グ[89]グ入グ[89]グ[A5]ピ[BF]明ガガh[A9]グガ[8D]ダグ左グ[89]グ石グ[89]╳ワ[EF]ゥグガh[A9]ガ►ゴ▲`

code_08EF1A {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$000F
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SpawnAfterFlags] ( @code_08EF2F, #$1B02 )
    BRA code_08EF1A
}

code_08EF2F {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$0000
    STA $16
    COP [RngByte]
    ASL 
    STA $14
    AND #$0003
    ASL 
    CLC 
    ADC #$0004
    STA $moveXAlt, X
    DEC 
    STA $moveYAlt, X

  loc_08EF57:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $16
    CMP #$00FF
    BCC loc_08EF57
    COP [Die]

  loc_08EF66:
    PHX 
    LDX $decelStepCounter
    LDA #$0082
    STA $0002, X
    LDA #$D01B
    STA $0000, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    LDA $0010, X
    AND #$FDFF
    ORA #$0008
    STA $0010, X
    LDA #$0F00
    TRB $joypadMaskStd
    LDA #$0800
    TRB $slopeCurvePtrB
    PLX 
    RTS 
}

actor_def_08EF9C [
  actor-def < #00, #00, #00, {

  code_08EF9F:
    LDA #$0011
    TSB $12
    LDA #$0100
    STA $cameraBoundsY
    COP [SpawnBeforeFlags] ( @code_08F285, #$2000 )
    LDA #$0088
    AND #$00FF
    STA $0AF6
    LDA #$F27D
    STA $0AF4
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #13 )
    COP [PlaySoundCh1] ( #0E )
    COP [StageBgChange] ( #9C )
    COP [ApplyBgChange]
    COP [BranchIfFlagByte] ( #E8, #01, &code_08EFE7 )
    COP [WaitByte] ( #27 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #B3 )
    COP [SetFlagByte] ( #E8 )
    COP [PrintWideString] ( &widestring_08F2C4 )
} >
]

code_08EFE7 {
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #31 )
    LDA #$EFF0
    TRB $joypadMaskStd

  loc_08EFF6:
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]

  code_08EFFB:
    LDA $playerSpeedEw
    CMP #$0070
    BCS loc_08F006
    JMP $&code_08F0D1

  loc_08F006:
    COP [BranchOnPlayerX] ( #$0010, &code_08F03D, &code_08F010, &code_08F03D )
}

code_08F010 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08F147, #$0000, #$FFE8, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_08F179, #$0000, #$FFE8, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_08F193, #$0000, #$FFE8, #$0200 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    BRA loc_08EFF6
}

code_08F03D {
    COP [BranchOnPlayerX] ( #$0050, &code_08F047, &code_08F0B5, &code_08F047 )
}

code_08F047 {
    COP [BranchOnPlayerX] ( #$0070, &code_08F0B5, &code_08F051, &code_08F0B5 )
}

code_08F051 {
    COP [BranchOnPlayerX] ( #$0000, &code_08F05B, &code_08F088, &code_08F088 )
}

code_08F05B {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08F1CA, #$FFF0, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08F1CA, #$FFF0, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F088 {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08F1EA, #$0010, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08F1EA, #$0010, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F0B5 {
    COP [BranchOnPlayerX] ( #$0000, &code_08F0BF, &code_08F0C8, &code_08F0C8 )
}

code_08F0BF {
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F0C8 {
    COP [StageSpriteMoveX] ( #05, #11 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F0D1 {
    COP [BranchOnPlayerX] ( #$0040, &code_08F135, &code_08F0DB, &code_08F13E )
}

code_08F0DB {
    COP [BranchOnPlayerX] ( #$0000, &code_08F0E5, &code_08F10D, &code_08F10D )
}

code_08F0E5 {
    COP [PlaySoundCh1] ( #02 )
    LDA #$0010
    TSB $10
    LDA #$AD58
    STA $statsPtr, X
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$AD54
    STA $statsPtr, X
    LDA #$0010
    TRB $10
    JMP $&code_08EFFB
}

code_08F10D {
    COP [PlaySoundCh1] ( #02 )
    LDA #$0010
    TSB $10
    LDA #$AD58
    STA $statsPtr, X
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA #$AD54
    STA $statsPtr, X
    LDA #$0010
    TRB $10
    JMP $&code_08EFFB
}

code_08F135 {
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F13E {
    COP [StageSpriteMoveX] ( #06, #01 )
    COP [AnimOnce]
    JMP $&code_08EFFB
}

code_08F147 {
    COP [OrActorFlags] ( #$0010 )
    COP [CollPrioritySetMax]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #04, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #02, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #04, #07 )
    COP [AnimLoop]
    LDA #$0008
    STA $26
    JMP $&code_08F20A
}

code_08F179 {
    COP [OrActorFlags] ( #$0010 )
    COP [CollPrioritySetMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #0C, #07 )
    COP [AnimLoop]
    COP [Die]
}

code_08F193 {
    COP [OrActorFlags] ( #$0010 )
    COP [CollPrioritySetMax]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #05, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #03, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #01, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #13, #07 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #04, #07 )
    COP [AnimLoop]
    LDA #$0008
    STA $26
    BRA code_08F20A
}

code_08F1CA {
    COP [OrActorFlags] ( #$0010 )
    COP [CollPrioritySetMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #13, #05, #06, #05 )
    COP [AnimLoop]
    LDA #$000A
    STA $26
    BRA code_08F20A
}

code_08F1EA {
    COP [OrActorFlags] ( #$0010 )
    COP [CollPrioritySetMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #13, #05, #05, #05 )
    COP [AnimLoop]
    LDA #$0006
    STA $26
    BRA code_08F20A
}

code_08F20A {
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E77A, #$2000 )
    LDA #$8013
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $decelStepCounter
    STA $0024, Y
    PHX 
    TYX 
    LDA $26
    STA $animScratch2, X
    PLX 
    COP [StageSpriteLoop] ( #13, #03 )
    COP [AnimLoop]
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $7F100E, X
    LDA $0000
    STA $7F100C, X
    COP [KillNext]
    COP [StageSprAndHitbox] ( #13 )

  loc_08F253:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryContinue]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_08F274
    RTL 

  loc_08F274:
    LDA $10
    BIT #$4000
    BEQ loc_08F253
    COP [Die]

  loc_08F27D:
    SBC #$0378
    BCC loc_08F282

  loc_08F282:
    BRK #$00
    MVP #$E2, #$20
    LDA #$8D15
    BIT $&scene_warps.warp_def_01A8B4+6D
    AND ($8D, X)
    AND ($21), Y
    REP #$20
    LDA $0AEC
    BEQ loc_08F299
    RTL 

  loc_08F299:
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_08F40A )
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$0280, #$01A0, #80, #$2310 )
    COP [Die]
}

widestring_08F2C4 `[DEF]私の やしきへ ようこそ.[FIN]宝石商ジェムは カリの姿.[N]その正体は ソリッドアームと[N]いうわけだ.[FIN]そのむかし 天空から降りたった[N]ソウルブレイダーに うちのめされ[N]長い長い ねむりについた···[FIN]私の力は 赤い宝石に ふうじられ[N]世界中に 分散していたのだ.[FIN]そして 私は 復活のために[N]さまざまな 手をつくした.[FIN]ドレイ貿易を うらで あやつって[N]いたのも この私.[FIN]ドレイの 労働力を使い[N]宝石を さがして求めていたのだが[N]これほど はやく 力を[N]とりもどせるとはな···[FIN]君には かんしゃするとともに[N]永遠のねむりに ついてもらおうか![END]`

widestring_08F40A `[DEF]かぼそい声が 聞こえる···[FIN][DLY:4]またしても やられてしまうとは··[FIN]ソウルブレイダーも 強かったが[N]おまえは さらに 強いな····[FIN]この星に 危険が せまっている.[N]さあ バベルの塔へもどり[N]先を 急ぐがいい···[END]`

actor_def_08F487 [
  actor-def < #00, #00, #30, {

  code_08F48A:
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08F4C0 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [BranchIfPlayerInRelTiles] ( #32, #3E, #34, #3F, &code_08F4A8 )
    RTL 
} >
]

code_08F4A8 {
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$0280, #$01A0, #80, #$2310 )
    COP [Die]
}

widestring_08F4C0 `[TPL:A][TPL:0]気がつくと ぼくは 不思議な[N]やかたの 入口に たたずんでいた.[PAL:0][END]`

widestring_08F4ED `が が[A9][85]が[9F]だが:ぐ[88]が[E0][8E]ぐ[DLG:2,80]じぐ[89]ぅ`