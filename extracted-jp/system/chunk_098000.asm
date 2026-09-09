?BANK 09

?INCLUDE 'binary_01C36C'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_058000'
?INCLUDE 'chunk_068000'
?INCLUDE 'chunk_088000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'ec0B_cell'
?INCLUDE 'parallax_table'
?INCLUDE 'scene_meta'
?INCLUDE 'scene_warps'
?INCLUDE 'stats_table'
?INCLUDE 'table_018000'
?INCLUDE 'table_01A946'
?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraBoundsY                  06DC
!layerPriorityFlag              06EE
!sfxQueueCh1                    06F8
!joypadInject                   09AC
!playerFlags                    09AE
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!abilityBitmask                 0AA2
!INIDISP                        2100
!BG3SC                          2109
!VMADDL                         2116
!M7SEL                          211A
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!COLDATA                        2132
!MDMAEN                         420B
!MEMSEL                         420D
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!decompressedTilesets           7E4000
!tileStagingBuffer              7E7000
!mapLayerTilemap                7EA000
!effectLayerTilemap             7EC000
!mode7Tilemap                   7EE000
!thinkerExtendedData            7EF000
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026
!cgramPalette                   7F0A00
!backdropColors                 7F0C00
!oamComposeBuffer               7F3100

---------------------------------------------

