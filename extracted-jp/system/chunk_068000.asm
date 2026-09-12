?BANK 06

?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'table_0EE000'

!extVelocityX                   0408
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraBoundsY                  06DC
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!eventFlags                     0A00
!playerHp                       0ACE
!characterForm                  0AD4
!TM                             212C
!CGWSEL                         2130
!CGADSUB                        2131
!APUIO0                         2140
!APUIO1                         2141
!decompressedTilesets           7E4000
!tileStagingBuffer              7E7000
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

actor_def_068000 [
  actor-def < #03, #00, #18, {

  code_068003:
    LDA #$1000
    TSB $12
    LDA $0AA6
    BNE loc_068040
    LDA #$FFA4
    STA $14
    COP [StageSpriteLoopMoveX] ( #03, #2A, #01 )
    COP [AnimLoop]
    COP [SpawnAfterFlags] ( @code_068042, #$2000 )

  code_068020:
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_068020 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    LDA #$01C0
    STA $14

  loc_068038:
    COP [StageSpriteMoveX] ( #83, #02 )
    COP [AnimOnce]
    BRA loc_068038

  loc_068040:
    COP [Die]
} >
]

code_068042 {
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06805C )
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    CMP #$0120
    BCS loc_068056
    RTL 

  loc_068056:
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06805C `[TPL:A][TPL:6]ニール:[N]しまったあっ![N]この ぼくが ミスするとはっ!![FIN][TPL:1]カレン:[N]ニールの ばかばかばかばかっ![N]テムが 死んじゃうっ!!![FIN][TPL:4]ロブ: ニール![N]まだ 地上まで もう少しあるっ![N]もう ー回だっ!![FIN][TPL:6]ニール:[N]よおし![N]今度こそは 見てろっ!!![PAL:0][END]`

actor_def_0680FE [
  actor-def < #00, #02, #18, {

  code_068101:
    LDA #$1000
    TSB $12
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    LDA $0AA6
    BNE loc_068170
    COP [SpawnAfterFlags] ( @code_068172, #$2000 )

  code_06812D:
    COP [StageSpriteMoveY] ( #00, #11 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_06812D )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearFlagByte] ( #02 )
    LDA #$FFF0
    STA $16
    COP [StageSpriteLoopMoveY] ( #00, #34, #11 )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$2C2C )
    COP [StageSpriteLoopMoveX] ( #02, #A0, #02 )
    COP [AnimLoop]
    LDA #$0002
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #80, #$1100 )
    COP [SetEntryContinue]
    RTL 

  loc_068170:
    COP [Die]
} >
]

code_068172 {
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [Die]
}

actor_def_06817D [
  actor-def < #03, #00, #18, {

  code_068180:
    LDA #$1000
    TSB $12
    LDA $0AA6
    CMP #$0002
    BNE loc_068207
    COP [WaitByte] ( #01 )
    COP [FadeThenStartMusic] ( #02 )
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0001
    STA $002C, Y
    LDA #$0000
    STA $002E, Y
    COP [SpawnAfterFlags] ( @code_068209, #$2000 )
    LDA $14
    SEC 
    SBC #$009C
    STA $14
    COP [StageSpriteLoopMoveX] ( #03, #68, #13 )
    COP [AnimLoop]

  loc_0681D0:
    COP [BranchIfFlagByte] ( #01, #01, &code_0681DD )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA loc_0681D0
} >
]

code_0681DD {
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0002
    STA $002C, Y
    COP [StageSpriteLoopMoveX] ( #03, #3C, #11 )
    COP [AnimLoop]
    JSL $@chunk_008000.code_00B57A
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #59, #$0000, #$0000, #00, #$1100 )

  loc_068207:
    COP [Die]
}

code_068209 {
    COP [WaitWord] ( #$012B )
    COP [PrintDialogString] ( &dialogstring_06821D )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06832A )
    COP [Die]
}

dialogstring_06821D `[TPL:A][TPL:6]ニール:[N]しかし あぶないところだった···[FIN][TPL:1]カレン:[N]くすん くすん···[FIN][TPL:3]エリック:[N]ヒック ヒック ぐすっ···[FIN][TPL:4]ロブ:[N]カレンも エリックも 泣くなよ.[N]テムは 助かったんだからさ.[FIN][TPL:2]リリィ:[N]しっかし ニールって すごいよね.[N]こんなもの 作っちゃうんだもん.[FIN][TPL:6]ニール: はっは.[N]そんなに ほめないでくれよ.[FIN]それより このまま 次のイセキまで[N]送ってあげよう.[FIN]例の 白鳥座の形から 言うと[N]ムー大陸の はずだ.[END]`

dialogstring_06832A `[TPL:A][TPL:6]ニール:[N]さあ 海へ でるぞっ!![FIN]この 大海原の どこかに[N]ムー大陸が ねむっているはずだ.[END]`

actor_def_068368 [
  actor-def < #05, #00, #18, {

  code_06836B:
    LDA $0AA6
    CMP #$0001
    BNE loc_0683A5
    BRA loc_068399
} >
]

actor_def_068375 [
  actor-def < #05, #00, #18, {

  code_068378:
    LDA $0AA6
    CMP #$0001
    BNE loc_0683A5
    COP [SpawnAfterFlags] ( @code_0683A7, #$2000 )
    COP [WriteApuIo0] ( #7F )
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0001
    STA $002E, Y

  loc_068399:
    COP [AddPosition] ( #00, #B0 )

  loc_06839D:
    COP [StageSpriteMoveY] ( #05, #13 )
    COP [AnimOnce]
    BRA loc_06839D

  loc_0683A5:
    COP [Die]
} >
]

code_0683A7 {
    COP [WaitByte] ( #EF )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_0683D0 )
    COP [WaitByte] ( #77 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    STA $0688
    COP [QueueMapChange] ( #5A, #$0090, #$0070, #83, #$1400 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_0683D0 `[TPL:A][TPL:0]テム:[N]ぼくらは ききいっぱつで[N]エアプレインから にげだした···[FIN]ニールは すごい 発明家だが[N]彼の作品には いつも どこかしら[N]ぬけている ところがある···[FIN]かんぺきな人間なんて どこにも[N]いないのかもしれないと ぼくは[N]思った.[PAL:0][END]`

actor_def_06845D [
  actor-def < #00, #00, #30, {

  code_068460:
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $sceneCurrent
    CMP #$005A
    BEQ loc_068480
    CMP #$005F
    BEQ loc_068492
    CMP #$0061
    BEQ loc_0684A4

  code_068478:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]

  loc_068480:
    COP [BranchIfFlagByte] ( #6E, #01, &code_068478 )
    COP [SetFlagByte] ( #6E )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0684BC )
    BRA code_068478

  loc_068492:
    COP [BranchIfFlagByte] ( #77, #01, &code_068478 )
    COP [SetFlagByte] ( #77 )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_068520 )
    BRA code_068478

  loc_0684A4:
    COP [BranchIfFlagByte] ( #7C, #01, &code_068478 )
    COP [BranchIfFlagByte] ( #7B, #00, &code_068478 )
    COP [SetFlagByte] ( #7C )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_068579 )
    BRA code_068478
} >
]

dialogstring_0684BC `[TPL:A][TPL:0]テム:[N]気がつくと ぼくは きみょうな[N]きゅうでんの中に たたずんでいた.[FIN]パラシュートが 着水してからの[N]きおくが まったくなかった···[N]みんなは 無事だろうか.[PAL:0][END]`

dialogstring_068520 `[TPL:E][TPL:0]テム:[N]ぼくと リリィは ムー大陸へと[N]足をふみいれた.[FIN]数千年のねむりからさめた 大陸は[N]ぼくらを かんげいしてくれる[N]だろうか···[PAL:0][END]`

dialogstring_068579 `[TPL:E][TPL:2]リリィ: あっ![N]さっきより 水が少なくなってるっ![FIN]どこからか 下の段へ おりられ[N]そうだねっ!![END]`

dialogstring_0685B6 `[PAL:0][END]`

actor_def_0685B9 [
  actor-def < #1C, #00, #10, {

  code_0685BC:
    COP [BranchIfFlagByte] ( #70, #01, &code_0685F2 )
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C93F, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0685F4 )

  loc_0685D6:
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #78 )
    COP [AnimLoop]
    BRA loc_0685D6
} >
]

code_0685F2 {
    COP [Die]
}

code_0685F4 {
    COP [PrintDialogString] ( &dialogstring_0685F9 )
    RTL 
}

dialogstring_0685F9 `[TPL:A][TPL:1]カレン:[N]テム···· どこ?[N]どこにいるの···??[PAL:0][END]`

actor_def_06861F [
  actor-def < #24, #00, #10, {

  code_068622:
    COP [BranchIfFlagByte] ( #6F, #01, &code_06869E )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_068630 )
    RTL 
} >
]

code_068630 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WriteApuIo0] ( #7F )
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_0686A0 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_0686B7 )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_0686FA )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #08 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06879F )
    COP [StageSpriteLoopMoveX] ( #33, #03, #02 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0687C5 )
    COP [SetFlagByte] ( #6F )
    LDA #$0000
    STA $0688
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_06869E {
    COP [Die]
}

dialogstring_0686A0 `[TPL:A][TPL:2]リリィ:[N]わあっ!!![PAU:14][PAL:0][CLD]`

dialogstring_0686B7 `[TPL:A][TPL:2]リリィ: もう···[N]びっくり させないでよっ!![FIN]しんぞうが のどから 飛び出したら[N]テムのせいだからねっ!![END]`

dialogstring_0686FA `[TPL:A][TPL:2]リリィ:[N]さっき 他の部屋で エリックを[N]見かけたんだけど,何か変でさ.[FIN]体が 半分 とうめいで[N]向こうがわが すけて見えるし,[FIN]それに 話しかけても[N]たましいを ぬきとられたみたいに[N]まるで 意識がないの···[FIN]とにかく いっしょに行動しよ.[N]何がおこるか わからないし.[PAL:0][END]`

dialogstring_06879F `[TPL:A][TPL:2]リリィ:[N]テムの ポケットを ちょっと[N]かりるね.[PAL:0][END]`

dialogstring_0687C5 `[PAU:1E][TPL:9][TPL:2]リリィ:[N]さ. 行こっ.[PAL:0][END]`

actor_def_0687DD [
  actor-def < #0C, #00, #10, {

  code_0687E0:
    COP [BranchIfFlagByte] ( #70, #01, &code_068816 )
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C93F, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_068818 )

  loc_0687FA:
    COP [StageSpriteLoopMoveX] ( #10, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0D, #78 )
    COP [AnimLoop]
    BRA loc_0687FA
} >
]

code_068816 {
    COP [Die]
}

code_068818 {
    COP [PrintDialogString] ( &dialogstring_06881D )
    RTL 
}

dialogstring_06881D `[TPL:A][TPL:3]エリック: ここは どこ?[N]くらいよ··· さみしいよ···[N]おかあさん たすけて···[PAL:0][END]`

actor_def_068852 [
  actor-def < #04, #00, #10, {

  code_068855:
    COP [BranchIfFlagByte] ( #70, #01, &code_06888B )
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C93F, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06888D )

  loc_06886F:
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #04, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #78 )
    COP [AnimLoop]
    BRA loc_06886F
} >
]

code_06888B {
    COP [Die]
}

code_06888D {
    COP [PrintDialogString] ( &dialogstring_068892 )
    RTL 
}

dialogstring_068892 `[TPL:A][TPL:4]ロブ:[N]うーん うーん.[PAL:0][END]`

actor_def_0688AB [
  actor-def < #14, #00, #10, {

  code_0688AE:
    COP [BranchIfFlagByte] ( #70, #01, &code_0688E4 )
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C93F, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0688E6 )

  loc_0688C8:
    COP [StageSpriteLoopMoveX] ( #18, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #15, #78 )
    COP [AnimLoop]
    BRA loc_0688C8
} >
]

code_0688E4 {
    COP [Die]
}

code_0688E6 {
    COP [PrintDialogString] ( &dialogstring_0688EB )
    RTL 
}

dialogstring_0688EB `[TPL:A][TPL:6]ニール:[N]うーん うーん.[PAL:0][END]`

actor_def_068905 [
  actor-def < #00, #00, #01, {

  code_068908:
    COP [BranchIfFlagByte] ( #70, #01, &code_068976 )
    LDA #$00FF
    STA $currentHp, X
    LDA #$AC1C
    STA $statsPtr, X
    LDA #$0020
    TSB $12
    COP [SetHitCallback] ( &code_068955 )

  loc_068925:
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #88, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    BRA loc_068925
} >
]

code_068955 {
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C93F, #$0000, #$0000, #$2800 )
    LDA #$1000
    TSB $10
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_068978 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_068976 {
    COP [Die]
}

code_068978 {
    COP [PrintDialogString] ( &dialogstring_06897D )
    RTL 
}

dialogstring_06897D `[TPL:A][TPL:0]テム: 何か 変だな.[N]さわっても ダメージを受ける[N]気配もないし···[PAL:0][END]`

actor_def_0689B1 [
  actor-def < #02, #00, #10, {

  code_0689B4:
    COP [BranchIfFlagByte] ( #70, #00, &code_0689E6 )
    LDA #$0008
    TSB $slopeCurvePtrB
    LDA $0E
    AND #$0030
    LSR 
    CLC 
    ADC #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_0689E8 )

  loc_0689DA:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_0689DA
} >
]

code_0689E6 {
    COP [Die]
}

code_0689E8 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0689F3 )
}

code_list_0689F3 [
  &code_068A0F   ;00
  &code_068A14   ;01
  &code_068A19   ;02
  &code_068A1E   ;03
  &code_068A23   ;04
  &code_068A28   ;05
  &code_068A2D   ;06
  &code_068A32   ;07
  &code_068A37   ;08
  &code_068A3C   ;09
  &code_068A41   ;0A
  &code_068A6B   ;0B
  &code_068A70   ;0C
  &code_068A75   ;0D
]

code_068A0F {
    COP [PrintDialogString] ( &dialogstring_068A7A )
    RTL 
}

code_068A14 {
    COP [PrintDialogString] ( &dialogstring_068B0F )
    RTL 
}

code_068A19 {
    COP [PrintDialogString] ( &dialogstring_068B94 )
    RTL 
}

code_068A1E {
    COP [PrintDialogString] ( &dialogstring_068BFB )
    RTL 
}

code_068A23 {
    COP [PrintDialogString] ( &dialogstring_068C28 )
    RTL 
}

code_068A28 {
    COP [PrintDialogString] ( &dialogstring_068C58 )
    RTL 
}

code_068A2D {
    COP [PrintDialogString] ( &dialogstring_068C98 )
    RTL 
}

code_068A32 {
    COP [PrintDialogString] ( &dialogstring_068CF1 )
    RTL 
}

code_068A37 {
    COP [PrintDialogString] ( &dialogstring_068D3F )
    RTL 
}

code_068A3C {
    COP [PrintDialogString] ( &dialogstring_068D83 )
    RTL 
}

code_068A41 {
    COP [BranchIfFlagByte] ( #85, #01, &code_068A6B )
    JSL $@chunk_028000.code_02A178
    BCS loc_068A65
    COP [GiveItem] ( #10, &code_068A66 )
    COP [SetFlagByte] ( #85 )
    COP [PrintDialogString] ( &dialogstring_068DD2 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @dialogstring_068DFE )

  loc_068A65:
    RTL 
}

code_068A66 {
    COP [PrintDialogString] ( &dialogstring_068E1D )
    RTL 
}

code_068A6B {
    COP [PrintDialogString] ( &dialogstring_068E65 )
    RTL 
}

code_068A70 {
    COP [PrintDialogString] ( &dialogstring_068E91 )
    RTL 
}

code_068A75 {
    COP [PrintDialogString] ( &dialogstring_068EC0 )
    RTL 
}

dialogstring_068A7A `[DEF]助かったぜ ぼうずっ![N]ありがとよっ!![FIN]おれは フリージアの町から[N]このきゅうでんへ 連れてこられて[N]まものに 変えられてたんだ···[FIN][TPL:2]リリィが ポケットの中から[N]話しかけてきた.[FIN]えーっ![N]じゃ さっきの まものたちは[N]みんな 人間だったわけ···?[PAL:0][END]`

dialogstring_068B0F `[DEF]さっき 殺される[N]しゅんかんっていうのを味わったわ.[N]死ぬことが あれほど[N]おそろしい ものだとは···[FIN]あなたは 何も 知らなかったん[N]だから 罪は ないけれど[N]私たちが 食料にしている動物たちも[N]あんな気分を 味わってるのかしら.[END]`

dialogstring_068B94 `[DEF]おれたちゃ もと ドレイ商人.[N]人身売買の罪で つかまって···[FIN]でも 役人の連中は おれたちを[N]キュウケツキに売りとばしやがった![N]もう 何も 信じられねえよ···[END]`

dialogstring_068BFB `[DEF]やれやれ···[N]美人の女の さそいに のって[N]ついてきたら このザマだ···[END]`

dialogstring_068C28 `[DEF]素敵な男が さそいを かけるから[N]ついてきたの···[N]もう 男なんて 信じないっ![END]`

dialogstring_068C58 `[DEF]このカンオケで ねおきしてるのは[N]まぎれもなく キュウケツキ.[N]やつらは とんでもねえことを[N]たくらんでやがる···[END]`

dialogstring_068C98 `[DEF]このきゅうでんに 住んでいるのは[N]キュウケツキの 夫婦です.[FIN]いたるところから 人間をつれてきて[N]まものに変え 労働力として[N]使っているんですよ···[END]`

dialogstring_068CF1 `[DEF]このきゅうでんは まぼろしの土地[N]ムー大陸へと つながっているの.[N]キュウケツキの 夫婦は そこで[N]何かを さがしてるみたい···[END]`

dialogstring_068D3F `[DEF]おれたちゃ まものに 変わりかけの[N]ところだったから 助かったが[N]あんたが くるのが あとー歩[N]おそかったらと思うと···[END]`

dialogstring_068D83 `[DEF]キュウケツキの 夫婦の話を 立聞き[N]したんだけど ムー大陸には[N]ミステリードールとかいう 人形が[N]ねむっているらしいわ···[END]`

dialogstring_068DD2 `[DEF]キュウケツキの女から カギをー個[N]かっぱらったんだ.[N]もっていきな.[FIN]`

dialogstring_068DFE `[CLR][SFX:0][DLY:9]海底きゅうでんのカギを手に入れた![PAU:78][END]`

dialogstring_068E1D `[DEF]キュウケツキの女から カギをー個[N]かっぱらったんだ.[FIN]もっていきなと いいたいところだが[N]持ち物が いっぱいのようだな··[END]`

dialogstring_068E65 `[DEF]きゅうでんの 最上階には[N]ムー大陸へつづく 通路が[N]あるらしいぜ.[END]`

dialogstring_068E91 `[DEF]こんな 海のまんなかに[N]おきざりになって おれたちゃ 今後[N]どうすりゃいいんだ···[END]`

dialogstring_068EC0 `[DEF]みんなで このきゅうでんを[N]のっとって 住んじゃうっていうのは[N]どうかしら?[END]`

actor_def_068EE9 [
  actor-def < #00, #02, #30, {

  code_068EEC:
    COP [BranchIfFlagWord] ( #$013A, #01, &code_068F90 )
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_068F92 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveX] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$0300
    STA $moveXAlt, X
    LDA #$009C
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3B )
    COP [StageBgChange] ( #3A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$013A )
    COP [WaitByte] ( #3B )
    LDA #$0300
    STA $14
    LDA #$00A0
    STA $16
    LDA #$2000
    TRB $10
    COP [PrintDialogString] ( &dialogstring_06904F )
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_068F90 {
    COP [Die]
}

code_068F92 {
    COP [BranchIfFlagByte] ( #6F, #01, &code_068F9D )
    COP [PrintDialogString] ( &dialogstring_068FA5 )
    RTL 
}

code_068F9D {
    COP [PrintDialogString] ( &dialogstring_068FC0 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_068FA5 `[DEF][TPL:0]テム:[N]かんおけが ならんでいる···[PAL:0][END]`

dialogstring_068FC0 `[DEF][TPL:0]テム:[N]かんおけの ふたは 開きそうに[N]ないな···[FIN][TPL:2]ポケットの中から[N]リリィが 話しかけてきた.[FIN][TPL:2]リリィ: ちょっと まって.[N]この かんおけって 穴があいてる[N]じゃない?[FIN]あたしなら 穴から 中に[N]入れそうだよね.[N]見てこよっか?[PAL:0][END]`

dialogstring_06904F `[DEF][TPL:2]リリィ: 変なの···[N]この かんおけって 内側に カギが[N]ついてるよ.[N]どうりで 開かないわけだよね.[PAL:0][END]`

actor_def_069091 [
  actor-def < #00, #02, #30, {

  code_069094:
    COP [BranchIfFlagWord] ( #$013B, #01, &code_069176 )
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_0691B4 )

  code_0690A3:
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveX] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$02C0
    STA $moveXAlt, X
    LDA #$009C
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3B )
    COP [StageBgChange] ( #3B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$013B )
    COP [WaitByte] ( #3B )
    LDA #$02C0
    STA $14
    LDA #$00A0
    STA $16
    LDA #$2000
    TRB $10
    JSL $@chunk_028000.code_02A178
    BCS loc_06917C
    COP [GiveItem] ( #11, &code_069178 )
    COP [PrintDialogString] ( &dialogstring_069247 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @dialogstring_06926E )
    COP [WaitByte] ( #03 )
    COP [SetEntryContinue]
    LDA #$CFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_069140
    RTL 

  loc_069140:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_069176 {
    COP [Die]
}

code_069178 {
    COP [PrintDialogString] ( &dialogstring_069286 )

  loc_06917C:
    COP [ClearFlagWord] ( #$013B )
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetTilePos] ( #2B, #0A )
    JMP $&code_0690A3
}

code_0691B4 {
    COP [BranchIfFlagByte] ( #6F, #01, &code_0691BF )
    COP [PrintDialogString] ( &dialogstring_0691C7 )
    RTL 
}

code_0691BF {
    COP [PrintDialogString] ( &dialogstring_0691E2 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_0691C7 `[DEF][TPL:0]テム:[N]かんおけが ならんでいる···[PAL:0][END]`

dialogstring_0691E2 `[DEF][TPL:2]ポケットの中から[N]リリィが 話しかけてきた.[FIN][TPL:2]リリィ:[N]この かんおけって 穴があいてる[N]じゃない?[FIN]あたしなら 穴から 中に[N]入れそうだよね.[N]見てこよっか?[PAL:0][END]`

dialogstring_069247 `[DEF][TPL:2]リリィ:[N]かんおけの中で 変な石を[N]見つけちゃった.[PAL:0][FIN]`

dialogstring_06926E `[CLR][SFX:0][DLY:9]じょうか石を 手に入れた![PAU:78][END]`

dialogstring_069286 `[DEF][TPL:2]リリィ:[N]かんおけの中で 変な石を[N]見つけちゃった.[FIN]でも 持ち物が いっぱいみたい[N]だね···[PAL:0][END]`

actor_def_0692C4 [
  actor-def < #26, #02, #03, {

  code_0692C7:
    STZ $066D
    COP [BranchIfFlagByte] ( #70, #01, &code_069370 )
    COP [BranchIfFlagByte] ( #6F, #00, &code_069370 )
    COP [BranchIfNoItem] ( #11, &code_0692DE )
    JMP $&code_069370
} >
]

code_0692DE {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_069372 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #0E, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [SpawnMarkedAfter] ( @code_0693AF, #$2000 )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetSpritePriority] ( #30 )
    COP [LoopInit] ( #40 )
    COP [SetEntryExit]
    COP [StageSpriteMoveY] ( #26, #02 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    LDA #$0100
    STA $moveXAlt, X
    LDA #$0160
    STA $moveYAlt, X
    COP [MoveToward] ( #26, #01 )
    LDA #$2000
    TSB $10
    SEP #$20
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_008000.code_00B8A1 )
    COP [SetFlagByte] ( #0F )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @chunk_008000.code_00B8A1 )
    COP [SpawnThinkerParam] ( #41, @chunk_008000.code_00B5C4 )
    COP [WaitWord] ( #$02B1 )
    COP [ClearFlagByte] ( #0F )
    COP [SetFlagByte] ( #70 )
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_069370 {
    COP [Die]
}

dialogstring_069372 `[DEF][TPL:2]リリィ:[N]あっ! 血で できた泉だ···[FIN]ここと さっきの石が[N]何か 関係してるのかな···?[PAL:0][END]`

code_0693AF {
    LDA $0036
    AND #$0003
    BNE loc_0693CA
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SpawnAfterFlags] ( @code_0693CB, #$0B02 )

  loc_0693CA:
    RTL 
}

code_0693CB {
    COP [RngByte]
    AND #$0003
    DEC 
    CLC 
    ADC $14
    STA $14
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}

actor_def_0693E2 [
  actor-def < #00, #00, #30, {

  code_0693E5:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #70, #01, &code_069415 )
    COP [BranchIfPlayerInAbsTiles] ( #37, #28, #38, #29, &code_069416 )
    COP [BranchIfPlayerInAbsTiles] ( #0E, #38, #0F, #39, &code_069424 )
    COP [BranchIfPlayerInAbsTiles] ( #2B, #59, #2C, #5A, &code_069432 )
    COP [BranchIfPlayerInAbsTiles] ( #36, #07, #3B, #0B, &code_069440 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #18, #0B, #1A, &code_06944E )
} >
]

code_069415 {
    RTL 
}

code_069416 {
    COP [BranchIfFlagByte] ( #71, #01, &code_069415 )
    COP [SetFlagByte] ( #71 )
    COP [PrintDialogString] ( &dialogstring_06945C )
    RTL 
}

code_069424 {
    COP [BranchIfFlagByte] ( #72, #01, &code_069415 )
    COP [SetFlagByte] ( #72 )
    COP [PrintDialogString] ( &dialogstring_0694B1 )
    RTL 
}

code_069432 {
    COP [BranchIfFlagByte] ( #73, #01, &code_069415 )
    COP [SetFlagByte] ( #73 )
    COP [PrintDialogString] ( &dialogstring_069500 )
    RTL 
}

code_069440 {
    COP [BranchIfFlagByte] ( #83, #01, &code_069415 )
    COP [SetFlagByte] ( #83 )
    COP [PrintDialogString] ( &dialogstring_069529 )
    RTL 
}

code_06944E {
    COP [BranchIfFlagByte] ( #84, #01, &code_069415 )
    COP [SetFlagByte] ( #84 )
    COP [PrintDialogString] ( &dialogstring_069551 )
    RTL 
}

dialogstring_06945C `[TPL:A][TPL:0][PRT]6[95][86][PAL:0]不思議な声:[N]ここは キュウケツキの 住む[N]きゅうでん···[FIN]このきゅうでんの 血の泉は[N]まものを 次々と 作り出し···[END]`

dialogstring_0694B1 `[TPL:A][TPL:0][PRT]6[95][86][PAL:0]不思議な声:[N]きゅうでんの ー番下の階には[N]血の泉がある···[FIN]そこに あの石を···[N]はやく は·や··く···[END]`

dialogstring_069500 `[TPL:A][TPL:0][PRT]6[95][86][PAL:0]不思議な声:[N]じょうか石は かんおけの中に···[END]`

dialogstring_069529 `[TPL:A][TPL:0]テム: おや?[N]右の部屋から 人の気配がする···[PAL:0][END]`

dialogstring_069551 `[TPL:A][TPL:0]テム: おや?[N]左の部屋から 人の気配がする···[PAL:0][END]`

dialogstring_069579 `テム: おや?[N]どこからか かぼそい声が 聞こえる[N]みたいだ···[FIN]`

actor_def_0695A0 [
  actor-def < #00, #00, #30, {

  code_0695A3:
    COP [BranchIfFlagByte] ( #7D, #01, &code_0695BB )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #14, #08, #16, #0C, &code_0695B4 )
    RTL 
} >
]

code_0695B4 {
    COP [SetFlagByte] ( #7D )
    COP [PrintDialogString] ( &dialogstring_0695BD )
}

code_0695BB {
    COP [Die]
}

dialogstring_0695BD `[TPL:A][TPL:2]ポケットの中から[N]リリィが 話しかけてきた.[FIN][TPL:2]リリィ: 長い通路だよね····[N]これ ほんとに ムー大陸に[N]つづいてるのかな···[PAL:0][END]`

actor_def_069616 [
  actor-def < #00, #00, #30, {

  code_069619:
    COP [BranchIfFlagByte] ( #7A, #01, &code_069637 )
    COP [BranchIfFlagByte] ( #78, #00, &code_069637 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0A, #30, #0C, #37, &code_069630 )
    RTL 
} >
]

code_069630 {
    COP [SetFlagByte] ( #7A )
    COP [PrintDialogString] ( &dialogstring_069639 )
}

code_069637 {
    COP [Die]
}

dialogstring_069639 `[DEF][TPL:2]ポケットの中から[N]リリィが 話しかけてきた.[FIN][TPL:2]リリィ: ねえ テム.[N]ちょっと 思ったんだけどさ,[FIN]この石像って 何かを 見つめてる[N]ように見えない?[FIN]ほら そこにある たからばこって[N]2つの石像の 視線が交わるところに[N]あるよね.[FIN]だったら 他の石像も 何かを[N]見つめてるんじゃないかと思って.[N]あたしの 思いすごしなのかな.[PAL:0][END]`

actor_def_069701 [
  actor-def < #00, #00, #30, {

  code_069704:
    COP [SetFlagByte] ( #78 )
    COP [SetOnInteract] ( &code_069711 )
    COP [ExitIfFlagByte] ( #79, #01 )
    COP [Die]
} >
]

code_069711 {
    JSL $@chunk_028000.code_02A178
    BCS loc_06972B
    COP [GiveItem] ( #12, &code_06972C )
    COP [SetFlagByte] ( #79 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @dialogstring_069731 )

  loc_06972B:
    RTL 
}

code_06972C {
    COP [PrintDialogString] ( &dialogstring_069776 )
    RTL 
}

dialogstring_069731 `[DEF][SFX:0][DLY:9]いのりの像を 見つけた![N][PAU:3C][DLY:2]いのりの像···[N][PAU:1E]どこかに 同じ名前の部屋が[N]なかっただろうか···[PAU:5A][END]`

dialogstring_069776 `[DEF]いのりの像を 見つけた![N]だが もちものが いっぱいで[N]これ以上 持つことが できない![END]`

actor_def_0697A9 [
  actor-def < #00, #00, #30, {

  code_0697AC:
    COP [SetOnInteract] ( &code_0697B6 )
    COP [ExitIfFlagByte] ( #7F, #01 )
    COP [Die]
} >
]

code_0697B6 {
    JSL $@chunk_028000.code_02A178
    BCS loc_0697D0
    COP [GiveItem] ( #12, &code_06972C )
    COP [SetFlagByte] ( #7F )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @dialogstring_0697D1 )

  loc_0697D0:
    RTL 
}

dialogstring_0697D1 `[DEF][SFX:0][DLY:9]いのりの像を 見つけた![N][PAU:3C][DLY:2]いのりの像···[N][PAU:1E]どこかに 同じ名前の部屋が[N]なかっただろうか···[PAU:5A][END]`

actor_def_069816 [
  actor-def < #0E, #00, #30, {

  code_069819:
    COP [BranchIfPlayerInAbsTiles] ( #10, #00, #20, #10, &code_06990A )
    COP [BranchIfFlagByte] ( #7B, #01, &code_0698F7 )
    COP [ExitIfFlagByte] ( #7B, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069904, #$0080, #$0058, #$1000 )
    COP [WriteApuIo0] ( #7F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SpawnThinker] ( @chunk_008000.code_00B88D )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0020, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$00E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0040, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$00C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0070, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0090, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0050, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0070, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0090, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$00B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0699ED )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
    COP [WaitByte] ( #7F )
    STZ $0688
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_0698F7 {
    COP [SpawnAfterAbsFlags] ( @code_069904, #$0080, #$0058, #$1000 )
    COP [Die]
}

code_069904 {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    RTL 
}

code_06990A {
    COP [BranchIfFlagByte] ( #7E, #01, &code_0699E0 )
    COP [ExitIfFlagByte] ( #7E, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069904, #$0180, #$0058, #$1000 )
    COP [WriteApuIo0] ( #7F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SpawnThinker] ( @chunk_008000.code_00B88D )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0120, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$01E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0140, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$01C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0170, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069A5C, #$0190, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0150, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0170, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$0190, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069A22, #$01B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_0699ED )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
    COP [WaitByte] ( #7F )
    STZ $0688
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_0699E0 {
    COP [SpawnAfterAbsFlags] ( @code_069904, #$0180, #$0058, #$1000 )
    COP [Die]
}

dialogstring_0699ED `[TPL:A]太陽のカミよ···[N]ラ·ムーよ···[FIN]大いなる 海に 力を[N]あたえたまえ···[END]`

code_069A22 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSprAndHitbox] ( #0E )
    COP [PlaySoundBoth] ( #$2626 )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]

  code_069A3D:
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #02, #00, &code_069A3D )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_069A5C {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [PlaySoundBoth] ( #$2525 )

  code_069A65:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #02, #00, &code_069A65 )
    COP [Die]
}

actor_def_069A72 [
  actor-def < #2D, #00, #30, {

  code_069A75:
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #80, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #81, #01 )
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #20, #20, &code_069AB2 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0303
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #66, #$00F8, #$01D8, #80, #$2200 )
} >
]

code_069AB2 {
    COP [SetEntryContinue]
    RTL 
}

actor_def_069AB5 [
  actor-def < #2D, #00, #30, {

  code_069AB8:
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #81, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_069ACD [
  actor-def < #00, #00, #30, {

  code_069AD0:
    COP [BranchIfPlayerInAbsTiles] ( #20, #00, #30, #10, &code_069AF7 )
    COP [BranchIfFlagByte] ( #82, #01, &code_069AF4 )
    COP [SetFlagByte] ( #82 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_069AFF )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_069AF4 {
    COP [SetEntryContinue]
    RTL 
}

code_069AF7 {
    LDA #$0100
    STA $cameraBoundsY
    COP [Die]
}

dialogstring_069AFF `[TPL:A][TPL:0]そこは ムーの人々の 墓場の[N]ようだった···[PAL:0][END]`

actor_def_069B23 [
  actor-def < #28, #01, #03, {

  code_069B26:
    COP [BranchIfSolid] ( &code_069B57 )
    LDA #$ABD8
    STA $statsPtr, X

  loc_069B31:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    LDA #$0101
    TRB $10
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDA #$0101
    TSB $10
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    BRA loc_069B31
} >
]

code_069B57 {
    COP [Die]
}

actor_def_069B59 [
  actor-def < #2A, #01, #03, {

  code_069B5C:
    LDA #$ABD8
    STA $statsPtr, X

  loc_069B63:
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0F, #01 )
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [WaitByte] ( #C7 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    BRA loc_069B63
} >
]

actor_def_069B87 [
  actor-def < #25, #00, #01, {

  code_069B8A:
    COP [BranchIfSolid] ( &code_069C74 )
    LDA #$0021
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E4B1, #$2400 )
    COP [SpawnMarkedBefore] ( @code_069BB3, #$2000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_069BB3 {
    COP [SetEntryContinue]
    LDY $06
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $playerWallType
    CLC 
    ADC #$0008
    CMP $14
    BNE loc_069BE9
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    CMP $16
    BNE loc_069BE9
    COP [BranchIfSolidWest] ( &code_069BDD )
    BRA loc_069C57
}

code_069BDD {
    COP [BranchIfSolidEast] ( &code_069BE3 )
    BRA loc_069C1D
}

code_069BE3 {
    COP [BranchIfSolidNorth] ( &code_069C3A )
    BRA loc_069C00

  loc_069BE9:
    COP [CardinalToPlayer]
    CMP #$0000
    BEQ loc_069C00
    CMP #$0001
    BEQ loc_069C1D
    CMP #$0002
    BEQ code_069C3A
    CMP #$0003
    BEQ loc_069C57
    RTL 

  loc_069C00:
    LDA $16
    SEC 
    SBC $playerSpeedEw
    SEC 
    SBC #$0010
    CMP #$0010
    BCC loc_069C10
    RTL 

  loc_069C10:
    STZ $09C0
    LDA #$FFF8
    STA $decelCurvePtr
    COP [PlaySoundCh2] ( #1D )
    RTL 

  loc_069C1D:
    LDA $playerWallType
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    CMP #$0010
    BCC loc_069C2D
    RTL 

  loc_069C2D:
    LDA #$0008
    STA $09C0
    STZ $decelCurvePtr
    COP [PlaySoundCh2] ( #1D )
    RTL 
}

code_069C3A {
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    SEC 
    SBC $16
    CMP #$0010
    BCC loc_069C4A
    RTL 

  loc_069C4A:
    STZ $09C0
    LDA #$0008
    STA $decelCurvePtr
    COP [PlaySoundCh2] ( #1D )
    RTL 

  loc_069C57:
    LDA $14
    SEC 
    SBC $playerWallType
    SEC 
    SBC #$0008
    CMP #$0010
    BCC loc_069C67
    RTL 

  loc_069C67:
    LDA #$FFF8
    STA $09C0
    STZ $decelCurvePtr
    COP [PlaySoundCh2] ( #1D )
    RTL 
}

code_069C74 {
    COP [Die]
}

actor_def_069C76 [
  actor-def < #00, #00, #30, {

  code_069C79:
    COP [BranchIfFlagWord] ( #$0139, #01, &code_069D57 )
    COP [AddPosition] ( #08, #02 )
    COP [SetOnInteract] ( &code_069D59 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$00B8, #$0080, #$1000 )
    LDA #$0000
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$0148, #$00A0, #$1000 )
    LDA #$0001
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$0188, #$00E0, #$1000 )
    LDA #$0002
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$0138, #$0120, #$1000 )
    LDA #$0003
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$00D8, #$0100, #$1000 )
    LDA #$0004
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_069E4E, #$0078, #$0140, #$1000 )
    LDA #$0005
    STA $0024, Y
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$80
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitByte] ( #7F )
    COP [StageBgChange] ( #39 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0139 )
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    COP [WaitByte] ( #7F )
    LDA #$0002
    STA $0AAC
    LDA #$0066
    STA $0B12
    LDA #$000F
    STA $0B08
    STA $0B0A
    LDA #$0007
    STA $0B0C
    STA $0B0E
    LDA #$2200
    STA $0B10
    LDA #$0104
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
} >
]

code_069D57 {
    COP [Die]
}

code_069D59 {
    LDA $eventFlags
    AND #$00FF
    CMP #$00FE
    BEQ loc_069D77
    COP [BranchIfFlagByte] ( #01, #01, &code_069D72 )
    COP [PrintDialogString] ( &dialogstring_069D7F )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_069D72 {
    COP [PrintDialogString] ( &dialogstring_069DEB )
    RTL 

  loc_069D77:
    COP [PrintDialogString] ( &dialogstring_069E0D )
    COP [SetFlagByte] ( #0F )
    RTL 
}

dialogstring_069D7F `[DEF]私は ムー大陸の王 ラ·ムー.[N]肉体は はるかむかしに なくしたが[N]精神だけは 生きつづけている.[FIN]さあ よく 目をこらしてみなさい.[N]さまよえる たましいたちが[N]見えるはずだ.[END]`

dialogstring_069DEB `[DEF]ねむりからさめた たましいたちの[N]言葉を聞いてくるがよい.[END]`

dialogstring_069E0D `[DEF]人々が ほり進んだ 海底トンネルは[N]この おくにある.[FIN]そして この ミステリードールを[N]もっていきなさい.[END]`

code_069E4E {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SetOnInteract] ( &code_069E8F )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
}

code_069E8F {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_069E9A )
}

code_list_069E9A [
  &code_069EA6   ;00
  &code_069EAE   ;01
  &code_069EB6   ;02
  &code_069EBE   ;03
  &code_069EC6   ;04
  &code_069ECE   ;05
]

code_069EA6 {
    COP [PrintDialogString] ( &dialogstring_069ED6 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_069EAE {
    COP [PrintDialogString] ( &dialogstring_069F0A )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_069EB6 {
    COP [PrintDialogString] ( &dialogstring_069F74 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_069EBE {
    COP [PrintDialogString] ( &dialogstring_069FC0 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_069EC6 {
    COP [PrintDialogString] ( &dialogstring_069FED )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_069ECE {
    COP [PrintDialogString] ( &dialogstring_06A087 )
    COP [SetFlagByte] ( #07 )
    RTL 
}

dialogstring_069ED6 `[DEF]あるとき 天空から ひとすじの光が[N]さしこんだ.[N]我々は 神の光だと思いひれふした.[END]`

dialogstring_069F0A `[DEF]神の光を見た日から ー年がすぎ[N]我々の体に 変化が起こりはじめた.[FIN]ある者は やせほそり[N]ある者は 岩のようになり[N]また あるものは 水のように 体が[N]とけていったのだ···[END]`

dialogstring_069F74 `[DEF]家族や 友人が 目前で 化け物の[N]姿に 変化し おそいかかってくる.[N]我々は なみだを流しながら[N]武器をふるう···[END]`

dialogstring_069FC0 `[DEF]こんなことが 続くなら[N]生きていることに いったい 何の[N]意味があろう···[END]`

dialogstring_069FED `[DEF]おそろしさに たえきれず[N]ここから にげ出そうと 考える者も[N]少なくない.[FIN]しかし ム-大陸は 大海原の島.[N]生きて 他の場所へ たどりつける[N]保障は どこにもない···[FIN]この島には 船の材料がないのだ.[N]石で組み立てても すぐに しずんで[N]しまう···[END]`

dialogstring_06A087 `[DEF]人々は 海底トンネルをほり始めた.[N]何百年 いや 何千年かかるか[N]わからない計画に のぞみをたくして[N]ひたすら ほり続ける···[END]`

actor_def_06A0D9 [
  actor-def < #0C, #00, #10, {

  code_06A0DC:
    LDA $characterForm
    BEQ loc_06A0E6
    LDA #$FFFF
    STA $24

  loc_06A0E6:
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06A16A )
    COP [BranchIfFlagByte] ( #86, #01, &code_06A120 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_06A10A )
    RTL 
} >
]

code_06A10A {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #17 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06A186 )
    COP [SetFlagByte] ( #86 )
}

code_06A120 {
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$2000
    TSB $10
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$2000
    TRB $10
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #0E, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #11, #13 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06A16A {
    COP [BranchIfFlagByte] ( #01, #01, &code_06A175 )
    COP [PrintDialogString] ( &dialogstring_06A1AD )
    RTL 
}

code_06A175 {
    LDA $24
    CMP #$FFFF
    BEQ loc_06A181
    COP [PrintDialogString] ( &dialogstring_06A1FC )
    RTL 

  loc_06A181:
    COP [PrintDialogString] ( &dialogstring_06A1CE )
    RTL 
}

dialogstring_06A186 `[DEF][TPL:3]エリック:[N]うわああああああん···[N]だれか 助けてえっ!![PAL:0][END]`

dialogstring_06A1AD `[DEF][TPL:3]まずは ばくだんを とめてよおっ!はやく はやくっ!![PAL:0][END]`

dialogstring_06A1CE `[DEF][TPL:3]エリック:[N]テムが 変身してたことは[N]だれにも 言わないでおくよ.[PAL:0][END]`

dialogstring_06A1FC `[DEF][TPL:3]エリック:[N]また テムに たすけられちゃった[N]なあ····[PAL:0][END]`

actor_def_06A223 [
  actor-def < #21, #00, #10, {

  code_06A226:
    COP [SpawnMarkedAfterAbs] ( @code_06A47E, #$0078, #$00F0, #$2300 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06A2D9 )

  loc_06A244:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    LDA $0AEC
    BNE loc_06A244
    LDA $characterForm
    BEQ loc_06A279
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_06A279
    RTL 

  loc_06A279:
    COP [StageBgChange] ( #46 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #47 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0146 )
    COP [SetFlagWord] ( #$0147 )

  code_06A28B:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_06A28B )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$2C2C )
    COP [SetOnInteract] ( #$0000 )
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #3C )
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    LDA #$2000
    TSB $10
    COP [LoopNext]
    COP [AddPosition] ( #F8, #00 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #01, #00 )
    COP [PrintDialogString] ( &dialogstring_06A367 )
    COP [SetFlagByte] ( #03 )
    COP [StageBgChange] ( #93 )
    COP [ApplyBgChange]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_06A2D9 {
    COP [PrintDialogString] ( &dialogstring_06A2FC )
    COP [WriteApuIo0] ( #7F )
    COP [DialogueOptions] ( #02, #01, &code_list_06A2E6 )
}

code_list_06A2E6 [
  &code_06A2EC   ;00
  &code_06A2EC   ;01
  &code_06A2F4   ;02
]

code_06A2EC {
    COP [PrintDialogString] ( &dialogstring_06A341 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_06A2F4 {
    COP [PrintDialogString] ( &dialogstring_06A354 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_06A2FC `[TPL:E][TPL:0]ばくだんからは 赤い線と 青い線が[N]2本 出ているようだ···[FIN]どっちを 切りますか?[N] 赤いほう[N] 青いほう`

dialogstring_06A341 `[CLR]赤い線を 引きちぎった![PAL:0][END]`

dialogstring_06A354 `[CLR]青い線を 引きちぎった![PAL:0][END]`

dialogstring_06A367 `[PAU:28][TPL:A][TPL:0]テム:[N]どうやら ばくだんは[N]止まった みたいだった···[FIN][TPL:3]エリック:[N]たすかったあ···[FIN][TPL:2]ポケットの中から[N]リリィが 話しかけてきた.[FIN]リリィ: ごめんね テム···[N]あたし いっしょにいたのに[N]何にも できなかった···[FIN]足がすくんで ぜんぜん[N]動けないし 声も出ないし···[N]テムは やっぱり 男の子だよね.[FIN]いままで 自分をしっかりしてるって[N]思ってたけど いざとなると[N]これだもん···[FIN]·········.[N]ごめん もう しばらく[N]ポケットの 中に いさせて.[PAL:0][END]`

code_06A47E {
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SpawnMarkedAfterRel] ( @code_06A5A6, #00, #01, #$1002 )
    COP [SpawnMarkedAfterRel] ( @code_06A5A6, #08, #01, #$1002 )
    COP [SpawnMarkedAfterRel] ( @code_06A5A6, #10, #01, #$1002 )
    LDA #$0240
    STA $26
    LDA #$0000
    STA $orbitAngle, X

  code_06A4A9:
    COP [BranchIfFlagByte] ( #01, #01, &code_06A55A )
    LDA #$003B
    STA $24
    COP [SetEntryContinue]
    DEC $24
    BMI loc_06A4BB
    RTL 

  loc_06A4BB:
    COP [PlaySoundCh1] ( #10 )
    SED 
    LDA $26
    SEC 
    SBC #$0001
    STA $26
    CLD 
    BPL loc_06A4CD
    JMP $&code_06A55C

  loc_06A4CD:
    LDA $26
    AND #$000F
    PHA 
    LDY $06
    JSR $&code_06A550
    LDA $orbitAngle, X
    AND #$FFF0
    ORA $01, S
    STA $orbitAngle, X
    STA $01, S
    PLA 
    CMP $26
    BEQ code_06A4A9
    LDA $0006, Y
    TAY 
    LDA $26
    AND #$00F0
    PHA 
    BNE loc_06A4FF
    LDA $26
    AND #$0F00
    BEQ loc_06A53D

  loc_06A4FF:
    LDA $01, S
    LSR 
    LSR 
    LSR 
    LSR 
    JSR $&code_06A550
    LDA $orbitAngle, X
    AND #$FF0F
    ORA $01, S
    STA $orbitAngle, X
    STA $01, S
    PLA 
    CMP $26
    BEQ code_06A4A9
    LDA $0006, Y
    TAY 
    LDA $26
    AND #$0F00
    BEQ loc_06A53E
    PHA 
    XBA 
    JSR $&code_06A550
    LDA $orbitAngle, X
    AND #$F0FF
    ORA $01, S
    STA $orbitAngle, X
    PLA 
    JMP $&code_06A4A9

  loc_06A53D:
    PLA 

  loc_06A53E:
    LDA $26
    STA $orbitAngle, X
    PHX 
    PHD 
    TYA 
    TCD 
    TAX 
    COP [MarkDeath]
    PLD 
    PLX 
    JMP $&code_06A4A9
}

code_06A550 {
    STA $002A, Y
    LDA #$A5A9
    STA $0000, Y
    RTS 
}

code_06A55A {
    COP [Die]
}

code_06A55C {
    LDA $0AEC
    BEQ loc_06A577
    COP [WriteApuIo0] ( #7F )
    STZ $0688
    COP [PlaySoundBoth] ( #$1515 )
    SEP #$20
    LDA #$00
    STA $playerHp
    REP #$20
    COP [SetEntryContinue]
    RTL 

  loc_06A577:
    COP [PrintDialogString] ( &dialogstring_06A57E )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06A57E `[DEF][TPL:0]············[FIN]不発だったんだ···[N]助かった···[PAL:0][END]`

code_06A5A6 {
    COP [StageSprAndHitbox] ( #22 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    RTL 
}

actor_def_06A5B0 [
  actor-def < #13, #00, #30, {

  code_06A5B3:
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #19, #0F, #1B, &code_06A5C2 )
    RTL 
} >
]

code_06A5C2 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #04 )
    COP [Decompress] ( @gfx_nazca_sprites, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_nazca_sprites, #00, #A0, #50 )
    COP [Decompress] ( @spm_nazca_sprites, $7E4000 )
    COP [SetFlagByte] ( #88 )
    COP [StartMusic] ( #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #17, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #45 )
    COP [PrintDialogString] ( &dialogstring_06A632 )
    COP [SpawnAfterFlags] ( @code_06A85F, #$1002 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06A632 `[TPL:A][TPL:6]ニール:[N]テムっ! 無事かっ?![FIN][TPL:4]ロブ: テムっ![N]リリィの姿が 見あたらないけど[N]リリィは どうしたっ?![FIN][TPL:2]リリィ:[N]ここに いるよっ.[PAL:0][END]`

actor_def_06A694 [
  actor-def < #03, #00, #30, {

  code_06A697:
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [WaitByte] ( #1D )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_06A6B2 [
  actor-def < #1B, #00, #30, {

  code_06A6B5:
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [WaitByte] ( #1D )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06A700 )
    LDA #$0000
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0070, #$00C0, #00, #$1200 )
    COP [SetEntryContinue]
    RTL 
} >
]

dialogstring_06A700 `[TPL:A][TPL:1]カレン:[N]そんなの どうでも いいじゃない![FIN]それより ムー大陸から どうやって[N]出るかを 考えましょっ![FIN][TPL:2]リリィ: それなら だいじょうぶ.[N]さっき ラ·ムーとか いう人から[N]いいこと 聞いちゃったもの.[FIN][TPL:0]テムは ムー大陸のことや[N]海底トンネルを わたった人々の[N]ことを みんなに 話した···[FIN][TPL:1]カレン:[N]悲しい話ね···[FIN]いっしょに くらしてた人たちが[N]はなればなれになって しかも[N]片方は 海の底なんて···[FIN][TPL:6]ニール: とにかく その[N]海底トンネルを 通っていけば[N]近くの大陸へ 出られるってわけか.[FIN][TPL:4]ロブ: よしっ![N]そうと決まれば さっそく出発だっ![PAL:0][END]`

code_06A85F {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveY] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$00A8
    STA $moveXAlt, X
    LDA #$01B0
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    COP [StageSpriteLoop] ( #33, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06A8C4 )
    COP [SetFlagByte] ( #05 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06A8FE )
    COP [SetFlagByte] ( #06 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06A8C4 `[TPL:A][TPL:2]リリィ: 心配 させてごめんね.[N]でも テムが 守ってくれたから[N]あたしは 平気っ.[PAL:0][END]`

dialogstring_06A8FE `[TPL:A][TPL:6]ニール: へえ.[N]テムも なかなか 男らしいところが[N]出てきたじゃないか.[PAL:0][END]`

actor_def_06A930 [
  actor-def < #08, #00, #18, {

  code_06A933:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06A93F )
} >
]

code_list_06A93F [
  &code_06A945   ;00
  &code_06A956   ;01
  &code_06A956   ;02
]

code_06A945 {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #08 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_06A956 {
    COP [Die]
}

actor_def_06A958 [
  actor-def < #12, #00, #10, {

  code_06A95B:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06A967 )
} >
]

code_list_06A967 [
  &code_06A96D   ;00
  &code_06A9B1   ;01
  &code_06A9B3   ;02
]

code_06A96D {
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06A9D6 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #3F )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_06A9D1 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #00, #0C, #10, &code_06A9A0 )
    RTL 
}

code_06A9A0 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #03 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06A9B1 {
    COP [Die]
}

code_06A9B3 {
    COP [SetTilePos] ( #18, #1A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06AB7D )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06ABAE )
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    RTL 
}

code_06A9D1 {
    COP [PrintDialogString] ( &dialogstring_06AB1B )
    RTL 
}

dialogstring_06A9D6 `[TPL:A][TPL:0]海底トンネルに 入って[N]5日が すぎた.[FIN]行けども 行けども 同じような[N]景色が つづく.[N]気が 遠くなりそうだった···[WAI][CLD][PAU:28][TPL:A][TPL:6]ニール:[N]今日は このあたりで 休むと[N]しようか.[FIN][TPL:3]エリック: つかれたあ.[N]今日は 1000キロくらい[N]歩いたかな.[FIN][TPL:4]ロブ: ばかだな.[N]人間の足で そんなに 歩けるわけ[N]ねえだろっ.[FIN][TPL:1]カレン: もーう やだっ![N]もう 旅に出てから つかれること[N]しか ないんだものっ.[FIN][TPL:2]リリィ:[N]みんな 同じこと 思ってるんだから[N]声に だして言わないのっ![FIN]それより ごはんにしよ.[N]おなか すいちゃった.[PAL:0][END]`

dialogstring_06AB1B `[TPL:A][TPL:6]ニール:[N]何千年も むかしに この地下道を[N]歩いた人たちが いたんだなあ.[FIN]なんだか 遠い過去を 想像してると[N]自分が ちっぽけに 思えてくるよ.[PAL:0][END]`

dialogstring_06AB7D `[TPL:A][TPL:0]海底トンネルに入って 2週間.[N]今だに 出口は 見えない···[PAL:0][END]`

dialogstring_06ABAE `[TPL:A][TPL:1]カレン: ねえねえ.[N]ゆうべ ねているとき 上の方から[N]不気味な 物音が しなかった?[FIN][TPL:4]ロブ:[N]カレンは よく そんな物音に[N]気がつくなあ···[FIN]つかれはてて それどころじゃ[N]なかったよ.[PAL:0][END]`

actor_def_06AC25 [
  actor-def < #0A, #00, #10, {

  code_06AC28:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AC34 )
} >
]

code_list_06AC34 [
  &code_06AC3A   ;00
  &code_06AC9A   ;01
  &code_06AC9C   ;02
]

code_06AC3A {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #10, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06ACA3 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06ACCE )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0070, #$01A0, #03, #$2110 )
    COP [SetEntryContinue]
    RTL 
}

code_06AC9A {
    COP [Die]
}

code_06AC9C {
    COP [SetTilePos] ( #17, #1A )
    COP [SetEntryContinue]
    RTL 
}

code_06ACA3 {
    COP [PrintDialogString] ( &dialogstring_06ACA8 )
    RTL 
}

dialogstring_06ACA8 `[TPL:A][TPL:3]エリック:[N]おしっこ するんだから 見に[N]こないでよっ![PAL:0][END]`

dialogstring_06ACCE `[TPL:A][TPL:0]こうして また ー日が ゆっくりと[N]すぎていった···[PAL:0][END]`

actor_def_06ACF2 [
  actor-def < #05, #00, #10, {

  code_06ACF5:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AD01 )
} >
]

code_list_06AD01 [
  &code_06AD07   ;00
  &code_06AD32   ;01
  &code_06AD34   ;02
]

code_06AD07 {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06AD40 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06AD32 {
    COP [Die]
}

code_06AD34 {
    COP [SetTilePos] ( #18, #1D )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06AD40 {
    COP [PrintDialogString] ( &dialogstring_06AD45 )
    RTL 
}

dialogstring_06AD45 `[TPL:A][TPL:4]ロブ:[N]この地下道って いったい どこまで[N]つづいてるんだろう···[PAL:0][END]`

actor_def_06AD73 [
  actor-def < #1C, #00, #10, {

  code_06AD76:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AD82 )
} >
]

code_list_06AD82 [
  &code_06AD88   ;00
  &code_06ADC5   ;01
  &code_06ADC7   ;02
]

code_06AD88 {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #1E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06AEA8 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06AF0C )
    COP [SetFlagByte] ( #04 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06ADC5 {
    COP [Die]
}

code_06ADC7 {
    COP [SetTilePos] ( #15, #1B )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #59 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #1B, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06AF64 )
    COP [CallScript] ( &code_06AE50 )
    COP [WaitByte] ( #3B )
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_06AF95 )
    COP [WaitByte] ( #59 )
    COP [CallScript] ( &code_06AE80 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_06AFF7 )
    COP [WaitByte] ( #3B )
    COP [CallScript] ( &code_06AE80 )
    COP [PrintDialogString] ( &dialogstring_06B08F )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06B1EA )
    JSL $@chunk_008000.code_00B57A
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    COP [SetEntryContinue]
    RTL 
}

code_06AE50 {
    COP [WaitByte] ( #27 )
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2800 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #02 )
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2800 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #17 )
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_06AE80 {
    COP [LoopInit] ( #02 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #09 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #09 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_06AEA8 {
    COP [PrintDialogString] ( &dialogstring_06AEAD )
    RTL 
}

dialogstring_06AEAD `[TPL:A][TPL:1]カレン:[N]あーあ ステーキが食べたいっ![N]サラダも 食べたいっ!![FIN]変なものばっかり 食べてるから[N]もう ハダが がさがさになって[N]きちゃった···[PAL:0][END]`

dialogstring_06AF0C `[TPL:A][TPL:1]カレン: があああん.[N]テムが また キノコを 見つけて[N]きたわ···[FIN][TPL:2]リリィ:[N]死ぬよりいいと 思わなきゃ.[N]さあ ごはんに しよっ.[PAL:0][END]`

dialogstring_06AF64 `[TPL:A][TPL:1]カレン: ほらっ.[N]今も 聞こえたわっ!![N]何かしら··· あの音···[PAL:0][END]`

dialogstring_06AF95 `[TPL:A][TPL:3][DLY:3]エリック:[N]もしかして リバイヤサン···?[FIN][TPL:1][DLY:0]カレン:[N]たいへんっ!![N]にげなくっちゃ!!![FIN][TPL:2]リリィ:[N]にげるって いったい どこへ[N]にげるわけっ?![PAL:0][END]`

dialogstring_06AFF7 `[TPL:A][TPL:6]ニール:[N]みんな 静かにっ!![N]この しんどうの 連続音···[FIN]これは モールス信号だ···[FIN]音の長さが 言葉になっている信号で[N]船同士が 連らくを とりあうときに[N]使われている 合図なんだよ.[FIN]ちょっと 解読してみるから[N]まってくれ···[PAL:0][END]`

dialogstring_06B08F `[TPL:A][TPL:5][DLY:5]ぼくは モリス···[FIN][TPL:4][DLY:0]ロブ:[N]モリスだって?!!![FIN][TPL:2][DLY:1]リリィ:[N]しっ. 静かにっ.[N][DLY:2]ニール 先を 続けて.[FIN][TPL:5][DLY:5]ぼくは リバイヤサンに[N]飲みこまれました····[FIN]そして 気づいた時には[N]体が リバイヤサンの姿に なって[N]いたのです.[FIN]この リバイヤサンという生物は[N]海の中で生活する 人間なのかも[N]しれませんね.[FIN]仲間の リバイヤサンの話では[N]すい星の光で 生き物の 進化が[N]おかしくなっているとか.[FIN]ぼくも いっしょに[N]旅を 続けたかったけど 今は[N]こんな体 ですからね.[FIN]どうか がんばって[N]すい星と イセキのなぞを[N]解き明かしてください····[PAL:0][END]`

dialogstring_06B1EA `[TPL:A][TPL:6]ニール:[N]もう 何も 聞こえなくなった···[FIN][TPL:1][DLY:4]カレン:[N]モリス····[N]かわいそうに·····[FIN][TPL:4][DLY:3]ロブ: そういえば あいつ[N]モールス信号について 勉強してた[N]もんなあ.[FIN]モリスも いきなこと してくれる[N]じゃねえか.[FIN][TPL:3][DLY:2]エリック:[N]でも モリスは 人間の姿じゃ[N]なくなっちゃたんだよっ!![FIN][TPL:6]ニール:[N]いや エリック.[N]そう 決めつけるのはよくないな.[FIN]人間の体が ー番なんて[N]思っているのは 案外と ぼくら[N]人間だけなのかも しれないぞ.[FIN]さあ.[N]元気を出して 先を急ごう!![PAL:0][END]`

actor_def_06B319 [
  actor-def < #23, #00, #10, {

  code_06B31C:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06B328 )
} >
]

code_list_06B328 [
  &code_06B32E   ;00
  &code_06B34C   ;01
  &code_06B39E   ;02
]

code_06B32E {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3F )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B3A5 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06B34C {
    COP [SetTilePos] ( #11, #1C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06B41C )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #28 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #28, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06B459 )
    LDA #$0003
    JSL $@chunk_008000.dialogstring_00C829
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_06B46E )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0160, #$01C0, #00, #$2211 )
    COP [SetEntryContinue]
    RTL 
}

code_06B39E {
    COP [SetTilePos] ( #19, #1D )
    COP [SetEntryContinue]
    RTL 
}

code_06B3A5 {
    COP [PrintDialogString] ( &dialogstring_06B3AA )
    RTL 
}

dialogstring_06B3AA `[TPL:A][TPL:2]リリィ:[N]人間って 不思議だよね···[FIN]極限じょうたいになると[N]何が食べられて 何が毒なのか[N]ー目で わかっちゃうんだもん.[FIN]もしかすると むかしの人って[N]みんな そうだったのかな.[PAL:0][END]`

dialogstring_06B41C `[TPL:A][TPL:0]海底トンネルに入って 8日目.[N]ぼくは ねつかれず[N]地下水の流れを 見つめていた··[PAL:0][END]`

dialogstring_06B459 `[TPL:A][TPL:2]リリィ:[N]ねむれないの?[PAL:0][END]`

dialogstring_06B46E `[PAU:1E][TPL:A][TPL:0]テム: うん.[N]お腹が すいてさ.[N]っていうのは じょうだんだけど.[FIN][TPL:2]リリィ: テムってさ.[N]旅を つづけるうちに ずいぶん[N]変わったよね.[FIN]なんだか[N]大人っぽくなったって いうかさ.[FIN][TPL:0]テム:[N]自分でも よく わかんないん[N]だけど···[FIN]ぼくは 不思議な力が 使えるし[N]それに 戦士の姿に 変身するのも[N]見たろ?[FIN]ぼくの体に 変化がおこったのは[N]以前 父さんと バベルのとうに[N]探険に いった時からなんだ.[FIN]この旅で ぼくの力の 秘密が[N]わかりそうな 気がするんだよ.[FIN]それより リリィは なんで[N]危険な旅に ついてきたわけ?[FIN][TPL:2]リリィ:[N]最初は 面白半分だったんだけどね.[N]でも 今は ないしょ. エヘヘ.[FIN]明日は また いっぱい 歩かなきゃ[N]ならないし···[N]もう そろそろ ねなくちゃね.[PAL:0][END]`

actor_def_06B614 [
  actor-def < #36, #00, #10, {

  code_06B617:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06B623 )
} >
]

code_list_06B623 [
  &code_06B629   ;00
  &code_06B640   ;01
  &code_06B640   ;02
]

code_06B629 {
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B637 )
    COP [SetEntryContinue]
    RTL 
}

code_06B637 {
    COP [PrintDialogString] ( &dialogstring_06B642 )
    COP [ClearLowHere]
    COP [SetFlagByte] ( #02 )
}

code_06B640 {
    COP [Die]
}

dialogstring_06B642 `[TPL:A][TPL:0]この キノコは トンネル内の[N]いたるところに 生えている.[N]ぼくらの ゆいいつの 食料だ.[FIN]昨日は 燒きキノコ.[N]おとといは ゆでキノコ.[FIN]さきおとといは 生で食べたら[N]おそろしく まずかった···[FIN]でも ぜいたくは言っていられない.[N]生きるためには がまんしてでも[N]お腹に入れなくては···[PAL:0][END]`

actor_def_06B6F0 [
  actor-def < #00, #00, #38, {

  code_06B6F3:
    LDA #$1000
    TSB $12
    LDA $0036
    AND #$003F
    BEQ loc_06B701
    RTL 

  loc_06B701:
    COP [RngByte]
    AND #$0003
    BEQ loc_06B710
    COP [SpawnAfterFlags] ( @code_06B718, #$0B02 )
    RTL 

  loc_06B710:
    COP [SpawnAfterFlags] ( @code_06B757, #$0B02 )
    RTL 
} >
]

code_06B718 {
    JSR $&code_06B79D
    COP [StageSpriteLoopMoveY] ( #35, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #05 )
    COP [AnimLoop]

  code_06B737:
    COP [StageSpriteMoveY] ( #35, #07 )
    COP [AnimOnce]
    COP [BranchIfSolid] ( &code_06B737 )

  loc_06B741:
    COP [StageSpriteMoveY] ( #35, #07 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE loc_06B755
    COP [RngByte]
    AND #$0007
    BNE loc_06B741

  loc_06B755:
    COP [Die]
}

code_06B757 {
    JSR $&code_06B79D
    COP [StageSpriteLoopMoveY] ( #34, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #07 )
    COP [AnimLoop]

  code_06B77D:
    COP [StageSpriteMoveY] ( #34, #0B )
    COP [AnimOnce]
    COP [BranchIfSolid] ( &code_06B77D )

  loc_06B787:
    COP [StageSpriteMoveY] ( #34, #0B )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE loc_06B79B
    COP [RngByte]
    AND #$0007
    BNE loc_06B787

  loc_06B79B:
    COP [Die]
}

code_06B79D {
    LDA $cameraTargetY
    STA $16
    COP [RngByte]
    CLC 
    ADC $cameraTargetX
    STA $14
    RTS 
}

code_06B7AB {
    LDA $0E
    AND #$000F
    STA $24
    LDA #$2000
    STA $0E
    LDA #$2000
    TRB $10
    LDA #$1000
    TSB $10
    RTL 
}

actor_def_06B7C2 [
  actor-def < #05, #00, #10, {

  code_06B7C5:
    JSL $@code_06B7AB
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B7E1 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_06B7E1 {
    LDA $24
    BNE loc_06B7EA
    COP [PrintDialogString] ( &dialogstring_06B7EF )
    RTL 

  loc_06B7EA:
    COP [PrintDialogString] ( &dialogstring_06B822 )
    RTL 
}

dialogstring_06B7EF `[DEF]旅人の方は こちらの部屋を[N]お使い下さい.[N]             だ天使族[END]`

dialogstring_06B822 `[DEF]だ天使の町 入口[END]`

actor_def_06B831 [
  actor-def < #03, #00, #10, {

  code_06B834:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06B8A4 )
    COP [BranchIfFlagByte] ( #75, #01, &code_06B8A4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06B8A6 )
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06B8FE )
    COP [SetFlagByte] ( #01 )
    COP [StageSpriteLoop] ( #05, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [SetFlagByte] ( #75 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #13 )
    COP [AnimLoop]
} >
]

code_06B8A4 {
    COP [Die]
}

dialogstring_06B8A6 `[TPL:A][TPL:6]ニール: ようやく ついたな.[N]結局 海底トンネルを ーカ月近く[N]歩いたんだなあ···[FIN][TPL:4]ロブ:[N]あれ? 立てふだが あるぜ.[PAL:0][END]`

dialogstring_06B8FE `[TPL:A][TPL:4]ロブ:[N]なになに? だ天使族?[N]旅人は この部屋を使ってください?[FIN][TPL:6]ニール: だ天使族っていうのは[N]こんなところに 住んでいたのか··[FIN][TPL:6]ニール: 彼らは 自分から[N]人に会いたがらないっていうからな.[FIN]まずは その部屋で 休ませてもらう[N]とするか···[PAL:0][END]`

actor_def_06B9A0 [
  actor-def < #04, #00, #10, {

  code_06B9A3:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06B8A4 )
    COP [BranchIfFlagByte] ( #8C, #01, &code_06B9B8 )
    COP [SetOnInteract] ( &code_06B9CA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06B9B8 {
    COP [SetTilePos] ( #1C, #0C )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B9C5 )
    COP [SetEntryContinue]
    RTL 
}

code_06B9C5 {
    COP [PrintDialogString] ( &dialogstring_06BD3F )
    RTL 
}

code_06B9CA {
    COP [BranchIfFlagByte] ( #74, #01, &code_06BA08 )
    COP [SetFlagByte] ( #74 )
    COP [PrintDialogString] ( &dialogstring_06BA0D )
    COP [DialogueOptions] ( #02, #01, &code_list_06B9DD )
}

code_list_06B9DD [
  &code_06B9E7   ;00
  &code_06B9E3   ;01
  &code_06B9E7   ;02
]

code_06B9E3 {
    COP [PrintDialogString] ( &dialogstring_06BABC )
}

code_06B9E7 {
    COP [PrintDialogString] ( &dialogstring_06BAEE )

  code_06B9EB:
    COP [DialogueOptions] ( #03, #00, &code_list_06B9F1 )
}

code_list_06B9F1 [
  &code_06B9EB   ;00
  &code_06B9F9   ;01
  &code_06B9FE   ;02
  &code_06BA03   ;03
]

code_06B9F9 {
    COP [PrintDialogString] ( &dialogstring_06BBB7 )
    RTL 
}

code_06B9FE {
    COP [PrintDialogString] ( &dialogstring_06BC25 )
    RTL 
}

code_06BA03 {
    COP [PrintDialogString] ( &dialogstring_06BCA4 )
    RTL 
}

code_06BA08 {
    COP [PrintDialogString] ( &dialogstring_06BCFD )
    RTL 
}

dialogstring_06BA0D `[TPL:A][TPL:4]ロブ:[N]テム. お前に ーつ そうだんが[N]あるんだけどさ.[FIN][TPL:4]言いにくいんだけど[N]おれ リリィのことを 好きに[N]なっちまった みたいなんだ···[FIN]夢だって 彼女の夢ばっかりだし··[N]気づくと リリィのことを 目で[N]追ってるんだよ.[FIN]おれらしくないと 思ってるだろ?[N][PAL:0] うんっ[N] そんなことないさ`

dialogstring_06BABC `[CLR][TPL:0]テム: そうだね.[N]ロブから そんな話が でてくるとは[N]思ってもみなかったよ.[FIN]`

dialogstring_06BAEE `[CLR][TPL:0]テム: でも これだけ 長い間[N]いっしょに いるんだもの.[N]恋をしても 不自然じゃないさ.[FIN][CLR][TPL:4]ロブ: それでさ.[N]もうじき リリィの 15才の[N]たんじょう日が くるらしいんだ.[FIN]そのとき プレゼントと いっしょに[N]おれの気持ちを 話したいんだけど[N]お前なら どれが いいとおもう?[FIN] きれいな花たば[N] すてきなネックレス[N] あまーいキス`

dialogstring_06BBB7 `[CLR][TPL:0]テム:[N]花たばをもらって うれしくない[N]女の子は いないと思うよ.[FIN][TPL:4]ロブ: やっぱり そうだよな.[N]じゃあ 花ことばで 告白って意味の[N]つぼみのバラを 送ってみるかなあ.[FIN][JMP:&chunk_068000.dialogstring_06BCFD]`

dialogstring_06BC25 `[CLR][TPL:0]テム: やっぱり ふだん 身に[N]つけられるものが いいんじゃない?[FIN]それを 見るたびに ロブのこと[N]思い出すわけだしさ.[FIN][TPL:4]ロブ: なるほどなあ.[N]じゃあ きれいな石でも さがして[N]ネックレスを つくってみるよ.[FIN][JMP:&chunk_068000.dialogstring_06BCFD]`

dialogstring_06BCA4 `[CLR][TPL:0]テム:[N]本当に 好きなら これしか[N]ないだろ?[FIN][TPL:4]ロブ: いきなり だいたんすぎる[N]ような気もするけど お前が[N]そういうなら やってみるか···[FIN][JMP:&chunk_068000.dialogstring_06BCFD]`

dialogstring_06BCFD `[TPL:A][TPL:4]ロブ:[N]そうだんに のってくれてサンキュ.[FIN]自分なりに 考えてみるよ.[N]もつべきものは 友だちだなあ.[PAL:0][END]`

dialogstring_06BD3F `[TPL:A][TPL:4]ロブ:[N]リリィは 水上都市で たん生日を[N]向えることに なるんだよな···[PAL:0][END]`

actor_def_06BD76 [
  actor-def < #13, #00, #18, {

  code_06BD79:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06BDB2 )
    COP [BranchIfFlagByte] ( #75, #01, &code_06BDB2 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #17, #02, #13 )
    COP [AnimLoop]
} >
]

code_06BDB2 {
    COP [Die]
}

actor_def_06BDB4 [
  actor-def < #15, #00, #10, {

  code_06BDB7:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06BDB2 )
    COP [BranchIfFlagByte] ( #A9, #01, &code_06BDE1 )
    COP [BranchIfFlagByte] ( #8C, #01, &code_06BDD2 )
    COP [SetOnInteract] ( &code_06BE49 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06BDD2 {
    COP [SetTilePos] ( #0F, #0E )
    COP [SolidHighHere]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #19, #04, #01 )
    COP [AnimLoop]
}

code_06BDE1 {
    COP [SetTilePos] ( #17, #0E )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06BDF3 )
    COP [SetEntryContinue]
    RTL 
}

code_06BDF3 {
    COP [PrintDialogString] ( &dialogstring_06BE8A )
    COP [DialogueOptions] ( #02, #01, &code_list_06BDFD )
}

code_list_06BDFD [
  &code_06BE03   ;00
  &code_06BE08   ;01
  &code_06BE03   ;02
]

code_06BE03 {
    COP [PrintDialogString] ( &dialogstring_06BEB2 )
    RTL 
}

code_06BE08 {
    COP [PrintDialogString] ( &dialogstring_06BEDE )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0003
    STA $0D66
    LDA #$0004
    STA $0D68
    LDA #$0005
    STA $0D6A
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0384, #$0164, #00, #11 )
    COP [QueueMapChange] ( #78, #$0250, #$0370, #06, #$4500 )
    RTL 
}

code_06BE49 {
    COP [PrintDialogString] ( &dialogstring_06BE4E )
    RTL 
}

dialogstring_06BE4E `[TPL:A][TPL:6]ニール: だ天使族こそが[N]ムーの人々の 子孫じゃないかと[N]ぼくは 思っているのさ.[PAL:0][END]`

dialogstring_06BE8A `[TPL:A][TPL:6]ニール: 出発しても いいのかい?[N] いいよ[N] ちょっとまって`

dialogstring_06BEB2 `[CLR]ニール:[N]なにも 急ぐことは ないさ.[N]ゆっくり 用を すませておいで.[PAL:0][END]`

dialogstring_06BEDE `[CLR]ニール:[N]水上都市は かなり 暑いところに[N]あるらしい.[FIN]みんな 日射病に ならないよう[N]気をつけるんだぞ.[PAL:0][END]`

actor_def_06BF23 [
  actor-def < #23, #00, #10, {

  code_06BF26:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06BF93 )
    COP [BranchIfFlagByte] ( #75, #01, &code_06BF93 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #28, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06BF95 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06BFAC )
    COP [SetFlagByte] ( #04 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$02A8
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
} >
]

code_06BF93 {
    COP [Die]
}

dialogstring_06BF95 `[TPL:A][TPL:2]リリィ:[N]テム. 行こっ.[END]`

dialogstring_06BFAC `[TPL:A][TPL:2]リリィ:[N]何を カリカリしてるんだか···[FIN][TPL:4]ロブ:[N]まあ いつもの おじょうさまの[N]気まぐれさ. ほっとくんだな.[PAL:0][END]`

actor_def_06BFF6 [
  actor-def < #23, #00, #10, {

  code_06BFF9:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06BF93 )
    COP [BranchIfFlagByte] ( #8C, #01, &code_06C00E )
    COP [SetOnInteract] ( &code_06C020 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C00E {
    COP [SetTilePos] ( #1A, #0E )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06C01B )
    COP [SetEntryContinue]
    RTL 
}

code_06C01B {
    COP [PrintDialogString] ( &dialogstring_06C060 )
    RTL 
}

code_06C020 {
    COP [PrintDialogString] ( &dialogstring_06C025 )
    RTL 
}

dialogstring_06C025 `[TPL:A][TPL:2]リリィ: だ天使族って[N]こんな暗い所で くらしてるんだね.[N]気が めいっちゃいそう···[PAL:0][END]`

dialogstring_06C060 `[TPL:A][TPL:2]リリィ:[N]カレンの 樣子が なんか[N]変なんだよね···[FIN]カレンと 何か あったの?[N]あたしの カンはするどいんだから.[PAL:0][END]`

actor_def_06C0AE [
  actor-def < #1B, #00, #10, {

  code_06C0B1:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06C0E6 )
    COP [BranchIfFlagByte] ( #75, #01, &code_06C0E6 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06C117 )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #03 )
    COP [StageSpriteLoopMoveX] ( #20, #05, #02 )
    COP [AnimLoop]
} >
]

code_06C0E6 {
    COP [Die]
}

actor_def_06C0E8 [
  actor-def < #1A, #00, #30, {

  code_06C0EB:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06C0E6 )
    COP [ExitIfFlagByte] ( #8C, #01 )
    LDA #$2000
    TRB $10
    COP [SetOnInteract] ( &code_06C112 )
    COP [ExitIfFlagByte] ( #A9, #01 )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C112 {
    COP [PrintDialogString] ( &dialogstring_06C179 )
    RTL 
}

dialogstring_06C117 `[TPL:A][TPL:1]カレン:[N]何が ̋”テム 行こっ̋”よっ![FIN]テムも テムよ.[N]でれでれ しちゃってさ.[FIN]あたし ー人で あたりを[N]見物してくる![N]ついて こないでよっ!![PAL:0][END]`

dialogstring_06C179 `[TPL:A][TPL:1]カレン:[N]水上都市ってね イカダの上に[N]たくさん 家がたってるんだって.[FIN]なんだか ロマンチックよね.[N]楽しみだなっ.[PAL:0][END]`

actor_def_06C1C8 [
  actor-def < #0B, #00, #18, {

  code_06C1CB:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06C215 )
    COP [BranchIfFlagByte] ( #75, #01, &code_06C215 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #02, #13 )
    COP [AnimLoop]
} >
]

code_06C215 {
    COP [Die]
}

actor_def_06C217 [
  actor-def < #0C, #00, #10, {

  code_06C21A:
    COP [BranchIfFlagByte] ( #8D, #01, &code_06C215 )
    COP [BranchIfFlagByte] ( #A9, #01, &code_06C271 )
    COP [BranchIfFlagByte] ( #8C, #01, &code_06C235 )
    COP [SetOnInteract] ( &code_06C288 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C235 {
    COP [SetTilePos] ( #0F, #0C )
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetOnInteract] ( &code_06C283 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0D, #28 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_06C2C9 )
    COP [SetFlagByte] ( #A9 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_06C271 {
    COP [SetTilePos] ( #16, #0C )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06C283 )
    COP [SetEntryContinue]
    RTL 
}

code_06C283 {
    COP [PrintDialogString] ( &dialogstring_06C409 )
    RTL 
}

code_06C288 {
    COP [PrintDialogString] ( &dialogstring_06C28D )
    RTL 
}

dialogstring_06C28D `[TPL:A][TPL:3]エリック: 太陽の光って すっごく[N]明るかったんだなあ.[N]いつも見てるのに気づかなかった.[PAL:0][END]`

dialogstring_06C2C9 `[TPL:A][TPL:6][SFX:1A]ニール:[N]カレン! 心配したぞっ!![FIN][TPL:2][SFX:19]リリィ:[N]なんで あんたは いつも[N]ー人で つっぱしるのよっ!![FIN]みんなの 気持ちを 考えたこと[N]あるわけっ?![FIN][TPL:1][SFX:1B]カレン:[N]そのへんのことなら テムに[N]さんざん おこられたわよ.[FIN]というわけで みなさん 本当に[N]ごめんなさいっ! ペコリっ.[FIN][TPL:6][SFX:1A]ニール: まあ 本人も[N]わかっているみたいだし その辺で[N]ゆるしてやれよ.[FIN]ところで ここから 3日ほど[N]南へ 進んだところに 水上都市が[N]あるらしいんだ.[FIN]とりあえず そこに 行ってみようと[N]思うんだ.[N]出発の準備ができたら言ってくれ.[PAL:0][END]`

dialogstring_06C409 `[TPL:A][TPL:3]エリック: あ そういえばさ.[N]ぼく だ天使の町の中で 赤い宝石[N]らしきものを 見かけたよ.[PAL:0][END]`

actor_def_06C448 [
  actor-def < #02, #00, #10, {

  code_06C44B:
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06C46A )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_06C45E:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_06C45E
} >
]

code_06C46A {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C475 )
}

code_list_06C475 [
  &code_06C47D   ;00
  &code_06C47D   ;01
  &code_06C47D   ;02
  &code_06C47D   ;03
]

code_06C47D {
    COP [PrintDialogString] ( &dialogstring_06C482 )
    RTL 
}

dialogstring_06C482 `[TPL:9]我々が いつの時代から ここに[N]住みはじめたのかは わかりません.[FIN]でも 海を見ると なぜか[N]むねが 苦しく なるんですよ.[END]`

actor_def_06C4CB [
  actor-def < #02, #00, #10, {

  code_06C4CE:
    LDA $0E
    AND #$0070
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $28
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06C4F3 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_06C4F3 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C4FE )
}

code_list_06C4FE [
  &code_06C50A   ;00
  &code_06C54D   ;01
  &code_06C590   ;02
  &code_06C5D3   ;03
  &code_06C6A0   ;04
  &code_06C6D6   ;05
]

code_06C50A {
    COP [PrintDialogString] ( &dialogstring_06C50F )
    RTL 
}

dialogstring_06C50F `[TPL:A]ここは だ天使の町.[N]我々は 体が弱く 太陽の光さえも[N]長時間あびると 死んでしまうのだ.[END]`

code_06C54D {
    COP [PrintDialogString] ( &dialogstring_06C552 )
    RTL 
}

dialogstring_06C552 `[TPL:A]ここは だ天使の町.[N]我々は 体が弱く 太陽の光さえも[N]長時間あびると 死んでしまうのだ.[END]`

code_06C590 {
    COP [PrintDialogString] ( &dialogstring_06C595 )
    RTL 
}

dialogstring_06C595 `[TPL:A]ここは だ天使の町.[N]我々は 体が弱く 太陽の光さえも[N]長時間あびると 死んでしまうのだ.[END]`

code_06C5D3 {
    COP [PrintDialogString] ( &dialogstring_06C5ED )
    COP [DialogueOptions] ( #02, #02, &code_list_06C5DD )
}

code_list_06C5DD [
  &code_06C5E3   ;00
  &code_06C5E8   ;01
  &code_06C5E3   ;02
]

code_06C5E3 {
    COP [PrintDialogString] ( &dialogstring_06C611 )
    RTL 
}

code_06C5E8 {
    COP [PrintDialogString] ( &dialogstring_06C62F )
    RTL 
}

dialogstring_06C5ED `[DEF]画家の イシタルのことを[N]知っているか?[N] はい[N] いいえ`

dialogstring_06C611 `[CLR]ならば みんなの話を[N]もう少し 聞いてくるがいい.[END]`

dialogstring_06C62F `[CLR]画家イシタルの アトリエは[N]このトビラの 向こうがわ.[FIN]だが この先には にくしみと[N]はかいの心しか もたない 生物が[N]うごめいているのだ.[FIN]それでも ゆくというのなら[N]とびらを 開けるがいい.[END]`

code_06C6A0 {
    COP [PrintDialogString] ( &dialogstring_06C6A5 )
    RTL 
}

dialogstring_06C6A5 `[TPL:A]私は ちょうこく家.[N]死ぬまでに この石像を 1000体[N]作るつもりだよ···[END]`

code_06C6D6 {
    COP [PrintDialogString] ( &dialogstring_06C6DB )
    RTL 
}

dialogstring_06C6DB `[TPL:A]ここは だ天使の町.[N]我々は 体が弱く 太陽の光さえも[N]長時間あびると 死んでしまうのだ.[END]`

actor_def_06C719 [
  actor-def < #02, #00, #10, {

  code_06C71C:
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06C74C )
    LDA #$0200
    TSB $12

  loc_06C729:
    COP [StageSpriteLoopMoveX] ( #09, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #04, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #14 )
    COP [AnimLoop]
    BRA loc_06C729
} >
]

code_06C74C {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C757 )
}

code_list_06C757 [
  &code_06C75B   ;00
  &code_06C760   ;01
]

code_06C75B {
    COP [PrintDialogString] ( &dialogstring_06C765 )
    RTL 
}

code_06C760 {
    COP [PrintDialogString] ( &dialogstring_06C788 )
    RTL 
}

dialogstring_06C765 `[TPL:A]これは 人間たちの ごらくのーつで[N]ダンスというもの.[END]`

dialogstring_06C788 `[TPL:A]そこのカベに かかっている絵は[N]イシタルという画家がかいたものさ.[FIN]ただ 彼の絵の モデルになった人は[N]その後 行方不明になるんだ···[END]`

actor_def_06C7E0 [
  actor-def < #0A, #00, #10, {

  code_06C7E3:
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06C802 )
    LDA #$000A
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_06C7F6:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_06C7F6
} >
]

code_06C802 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C80D )
}

code_list_06C80D [
  &code_06C813   ;00
  &code_06C818   ;01
  &code_06C813   ;02
]

code_06C813 {
    COP [PrintDialogString] ( &dialogstring_06C81D )
    RTL 
}

code_06C818 {
    COP [PrintDialogString] ( &dialogstring_06C86B )
    RTL 
}

dialogstring_06C81D `[TPL:A]私たちには 感情がない···[FIN]生まれてからこれまで 芺ったことも[N]ないし なみだを流したこともない.[N]ただ 每日を 生きるだけ···[END]`

dialogstring_06C86B `[TPL:A]さっき カレンとかいう 人間の[N]女の子が きたわよ.[FIN]イシタルっていう画家に 美しさを[N]ほめられて 彼のアトリエへ[N]行ったみたいね.[END]`

actor_def_06C8BF [
  actor-def < #0A, #00, #10, {

  code_06C8C2:
    LDA $0E
    AND #$0030
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $28
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06C8E3 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C8E3 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C8EE )
}

code_list_06C8EE [
  &code_06C8F4   ;00
  &code_06C8F9   ;01
  &code_06C8F4   ;02
]

code_06C8F4 {
    COP [PrintDialogString] ( &dialogstring_06C8FE )
    RTL 
}

code_06C8F9 {
    COP [PrintDialogString] ( &dialogstring_06C923 )
    RTL 
}

dialogstring_06C8FE `[TPL:A]人間が 進化した形が[N]あたしたちだって いう話もあるわ.[END]`

dialogstring_06C923 `[TPL:B]アトリエへの 道順を教えるから[N]しっかり 覚えてね.[FIN]まずは 風について行くの.[N]これは たいまつの火がなびく方向を[N]見ていれば わかるはず.[FIN]暗ヤミの通路をとおって[N]強風の吹きあれる場所をぬけていくと[N]そのうち たきの音が聞こえる場所に[N]でるわ.[FIN]そしたら たきの音が もっとも[N]大きく聞こえるところを しらべて[N]ごらんなさい.[FIN]その先が イシタルのアトリエ.[N]気をつけてね.[END]`

actor_def_06CA06 [
  actor-def < #0A, #00, #10, {

  code_06CA09:
    JSL $@code_06B7AB
    COP [SetOnInteract] ( &code_06CA39 )
    LDA #$0200
    TSB $12

  loc_06CA16:
    COP [StageSpriteLoopMoveX] ( #10, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #04, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #14 )
    COP [AnimLoop]
    BRA loc_06CA16
} >
]

code_06CA39 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06CA44 )
}

code_list_06CA44 [
  &code_06CA4A   ;00
  &code_06CA4F   ;01
  &code_06CA54   ;02
]

code_06CA4A {
    COP [PrintDialogString] ( &dialogstring_06CA59 )
    RTL 
}

code_06CA4F {
    COP [PrintDialogString] ( &dialogstring_06CA94 )
    RTL 
}

code_06CA54 {
    COP [PrintDialogString] ( &dialogstring_06CAF3 )
    RTL 
}

dialogstring_06CA59 `[TPL:A]人間の 感情に 近づきたくて[N]こうして 每日 おどってくらしても[N]何も 変わることはない···[END]`

dialogstring_06CA94 `[TPL:A]イシタルは 無表情の 私たちを[N]人間味あふれた顔にえがいてくれる.[FIN]その後 自分がどうなるか[N]わからなくても えがいてほしい[N]という人が 後をたたないわ.[END]`

dialogstring_06CAF3 `[TPL:A]私といっしょに おどっていた人は[N]今は そこの絵の中.[END]`

actor_def_06CB16 [
  actor-def < #12, #00, #10, {

  code_06CB19:
    COP [AddPosition] ( #00, #FC )
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_06CB4C, #$0000, #$FFF0, #$0300 )
    COP [SetOnInteract] ( &code_06CB6E )
    COP [BranchIfFlagByte] ( #89, #00, &code_06CB39 )
    COP [Die]
} >
]

code_06CB39 {
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    RTL 
}

code_06CB41 {
    ORA ($00, S), Y
    BPL loc_06CB47
    ORA $020825
    LDY $0008, X
}

code_06CB4C {
    COP [BranchIfFlagByte] ( #89, #00, &code_06CB62 )
    LDA #$1000
    TSB $10
    COP [SetOnInteract] ( &code_06CB73 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    BRA loc_06CB67
}

code_06CB62 {
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]

  loc_06CB67:
    COP [SolidHighAbs] ( #25, #08 )
    COP [SetEntryContinue]
    RTL 
}

code_06CB6E {
    COP [PrintDialogString] ( &dialogstring_06CB86 )
    RTL 
}

code_06CB73 {
    COP [BranchIfFlagByte] ( #8B, #01, &code_06CB81 )
    COP [SetFlagByte] ( #8B )
    COP [PrintDialogString] ( &dialogstring_06CBE8 )
    RTL 
}

code_06CB81 {
    COP [PrintDialogString] ( &dialogstring_06CCB4 )
    RTL 
}

dialogstring_06CB86 `[TPL:A][TPL:3]イシタル: カレンとかいう 娘を[N]つれもどしに きたのじゃな.[FIN]ならば この先の部屋へゆくがいい.[N]すべてのなぞを とくことが[N]できたなら 娘を かえしてやろう.[END]`

dialogstring_06CBE5 `[PAL:0][END]`

dialogstring_06CBE8 `[TPL:A][TPL:3]イシタル:[N]わしは お前が くるのを[N]まっておったんじゃよ.[FIN]まほうのこなを 絵にふりかけ[N]心の こもった くちづけを[N]してやるがよい.[FIN]お前が 本気で あの娘を[N]想ったとき 何かが おこるはず.[N]まあ いずれ わかることじゃろう.[FIN]わしは 自分で 自画像をかいた.[N]もうじき 絵と 同化する···[FIN]あのこを··· 大切に 守って[N]やるのじゃぞ···[PAL:0][END]`

dialogstring_06CCB4 `[TPL:A][TPL:3]············[PAL:0][END]`

actor_def_06CCC7 [
  actor-def < #0A, #00, #10, {

  code_06CCCA:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06CCD8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_06CCD8 {
    COP [PrintDialogString] ( &dialogstring_06CCDD )
    RTL 
}

dialogstring_06CCDD `[TPL:A][TPL:0]テム:[N]たましいを ぬかれたように[N]まるで 意識がない···[PAL:0][END]`

actor_def_06CD06 [
  actor-def < #18, #00, #10, {

  code_06CD09:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06CD1C )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    RTL 
} >
]

code_06CD1C {
    COP [PrintDialogString] ( &dialogstring_06CD21 )
    RTL 
}

dialogstring_06CD21 `[TPL:A]ハープひきの女:[N]音楽は 何よりの 心の藥.[FIN]すてきな曲を聞けば どんな病気でも[N]よくなるものよ.[END]`

actor_def_06CD61 [
  actor-def < #18, #00, #10, {

  code_06CD64:
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_06CD71 [
  actor-def < #17, #00, #10, {

  code_06CD74:
    BRA loc_06CD81
} >
]

actor_def_06CD76 [
  actor-def < #17, #00, #10, {

  code_06CD79:
    COP [SetSpritePalette] ( #0C )
    BRA loc_06CD81
} >
]

actor_def_06CD7E [
  actor-def < #17, #00, #10, {

  loc_06CD81:
    COP [AddPosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_06CD8B [
  actor-def < #16, #00, #10, {

  code_06CD8E:
    COP [BranchIfFlagByte] ( #8C, #01, &code_06CE95 )
    COP [AddPosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SpawnAfterRelFlags] ( @code_06CE8E, #$0000, #$0010, #$3000 )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #14, &code_06CDAE )
    RTL 
} >
]

code_06CDAE {
    COP [SolidHighAbs] ( #0B, #0C )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #8A, #01 )
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$00
    STA $CGWSEL
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_008000.code_00B8A1 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TSB $10
    COP [SpawnThinker] ( @chunk_008000.code_00B8A1 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TSB $10
    COP [Decompress] ( @gfx_nazca_sprites, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_nazca_sprites, #00, #A0, #50 )
    COP [Decompress] ( @spm_nazca_sprites, $7E4000 )
    COP [SetTilePos] ( #0B, #10 )
    COP [SetSpritePriority] ( #20 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06CF65 )
    LDA #$0003
    JSL $@chunk_008000.dialogstring_00C829
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_06CF91 )
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06CFEE )
    COP [SetFlagByte] ( #8C )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #6A, #$01A0, #$00B0, #03, #$1200 )
    COP [SetEntryContinue]
    RTL 
}

code_06CE8E {
    COP [SetOnInteract] ( &code_06CE97 )
    COP [SetEntryContinue]
    RTL 
}

code_06CE95 {
    COP [Die]
}

code_06CE97 {
    COP [BranchIfFlagByte] ( #89, #00, &code_06CEB0 )
    COP [BranchIfFlagByte] ( #01, #01, &code_06CEA8 )
    COP [PrintDialogString] ( &dialogstring_06CEB5 )
    RTL 
}

code_06CEA8 {
    COP [PrintDialogString] ( &dialogstring_06CED9 )
    COP [SetFlagByte] ( #8A )
    RTL 
}

code_06CEB0 {
    COP [PrintDialogString] ( &dialogstring_06CF2F )
    RTL 
}

dialogstring_06CEB5 `[TPL:A][TPL:0][SFX:10]テム:[N]まずは まほうのこなを[N]かけなくては···[PAL:0][END]`

dialogstring_06CED9 `[TPL:E][TPL:0][SFX:10]テム:[N]おねがいだ. カレン···[N]もとのすがたに もどってくれ···[FIN][SFX:0]テムは カレンの絵に 心のこもった[N]くちづけをした····[PAL:0][END]`

dialogstring_06CF2F `[TPL:A][TPL:0][SFX:10]テム: カレンの絵だ.[N]彼女は この中に すいこまれて[N]しまったのか···[PAL:0][END]`

dialogstring_06CF65 `[TPL:A][TPL:1][SFX:1B]カレン:[N]テム·····[N]勝手なことして ごめんなさい···[FIN]`

dialogstring_06CF91 `[TPL:A][CLR][TPL:0][SFX:10]テム: ああ 悪いよっ![N]ものすごく 悪いよっ!!![FIN]人に めいわくかけるのも[N]いいかげんに しろよなっ!![FIN][TPL:1][SFX:1B]カレン:[N]············[PAL:0][END]`

dialogstring_06CFEE `[TPL:A][TPL:1][SFX:1B]カレン:[N]うわああああああああああん.[N]ヒック·· ぐすっ···[FIN]あたし··· ヒック[N]自分でも 何やってるのか··[N]わかんないの··· ぐすっ···[FIN]お城に いるときはね···[N]自分の ほしいものは 何だって[N]手に入ってた···[FIN]でも 旅先では ぜんぜん ちがうん[N]だもの···[FIN][TPL:0][SFX:10]テム: あたりまえだろっ![N]何でも 自分の 思いどおりになると[N]おもったら おおまちがいだっ!![FIN][TPL:1][SFX:1B]カレン: ちがうのっ![FIN]遠くにいても 近く感じて[N]近くにいても 遠く感じるものが[N]あることを 知ったの···[FIN]テムが わかってくれなければ[N]それでいい···[FIN]でも あたし 今日のことは[N]ー生 忘れないと 思う···[PAL:0][END]`

actor_def_06D150 [
  actor-def < #06, #00, #18, {

  code_06D153:
    COP [AddPosition] ( #09, #03 )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_06D164 [
  actor-def < #19, #00, #18, {

  code_06D167:
    COP [AddPosition] ( #09, #03 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_06D173 [
  actor-def < #19, #00, #18, {

  code_06D176:
    COP [ToggleHFlip]
    COP [AddPosition] ( #09, #03 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #99 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_06D184 [
  actor-def < #18, #00, #18, {

  code_06D187:
    COP [AddPosition] ( #09, #03 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_06D193 [
  actor-def < #00, #00, #30, {

  code_06D196:
    LDA $sceneCurrent
    CMP #$0073
    BEQ loc_06D1BC
    COP [BranchIfFlagWord] ( #$0143, #01, &code_06D1BA )
    COP [SetOnInteract] ( &code_06D1DA )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #43 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0143 )
} >
]

code_06D1BA {
    COP [Die]

  loc_06D1BC:
    COP [BranchIfFlagWord] ( #$0144, #01, &code_06D1D8 )
    COP [SetOnInteract] ( &code_06D1DA )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #44 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0144 )
}

code_06D1D8 {
    COP [Die]
}

code_06D1DA {
    COP [PrintDialogString] ( &dialogstring_06D1E2 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_06D1E2 `[TPL:9][TPL:0]かべのすきまから 風が[N]ふきこんで いるようだ.[FIN]なんと かくしつうろを[N]見つけた![PAL:0][END]`

actor_def_06D215 [
  actor-def < #00, #00, #30, {

  code_06D218:
    LDA $sceneCurrent
    CMP #$0070
    BEQ loc_06D232
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$01D0
    BEQ loc_06D22B
    RTL 

  loc_06D22B:
    COP [BranchIfButton] ( #$0400, &code_06D244 )
    RTL 

  loc_06D232:
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$02D0
    BEQ loc_06D23D
    RTL 

  loc_06D23D:
    COP [BranchIfButton] ( #$0400, &code_06D244 )
    RTL 
} >
]

code_06D244 {
    LDA $slopeCurvePtrB
    BIT #$0002
    BEQ loc_06D24D
    RTL 

  loc_06D24D:
    COP [PrintDialogString] ( &dialogstring_06D252 )
    RTL 
}

dialogstring_06D252 `[TPL:A][TPL:0]入り口が せまくて 通れない![PAL:0][END]`

actor_def_06D26B [
  actor-def < #00, #00, #30, {

  code_06D26E:
    COP [SpawnAfterFlags] ( @code_06D27E, #$2800 )
    COP [SetEntryContinue]
    LDA #$FFF7
    STA $extVelocityX
    RTL 
} >
]

code_06D27E {
    LDA $0036
    AND #$000F
    BEQ loc_06D287
    RTL 

  loc_06D287:
    COP [RngByte]
    AND #$0001
    BEQ loc_06D296
    COP [SpawnAfterFlags] ( @code_06D29E, #$0B02 )
    RTL 

  loc_06D296:
    COP [SpawnAfterFlags] ( @code_06D2CD, #$0B02 )
    RTL 
}

code_06D29E {
    COP [StageSprAndHitbox] ( #1C )

  loc_06D2A1:
    LDA $cameraTargetX
    CLC 
    ADC #$0110
    STA $14
    COP [RngByte]
    STA $16
    AND #$0003
    CLC 
    ADC #$0005
    ASL 
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X

  loc_06D2C1:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $14
    BPL loc_06D2C1
    COP [Die]
}

code_06D2CD {
    COP [StageSprAndHitbox] ( #1D )
    BRA loc_06D2A1
}

actor_def_06D2D2 [
  actor-def < #00, #00, #30, {

  code_06D2D5:
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #40, #10, &code_06D30D )
    COP [SpawnAfterFlags] ( @code_06D312, #$2000 )
    COP [SetEntryContinue]
    LDA $0036
    AND #$001F
    BEQ loc_06D2EF
    RTL 

  loc_06D2EF:
    LDA $playerSpeedNs
    SEC 
    SBC #$002C
    BPL loc_06D2FC
    EOR #$FFFF
    INC 

  loc_06D2FC:
    INC 
    ASL 
    CLC 
    ADC #$0010
    AND #$007F
    SEP #$20
    STA $APUIO0
    REP #$20
    RTL 
} >
]

code_06D30D {
    COP [SetFlagByte] ( #00 )
    COP [Die]
}

code_06D312 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #2A, #17, #2F, #1D, &code_06D320 )
    COP [ClearFlagByte] ( #00 )
    RTL 
}

code_06D320 {
    COP [SetFlagByte] ( #00 )
    RTL 
}

actor_def_06D324 [
  actor-def < #00, #00, #30, {

  code_06D327:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfPlayerNear] ( #01, &code_06D338 )
    COP [SetOnInteract] ( &code_06D349 )
    COP [ExitIfFlagByte] ( #01, #01 )
} >
]

code_06D338 {
    COP [PlaySoundCh2] ( #06 )
    COP [StageBgChange] ( #45 )
    COP [ApplyBgChange]
    LDA #$0000
    STA $0AA6
    COP [SetEntryContinue]
    RTL 
}

code_06D349 {
    COP [SetFlagByte] ( #01 )
    RTL 
}

actor_def_06D34D [
  actor-def < #00, #00, #10, {

  code_06D350:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #89, #01, &code_06D384 )
    STZ $067F
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $playerSpeedEw
    CMP #$00F0
    BCC code_06D384
    COP [AddPosition] ( #08, #02 )
    LDA $0E
    AND #$000F
    STA $24
    STZ $0E
    COP [SetOnInteract] ( &code_06D386 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_06D384 {
    COP [Die]
}

code_06D386 {
    LDA $0AA6
    CMP $24
    BCC loc_06D3FD
    BNE loc_06D402
    COP [PlaySoundCh1] ( #0E )
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06D39D )
}

code_list_06D39D [
  &code_06D3AD   ;00
  &code_06D3B7   ;01
  &code_06D3C1   ;02
  &code_06D3CB   ;03
  &code_06D3D5   ;04
  &code_06D3DF   ;05
  &code_06D3E9   ;06
  &code_06D3F3   ;07
]

code_06D3AD {
    COP [StageBgChange] ( #49 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0149 )
    RTL 
}

code_06D3B7 {
    COP [StageBgChange] ( #4A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014A )
    RTL 
}

code_06D3C1 {
    COP [StageBgChange] ( #4B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014B )
    RTL 
}

code_06D3CB {
    COP [StageBgChange] ( #4C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014C )
    RTL 
}

code_06D3D5 {
    COP [StageBgChange] ( #4D )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014D )
    RTL 
}

code_06D3DF {
    COP [StageBgChange] ( #4E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014E )
    RTL 
}

code_06D3E9 {
    COP [StageBgChange] ( #4F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014F )
    RTL 
}

code_06D3F3 {
    COP [StageBgChange] ( #50 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0150 )
    RTL 

  loc_06D3FD:
    COP [PrintDialogString] ( &dialogstring_06D407 )
    RTL 

  loc_06D402:
    COP [PrintDialogString] ( &dialogstring_06D440 )
    RTL 
}

dialogstring_06D407 `[TPL:A]イシタルの 声が ひびく.[FIN]そう あせるでない.[N]左のとびらから 順番に 開けてゆく[N]のじゃ.[END]`

dialogstring_06D440 `[TPL:A]イシタルの 声が ひびく.[FIN]そのとびらは すでに 開けたはず.[N]もう 開く 必要はない.[END]`

actor_def_06D476 [
  actor-def < #00, #00, #30, {

  code_06D479:
    LDA $playerSpeedEw
    CMP #$00F0
    BCC loc_06D484
    JMP $&code_06D5C6

  loc_06D484:
    COP [ClearFlagWord] ( #$0149 )
    COP [ClearFlagWord] ( #$014A )
    COP [ClearFlagWord] ( #$014B )
    COP [ClearFlagWord] ( #$014C )
    COP [ClearFlagWord] ( #$014D )
    COP [ClearFlagWord] ( #$014E )
    COP [ClearFlagWord] ( #$014F )
    COP [ClearFlagWord] ( #$0150 )
    LDA $playerSpeedNs
    AND #$0010
    BNE loc_06D4C5
    INC $0AA6
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06D5CE )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 

  loc_06D4C5:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06D61C )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterFlags] ( @code_06D78C, #$1002 )
    LDA $playerWallType
    STA $0014, Y
    LDA $playerSpeedEw
    STA $0016, Y
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$8001, &code_06D4F1 )
    RTL 
} >
]

code_06D4F1 {
    LDY $06
    LDA $0014, Y
    STA $24
    LDA $0016, Y
    STA $26
    COP [KillNext]
    LDA $playerSpeedNs
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06D510 )
}

code_list_06D510 [
  &code_06D518   ;00
  &code_06D544   ;01
  &code_06D56E   ;02
  &code_06D598   ;03
]

code_06D518 {
    LDA $24
    CMP #$01B0
    BCC loc_06D53A
    CMP #$01C0
    BCS loc_06D53A
    LDA $26
    CMP #$0070
    BCC loc_06D53A
    CMP #$0090
    BCS loc_06D53A
    COP [PrintDialogString] ( &dialogstring_06D693 )
    INC $0AA6
    JMP $&code_06D5C6

  loc_06D53A:
    COP [PrintDialogString] ( &dialogstring_06D64B )
    DEC $0AA6
    JMP $&code_06D5C6
}

code_06D544 {
    LDA $24
    CMP #$0330
    BCC loc_06D565
    CMP #$0350
    BCS loc_06D565
    LDA $26
    CMP #$00A0
    BCC loc_06D565
    CMP #$00C0
    BCS loc_06D565
    COP [PrintDialogString] ( &dialogstring_06D6CF )
    INC $0AA6
    BRA code_06D5C6

  loc_06D565:
    COP [PrintDialogString] ( &dialogstring_06D64B )
    DEC $0AA6
    BRA code_06D5C6
}

code_06D56E {
    LDA $24
    CMP #$0570
    BCC loc_06D58F
    CMP #$0590
    BCS loc_06D58F
    LDA $26
    CMP #$0070
    BCC loc_06D58F
    CMP #$0090
    BCS loc_06D58F
    COP [PrintDialogString] ( &dialogstring_06D6F1 )
    INC $0AA6
    BRA code_06D5C6

  loc_06D58F:
    COP [PrintDialogString] ( &dialogstring_06D64B )
    DEC $0AA6
    BRA code_06D5C6
}

code_06D598 {
    LDA $24
    CMP #$0790
    BCC loc_06D5BD
    CMP #$07B0
    BCS loc_06D5BD
    LDA $26
    CMP #$00A0
    BCC loc_06D5BD
    CMP #$00C0
    BCS loc_06D5BD
    COP [PrintDialogString] ( &dialogstring_06D734 )
    COP [SetFlagByte] ( #89 )
    COP [SetFlagWord] ( #$0151 )
    BRA code_06D5C6

  loc_06D5BD:
    COP [PrintDialogString] ( &dialogstring_06D64B )
    DEC $0AA6
    BRA code_06D5C6
}

code_06D5C6 {
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

dialogstring_06D5CE `[TPL:9]イシタルの声が ひびく.[FIN]その部屋の樣子を じっくりと[N]覚えるのじゃ.[FIN]完ぺきに 覚えたと 思ったら[N]部屋から でるがよい.[END]`

dialogstring_06D61C `[TPL:9]イシタルの声が ひびく.[FIN]前の部屋と ちがっている場所を[N]示すのじゃ.[END]`

dialogstring_06D64B `[TPL:A]そんな かんさつ力で どうする![FIN]今後 お前の旅は さらに[N]たいへんなものと なるはずじゃ.[FIN]もうー度 やりなおすがよい!![END]`

dialogstring_06D693 `[TPL:A]正解じゃ!![N]つぼの 色が 変わっていた[N]というわけじゃな.[FIN]よかろう.[N]次の部屋へ 進むがよい.[END]`

dialogstring_06D6CF `[TPL:A]正解じゃ!![FIN]よかろう.[N]次の部屋へ 進むがよい.[END]`

dialogstring_06D6F1 `[TPL:A]正解じゃ!![N]なんと たからばこの 中身が[N]ちがっているというわけじゃな.[FIN]よかろう.[N]次の部屋へ 進むがよい.[END]`

dialogstring_06D734 `[TPL:A]正解じゃ!![N]風が ふいておったため お前の[N]カミは なびいていたんじゃな.[FIN]お前は わしのテストに みごと[N]パスした.[N]さあ もどってくるがよい.[END]`

code_06D78C {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0801, &code_06D7AF )

  loc_06D79C:
    COP [BranchIfButton] ( #$0401, &code_06D7BC )

  loc_06D7A2:
    COP [BranchIfButton] ( #$0201, &code_06D7C9 )

  loc_06D7A8:
    COP [BranchIfButton] ( #$0101, &code_06D7D9 )

  loc_06D7AE:
    RTL 
}

code_06D7AF {
    LDA $16
    CMP #$0008
    BCC loc_06D79C
    DEC $16
    DEC $16
    BRA loc_06D79C
}

code_06D7BC {
    LDA $16
    CMP #$00D0
    BCS loc_06D7A2
    INC $16
    INC $16
    BRA loc_06D7A2
}

code_06D7C9 {
    LDA $14
    AND #$00FF
    CMP #$0008
    BCC loc_06D7A8
    DEC $14
    DEC $14
    BRA loc_06D7A8
}

code_06D7D9 {
    LDA $14
    AND #$00FF
    CMP #$00F8
    BCS loc_06D7AE
    INC $14
    INC $14
    BRA loc_06D7AE
}

actor_def_06D7E9 [
  actor-def < #04, #00, #10, {

  code_06D7EC:
    COP [BranchIfPlayerInAbsTiles] ( #70, #00, #80, #10, &code_06D7F6 )
    BRA loc_06D7FF
} >
]

code_06D7F6 {
    COP [SetFlagByte] ( #00 )
    LDA #$FFFF
    STA $decelCurvePtr

  loc_06D7FF:
    LDA $0AA6
    LSR 
    CMP #$0001
    BNE loc_06D80E
    COP [SetTilePos] ( #3A, #1D )
    BRA loc_06D822

  loc_06D80E:
    CMP #$0002
    BNE loc_06D819
    COP [SetTilePos] ( #57, #1D )
    BRA loc_06D822

  loc_06D819:
    CMP #$0003
    BNE loc_06D822
    COP [SetTilePos] ( #00, #71 )

  loc_06D822:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06D82B )
    COP [SetEntryContinue]
    RTL 
}

code_06D82B {
    COP [PrintDialogString] ( &dialogstring_06D830 )
    RTL 
}

dialogstring_06D830 `[TPL:A]イシタルの弟子:[N]ここを 通るのは 手前の部屋の[N]なぞを といてからだ.[END]`