actor_def_098000 [
  actor-def < #00, #00, #10, {

  code_098003:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09801D )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_09801D {
    COP [PrintWideString] ( &widestring_098053 )
    COP [DialogueOptions] ( #02, #02, &code_list_098027 )
}

code_list_098027 [
  &code_09802D   ;00
  &code_09802D   ;01
  &code_098032   ;02
]

code_09802D {
    COP [PrintWideString] ( &widestring_0980A8 )
    RTL 
}

code_098032 {
    COP [PrintWideString] ( &widestring_0980A8 )
    STZ $066D
    STZ $0670
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #C3, #$0210, #$0090, #03, #$2300 )
    RTL 
}

widestring_098053 `[TPL:B]この先に進むと お前は もう[N]後もどりできなくなる···[FIN]ダオの町へ もどりたいなら[N]運んであげるが どうする?[N] やめる[N] ダオの町へもどる`

widestring_0980A8 `[CLD]`

actor_def_0980AA [
  actor-def < #00, #00, #10, {

  code_0980AD:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #D2, #00, &code_0980CD )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0980CF )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_0980CD {
    COP [Die]
}

code_0980CF {
    COP [PrintWideString] ( &widestring_098105 )
    COP [DialogueOptions] ( #02, #01, &code_list_0980D9 )
}

code_list_0980D9 [
  &code_0980DF   ;00
  &code_0980DF   ;01
  &code_0980E4   ;02
]

code_0980DF {
    COP [PrintWideString] ( &widestring_09812C )
    RTL 
}

code_0980E4 {
    COP [PrintWideString] ( &widestring_09812C )
    STZ $066D
    STZ $0670
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #E3, #$0280, #$01B0, #00, #$2310 )
    RTL 
}

widestring_098105 `[TPL:A]バベルの塔へ もどるのだな?[N] やめる[N] バベルの塔へもどる`

widestring_09812C `[CLD]`

actor_def_09812E [
  actor-def < #06, #00, #18, {

  code_098131:
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$FFFE
    STA $002C, Y
    LDA #$0001
    STA $002E, Y
    LDA $14
    CLC 
    ADC #$009C
    STA $14
    COP [StageSpriteLoopMoveX] ( #06, #22, #14 )
    COP [AnimLoop]
    COP [SpawnAfterFlags] ( @code_0981CD, #$3000 )
    COP [StageSpriteLoopMoveX] ( #06, #46, #14 )
    COP [AnimLoop]

  loc_09817E:
    COP [BranchIfFlagByte] ( #01, #01, &code_09818B )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_09817E
} >
]

code_09818B {
    COP [StageSpriteLoopMoveXY] ( #06, #1E, #02, #02 )
    COP [AnimLoop]
    COP [SpawnAfterAbsFlags] ( @code_098489, #$0020, #$0000, #$1800 )
    COP [WaitByte] ( #C7 )
    COP [SpawnAfterFlags] ( @code_0981D6, #$3000 )
    COP [WaitWord] ( #$0117 )
    COP [SpawnAfterAbsFlags] ( @code_098489, #$0020, #$0000, #$1800 )
    COP [WaitByte] ( #4F )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #DE, #$0078, #$00C0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_0981CD {
    COP [PrintWideString] ( &widestring_0981DC )
    COP [SetFlagByte] ( #01 )
    COP [Die]
}

code_0981D6 {
    COP [PrintWideString] ( &widestring_098452 )
    COP [Die]
}

widestring_0981DC `[TPL:A][TPL:6]ニール:[N]さあ そろそろ 着くぞ.[N]テム. おやじさんに よろしくな.[FIN][TPL:0]テム: ありがとう.[N]ニールも りっぱな 社長に[N]なってよね.[FIN][TPL:3]エリック: あーあ.[N]これで しばらく テムと 会えなく[N]なるんだなあ.[FIN]用がすんだら さっさと[N]サウスケープの町に もどって[N]おいでよ.[FIN][TPL:0]テム: サンキュ.[N]ぼくも みんなと 旅ができて[N]楽しかった.[FIN][TPL:3]エリック:[N]この旅で みんな 何かを[N]見つけたよね.[FIN]ロブは リリィと 出会ったし[N]行方不明の 父さんとも再会した.[FIN]ニールは 親の会社を つぐことを[N]心に 決めたし,[FIN]カレンは 生まれてはじめて[N]お城の外の 世界を 自分の足で[N]見て回ったんだよね.[FIN]ぼくも この場をかりて ひとつ.[N]何と 夜中に ー人で おしっこに[N]いけるように なりましたっ![FIN][TPL:6]ニール:[N]ははは. エリックらしいや.[FIN]ところで カレンは さっきから[N]何にも 話さないな.[FIN]テムと しばらく 会えなく[N]なるんだぞ.[N]别れの あいさつくらいしとけよ.[FIN][TPL:1]カレン:[N][DLY:4]うん. そうね···[FIN][TPL:6][DLY:1]ニール:[N]おっと 話しているうちに[N]バベルの塔は すぐ そこだ.[FIN]さあ テム.[N]パラシュートの 準備はいいかっ?[N]いくぞっ![PAL:0][END]`

widestring_098452 `[TPL:A][TPL:0][DLY:2]そして ぼくは 1年半ぶりに[N]バベルの塔へ 降り立とうと[N]している···[PAU:B4][PAL:0][CLD]`

code_098489 {
    COP [StageSpriteMoveXY] ( #05, #13, #11 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_098489
    COP [Die]
}

actor_def_098499 [
  actor-def < #1C, #00, #03, {

  code_09849C:
    COP [BranchIfFlagByte] ( #D4, #01, &code_098650 )
    COP [BranchIfPlayerAt] ( #$0080, #$01A0, &code_0984AD )
    JMP $&code_098650
} >
]

code_0984AD {
    COP [AddPosition] ( #08, #00 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_0984FB )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    LDA #$1000
    TRB $10
    LDA #$0B00
    TSB $10
    COP [SetFlagByte] ( #D4 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

widestring_0984FB `[TPL:A][TPL:0]テム:[N]カレンっ![N]どこに いってたんだよっ!![FIN][TPL:1]カレン:[N]きゅうけつきの女の人が やってきて[N]話があるって いうから···[FIN]あの人 永遠に 死ぬことの[N]できない体 なんですって···[FIN]すい星さえ なくなれば[N]やすらかな ねむりにつけるって[N]言ってたわ.[END]`

actor_def_098591 [
  actor-def < #1A, #00, #0B, {

  code_098594:
    COP [BranchIfFlagByte] ( #D4, #00, &code_098650 )
    LDA $sceneCurrent
    CMP #$00E0
    BNE code_0985CB
    COP [BranchIfFlagWord] ( #$0178, #00, &code_0985CB )
    COP [ClearFlagByte] ( #D4 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_098652 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_0985CB {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2800 )
    PHX 
    TYX 
    JSL $@chunk_3B7DD.code_03E58B
    EOR #$0001
    INC 
    STA $orbitAngle, X
    CMP #$0001
    BEQ loc_0985F8
    COP [AddPosition] ( #00, #F0 )
    BRA loc_0985FC

  loc_0985F8:
    COP [AddPosition] ( #00, #10 )

  loc_0985FC:
    LDA #$001A
    STA $orbitDiameter, X
    PLX 
    COP [SetEntryContinue]
    COP [AnimOnce]

  loc_098608:
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDY $decelStepCounter
    LDA $000E, Y
    BIT #$2000
    BEQ loc_09861A
    RTL 

  loc_09861A:
    LDA #$2000
    TSB $10
    COP [SpawnLastRel] ( @code_098677, #00, #00, #$1002 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDY $decelStepCounter
    LDA $000E, Y
    BIT #$2000
    BNE loc_09863A
    RTL 

  loc_09863A:
    COP [WaitByte] ( #07 )
    COP [SpawnLastRel] ( @code_098677, #00, #00, #$1002 )
    COP [WaitByte] ( #0F )
    LDA #$2000
    TRB $10
    BRA loc_098608
}

code_098650 {
    COP [Die]
}

widestring_098652 `[TPL:A][TPL:0]おや カレンが いない···[N]どこへ いったんだ···?[PAL:0][END]`

code_098677 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [Die]
}

actor_def_098683 [
  actor-def < #00, #00, #30, {

  code_098686:
    COP [SolidHighAbs] ( #71, #38 )
    COP [SolidHighAbs] ( #72, #38 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$072E, #$0384, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$072E, #$0374, #$1800 )
    COP [ExitIfFlagWord] ( #$0175, #01 )
    COP [ClearLowAbs] ( #71, #38 )
    COP [ClearLowAbs] ( #72, #38 )
    COP [Die]
} >
]

actor_def_0986B3 [
  actor-def < #00, #00, #30, {

  code_0986B6:
    COP [SolidHighAbs] ( #0D, #28 )
    COP [SolidHighAbs] ( #0E, #28 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$00EE, #$0284, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$00EE, #$0274, #$1800 )
    COP [ExitIfFlagWord] ( #$0176, #01 )
    COP [ClearLowAbs] ( #0D, #28 )
    COP [ClearLowAbs] ( #0E, #28 )
    COP [Die]
} >
]

actor_def_0986E3 [
  actor-def < #00, #00, #30, {

  code_0986E6:
    COP [SolidHighAbs] ( #49, #18 )
    COP [SolidHighAbs] ( #4A, #18 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$04AE, #$0184, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$04AE, #$0174, #$1800 )
    COP [ExitIfFlagWord] ( #$0177, #01 )
    COP [ClearLowAbs] ( #49, #18 )
    COP [ClearLowAbs] ( #4A, #18 )
    COP [Die]
} >
]

actor_def_098713 [
  actor-def < #00, #00, #30, {

  code_098716:
    COP [SolidHighAbs] ( #15, #08 )
    COP [SolidHighAbs] ( #16, #08 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$016E, #$0084, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$016E, #$0074, #$1800 )
    COP [ExitIfFlagWord] ( #$0178, #01 )
    COP [ClearLowAbs] ( #15, #08 )
    COP [ClearLowAbs] ( #16, #08 )
    COP [Die]
} >
]

actor_def_098743 [
  actor-def < #00, #00, #30, {

  code_098746:
    COP [SolidHighAbs] ( #29, #38 )
    COP [SolidHighAbs] ( #2A, #38 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$02AE, #$0384, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @code_09994F, #$02AE, #$0374, #$1800 )
    COP [ExitIfFlagWord] ( #$0179, #01 )
    COP [ClearLowAbs] ( #29, #38 )
    COP [ClearLowAbs] ( #2A, #38 )
    COP [Die]
} >
]

actor_def_098773 [
  actor-def < #00, #01, #10, {

  code_098776:
    LDA #$1200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #02 )
    COP [BranchIfFlagByte] ( #FD, #01, &code_0987FC )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09883D )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetOnInteract] ( #$0000 )
    COP [SpawnAfterRelFlags] ( @code_098845, #$0000, #$FFE0, #$1800 )
    COP [StartMusic] ( #0E )
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_0988FE )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitWord] ( #$012B )
    COP [SetEntryContinue]
    JSL $@chunk_028000.code_02A178
    BCC loc_0987C2
    RTL 

  loc_0987C2:
    COP [WaitByte] ( #1D )
    LDA #$0005
    STA $0AAC
    LDA #$00DE
    STA $0B12
    LDA #$0017
    STA $0B08
    STA $0B0A
    LDA #$000B
    STA $0B0C
    STA $0B0E
    LDA #$1201
    STA $0B10
    LDA #$0104
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0987FC {
    COP [SpawnAfterRelFlags] ( @code_09885E, #$0000, #$FFE0, #$1800 )
    LDA #$0001
    JSL $@chunk_008000.widestring_00C829
    LDY $decelStepCounter
    LDA #$0001
    STA $0028, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_098B87 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E4, #$00F0, #$0140, #80, #$2200 )
    COP [SetEntryContinue]
    RTL 
}

code_09883D {
    COP [PrintWideString] ( &widestring_09886E )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_098845 {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [LoopInit] ( #28 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
}

code_09885E {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
}

widestring_09886E `[TPL:9][TPL:0][SFX:0]古ぼけた しかばねが ーつ[N]静かに 横たわっている···[FIN]そのとき 頭の中に[N]聞き覚えのある声が語りかけてきた.[FIN][TPL:4][SFX:10][DLY:2]テム. 私だよ.[N]お前の父 オールマンだ.[FIN]肉体は くち果てたが[N]私は こうして生き続けている··[PAL:0][END]`

widestring_0988FE `[TPL:B][TPL:0][DLY:1]テム: と とうさんっ![N]どうして そんな 姿にっ!!![FIN][TPL:4][DLY:2]バベルの塔は 不思議な空間.[N]内部は すい星の光で 満ちている.[FIN]時が 数百倍の速さで流れ[N]中にいる者は すさまじい速度で[N]進化してゆく···[FIN][TPL:0][DLY:1]テム:[N]じゃあ ぼくと カレンは[N]どうして 生きていられるのっ?![FIN][TPL:4][DLY:2]テムの父:[N]それは お前たちも 進化した人間[N]だからだ.[FIN][TPL:1][DLY:1]カレン:[N]あたしたちが····?[FIN][TPL:4][DLY:2]テムの父:[N]はるかむかし すい星から[N]放たれる光を使った バイオ技術が[N]あって,[FIN]人々は その力を使い[N]自由に 動植物を 作りだしていた.[FIN]例えば ラクダが 長期間[N]飲まず食わずで 生きていられるのは[N]さばくを 移動する 乗り物として[N]作られたからだ.[FIN]やがて 人は この力を 兵器として[N]利用できることに気づき,[N][PAU:1E]まものが 次々と 生みだされた.[FIN]まもなく 世界は[N]はめつのききに おちいった···[FIN]そのとき 人類の存亡を かけて[N]作り出された 光とヤミの戦士.[N][PAU:1E]それが お前たちの 先祖なのだ.[FIN]そして 6つのミステリードールこそ[N]光とヤミの戦士を 作り出したもの.[FIN]さあ 最後のーつ[N]命の ミステリードールを お前に[N]たくそう.[END]`

widestring_098B87 `[TPL:B][TPL:4][DLY:2]もうじき すい星が 大接近する.[N][PAU:1E]お前たちは それまでに 塔の屋上へ[N]ゆかねばならない.[N][PAU:28][DLY:4]さあ 静かに目を閉じなさい···[END]`

actor_def_098BDC [
  actor-def < #1B, #00, #10, {

  code_098BDF:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_098CAE )
    COP [ExitIfFlagByte] ( #0E, #01 )
    COP [SetOnInteract] ( #$0000 )
    JSL $@chunk_3B7DD.code_03E58B
    EOR #$0001
    CLC 
    ADC #$001A
    STA $28
    STZ $2A
    COP [SpawnAfterFlags] ( @code_098DA5, #$1802 )
    COP [SpawnAfterFlags] ( @code_098DAE, #$1802 )
    COP [SpawnAfterFlags] ( @code_098DB7, #$1802 )
    COP [SpawnAfterFlags] ( @code_098DC0, #$1802 )
    COP [SpawnAfterFlags] ( @code_098DC9, #$1802 )
    COP [SpawnAfterFlags] ( @code_098DD2, #$1802 )
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #1A, #01 )
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_098C66
    RTL 

  loc_098C66:
    COP [PrintWideString] ( &widestring_098D6E )
    COP [SetFlagByte] ( #0A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDY $decelStepCounter
    LDA #$0089
    STA $0002, Y
    LDA #$8E22
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitWord] ( #$00EF )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E7, #$0050, #$0090, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_098CAE {
    COP [BranchIfFlagByte] ( #0F, #01, &code_098CB9 )
    COP [PrintWideString] ( &widestring_098CC1 )
    RTL 
}

code_098CB9 {
    COP [PrintWideString] ( &widestring_098CDD )
    COP [SetFlagByte] ( #0E )
    RTL 
}

widestring_098CC1 `[DEF][TPL:1]カレン:[N]···············[PAL:0][END]`

widestring_098CDD `[DEF][TPL:0]テムと カレンの 心が重なったとき[N]光とヤミが ーつになったとき[N]そこに 大いなる力が生まれる··[FIN]光とヤミの戦士が ここに[N]数千年の時を越えて よみがえり,[N]ヤミの戦士の 究極の力[N]ファイアバードが やどった!![PAL:0][END]`

widestring_098D6E `[TPL:D][TPL:4]お前たちの 戦いが 地球の運命を[N]変える.[FIN]さあ いきなさい.[N]すい星へっ!!![PAL:0][END]`

code_098DA5 {
    LDA #$0000
    STA $orbitAngle, X
    BRA loc_098DD9
}

code_098DAE {
    LDA #$002A
    STA $orbitAngle, X
    BRA loc_098DD9
}

code_098DB7 {
    LDA #$0054
    STA $orbitAngle, X
    BRA loc_098DD9
}

code_098DC0 {
    LDA #$0080
    STA $orbitAngle, X
    BRA loc_098DD9
}

code_098DC9 {
    LDA #$00AA
    STA $orbitAngle, X
    BRA loc_098DD9
}

code_098DD2 {
    LDA #$00D4
    STA $orbitAngle, X

  loc_098DD9:
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #0A )
    LDA #$0001
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $decelStepCounter
    STA $24
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$0080
    BEQ loc_098E0F
    INC 
    STA $orbitDiameter, X

  loc_098E0F:
    COP [BranchIfFlagByte] ( #0A, #01, &code_098E16 )
    RTL 
}

code_098E16 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [Die]

  loc_098E22:
    LDA #$0008
    TRB $10
    COP [StagePlayerSprite] ( #1C )
    COP [AnimOnce]
    COP [ToggleVFlip]

  loc_098E2E:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    BRA loc_098E2E
}

actor_def_098E36 [
  actor-def < #00, #00, #10, {

  code_098E39:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_098F0C )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterAbsFlags] ( @code_09905D, #$00D8, #$00F0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_0990F6, #$0098, #$00E0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_09919A, #$00B8, #$0160, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_09923C, #$0148, #$0130, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_0992CD, #$0158, #$00E0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    LDA #$0800
    TSB $10
    COP [SetOnInteract] ( &code_098EC7 )

  code_098EB6:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_098EB6 )
    COP [WaitByte] ( #1D )
    COP [ClearLowHere]
    COP [Die]
} >
]

code_098EC7 {
    COP [BranchIfFlagByte] ( #01, #00, &code_098EE5 )
    COP [BranchIfFlagByte] ( #02, #00, &code_098EE5 )
    COP [BranchIfFlagByte] ( #03, #00, &code_098EE5 )
    COP [BranchIfFlagByte] ( #04, #00, &code_098EE5 )
    COP [BranchIfFlagByte] ( #05, #01, &code_098EF4 )
}

code_098EE5 {
    LDA #$0800
    TRB $10
    COP [PrintWideString] ( &widestring_098FFE )
    LDA #$0800
    TSB $10
    RTL 
}

code_098EF4 {
    LDA #$0800
    TRB $10
    COP [PrintWideString] ( &widestring_09901E )
    COP [SetFlagByte] ( #0F )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0800
    TSB $10
    RTL 
}

widestring_098F0C `[TPL:F][TPL:4]テムの父:[N]かつて 古代人たちは すい星を[N]神とあがめた.[FIN]すい星の光を あびたものには[N]不思議な力が やどったからだ.[FIN]確かに すい星は 神といえる.[N]すい星は ーつの生命体ともいえる.[N]だが それは 招かれざる神なのだ.[FIN]速すぎる 進歩からは[N]はめつだけが 生まれる···[FIN]人の心に 悪が あるかぎり[N]あらゆる まものが 生み出されて[N]しまう.[FIN]さあ テム 目をこらして[N]まわりを 見てみなさい.[END]`

widestring_098FFE `[TPL:F][TPL:4]テムの父:[N]さあ 彼らと 話しておいで.[PAL:0][END]`

widestring_09901E `[TPL:F][TPL:4]テムの父:[N]いよいよ その時が 近づいてきた.[FIN]さあ みんな.[N]テムに 力を かしてやってくれ![PAL:0][END]`

code_09905D {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09909B )

  code_099077:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099077 )
    COP [ClearLowHere]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_09909B {
    COP [PrintWideString] ( &widestring_0990A3 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

widestring_0990A3 `[DEF][TPL:5]モリス:[N]やあ テム ひさしぶり.[FIN]こんな世界が あったなんて···[N]これを 学会で 発表したら[N]ぼくは 学者になれるだろうなあ.[PAL:0][END]`

code_0990F6 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09913A )

  code_099110:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099110 )
    COP [ClearLowHere]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_09913A {
    COP [PrintWideString] ( &widestring_099142 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

widestring_099142 `[DEF]ニールの父:[N]ええい···[N]ニールは 何を やっておるっ![FIN]あいつには ローレック株式会社を[N]もっともっと 大きくしてもらわねば[N]ならんのじゃ.[END]`

widestring_099199 `[END]`

code_09919A {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0991D8 )

  code_0991B4:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_0991B4 )
    COP [ClearLowHere]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_0991D8 {
    COP [PrintWideString] ( &widestring_0991E0 )
    COP [SetFlagByte] ( #03 )
    RTL 
}

widestring_0991E0 `[DEF]ニールの母:[N]現実世界を ながめることはできても[N]ふれることはできない···[FIN]ニールが どんなに困っていても[N]もう 手をかしてあげることは[N]できないのね···[END]`

code_09923C {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09927A )

  code_099256:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099256 )
    COP [ClearLowHere]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_09927A {
    COP [PrintWideString] ( &widestring_099282 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

widestring_099282 `[DEF][TPL:1]ペギー:[N]ブヒブヒッ!![FIN][SFX:0][TPL:0]テム:[N]そうか 体がなくなっちゃえば[N]人も動物も 区别なんか[N]ないんだな···[PAL:0][END]`

widestring_0992CC `[END]`

code_0992CD {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09930B )

  code_0992E7:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_0992E7 )
    COP [ClearLowHere]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_09930B {
    COP [PrintWideString] ( &widestring_099313 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

widestring_099313 `[DEF]肉体が なくなり 私は[N]不老不死の 生物となった.[N]すい星の光による 進化によって[N]永遠の命を 手に入れたのだ.[FIN]だが 果てることのない命に[N]いったい 何の 意味があろうか.[N]不治の病に おびえていたころの方が[N]よほど じゅうじつしていたな··[END]`

actor_def_0993AA [
  actor-def < #00, #00, #30, {

  code_0993AD:
    COP [BranchIfPlayerAt] ( #$0180, #$07A0, &code_099449 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #7B, #0A, #7D, &code_0993C0 )
    RTL 
} >
]

code_0993C0 {
    COP [SpawnThinker] ( @code_09943C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitWord] ( #$00EF )
    COP [SetFlagByte] ( #00 )
    COP [WaitWord] ( #$0167 )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @chunk_088000.code_08B37D, #$1002 )
    COP [SetEntryExit]
    LDY $decelStepCounter
    LDA $000E, Y
    EOR #$2000
    STA $000E, Y
    LDA $0014, Y
    CLC 
    ADC #$0090
    STA $0014, Y
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC #$0004
    STA $0016, Y
    CMP #$00B0
    BCC loc_09940D
    RTL 

  loc_09940D:
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC #$0090
    STA $0014, Y
    COP [SpawnAfterFlags] ( @chunk_088000.code_08B37D, #$1002 )
    COP [WaitByte] ( #0F )
    LDY $decelStepCounter
    LDA $000E, Y
    EOR #$2000
    STA $000E, Y
    COP [WaitByte] ( #07 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_09943C {
    COP [PaletteStart] ( #6D )
    COP [PaletteStep]
    COP [SetEntryContinue]
    COP [PaletteStart] ( #6F )
    COP [PaletteStep]
    RTL 
}

code_099449 {
    COP [SpawnThinker] ( @code_099450 )
    COP [Die]
}

code_099450 {
    COP [SetEntryContinue]
    COP [PaletteStart] ( #6E )
    COP [PaletteStep]
    RTL 
}

actor_def_099458 [
  actor-def < #00, #00, #10, {

  code_09945B:
    COP [BranchIfPlayerAt] ( #$0180, #$07A0, &code_099465 )
    COP [Die]
} >
]

code_099465 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [Decompress] ( @gfx_vampires, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_vampires, #00, #A0, #50 )
    COP [Decompress] ( @spm_vampires, $7E4000 )
    LDA #$DFF0
    TRB $joypadMaskStd
    STZ $0676
    STZ $0685
    COP [SetFlagByte] ( #0F )
    LDA #$0200
    TSB $12
    COP [StageSprAndHitbox] ( #00 )
    LDA #$0158
    STA $moveXAlt, X
    LDA #$07A0
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09956A )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [SpawnBeforeFlags] ( @code_0995B2, #$2000 )
    LDY $decelStepCounter
    LDA #$0089
    STA $0002, Y
    LDA #$95CC
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_09951E:
    COP [StageSpriteMoveY] ( #01, #08 )
    COP [AnimOnce]
    LDA $16
    CMP #$00E0
    BCS loc_09951E
    LDA $14
    STA $moveXAlt, X
    LDA #$0080
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #02 )
    COP [WaitByte] ( #3B )
    LDA #$0178
    STA $moveXAlt, X
    LDA #$00A0
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [WaitByte] ( #31 )
    COP [SetFlagByte] ( #04 )
    COP [KillPrev]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveXY] ( #01, #0A, #02, #04 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_09956A {
    COP [PrintWideString] ( &widestring_099572 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

widestring_099572 `[DEF]もう まもなく すい星が[N]地球の すぐ 横を 通過する.[N]さあ それまでに バベルの塔の[N]頂上へ···[END]`

code_0995B2 {
    COP [SetEntryContinue]
    PHX 
    LDX $24
    LDY $decelStepCounter
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    CLC 
    ADC #$000A
    STA $0016, Y
    PLX 
    RTL 
}

code_0995CC {
    COP [SetSpritePriority] ( #30 )
    COP [StagePlayerSprite] ( #19 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #04, #00, &code_0995CC )
    COP [SetSpritePriority] ( #20 )
    JML $@chunk_028000.code_02D01B
}

actor_def_0995E1 [
  actor-def < #00, #00, #10, {

  code_0995E4:
    LDA #$0200
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099673 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$0001
    TSB $10
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [SpawnBeforeFlags] ( @code_0996B0, #$2000 )
    LDY $decelStepCounter
    LDA #$0089
    STA $0002, Y
    LDA #$95CC
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_09963C:
    COP [StageSpriteMoveY] ( #00, #08 )
    COP [AnimOnce]
    LDA $16
    CMP #$0090
    BCS loc_09963C
    COP [WaitByte] ( #3B )
    LDA #$0188
    STA $moveXAlt, X
    LDA #$0110
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [KillPrev]
    COP [SetFlagByte] ( #04 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #00, #0A, #04 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
} >
]

code_099673 {
    COP [PrintWideString] ( &widestring_09967B )
    COP [SetFlagByte] ( #01 )
    RTL 
}

widestring_09967B `[DEF]お前は この地球を 救うために[N]よみがえった人間.[N]さあ 上の階へ 運んであげよう.[END]`

code_0996B0 {
    COP [SetEntryContinue]
    PHX 
    LDX $24
    LDY $decelStepCounter
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC #$0008
    STA $0016, Y
    PLX 
    RTL 
}

actor_def_0996CA [
  actor-def < #00, #00, #30, {

  code_0996CD:
    LDA $sceneCurrent
    CMP #$00DE
    BEQ loc_0996DD
    CMP #$00DF
    BEQ loc_0996FB
    COP [SetEntryContinue]
    RTL 

  loc_0996DD:
    COP [BranchIfFlagByte] ( #D2, #01, &code_0996F9 )
    COP [SetFlagByte] ( #D2 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_09972B )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_0996F9 {
    COP [Die]

  loc_0996FB:
    COP [BranchIfFlagByte] ( #D3, #01, &code_099729 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #3F, #19, #40, #1D, &code_09970C )
    RTL 
}

code_09970C {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    LDA #$0001
    JSL $@chunk_008000.widestring_00C829
    COP [SetFlagByte] ( #D3 )
    COP [PrintWideString] ( &widestring_09976E )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_099729 {
    COP [Die]
}

widestring_09972B `[TPL:A][TPL:0]バベルの塔は 静まりかえっている.[N]まるで このー年半の間 時の流れが[N]止まっていたみたいだった···[END]`

widestring_09976E `[TPL:9][TPL:0][DLY:2]ぼくのもっている笛は ここで[N]発見 されたんだっけ.[END]`

actor_def_099792 [
  actor-def < #02, #00, #30, {

  code_099795:
    LDA #$0200
    TSB $12
    COP [SpawnAfterAbsFlags] ( @code_09994F, #$076E, #$017C, #$0B00 )
    COP [SpawnAfterAbsFlags] ( @code_09994F, #$076E, #$018C, #$0B00 )

  loc_0997B0:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #75, #17, #77, #19, &code_0997BB )

  code_0997BA:
    RTL 
} >
]

code_0997BB {
    COP [BranchIfEquipped] ( #27, &code_0997BA )
    COP [PlaySoundBoth] ( #$1D1D )
    LDA #$0006
    STA $decelCurvePtr
    COP [BranchIfNoItem] ( #27, &code_0997BA )
    COP [BranchIfFlagByte] ( #01, #01, &code_0997DF )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0997EC, #$3802 )
}

code_0997DF {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #75, #17, #77, #19, &code_0997EB )
    BRA loc_0997B0
}

code_0997EB {
    RTL 
}

code_0997EC {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    COP [InitGravity] ( #02, #06, #00 )
    COP [StageForceMoveX] ( #12 )

  loc_099817:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_099817
    LDA $08
    STZ $08
    STA $24

  loc_099823:
    COP [TickGravity]
    CMP #$0000
    BMI loc_099832
    COP [SetEntryExit]
    DEC $24
    BPL loc_099823
    BRA loc_099817

  loc_099832:
    COP [StageSpriteMoveXY] ( #02, #12, #45 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    LDA #$0001
    TSB $10
    COP [StageSpriteLoop] ( #02, #05 )
    COP [AnimLoop]
    LDA #$0800
    TRB $10
    COP [PrintWideString] ( &widestring_099890 )
    LDA #$0800
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_099869 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    RTL 
}

code_099869 {
    LDA #$0800
    TRB $10
    COP [PrintWideString] ( &widestring_0998B4 )
    LDA #$0800
    TSB $10
    COP [GiveItem] ( #27, &code_09988B )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_09990B )
    COP [Die]

  loc_09988A:
    RTL 
}

code_09988B {
    COP [PrintWideString] ( &widestring_099928 )
    RTL 
}

widestring_099890 `[TPL:A][TPL:0]笛から 何か はずれて[N]ころがった みたいだ·····[PAL:0][END]`

widestring_0998B4 `[TPL:A][TPL:0]こ これは エドワード国王が[N]こだわっていた すいしょうの指輪![FIN]笛のかざりかと 思っていたけど[N]こんなところに かくされて[N]いたなんて···[PAL:0][FIN]`

widestring_09990B `[TPL:A][SFX:0][DLY:9]すいしょうの指輪を 手に入れた![PAU:78][END]`

widestring_099928 `[CLR][TPL:0]だが もちものが いっぱいで[N]これ以上 持つことができない![PAL:0][END]`

code_09994F {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    RTL 
}

actor_def_099961 [
  actor-def < #00, #00, #10, {

  code_099964:
    LDA #$0200
    TSB $12
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09998D )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
} >
]

code_09998D {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_099998 )
}

code_list_099998 [
  &code_0999A4   ;00
  &code_0999A9   ;01
  &code_0999AE   ;02
  &code_0999B3   ;03
  &code_0999B8   ;04
  &code_0999BD   ;05
]

code_0999A4 {
    COP [PrintWideString] ( &widestring_0999C2 )
    RTL 
}

code_0999A9 {
    COP [PrintWideString] ( &widestring_099A31 )
    RTL 
}

code_0999AE {
    COP [PrintWideString] ( &widestring_099AA5 )
    RTL 
}

code_0999B3 {
    COP [PrintWideString] ( &widestring_099B1C )
    RTL 
}

code_0999B8 {
    COP [PrintWideString] ( &widestring_099BAB )
    RTL 
}

code_0999BD {
    COP [PrintWideString] ( &widestring_099BF9 )
    RTL 
}

widestring_0999C2 `[TPL:A]あの すい星から 放たれている[N]強れつな光は 生物の成長に 大きな[N]えいきょうを あたえる.[END]`

widestring_0999FC `すい星が 地球のそばを かすめる[N]たびに 生物は げき的な 進化を[N]とげてきたのだ···[END]`

widestring_099A31 `[TPL:B]この バベルの塔の内部は[N]時間の進みかたが ちがう···[N]通常の 何百倍もの スピードで[N]時が 流れてゆく····[FIN]ここで 生きていられるとは[N]あんたら ふつうの 人間じゃ[N]ないね···[END]`

widestring_099AA5 `[TPL:A]生き物は 長い長い 年月をかけて[N]進化してきた.[FIN]三葉虫から 魚が生まれ[N]はちゅう類 ほにゅう類をへて[N]人類が生まれた.[FIN]そして 人類は この先 さらに[N]進化を 続けていくことだろう.[END]`

widestring_099B1C `[TPL:A]すい星は 太古の時代から[N]神の星とよばれ また あくまの星[N]とも よばれてきた.[FIN]だが 今 地球に 近づいている[N]すい星は あくまの星····[FIN]あの星は 高度な 意識をもち[N]地球を 自分の 思い通りに[N]進化させてきたのだ···[END]`

widestring_099BAB `[TPL:B]そこの 部屋には 進化の光を使って[N]作られた 化け物が ねむっている.[N]上の階へいくのなら 彼らを[N]ねむらせてやることだ···[END]`

widestring_099BF9 `[TPL:B]地球は 誤った時間を 誤った進化の[N]道を たどっている···[N]お前たちの 戦いが 地球の運命を[N]変えるのだ.[END]`

actor_def_099C42 [
  actor-def < #1A, #00, #30, {

  code_099C45:
    COP [BranchIfFlagByte] ( #D4, #01, &code_099C56 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #70, #09, #72, #0D, &code_099C58 )
    RTL 
} >
]

code_099C56 {
    COP [Die]
}

code_099C58 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WriteApuIo0] ( #7F )
    COP [PrintWideString] ( &widestring_099CCB )
    LDA #$0003
    JSL $@chunk_008000.widestring_00C829
    COP [SetTilePos] ( #75, #09 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_099CD9 )
    LDY $decelStepCounter
    LDA $0014, Y
    CLC 
    ADC #$0010
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #20, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [WriteApuIo0] ( #01 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetFlagByte] ( #D4 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

widestring_099CCB `[TPL:A][TPL:1]まって····[PAL:0][END]`

widestring_099CD9 `[TPL:B][TPL:0]テム:[N]カレン!!!?[FIN][TPL:1]カレン:[N]ごめんなさい···[N]今 别れたら なんだか 二度と[N]会えないような気がして··[FIN][TPL:0]テム:[N]でも カレンは どうして ここへ[N]入って こられたんだろう?[FIN]この クリスタルリングが[N]なくちゃ ここへは こられない[N]はずなのに···[FIN][TPL:1]カレン: もしかすると[N]この ゆびわのせいかしら···[N]ほら インカの黄金船で 見つけた[N]じゃない?[FIN][TPL:0]この すいしょうの指輪の色は[N]ダークブルー···[FIN]カレンの 持っている指輪は[N]ライトブルー なのか···[FIN]もしかすると これが[N]光とヤミって いうことなのかな.[FIN]テム: わかったよ···[N]何がおこるか わからないし[N]ぼくの そばから はなれるなよ.[PAL:0][END]`

code_099E46 {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    RTL 
}

code_099E4C {
    COP [StageSprAndHitbox] ( #01 )
    LDA #$0000
    STA $24

  loc_099E54:
    COP [SetEntryContinue]
    LDA $24
    BNE loc_099E5B
    RTL 

  loc_099E5B:
    LDA $sfxQueueCh1
    BNE loc_099E61
    RTL 

  loc_099E61:
    COP [RngByte]
    AND #$0003
    DEC 
    BEQ loc_099E77
    DEC 
    BEQ loc_099E82
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_099E54

  loc_099E77:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_099E54

  loc_099E82:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_099E54

  loc_099E8D:
    ORA $00
    BMI loc_099E36
    ASL $2685
    LDA #$2000
    STA $0E
    BRA loc_099EAF

  loc_099E9B:
    ORA $00
    BMI loc_099E44
    ASL $2685
    LDA #$2000
    STA $0E
    COP [StageSprAndHitbox] ( #85 )
    LDA #$0002
    TSB $12

  loc_099EAF:
    COP [AddPosition] ( #F8, #00 )
    COP [SpawnAfterRelFlags] ( @code_09A0C8, #$0000, #$FFD0, #$1800 )
    COP [SpawnAfterRelFlags] ( @code_09A0DB, #$0000, #$FFD0, #$1800 )
    COP [AddPosition] ( #F8, #01 )
    COP [SetOnInteract] ( &code_099ED9 )
    LDA #$0000
    STA $24
    COP [SetEntryContinue]
    RTL 
}

code_099ED9 {
    LDA #$FFFF
    STA $24
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_099EE9 )
}

code_list_099EE9 [
  &code_099EFF   ;00
  &code_099F05   ;01
  &code_099F0B   ;02
  &code_099F11   ;03
  &code_099F17   ;04
  &code_099F1D   ;05
  &code_099F23   ;06
  &code_099F29   ;07
  $#00A9   ;08
  &code_098500   ;09
  $#6B24   ;0A
]

code_099EFF {
    COP [PrintWideString] ( &widestring_099F2F )
    BRA loc_099EF9
}

code_099F05 {
    COP [PrintWideString] ( &widestring_099F31 )
    BRA loc_099EF9
}

code_099F0B {
    COP [PrintWideString] ( &widestring_099F75 )
    BRA loc_099EF9
}

code_099F11 {
    COP [PrintWideString] ( &widestring_099FBA )
    BRA loc_099EF9
}

code_099F17 {
    COP [PrintWideString] ( &widestring_099FF7 )
    BRA loc_099EF9
}

code_099F1D {
    COP [PrintWideString] ( &widestring_09A02D )
    BRA loc_099EF9
}

code_099F23 {
    COP [PrintWideString] ( &widestring_09A074 )
    BRA loc_099EF9
}

code_099F29 {
    COP [PrintWideString] ( &widestring_09A0AA )
    BRA loc_099EF9
}

widestring_099F2F `[DEF][END]`

widestring_099F31 `[DEF]ー定地域の敵を すべてたおすと[N]能力の上がる 宝石があらわれる.[FIN]まものは 残さず たおしてゆく[N]ことだ···[END]`

widestring_099F75 `[DEF]敵をたおすと あらわれる 不思議な[N]宝石たち.[N]手のとどかない ところだったなら[N]フエの力で 引きよせればいい.[END]`

widestring_099FBA `[DEF]ヤミの力を 使うには DPが[N]必要となる···[FIN]DPとは ヤミの玉を 集めれば[N]增えてゆく···[END]`

widestring_099FF7 `[DEF]連続して ジャンプすることも[N]必要だが 時には 止まらなくては[N]ならないこともある···[END]`

widestring_09A02D `[DEF]ピラミッドの石は すきまが多い.[N]下へ向って ブロックが続くユカは[N]そなたの体なら しみこむことが[N]できよう···[END]`

widestring_09A074 `[DEF]戦いの 基本は やられる前に[N]やること.[N]動くものは 動く前に 手をうてば[N]いい····[END]`

widestring_09A0AA `[DEF]くきの切れ目は しずくの力で[N]つながっていく···[END]`

code_09A0C8 {
    COP [StageSprAndHitbox] ( #05 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #05 )

  loc_09A0D1:
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
}

code_09A0DB {
    COP [StageSprAndHitbox] ( #07 )

  loc_09A0DE:
    COP [SetEntryContinue]
    LDY $24
    LDA $0024, Y
    BNE loc_09A0E8
    RTL 

  loc_09A0E8:
    LDA $sfxQueueCh1
    BNE loc_09A0EE
    RTL 

  loc_09A0EE:
    COP [RngByte]
    AND #$0003
    DEC 
    BEQ loc_09A104
    DEC 
    BEQ loc_09A10F
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A0DE

  loc_09A104:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A0DE

  loc_09A10F:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A0DE

  loc_09A11A:
    ORA $00
    BMI loc_09A0C3
    ASL $2685
    LDA #$2000
    STA $0E
    BRA loc_09A13C

  loc_09A128:
    ORA $00
    BMI loc_09A0D1
    ASL $2685
    LDA #$2000
    STA $0E
    COP [StageSprAndHitbox] ( #85 )
    LDA #$0002
    TSB $12

  loc_09A13C:
    COP [AddPosition] ( #F8, #00 )
    COP [SpawnAfterRelFlags] ( @code_09A0C8, #$0000, #$FFD0, #$1800 )
    COP [SpawnAfterRelFlags] ( @code_09A0DB, #$0000, #$FFD0, #$1800 )
    COP [AddPosition] ( #F8, #01 )
    COP [SetOnInteract] ( &code_09A166 )
    LDA #$0000
    STA $24
    COP [SetEntryContinue]
    RTL 
}

code_09A166 {
    LDA #$FFFF
    STA $24
    LDA $0B12
    CMP #$0015
    BNE loc_09A176
    JMP $&code_09A1B4

  loc_09A176:
    CMP #$0042
    BNE loc_09A17E
    JMP $&code_09A22E

  loc_09A17E:
    CMP #$0062
    BNE loc_09A186
    JMP $&code_09A2A2

  loc_09A186:
    CMP #$0086
    BNE loc_09A18E
    JMP $&code_09A339

  loc_09A18E:
    CMP #$00B8
    BNE loc_09A196
    JMP $&code_09A3E0

  loc_09A196:
    CMP #$00CC
    BNE loc_09A19E
    JMP $&code_09A4E9

  loc_09A19E:
    CMP #$00A7
    BNE loc_09A1A6
    JMP $&code_09A468

  loc_09A1A6:
    CMP #$00A1
    BNE code_09A1AE
    JMP $&code_09A584

  code_09A1AE:
    LDA #$0000
    STA $24
    RTL 
}

code_09A1B4 {
    LDA $abilityBitmask
    BIT #$0001
    BNE loc_09A1CC
    LDA $abilityBitmask
    ORA #$0001
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A1D3 )
    JMP $&code_09A1AE

  loc_09A1CC:
    COP [PrintWideString] ( &widestring_09A1E8 )
    JMP $&code_09A1AE
}

widestring_09A1D3 `[DEF]サイコクラッシュを 手にいれた![FIN]`

widestring_09A1E8 `[DEF]サイコクラッシュは 体当たりで[N]障害物を はかいすることができる.[N]こうげきボタンで 力をためて[N]使うがよい···[END]`

code_09A22E {
    LDA $abilityBitmask
    BIT #$0010
    BNE loc_09A246
    LDA $abilityBitmask
    ORA #$0010
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A24D )
    JMP $&code_09A1AE

  loc_09A246:
    COP [PrintWideString] ( &widestring_09A262 )
    JMP $&code_09A1AE
}

widestring_09A24D `[DEF]ライトフライヤーを 手にいれた![FIN]`

widestring_09A262 `[DEF]ライトフライヤーは 敵を ほのおで[N]燒きつくすことができる.[N]こうげきボタンで 力をためて[N]使うがよい···[END]`

code_09A2A2 {
    LDA $abilityBitmask
    BIT #$0002
    BNE loc_09A2BA
    LDA $abilityBitmask
    ORA #$0002
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A2C1 )
    JMP $&code_09A1AE

  loc_09A2BA:
    COP [PrintWideString] ( &widestring_09A2D6 )
    JMP $&code_09A1AE
}

widestring_09A2C1 `[DEF]サイコスライダーを 手にいれた![FIN]`

widestring_09A2D6 `[DEF]サイコスライダーは スライディング[N]こうげきが できるようになる.[N]また せまい通路も 通れるように[N]なるであろう.[FIN]走っている最中に こうげきボタンを[N]おすがよい···[END]`

code_09A339 {
    LDA $abilityBitmask
    BIT #$0004
    BNE loc_09A351
    LDA $abilityBitmask
    ORA #$0004
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A358 )
    JMP $&code_09A1AE

  loc_09A351:
    COP [PrintWideString] ( &widestring_09A36C )
    JMP $&code_09A1AE
}

widestring_09A358 `[DEF]スピンダッシュを 手にいれた![FIN]`

widestring_09A36C `[DEF]スピンダッシュは 自分が[N]高速回転し 敵をはじきとばすことが[N]できる.[FIN]その反動を 利用して 坂を[N]かけあがることもできるであろう.[N]こうげきボタンで 力をため[N]LRを こうごにおすがよい···[END]`

code_09A3E0 {
    LDA $abilityBitmask
    BIT #$0040
    BNE loc_09A3F8
    LDA $abilityBitmask
    ORA #$0040
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A3FF )
    JMP $&code_09A1AE

  loc_09A3F8:
    COP [PrintWideString] ( &widestring_09A414 )
    JMP $&code_09A1AE
}

widestring_09A3FF `[DEF]アースクエイカーを 手にいれた![FIN]`

widestring_09A414 `[DEF]アースクエイカーは じしんを[N]おこすことができる.[FIN]敵は しばらくの間 停止するのだ.[N]飛びおりている最中に[N]こうげきボタンをおすがよい···[END]`

code_09A468 {
    LDA $abilityBitmask
    BIT #$0020
    BNE loc_09A480
    LDA $abilityBitmask
    ORA #$0020
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A487 )
    JMP $&code_09A1AE

  loc_09A480:
    COP [PrintWideString] ( &widestring_09A49A )
    JMP $&code_09A1AE
}

widestring_09A487 `[DEF]オーラバリアを 手にいれた![FIN]`

widestring_09A49A `[DEF]この力は 自分の まわりに[N]オーラでできた バリアをはることが[N]できる.[FIN]こうげきボタンで 力をため[N]LRを こうごにおすがよい···[END]`

code_09A4E9 {
    COP [BranchIfNoItem] ( #24, &code_09A4FA )
    COP [GiveItem] ( #24, &code_09A501 )
    COP [PrintWideString] ( &widestring_09A508 )
    JMP $&code_09A1AE
}

code_09A4FA {
    COP [PrintWideString] ( &widestring_09A51E )
    JMP $&code_09A1AE
}

code_09A501 {
    COP [PrintWideString] ( &widestring_09A55F )
    JMP $&code_09A1AE
}

widestring_09A508 `[DEF]オーラの玉を もっていくがよい··[FIN]`

widestring_09A51E `[DEF]シャドウの体は 質量のない体.[N]この玉を かかげれば[N]たちどころに 体を 水のように[N]することができるのだ.[END]`

widestring_09A55F `[PAU:1E][DEF]持ち物が いっぱいのようだな.[N]どこかで へらしてくるがよい.[END]`

code_09A584 {
    COP [PrintWideString] ( &widestring_09A589 )
    RTL 
}

widestring_09A589 `[DEF]クモは くきから くきへと[N]糸を使って わたってくる.[N]糸のないものは 飛べばいい···[END]`

actor_def_09A5BD [
  actor-def < #15, #00, #20, {

  code_09A5C0:
    LDA #$0008
    TSB $12
    COP [BranchIfFlagByte] ( #DE, #01, &code_09A647 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_09A5D3 )
    RTL 
} >
]

code_09A5D3 {
    COP [SetFlagByte] ( #DE )
    COP [SpawnMarkedAfter] ( @code_09A649, #$0102 )
    LDA #$04B0
    STA $24

  code_09A5E2:
    COP [DirToPlayer]
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_09A5ED )
}

code_list_09A5ED [
  &code_09A5FD   ;00
  &code_09A601   ;01
  &code_09A607   ;02
  &code_09A60B   ;03
  &code_09A611   ;04
  &code_09A615   ;05
  &code_09A61B   ;06
  &code_09A61F   ;07
]

code_09A5FD {
    DEC $16
    BRA loc_09A625
}

code_09A601 {
    DEC $16
    INC $14
    BRA loc_09A625
}

code_09A607 {
    INC $14
    BRA loc_09A625
}

code_09A60B {
    INC $16
    INC $14
    BRA loc_09A625
}

code_09A611 {
    INC $16
    BRA loc_09A625
}

code_09A615 {
    INC $16
    DEC $14
    BRA loc_09A625
}

code_09A61B {
    DEC $14
    BRA loc_09A625
}

code_09A61F {
    DEC $16
    DEC $14
    BRA loc_09A625

  loc_09A625:
    DEC $24
    BEQ loc_09A62E
    COP [SetEntryExitNow] ( @code_09A5E2 )

  loc_09A62E:
    COP [PrintWideString] ( &widestring_09A6BF )
    LDA #$0060
    STA $moveXAlt, X
    LDA #$0030
    STA $moveYAlt, X
    COP [StageMove] ( #00, #01, #FF )
    COP [TickMove]
}

code_09A647 {
    COP [Die]
}

code_09A649 {
    LDA #$0030
    TSB $12
    LDA #$AD68
    STA $statsPtr, X
    LDA $@stats_table+190
    AND #$00FF
    STA $currentHp, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #33 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X

  loc_09A676:
    COP [SetHitCallback] ( &code_09A69D )

  loc_09A67A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_09A67A
    LDA $08
    STZ $08
    STA $26

  loc_09A686:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
    COP [SetEntryExit]
    DEC $26
    BPL loc_09A686
    BRA loc_09A67A
}

code_09A69D {
    LDA #$00FF
    STA $currentHp, X
    COP [PrintWideString] ( &widestring_09A6AA )
    BRA loc_09A676
}

widestring_09A6AA `[DEF][TPL:2]いたいっ! 何するのよっ!![PAL:0][END]`

widestring_09A6BF `[DEF][TPL:2]早く こっちに 来なさいよっ![N]まものに やられちゃうじゃないっ![PAL:0][END]`

actor_def_09A6E8 [
  actor-def < #15, #00, #10, {

  code_09A6EB:
    COP [BranchIfFlagByte] ( #DF, #01, &code_09A714 )
    COP [SetFlagByte] ( #DF )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteLoop] ( #33, #02 )
    COP [AnimLoop]
    LDA #$0048
    STA $moveXAlt, X
    LDA #$0050
    STA $moveYAlt, X
    COP [StageMove] ( #33, #02, #FF )
    COP [TickMove]
} >
]

code_09A714 {
    COP [Die]
}

actor_def_09A716 [
  actor-def < #00, #00, #18, {

  code_09A719:
    LDA #$4000
    TSB $09FA
    SEP #$20
    LDA #$01
    STA $MEMSEL
    LDA #$10
    STA $TM
    REP #$20
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [AddPosition] ( #08, #00 )
    COP [StageSpriteLoop] ( #00, #03 )
    COP [AnimLoop]
    JSL $@chunk_028000.code_028168
    SEP #$20
    LDA #$00
    STA $TM
    REP #$20
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 )
    COP [Die]
} >
]

actor_def_09A756 [
  actor-def < #00, #00, #30, {

  code_09A759:
    LDA #$4001
    TSB $09FA
    LDA #$0000
    STA $cgramPalette
    COP [CopyPalette] ( @pal_title, #00, #00, #08 )
    COP [SpawnAfterAbsFlags] ( @code_09A7BC, #$0060, #$00A6, #$1800 )
    COP [SpawnAfterAbsFlags] ( @code_09A7CE, #$0080, #$00A6, #$1800 )
    COP [SpawnAfterAbsFlags] ( @code_09A7E0, #$00A0, #$00A6, #$1800 )
    SEP #$20
    LDA #$17
    STA $TM
    REP #$20
    COP [RunBg3Script] ( @binary_01D9FB+6 )
    COP [RunBg3Script] ( @binary_01D9FB+1D )
    COP [WaitWord] ( #$0B7B )
    COP [SetFlagByte] ( #F4 )
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09A7BC {
    COP [SetSpritePriority] ( #30 )
    COP [SpawnAfterFlags] ( @code_09A7F2, #$1000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    RTL 
}

code_09A7CE {
    COP [SetSpritePriority] ( #30 )
    COP [SpawnAfterFlags] ( @code_09A7F2, #$1000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    RTL 
}

code_09A7E0 {
    COP [SetSpritePriority] ( #30 )
    COP [SpawnAfterFlags] ( @code_09A7F2, #$1000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    RTL 
}

code_09A7F2 {
    COP [SetSpritePalette] ( #0A )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    RTL 
}

actor_def_09A800 [
  actor-def < #00, #00, #38, {

  code_09A803:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [BranchIfButton] ( #$1001, &code_09A810 )
    RTL 
} >
]

code_09A810 {
    STZ $0DB6
    LDA #$0000
    STA $gfxCacheIdxB
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #FA, #$0100, #$0370, #00, #$4400 )
    COP [SetEntryExit]
    PHD 
    PHX 
    LDA #$0000
    TCD 
    JSL $@chunk_028000.code_028168
    PLX 
    PLD 
    COP [SetEntryContinue]
    SEP #$20
    LDA #$00
    STA $INIDISP
    REP #$20
    RTL 
}

actor_def_09A843 [
  actor-def < #00, #00, #38, {

  code_09A846:
    LDA #$0800
    STA $gfxCacheIdxB
    COP [BranchIfFlagByte] ( #F4, #00, &code_09A8D9 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AE41
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09A8DB, #$016E, #$03E8, #$1800 )
    COP [WaitByte] ( #00 )
    COP [SpawnAfterAbsFlags] ( @code_09A8DB, #$0166, #$041A, #$1800 )
    COP [WaitByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @code_09A8DB, #$01A4, #$03F0, #$1800 )
    COP [WaitByte] ( #00 )
    COP [SpawnAfterAbsFlags] ( @code_09A8DB, #$01A0, #$040C, #$1800 )
    COP [WaitByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @code_09A8DB, #$01D2, #$03FC, #$1800 )
    SEP #$20
    STZ $M7SEL
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_038000.code_03A6CD )
    TXA 
    TYX 
    TAY 
    LDA #$0804
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SpawnBeforeFlags] ( @code_09A8E9, #$2800 )
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0020, #$2000 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09A8D9 {
    COP [Die]
}

code_09A8DB {
    COP [StageSpriteMoveX] ( #8B, #11 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_09A8DB )
    COP [Die]
}

code_09A8E9 {
    LDA #$03FC
    STA $24
    LDA #$0000
    STA $cameraTargetX
    LDA #$0360
    STA $cameraTargetY
    LDA #$0080
    STA $00CA
    LDA #$03E0
    STA $00CC
    LDA #$0280
    STA $00B6
    LDA #$0020
    STA $00B8
    STZ $00BC
    COP [SetEntryContinue]
    LDA $cameraTargetX
    INC 
    AND #$03FF
    STA $cameraTargetX
    CLC 
    ADC #$0080
    STA $00CA
    DEC $24
    BMI loc_09A92D
    RTL 

  loc_09A92D:
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    INC $00BC
    DEC $00B6
    LDA $00B6
    CMP #$0180
    BEQ loc_09A946
    CMP #$00D0
    BEQ loc_09A94C
    RTL 

  loc_09A946:
    COP [SpawnThinker] ( @code_09AE36 )
    RTL 

  loc_09A94C:
    COP [ClearFlagByte] ( #F4 )
    LDA #$0808
    STA $gfxCacheIdxB
    COP [ClearFlagWord] ( #$017C )
    COP [ClearFlagWord] ( #$017D )
    COP [ClearFlagWord] ( #$017E )
    COP [ClearFlagWord] ( #$017F )
    COP [QueueMapChange] ( #8D, #$0000, #$0000, #00, #$4400 )
    COP [SetEntryContinue]
    DEC $00B6
    INC $00BC
    RTL 
}

actor_def_09A978 [
  actor-def < #00, #00, #38, {

  code_09A97B:
    SEP #$20
    STZ $M7SEL
    REP #$20
    COP [CopyPalette] ( @pal_prologue_legends, #00, #00, #20 )
    COP [BranchIfFlagWord] ( #$017C, #01, &code_09A9BA )
    COP [SetFlagWord] ( #$017C )
    COP [SpawnBeforeFlags] ( @code_09AA73, #$2800 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AE94
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [Die]
} >
]

code_09A9BA {
    COP [BranchIfFlagWord] ( #$017D, #01, &code_09A9EA )
    COP [SetFlagWord] ( #$017D )
    COP [SpawnBeforeFlags] ( @code_09AAA3, #$2800 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AEB5
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [Die]
}

code_09A9EA {
    COP [BranchIfFlagWord] ( #$017E, #01, &code_09AA1A )
    COP [SetFlagWord] ( #$017E )
    COP [SpawnBeforeFlags] ( @code_09AACD, #$2800 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AEE9
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [Die]
}

code_09AA1A {
    COP [BranchIfFlagWord] ( #$017F, #01, &code_09AA4A )
    COP [SetFlagWord] ( #$017F )
    COP [SpawnBeforeFlags] ( @code_09AAF6, #$2800 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AF09
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [Die]
}

code_09AA4A {
    COP [SpawnBeforeFlags] ( @code_09AB1F, #$2800 )
    COP [ClearFlagWord] ( #$017C )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AF36
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [Die]
}

code_09AA73 {
    JSR $&code_09AB6E
    COP [SetEntryContinue]
    LDA $0036
    AND #$0003
    BNE loc_09AA86
    DEC $00CA
    DEC $cameraTargetX

  loc_09AA86:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00C0
    BEQ code_09AA9D
    CMP #$008B
    BCC loc_09AA9A
    RTL 

  loc_09AA9A:
    JMP $&code_09AB3D

  code_09AA9D:
    COP [SpawnThinker] ( @code_09AE36 )
    RTL 
}

code_09AAA3 {
    JSR $&code_09AB6E
    COP [SetEntryContinue]
    LDA $0036
    AND #$0003
    BNE loc_09AAB6
    INC $00CA
    INC $cameraTargetX

  loc_09AAB6:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00C0
    BEQ code_09AA9D
    CMP #$008B
    BCC loc_09AACA
    RTL 

  loc_09AACA:
    JMP $&code_09AB3D
}

code_09AACD {
    JSR $&code_09AB6E
    COP [SetEntryContinue]
    LDA $0036
    AND #$0003
    BNE loc_09AAE0
    INC $00CC
    INC $cameraTargetY

  loc_09AAE0:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00C0
    BEQ code_09AA9D
    CMP #$008B
    BCC loc_09AAF4
    RTL 

  loc_09AAF4:
    BRA code_09AB3D
}

code_09AAF6 {
    JSR $&code_09AB6E
    COP [SetEntryContinue]
    LDA $0036
    AND #$0003
    BNE loc_09AB09
    DEC $00CC
    DEC $cameraTargetY

  loc_09AB09:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00C0
    BEQ code_09AA9D
    CMP #$008B
    BCC loc_09AB1D
    RTL 

  loc_09AB1D:
    BRA code_09AB3D
}

code_09AB1F {
    JSR $&code_09AB6E
    COP [SetEntryContinue]
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$0050
    BNE loc_09AB35
    JMP $&code_09AA9D

  loc_09AB35:
    CMP #$0000
    BEQ loc_09AB3B
    RTL 

  loc_09AB3B:
    BRA code_09AB3D
}

code_09AB3D {
    COP [BranchIfFlagWord] ( #$017C, #00, &code_09AB5C )
    LDA #$0200
    STA $gfxCacheIdxB
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #8D, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_09AB5C {
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8E, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_09AB6E {
    LDA #$0200
    STA $00C2
    LDA #$0200
    STA $00C8
    LDA #$0200
    STA $00CA
    LDA #$0200
    STA $00CC
    LDA #$0180
    STA $cameraTargetX
    LDA #$0180
    STA $cameraTargetY
    RTS 
}

actor_def_09AB93 [
  actor-def < #00, #00, #38, {

  code_09AB96:
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AF74
    JSL $@code_09B035
    PLB 
    LDA #$4001
    TSB $09FA
    COP [CopyPalette] ( @pal_prologue_missing, #00, #00, #20 )
    LDA #$0A00
    STA $gfxCacheIdxB
    LDA #$0220
    STA $cameraBoundsY
    SEP #$20
    LDA #$81
    STA $CGADSUB
    LDA #$EF
    STA $COLDATA
    REP #$20
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    AND #$FFF7
    STA $0010, Y
    COP [SpawnAfterFlags] ( @code_09AC40, #$2800 )
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0016, Y
    INC 
    STA $0016, Y
    CMP #$01A0
    BEQ loc_09ABF7
    RTL 

  loc_09ABF7:
    LDA #$000F
    STA $24

  loc_09ABFC:
    COP [WaitByte] ( #09 )
    SEP #$20
    LDA $24
    ORA #$E0
    STA $COLDATA
    REP #$20
    LDA $24
    BEQ loc_09AC13
    DEC 
    STA $24
    BRA loc_09ABFC

  loc_09AC13:
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [WaitWord] ( #$010D )
    COP [SpawnThinker] ( @code_09AE36 )
    COP [WaitByte] ( #59 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8F, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09AC3D {
    COP [SetEntryContinue]
    RTL 
}

code_09AC40 {
    COP [RngByte]
    AND #$0007
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_09AC55, #$1800 )
    BRA code_09AC40
}

code_09AC55 {
    LDA #$0100
    STA $14
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0138
    STA $16
    COP [StageSpriteLoopMoveX] ( #0C, #08, #02 )
    COP [AnimLoop]
    COP [Die]
}

actor_def_09AC6E [
  actor-def < #00, #00, #30, {

  code_09AC71:
    LDA #$4001
    TSB $09FA
    COP [CopyPalette] ( @pal_prologue_mishap, #00, #00, #20 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AFB0
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0050, #$2000 )
    COP [WaitWord] ( #$010D )
    COP [SpawnThinker] ( @code_09AE36 )
    COP [WaitByte] ( #59 )
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_09ACBA [
  actor-def < #00, #00, #38, {

  code_09ACBD:
    COP [BranchIfFlagByte] ( #F4, #01, &code_09AD07 )
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    LDY #$AFEC
    JSL $@code_09B035
    PLB 
    COP [SpawnAfterAbsFlags] ( @code_09AD9E, #$0020, #$0020, #$2000 )
    SEP #$20
    STZ $M7SEL
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_038000.code_03A6CD )
    TXA 
    TYX 
    TAY 
    LDA #$0804
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SpawnBeforeFlags] ( @code_09AD09, #$2800 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09AD07 {
    COP [Die]
}

code_09AD09 {
    LDA #$0200
    STA $00B6
    LDA #$0020
    STA $00B8
    STZ $00BC
    LDA #$0280
    STA $cameraTargetX
    LDA #$0300
    STA $cameraTargetY
    LDA #$0300
    STA $00CA
    LDA #$0380
    STA $00CC
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CMP #$0040
    BEQ loc_09AD4C
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0080
    STA $00CC
    RTL 

  loc_09AD4C:
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CMP #$FFD8
    BEQ loc_09AD6B
    SEC 
    SBC #$0001
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0080
    STA $00CC
    DEC $00B6
    RTL 

  loc_09AD6B:
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #82 )
    DEC $00B6
    COP [LoopNext]
    COP [SpawnThinker] ( @code_09AE36 )
    COP [LoopInit] ( #64 )
    DEC $00B6
    COP [LoopNext]
    LDA #$0008
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    DEC $00B6
    BEQ loc_09AD9B
    RTL 

  loc_09AD9B:
    COP [SetEntryContinue]
    RTL 
}

code_09AD9E {
    LDA #$0000
    STA $7F0B22
    STA $7F0B24
    COP [SpawnThinker] ( @code_09AE2E )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #0F, #01, &code_09AE2C )
    PHD 
    LDA #$3200
    STA $0002
    STZ $0000
    LDA #$0000
    TCD 
    SEP #$20
    LDA $0014, X
    STA $1C
    STA $18
    LDA $0016, X
    STA $19
    LDX #$0000
    TXY 

  loc_09ADD6:
    REP #$20
    LDA $0100, Y
    BMI loc_09AE24
    DEC 
    STA $0E
    INY 
    INY 

  loc_09ADE2:
    REP #$20
    LDA $00
    ORA $02
    STA $7F3102, X
    LDA $18
    STA $oamComposeBuffer, X
    INX 
    INX 
    INX 
    INX 
    SEP #$20
    LDA $00
    CLC 
    ADC #$02
    BIT #$0F
    BNE loc_09AE08
    CLC 
    ADC #$10
    STA $00
    BRA loc_09AE0A

  loc_09AE08:
    STA $00

  loc_09AE0A:
    DEC $0E
    BMI loc_09AE17
    LDA $18
    CLC 
    ADC #$10
    STA $18
    BRA loc_09ADE2

  loc_09AE17:
    LDA $1C
    STA $18
    LDA $19
    CLC 
    ADC #$10
    STA $19
    BRA loc_09ADD6

  loc_09AE24:
    STX $00D8
    STX $00DA
    PLD 
    RTL 
}

code_09AE2C {
    COP [Die]
}

code_09AE2E {
    COP [PaletteStart] ( #75 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_09AE36 {
    COP [PaletteStart] ( #76 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #0F )
    COP [KillThinker]
    RTL 
}
---------------------------------------------

widestring_09AE41 ` 世界は 大航海時代の[N]  真っ直中だった.[N]人々は 新大陸へと 足を[N]のばし 古代文明の遺産を[N] はっくつしていった.`

widestring_09AE94 `はるかなる 時の流れは[N]数々の伝說を生み出した.`

widestring_09AEB5 `遺跡の数だけ 伝說があり[N]伝說の数だけ 古代文明が[N]  存在したのだ···`

widestring_09AEE9 ` 遺跡から 発見される[N]さまざまな 出土品たち.`

widestring_09AF09 `その中には 必ずと言って[N]いいほど 神をかたどった[N]きみょうな石像があった.`

widestring_09AF36 `古代人にとっての 神とは[N]いったい 何なのか···[N]遺跡は 口を閉ざしたまま[N]静かに たたずんでいる.`

widestring_09AF74 `失われた時の みりょくに[N] とりつかれた 人々は[N]遺跡へと 足をふみ入れ[N]帰らぬ人に なってゆく.`

widestring_09AFB0 `ある者は財宝を守るための[N]  ワナだと 言い[N]また ある者は 古代人の[N] のろいだと 語った.`

widestring_09AFEC `  だが それらが[N]これから 起ころうとする[N] とてつもない 災いに[N]  結びつこうとは[N]だれー人として 気づか[N]  なかった···`

code_09B035 {
    PHP 
    REP #$20
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    REP #$20
    LDA #$4000
    STA $VMADDL
    STZ $08
    STZ $22
    STZ $0D70
    LDA #$0100
    STA $20
    STZ $0100

  loc_09B060:
    REP #$20
    LDX #$0000

  loc_09B065:
    LDA #$0000
    STA $mode7Tilemap, X
    STA $7EE002, X
    STA $7EE004, X
    STA $7EE006, X
    STA $7EE008, X
    STA $7EE00A, X
    STA $7EE00C, X
    STA $7EE00E, X
    TXA 
    CLC 
    ADC #$0010
    TAX 
    CPX #$0800
    BCC loc_09B065
    SEP #$20
    LDX #$E000
    STX $3E
    LDA #$7E
    STA $40
    STA $44
    BRA loc_09B0AF

  code_09B0A2:
    LDA $22
    CMP #$10
    BNE loc_09B0AF
    STZ $22
    JSR $&code_09B1B0
    BRA loc_09B060

  loc_09B0AF:
    PEA $&code_09B0A2-1
    LDA $0000, Y
    BMI loc_09B0BC
    INY 
    JSR $&code_09B12E
    RTS 

  loc_09B0BC:
    INY 
    BIT #$40
    BNE loc_09B0C5
    JSR $&code_09B107
    RTS 

  loc_09B0C5:
    AND #$1F
    CMP #$14
    BEQ loc_09B0E9
    CMP #$15
    BEQ loc_09B0E4
    CMP #$0D
    BNE loc_09B0EE
    REP #$20
    LDA $0D70
    STA ($20)
    INC $20
    INC $20
    STZ $0D70
    SEP #$20
    RTS 

  loc_09B0E4:
    LDA #$00
    STA $09
    RTS 

  loc_09B0E9:
    LDA #$20
    STA $09
    RTS 

  loc_09B0EE:
    JSR $&code_09B1B0
    REP #$20
    LDA $0D70
    STA ($20)
    INC $20
    INC $20
    LDA #$FFFF
    STA ($20)
    PLA 
    PLA 
    TCD 
    TAX 
    PLP 
    RTL 
}

code_09B107 {
    AND #$3F
    XBA 
    LDA $0000, Y
    INY 
    REP #$20
    PHA 
    AND #$01FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $62
    PLA 
    XBA 
    AND #$00FF
    LSR 
    CLC 
    ADC #$00C2
    STA $64
    JSR $&code_09B14A
    SEP #$20
    RTS 
}

code_09B12E {
    PHA 
    LDA #$C1
    STA $64
    PLA 
    REP #$20
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $08
    STA $62
    JSR $&code_09B14A
    SEP #$20
    RTS 
}

code_09B14A {
    PHY 
    INC $0D70
    INC $22
    LDY #$0000
    LDA $3E
    STA $42
    LDA #$0001
    STA $10

  loc_09B15C:
    LDA #$0001
    STA $0E

  loc_09B161:
    LDX #$0007

  loc_09B164:
    LDA [$62], Y
    STA $00
    SEP #$20
    EOR $01
    EOR #$FF
    TRB $00
    TRB $01
    REP #$20
    LDA $00
    STA [$42], Y
    INY 
    INY 
    DEX 
    BPL loc_09B164
    LDA $42
    CLC 
    ADC #$0010
    STA $42
    DEC $0E
    BPL loc_09B161
    LDA $42
    CLC 
    ADC #$01C0
    STA $42
    DEC $10
    BPL loc_09B15C
    LDA $3E
    PHA 
    CLC 
    ADC #$0040
    STA $3E
    EOR $01, S
    BIT #$0200
    BEQ loc_09B1AD
    LDA #$0200
    CLC 
    ADC $3E
    STA $3E

  loc_09B1AD:
    PLA 
    PLY 
    RTS 
}

code_09B1B0 {
    REP #$20
    LDA #$E000
    STA $A1T0L
    LDA #$0800
    STA $DAS0L
    SEP #$20
    LDA #$7E
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    RTS 
}

code_09B1CB {
    BRK #$00
    SEC 
    LDA #$78
    BRK #$85
    BIT $A5
    BIT $C9
    TSB $00
    BEQ loc_09B1DC
    DEC $24

  loc_09B1DC:
    LDA $24
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_09B1EB, #$1802 )
    BRA loc_09B1D3
}

code_09B1EB {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    COP [SetSpritePriority] ( #30 )
    LDA #$E0
    SBC $021685, X
    AND $48, S
    ASL 
    CLC 
    ADC #$C4
    BRK #$85
    TRB $68
    AND #$03
    BRK #$0A
    CLC 
    ADC #$04
    BRK #$9F
    CLC 
    BRK #$7F
    DEC 
    STA $moveYAlt, X
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $16
    CMP #$00
    COP [StagePlayerMoveX] ( #F3, #02 )
    CPX #$001B
    BPL loc_09B1D3
    BEQ loc_09B22B
    TSB $joypadMaskStd
    LDA #$01
    RTI 
    TSB $09FA
    COP [SpawnThinkerParam] ( #0B, @chunk_008000.code_00B5C4 )
    SEP #$20
    LDA #$13
    STA $TM
    LDA #$04
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [BranchIfFlagByte] ( #DB, #01, &code_09B2A5 )
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_09B486 )
    COP [SpawnAfterAbsFlags] ( @code_09B40C, #$0088, #$0080, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_09B4CC )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_09B5FC )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @code_09B467, #$00A0, #$FFF0, #$1800 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [PrintWideString] ( &widestring_09B62F )
    COP [SetFlagByte] ( #DB )
    LDA #$0202
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #90, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_09B2A5 {
    COP [SpawnAfterAbsFlags] ( @code_09B425, #$0078, #$0080, #$1800 )
    COP [SpawnAfterAbsFlags] ( @code_09B425, #$0098, #$0080, #$1800 )
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_09B888 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [FadeThenStartMusic] ( #13 )
    COP [WaitByte] ( #EF )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDY $decelStepCounter
    SEP #$20
    LDA #$89
    STA $0002, Y
    REP #$20
    LDA #$B3C2
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_09BABC )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #04, #00 )
    COP [PrintWideString] ( &widestring_09BB4E )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_09BBF1 )
    COP [StageSpriteMoveX] ( #21, #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_09BC15 )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [WaitByte] ( #77 )
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #1F, #01 )
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_09B365
    RTL 

  loc_09B365:
    LDY $decelStepCounter
    LDA #$0089
    STA $0002, Y
    LDA #$B3E5
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_09B38B
    RTL 

  loc_09B38B:
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

  loc_09B3C2:
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

code_09B3E5 {
    LDA #$0008
    TRB $10
    COP [StagePlayerSprite] ( #1C )
    COP [AnimOnce]
    COP [ToggleVFlip]

  loc_09B3F1:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_09B3F1
    LDA #$0800
    TRB $slopeCurvePtrB
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

code_09B40C {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
}

code_09B425 {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_09B44D )
    COP [BranchIfFlagByte] ( #02, #01, &code_09B440 )
    RTL 
}

code_09B440 {
    COP [StageSpriteMoveX] ( #04, #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_09B44D {
    COP [StageSpriteLoopMoveY] ( #04, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #04, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #04, #08, #02 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #03 )
    COP [Die]
}

code_09B467 {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [StageSpriteLoopMoveY] ( #04, #06, #01 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_09B44D )
    RTL 
}

widestring_09B486 `[DLG:3,4][SIZ:D,3,0][SFX:0][TPL:1][SFX:0][DLY:6]カレン:[N]すい星は どうなったのかしら··?[N][PAU:78][CLR]あの 青くかがやいている星は[N]いったい?[PAU:B4][CLD]`

widestring_09B4CC `[DLG:3,4][SIZ:D,3,0][TPL:4][SFX:0][DLY:6]テムの父:[N]すい星は その力を失った.[N][PAU:78][CLR]あくまの星は 今[N]宇宙の彼方へ 飛び去ろうと[N]しているのだ···[PAU:B4][CLR][TPL:4][SFX:0][DLY:6]テム.[N][PAU:28]あの 暗やみに うかんでいる[N]青い星が 何だか わかるか?[PAU:B4][CLR][TPL:0][SFX:0]テム:[N]あれが ぼくたちの星···?[PAU:78][CLR][TPL:4][SFX:0]テムの父:[N]そう. あれが 我々の星 地球だ.[N][PAU:78][CLR]さばくのオアシスのように 見える[N]だろう?[PAU:B4][CLR][TPL:1][SFX:0]カレン:[N]地球って あんなに きれいだった[N]のね.[PAU:B4][CLR]でも ヤミの中に ぽつんと光ってて[N]なんだか さびしそう···[PAU:B4][CLD]`

widestring_09B5FC `[DLG:3,4][SIZ:D,2,0][SFX:0][DLY:6][TPL:2][SFX:0]不思議な声: そうよ.[N]地球は さみしがっているの.[PAU:B4][CLD]`

widestring_09B62F `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][CLR][TPL:0][SFX:0]テム:[N]かあさんっ!?[PAU:B4][CLR][TPL:2][SFX:0]テムの母: 地球はね.[N]何億人という 子供をもった[N]お母さんなの.[PAU:B4][CLR]テムは 時々 あたしたちのことを[N]思い出してくれるし カレンだって[N]ご両親を想うことがあるでしょう?[PAU:B4][CLR]地球だって同じ.[N]子供に 忘れられたら さびしい[N]ものよ.[PAU:B4][CLR][TPL:4][SFX:0]テムの父: どうだ? 二人とも?[N][PAU:3C]自分たちの 住んでいた星を 外から[N]ながめた 気分は?[PAU:B4][CLR][TPL:1][SFX:0]カレン:[N]あたしたち まるで[N]神樣に なったみたい···[PAU:B4][CLR][TPL:0][SFX:0]テム:[N]ロブたちにも 見せてあげたい···[PAU:78][CLR]いや 世界中の人に この景色を[N]見せてあげたいよ···[PAU:B4][CLR][TPL:4][SFX:0]テムの父:[N]人類は いずれ 宇宙へ行く船を[N]自分たちの力で 作り出す.[PAU:B4][CLR]そして この 青い地球を[N]自分たちの目で 見ることになる[N]だろう.[PAU:B4][CLR]その時 テムや カレンと[N]同じように さびしそうな顔をした[N]地球に 気がついてほしいものだ.[PAU:B4][CLR]テムの父: ほら.[N]お前のもっている 世界地図を[N]よく 見てごらん.[PAU:B4][CLR][TPL:0][SFX:0]テム:[N]あっ.[N]地図の形が 変わり始めてるっ![PAU:B4][CLD]`

widestring_09B888 `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][CLR][TPL:0][SFX:0]テム:[N]父さんも 母さんも どうして[N]未来のことまで 知ってるの?[PAU:B4][CLR][TPL:4][SFX:0]テムの父:[N]私は 肉体を 失ったとき[N]すべてが見えるようになったのだ.[PAU:B4][CLR]過去のことも 未来のことも[N]そして 人類の たどる道もね.[PAU:B4][CLR]人は こういう体を[N]神と 呼ぶのかも しれない.[PAU:B4][CLR][TPL:2][SFX:0]テムの母: とにかく[N]テムも カレンも これで[N]ふつうの子供に もどれるのよ.[PAU:B4][CLR]もう こわい 思いは しなくて[N]いいの.[PAU:B4][CLR][TPL:1][SFX:0]カレン:[N]地球に もどったら あたしたち[N]はなればなれに なっちゃうの?[PAU:B4][CLR][TPL:4][SFX:0]テムの父: そうだ···[N][PAU:28]地球も変わるし 人も 歷史も[N]すべてが 新しい道を歩み始める.[PAU:B4][CLR]お前たちは たとえ[N]どこかの 街角で 出会っても[N]おたがい 気づかないだろう···[PAU:B4][CLR]だが 地球が 光とヤミの戦士を[N]必要としたとき お前たちは[N]再び めぐりあうかもしれんな.[PAU:B4][CLR]さあ すい星の力が 消えないうちに[N]地球へ 向かいなさい.[PAU:B4][CLR][TPL:2][SFX:0]テムの母:[N]二人に すてきな未来が 訪れると[N]いいわね···[PAU:B4][CLD]`

widestring_09BABC `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][TPL:1][SFX:0]カレン: テム···[N][PAU:28]こっちへ きて···[N][PAU:50]そして 顔を よく見せて···[PAU:B4][CLR]しっかりと 心に 燒きつけて[N]おきたいの.[PAU:B4][CLR]テムの目も [PAU:1E]鼻も [PAU:1E]口も[N][PAU:28]カミの毛も [PAU:1E]声も[N][PAU:28]手のぬくもりも···[PAU:B4][CLD]`

widestring_09BB4E `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][TPL:0][SFX:0]テム: 心配 しなくていいよ.[N][PAU:3C]ぼくは カレンのことを 必ず[N]さがしだすからさ.[PAU:B4][CLR]たとえ 何年 かかっても,[N][PAU:3C]100年かかっても [PAU:1E]1000年[N]かかっても [PAU:1E]必ず むかえにいく.[PAU:B4][CLR]だから 安心して···[N][PAU:5A]そして 目を 閉じて····[PAU:78][CLD]`

widestring_09BBF1 `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][TPL:1][SFX:0]カレン:[N]テム······[PAU:78][CLD]`

widestring_09BC15 `[DLG:3,4][SIZ:D,3,0][SFX:0][DLY:6][TPL:0][SFX:0]テム:[N]さあ 行くよ.[N]地球へ····[PAU:B4][CLR][TPL:1][SFX:0]カレン:[N]うん·····[PAU:B4][CLD]`

actor_def_09BC55 [
  actor-def < #00, #00, #30, {

  code_09BC58:
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$4001
    TSB $09FA
    SEP #$20
    LDA #$02
    STA $CGWSEL
    LDA #$41
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #80 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #81 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #82 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #83 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #84 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_09BCE9 )
    COP [WaitByte] ( #B3 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

widestring_09BCE9 `[DLG:3,13][SIZ:D,3,0][SFX:0][TPL:0][SFX:0][DLY:6]テム:[N]陸地が なんだか 変な形に[N]なっちゃった.[PAU:B4][CLR][TPL:4][SFX:0]テムの父:[N]それが 新しい世界だよ.[PAU:B4][CLR][TPL:1][SFX:0]カレン:[N]新しい世界?[PAU:B4][CLR][TPL:4][SFX:0]テムの父:[N]これまで 生き物は すい星の力で[N]誤った進化を 続けてきた.[PAU:B4][CLR]地球も ひとつの 生命.[N][PAU:3C]同じように 進化し その姿が[N]変わっていたのさ.[PAU:B4][CLR]すい星の力が およばなくなった今[N]世界は 本来の姿に もどったと[N]いうわけだ.[PAU:B4][CLD]`

actor_def_09BDEC [
  actor-def < #00, #00, #30, {

  code_09BDEF:
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$4001
    TSB $09FA
    SEP #$20
    LDA #$11
    STA $TM
    LDA #$04
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$01
    STA $CGADSUB
    REP #$20
    COP [WaitWord] ( #$00EF )
    COP [PrintWideString] ( &widestring_09BE38 )
    COP [WaitWord] ( #$01DF )
    COP [FadeThenStartMusic] ( #14 )
    COP [WaitByte] ( #B3 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #F7, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

widestring_09BE38 `[DEF][SFX:0][DLY:8]地球は その よそおいを 大きく[N]変えたが あかね色にそまった世界は[N]あいかわらず 美しかった.[PAU:B4][CLR]森が ビルの群れになり[N]川が 車の流れに 変わっても[N]町の中は人々の芺顔であふれている.[PAU:B4][CLR]ただ 地球だけが ー人ぼっちで[N]さびしそうに見えた.[PAU:B4][CLR]明日の朝 目覚めたときには[N]ぼくや カレンの[N]新しい生活が はじまる.[PAU:B4][CLR]これからの 地球の未来を[N]すべて 知っているかのように[N]1993年の バベルの塔は[N]空高く そびえていた···[PAU:F0][CLD]`

actor_def_09BF4D [
  actor-def < #00, #00, #38, {

  code_09BF50:
    LDA #$FFFF
    STA $00E4
    LDA #$4001
    TSB $09FA
    SEP #$20
    LDA #$00
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    LDA #$0000
    STA $cgramPalette
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [Decompress] ( @gfx_sc02_main_characters, $7EA000 )
    COP [Decompress] ( @binary_1EEDBB, $7EC000 )
    COP [Decompress] ( @binary_0D44DB, $7EE000 )
    COP [Decompress] ( @palette_1B4166, $7E6000 )
    COP [CopyPalette] ( @palette_1F7AA1, #01, #01, #1F )
    COP [AdhocVramDma] ( $7F0200, #$7C00, #$0800 )
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [StartMusic] ( #14 )
    STZ $cameraTargetX
    STZ $cameraTargetY
    COP [SpawnLastRel] ( @code_09CFD4, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_09CF1B, #00, #00, #$2000 )
    STZ $00E4
    COP [CallScript] ( &code_09CF36 )
    COP [HaltIfCounterGte] ( #$00C8 )
    SEP #$20
    LDA #$10
    STA $TM
    REP #$20
    COP [HaltIfCounterGte] ( #$3264 )
    COP [SpawnLastRel] ( @code_09CC31, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$32E4 )
    COP [SpawnLastRel] ( @code_09CC39, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$32FC )
    COP [SpawnLastRel] ( @code_09CC31, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$3396 )
    COP [SpawnLastRel] ( @code_09CC31, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$344A )
    COP [SpawnLastRel] ( @code_09CC39, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$37B4 )
    COP [SpawnLastRel] ( @code_09CC5F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$39FC )
    COP [SpawnLastRel] ( @code_09CC7E, #00, #00, #$2500 )
    COP [HaltIfCounterGte] ( #$3C8C )
    COP [CallScript] ( &code_09CFA6 )
    COP [HaltIfCounterGte] ( #$4920 )
    COP [CallScript] ( &code_09CF64 )
    COP [HaltIfCounterGte] ( #$500C )
    COP [SpawnLastRel] ( @code_09CC8F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5208 )
    COP [SpawnLastRel] ( @code_09CCA7, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5398 )
    COP [SpawnLastRel] ( @code_09CCC2, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$53A8 )
    COP [SpawnLastRel] ( @code_09CCDD, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5528 )
    COP [SpawnLastRel] ( @code_09CCF8, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5538 )
    COP [SpawnLastRel] ( @code_09CD13, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$56B8 )
    COP [SpawnLastRel] ( @code_09CD2E, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5848 )
    COP [SpawnLastRel] ( @code_09CD49, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5860 )
    COP [SpawnLastRel] ( @code_09CD64, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$59CE )
    COP [CallScript] ( &code_09CF92 )
    COP [HaltIfCounterGte] ( #$59D8 )
    COP [SpawnLastRel] ( @code_09CD7F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$59F0 )
    COP [SpawnLastRel] ( @code_09CD9A, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5B68 )
    COP [SpawnLastRel] ( @code_09CDB5, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5CF8 )
    COP [SpawnLastRel] ( @code_09CDD0, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5D10 )
    COP [SpawnLastRel] ( @code_09CDEB, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5E88 )
    COP [SpawnLastRel] ( @code_09CE06, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5EA0 )
    COP [SpawnLastRel] ( @code_09CE21, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$600E )
    COP [CallScript] ( &code_09CF9C )
    COP [HaltIfCounterGte] ( #$6018 )
    COP [SpawnLastRel] ( @code_09CE3C, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6038 )
    COP [SpawnLastRel] ( @code_09CE57, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6198 )
    COP [SpawnLastRel] ( @code_09CE72, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$61C8 )
    COP [SpawnLastRel] ( @code_09CE8D, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6338 )
    COP [SpawnLastRel] ( @code_09CEA8, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$64C8 )
    COP [SpawnLastRel] ( @code_09CEC3, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$7068 )
    STZ $066D
    STZ $0670
    STZ $0673
    STZ $0676
    STZ $0679
    STZ $067C
    STZ $067F
    STZ $0682
    STZ $0685
    COP [QueueMapChange] ( #F0, #$0090, #$0178, #06, #$1201 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_09C1A1 [
  actor-def < #00, #00, #20, {

  code_09C1A4:
    LDA #$1000
    TSB $12
    LDA #$0000
    SEP #$20
    PHD 
    PHX 
    TCD 
    JSL $@chunk_028000.code_02FCBC
    PLX 
    PLD 
    REP #$20
    LDA #$4001
    TSB $09FA
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$FF
    STA $backdropColors
    REP #$20
    STZ $00E4
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SpawnAfter] ( @code_09C277 )
    COP [SpawnAfterAbsFlags] ( @code_09C2AD, #$0098, #$0078, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09C2C2, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09C2E1, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09C300, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09C31F, #$0000, #$0078, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09C33E, #$0088, #$0040, #$3000 )
    COP [WaitByte] ( #0F )
    INC $00E4
    COP [WaitWord] ( #$00B3 )
    INC $00E4
    COP [WaitWord] ( #$00B3 )
    COP [LoopInit] ( #06 )
    COP [PlaySoundBoth] ( #$0909 )
    COP [SetEntryDelayExit] ( @code_09C23D, #$001E )
} >
]

code_09C23D {
    COP [LoopNext]
    COP [WaitWord] ( #$003B )
    COP [PrintWideString] ( &widestring_09C35A )
    COP [WaitWord] ( #$003B )
    COP [StartMusic] ( #02 )
    COP [WaitWord] ( #$0077 )
    INC $00E4
    COP [WaitByte] ( #13 )
    INC $00E4
    COP [WaitByte] ( #13 )
    INC $00E4
    COP [WaitByte] ( #27 )
    INC $00E4
    COP [WaitByte] ( #27 )
    INC $00E4
    COP [WaitWord] ( #$0077 )
    INC $00E4
    COP [SetEntryContinue]
    RTL 
}

code_09C277 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0001
    BEQ loc_09C285
    RTL 

  loc_09C285:
    COP [PaletteStart] ( #6A )
    COP [PaletteStep]
    COP [SetEntryContinue]
    LDA $00E4
    CMP #$0002
    BEQ loc_09C295
    RTL 

  loc_09C295:
    COP [PaletteStart] ( #1C )
    COP [PaletteStep]
    COP [SetEntryContinue]
    LDA $00E4
    CMP #$0007
    BEQ loc_09C2A5
    RTL 

  loc_09C2A5:
    COP [PaletteStart] ( #70 )
    COP [PaletteStep]
    COP [SetEntryContinue]
    RTL 
}

code_09C2AD {
    LDA #$1000
    TSB $12

  loc_09C2B2:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09C2B2
    COP [SetEntryContinue]
    RTL 
}

code_09C2C2 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0003
    BEQ loc_09C2D0
    RTL 

  loc_09C2D0:
    COP [StageSpriteMoveX] ( #00, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09C2D0
    COP [SetEntryContinue]
    RTL 
}

code_09C2E1 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0004
    BEQ loc_09C2EF
    RTL 

  loc_09C2EF:
    COP [StageSpriteMoveX] ( #01, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09C2EF
    COP [SetEntryContinue]
    RTL 
}

code_09C300 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0005
    BEQ loc_09C30E
    RTL 

  loc_09C30E:
    COP [StageSpriteMoveX] ( #02, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09C30E
    COP [SetEntryContinue]
    RTL 
}

code_09C31F {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0006
    BEQ loc_09C32D
    RTL 

  loc_09C32D:
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09C32D
    COP [SetEntryContinue]
    RTL 
}

code_09C33E {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0008
    BEQ loc_09C34C
    RTL 

  loc_09C34C:
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #09, #11 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

widestring_09C35A `[TPL:E][DLY:5]今日の 授業は ここまでに[N]しましょう.[PAU:B4][N][CLR]近ごろ 交通じこが ふえています.[N][PAU:32]みんな 車に 気をつけて[N]かえるのですよ.[PAU:F0][CLD]`

widestring_09C3AC `[AD][E4]が┌ぎぅぐぁLぎぐぃび[BCD:6902,1CC]ぐぃP[BCD:6902,CA8]ぐぃら[BCD:6902,E10]ぐぃみ[BCD:6902,EB8]ぐぃら[BCD:6902,F78]ぐぃさ[BCD:6902,1168]ぐぃら[BCD:6902,1774]ぐぃさ[BCD:6902,1968]ぐぃP[BCD:6902,1968]ぐぃP[BCD:6902,2138]ぐぃら[BCD:6902,2390]ぐぃ[DF][BCD:6902,23B0]ぐぃ[E9][BCD:6902,23CC]ぐぃ[PAL:C6]ぐぁ[EE]Cぐぃ[FIN][BCD:6902,244E]ぐぃ[BC][BCD:6902,245F]ぐぃ[SEP:C6,6902][88]Dぐぃ[RET]`

widestring_09C441 `[BCD:6902,24C8]ぐぃの[BCD:6902,2540]ぐぃゃ[BCD:6902,2608]ぐぃ[F0][BCD:6902,2618]ぐぃ[FA][BCD:6902,2658]ぐぃぎ[SIZ:2,69,68]Fぐぃら[BCD:6902,26C8]ぐぃ[B5][BCD:6902,2740]ぐぃら[BCD:6902,2770]ぐぃぜ[SIZ:2,69,90]GぐぃQ[SIZ:2,69,AE]GぐぃX[SIZ:2,69,C7]Gぐぃお[SIZ:2,69,DB]Gぐぃし[SIZ:2,69,EA]GぐぃQ[SIZ:2,69,F6]GぐぃX[SIZ:2,69,2]Hぐぃお[SIZ:2,69,B]Hぐぃし[SIZ:2,69,14]Hぐぃ([SIZ:2,69,2C]Hぐぃぱ[SIZ:2,69,7C]Hぐぃ [SIZ:2,69,EC]Hぐぃら[BCD:6902,291C]ぐぃ[A0][BCD:6902,293C]ぐぃ[AE][BCD:6902,29CC]ぐぃ[A7][BCD:6902,29EC]ぐぃ![BCD:6902,2A4C]ぐぃ3[BCD:6902,2AB0]ぐぃら[BCD:6902,2AF8]ぐぃの[BCD:6902,2B10]ぐぃG[SIZ:2,69,88]Kぐぃら[BCD:6902,2C00]ぐぃさ[BCD:6902,2CFA]ぐぃ[84][BCD:6902,2DBA]ぐぃ[8B][BCD:6902,2DDA]ぐぃ[92][BCD:6902,2E52]ぐぃ[99][BCD:6902,2E72]ぐぃW[BCD:6902,2F6C]ぐぃさ[BCD:6902,3066]ぐぃえ[BCD:6902,3138]ぐぃ![BCD:6902,3634]ぐぃさ[BCD:6902,3840]ぐぃW[BCD:6902,3A34]ぐぃつ[BCD:6902,3CB4]ぐぃみ[BCD:6902,3D68]ぐぃつ[BCD:6902,4164]ぐぃん[BCD:6902,417C]ぐぃつ[BCD:6902,42CC]ぐぃG[SIZ:2,69,F8]けぐぃつ[BCD:6902,46C8]ぐぃら[BCD:6902,4830]ぐぃつ[BCD:6902,4A4C]ぐぃら[BCD:6902,4D1C]ぐぃP[BCD:6902,6C0C]ぐぃら[BCD:6902,6D1A]ぐぃさ[BCD:6902,6D38]ぐぃW[BCD:C102,6B]が[A5][A9]がぐ[85]ばぐ[99][AC][PAL:89][9C]ダグ[8F]ガグ[89]グ[DLG:6B,A9]ガ╳バ►[A9]sガ╳[E6][SKP:A5]ブボァグガ[85]ブグ[90]ドググ[89]正グ[8F]ドグ[89]女グ[8F]ガグ[89]女グ[8F]ギグ[89]女グ[8F]ググ[89]女グ[8F]ゲグ[89]女グ[8F]ゼグ[89]女グ[8F]ゾグ[89]女グ[8F]ダグ[89]女グ[8F]ヂグ[89]女グ[8F]ヅグ[89]女グ[8F]デグ[89]女グ[8F]◄グ[89]女グ[8F]▲グ[89]女グ[8F]ボグ[89]女グ[8F]パグ[89]女グ[8F]ペグ[89]女グ[8F]fグ[89]女グ[8F]gグ[89]女グ[8F]lグ[89]女グ[8F]rグ[89]女グ[8F]vグ[89]女グ[8F]xグ[89]女グ[8F]zグ[89]女グ[8F]イグ[89]女グ[8F]コグ[89]女グ[8E]ゴグ手グ[89]女グ冒グ[89]女グ[8E]ゴグ所グ[89]女グ能グ[89]女グ力グ[89]女グ[8E]ゴグ変グ[89]女グ頭グ[89]女グ中グ[89]女グ声グ[89]女グ[8E]ゴグ時グ[89]女グ生グ[89]女グ今グ[89]女グ後グ[89]女グ自グ[89]女[AD][E4]ガ►ギゥグァガ…グィ[93][CLD]グァ╝…グィ[A9][CLD]グァン►グィ►[PAU:2]ァン◄グィ[99][CLD]グァ[8C]◄グィ[SFX:C8]グァ[A4]◄グィ[PRT][CLD]グァ╳ベグィ[8C][CLD]グァンパグィ[EC][CLD]グァ╝"グィ[F3][CLD]グァュ̋”グィ-[CLD]グァホoグィ[DE][CLD]グァ[CLR]oグィ[A9][CLD]グァワpグィ[E4][CLD]グァ[96]pグィ[85][CLD]グァxqグィゾ[PAU:2]ァ[E8]uグィ[B8][CLD]グァ[F8]uグィ[8C][CLD]グァdzグィ[SIZ:C8,2,69]tzグィ[8C][CLD]グァ[B4]イグィ[END]`

widestring_09C7F2 `[CLD]ぐぁんうぐぃ[E4][CLD]ぐぁ気ぐぃ[A9][CLD]ぐぁれきぐぃ[A1][CLD]ぐぁ9きぐぃ[A9][CLD]ぐぁ[CLD]しぐぃ[99][CLD]ぐぁせすぐぃ8[CLD]ぐぁ[AC]せぐぃ[FB][CLD]ぐぁ そぐぃ[8C][CLD]ぐぁつたぐぃ[PRT][CLD]ぐぁぺてぐぃ[EC][CLD]ぐぁづぇぐぃ[PRT][CLD]ぐぁぴぉぐぃ[8C][CLD]ぐぁXぉぐぃ·[CLD]ぐぁれっぐぃ[B0][CLD]ぐぁ1っぐぃ·[CLD]ぐ[DLG:6B,0]がぼぐ[99]て[SIZ:89,2,88]がよ·ぐ[DLG:6B,2]私ぐ[89]女ぐ旅ぐ[89]女ぐ手ぐ[89]女[A9]Qが [E6][SKP:2]品ぎぐ[89]正ぐ品ぐぐ[89]正ぐ助ぐ[89]女ぐ着(ぐ[89]正ぐ列ぎぐ[89]正ぐ間ぐ[89]女ぐ効ぐぐ[89]正ぐ冒ぐ[89]女ぐ数┘ぐ[89]正[A9]Qが [E6][SKP:2]数ぎぐ[89]正ぐ行ぐ[89]女ぐ千┘ぐ[89]正[A9]Uが [E6][SKP:2]千ぐぐ[89]正ぐ先ぐ[89]女ぐ右ぐ[89]ぐ助ぐ[89]女[AD][E4]が┌ぎぅぐぁゅべぐぃS[RET]`

widestring_09C92A `ぐぁ[E8]べぐぃD[RET]`

widestring_09C932 `ぐぁ[EB]べぐぃど[RET]`

widestring_09C93A `ぐぁ[EE]べぐぃび[RET]`

widestring_09C942 `ぐぁ[F2]べぐぃず[RET]`

widestring_09C94A `ぐぁ[F6]べぐぃD[RET]`

widestring_09C952 `ぐぁ[FB]べぐぃど[RET]`

widestring_09C95A `ぐぁがぼぐぃび[RET]`

widestring_09C962 `ぐぁじぼぐぃず[RET]`

widestring_09C96A `ぐぁづぼぐぃD[RET]`

widestring_09C972 `ぐぁ)ぼぐぃど[RET]`

widestring_09C97A `ぐぁぴぼぐぃび[RET]`

widestring_09C982 `ぐぁBぼぐぃず[RET]`

widestring_09C98A `ぐぁJぼぐぃD[RET]`

widestring_09C992 `ぐぁんぱぐぃK[RET]`

widestring_09C99A `ぐぁ[88]ぱぐぃぺ[RET]`

widestring_09C9A2 `ぐぁ[B0]ぱぐぃ[F8][PAU:2]ぁ5,ぐぃ[FF][PAU:2]ぁゅ.ぐぃ[F5][PAU:2]ぁ[A4]うぐぃほ[RET]`

widestring_09C9C2 `ぐぁ[EC]うぐぃき[RET]`

widestring_09C9CA `ぐぁれきぐぃせ[RET]`

widestring_09C9D2 `ぐぁ9きぐぃき[RET]`

widestring_09C9DA `ぐぁ[CLD]しぐぃに[RET]`

widestring_09C9E2 `ぐぁせすぐぃ[F5][PAU:2][DLG:6B,0]がぼぐ[99]ぺ[PAU:89]ぐ[DLG:6B,2]助ぐ[89]女ぐ品┘ぐ[89]正ぐ空ぐ[89]女ぐ間ぐ[89]女ぐ冒ぐ[89]女ぐ事ぎぐ[89]正ぐ険ぐ[89]女ぐ数ぎぐ[89]正[A9]Qが [E6][SKP:2]千ぎぐ[89]正ぐ二ぐ[89]女ぐ友ぐぐ[89]正ぐ友ぎぐ[89]正[A9]くが [E6][SKP:2]保ぐぐ[89]正[AD][E4]が┌ぎぅぐぁXごぐぃ[EA][RET]`

widestring_09CA74 `ぐぁHざぐぃが[ZZZ]ぐぁゅぢぐぃ[F8][RET]`

widestring_09CA84 `ぐぁ5づぐぃ[E7][RET]`

widestring_09CA8C `ぐぁづおぐぃL[ZZZ]ぐぁはおぐぃず[ZZZ]ぐぁれきぐぃど[ZZZ]ぐぁ9きぐぃず[ZZZ]ぐぁTこぐぃ,[ZZZ]ぐぁゅこぐぃず[ZZZ]ぐぁ7こぐぃE[ZZZ]ぐぁ[AC]こぐぃず[ZZZ]ぐぁ[CLD]しぐぃぶ[ZZZ]ぐぁせすぐぃ[E7][RET]`

widestring_09CADC `ぐ[DLG:6B,0]がぼぐ[99]わ[RET]`

widestring_09CAE6 `[89]ぐ[DLG:6B,A9]Eが [E6][SKP:2]明(ぐ[89]正ぐ明┘ぐ[89]正ぐ私ぐ[89]女ぐ中ぐ[89]女ぐ通ぐぐ[89]正ぐ通ぎぐ[89]正ぐ時ぐ[89]女ぐ待ぐ[89]女[A9]Bが [E6][SKP:2]々ぐぐ[89]正[AD][E4]が┌ぎぅぐぁ[B0]ごぐぃ[9E][ZZZ]ぐぁ[A0]ざぐぃ[B4][ZZZ]ぐぁ[CLD]だぐぃ[AC][ZZZ]ぐぁ[CLR]ぢぐぃ[9B][ZZZ]ぐぁ[FC]おぐぃ[BB][ZZZ]ぐぁLかぐぃ[PAU:CB]ぐぁれきぐぃ[CLR][ZZZ]ぐぁ9きぐぃ[PAU:CB]ぐぁ[CLD]しぐぃ[SEP:CB,6902]せすぐぃ[9B][ZZZ]ぐ[DLG:6B,0]がぼぐ[99]Z[ZZZ][89]ぐ[DLG:6B,A9]くが [E6][SKP:2]家(ぐ[89]正ぐ家┘ぐ[89]正ぐ旅ぐ[89]女[A9]Rが [E6][SKP:2]化ぐぐ[89]正ぐ然ぐ[89]女ぐ精ぐぐ[89]正ぐ精ぎぐ[89]正[AD][E4]が┌ぎぅぐぁれざぐぃば`

widestring_09CBEE `ぐぁDじぐぃJ`

widestring_09CBF6 `ぐぁ[9C]ぞぐぃB`

widestring_09CBFE `ぐぁ1だぐぃ┘`

widestring_09CC06 `ぐ[DLG:6B,0]がぼぐ[99][E0][ZZZ][89]ぐ[DLG:6B,A9]Uが [E6][SKP:2]彼(ぐ[89]正ぐ彼┘ぐ[89]正ぐ手ぐ[89]女`

code_09CC31 {
    LDA #$0012
    JSR $&code_09CEE6
    BRA loc_09CC3F
}

code_09CC39 {
    LDA #$0022
    JSR $&code_09CEE6

  loc_09CC3F:
    COP [SetMetasprite] ( $7E6000 )
    COP [StageSpriteLoopMoveX] ( #10, #07, #02 )
    COP [AnimLoop]
    COP [Die]

  code_09CC4D:
    COP [HaltIfCounterGte] ( #$3844 )
    COP [SetLinkedActorScript] ( &code_09CC77 )
    COP [HaltIfCounterGte] ( #$3A4C )
    COP [SetLinkedActorScript] ( &code_09CC5D )
}

code_09CC5D {
    COP [Die]
}

code_09CC5F {
    COP [SpawnBefore] ( @code_09CC4D )
    LDA #$0041
    JSR $&code_09CEE6
    COP [SetMetasprite] ( $7E6000 )

  loc_09CC6F:
    COP [StageSpriteMoveX] ( #0E, #01 )
    COP [AnimOnce]
    BRA loc_09CC6F
}

code_09CC77 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    BRA code_09CC77
}

code_09CC7E {
    COP [PaletteStart] ( #7C )
    COP [PaletteStep]
    COP [Die]

  code_09CC85:
    COP [HaltIfCounterGte] ( #$515C )
    COP [SetLinkedActorScript] ( &code_09CC8D )
}

code_09CC8D {
    COP [Die]
}

code_09CC8F {
    COP [SpawnBefore] ( @code_09CC85 )
    COP [SetMetasprite] ( $7E6000 )
    LDA #$0003
    JSR $&code_09CEE6

  loc_09CC9F:
    COP [StageSpriteMoveX] ( #0A, #02 )
    COP [AnimOnce]
    BRA loc_09CC9F
}

code_09CCA7 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0D, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0D, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CCC2 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #09, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CCDD {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0A, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0A, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CCF8 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0B, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0B, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD13 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0C, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0C, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD2E {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #11, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD49 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #15, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #15, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD64 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #16, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #16, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD7F {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #1B, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1B, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CD9A {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #1C, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1C, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CDB5 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #17, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #17, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CDD0 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0E, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0E, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CDEB {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #0F, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0F, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE06 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #12, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #12, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE21 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #13, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #13, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE3C {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #18, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE57 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #14, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #14, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE72 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0020
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #1A, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1A, #88, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CE8D {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #19, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #80, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CEA8 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #10, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #80, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09CEC3 {
    COP [SetMetasprite] ( $7E6000 )
    LDA #$0032
    JSR $&code_09CEE6
    COP [StageSpriteLoopMoveX] ( #13, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #13, #55 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitWord] ( #$0FEF )
    COP [Die]
}

code_09CEE6 {
    PHX 
    PHA 
    AND #$000F
    ASL 
    TAX 
    LDA $@loc_09CF07+8, X
    STA $14
    PLA 
    AND #$00F0
    LSR 
    LSR 
    LSR 
    TAX 
    LDA $@code_09CF03, X
    STA $16
    PLX 
    RTS 
}

code_09CF03 {
    BRA loc_09CF05

  loc_09CF05:
    BCC loc_09CF07

  loc_09CF07:
    LDY #$B000
    BRK #$C0
    BRK #$D0
    BRK #$E0
    SBC $@map_ir1E+465, X
    ORA ($20, X)
    ORA ($F8, X)
    SBC $020108, X
    CMP ($EE, X)
    CPX $00
    SED 
    LDA $00E6
    CLC 
    ADC #$0001
    STA $00E6
    LDA $00E8
    ADC #$0000
    STA $00E8
    CLD 
    RTL 
}

code_09CF36 {
    COP [AdhocVramDma] ( $7EC000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7EC800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7ED000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7ED800, #$5C00, #$0800 )
    COP [CopyPalette] ( @palette_1F6FF5, #00, #90, #40 )
    COP [RestoreSavedPtr]
}

code_09CF64 {
    COP [AdhocVramDma] ( $7EE000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7EE800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7EF000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7EF800, #$5C00, #$0800 )
    COP [CopyPalette] ( @palette_1F2060, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09CF92 {
    COP [CopyPalette] ( @palette_1F2140, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09CF9C {
    COP [CopyPalette] ( @palette_1F2220, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09CFA6 {
    COP [AdhocVramDma] ( $7EA000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7EA800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7EB000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7EB800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_sc02_main_characters, #00, #A0, #60 )
    COP [RestoreSavedPtr]
}

code_09CFD4 {
    LDA $00E4
    BPL loc_09CFDA
    RTL 

  loc_09CFDA:
    COP [HaltIfCounterGte] ( #$01F4 )
    LDA #$D248
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D270
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D299
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D2C6
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D2EE
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D319
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D343
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D371
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D3AE
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D400
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D429
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D478
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D4C4
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D513
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D54E
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D58D
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D5DD
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D62D
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D67D
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D6B9
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D6DC
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D709
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D72C
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D750
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D783
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #D1 )
    LDA #$D7D0
    STA $26
    COP [CallScript] ( &code_09D13F )
    COP [WaitByte] ( #95 )
    SEP #$20
    LDA #$79
    STA $BG3SC
    REP #$20
    LDY #$D7EB
    JSR $&code_09D1B0
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    SEP #$20
    LDA #$14
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    COP [SetEntryContinue]
    RTL 
}

code_09D13F {
    SEP #$20
    LDA #$79
    STA $BG3SC
    REP #$20
    LDY $26
    JSR $&code_09D1B0
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    SEP #$20
    LDA #$14
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    COP [WaitWord] ( #$02CF )
    SEP #$20
    LDA #$7A
    STA $BG3SC
    REP #$20
    COP [LoopInit] ( #80 )
    LDA $0720
    CLC 
    ADC #$0001
    STA $0720
    COP [LoopNext]
    SEP #$20
    LDA #$10
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    LDA #$0000
    STA $0720
    PHX 
    LDX #$0400

  loc_09D19C:
    STA $7F0200, X
    DEX 
    DEX 
    BPL loc_09D19C
    PLX 
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    COP [RestoreSavedPtr]
}

code_09D1B0 {
    PHX 
    PHB 
    SEP #$20
    LDA #$89
    PHA 
    PLB 
    REP #$20
    STZ $0000
    LDA #$2000
    STA $joypadInject

  loc_09D1C3:
    SEP #$20
    LDA $0000, Y
    INY 
    CMP #$10
    BCC loc_09D1EB
    LDX $0000
    REP #$20
    AND #$00FF
    ORA $joypadInject
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0000

  loc_09D1E9:
    BRA loc_09D1C3

  loc_09D1EB:
    STX $0000
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    JSR ($&code_list_09D1FE, X)
    BRA loc_09D1C3

  code_09D1FA:
    PLA 
    PLB 
    PLX 

  code_09D1FD:
    RTS 
}

code_list_09D1FE [
  &code_09D1FA   ;00
  &code_09D21E   ;01
  &code_09D1FD   ;02
  &code_09D22A   ;03
  &code_09D1FD   ;04
  &code_09D1FD   ;05
  &code_09D1FD   ;06
  &code_09D1FD   ;07
  &code_09D1FD   ;08
  &code_09D1FD   ;09
  &code_09D1FD   ;0A
  &code_09D1FD   ;0B
  &code_09D1FD   ;0C
  &code_09D23A   ;0D
  &code_09D1FD   ;0E
  &code_09D1FD   ;0F
]

code_09D21E {
    LDA $0000, Y
    INY 

  loc_09D222:
    INY 
    STA $0000
    STA $playerFlags
    RTS 
}

code_09D22A {
    LDA $09AD
    AND #$00E3
    ORA $0000, Y
    INY 
    STA $09AD

  loc_09D237:
    REP #$20

  loc_09D239:
    RTS 
}

code_09D23A {
    LDA $playerFlags
    CLC 
    ADC #$0080
    STA $playerFlags
    STA $0000
    RTS 
}

code_09D248 {
    ORA $04, S
    ORA ($CC, X)
    ORA ($A4, X)
    INY 
    CMP $80
    BIT #$CCCC
    SBC $E3
    CMP #$CECF
    BRA code_09D22A

  loc_09D25B:
    DEC $80
    STA [$81]
    BIT #$0D81
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D1E7

  loc_09D267:
    BRA loc_09D1E9

  loc_09D269:
    BRA loc_09D20E

  loc_09D26B:
    LDY $81
    STX $86
    BRK #$03
    TSB $01

  loc_09D273:
    CPY $&scene_warps.warp_def_018EE4+1D
    SEP #$C9
    CMP [$C9]
    DEC $&parallax_table.binary_01CC92+2F
    BRA loc_09D222

  loc_09D27F:
    CPX $CF
    SEP #$E9
    ORA $&table_018000+D
    BRA loc_09D208

  loc_09D288:
    BRA loc_09D20A

  loc_09D28A:
    BRA loc_09D20C

  loc_09D28C:
    STA $&scene_warps.warp_def_01A260+21
    BIT #$8B
    STA $@chunk_088000.widestring_088F4D+M
    STA ($A2, X)
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($83, X)
    INY 
    CMP ($E2, X)
    CMP ($C3, X)
    CPX $CF
    SEP #$80
    STY $C5
    SBC $C9, S
    CMP [$CE]
    CMP $E2
    ORA $&table_018000+D
    BRA loc_09D235

  loc_09D2B5:
    BRA loc_09D237

  loc_09D2B7:
    BRA loc_09D239

  loc_09D2B9:
    BRA loc_09D23B

  loc_09D2BB:
    STA $&scene_warps.warp_def_01A48A+5
    STA $@scene_warps.warp_def_018870+10
    STA [$89]
    STA $040300
    ORA ($CC, X)
    ORA ($87, X)
    CMP ($CD, X)
    CMP $80
    STY $C5
    SBC $C9, S
    CMP [$CE]
    CMP $E2

  loc_09D2D8:
    ORA $&table_018000+D
    LDY $8F
    STA $&table_01A946.binary_01A97A+15

  loc_09D2E0:
    STA $@widestring_09886E+M
    BRA loc_09D273

  loc_09D2E6:
    BIT #$A9
    STA ($AA, X)
    STA ($8B, X)
    BIT #$00
    ORA $04, S
    ORA ($CC, X)
    ORA ($A0, X)
    SEP #$CF
    CMP [$E2]
    CMP ($CD, X)
    BRA loc_09D280

  loc_09D2FC:
    CMP #$E2
    CMP $C3
    CPX $CF
    SEP #$0D
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D296

  loc_09D309:
    STA ($A3, X)
    STA ($A9, X)
    STA ($80, X)
    DEY 
    STA ($A3, X)
    DEY 
    BIT #$8D
    STA $@chunk_008000.loc_008FA0+4
    ORA $04, S
    ORA ($CC, X)
    ORA ($8D, X)
    CMP ($C9, X)
    DEC $&scene_warps.warp_def_01A066+1A
    SEP #$CF
    CMP [$E2]
    CMP ($CD, X)

  loc_09D32A:
    CMP $&01E2C5
    ORA $&table_018000+D
    BRA loc_09D2B2

  loc_09D332:
    STA ($8B, X)
    BIT #$A2
    STA ($80, X)
    PHB 
    BIT #$A4
    STA ($8E, X)
    STA $@228188
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($82, X)
    CMP ($C3, X)
    WAI 
    CMP [$E2]
    CMP $@ec0B_cell.code_04CEC5+20
    BRA loc_09D2D8

  loc_09D354:
    CMP $E3
    CMP #$C7
    DEC $&01E2C5
    ORA $&table_018000+D
    BRA loc_09D2E0

  loc_09D360:
    BRA loc_09D2E2

  loc_09D362:
    DEY 
    BIT #$A3
    STA ($A3, X)
    DEY 
    BIT #$80
    LDA #$8F
    PHB 
    STA $@chunk_008000.code_008181+23
    ORA $04, S
    ORA ($CC, X)
    ORA ($8F, X)
    REP #$CA
    CMP $C3
    CPX $80
    STY $C5

  loc_09D37F:
    SBC $C9, S
    CMP [$CE]
    CMP $E2
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D30A

  loc_09D38A:
    BRA loc_09D316

  loc_09D38C:
    LDA $8E
    BIT #$83
    DEY 
    BIT #$80
    BIT #$A3
    DEY 
    BIT #$84
    STA ($0D, X)
    BRA loc_09D31C

  loc_09D39C:
    BRA loc_09D31E

  loc_09D39E:
    BRA loc_09D320

  loc_09D3A0:
    DEY 
    BIT #$A4

  loc_09D3A3:
    STA $@widestring_09886E+M
    BRA loc_09D32A

  loc_09D3A9:
    LDX #$8789
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($87, X)
    SEP #$C1
    CPX #$C9C8
    CMP $80, S
    STY $C5
    SBC $C9, S
    CMP [$CE]
    CMP $E2
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D348

  loc_09D3C8:
    BRA loc_09D34A

  loc_09D3CA:
    BRA loc_09D35A

  loc_09D3CC:
    STA ($8F, X)
    PHB 
    STA $@25A380
    TAX 

  loc_09D3D4:
    LDA $8B

  loc_09D3D6:
    BIT #$0D
    BRA loc_09D35A

  loc_09D3DA:
    BRA loc_09D35C

  loc_09D3DC:
    BRA loc_09D382

  loc_09D3DE:
    STA ($8B, X)
    STA ($88, X)
    BIT #$A2

  loc_09D3E4:
    STA $@chunk_088000.widestring_088F4D+M
    LDA $A2
    STA ($0D, X)
    BRA loc_09D36E

  loc_09D3EE:
    BRA loc_09D370

  loc_09D3F0:
    BRA loc_09D372

  loc_09D3F2:
    BRA loc_09D37F

  loc_09D3F4:
    STA $@widestring_0988FE+M
    BRA loc_09D3A3

  loc_09D3FA:
    STA $@248F8B
    STA ($00, X)
    ORA $04, S
    ORA ($CA, X)
    ORA ($A3, X)
    CMP $@ec0B_cell.code_04CEC5+20
    BRA loc_09D38F

  loc_09D40C:
    CMP $@actor_def_0FDF02+1CB
    SBC $C5, S
    SEP #$0D
    ORA $&table_018000.display_preset_018078+8
    LDA #$81
    LDA $A5, S
    DEY 
    BIT #$A2

  loc_09D41E:
    STA $@scene_warps.warp_def_018B80
    LDA [$81]
    LDA $81, S

  loc_09D426:
    PHB 
    BIT #$00
    ORA $04, S
    ORA ($CC, X)
    ORA ($A1, X)
    SBC $C9
    DEC $&binary_01C36C.binary_01C57D+67

  loc_09D434:
    CPX $80

  loc_09D436:
    LDA $E4, S

  loc_09D438:
    CMP ($C6, X)
    DEC $0D
    BRA loc_09D3BE

  loc_09D43E:
    BRA loc_09D3E4

  loc_09D440:
    STA ($A4, X)
    LDA $A5, S
    STA $@scene_warps.warp_def_018870+10
    LDA $88, S
    BIT #$8D
    STA $@scene_meta.0D8FA4
    BRA loc_09D3D2

  loc_09D452:
    BRA loc_09D3D4

  loc_09D454:
    BRA loc_09D3D6

  loc_09D456:
    BRA loc_09D3FB

  loc_09D458:
    DEY 
    BIT #$87
    STA $8D
    BIT #$80
    PHB 

  loc_09D460:
    BIT #$A4
    STA ($0D, X)
    BRA loc_09D3E6

  loc_09D466:
    LDX #$8985
    PHB 
    STA $@scene_warps.warp_def_01A470+10
    PHB 

  loc_09D46F:
    STA $82
    STA ($A9, X)
    STA ($A3, X)
    DEY 
    BIT #$00
    ORA $04, S
    ORA ($CC, X)
    ORA ($85, X)
    STX $&scene_warps.warp_def_01A868+21

  loc_09D481:
    BRA loc_09D426

  loc_09D483:
    CPX $C1
    DEC $C6
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D40C

  loc_09D48C:
    BRA loc_09D437

  loc_09D48E:
    LDA $8B
    BIT #$8E
    STA $@chunk_008000.loc_00A578+A
    STA $88, S
    BIT #$84
    STA ($0D, X)
    BRA loc_09D41E

  loc_09D49E:
    BRA loc_09D420

  loc_09D4A0:
    LDY $81
    PHB 
    STA ($8F, X)
    BRA loc_09D432

  loc_09D4A7:
    STA ($A7, X)

  loc_09D4A9:
    STA ($87, X)

  loc_09D4AB:
    LDA $83
    DEY 
    BIT #$0D
    BRA loc_09D432

  loc_09D4B2:
    BRA loc_09D434

  loc_09D4B4:
    BRA loc_09D436

  loc_09D4B6:
    BRA loc_09D438

  loc_09D4B8:
    PHB 
    STA $89
    TXA 

  loc_09D4BC:
    BIT #$80
    DEY 
    STA $@scene_warps.warp_def_01841C+72
    BRK #$03
    TSB $01
    CPY $&table_018000.display_preset_0180FA+7
    SEP #$E4
    BRA loc_09D452

  loc_09D4CE:
    CMP #$E2

  loc_09D4D0:
    CMP $C3
    CPX $C9
    CMP $800DCE
    BRA loc_09D45A

  loc_09D4DA:
    BRA loc_09D45C

  loc_09D4DC:
    BRA loc_09D45E

  loc_09D4DE:
    BRA loc_09D460

  loc_09D4E0:
    LDY $8F
    STA $@chunk_008000.code_00A595+D
    STA $&scene_warps.warp_def_018B80+1

  loc_09D4E9:
    BIT #$0D

  loc_09D4EB:
    BRA loc_09D46D

  loc_09D4ED:
    BRA loc_09D46F

  loc_09D4EF:
    DEY 
    BIT #$84
    STA $8B
    BIT #$80
    LDA #$81
    STA $&scene_warps.warp_def_018D38+49

  loc_09D4FB:
    STA $@scene_meta.0D8FA4

  loc_09D4FF:
    BRA loc_09D481

  loc_09D501:
    BRA loc_09D483

  loc_09D503:
    LDY $81
    PHB 
    STA ($A3, X)
    DEY 
    BIT #$80
    STA $@23A48F
    LDA $8B
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($81, X)
    SEP #$E4
    BRA loc_09D4A1

  loc_09D51D:
    CMP #$E2
    CMP $C3
    CPX $C9

  loc_09D523:
    CMP $800DCE

  loc_09D527:
    BRA loc_09D4A9

  loc_09D529:
    BRA loc_09D4AB

  loc_09D52B:
    BRA loc_09D4D0

  loc_09D52D:
    DEY 
    BIT #$8E
    TXA 
    BIT #$80
    STX $A5
    LDY $81

  loc_09D537:
    STA $0D89
    BRA loc_09D4BC

  loc_09D53C:
    BRA loc_09D4E7

  loc_09D53E:
    STA ($A3, X)
    LDA $8B
    STA $@chunk_058000.loc_05A2EA+96
    PHB 
    BIT #$87
    LDA $83
    DEY 
    BIT #$00
    ORA $04, S
    ORA ($CC, X)
    ORA ($A4, X)
    CMP $C3
    INY 
    DEC $&binary_01C36C+5D
    CMP ($CC, X)
    BRA loc_09D501

  loc_09D55E:
    SBC $E0
    CPX #$E2CF
    CPX $0D
    BRA loc_09D4E7

  loc_09D567:
    BRA loc_09D4E9

  loc_09D569:
    BRA loc_09D4EB

  loc_09D56B:
    BRA loc_09D510

  loc_09D56D:
    STA ($84, X)
    STA ($8F, X)
    BRA loc_09D51C

  loc_09D573:
    STA ($88, X)

  loc_09D575:
    STA ($87, X)
    BIT #$0D
    BRA loc_09D4FB

  loc_09D57B:
    BRA loc_09D4FD

  loc_09D57D:
    BRA loc_09D4FF

  loc_09D57F:
    BRA loc_09D50C

  loc_09D581:
    STA $8E
    TXA 
    BIT #$A2
    STA $@scene_warps.warp_def_018B80
    STX $008F
    ORA $04, S
    ORA ($CC, X)
    ORA ($A3, X)
    CPX #$C3C5
    CMP #$C1
    CPY $&scene_warps.warp_def_01A470+10
    INY 
    CMP ($CE, X)
    WAI 

  loc_09D59F:
    SBC $0D, S
    BRA loc_09D523

  loc_09D5A3:
    BRA loc_09D525

  loc_09D5A5:
    BRA loc_09D527

  loc_09D5A7:
    LDA #$A5
    LDY $81
    PHB 
    STA ($80, X)
    LDA $81, S
    LDA $81, S
    PHB 
    BIT #$0D
    BRA loc_09D537

  loc_09D5B7:
    BRA loc_09D539

  loc_09D5B9:
    BRA loc_09D53B

  loc_09D5BB:
    BRA loc_09D561

  loc_09D5BD:
    STA ($8B, X)
    STA $A3
    DEY 
    BIT #$80
    BIT #$89
    STY $81
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D54D

  loc_09D5CD:
    DEY 
    BIT #$84
    STA $A9
    LDA $8B
    BIT #$80
    STA $@scene_warps.warp_def_018B80+9
    PHB 
    STA $00
    ORA $04, S
    ORA ($CC, X)
    ORA ($A3, X)
    CPX #$C3C5
    CMP #$C1
    CPY $&scene_warps.warp_def_01A470+10
    INY 
    CMP ($CE, X)
    WAI 
    SBC $0D, S
    BRA loc_09D573

  loc_09D5F3:
    BRA loc_09D575

  loc_09D5F5:
    DEY 
    BIT #$A2
    STA $@scene_meta.0DA586
    BIT #$80
    PHB 
    LDA $A2
    STA $@scene_meta+184
    BRA loc_09D587

  loc_09D607:
    BRA loc_09D589

  loc_09D609:
    STA ($8B, X)
    BIT #$A4
    STA ($8B, X)
    STA ($80, X)
    LDA $88, S

  loc_09D613:
    BIT #$87
    STA $8E
    STA $@chunk_008000.native_mode_nmi_00800B+2
    BRA loc_09D59D

  loc_09D61D:
    BRA loc_09D59F

  loc_09D61F:
    TXA 
    LDA $8E
    BRA loc_09D5CD

  loc_09D624:
    LDA $8B
    LDA $A9
    STA $@widestring_09886E+M
    BRK #$03
    TSB $01
    CPY $&scene_warps.warp_def_01A2FC+5
    CPX #$C3C5

  loc_09D636:
    CMP #$C1
    CPY $&scene_warps.warp_def_01A470+10
    INY 
    CMP ($CE, X)
    WAI 
    SBC $0D, S
    BRA loc_09D5C3

  loc_09D643:
    BRA loc_09D5C5

  loc_09D645:
    BRA loc_09D5F0

  loc_09D647:
    LDA $8D
    BIT #$8B
    STA $@23A480
    LDA $8B
    LDA $84
    STA ($0D, X)
    BRA loc_09D5D7

  loc_09D657:
    BRA loc_09D5D9

  loc_09D659:
    DEY 
    BIT #$84
    STA $A9
    LDA $8B
    BIT #$80
    STA $@scene_warps.warp_def_01A778+10
    STY $81
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D5ED

  loc_09D66D:
    STA $&scene_warps.warp_def_018E80+9
    STA $@chunk_008000.code_00A595+D
    PHB 
    STA ($8B, X)
    BIT #$AA

  loc_09D679:
    STA ($A7, X)
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($A3, X)
    CPX #$C3C5
    CMP #$C1
    CPY $&scene_warps.warp_def_01A470+10
    INY 
    CMP ($CE, X)
    WAI 
    SBC $0D, S
    BRA loc_09D613

  loc_09D693:
    BRA loc_09D623

  loc_09D695:
    STA ($8F, X)
    DEY 
    BIT #$A4
    STA $@25A380

  loc_09D69E:
    STA [$89]
    STX $&scene_warps.warp_def_018B80+1
    STA ($0D, X)
    BRA loc_09D627

  loc_09D6A7:
    BRA loc_09D629

  loc_09D6A9:
    BRA loc_09D636

  loc_09D6AB:
    STA $8E
    TXA 
    BIT #$80
    LDY $81
    STX $&scene_warps.warp_def_01A574+15
    STA $88, S
    BIT #$00
    ORA $04, S
    ORA ($CC, X)
    ORA ($84, X)
    CMP #$E2
    CMP $C3
    CPX $CF
    SEP #$0D
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D659

  loc_09D6CC:
    STA ($A3, X)
    STA ($A9, X)
    STA ($80, X)
    DEY 
    STA ($A3, X)
    DEY 
    BIT #$8D

  loc_09D6D8:
    STA $@chunk_008000.loc_008FA0+4
    ORA $04, S
    ORA ($CC, X)
    ORA ($81, X)
    SBC $E3, S
    CMP #$E3

  loc_09D6E6:
    CPX $C1

  loc_09D6E8:
    DEC $&table_018000.display_preset_0180DC+8
    LDY #$CFE2
    CPY $E5
    CMP $C5, S
    SEP #$0D
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D679

  loc_09D6F9:
    PHB 
    STA ($AA, X)
    LDA $8E
    STA $@chunk_008000.code_00899E+4
    LDY $81
    PHB 
    STA ($84, X)
    STA $040300

  loc_09D70B:
    ORA ($CC, X)

  loc_09D70D:
    ORA ($A0, X)
    SEP #$CF
    CPY $E5
    CMP $C5, S
    SEP #$0D
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D69C

  loc_09D71C:
    BRA loc_09D69E

  loc_09D71E:
    LDA #$81
    LDA $A5, S
    LDA #$A5
    PHB 
    BIT #$80
    LDA $8F, S
    STX $0085
    ORA $04, S
    ORA ($CC, X)
    ORA ($A0, X)
    SBC $C2
    CPY $&01E3C9
    INY 
    CMP $E2
    ORA $&table_018000+D
    LDA #$81
    LDA $A5, S
    DEY 
    BIT #$A2
    STA $@258680
    PHB 
    LDA $A3
    DEY 
    BIT #$8D
    STA ($00, X)
    ORA $04, S
    ORA ($CC, X)
    ORA ($80, X)
    BRA loc_09D6D8

  loc_09D758:
    BRA loc_09D6DA

  loc_09D75A:
    STA $CF, S
    CPX #$E2E9
    CMP #$C7
    INY 
    CPX $0D
    BRA loc_09D6E6

  loc_09D766:
    BRA loc_09D6E8

  loc_09D768:
    ADC ($69, X)
    ADC #$63
    BRA loc_09D6F3

  loc_09D76E:
    STX $&scene_warps.warp_def_01A868+21

  loc_09D771:
    ORA $&table_018000.display_preset_018078+8
    BRA loc_09D6F6

  loc_09D776:
    ADC ($69, X)
    ADC #$63
    BRA loc_09D71D

  loc_09D77C:
    LDA $89
    STX $&scene_warps.warp_def_018560+44
    LDY $00
    ORA $04, S
    ORA ($CA, X)
    ORA ($80, X)
    BRA loc_09D70B

  loc_09D78B:
    BRA loc_09D70D

  loc_09D78D:
    STA $CF, S
    CPX #$E2E9
    CMP #$C7
    INY 
    CPX $0D
    ADC ($69, X)
    ADC #$63
    BRA loc_09D72A

  loc_09D79D:
    STA ($A2, X)
    BIT #$8B
    STA $@chunk_088000.widestring_088F4D+M
    STA ($A2, X)
    STA ($0D, X)
    ADC ($69, X)
    ADC #$63
    BRA loc_09D73C

  loc_09D7AF:
    STA $@chunk_008000.loc_008FA0+4
    DEY 
    STA ($87, X)
    BIT #$8F
    ORA $6961
    ADC #$63
    BRA loc_09D768

  loc_09D7BF:
    STA ($A3, X)
    LDA $88
    BIT #$A2
    STA $@scene_warps.warp_def_018B80
    LDA [$81]
    LDA $81, S
    PHB 
    BIT #$00
    ORA $04, S
    ORA ($4A, X)
    COP [StageSpriteFrame] ( #8C )
    CMP #$C3
    CMP $CE
    SBC $C5, S
    CPY $80
    REP #$E9
    BRA loc_09D771

  loc_09D7E3:
    BIT #$A48E
    STA $8E
    STY $8F
    BRK #$03
    TSB $01
    JMP $&code_09A403
}

code_09D7F1 {
    INY 
    CMP ($CE, X)
    WAI 
    BRA loc_09D7E0

  loc_09D7F7:
    CMP $@chunk_068000.widestring_06805C+M
    CMP $@2080E2
    CPY $&01E9C1
    CMP #$C7CE
    BRK #$04
    PHP 
    LDA $7F2104, X
    INC 
    STA $7F2104, X
    LSR 
    BCC loc_09D821
    LDA $0720
    STA $0722
    COP [QueueHdma] ( @dma_channel_09D82E, #12 )
    RTL 

  loc_09D821:
    LDA $0720
    STA $0724
    COP [QueueHdma] ( @dma_channel_09D832, #12 )
    RTL 
}

dma_channel_09D82E [
  dma-channel < #01, #22, #07 >
]

dma_channel_09D832 [
  dma-channel < #01, #24, #07 >
]

thinker_def_09D836 [
  thinker-def < #04, #08, {

  code_09D838:
    COP [QueueDma] ( @dma_channel_09D83F, #11 )
    RTL 
} >
]

dma_channel_09D83F [
  dma-channel < #01, #18, #00 >   ;00
  dma-channel < #01, #E8, #FF >   ;01
  dma-channel < #01, #17, #00 >   ;02
  dma-channel < #01, #E9, #FF >   ;03
  dma-channel < #01, #16, #00 >   ;04
  dma-channel < #01, #EA, #FF >   ;05
  dma-channel < #01, #15, #00 >   ;06
  dma-channel < #01, #EB, #FF >   ;07
  dma-channel < #01, #14, #00 >   ;08
  dma-channel < #01, #EC, #FF >   ;09
  dma-channel < #01, #13, #00 >   ;0A
  dma-channel < #01, #ED, #FF >   ;0B
  dma-channel < #01, #12, #00 >   ;0C
  dma-channel < #01, #EE, #FF >   ;0D
  dma-channel < #01, #11, #00 >   ;0E
  dma-channel < #01, #EF, #FF >   ;0F
  dma-channel < #01, #10, #00 >   ;10
  dma-channel < #01, #F0, #FF >   ;11
  dma-channel < #01, #0F, #00 >   ;12
  dma-channel < #01, #F1, #FF >   ;13
  dma-channel < #01, #0E, #00 >   ;14
  dma-channel < #01, #F2, #FF >   ;15
  dma-channel < #01, #0D, #00 >   ;16
  dma-channel < #01, #F3, #FF >   ;17
  dma-channel < #01, #0C, #00 >   ;18
  dma-channel < #01, #F4, #FF >   ;19
  dma-channel < #01, #0B, #00 >   ;1A
  dma-channel < #01, #F5, #FF >   ;1B
  dma-channel < #01, #0A, #00 >   ;1C
  dma-channel < #01, #F6, #FF >   ;1D
  dma-channel < #01, #09, #00 >   ;1E
  dma-channel < #01, #F7, #FF >   ;1F
  dma-channel < #01, #08, #00 >   ;20
  dma-channel < #01, #F8, #FF >   ;21
  dma-channel < #01, #07, #00 >   ;22
  dma-channel < #01, #F9, #FF >   ;23
  dma-channel < #01, #06, #00 >   ;24
  dma-channel < #01, #FA, #FF >   ;25
  dma-channel < #01, #05, #00 >   ;26
  dma-channel < #01, #FB, #FF >   ;27
  dma-channel < #01, #04, #00 >   ;28
  dma-channel < #01, #FC, #FF >   ;29
  dma-channel < #01, #03, #00 >   ;2A
  dma-channel < #01, #FD, #FF >   ;2B
  dma-channel < #01, #02, #00 >   ;2C
  dma-channel < #01, #FE, #FF >   ;2D
  dma-channel < #01, #01, #00 >   ;2E
  dma-channel < #01, #FF, #FF >   ;2F
]