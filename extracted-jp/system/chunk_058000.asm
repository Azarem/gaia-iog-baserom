?BANK 05

?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_088000'
?INCLUDE 'chunk_0A8000'
?INCLUDE 'ec_actor_04FCFB'
?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!cameraBoundsY                  06DC
!layerPriorityFlag              06EE
!musicRoomGroup                 06F6
!dmaSkipFlag                    0800
!playerWallType                 09B0
!playerSpeedEw                  09B2
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!eventFlags                     0A00
!jewelsCollected                0AB0
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!damageFlashTimer               0B22
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132
!APUIO1                         2141
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!statsPtr                       7F0020
!currentHp                      7F0026
!backdropColors                 7F0C00

---------------------------------------------

actor_def_058000 [
  actor-def < #00, #00, #23, {

  code_058003:
    COP [BranchIfFlagByte] ( #3C, #01, &code_058053 )
    COP [AddPosition] ( #08, #08 )

  code_05800D:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_058033 )
    COP [BranchIfActorNear] ( #02, #01, &code_05804C )
    COP [BranchIfActorNear] ( #03, #01, &code_05804C )
    COP [BranchIfActorNear] ( #04, #01, &code_05804C )
    COP [BranchIfActorNear] ( #05, #01, &code_05804C )
    LDA $0E
    JSL $@chunk_008000.code_00B573
    RTL 
} >
]

code_058033 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_058040 )
    COP [PrintDialogString] ( &dialogstring_058055 )
    COP [SetFlagByte] ( #0F )
}

code_058040 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05804C )
    COP [SetEntryExitNow] ( @code_05800D )
}

code_05804C {
    LDA $0E
    JSL $@chunk_008000.code_00B56C
    RTL 
}

code_058053 {
    COP [Die]
}

dialogstring_058055 `[DEF]この 黄金のユカを ふむと[N]何か 音がするようだ···[FIN]黄金のユカは 4つ····[N]何か 重りにできるものは[N]ないだろうか···[END]`

h_ir1F_actor_09C489 [
  actor-def < #00, #00, #23, {

  code_0580A6:
    COP [BranchIfFlagByte] ( #3C, #01, &code_0580CA )
    COP [SetEntryContinue]
    LDA $eventFlags
    AND #$001E
    CMP #$001E
    BEQ loc_0580BA
    RTL 

  loc_0580BA:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #08 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0108 )
    COP [SetFlagByte] ( #3C )
} >
]

code_0580CA {
    COP [Die]
}

h_ir1E_actor_09C4B2 [
  actor-def < #00, #00, #30, {

  code_0580CF:
    COP [SetEntryExit]
    LDA $playerSpeedEw
    CMP #$0110
    BCS loc_0580DE
    COP [SetFlagByte] ( #00 )
    BRA loc_0580E1

  loc_0580DE:
    COP [ClearFlagByte] ( #00 )

  loc_0580E1:
    COP [BranchIfFlagByte] ( #30, #00, &code_0580CF )
    COP [BranchIfFlagByte] ( #31, #00, &code_0580CF )
    COP [SetFlagByte] ( #00 )
    COP [PlaySoundBoth] ( #$1616 )

  loc_0580F4:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$01E8, #$0120, &code_058107 )
    COP [BranchIfPlayerAt] ( #$01E7, #$0120, &code_058107 )
    RTL 
} >
]

code_058107 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundBoth] ( #$1616 )
    COP [LoopInit] ( #28 )
    COP [SpawnAfterFlags] ( @code_058135, #$1000 )
    COP [SetEntryDelayExit] ( @code_058122, #$0008 )
}

code_058122 {
    COP [LoopNext]
    LDA #$FFF8
    STA $09C0
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #3B )
    BRA loc_0580F4
}

code_058135 {
    LDA #$02A0
    STA $14
    COP [RngByte]
    CLC 
    ADC #$0090
    STA $16
    COP [RngByte]
    AND #$0003
    BEQ loc_058155
    DEC 
    BEQ loc_05815E
    COP [StageSpriteLoopMoveX] ( #1A, #40, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_058155:
    COP [StageSpriteLoopMoveX] ( #1B, #40, #0E )
    COP [AnimLoop]
    COP [Die]

  loc_05815E:
    COP [StageSpriteLoopMoveX] ( #1C, #40, #10 )
    COP [AnimLoop]
    COP [Die]
}

h_ir1E_actor_09C54D [
  actor-def < #19, #02, #30, {

  code_05816A:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #30, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]

h_ir1E_actor_09C563 [
  actor-def < #19, #02, #30, {

  code_058180:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #31, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]

h_ir1D_wind_melody [
  actor-def < #00, #00, #30, {

  code_058196:
    COP [BranchIfFlagByte] ( #32, #01, &code_0581E7 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0050, #$0170, &code_0581A7 )
    RTL 
} >
]

code_0581A7 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PlaySoundCh1] ( #16 )
    COP [PrintDialogString] ( &dialogstring_0581EF )
    COP [StartMusic] ( #1A )
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_0581D5
    RTL 

  loc_0581D5:
    COP [GiveItem] ( #08, &code_0581E9 )
    COP [PrintDialogString] ( &dialogstring_05822A )
    COP [SetFlagByte] ( #32 )

  loc_0581E1:
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_0581E7 {
    COP [Die]
}

code_0581E9 {
    COP [PrintDialogString] ( &dialogstring_058243 )
    BRA loc_0581E1
}

dialogstring_0581EF `[TPL:10]谷風が 何かの メロディーを[N]かなでている.[N]まるで インカの石像が[N]歌っているようだ···[END]`

dialogstring_05822A `[DLG:3,11][SIZ:D,3,0]風のメロディーを 覚えた![END]`

dialogstring_058243 `[DLG:3,11][SIZ:D,3,0]風のメロディーが 聞こえる.[N]だが 持ち物が いっぱいだった.[END]`

h_ir24_glowing_tile [
  actor-def < #00, #00, #23, {

  code_058273:
    COP [BranchIfFlagWord] ( #$0112, #01, &code_0582A9 )

  code_05827A:
    LDA #$0258
    STA $orbitAngle, X
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #14, #17, #17, #1A, &code_058290 )
    COP [SetEntryExitNow] ( @code_05827A )
} >
]

code_058290 {
    LDA $orbitAngle, X
    DEC 
    BEQ loc_05829C
    STA $orbitAngle, X
    RTL 

  loc_05829C:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #12 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0112 )
}

code_0582A9 {
    COP [Die]
}

h_ir28_actor_09C6A9 [
  actor-def < #00, #00, #20, {

  code_0582AE:
    COP [SetEntryContinue]

  code_0582B0:
    COP [BranchIfPlayerInAbsTiles] ( #1A, #0C, #1C, #0E, &code_0582EA )
    COP [BranchIfPlayerInAbsTiles] ( #1A, #16, #1C, #18, &code_058300 )
    COP [BranchIfPlayerInAbsTiles] ( #12, #24, #14, #26, &code_058316 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #24, #0A, #26, &code_05832C )
    COP [BranchIfPlayerInAbsTiles] ( #10, #1C, #12, #1E, &code_058350 )
    COP [BranchIfPlayerInAbsTiles] ( #12, #16, #14, #18, &code_058375 )

  code_0582E0:
    RTL 
} >
]

code_0582E1 {
    COP [PlaySoundBoth] ( #$2C2C )
    COP [SetEntryExitNow] ( @code_0582B0 )
}

code_0582EA {
    COP [BranchIfFlagByte] ( #01, #01, &code_0582E0 )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$01A8, #$0130, #$2300 )
    BRA code_0582E1
}

code_058300 {
    COP [BranchIfFlagByte] ( #02, #01, &code_0582E0 )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$01C8, #$01C0, #$2300 )
    BRA code_0582E1
}

code_058316 {
    COP [BranchIfFlagByte] ( #03, #01, &code_0582E0 )
    COP [SetFlagByte] ( #03 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$00E8, #$0260, #$2300 )
    BRA code_0582E1
}

code_05832C {
    COP [BranchIfFlagByte] ( #04, #01, &code_0582E0 )
    COP [SetFlagByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$0220, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$0200, #$2300 )
    BRA code_0582E1
}

code_058350 {
    COP [BranchIfFlagByte] ( #05, #01, &code_0582E0 )
    COP [SetFlagByte] ( #05 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$01C0, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$01A0, #$2300 )
    JMP $&code_0582E1
}

code_058375 {
    COP [BranchIfFlagByte] ( #06, #01, &code_0582E0 )
    COP [SetFlagByte] ( #06 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0128, #$0160, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0128, #$0140, #$2300 )
    JMP $&code_0582E1
}

h_ir26_bones [
  actor-def < #2E, #01, #10, {

  code_05839D:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0583AB )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0583AB {
    COP [PrintDialogString] ( &dialogstring_0583B0 )
    RTL 
}

dialogstring_0583B0 `[DEF][TPL:0]インカの 黄金船を 求めた[N]探険家だろうか···?[FIN]白骨化した その手には お守りの[N]ようなものが にぎられている.[N][PAU:28]中には 紙きれが入っており[N]こんなことが 書かれていた.[FIN][PAL:0][SFX:0]お父さん 死なないでね.  ナナ[N][N]黄金船を見つけたら,[N]クルックを買おうね.  サーバス[END]`

h_ir28_bones [
  actor-def < #2E, #01, #10, {

  code_058461:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05846F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05846F {
    COP [PrintDialogString] ( &dialogstring_058474 )
    RTL 
}

dialogstring_058474 `[DEF][TPL:0]インカの 黄金船を 求めた[N]探険家だろうか···?[FIN]トラップに かかって[N]命を 落としたんだ····[END]`

h_ir26_journal_bones [
  actor-def < #2E, #01, #10, {

  code_0584BA:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0584C8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0584C8 {
    COP [PrintDialogString] ( &dialogstring_0584CD )
    RTL 
}

dialogstring_0584CD `[DEF][TPL:0]遺体は 何か 手帳のようなものを[N]もっているようだ···[FIN][PAL:0][N]  インカについてわかったこと[FIN]インカ地方には 文字が 存在[N]しなかった.[N]そのため 人々は 音で 言い伝えを[N]後世に 残したようである.[FIN]私は インカの谷風が メロディを[N]かなでていることに 気がつき[N]その解読に 成功した.[FIN]┌黄金の しきつめられた部屋にて[N] われを となえよ···┘[N]谷風がかなでるメロディを そこで[N]吹けということだろうか···[END]`

h_ir1C_lily [
  actor-def < #1D, #00, #10, {

  code_0585D0:
    COP [BranchIfFlagByte] ( #4B, #01, &code_05867F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0586B3 )
    COP [SolidHighAbs] ( #06, #19 )
    COP [SolidHighAbs] ( #07, #19 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0003
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #01, #01, &code_058622 )
    RTL 
} >
]

code_058622 {
    LDA #$0800
    TRB $10
    COP [KillNext]
    COP [ClearLowAbs] ( #06, #19 )
    COP [ClearLowAbs] ( #07, #19 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$0000
    JSL $@chunk_008000.dialogstring_00C829
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_0588A5 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    LDA $16
    AND #$FFF0
    STA $16
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #14 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0589FB )
    COP [SetFlagByte] ( #4B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
}

code_05867F {
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetTilePos] ( #16, #13 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0586AE )
    LDA $characterForm
    BEQ loc_0586AB
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EC6A
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_0586AB:
    COP [SetEntryContinue]
    RTL 
}

code_0586AE {
    COP [PrintDialogString] ( &dialogstring_0589FB )
    RTL 
}

dialogstring_0586B3 `[DLG:3,11][SIZ:D,4,0][TPL:2]リリィ:[N]ここが インカのイセキの入口.[FIN]インカっていっても 広くってね,[N]ここは インカ伝說の ナゾが[N]かくされているって いわれる場所.[FIN]あたしが まだ ちっちゃいころ[N]長老樣から こんな話を[N]聞いたことがあるんだけど···[FIN]かつて インカが しゅうげきを[N]受けたとき 祖国をすてて[N]新天地を 求めようという[N]計画があったらしいの.[FIN]しんりゃく者の目を ぬすんで[N]きょだいな船が 建造され,[N]最も 賁重な 黄金細工とともに[N]インカ人達が 乗りこんだというわ.[FIN]でもね その船が出航したという[N]記録は 残ってないんだって···[FIN]たぶん インカにねむる 黄金船[N]っていうのは その船のことなんで[N]しょうね.[FIN]長老樣は これまで イトリー族[N]以外の人に この言い伝えを[N]話したことが ないはず.[FIN]長老樣は テムに 何をさせようと[N]してるんだろ···[PAL:0][END]`

dialogstring_058886 `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]ちょっと どこへ いくのよぉ[END]`

dialogstring_0588A5 `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ: なんで あなたが[N]こんな場所に いるのっ![N]あぶないじゃない!![FIN][TPL:1]カレン: ローラおばあさまから[N]この場所を 聞きだして[N]何時間も 待ってたのよっ![FIN]もう おいて いかれたのかと[N]思ったわ. せめて 行き先くらい[N]言ってくれたって いいじゃない![FIN]それに テムは イセキで[N]何かを さがしてるんでしょう?[FIN]テムが がんばってるのに[N]あたしだけ 村で のんびり[N]ごはんなんか 食べてられないわ.[FIN]あたし ここで テムが[N]もどってくるのを 待ってる.[FIN][TPL:2]リリィ: やれやれ.[N]これだもの おじょうさまは···[FIN]わかった. あたしも[N]つきあって ここで 待ってる.[N]それでいいんでしょ?[END]`

dialogstring_0589FB `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]テム. 長老樣の言葉を よく[N]思い出してね.[FIN]┌遺跡の地下の ラライのガケにて[N] 神の息のとどかぬところへ[N] インカの神をおさめよ.[FIN] 谷風が その者を黄金船のもとへ[N] 導くであろう.┘っていう言葉,[N]ちゃんと 覚えてる?[PAL:0][END]`

actor_def_058A9D [
  actor-def < #12, #00, #10, {

  code_058AA0:
    COP [BranchIfFlagByte] ( #4B, #01, &code_058B01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #1A, #0F, #1B, #11, &code_058AB1 )
    RTL 
} >
]

code_058AB1 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #01 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_058B13 )
    COP [StartMusic] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteLoopMoveX] ( #18, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
}

code_058B01 {
    COP [SetTilePos] ( #15, #13 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058B0E )
    COP [SetEntryContinue]
    RTL 
}

code_058B0E {
    COP [PrintDialogString] ( &dialogstring_058B50 )
    RTL 
}

dialogstring_058B13 `[DLG:3,6][SIZ:D,3,0][TPL:1]カレン: ひどいじゃない?![N]あたしを おいてけぼりにして[N]どこまで 行こうっていうのよっ![PAL:0][END]`

dialogstring_058B50 `[DLG:3,6][SIZ:D,3,0][TPL:1]カレン: どう?[N]さがしてるものは 見つかった?[N]がんばってね.[PAL:0][END]`

actor_def_058B7F [
  actor-def < #00, #00, #30, {

  code_058B82:
    COP [BranchIfFlagWord] ( #$011F, #01, &code_058BE0 )
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_058B91
    RTL 

  loc_058B91:
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ExitIfFlagWord] ( #$011F, #01 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    LDA $characterForm
    BEQ loc_058BDA
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_058BE2 )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_058BDA
    RTL 

  loc_058BDA:
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_058BE0 {
    COP [Die]
}

dialogstring_058BE2 `[TPL:A]まものの気配が消え[N]テムの変身が 解けてゆく···[END]`

actor_def_058C06 [
  actor-def < #00, #00, #2B, {

  code_058C09:
    LDA $sceneCurrent
    CMP #$002D
    BCC loc_058C20
    CMP #$002F
    BCS loc_058C20
    LDA $cameraDeltaY
    SEC 
    SBC #$0020
    STA $cameraDeltaY

  loc_058C20:
    LDA #$0000
    STA $chatPtr, X

  loc_058C27:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@loc_058C8F, X
    STA $0000
    LDA $@loc_058C8F+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_058C49
    XBA 
    DEC 
    XBA 

  loc_058C49:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_058C20
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_058C83
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    LDA $sceneCurrent
    CMP #$002F
    BEQ loc_058C7C
    RTL 

  loc_058C7C:
    LDA $cameraDeltaY
    STA $cameraTargetY
    RTL 

  loc_058C83:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_058C27

  loc_058C8F:
    ORA ($01, X)
    BRK #$03
    ORA ($01, X)
    BRK #$03
    ORA ($01, X)
    BRK #$02
    ORA ($01, X)
    BRK #$02
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($04, X)
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$01
    ORA ($01, X)
    BRK #$02
    ORA ($01, X)
    BRK #$02
    ORA ($01, X)
    BRK #$03
    ORA ($01, X)
    BRK #$03
    BRK #$3C
    SBC $030001, X
    SBC $030001, X
    SBC $020001, X
    SBC $020001, X
    SBC $010001, X
    SBC $010001, X
    SBC $010001, X
    SBC $010001, X
    SBC $@01FF04, X
    BRK #$01
    SBC $010001, X
    SBC $010001, X
    SBC $010001, X
    SBC $020001, X
    SBC $020001, X
    SBC $030001, X
    SBC $030001, X
    BRK #$3C
    BRK #$00
} >
]

actor_def_058D19 [
  actor-def < #02, #00, #2B, {

  loc_058D1C:
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_058D28, #$0B00 )
    BRA loc_058D1C
} >
]

code_058D28 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePriority] ( #30 )
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $playerWallType
    STA $14
    COP [RngByte]
    AND #$007F
    CLC 
    ADC #$0218
    STA $16
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}

actor_def_058D4E [
  actor-def < #1E, #02, #10, {

  code_058D51:
    COP [AddPosition] ( #F8, #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_058D58 [
  actor-def < #00, #00, #20, {

  code_058D5B:
    COP [BranchIfFlagByte] ( #4C, #01, &code_058DDC )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetFlagWord] ( #$0185 )
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$B1
    STA $CGADSUB
    LDA #$FF
    STA $COLDATA
    REP #$20
    LDY $decelStepCounter
    LDA #$00D0
    STA $0014, Y
    LDA #$0020
    STA $0016, Y
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
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$00D0, #$0240, &code_058DBC )
    RTL 
} >
]

code_058DBC {
    COP [LoopInit] ( #3C )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
    COP [WaitByte] ( #BF )
    COP [SetFlagByte] ( #4C )
    COP [PrintDialogString] ( &dialogstring_058DDE )
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_058DDC {
    COP [Die]
}

dialogstring_058DDE `[DLG:3,12][SIZ:D,2,0][TPL:0]テム:[N]これが インカの 黄金船か?![FIN]おやっ?[N]人の気配がする···[PAL:0][END]`

actor_def_058E17 [
  actor-def < #02, #00, #10, {

  code_058E1A:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058E23 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058E23 {
    COP [PrintDialogString] ( &dialogstring_058E28 )
    RTL 
}

dialogstring_058E28 `[DEF]王樣っ! よく ご無事でっ![N]これで やっと 大海原へ[N]出航できますよ.[END]`

actor_def_058E57 [
  actor-def < #04, #00, #10, {

  code_058E5A:
    COP [SetOnInteract] ( &code_058E9A )

  loc_058E5E:
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #05, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #04, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    BRA loc_058E5E
} >
]

code_058E9A {
    COP [PrintDialogString] ( &dialogstring_058E9F )
    RTL 
}

dialogstring_058E9F `[DEF]これが 喜ばずに いられますかっ![N]長い間 王樣を 待ったかいが[N]ありましたよっ![END]`

actor_def_058ED0 [
  actor-def < #0D, #00, #10, {

  code_058ED3:
    COP [SetOnInteract] ( &code_058F13 )

  loc_058ED7:
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0C, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0D, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    BRA loc_058ED7
} >
]

code_058F13 {
    COP [PrintDialogString] ( &dialogstring_058F18 )
    RTL 
}

dialogstring_058F18 `[DEF]おきさき樣は 船室でございます.[N]はやく その元気な お姿を[N]見せてあげて下さいまし.[END]`

actor_def_058F4D [
  actor-def < #02, #00, #10, {

  code_058F50:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058F59 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058F59 {
    COP [PrintDialogString] ( &dialogstring_058F5E )
    RTL 
}

dialogstring_058F5E `[DEF]これは 王樣![N]よく ご無事でっ![FIN][::][TPL:0]テム:[N](ボクが 王樣だって???)[PAL:0][END]`

actor_def_058F92 [
  actor-def < #12, #00, #10, {

  code_058F95:
    COP [BranchIfFlagByte] ( #4E, #00, &code_058FA5 )
    COP [BranchIfFlagByte] ( #F8, #00, &code_058FA5 )
    COP [AddPosition] ( #20, #00 )
} >
]

code_058FA5 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058FAE )
    COP [SetEntryContinue]
    RTL 
}

code_058FAE {
    COP [PrintDialogString] ( &dialogstring_058FB3 )
    RTL 
}

dialogstring_058FB3 `[DEF]わーい わーい[N]王樣が もどってきたあっ![FIN][JMP:&chunk_058000.dialogstring_058F5E+M]`

actor_def_058FD3 [
  actor-def < #02, #00, #30, {

  code_058FD6:
    COP [AddPosition] ( #00, #FC )
    COP [SetOnInteract] ( &code_059058 )
    COP [BranchIfFlagByte] ( #4F, #01, &code_059047 )
    COP [ExitIfFlagByte] ( #4C, #01 )
    COP [SpawnAfterFlags] ( @code_05910E, #$2000 )
    LDA #$2000
    TRB $10
    COP [ExitIfFlagByte] ( #4F, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #03 )
    COP [WaitByte] ( #01 )
    JSL $@chunk_028000.code_028168
    LDA #$0000
    STA $7F0C01
    SEP #$20
    STA $backdropColors
    LDA #$FF
    STA $COLDATA
    LDA #$17
    STA $TM
    LDA #$A2
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
    COP [WaitByte] ( #BF )
    SEP #$20
    LDA #$22
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_059095 )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_059047 {
    LDA #$2000
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryContinue]
    RTL 
}

code_059058 {
    COP [BranchIfFlagByte] ( #4F, #01, &code_059066 )
    COP [PrintDialogString] ( &dialogstring_05906B )
    COP [SetFlagByte] ( #4F )
    RTL 
}

code_059066 {
    COP [PrintDialogString] ( &dialogstring_059095 )
    RTL 
}

dialogstring_05906B `[DEF]見張り:[N]王樣 外を ごらんください.[N]船が どうくつを ぬけます![END]`

dialogstring_059095 `[DEF]見張り:[N]ずっと 暗ヤミで 生活をしてきた[N]我々にとって この海のかがやきは[N]神の光に 見えますよ.[FIN]世界は こんなにも 美しいのに[N]なぜ しんりゃく者が 生まれ[N]自然を こわしてゆくのでしょうね.[END]`

code_05910E {
    COP [SetEntryContinue]
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$A1
    STA $CGADSUB
    LDA #$E0
    STA $COLDATA
    REP #$20
    COP [BranchIfFlagByte] ( #4F, #01, &code_05912A )
    RTL 
}

code_05912A {
    COP [Die]

  code_05912C:
    LDA $cameraTargetY
    STA $16
    LDA #$0000
    STA $chatPtr, X

  loc_059138:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@loc_05919A, X
    STA $0000
    LDA $@loc_05919A+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_05915A
    XBA 
    DEC 
    XBA 

  loc_05915A:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_059191
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_059185
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTL 

  loc_059185:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_059138

  loc_059191:
    LDA #$0020
    STA $chatPtr, X
    BRA loc_059138

  loc_05919A:
    TSB $04
    JSR ($0406, X)
    ASL $FC
    ASL $04
    ASL $FC
    ASL $04
    ASL $FC
    ASL $08
    ORA $F8
    ASL $08
    ASL $F8
    ASL $08
    ASL $F8
    ASL $10
    ASL $F0
    PHP 
    BPL loc_0591C4
    BEQ loc_0591C6
    BRK #$00
}

actor_def_0591C0 [
  actor-def < #0A, #00, #10, {

  code_0591C3:
    COP [SetOnInteract] ( &code_059242 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #4E, #01 )
    COP [ExitIfFlagByte] ( #4F, #01 )
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #F8, #01, &code_0591E3 )
    RTL 
} >
]

code_0591E3 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #04, #0C, #06, &code_0591EE )
    RTL 
}

code_0591EE {
    COP [LoopInit] ( #1E )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [PrintDialogString] ( &dialogstring_059260 )
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5A6
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $0016, Y
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #4D )
    LDA #$0000
    STA $musicRoomGroup
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #2A, #$00A0, #$0070, #03, #$1100 )
    RTL 
}

code_059242 {
    COP [BranchIfFlagByte] ( #4E, #00, &code_05925B )
    COP [BranchIfFlagByte] ( #4F, #00, &code_05925B )
    COP [BranchIfFlagByte] ( #F8, #01, &code_059256 )
    BRA code_05925B
}

code_059256 {
    COP [PrintDialogString] ( &dialogstring_0592F4 )
    RTL 
}

code_05925B {
    COP [PrintDialogString] ( &dialogstring_05929B )
    RTL 
}

dialogstring_059260 `[DEF][TPL:0]テム:[N]ボクは もうれつな すいまに[N]おそわれ 深い深い 夢の中へと[N]いざなわれていった.[PAL:0][END]`

dialogstring_05929B `[DEF]これは 王樣.[N]船内を 見物なさっているのですね.[FIN]しかし 王樣も おつかれのはず.[N]船をひととおり まわったら[N]このベッドで 少しお休みください.[END]`

dialogstring_0592F4 `[DEF]こんな みすぼらしいベッドで[N]申しわけないんですが[N]どうぞ ゆっくり 休んでください.[END]`

actor_def_059325 [
  actor-def < #03, #00, #10, {

  code_059328:
    COP [AddPosition] ( #00, #F8 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_059338 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_059338 {
    COP [PrintDialogString] ( &dialogstring_05933D )
    RTL 
}

dialogstring_05933D `[TPL:E]暗ヤミにつつまれた どうくつの先に[N]まばゆい光が 見える···[FIN]あの光にみちた 海原へ出航したとき[N]我々は 永遠の自由を 手に入れる[N]のだ.[END]`

actor_def_059399 [
  actor-def < #0C, #00, #10, {

  code_05939C:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0593A5 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0593A5 {
    COP [PrintDialogString] ( &dialogstring_0593AA )
    RTL 
}

dialogstring_0593AA `[TPL:A]おきさき樣は 以前 王樣が[N]おくられたゆびわを 今でも 大切に[N]身につけて いらっしゃいます.[FIN]そうです. しんりゃく者に追われ[N]王樣とおきさき樣が はなればなれに[N]なるときに おくられたゆびわです.[FIN]おきさき樣は 王樣のことを[N]それだけ したっていらっしゃるので[N]しょうね.[END]`

actor_def_059448 [
  actor-def < #04, #00, #10, {

  code_05944B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05949B )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #38, &code_059459 )
    RTL 
} >
]

code_059459 {
    LDA #$EFF0
    TSB $joypadMaskStd
    LDA #$1000
    TRB $10
    COP [WaitByte] ( #01 )
    COP [RemoveItem] ( #38 )
    LDA #$0000
    STA $0AAC
    LDA #$002E
    STA $0B12
    LDA #$0025
    STA $0B08
    STA $0B0A
    LDA #$001A
    STA $0B0C
    STA $0B0E
    LDA #$2310
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_05949B {
    COP [PrintDialogString] ( &dialogstring_0594A0 )
    RTL 
}

dialogstring_0594A0 `[TPL:A]これは 王樣.[N]ミステリードールは このハコの中で[N]ございます.[FIN]それに そろそろ 出航の準備が[N]ととのったようですよ.[FIN]どうですか?[N]見張り台に のぼってみては?[N]出航の樣子が 見られますよ.[END]`

actor_def_059517 [
  actor-def < #15, #00, #10, {

  code_05951A:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_059523 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_059523 {
    COP [PrintDialogString] ( &dialogstring_059528 )
    RTL 
}

dialogstring_059528 `[TPL:A]なんで ぼくたちは にげなくちゃ[N]いけないの?[N]インカは ぼくたちの お家なのに.[END]`

actor_def_059557 [
  actor-def < #1A, #00, #10, {

  code_05955A:
    COP [BranchIfFlagByte] ( #4F, #01, &code_059567 )
    COP [SpawnAfterFlags] ( @code_059638, #$2000 )
} >
]

code_059567 {
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_059575 )
    COP [SetEntryContinue]
    RTL 
}

code_059572 {
    COP [SetEntryContinue]
    RTL 
}

code_059575 {
    COP [BranchIfFlagByte] ( #4E, #01, &code_059583 )
    COP [PrintDialogString] ( &dialogstring_059588 )
    COP [SetFlagByte] ( #4E )
    RTL 
}

code_059583 {
    COP [PrintDialogString] ( &dialogstring_059600 )
    RTL 
}

dialogstring_059588 `[TPL:A][TPL:3]インカ女王:[N]よくぞ ご無事で もどって[N]くださいました.[FIN]あなたに 言われたとおり[N]風のミステリードールを[N]今日まで 守り続けてきましたわ.[FIN]あれは あなたが 神から[N]さずかった石像ですものね.[FIN]`

dialogstring_059600 `[TPL:A][TPL:3]下の倉庫の たからばこに[N]しまってありますから ご自分の[N]目で たしかめてくださいな.[PAL:0][END]`

code_059638 {
    COP [SetEntryContinue]
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    COP [BranchIfFlagByte] ( #4F, #01, &code_05964A )
    RTL 
}

code_05964A {
    COP [Die]
}

actor_def_05964C [
  actor-def < #00, #00, #10, {

  code_05964F:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_059669 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_059669 {
    COP [BranchIfFlagByte] ( #01, #01, &code_059678 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #01 )
}

code_059678 {
    COP [PrintDialogString] ( &dialogstring_059680 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_059680 `[TPL:A][TPL:0]きさきの ミイラが[N]静かに ねむっている.[FIN]その 細くて 長い指には[N]黄金のゆびわが はめられている[N]ようだ···[PAL:0][END]`

actor_def_0596C8 [
  actor-def < #02, #00, #10, {

  code_0596CB:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0596E7 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #04 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0596E7 {
    COP [PrintDialogString] ( &dialogstring_0596EC )
    RTL 
}

dialogstring_0596EC `[TPL:A][TPL:0]テム:[N]ここは さっき インカ人が[N]立っていた場所だ···[PAL:0][END]`

actor_def_059718 [
  actor-def < #1B, #00, #10, {

  code_05971B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05972C )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetOnInteract] ( &code_059731 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05972C {
    COP [PrintDialogString] ( &dialogstring_059736 )
    RTL 
}

code_059731 {
    COP [PrintDialogString] ( &dialogstring_0597A3 )
    RTL 
}

dialogstring_059736 `[TPL:A][TPL:1]カレン: もどるはずのない[N]インカ王の帰りを まちつづけて[N]彼らは 死んでいったのよね···[FIN]平和にくらしてた人たちの 生活を[N]こなごなにするなんて ゆるせないよ[N]やっぱり···[PAL:0][END]`

dialogstring_0597A3 `[TPL:B][TPL:1]カレン:[N]な なに···?[PAL:0][END]`

actor_def_0597B9 [
  actor-def < #23, #00, #18, {

  code_0597BC:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0598C8 )
    COP [BranchIfFlagByte] ( #50, #01, &code_059816 )
    COP [SetFlagByte] ( #50 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5A6
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0598D2 )
    COP [WaitByte] ( #3B )
    LDY $decelStepCounter
    LDA #$0082
    STA $0002, Y
    LDA #$D01B
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_059816 {
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #1D, #0D )
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #26, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [PrintDialogString] ( &dialogstring_059954 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #02 )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #17 )
    COP [LoopNext]
    COP [PrintDialogString] ( &dialogstring_059A5A )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [WaitByte] ( #77 )
    LDA #$0001
    STA $musicRoomGroup
    COP [SetOnInteract] ( &code_0598CD )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [RngByte]
    AND #$00E0
    BNE loc_0598B4
    RTL 

  loc_0598B4:
    STA $08
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    RTL 
}

code_0598C8 {
    COP [PrintDialogString] ( &dialogstring_0598F1 )
    RTL 
}

code_0598CD {
    COP [PrintDialogString] ( &dialogstring_059A6D )
    RTL 
}

dialogstring_0598D2 `[TPL:A][TPL:2]リリィ:[N]テム![FIN]テム! 起きて![PAL:0][END]`

dialogstring_0598F1 `[TPL:A][TPL:2]リリィ: テムの帰りが[N]あんまりおそいから 長老樣に[N]うらなってもらったの.[FIN]そしたら 海の上を ー人で[N]さまよっているって言うんだもの.[N]びっくりしたわよ.[PAL:0][END]`

dialogstring_059954 `[TPL:B][TPL:2]リリィ: この船に 積みこまれた[N]賁重な 黄金細工っていうのは[N]きっと その ゆびわのことだよね.[FIN]他の どの黄金細工より[N]かがやいていたんじゃ ないかなあ.[FIN][TPL:1]カレン: 黄金を 見つけて[N]お金もちに なろうとした 人たちは[N]こんな ゆびわのために 命を[N]落としたわけね.[FIN]あたし この ゆびわ もらっとこ.[N]かわいくて なんだか すっごく[N]気にいっちゃった.[FIN][TPL:2]リリィ: あなたには[N]えんりょってものが ないの?![N]のろわれても 知らないからねっ![PAL:0][END]`

dialogstring_059A5A `[TPL:9][TPL:1]カレン:[N]な なに?[PAL:0][END]`

dialogstring_059A6D `[TPL:A][TPL:2]リリィ:[N]リバイヤサンかも しれないっ![FIN]このあたりの海には 化け物みたいに[N]おっきくて どうもうな魚がいるんだ[N]よっ!![PAL:0][END]`

actor_def_059AB9 [
  actor-def < #03, #00, #10, {

  code_059ABC:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_059B21 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0F, #0D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_059AD9 )
    RTL 
} >
]

code_059AD9 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_059C1B )
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_059C31 )
    COP [SetFlagByte] ( #51 )
    COP [SetOnInteract] ( #$0000 )
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #02 )
    COP [AnimOnce]
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [Die]
}

code_059B21 {
    COP [PrintDialogString] ( &dialogstring_059B26 )
    RTL 
}

dialogstring_059B26 `[TPL:A][TPL:4]ロブ: お前の樣子が 変だから[N]3人で こっそり 後をつけたんだ.[FIN]そしたら 変な村に[N]たどりついてさ···[FIN][TPL:2]リリィ: ちょっとお.[N]あたしの 生まれた場所なんだから[N]変な村なんて 言わないでよっ.[FIN][TPL:4]ロブ:[N]じゅうぶん 変な村じゃねえかっ.[N]目に見えない村なんてよっ.[FIN]テム.[N]おれたちに かくれて 旅に出よう[N]ったって そうは いかないぜ.[FIN]友達だったら 楽しみと 苦労は[N]わかちあわなくっちゃな.[PAL:0][END]`

dialogstring_059C1B `[TPL:A][TPL:4]ロブ:[N]だいじょうぶかっ?[PAL:0][END]`

dialogstring_059C31 `[TPL:8][TPL:5]うわあああああああああああああっ[FIN][TPL:9][TPL:4]ロブ: モリスの悲鳴だっ![N]かんぱんの方から 聞こえたぞっ![PAL:0][END]`

actor_def_059C73 [
  actor-def < #0B, #00, #10, {

  code_059C76:
    COP [BranchIfFlagByte] ( #51, #01, &code_059C85 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_059D15 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_059C85 {
    COP [SpawnAfterAbsFlags] ( @code_059D51, #$01D8, #$0260, #$1000 )
    COP [SetTilePos] ( #19, #26 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_059E9E )
    COP [SetFlagByte] ( #02 )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @code_05912C, #$2B00 )
    COP [SpawnAfterFlags] ( @code_059CD2, #$2000 )
    COP [WaitByte] ( #4F )
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #06 )

  loc_059CC4:
    COP [TickGravity]
    CMP #$0000
    BMI loc_059CCF
    COP [SetEntryExit]
    BRA loc_059CC4

  loc_059CCF:
    COP [SetEntryContinue]
    RTL 
}

code_059CD2 {
    COP [WaitByte] ( #77 )
    LDA #$0008
    TSB $12
    LDA #$0200
    TSB $layerPriorityFlag
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #03 )

  loc_059CFB:
    COP [TickGravity]
    CMP #$0000
    BMI loc_059D13
    LDY $decelStepCounter
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetEntryExit]
    BRA loc_059CFB

  loc_059D13:
    COP [Die]
}

code_059D15 {
    COP [PrintDialogString] ( &dialogstring_059D1A )
    RTL 
}

dialogstring_059D1A `[DEF][TPL:3]エリック:[N]わあっ! びっくりしたっ!![FIN]なんだ テムかあ.[N]もう おどかさないでよっ!![PAL:0][END]`

code_059D51 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_059DD7 )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #EF )
    COP [SetFlagByte] ( #01 )
    LDA #$0800
    TSB $10

  code_059D82:
    COP [RngByte]
    AND #$0060
    BEQ loc_059D9A
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D108, #$2000 )
    LDA #$FFFF
    STA $0024, Y

  loc_059D9A:
    COP [BranchIfFlagByte] ( #02, #01, &code_059DA5 )
    COP [SetEntryExitNow] ( @code_059D82 )
}

code_059DA5 {
    COP [WaitByte] ( #63 )
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #07 )

  loc_059DB0:
    COP [TickGravity]
    CMP #$0000
    BMI loc_059DBB
    COP [SetEntryExit]
    BRA loc_059DB0

  loc_059DBB:
    COP [ClearFlagByte] ( #4D )
    LDA #$0000
    STA $0AA6
    LDA #$0808
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00B0, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_059DD7 `[TPL:E][TPL:4]ロブ:[N]モリスは どうしたっ?![N]何が あったんだっ!![FIN][TPL:3]エリック:[N]うえぇぇぇぇぇぇぇぇん[N]モリスが モリスが···[FIN]でっかい魚が 船にぶつかってきて[N]ヒック···[FIN]モリスが 海の中に おっこって[N]ヒック···[FIN]うわあぁぁぁぁぁん[N]モリスが 食べられちゃったよう[N]ヒック ヒック···[FIN][TPL:4]ロブ:[N]な 何だってっ?![PAL:0][END]`

dialogstring_059E9E `[TPL:E][TPL:3]エリック: うわああああああん[N]また あの魚だぁっ![N]ボクら 食べられちゃうんだぁっ![FIN][TPL:4]ロブ: 泣いてる ヒマがあったら[N]何かに つかまれっ![N]ふりおとされるなよっ![PAL:0][END]`

actor_def_059F06 [
  actor-def < #0B, #00, #10, {

  code_059F09:
    COP [SetOnInteract] ( &code_059F12 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_059F12 {
    COP [PrintDialogString] ( &dialogstring_059F43 )
    COP [DialogueOptions] ( #02, #01, &code_list_059F1C )
}

code_list_059F1C [
  &code_059F22   ;00
  &code_059F22   ;01
  &code_059F28   ;02
]

code_059F22 {
    COP [PrintDialogString] ( &dialogstring_05A01E )
    BRA loc_059F2C
}

code_059F28 {
    COP [PrintDialogString] ( &dialogstring_05A046 )

  loc_059F2C:
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #2D, #$00B0, #$0050, #03, #$1300 )
    RTL 
}

dialogstring_059F43 `[TPL:A][TPL:0]テム:[N]か かあさんっ!?[FIN][TPL:2][DLY:2]テムの母 シーラ:[N]テム. 空を 見てごらん···[N]ほら すい星が あんなにきれい.[FIN]すい星はね 長い長い 年月をかけて[N]地球に やってきて そして また[N]遠ざかっていくの.[FIN]あの星を 不幸を呼ぶ星っていう人も[N]いれば しあわせの星と 呼ぶ人も[N]いるわ···[FIN]テム. あなたは どっちだと思う?[N] ふこうの星[N] しあわせの星`

dialogstring_05A01E `[CLR]そう···[N]じゃあ ふこうが 訪れないように[N]いのらなくちゃね···[FIN][JMP:&chunk_058000.dialogstring_05A046+M]`

dialogstring_05A046 `[CLR]そう···[N]じゃあ しあわせが にげないように[N]いのらなくちゃね···[FIN][::]テムや. 私は いつでも[N]あなたのことを 見守っていますよ.[PAL:0][END]`

actor_def_05A091 [
  actor-def < #14, #00, #10, {

  code_05A094:
    COP [BranchIfFlagByte] ( #51, #01, &code_05A0A3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05A0A5 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05A0A3 {
    COP [Die]
}

code_05A0A5 {
    COP [BranchIfFlagByte] ( #E0, #01, &code_05A0BC )
    COP [PrintDialogString] ( &dialogstring_05A0C1 )
    COP [GiveItem] ( #01, &code_05A0B8 )
    COP [SetFlagByte] ( #E0 )
    RTL 
}

code_05A0B8 {
    JML $@chunk_008000.code_00C7E3
}

code_05A0BC {
    COP [PrintDialogString] ( &dialogstring_05A116 )
    RTL 
}

dialogstring_05A0C1 `[TPL:F][TPL:5]モリス: さっき[N]船の中で きみょうな 宝石を[N]見つけたんです.[N]これ テムに あげますね.[FIN][PAL:0]テムは 赤い宝石を もらった![PAL:0][END]`

dialogstring_05A116 `[TPL:F][TPL:5]そう言えば テムに 物をあげたのは[N]初めてかも 知れませんよね.[N]大事にしてくださいね.[PAL:0][END]`

actor_def_05A151 [
  actor-def < #00, #00, #28, {

  code_05A154:
    COP [SetAnimScratch] ( @misc_fx_1CD180 )
    COP [SetMetasprite] ( @sprite_set_list_14C0C8 )
    COP [ResetSpriteInit] ( #00, #$2010 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]

actor_def_05A166 [
  actor-def < #15, #00, #10, {

  code_05A169:
    COP [SwitchCase] ( #$0AA6, &code_list_05A16F )
} >
]

code_list_05A16F [
  &code_05A17D   ;00
  &code_05A1CC   ;01
  &code_05A398   ;02
  &code_05A4E0   ;03
  &code_05A561   ;04
  &code_05A5D7   ;05
  &code_05A69A   ;06
]

code_05A17D {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05A1A0 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #3B )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_05A1A0 {
    COP [BranchIfFlagByte] ( #01, #01, &code_05A1C4 )
    COP [PrintDialogString] ( &dialogstring_05A77A )
    COP [DialogueOptions] ( #02, #01, &code_list_05A1B0 )
}

code_list_05A1B0 [
  &code_05A1BC   ;00
  &code_05A1B6   ;01
  &code_05A1BC   ;02
]

code_05A1B6 {
    COP [PrintDialogString] ( &dialogstring_05A7CE )
    BRA loc_05A1C0
}

code_05A1BC {
    COP [PrintDialogString] ( &dialogstring_05A802 )

  loc_05A1C0:
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_05A1C4 {
    COP [PrintDialogString] ( &dialogstring_05A88B )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_05A1CC {
    LDA #$0008
    STA $playerHp
    LDA #$0200
    TSB $12
    COP [SetTilePos] ( #09, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_05A242, #$2800 )
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A705 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05A393 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$0000
    STA $orbitAngle, X

  code_05A1FF:
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05A923 )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_05A1FF )
    LDA $orbitAngle, X
    CMP #$0708
    BEQ loc_05A227
    INC 
    STA $orbitAngle, X
    RTL 

  loc_05A227:
    COP [PrintDialogString] ( &dialogstring_05A94D )
    COP [SetFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_05A242 {
    COP [RngByte]
    AND #$0007
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_05A25C, #$0900 )
    COP [SetEntryExitNow] ( @code_05A242 )
}

code_05A25C {
    LDA #$1039
    TSB $12
    COP [SetSpritePriority] ( #20 )
    LDA #$ABDC
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0100
    STA $14
    COP [RngByte]
    AND #$000F
    CLC 
    ADC #$0080
    STA $16
    COP [LoopInit] ( #06 )
    COP [SpawnAfterFlags] ( @code_05A38C, #$1800 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [StageSpriteLoopMoveXY] ( #42, #08, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #42, #06, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #08, #04, #03 )
    COP [AnimLoop]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_05A2EA

  code_05A2C5:
    COP [SpawnAfterFlags] ( @code_05A38C, #$1800 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$2000
    TSB $10
    COP [AddPosition] ( #E0, #00 )
    COP [WaitByte] ( #27 )
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]

  loc_05A2EA:
    LDA #$00FF
    STA $currentHp, X
    COP [SetFlagByte] ( #01 )
    LDA $0AA6
    CMP #$0001
    BEQ code_05A2C5
    COP [SetSpritePriority] ( #30 )
    COP [CollPrioritySetMax]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #11, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #42, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #11, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #05, #11, #07 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]
    COP [BranchIfSolid] ( &code_05A2C5 )
    LDA #$1000
    TSB $10
    COP [SetOnInteract] ( &code_05A381 )
    COP [LoopInit] ( #08 )
    COP [StageSpriteLoopMoveY] ( #42, #03, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #43, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #42, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #43, #03, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #44, #08 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_05A381 {
    COP [PlaySoundCh1] ( #22 )
    LDA #$0001
    STA $damageFlashTimer
    COP [Die]
}

code_05A38C {
    COP [StageSpriteFrame] ( #47 )
    COP [AnimOnce]
    COP [Die]
}

code_05A393 {
    COP [PrintDialogString] ( &dialogstring_05A8FA )
    RTL 
}

code_05A398 {
    LDA #$0004
    STA $playerHp
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A718 )
    COP [SetOnInteract] ( &code_05A3F1 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #18, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #18, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [SpawnAfterAbsFlags] ( @code_05A433, #$FFF8, #$00B0, #$1800 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoopMoveX] ( #19, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05A3F1 {
    COP [BranchIfFlagByte] ( #03, #01, &code_05A418 )
    COP [BranchIfFlagByte] ( #02, #01, &code_05A410 )
    COP [BranchIfFlagByte] ( #01, #01, &code_05A40B )
    COP [PrintDialogString] ( &dialogstring_05AA11 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_05A40B {
    COP [PrintDialogString] ( &dialogstring_05AA46 )
    RTL 
}

code_05A410 {
    COP [PrintDialogString] ( &dialogstring_05AA64 )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_05A418 {
    COP [PrintDialogString] ( &dialogstring_05ABE7 )
    COP [ClearFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_05A433 {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05A44B )
    COP [StageSpriteLoopMoveX] ( #46, #0C, #13 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #46 )
    COP [AnimOnce]
    RTL 
}

code_05A44B {
    COP [PrintDialogString] ( &dialogstring_05A453 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_05A453 `[TPL:A][PAL:0]つぼの中には[N]手紙が 入っていた···[N]それは こんな 内容だった.[FIN][TPL:5]ぼくらは どれい船にのせられ[N]見知らぬ土地へ 売られていく[N]ところです.[FIN]どなたか この手紙を読んだら[N]助けてください···[N]             サムス[PAL:0][END]`

code_05A4E0 {
    LDA #$0200
    TSB $12
    COP [SpawnAfterFlags] ( @code_05A242, #$2800 )
    LDA #$0001
    STA $playerHp
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A72B )
    COP [PrintDialogString] ( &dialogstring_05AC43 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_05A54C )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #18, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_05AD7A )
    COP [SetFlagWord] ( #$0120 )
    COP [SetFlagByte] ( #52 )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_05A54C {
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_05A559
    COP [PrintDialogString] ( &dialogstring_05ACA5 )
    RTL 

  loc_05A559:
    COP [PrintDialogString] ( &dialogstring_05ACBD )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_05A561 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SpawnThinker] ( @code_05A5CF )
    TXA 
    TYX 
    TAY 
    LDA $animScratch2, X
    ORA #$0800
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SetTilePos] ( #06, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A73E )
    COP [PrintDialogString] ( &dialogstring_05ADCB )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_05AEDE )
    LDA #$0800
    TSB $10
    COP [StageSprAndHitbox] ( #17 )
    COP [StageForceMoveX] ( #13 )
    COP [ClearFlagWord] ( #$0120 )
    LDA #$0000
    STA $0682
    COP [ClearFlagByte] ( #52 )
    INC $0AA6
    LDA #$0408
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00A0, #03, #$1100 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_05A5CF {
    COP [SetEntryContinue]
    COP [PaletteStart] ( #73 )
    COP [PaletteStep]
    RTL 
}

code_05A5D7 {
    COP [SetTilePos] ( #08, #0B )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A752 )
    COP [SetOnInteract] ( &code_05A64E )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnAfterAbsFlags] ( @code_05A664, #$0118, #$0088, #$1800 )
    COP [LoopInit] ( #02 )
    COP [WaitByte] ( #59 )
    COP [SpawnAfterAbsFlags] ( @code_05A67D, #$FFE8, #$00D8, #$1800 )
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    COP [StartMusic] ( #06 )
    COP [PrintDialogString] ( &dialogstring_05AFED )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryDelayExit] ( @code_05A624, #$04B0 )
}

code_05A624 {
    COP [FadeThenStartMusic] ( #15 )
    COP [PrintDialogString] ( &dialogstring_05B079 )
    COP [SetFlagByte] ( #03 )
    COP [SetOnInteract] ( #$0000 )
    COP [WaitByte] ( #EF )
    COP [SetFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00A0, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_05A64E {
    COP [BranchIfFlagByte] ( #01, #01, &code_05A65C )
    COP [PrintDialogString] ( &dialogstring_05AF17 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_05A65C {
    COP [PrintDialogString] ( &dialogstring_05B030 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_05A664 {
    LDA #$1000
    TSB $12
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteLoopMoveX] ( #45, #10, #02 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #50 )
    COP [BranchIfFlagByte] ( #03, #01, &code_05A698 )
}

code_05A67D {
    LDA #$1000
    TSB $12
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteLoopMoveX] ( #C5, #10, #01 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #B0 )
    COP [BranchIfFlagByte] ( #03, #01, &code_05A698 )
    BRA code_05A664
}

code_05A698 {
    COP [Die]
}

code_05A69A {
    COP [SetTilePos] ( #09, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_05A766 )
    COP [SetOnInteract] ( &code_05A6FD )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5A6
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_05B2BD )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #31, #$00A0, #$0060, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_05A6FD {
    COP [PrintDialogString] ( &dialogstring_05B14C )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05A705 `[DLG:A,7][SIZ:6,1,0]ひょう流 2日目[END]`

dialogstring_05A718 `[DLG:A,7][SIZ:6,1,0]ひょう流 4日目[END]`

dialogstring_05A72B `[DLG:A,7][SIZ:6,1,0]ひょう流 7日目[END]`

dialogstring_05A73E `[DLG:A,7][SIZ:7,1,0]ひょう流 12日目[END]`

dialogstring_05A752 `[DLG:A,7][SIZ:7,1,0]ひょう流 18日目[END]`

dialogstring_05A766 `[DLG:A,7][SIZ:7,1,0]ひょう流 21日目[END]`

dialogstring_05A77A `[TPL:A][TPL:1]カレン:[N]やっと 気がついたのね.[N]みんなと はぐれちゃった···[FIN]体の具合は だいじょうぶ?[N][PAL:0] うん へっちゃらさ[N] まだ ふらふらするんだ`

dialogstring_05A7CE `[CLR][TPL:1]カレン: そう.[N]テムって 回復がはやいのね.[N]まるで とかげのしっぽみたい.[FIN][JMP:&chunk_058000.dialogstring_05A802+M]`

dialogstring_05A802 `[CLR][TPL:1]カレン: 無理も ないわよね.[N]半日以上 気をうしなって[N]たんだもの.[FIN][::][TPL:A][TPL:1]ひょう流の話は 本で読んだこと[N]あるけど まさか 自分が そうなる[N]なんて 思ってもみなかった···[FIN]災難って とつぜんに[N]おとずれるものなのね.[PAL:0][END]`

dialogstring_05A88B `[TPL:A][TPL:1]カレン:[N]くよくよしたって しかたないわよ.[FIN]先のことは 考えないで[N]ひょう流を 楽しんじゃおっ.[FIN]もう おなか ぺこぺこ.[N]お城の地下から もってきた お肉で[N]お昼ごはんに しましょ.[PAL:0][END]`

dialogstring_05A8FA `[TPL:A][TPL:1]カレン: きれい···[N]ー日中見てても あきないな···[PAL:0][END]`

dialogstring_05A923 `[TPL:A][TPL:1]カレン: 何てことするのよっ![N]魚が かわいそうじゃないっ!![PAL:0][END]`

dialogstring_05A94D `[TPL:A][TPL:0]テム:[N]何ごともなく 時間がだけが[N]ゆっくりと 流れていった.[FIN]カレンは ー日中 のんびりと[N]魚を ながめていたが ボクは[N]それじゃ 気がすまなかった.[FIN]イカダの中を うろつきまわり[N]カレンに 何度も 話しかけた.[FIN]ー分が 何時間にも 感じられた.[N]まるで のんびりとした時間の足音が[N]聞こえてくるようだった.[PAL:0][END]`

dialogstring_05AA11 `[TPL:A][TPL:1]カレン:[N]何か 予感がするの···[N]助けが くるのかもしれないわ···[FIN]あらっ?[PAL:0][END]`

dialogstring_05AA46 `[TPL:A][TPL:1]カレン:[N]何か 流れてくるみたいよっ![PAL:0][END]`

dialogstring_05AA64 `[TPL:A][TPL:1]カレン:[N]あーあ 予感がしたのにっ.[FIN]助けてくれって 言われたって··[N]こっちが 助けてほしいよねぇ.[FIN]あーあ もう お腹と 背中が[N]くっつきそうよぉ.[FIN][TPL:0]テム: だから あのとき[N]魚を とっておけばよかったんだ.[N]そうすりゃ 今ごろは···[FIN][TPL:1]カレン:[N]あんな かわいい魚 殺せないわ![FIN][TPL:0]テム:[N]じゃ 何にも食べないで ぼくらが[N]死んでもいいって いうのかっ?![FIN][TPL:1]カレン:[N]だいたい 生の魚なんて[N]気持ち悪くて 食べられないわよっ![FIN]それに 魚だっていっしょうけんめい[N]生きてるのよっ![FIN]魚だって 痛いって思うのよっ![N]テムは 魚の気持ちを 考えたこと[N]あるわけっ?![FIN]そんなに 食べたきゃ 勝手に[N]食べればっ![N]あたしは 食べないからねっ!![PAL:0][END]`

dialogstring_05ABE7 `[TPL:A][TPL:1]カレン:[N]··········[FIN][TPL:0]テム:[N]カレンは その日 口をきいて[N]くれなかった···[FIN]まったく おじょう樣には[N]困ったものだ. やれやれ···[PAL:0][END]`

dialogstring_05AC43 `[PAU:1E][TPL:A][TPL:0]テム:[N]ひょう流 ー週間目.[N]再び 魚のむれに 出会った.[FIN]体力も もう げんかいだった.[N]ボクは これ以上 食べなければ[N]死ぬと思った···[END]`

dialogstring_05ACA5 `[TPL:A][TPL:1]カレン:[N]··········[PAL:0][END]`

dialogstring_05ACBD `[TPL:A][TPL:1]カレン:[N]··········[FIN]テム···[N]昨日は あんな言いかたして[N]ごめんなさい···[FIN]あたしも お魚 食べてみるわ.[N]死んじゃったら どうしようも[N]ないもんね.[FIN]きらいな食べ物を 食べないなんて[N]いっていられるのは 平和なとき[N]だけなのよね···[FIN][TPL:0]テム:[N]よおし. じゃ 魚をとってやる.[N]とびっきり うまいやつをさ.[PAL:0][END]`

dialogstring_05AD7A `[TPL:A][TPL:0]テム:[N]カレンは おいしそうに 魚を[N]食べた.[FIN]ボクの中で カレンが[N]ちょっぴり 気になる存在に[N]なってきたようだ···[PAL:0][END]`

dialogstring_05ADCB `[DLG:3,13][SIZ:D,3,0][TPL:1]カレン:[N]星が きれいね···[FIN]もう ちょっと 背が高かったら[N]手が とどきそうよね.[FIN]きっと リリィや ロブたちも[N]同じ 星空を 見てるんだろうな.[FIN]星と お話できれば[N]みんなのいる場所も きっと[N]わかるのに···[FIN][TPL:1]カレン: あ そうそう 最近[N]気がついたんだけど 白鳥座の近くに[N]星がーつ ふえてるの.[FIN]ほら あの 赤い星.[FIN]ねぇ.[N]あの星に お願いごとしない?[N]きっと かなうような 気がするの.[FIN]テムも ちゃんと 目を閉じて[N]お願いしてね.[END]`

dialogstring_05AEDE `[TPL:A][TPL:0]テム: ボクは みんなの無事と[N]父さんのことを いっしょうけんめい[N]いのってみた···[PAL:0][END]`

dialogstring_05AF17 `[TPL:A][TPL:1]カレン:[N]もう ひょう流してから 3週間[N]近くたつのね.[FIN]テムってば 少し カミの毛が[N]のびたんじゃない?[N]そうね 2ドットくらい(芺)[FIN][TPL:0]テム: そういう カレンもさ,[N]おひめさまって 感じじゃなくなった[N]よな.[FIN]どっかの島の 女の子って[N]言っても わかんないと思うけど.[FIN][TPL:1]カレン:[N]ひっどーい![FIN]な なに···?[N]あの 海にいるの なに···?[PAL:0][END]`

dialogstring_05AFED `[TPL:A][TPL:1]カレン:[N]もしかして サメ···?[FIN]あたしたち 食べられちゃうの[N]かしら···[N]どうしよう·· テム···[PAL:0][END]`

dialogstring_05B030 `[TPL:A][TPL:1]カレン:[N]イカダのまわりを ぐるぐるまわる[N]だけで おそってこないわね···[FIN][TPL:0]テム:[N]しばらく 樣子を見てみよう.[END]`

dialogstring_05B079 `[TPL:A][TPL:1]カレン:[N]わかった![N]この子たち お腹がすいてないのよ![FIN]むかし じいやに 教わったの.[N]お腹がすいてないのに 生き物を[N]おそうのは 人間だけだって.[FIN][TPL:0]テム:[N]それなら ボクらのやっていることは[N]人間らしくないんだなあ.[FIN]死にそうになるまで[N]魚を 食べなかったもんね.[FIN][TPL:1]カレン: そうよね.[N]あ いっちゃうみたい.[N]サメさん さよーならぁー···[PAL:0][END]`

dialogstring_05B14C `[TPL:A][TPL:1]カレン:[N]あたしね. お城にいるときは[N]夕日をみるのが 好きだったの···[FIN]お城のわたりロウカから見る 夕日は[N]すっごく すっごく きれいで···[FIN]でもね.[N]今は きらいになっちゃった.[FIN]夕日がしずむと 暗くて こわい[N]ヤミが やってきて···[FIN]そのまま 二度と 朝日を[N]見られないんじゃないかと思って··[FIN]でも テムが そばにいてくれたから[N]每日 きれいな 朝の光を 見られた[N]のよね.[FIN]テムが 近くに いてくれると,[N]たわいない こんな時間も なんだか[N]楽しく感じるの.[FIN][TPL:0]テム: ボクは そんな カレンに[N]話したいことが あるはずなのに[N]なぜか 言葉が 出てこなかった.[FIN]ボクは だまって うなづくだけ[N]だった···[PAL:0][END]`

dialogstring_05B2BD `[TPL:A][TPL:0]テム: とつぜん ボクは[N]ひざから がくっと くずれ落ち[N]意識が 遠のいていった···[FIN][TPL:1]カレン:[N]テムっ! テムっ!![N]どうしたのよっ![FIN]しっかりしてよっ![N]あたしを ー人にしないでよおっ!![PAL:0][END]`

actor_def_05B336 [
  actor-def < #48, #00, #10, {

  code_05B339:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05B353 )
    COP [SolidHighHere]

  loc_05B344:
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoop] ( #48, #10 )
    COP [AnimLoop]
    BRA loc_05B344
} >
]

code_05B353 {
    COP [PrintDialogString] ( &dialogstring_05B35B )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05B35B `[DEF]わん わんっ![END]`

actor_def_05B364 [
  actor-def < #15, #00, #10, {

  code_05B367:
    COP [BranchIfFlagByte] ( #56, #00, &code_05B376 )
    COP [SetOnInteract] ( &code_05B378 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05B376 {
    COP [Die]
}

code_05B378 {
    COP [PrintDialogString] ( &dialogstring_05B3A3 )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0254, #$0354, #00, #09 )
    COP [QueueMapChange] ( #32, #$0130, #$0350, #00, #$4500 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_05B3A3 `[DEF][TPL:1]カレン: この犬[N]ターボっていう 名前なんですって.[N]かしこそうな犬よね.[FIN]さあ 行きましょう.[N]きっと リリィや ロブ,エリック[N]たちと 会えるわよ.[FIN][TPL:6]こうして 二人は[N]花の都 フリージアへ向かう···[PAL:0][END]`

actor_def_05B428 [
  actor-def < #04, #00, #18, {

  code_05B42B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B48D )
    COP [BranchIfFlagByte] ( #56, #01, &code_05B48A )
    COP [BranchIfFlagByte] ( #76, #01, &code_05B48A )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5A6
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [WaitByte] ( #95 )
    COP [PrintDialogString] ( &dialogstring_05B492 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoop] ( #03, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05B757 )
    COP [SetFlagByte] ( #76 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05B48A {
    COP [SetEntryContinue]
    RTL 
}

code_05B48D {
    COP [PrintDialogString] ( &dialogstring_05B620 )
    RTL 
}

dialogstring_05B492 `[TPL:A][TPL:6]男の声:[N]もう そろそろ 起こしても[N]だいじょうぶだろう.[FIN]ビタミンCも じゅうぶんとらせたし[N]体のつかれも 回復しているはずだ.[FIN]これは かい血病といってね[N]長期間 ビタミンCをとらないと[N]かかる病気なんだよ.[FIN][TPL:1]カレン:[N]ふうん····[FIN][TPL:6]かの有名な 探険家 コロンブスの[N]ー行だって かかった病気だ.[N]気に することはないさ.[FIN]この病気が もっと ひどくなると[N]血がダメになり ヒフの色が[N]どす黒くなってくる.[FIN]齒ぐきから 血が止まらなくなり,[N]やがて 体が くさって···[FIN][TPL:1]カレン: やめてよっ!![N]そんな こわい話 聞きたくないわっ[FIN][TPL:6]男:[N]はははは.[N]まあ 無事で なによりだ.[FIN][TPL:1]カレン:[N]でも おじさんって 物知りなのね.[N]本当に ありがとう.[FIN]`

dialogstring_05B620 `[TPL:A][TPL:6]礼なら 外にいる 犬に言ってくれ.[N]あいつが 君たちのイカダを発見して[N]私を 海につれだしたんだからな.[PAL:0][END]`

dialogstring_05B666 `[TPL:E][TPL:1]カレン:[N]テム! テムっ!![N]目を覚ましてっ!!![FIN]陸地に 陸地についたのよっ!![N]あたしたち 助かったのよっ!!![FIN][TPL:0]テム:[N]う ううん···[PAL:0][END]`

dialogstring_05B6C5 `[TPL:E][TPL:0]テム: はっ カレン···?[N]ここは いったい···?[FIN][TPL:1]カレン:[N]あたしたちを 助けてくれた[N]親切な おじさんのおうち.[FIN]まったく テムったら ねぞうが[N]悪いんだからっ.[FIN]病人だっていうのに おふとんを[N]`

code_05B73F {
    RTI 
    EOR $4D, S
    EOR $4020, X
    EOR $4D, S
    EOR $5420, X
    BIT $6F06, X
    AND $&20CD68, X
    ASL 
    EOR $1F53, X

  loc_05B754:
    CMP $00, S
    CPY #$0EC2
    REP #$06
    BRA loc_05B754

  loc_05B75D:
    ADC $@gfx_ruins+1298, X
    MVN #$20, #$D4
    AND $@214273, X
    PLA 
    ASL $53D5
    STA ($6C, X)
    EOR ($54, S), Y
    ORA [$64]
    ORA $@gfx_ruins+129C, X
    RTI 
    ADC ($20, X)
    BRA loc_05B726

  loc_05B77B:
    STA ($2A, X)
    WDM 
    ADC ($3C, X)
    JSR $3882
    EOR [$81], Y
    ASL 
    RTI 
    AND $&20CD4E, X
    BRA loc_05B7DB

  loc_05B78C:
    EOR ($80, S), Y
    BVC loc_05B7B0
    PEI ($56)
    PER code_05BE08
    TSC 
    CMP $00, X
    TSC 
    ADC $1F, S
    CMP ($54), Y
    COP [TickGravity]
    LSR 
    STA ($4B, X)
    BRA loc_05B7A9

  loc_05B7A4:
    ADC [$20]
    EOR $00
    EOR [$4F]
    ADC ($20, X)
    EOR $5407, Y
    CMP $3180
    EOR ($4F, X)
    BRA loc_05B7FF

  loc_05B7B6:
    EOR [$20], Y
    BRA loc_05B7C2

  loc_05B7BA:
    ROR $5A4D
    ADC $44, S
    LSR $4F0A

  loc_05B7C2:
    ORA $@gfx_000000+C3, X

  dialogstring_05B7C6:
    REP #$0A
    REP #$01
    PEI ($40)
    STZ $68
    CMP $7F, X
    CMP $504E
    RTI 
    WDM 
    JSR $5349
    PEI ($56)
    PER loc_05BE50
    TSC 
    CMP $6E, X
    EOR $3D3C
    CMP $4980
    EOR [$20], Y
    BIT $4D6E, X
    PHY 
    EOR $7146, Y
    ORA $@gfx_prologue_prophecy+A33, X
    LSR $20
    STA ($C5, X)
    BVC loc_05B819
    AND $@3CA081, X
    ROR $424D
    ADC $1F, S
    CMP $7006
    PLA 
    ORA $00, X
    ORA $4A41
    ADC ($20, X)
    EOR ($4D, X)
    EOR ($1F)
    CMP $00, S
    CPY #$002D
    BPL loc_05B81A
    BNE loc_05B870

  loc_05B81A:
    ORA ($96, X)
    CLV 
    COP [SetOnInteract] ( &code_05B8A5 )
    COP [BranchIfFlagByte] ( #76, #01, &code_05B898 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #31, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05B666 )
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5B5
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0000
    JSL $@chunk_008000.dialogstring_00C829
    COP [WaitByte] ( #3B )
    LDA #$0002
    JSL $@chunk_008000.dialogstring_00C829
    COP [WaitByte] ( #13 )
    COP [PrintDialogString] ( &dialogstring_05B6C5 )
    COP [SetFlagByte] ( #02 )

  loc_05B876:
    COP [ExitIfFlagByte] ( #56, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #30, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2E, #04, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_05B898 {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SolidHighHere]
    BRA loc_05B876
}

code_05B8A5 {
    COP [PrintDialogString] ( &dialogstring_05B7C6 )
    COP [SetFlagByte] ( #56 )
    RTL 
}

actor_def_05B8AD [
  actor-def < #00, #00, #28, {

  code_05B8B0:
    LDA #$0420
    STA $cameraBoundsY
    COP [SpawnAfter] ( @code_05B8CD )
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @sprite_set_list_14C000 )
    COP [ResetSpriteInit] ( #00, #$3FE0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]

code_05B8CD {
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @sprite_set_list_14C000 )
    COP [ResetSpriteInit] ( #01, #$3FF0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
}

actor_def_05B8DF [
  actor-def < #2B, #00, #10, {

  code_05B8E2:
    COP [BranchIfFlagByte] ( #65, #01, &code_05B985 )
    COP [BranchIfFlagByte] ( #57, #01, &code_05B985 )
    COP [BranchIfFlagByte] ( #64, #01, &code_05B947 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05B98F )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05B9ED )
    COP [SetFlagByte] ( #64 )
    COP [SetFlagByte] ( #03 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #1F )
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #2F, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #31, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2F, #06, #02 )
    COP [AnimLoop]
} >
]

code_05B947 {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetTilePos] ( #27, #25 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B987 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #05 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #57 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_05B985 {
    COP [Die]
}

code_05B987 {
    COP [PrintDialogString] ( &dialogstring_05BA17 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

dialogstring_05B98F `[TPL:E][TPL:1]カレン: うわあ すてきっ![N]さすが 花の都って いうだけ[N]あるわよねっ!![FIN]こんな きれいなところに[N]住んでる人たちは きっと 心も[N]きれいなんだろうな···[PAL:0][END]`

dialogstring_05B9ED `[TPL:E][TPL:1]カレン:[N]テムも それで いいわよねっ.[N]さっ いこいこっ!![PAL:0][END]`

dialogstring_05BA17 `[TPL:E][TPL:1]カレン:[N]ここの 宿屋さんが そうだって.[N]さっ はいろっ!![PAL:0][END]`

actor_def_05BA41 [
  actor-def < #02, #00, #10, {

  code_05BA44:
    COP [BranchIfFlagByte] ( #57, #01, &code_05BAAF )
    COP [SpawnAfterAbsFlags] ( @code_05BBCA, #$0278, #$0230, #$1000 )
    COP [BranchIfFlagByte] ( #64, #01, &code_05BA9D )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05BAD1 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
} >
]

code_05BA9D {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SetTilePos] ( #28, #25 )
    COP [SetOnInteract] ( &code_05BAC7 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05BAAF {
    COP [SpawnAfterAbsFlags] ( @chunk_008000.code_00C738, #$0278, #$0230, #$1000 )
    COP [SetOnInteract] ( &code_05BACC )
    COP [SetTilePos] ( #29, #24 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05BAC7 {
    COP [PrintDialogString] ( &dialogstring_05BB89 )
    RTL 
}

code_05BACC {
    COP [PrintDialogString] ( &dialogstring_05BB96 )
    RTL 
}

dialogstring_05BAD1 `[TPL:E]男: こりゃまた ずいぶんと[N]かわいい 旅人さんだこと.[N]今夜の宿は おきまりですか?[FIN][TPL:1]カレン: ううん.[N]決ってないわ. それに あたしたち[N]人を さがしてるの.[FIN][TPL:6]男: それは それは.[N]なら うちの宿を きょ点にして[N]人さがしをしたら どうですか?[FIN][TPL:1]カレン: 決ーまりっ![N]あたし もう くったくたっ!![PAL:0][END]`

dialogstring_05BB89 `[DEF]さあ どうぞ どうぞ.[END]`

dialogstring_05BB96 `[DEF]最近 この町には 旅人が すっかり[N]よりつかなくなって···[N]商売 あがったりですよ.[END]`

code_05BBCA {
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [PlaySoundCh2] ( #0E )
    COP [ClearLowHere]
    COP [Die]
}

actor_def_05BBE1 [
  actor-def < #08, #00, #10, {

  code_05BBE4:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #FE, #05 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_05BBF2 [
  actor-def < #0A, #00, #10, {

  code_05BBF5:
    COP [SetSpritePriority] ( #10 )

  loc_05BBF8:
    COP [StageSpriteLoopMoveX] ( #11, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    BRA loc_05BBF8
} >
]

actor_def_05BC12 [
  actor-def < #11, #00, #10, {

  code_05BC15:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #02, #05 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_05BC23 [
  actor-def < #1A, #00, #10, {

  code_05BC26:
    COP [BranchIfFlagByte] ( #67, #01, &code_05BC54 )
    COP [SolidHighAbs] ( #04, #0D )
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #08, #02 )
    COP [WaitWhileOffscreen] ( #08 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0E, #0B, #12, &code_05BC43 )
    RTL 
} >
]

code_05BC43 {
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [SpawnAfterAbsFlags] ( @code_05BC56, #$0048, #$00E0, #$1000 )
}

code_05BC54 {
    COP [Die]
}

code_05BC56 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SetSpritePriority] ( #20 )
    COP [SetOnInteract] ( &code_05BCC0 )
    COP [PlaySoundCh2] ( #0E )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #67, #01 )
    PHX 
    LDX #$0000

  loc_05BC79:
    LDA $@pal_southcape_sprites+E0, X
    STA $7F0BE0, X
    INX 
    INX 
    CPX #$0020
    BNE loc_05BC79
    PLX 
    LDA #$2000
    TSB $joypadMaskStd
    LDA #$0008
    TRB $slopeCurvePtrB
    JSL $@chunk_0A8000.code_0AA340
    LDA #$0005
    STA $currentHp, X
    LDA #$1000
    TRB $10
    LDA #$0100
    TSB $10
    COP [OrActorFlags] ( #$0008 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #0E, #08, #12, &code_05BCB9 )
    RTL 
}

code_05BCB9 {
    COP [PrintDialogString] ( &dialogstring_05BDD5 )
    COP [SetEntryContinue]
    RTL 
}

code_05BCC0 {
    COP [BranchIfFlagByte] ( #66, #01, &code_05BCCB )
    COP [PrintDialogString] ( &dialogstring_05BCE3 )
    RTL 
}

code_05BCCB {
    COP [PrintDialogString] ( &dialogstring_05BCFB )
    COP [SetFlagByte] ( #67 )
    COP [SolidHighAbs] ( #08, #0E )
    COP [SolidHighAbs] ( #08, #0F )
    COP [SolidHighAbs] ( #08, #10 )
    COP [SolidHighAbs] ( #08, #11 )
    RTL 
}

dialogstring_05BCE3 `[DEF]男の声:[N]命がおしければ かえんな!![END]`

dialogstring_05BCFB `[DEF]男の声:[N]命がおしければ かえんな!![FIN][TPL:0]テム:[N]そこに エリックっていう 男の子が[N]いませんか?[FIN][PAL:0]男の声:[N]そんな 名前は聞いたこともないな.[N]何を しょうこに そんなことを[N]言うんだね?[FIN][TPL:3]テムっ? その声は テムだねっ?[N]たすけ···· [PAL:0]ボコッ[FIN]男の声: しっ···[N]ぼうずっ 静かにしないかっ···[FIN][TPL:0]テム:[N](しかたない ドアをやぶろう··)[N][PAL:0][END]`

dialogstring_05BDD5 `[DEF][TPL:0]テム:[N]今は エリックを 助けなくちゃ··[PAL:0][END]`

actor_def_05BDF6 [
  actor-def < #02, #00, #10, {

  code_05BDF9:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #08, #04 )
    COP [SetOnInteract] ( &code_05BE08 )
    COP [WaitWhileOffscreen] ( #08 )
    RTL 
} >
]

code_05BE08 {
    COP [PrintDialogString] ( &dialogstring_05BE15 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [PrintDialogString] ( &dialogstring_05BE62 )
    RTL 
}

dialogstring_05BE15 `[DEF]びっくりした···[N]屋根から 人が ふってくるとはね.[FIN]身のちぢむような ダイビングを[N]見せてくれた `

loc_05BE50 {
    AND $@gfx_angel+117A, X
    JSR $3C3C
    EOR $6753, X
    CMP $033B
    RTS 
}

code_05BE5E {
    AND $&20D11F, X
    CPY $&20C2D0
    ORA [$D4]
    TRB $46
    ROR $7DD5
    ADC $7D7D, X
    ADC $&20D17D, X
    CMP $00, S
    MVP #$53, #$20
    PEI ($00)
    EOR ($D5, X)
    ROR $&20CD7D
    MVP #$68, #$0E
    JSR $6849
    EOR $163B20
    EOR $@19D43C
    EOR ($D5)
    LSR $4D
    CMP $655A
    ROR $7D7D
    CMP $0A4A
    ASL $6F
    JSR $5947
    EOR $@2E093C
    ADC $7D7D, X
    CPY #$0012
    BPL loc_05BEAB
    LDX $10, Y

  loc_05BEAB:
    COP [SpawnAfterRelFlags] ( @code_05BEBE, #$0000, #$0018, #$3000 )
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

code_05BEBE {
    COP [SetOnInteract] ( &code_05BEC5 )
    COP [SetEntryContinue]
    RTL 
}

code_05BEC5 {
    COP [PrintDialogString] ( &dialogstring_05BECA )
    RTL 
}

dialogstring_05BECA `[DEF]女の子: 宿屋で[N]住みこみで はたらいていた男の子が[N]ドレイ商人に つかまったみたいよ.[END]`

actor_def_05BF03 [
  actor-def < #1A, #00, #10, {

  code_05BF06:
    COP [SetOnInteract] ( &code_05BF0F )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BF0F {
    COP [BranchIfFlagByte] ( #E1, #01, &code_05BF26 )
    COP [PrintDialogString] ( &dialogstring_05BF2B )
    COP [GiveItem] ( #01, &code_05BF22 )
    COP [SetFlagByte] ( #E1 )
    RTL 
}

code_05BF22 {
    JML $@chunk_008000.code_00C7E3
}

code_05BF26 {
    COP [PrintDialogString] ( &dialogstring_05BFB9 )
    RTL 
}

dialogstring_05BF2B `[DEF]ほっ ほっ ほっ.[N]よく ここが わかったのぅ.[FIN]どうでもいいと 思っているものが[N]実は 大切なものだったりする···[N]世の中 そういう ものじゃよ.[FIN]これは オマケじゃ.[N]とって おきなされ.[FIN]老人は テムの 持ち物の中に[N]そっと 何かをいれた![END]`

dialogstring_05BFB9 `[DEF]ほっ ほっ ほっ.[END]`

actor_def_05BFC4 [
  actor-def < #04, #00, #10, {

  code_05BFC7:
    COP [SetOnInteract] ( &code_05BFE1 )

  loc_05BFCB:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    LDA #$FFFB
    STA $09C0
    COP [WaitByte] ( #1D )
    COP [ClearFlagByte] ( #01 )
    BRA loc_05BFCB
} >
]

code_05BFE1 {
    LDA $playerWallType
    CMP $14
    BCS loc_05BFED
    COP [PrintDialogString] ( &dialogstring_05BFF5 )
    RTL 

  loc_05BFED:
    COP [PrintDialogString] ( &dialogstring_05C015 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05BFF5 `[DEF]ここは 子供のくるところじゃない.[N]帰った 帰った.[END]`

dialogstring_05C015 `[DEF]この ガキんちょはっ![N]どこから 入りこんだんだっ?![N]さあ 帰れ 帰れっ!![END]`

actor_def_05C043 [
  actor-def < #1D, #00, #10, {

  code_05C046:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05C066 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C068 )

  code_05C052:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #5A, #00, &code_05C052 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #04, #02 )
    COP [AnimLoop]
} >
]

code_05C066 {
    COP [Die]
}

code_05C068 {
    COP [PrintDialogString] ( &dialogstring_05C06D )
    RTL 
}

dialogstring_05C06D `[DEF]まったく どこへ いきやがった··[END]`

actor_def_05C080 [
  actor-def < #1C, #00, #10, {

  code_05C083:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05C0AC )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C0AE )
    COP [WaitByte] ( #07 )

  code_05C092:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #5A, #00, &code_05C092 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #04, #02 )
    COP [AnimLoop]
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_05C0AC {
    COP [Die]
}

code_05C0AE {
    COP [PrintDialogString] ( &dialogstring_05C0FB )
    COP [DialogueOptions] ( #02, #02, &code_list_05C0B8 )
}

code_list_05C0B8 [
  &code_05C0BE   ;00
  &code_05C0C3   ;01
  &code_05C0BE   ;02
]

code_05C0BE {
    COP [PrintDialogString] ( &dialogstring_05C129 )
    RTL 
}

code_05C0C3 {
    COP [PrintDialogString] ( &dialogstring_05C140 )
    COP [DialogueOptions] ( #02, #02, &code_list_05C0CD )
}

code_list_05C0CD [
  &code_05C0D3   ;00
  &code_05C0D8   ;01
  &code_05C0D3   ;02
]

code_05C0D3 {
    COP [PrintDialogString] ( &dialogstring_05C1EB )
    RTL 
}

code_05C0D8 {
    COP [BranchIfFlagByte] ( #59, #01, &code_05C0E3 )
    COP [PrintDialogString] ( &dialogstring_05C1CA )
    RTL 
}

code_05C0E3 {
    COP [GiveItem] ( #01, &code_05C0F6 )
    COP [PrintDialogString] ( &dialogstring_05C178 )
    COP [SetFlagByte] ( #5A )
    LDA #$EFF0
    TSB $joypadMaskStd
    RTL 
}

code_05C0F6 {
    COP [PrintDialogString] ( &dialogstring_05C20E )
    RTL 
}

dialogstring_05C0FB `[DEF]ドレイがー人 にげだしたんだ.[N]どこかで 見かけなかったか?[N] はい[N] いいえ`

dialogstring_05C129 `[CLR]そうか.[N]見つけたら 知らせてくれよ.[END]`

dialogstring_05C140 `[CLR]なんと! その場所を教えてくれたら[N]赤い宝石をやろう.[N] 場所を教える[N] 芺ってごまかす`

dialogstring_05C178 `[CLR]テムは ドレイの[N]かくれている家を 教えた.[FIN]男:[N]ありがとうよ.[N]これは お礼だ. とっといてくれ.[FIN]テムは 赤い宝石を もらった.[END]`

dialogstring_05C1CA `[CLR]しかし テムは[N]ドレイのかくれ場所を 知らない.[FIN]`

dialogstring_05C1EB `[CLR]男:[N]こらっ. ぼうずっ.[N]大人を からかうんじゃないっ!![END]`

dialogstring_05C20E `[CLR]男:[N]おっと 持ち物が いっぱいなのか?[N]それでは しょうがない···[END]`

actor_def_05C236 [
  actor-def < #13, #00, #10, {

  code_05C239:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C242 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C242 {
    COP [PrintDialogString] ( &dialogstring_05C247 )
    RTL 
}

dialogstring_05C247 `[DEF]フリージアっていうのは[N]町のしょうちょうに なっている花.[N]すてきな かおりでしょ.[END]`

actor_def_05C277 [
  actor-def < #02, #00, #10, {

  code_05C27A:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C283 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C283 {
    COP [PrintDialogString] ( &dialogstring_05C288 )
    RTL 
}

dialogstring_05C288 `[TPL:A]まったく 2階のやつらときたら··[N]かたみがせまいよ··· オレは.[END]`

actor_def_05C2B0 [
  actor-def < #0D, #00, #10, {

  code_05C2B3:
    COP [SetOnInteract] ( &code_05C2E0 )
    COP [AddPosition] ( #04, #00 )
    COP [WaitWhileOffscreen] ( #01 )
    COP [WaitByte] ( #1D )
    COP [StageSprAndHitbox] ( #10 )
    COP [StageForceMoveX] ( #14 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [StageForceMoveX] ( #00 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C2E0 {
    COP [PrintDialogString] ( &dialogstring_05C2E5 )
    RTL 
}

dialogstring_05C2E5 `[DEF]彼の 目に入ったゴミを[N]とって あげていたのよ.[N]ほほほほほほほほ.[END]`

actor_def_05C30E [
  actor-def < #04, #00, #10, {

  code_05C311:
    COP [AddPosition] ( #FC, #00 )
    COP [SetOnInteract] ( &code_05C33E )
    COP [WaitWhileOffscreen] ( #01 )
    COP [WaitByte] ( #1D )
    COP [StageSprAndHitbox] ( #09 )
    COP [StageForceMoveX] ( #13 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [StageForceMoveX] ( #00 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C33E {
    COP [PrintDialogString] ( &dialogstring_05C343 )
    RTL 
}

dialogstring_05C343 `[DEF]か 彼女に ゴミに入った目を[N]とってもらってたのさ···[N]はははははははは.[END]`

actor_def_05C371 [
  actor-def < #0C, #00, #10, {

  code_05C374:
    COP [SetOnInteract] ( &code_05C394 )

  loc_05C378:
    COP [StageSpriteLoopMoveX] ( #10, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    BRA loc_05C378
} >
]

code_05C394 {
    COP [PrintDialogString] ( &dialogstring_05C399 )
    RTL 
}

dialogstring_05C399 `[TPL:A]母親って ほんと 気苦労が[N]たえないものよ.[FIN]悪い人に連れていかれたんじゃないか[N]どこかで ケガしてるんじゃないか[N]とかね···[FIN]あたしの お母さんも 同じように[N]苦労を してきたんだろうな.[END]`

actor_def_05C40A [
  actor-def < #02, #00, #10, {

  code_05C40D:
    COP [SetOnInteract] ( &code_05C416 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C416 {
    COP [PrintDialogString] ( &dialogstring_05C41B )
    RTL 
}

dialogstring_05C41B `[TPL:A]别に どろぼうが 入ったわけじゃ[N]ないんだよ.[FIN]こんなふうに 少しは ちらかって[N]いた方が 落ち着くと思わないか?[END]`

actor_def_05C45E [
  actor-def < #02, #00, #10, {

  code_05C461:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05C470 )
    COP [SetOnInteract] ( &code_05C472 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C470 {
    COP [Die]
}

code_05C472 {
    COP [PrintDialogString] ( &dialogstring_05C477 )
    RTL 
}

dialogstring_05C477 `[TPL:A]見つかったものは しかたがないな.[N]ここにいるのは 昨日 にげだした[N]ドレイだよ.[FIN]ドレイ商人たちに このことを[N]話すがいい.[N]かくごの上で やったことさ.[END]`

actor_def_05C4D3 [
  actor-def < #0A, #00, #10, {

  code_05C4D6:
    COP [SetOnInteract] ( &code_05C4DF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C4DF {
    COP [PrintDialogString] ( &dialogstring_05C4E4 )
    RTL 
}

dialogstring_05C4E4 `[TPL:A]悪いことは 言わない.[N]裹通りには いかないほうが[N]身のためだよ.[FIN]美しいバラには トゲがあるように[N]美しい町には 裹の顔があるものさ.[END]`

actor_def_05C539 [
  actor-def < #02, #00, #10, {

  code_05C53C:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C574 )
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #04, #3C )
    COP [AnimLoop]
    COP [SpawnMarkedAfter] ( @code_05C5B4, #$1002 )
    COP [WaitByte] ( #B3 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #06, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #04, #04 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_05C574 {
    COP [PrintDialogString] ( &dialogstring_05C57C )
    COP [SetFlagByte] ( #0F )
    RTL 
}

dialogstring_05C57C `[DEF]火を使った 芸を 得意とする者で[N]おれの 右に出るヤツは いない.[N]いいか みてろよっ![END]`

code_05C5B4 {
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteLoop] ( #32, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #0F )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    RTL 
}

actor_def_05C5D7 [
  actor-def < #35, #00, #10, {

  code_05C5DA:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C5E8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C5E8 {
    COP [PrintDialogString] ( &dialogstring_05C5ED )
    RTL 
}

dialogstring_05C5ED `[DEF]ういー·· ひっく···[N]まじめに 生きるのも人生.[N]飲んで芺って生きるのも 人生さね.[END]`

actor_def_05C625 [
  actor-def < #35, #00, #10, {

  code_05C628:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C636 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C636 {
    COP [PrintDialogString] ( &dialogstring_05C63B )
    RTL 
}

dialogstring_05C63B `[DEF]もうじき きょうふの大王が 天から[N]降りてくるんだと···[N]そして 人類は 死に絕えるんだと.[FIN]だれが 予言したのか 知らないが[N]ウソっぱちも いいところだぜ.[N]バカバカしくって 飲まなきゃ[N]やってらんねえや. ヒック.[END]`

actor_def_05C6BD [
  actor-def < #28, #00, #10, {

  code_05C6C0:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05C6D4 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C6D6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C6D4 {
    COP [Die]
}

code_05C6D6 {
    COP [PrintDialogString] ( &dialogstring_05C6DB )
    RTL 
}

dialogstring_05C6DB `[DEF][TPL:5]ぼくは イムス.[N]遠くはなれた大陸から 船で[N]この町へ つれてこられました.[FIN]ぼくらは しゅりょう民族.[N]おなかがすくと カリをして[N]生活してたんです.[FIN]このところ 動物たちが つぎつぎと[N]原因不明の病気で バタバタと[N]死んでいって···[PAL:0][END]`

actor_def_05C770 [
  actor-def < #28, #00, #10, {

  code_05C773:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05C787 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C79A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C787 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C79F )
    COP [SetEntryContinue]
    RTL 
}

code_05C79A {
    COP [PrintDialogString] ( &dialogstring_05C7A4 )
    RTL 
}

code_05C79F {
    COP [PrintDialogString] ( &dialogstring_05C826 )
    RTL 
}

dialogstring_05C7A4 `[DEF][TPL:5]ぼくは レムス.[N]動物がいなくなり ぼくらは[N]食べ物が なくなったんだ.[FIN]そして 生きるために しかたなく[N]ドレイに なったというわけさ.[FIN]ぼくらは いったい どんな人に[N]買われて どんなところに[N]連れていかれんだろう···[PAL:0][END]`

dialogstring_05C826 `[DEF]神よ·· どうして あなたは[N]身分というものを 作ったのですか?[END]`

actor_def_05C84C [
  actor-def < #28, #00, #10, {

  code_05C84F:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05C863 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C865 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C863 {
    COP [Die]
}

code_05C865 {
    COP [PrintDialogString] ( &dialogstring_05C86D )
    COP [SetFlagByte] ( #66 )
    RTL 
}

dialogstring_05C86D `[DEF][TPL:5]ぼくは サムス.[FIN]夕べ 宿屋で はたらいている[N]エリックという男の子が ぼくらを[N]助けにきてくれたんです.[FIN]でも ドレイ商人たちに見つかって[N]連れていかてちゃった···[FIN]たぶん 町の裹通りの はじっこの[N]家に とじこめられているはず.[N]どうか 助けてあげてください.[PAL:0][END]`

actor_def_05C90D [
  actor-def < #1A, #00, #10, {

  code_05C910:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C92C )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C92C {
    COP [PrintDialogString] ( &dialogstring_05C949 )
    COP [DialogueOptions] ( #02, #02, &code_list_05C936 )
}

code_list_05C936 [
  &code_05C93C   ;00
  &code_05C941   ;01
  &code_05C93C   ;02
]

code_05C93C {
    COP [PrintDialogString] ( &dialogstring_05C9D2 )
    RTL 
}

code_05C941 {
    COP [PrintDialogString] ( &dialogstring_05C9A1 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05C949 `[TPL:B]こら ぼうずっ![N]ここは 子供のくるところじゃない![N]さあ かえった かえった!![FIN]それとも あんたも ドレイを[N]買いにきたって いうのかい?[N] はい[N] いいえ`

dialogstring_05C9A1 `[CLR]その どきょうが 気に入った![N]本当に 買うのかどうかは 知らんが[N]見ていきな.[END]`

dialogstring_05C9D2 `[CLR]さあ かえった かえった!![END]`

actor_def_05C9E2 [
  actor-def < #03, #00, #10, {

  code_05C9E5:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C9EE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C9EE {
    COP [PrintDialogString] ( &dialogstring_05C9F3 )
    RTL 
}

dialogstring_05C9F3 `[TPL:A]自分が 彼らの 立場になったらと[N]思うと ぞっとするよ.[FIN]でも 今の オレは 人の気持ちを[N]考えるより 自分が 生きることで[N]せいいっぱいなんだ.[END]`

actor_def_05CA4F [
  actor-def < #04, #00, #10, {

  code_05CA52:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CA5B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CA5B {
    COP [PrintDialogString] ( &dialogstring_05CA60 )
    RTL 
}

dialogstring_05CA60 `[TPL:E]このドレイたちは ちょうど[N]君と 同い年くらいだよね.[FIN]おぼえておくんだな.[N]世界には 同い年でも こういう[N]生活をしてる人が いるってことを.[END]`

actor_def_05CAB7 [
  actor-def < #27, #00, #10, {

  code_05CABA:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05CACE )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CAD0 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CACE {
    COP [Die]
}

code_05CAD0 {
    COP [PrintDialogString] ( &dialogstring_05CAD8 )
    COP [SetFlagByte] ( #59 )
    RTL 
}

dialogstring_05CAD8 `[TPL:A]おねがいです![N]見のがして下さいっ!![FIN]わたしは どうなってもいいが[N]この人に めいわくが[N]かかります···[END]`

actor_def_05CB14 [
  actor-def < #27, #00, #10, {

  code_05CB17:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CB25 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CB25 {
    COP [PrintDialogString] ( &dialogstring_05CB2A )
    RTL 
}

dialogstring_05CB2A `[TPL:9]私たち これから 売りに[N]出されるところ···[END]`

actor_def_05CB47 [
  actor-def < #27, #00, #10, {

  code_05CB4A:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CB58 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CB58 {
    COP [PrintDialogString] ( &dialogstring_05CB5D )
    RTL 
}

dialogstring_05CB5D `[TPL:B]私 物ごとを 考えないように[N]しました.[N]考えれば 考えるほど むなしく[N]なるだけです···[END]`

actor_def_05CB93 [
  actor-def < #27, #00, #10, {

  code_05CB96:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CBA4 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CBA4 {
    COP [PrintDialogString] ( &dialogstring_05CBA9 )
    RTL 
}

dialogstring_05CBA9 `[TPL:A]私は 神を 信じません.[N]もし 神がいるなら 世の中に[N]身分など 存在しないはず···[END]`

actor_def_05CBE1 [
  actor-def < #1B, #00, #10, {

  code_05CBE4:
    COP [BranchIfFlagByte] ( #65, #01, &code_05CC42 )
    COP [BranchIfFlagByte] ( #58, #01, &code_05CC42 )
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC #$0008
    STA $0014, Y
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SetFlagByte] ( #58 )
    COP [PrintDialogString] ( &dialogstring_05CC58 )
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #21, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]

  loc_05CC34:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CC48 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CC42 {
    COP [SetTilePos] ( #14, #1A )
    BRA loc_05CC34
}

code_05CC48 {
    COP [BranchIfFlagByte] ( #68, #01, &code_05CC53 )
    COP [PrintDialogString] ( &dialogstring_05CCEB )
    RTL 
}

code_05CC53 {
    COP [PrintDialogString] ( &dialogstring_05CD17 )
    RTL 
}

dialogstring_05CC58 `[TPL:A][TPL:1]カレン:[N]リリィ? リリィなのっ?![FIN][TPL:2]リリィ: 心配したよおっ![N]ひと月近くも はなればなれだったん[N]だもんね!![FIN]この宿屋で 住みこみで 働かせて[N]もらってたんだよ.[FIN][TPL:A][TPL:2]右のおくの部屋に ロブがいるから[N]行ってあげてよ···[PAL:0][END]`

dialogstring_05CCEB `[TPL:A][TPL:1]カレン:[N]せっかく 無事に会えたっていうのに[N]こんなのって···[PAL:0][END]`

dialogstring_05CD17 `[TPL:A][TPL:1]カレン:[N]なんだか なみだが出てきちゃった.[PAL:0][END]`

actor_def_05CD37 [
  actor-def < #22, #00, #10, {

  code_05CD3A:
    COP [BranchIfFlagByte] ( #65, #01, &code_05CDAD )
    COP [BranchIfFlagByte] ( #58, #01, &code_05CDAD )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #26, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #22, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05CDD8 )
    COP [SetFlagByte] ( #01 )
    COP [SetOnInteract] ( &code_05CDB8 )
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #1C )
    COP [StageSpriteLoopMoveX] ( #29, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [SetEntryExit]
    COP [StageSpriteLoop] ( #22, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05CE01 )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_05CDA4:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CDBD )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CDAD {
    COP [SetTilePos] ( #16, #1C )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_05CDA4
}

code_05CDB8 {
    COP [PrintDialogString] ( &dialogstring_05CCC3 )
    RTL 
}

code_05CDBD {
    COP [BranchIfFlagByte] ( #68, #01, &code_05CDD3 )
    COP [BranchIfFlagByte] ( #65, #01, &code_05CDCE )
    COP [PrintDialogString] ( &dialogstring_05CE84 )
    RTL 
}

code_05CDCE {
    COP [PrintDialogString] ( &dialogstring_05CE57 )
    RTL 
}

code_05CDD3 {
    COP [PrintDialogString] ( &dialogstring_05CEC1 )
    RTL 
}

dialogstring_05CDD8 `[TPL:A][TPL:2]リリィ:[N]いらっしゃいま···[FIN]テムに カレン···?![PAL:0][END]`

dialogstring_05CE01 `[TPL:A][TPL:2]リリィ:[N]ロブは インカ船からにげだすときに[N]頭をうって そのまま···[FIN]お医者さんに みてもらったら[N]ー時的な きおくそうしつだって.[FIN]`

dialogstring_05CE57 `[TPL:A][TPL:2]とりあえず[N]ロブが よくなるまでは[N]この町にいようと 思うんだけど.[PAL:0][END]`

dialogstring_05CE84 `[TPL:A][TPL:2]リリィ: それとね.[N]エリックのすがたが 夕べから[N]見えないんだよ.[FIN]どうしちゃったのかな···[PAL:0][END]`

dialogstring_05CEC1 `[TPL:A][TPL:2]リリィ:[N]旅をすると ほんと いろんな[N]けいけんするね···[PAL:0][END]`

actor_def_05CEE9 [
  actor-def < #02, #00, #10, {

  code_05CEEC:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CF4E )
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_05D426, #$2800 )
    COP [WaitByte] ( #77 )
    COP [SetSpritePriority] ( #30 )
    COP [PrintDialogString] ( &dialogstring_05CFB8 )
    COP [ClearFlagByte] ( #0F )
    COP [SpawnThinkerParam] ( #1C, @chunk_008000.code_00B5C4 )
    COP [SetSpritePriority] ( #20 )
    COP [WaitByte] ( #77 )
    COP [FadeThenStartMusic] ( #02 )
    COP [WaitWord] ( #$012B )
    COP [StageSpriteLoop] ( #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #28 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05D19D )
    COP [SetFlagByte] ( #68 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CF4E {
    COP [BranchIfFlagByte] ( #68, #01, &code_05CF5C )
    COP [SetFlagByte] ( #02 )
    COP [PrintDialogString] ( &dialogstring_05CF61 )
    RTL 
}

code_05CF5C {
    COP [PrintDialogString] ( &dialogstring_05D223 )
    RTL 
}

dialogstring_05CF61 `[TPL:A][TPL:4]ロブ:[N]自分が だれだか わからないって[N]なんだか 不思議だよ···[FIN]オレが だれだか わからないのに[N]オレは なんで ここにいるんだろ.[PAL:0][END]`

dialogstring_05CFB8 `[TPL:A][TPL:4]ロブ:[N]ここは どこなんだろう···[FIN][TPL:1]カレン:[N]なんだか とっても なつかしい[N]感じがするわ···[FIN][TPL:3]エリック:[N]まるで お母さんの おなかの中に[N]いるような感じ···[FIN][TPL:2]リリィ: 生まれてから 今までに[N]起こったことや 出会った人たちが[N]つぎつぎと 頭にうかんでくる···[FIN][TPL:4]ロブ:[N]おれは サウスケープの町で育った[FIN]そして おやじは 探険にいったまま[N]もどってこなかったんだっけ···[FIN]自分の中で いちばん 大きい存在が[N]なくなって どうしていいか[N]わからなかったなあ···[FIN][TPL:1]カレン: あたしは お父さまが[N]他の国へ 兵隊を使って[N]せめていくのが たまらなかった.[FIN]人が 死ぬのって 大変なことよね.[FIN]何年もかけて つみあげてきたもの[N]が いっしゅんで なくなっちゃうん[N]だもの.[FIN][TPL:3]エリック:[N]モリスも やっぱり 死んじゃった[N]のかな···?[FIN][TPL:2]リリィ:[N]人って いやなことを忘れられるから[N]生きていけるんだよね···[PAL:0][END]`

dialogstring_05D19D `[TPL:A][TPL:4]ロブ: あれ?[N]おれ 今まで 何してたんだろう.[FIN]それに みんな どうしたんだ?[FIN][TPL:2]リリィ:[N]ロブ! きおくが もどったんだっ![FIN][TPL:1]カレン:[N]もう! 心配したんだからあ!![FIN][TPL:3]エリック:[N]どうなることかと思ったようっ.[PAL:0][END]`

dialogstring_05D223 `[TPL:B][TPL:4]ロブ:[N]みんなに 心配かけちゃったな.[N]でも 今度 だれかが 同じ立場に[N]なったら かんびょうするからさ.[PAL:0][END]`

actor_def_05D268 [
  actor-def < #0C, #00, #10, {

  code_05D26B:
    COP [BranchIfFlagByte] ( #65, #00, &code_05D27A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05D283 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D27A {
    COP [Die]

  loc_05D27C:
    COP [SetOnInteract] ( &code_05D28E )
    COP [SetEntryContinue]
    RTL 
}

code_05D283 {
    COP [BranchIfFlagByte] ( #68, #01, &code_05D28E )
    COP [PrintDialogString] ( &dialogstring_05D2CB )
    RTL 
}

code_05D28E {
    COP [PrintDialogString] ( &dialogstring_05D31E )
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
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0254, #$02D4, #00, #0C )
    COP [QueueMapChange] ( #49, #$0050, #$00D0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_05D2CB `[TPL:A][TPL:3]エリック: テムたちと[N]無事に再会できたっていうのに[N]うれしなみだも 出てこないや.[FIN]ぼくの なみだってば[N]かれちゃったのかなぁ···[PAL:0][END]`

dialogstring_05D31E `[TPL:A][TPL:3]エリック: あのさ.[N]近くの森に かわり者の 発明家が[N]いるらしいんだけど 行ってみない?[FIN]ニールっていう 名前の人らしいん[N]だけど···[FIN][TPL:0]テム:[N]ニールだって?!!![FIN]それ 行方不明になっている ボクの[N]いとこと 同じ名前じゃないかっ!![FIN]いとこのニールも 発明家で[N]大空を鳥のようにまう エアプレイン[N]っていう のり物まで発明したんだ.[FIN][PAL:0]そして テムたちー行は 森の中の[N]発明家の家へ 向かうのであった.[END]`

code_05D426 {
    COP [SpawnAfterFlags] ( @code_05D440, #$0B01 )
    COP [RngByte]
    AND #$0003
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #0F, #01, &code_05D426 )
    COP [Die]
}

code_05D440 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePriority] ( #30 )
    LDA #$0200
    STA $16
    COP [RngByte]
    CLC 
    ADC #$0100
    STA $14
    AND #$0003
    BEQ loc_05D47B
    DEC 
    BEQ loc_05D472
    DEC 
    BEQ loc_05D469
    COP [StageSpriteLoopMoveY] ( #02, #10, #04 )
    COP [AnimLoop]
    COP [Die]

  loc_05D469:
    COP [StageSpriteLoopMoveY] ( #02, #08, #08 )
    COP [AnimLoop]
    COP [Die]

  loc_05D472:
    COP [StageSpriteLoopMoveY] ( #02, #06, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_05D47B:
    COP [StageSpriteLoopMoveY] ( #02, #04, #10 )
    COP [AnimLoop]
    COP [Die]
}

actor_def_05D484 [
  actor-def < #0A, #00, #10, {

  code_05D487:
    COP [BranchIfFlagByte] ( #65, #01, &code_05D4B3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05D4B5 )
    COP [ExitIfFlagByte] ( #65, #01 )
    COP [ClearLowHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #10, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #06, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05D4B3 {
    COP [Die]
}

code_05D4B5 {
    COP [PrintDialogString] ( &dialogstring_05D4CC )
    COP [SetFlagByte] ( #57 )
    COP [SetFlagByte] ( #58 )
    COP [SetFlagByte] ( #64 )
    COP [SetFlagByte] ( #65 )
    LDA #$0007
    STA $0AA6
    RTL 
}

dialogstring_05D4CC `[TPL:E][TPL:3]エリック:[N]まさか テムが 助けにきてくれる[N]なんてっ!![FIN]しかし ドアをやぶって 入ってくる[N]とは 思わなかったよ.[FIN]さっきの男は びっくりして[N]にげちゃった.[FIN]ボクね 収容所に しのびこんで[N]ドレイの3人兄弟を 助けようと[N]したんだ.[FIN]そしたら 見つかっちゃって[N]こんなことに なっちゃって···[FIN]ドレイたちは みんな[N]ダイヤモンド鉱山で 働かされて[N]いるみたい.[FIN]場所を 教えるから[N]助けにいってあげてよ.[FIN]テムは 鉱山の場所を 聞いた![N][PAL:0][END]`

actor_def_05D5DA [
  actor-def < #22, #02, #10, {

  code_05D5DD:
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_05D5E6 [
  actor-def < #22, #02, #10, {

  code_05D5E9:
    COP [WaitWhileOffscreen] ( #06 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_05D5F2 [
  actor-def < #24, #02, #10, {

  code_05D5F5:
    COP [AddPosition] ( #08, #00 )
    COP [WaitWhileOffscreen] ( #07 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_05D602 [
  actor-def < #26, #00, #10, {

  code_05D605:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D613 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D613 {
    COP [BranchIfFlagByte] ( #53, #01, &code_05D625 )
    COP [GiveItem] ( #06, &code_05D626 )
    COP [SetFlagByte] ( #53 )
    COP [PrintDialogString] ( &dialogstring_05D62B )
}

code_05D625 {
    RTL 
}

code_05D626 {
    COP [PrintDialogString] ( &dialogstring_05D639 )
    RTL 
}

dialogstring_05D62B `[DEF]藥草を 見つけた![END]`

dialogstring_05D639 `[DEF]藥草を 見つけた![N]しかし 持ち物がいっぱいだった.[END]`

actor_def_05D65A [
  actor-def < #25, #00, #10, {

  code_05D65D:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D66B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D66B {
    COP [BranchIfFlagByte] ( #54, #01, &code_05D67B )
    COP [SetFlagByte] ( #54 )
    COP [PrintDialogString] ( &dialogstring_05D67C )
    INC $playerMaxHp
}

code_05D67B {
    RTL 
}

dialogstring_05D67C `[DEF]HP(体力)の宝石を 見つけた![END]`

actor_def_05D693 [
  actor-def < #01, #00, #18, {

  code_05D696:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [SetSpritePriority] ( #20 )
    COP [BranchIfPlayerNear] ( #01, &code_05D6B6 )

  loc_05D6A8:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05D6CF )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D6B6 {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh2] ( #0E )
    LDA #$CFF0
    TRB $joypadMaskStd
    BRA loc_05D6A8
}

code_05D6CF {
    COP [PrintDialogString] ( &dialogstring_05D6D4 )
    RTL 
}

dialogstring_05D6D4 `[DEF]テム:[N]うちがわから カギがかかっている[N]ようだな···[END]`

actor_def_05D6F6 [
  actor-def < #0F, #01, #01, {

  code_05D6F9:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    SEP #$20
    STZ $0A01
    REP #$20
    COP [SetHitCallback] ( &code_05D726 )
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D726 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    SEP #$20
    INC $0A01
    REP #$20
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
}

actor_def_05D73C [
  actor-def < #00, #00, #30, {

  code_05D73F:
    COP [BranchIfFlagWord] ( #$0121, #01, &code_05D761 )
    COP [SetEntryContinue]
    LDA $0A01
    AND #$00FF
    CMP #$0004
    BEQ loc_05D754
    RTL 

  loc_05D754:
    COP [SetFlagWord] ( #$0121 )
    COP [StageBgChange] ( #21 )
    COP [ApplyBgChange]
    COP [PlaySoundBoth] ( #$0E0E )
} >
]

code_05D761 {
    COP [MarkDeath]
    RTL 
}

actor_def_05D764 [
  actor-def < #28, #00, #10, {

  code_05D767:
    COP [BranchIfFlagByte] ( #5E, #01, &code_05D793 )
    COP [SpawnAfterFlags] ( @code_05DB4E, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D795 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D78C
    RTL 

  loc_05D78C:
    COP [SetOnInteract] ( &code_05D79A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D793 {
    COP [Die]
}

code_05D795 {
    COP [PrintDialogString] ( &dialogstring_05D79F )
    RTL 
}

code_05D79A {
    COP [PrintDialogString] ( &dialogstring_05D7BF )
    RTL 
}

dialogstring_05D79F `[DEF][TPL:5]イムス:[N]どうか くさりを 切って下さいっ![PAL:0][END]`

dialogstring_05D7BF `[DEF][TPL:5]イムス: ありがとう.[N]ぼくらの こきょうでは 生き物が[N]みな おかしく なってきて[N]いるんです.[FIN]石に 変わってしまう人や[N]原因不明の 病気で死ぬ人も[N]後を たちません···[PAL:0][END]`

actor_def_05D82D [
  actor-def < #28, #00, #10, {

  code_05D830:
    COP [BranchIfFlagByte] ( #5E, #01, &code_05D793 )
    COP [SpawnAfterFlags] ( @code_05DB4E, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D85C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D855
    RTL 

  loc_05D855:
    COP [SetOnInteract] ( &code_05D861 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D85C {
    COP [PrintDialogString] ( &dialogstring_05D866 )
    RTL 
}

code_05D861 {
    COP [PrintDialogString] ( &dialogstring_05D885 )
    RTL 
}

dialogstring_05D866 `[DEF][TPL:5]レムス[N]どうか くさりを 切って下さいっ![PAL:0][END]`

dialogstring_05D885 `[DEF][TPL:5]レムス: ありがとう.[N]ぼくらの こきょうの村は[N]海をこえた はるか 遠くの場所.[FIN]もし おとずれることが あったら[N]村人たちの 力になってあげて[N]ください.[PAL:0][END]`

actor_def_05D8E4 [
  actor-def < #28, #00, #10, {

  code_05D8E7:
    COP [BranchIfFlagByte] ( #5E, #01, &code_05D793 )
    COP [SpawnAfterFlags] ( @code_05DB4E, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D95A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D90C
    RTL 

  loc_05D90C:
    COP [SetOnInteract] ( &code_05D95F )
    COP [ExitIfFlagByte] ( #5E, #01 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1E )
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_05D932
    RTL 

  loc_05D932:
    COP [BranchIfNoItem] ( #08, &code_05D947 )
    COP [PrintDialogString] ( &dialogstring_05DABD )
    COP [RemoveItem] ( #02 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D947 {
    COP [PrintDialogString] ( &dialogstring_05DA3B )
    COP [RemoveItem] ( #02 )
    COP [RemoveItem] ( #08 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_05D95A {
    COP [PrintDialogString] ( &dialogstring_05D981 )
    RTL 
}

code_05D95F {
    COP [BranchIfFlagByte] ( #5E, #01, &code_05D97C )
    COP [PrintDialogString] ( &dialogstring_05D9A0 )
    COP [BranchIfFlagByte] ( #5E, #01, &code_05D977 )
    COP [GiveItem] ( #0D, &code_05D978 )
    COP [SetFlagByte] ( #5E )
}

code_05D977 {
    RTL 
}

code_05D978 {
    JML $@chunk_008000.code_00CAD3
}

code_05D97C {
    COP [PrintDialogString] ( &dialogstring_05DB34 )
    RTL 
}

dialogstring_05D981 `[DEF][TPL:5]サムス[N]どうか くさりを 切って下さいっ![PAL:0][END]`

dialogstring_05D9A0 `[DEF][TPL:5]サムス[N]ありがとう.[FIN]エリックくんから 聞きましたが[N]あなたたちの仲間が きおくそうしつ[N]になっているそうですね.[FIN]ぼくらの部族に伝わる むかしを[N]思い出す歌が あります.[N]この歌を 聞かせてあげて下さい.[FIN]サムスは 不思議なメロディを[N]口ずさんだ.[PAL:0][END]`

dialogstring_05DA3B `[DEF]思い出のメロディを おぼえた![FIN][TPL:5]サムス:[N]ひとつ お願いがあるんですが···[FIN]あなたと 出会えた 思い出に[N]ろうごくのカギと 風のメロディを[N]いただいて いいですよね.[FIN]きっと 今後 使うことは[N]ないはずですから.[END]`

dialogstring_05DABD `[DEF]思い出のメロディを おぼえた![FIN][TPL:5]サムス:[N]ひとつ お願いがあるんですが···[FIN]あなたと 出会えた 思い出に[N]ろうごくのカギを いただいて[N]いいですよね.[FIN]きっと 今後 使うことは[N]ないはずですから.[END]`

dialogstring_05DB34 `[DEF][TPL:5]あなたのことは ー生忘れませんよ.[PAL:0][END]`

code_05DB4E {
    LDA #$0030
    TSB $12
    COP [OrActorFlags] ( #$0080 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_05DB5F [
  actor-def < #02, #01, #10, {

  code_05DB62:
    COP [BranchIfFlagByte] ( #5D, #01, &code_05DB94 )
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05DB80 )

  loc_05DB76:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    BRA loc_05DB76
} >
]

code_05DB80 {
    COP [GiveItem] ( #0B, &code_05DB96 )
    COP [SetFlagByte] ( #5D )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @dialogstring_05DB9B )
}

code_05DB94 {
    COP [Die]
}

code_05DB96 {
    COP [PrintDialogString] ( &dialogstring_05DBB4 )
    RTL 
}

dialogstring_05DB9B `[DEF][SFX:0][DLY:9]鉱山のカギを 見つけた![PAU:FF][END]`

dialogstring_05DBB4 `[DEF]鉱山のカギを 見つけた![N]しかし 持ち物が いっぱいだった.[END]`

actor_def_05DBDB [
  actor-def < #35, #01, #30, {

  code_05DBDE:
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05DBFE )
    COP [ExitIfFlagByte] ( #5B, #01 )
    COP [ExitIfFlagByte] ( #5C, #01 )
    COP [StageBgChange] ( #7A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$017A )
    COP [Die]
} >
]

code_05DBFE {
    COP [BranchIfNoItem] ( #0B, &code_05DC05 )
    BRA loc_05DC0A
}

code_05DC05 {
    COP [BranchIfNoItem] ( #0C, &code_05DC20 )

  loc_05DC0A:
    COP [BranchIfFlagByte] ( #5B, #01, &code_05DC1B )
    COP [BranchIfFlagByte] ( #5C, #01, &code_05DC1B )
    COP [PrintDialogString] ( &dialogstring_05DC46 )
    RTL 
}

code_05DC1B {
    COP [PrintDialogString] ( &dialogstring_05DC5D )
    RTL 
}

code_05DC20 {
    COP [PrintDialogString] ( &dialogstring_05DC83 )
    COP [DialogueOptions] ( #02, #02, &code_list_05DC2A )
}

code_list_05DC2A [
  &code_05DC30   ;00
  &code_05DC35   ;01
  &code_05DC30   ;02
]

code_05DC30 {
    COP [PrintDialogString] ( &dialogstring_05DCB5 )
    RTL 
}

code_05DC35 {
    COP [PrintDialogString] ( &dialogstring_05DCB7 )
    COP [RemoveItem] ( #0B )
    COP [RemoveItem] ( #0C )
    COP [SetFlagByte] ( #5B )
    COP [SetFlagByte] ( #5C )
    RTL 
}

dialogstring_05DC46 `[DEF]カギ穴が 二つ ついているようだ.[END]`

dialogstring_05DC5D `[DEF]カギを 二つとも 開けないと[N]とびらは 開きそうにないな···[END]`

dialogstring_05DC83 `[DEF]カギは 二つとも もっている···[N]カギ穴に さしこんでみますか?[N] はい[N] いいえ`

dialogstring_05DCB5 `[CLD]`

dialogstring_05DCB7 `[CLR]カギが 不気味な音をたてて[N]まわった.[END]`

actor_def_05DCD2 [
  actor-def < #24, #00, #20, {

  code_05DCD5:
    COP [BranchIfFlagWord] ( #$0132, #01, &code_05DCE1 )
    COP [ExitIfFlagWord] ( #$0132, #01 )
} >
]

code_05DCE1 {
    COP [SpawnAfterFlags] ( @chunk_088000.code_08D1C3, #$0B00 )
    LDA #$0001
    STA $0024, Y
    LDA #$2000
    STA $000E, Y
    COP [Die]
}

actor_def_05DCF6 [
  actor-def < #35, #01, #30, {

  code_05DCF9:
    COP [AddPosition] ( #08, #FE )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05DD15 )
    COP [ExitIfFlagByte] ( #69, #01 )
    COP [StageBgChange] ( #7B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$017B )
    COP [Die]
} >
]

code_05DD15 {
    COP [BranchIfEquipped] ( #0F, &code_05DD1F )
    COP [PrintDialogString] ( &dialogstring_05DD2A )
    RTL 
}

code_05DD1F {
    COP [SetFlagByte] ( #69 )
    COP [RemoveItem] ( #0F )
    COP [PrintDialogString] ( &dialogstring_05DD49 )
    RTL 
}

dialogstring_05DD2A `[DEF]このとびらには カギ穴が ひとつ[N]ついているようだ.[END]`

dialogstring_05DD49 `[DEF]リフトのり場のカギを 使った![END]`

actor_def_05DD60 [
  actor-def < #36, #01, #10, {

  code_05DD63:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05DD71 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05DD71 {
    COP [PrintDialogString] ( &dialogstring_05DD76 )
    RTL 
}

dialogstring_05DD76 `[DEF](リフトのり場 入り口)[N]リフトには そこの とびらより[N]向かうこと.[END]`

actor_def_05DDA3 [
  actor-def < #30, #00, #00, {

  code_05DDA6:
    LDA #$0011
    TSB $12

  loc_05DDAB:
    COP [WaitWhileOffscreen] ( #0D )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @chunk_0A8000.code_0AD9FA, #00, #CE, #$0202 )
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_05DDAB

  loc_05DDCB:
    TSB $1000
    RTL 
} >
]

actor_def_05DDCF [
  actor-def < #00, #00, #01, {

  code_05DDD2:
    COP [BranchIfFlagByte] ( #D9, #01, &code_05DE2F )
    COP [SpawnAfterFlags] ( @code_05DE64, #$1000 )
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12

  loc_05DDF9:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_05DE1B
    COP [BranchIfPlayerInAbsTiles] ( #08, #14, #0A, #17, &code_05DE17 )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_05DE17 {
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_05DE1B:
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_05DE28
    DEC $24
    BMI loc_05DDF9
    RTL 

  loc_05DE28:
    COP [SpawnAfterFlags] ( @chunk_008000.dialogstring_00CB00, #$3000 )
}

code_05DE2F {
    COP [SetFlagByte] ( #D9 )
    COP [DrawMetatileAbs] ( #08, #11, #D5 )
    COP [DrawMetatileAbs] ( #09, #11, #D4 )
    COP [DrawMetatileAbs] ( #08, #12, #EC )
    COP [DrawMetatileAbs] ( #09, #12, #DC )
    COP [DrawMetatileAbs] ( #08, #13, #F4 )
    COP [DrawMetatileAbs] ( #09, #13, #E4 )
    COP [DrawMetatileAbs] ( #08, #14, #02 )
    COP [DrawMetatileAbs] ( #09, #14, #02 )
    COP [SolidHighAbs] ( #08, #13 )
    COP [SolidHighAbs] ( #09, #13 )
    COP [Die]
}

code_05DE64 {
    COP [AddPosition] ( #08, #00 )
    LDA #$2000
    TSB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #D9, #01 )
    LDA #$2000
    TRB $10
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0003
    STA $jewelsCollected
    CLD 
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_05DEAF )
    LDA #$EFF0
    TRB $joypadMaskStd
    LDA #$0080
    TSB $09FA
    COP [StageSpriteLoopMoveY] ( #0D, #08, #01 )
    COP [AnimLoop]
    LDA #$0080
    TRB $09FA
    COP [Die]
}

dialogstring_05DEAF `[DEF]ありがとう ございます.[N]落ばんで 生きうめになって[N]いたんです···[FIN]もうちょっと おそかったら[N]どうなっていたことか···[FIN]私からの ほんの 気持ちを[N]プレゼントさせてください.[N]後で 宝石商さんの ところへ[N]赤い宝石を3つ送っておきますね.[END]`

actor_def_05DF3B [
  actor-def < #13, #00, #10, {

  code_05DF3E:
    COP [SpawnAfterFlags] ( @code_05E373, #$2000 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E010 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0098
    STA $0014, Y
    LDA #$0100
    STA $0016, Y
    COP [WaitByte] ( #1D )
    COP [LoopInit] ( #02 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [WaitByte] ( #13 )
    COP [LoopNext]
    COP [PrintDialogString] ( &dialogstring_05E025 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [WaitByte] ( #1D )
    LDY $decelStepCounter
    LDA #$0085
    STA $0002, Y
    LDA #$DFE3
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [StageSpriteLoop] ( #15, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #3C )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05E070 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [PrintDialogString] ( &dialogstring_05E0BD )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [PrintDialogString] ( &dialogstring_05E166 )
    LDA #$0000
    STA $0AA6
    COP [SetFlagByte] ( #05 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_05DFE3 {
    COP [LoopInit] ( #03 )
    COP [StagePlayerMoveY] ( #09, #02 )
    COP [AnimOnce]
    COP [LoopNext]
    LDY $decelStepCounter
    LDA #$0082
    STA $0002, Y
    LDA #$D01B
    STA $0000, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y
    RTL 
}

code_05E010 {
    LDA $0AA6
    CMP #$000F
    BEQ loc_05E01D
    COP [PrintDialogString] ( &dialogstring_05E1B3 )
    RTL 

  loc_05E01D:
    COP [PrintDialogString] ( &dialogstring_05E22A )
    COP [SetFlagByte] ( #06 )
    RTL 
}

dialogstring_05E025 `[PAU:1E][TPL:A][TPL:6]ニール:[N]開いてるから かってに[N]はいんなっ.[FIN][TPL:0]テム:[N]ニール. ぼくだよ.[N]サウスケープの町の テムだよ.[END]`

dialogstring_05E070 `[TPL:A][TPL:6]ニール:[N]おおっ! テムじゃないかっ!![N]ずいぶん たくましく なったな.[FIN]それに ずいぶん ぞろぞろいるけど[N]テムの友達かい?[END]`

dialogstring_05E0BD `[TPL:A][TPL:6]ニール: おいおい.[N]二人とも ずいぶん はっきり 物を[N]言う おじょうさんだね.[FIN]ずっと 発明に ぼっとうしていると[N]身なりにかまわなくなっちまうのさ.[FIN]でも 人に きらわれるほど[N]ひどい においじゃないと[N]思うけどなあ.[FIN]この くつ下だって[N]はきはじめてから まだ ーか月しか[N]たってないんだぜ.[END]`

dialogstring_05E166 `[TPL:A][TPL:6]ニール:[N]だからっ くつ下の話は もう[N]いいんだよっ.[FIN]まあ とにかく くつろいでくれ.[N]テムの友達だもんな.[N]かんげいするよ.[END]`

dialogstring_05E1B3 `[TPL:A][TPL:6]ニール:[N]この前 テムに会ってから 2年[N]くらいたつのかな?[FIN]あれから ずいぶん いろんな[N]発明をしたよ. [FIN]この部屋には ぼくの自信作の[N]発明品が 4つばかり置かれている.[N]さがしてごらん.[END]`

dialogstring_05E22A `[TPL:A][TPL:6]それで ぼくに 何か 用があって[N]来たんだろ? 話してごらん.[FIN][TPL:0]テムは これまでの できごとや[N]行方不明の 父親の声を聞いたこと,[FIN]世界中の イセキをめぐって[N]ミステリードールを探していることを[N]ニールに 話した.[FIN][TPL:6]ニール:[N]ほほお.[N]なかなか おもしろい話だなあ.[FIN]ぼくも イセキには ちょっとばかり[N]きょうみが あってね.[FIN]今 テムが 話してくれた イセキは[N]世界中に ちらばっているけど[N]不思議な 共通点が あるんだ.[FIN]世界地図の上で 今のイセキ同士を[N]線でむすぶと なんと きょだいな[N]白鳥座の形に なるんだよ.[END]`

code_05E373 {
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$00D0
    BEQ loc_05E37E
    RTL 

  loc_05E37E:
    COP [BranchIfButton] ( #$0400, &code_05E385 )
    RTL 
}

code_05E385 {
    COP [PrintDialogString] ( &dialogstring_05E38A )
    RTL 
}

dialogstring_05E38A `[TPL:A][TPL:6]ニール: テム どこへ行くんだ?[N]せっかく きたんだし もっと[N]ゆっくり していけよ.[PAL:0][END]`

actor_def_05E3C1 [
  actor-def < #23, #00, #10, {

  code_05E3C4:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E440 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #27, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #28, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [PrintDialogString] ( &dialogstring_05E445 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05E464 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #28, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #07, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #29, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05E4CD )

  loc_05E424:
    COP [DialogueOptions] ( #02, #01, &code_list_05E42A )
} >
]

code_list_05E42A [
  &code_05E430   ;00
  &code_05E436   ;01
  &code_05E430   ;02
]

code_05E430 {
    COP [PrintDialogString] ( &dialogstring_05E5F9 )
    BRA loc_05E424
}

code_05E436 {
    COP [PrintDialogString] ( &dialogstring_05E627 )
    COP [SetFlagByte] ( #08 )
    COP [SetEntryContinue]
    RTL 
}

code_05E440 {
    COP [PrintDialogString] ( &dialogstring_05E640 )
    RTL 
}

dialogstring_05E445 `[TPL:A][TPL:1]カレン:[N]この人 なんだか くさああい···[FIN]`

dialogstring_05E464 `[TPL:A][CLR][TPL:2]リリィ: なんてこと言うのっ![N]そおいうことは もっと 言い方って[N]いうものがあるでしょっ!![FIN]この部屋は 鼻が ねじまがるくらい[N]素敵なかおりが ただよってますねぇ[N]とかさぁ.[END]`

dialogstring_05E4CD `[TPL:A][TPL:2]リリィ: そういえばさあ[N]近ごろ 白鳥座の下の方に 赤い星がーつ ふえてるんだよ···[FIN][TPL:6]ニール:[N]そのとおりっ![N]よく 知ってるね!![FIN]白鳥座の 赤い星の出現といい,[N]テムの イセキの話といい,[FIN]いろんな要素が 有機的に結びつき[N]すぎている···[FIN]ぐう然のいっちなのか だれかの[N]たくらみなのかは わからないが[N]何かが起ころうとしてるのは事実だ.[FIN]そして 都合のいいことに ここから[N]東へ ー週間ほど歩いたところに[N]ナスカの地上絵のさばくがあるんだ.[FIN][::]行ってみるかい?[N] はい[N] いいえ`

dialogstring_05E5F9 `[CLR][TPL:6]ニール:[N]そう 言わないでくれよ.[N]実は ぼくの方が いきたいんだよ[FIN][JMP:&chunk_058000.dialogstring_05E4CD+M]`

dialogstring_05E627 `[CLR][TPL:6]ニール:[N]よしっ! 決まりだな.[PAL:0][END]`

dialogstring_05E640 `[TPL:A][TPL:2]リリィ:[N]テムのいとこじゃ 悪口いえないけど[N]これが 発明家ねえ···[PAL:0][END]`

actor_def_05E673 [
  actor-def < #1B, #00, #10, {

  code_05E676:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E6DC )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteLoop] ( #1D, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #14 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05E6E1 )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05E71B )
    COP [SetFlagByte] ( #07 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E6DC {
    COP [PrintDialogString] ( &dialogstring_05E6E1 )
    RTL 
}

dialogstring_05E6E1 `[TPL:A][TPL:1]カレン:[N]この人たちってば 信じらんないっ![FIN]もう 同じ空気を 吸ってるのも[N]やだわっ!![END]`

dialogstring_05E71B `[TPL:A][TPL:1]カレン:[N]白鳥座ですって?![FIN][TPL:6]ニール: そう. それに テムの[N]おやじさんが 行方不明になったって[N]いう バベルの塔はさ,[FIN]その きょだいな白鳥の ちょうど[N]中心に 位置することになるんだ.[END]`

actor_def_05E797 [
  actor-def < #03, #00, #10, {

  code_05E79A:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E83E )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #05, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05E843 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighOffset] ( #00, #01 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05E86F )
    COP [SetFlagByte] ( #6D )
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
    COP [StageWorldMapMove] ( #$0274, #$0264, #00, #0D )
    COP [QueueMapChange] ( #4B, #$0120, #$0080, #00, #$4400 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E83E {
    COP [PrintDialogString] ( &dialogstring_05E843 )
    RTL 
}

dialogstring_05E843 `[TPL:A][TPL:4]ロブ:[N]オレ 3週間っていう きろくが[N]あるけど 負けてるなあ.[END]`

dialogstring_05E86F `[TPL:A][TPL:4]ロブ: おれたちも 行くぜっ![N]テムばっかりに 楽しい思いは[N]させられないさ.[FIN][PAL:0]ー行は ナスカのさばくへと[N]向かうのであった···[END]`

actor_def_05E8C3 [
  actor-def < #0B, #00, #10, {

  code_05E8C6:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E8F7 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E8F7 {
    COP [PrintDialogString] ( &dialogstring_05E8FC )
    RTL 
}

dialogstring_05E8FC `[TPL:A][TPL:3]エリック:[N]この発明品を モリスが見たら[N]よろこぶだろうなぁ···[END]`

actor_def_05E92A [
  actor-def < #00, #00, #30, {

  code_05E92D:
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05E93E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E93E {
    COP [PrintDialogString] ( &dialogstring_05E94C )
    LDA $0AA6
    ORA #$0001
    STA $0AA6
    RTL 
}

dialogstring_05E94C `[TPL:A][TPL:6]ニール:[N]それは さんそボンベ.[N]中には 空気が入っているのさ.[FIN]それをつければ 水の中でも[N]息が できるんだけど 空気が[N]1分くらいしか もたないんだ.[FIN]空気を 圧縮できれば[N]長時間 もぐれるんだろうけど[N]その方法が 思いつかないんだよ.[PAL:0][END]`

actor_def_05E9E3 [
  actor-def < #00, #00, #30, {

  code_05E9E6:
    COP [AddPosition] ( #08, #00 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05E9FB )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E9FB {
    COP [PrintDialogString] ( &dialogstring_05EA09 )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    RTL 
}

dialogstring_05EA09 `[TPL:A][TPL:6]ニール:[N]それは エアプレインのつばさ.[FIN]鳥のように 空を飛びたいっていう[N]人類の夢を かなえてくれる 素敵な[N]機械の ー部だよ.[FIN]本体は あまりに 大きいうえに[N]飛び立つには かっ走路がいるんで[N]今は さばくに かくしてある.[PAL:0][END]`

actor_def_05EA9A [
  actor-def < #00, #00, #30, {

  code_05EA9D:
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05EAAE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05EAAE {
    COP [PrintDialogString] ( &dialogstring_05EABC )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    RTL 
}

dialogstring_05EABC `[TPL:A][TPL:6]それは ぼうえんきょう.[N]天空の星が 手にとるように[N]見えるんだ.[PAL:0][END]`

actor_def_05EAE9 [
  actor-def < #00, #00, #30, {

  code_05EAEC:
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05EAFD )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05EAFD {
    COP [PrintDialogString] ( &dialogstring_05EB0B )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    RTL 
}

dialogstring_05EB0B `[TPL:A][TPL:6]それは カメラ. 景色を[N]そっくりそのまま 印画紙に[N]燒きつけることができる機械さ.[FIN]欠点は 写すのに[N]30分近く かかることなんだ.[FIN]景色は 動かないからいいけど[N]人を 写す場合は 30分もの間[N]まばたきも しちゃいけない.[FIN]この機械を作ったときは おかげで[N]目が ウサギのように 真っ赤に[N]なってしまったよ.[PAL:0][END]`

actor_def_05EBCE [
  actor-def < #00, #00, #30, {

  code_05EBD1:
    COP [SpawnAfterFlags] ( @code_05ED4A, #$2000 )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05EC34 )
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    LDA #$00E0
    STA $orbitAngle, X
    COP [LoopInit] ( #08 )
    LDA $orbitAngle, X
    SEP #$20
    STA $COLDATA
    REP #$20
    INC 
    STA $orbitAngle, X
    COP [WaitByte] ( #1F )
    COP [LoopNext]
    COP [PrintDialogString] ( &dialogstring_05ECC2 )
    COP [SetFlagByte] ( #0C )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_05ED20, #$0300 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_05ECEF )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #4C, #$0168, #$0040, #83, #$2200 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05EC34 {
    COP [BranchIfFlagByte] ( #0B, #00, &code_05EC42 )
    COP [PrintDialogString] ( &dialogstring_05EC47 )
    COP [SetFlagByte] ( #0F )
    RTL 
}

code_05EC42 {
    COP [PrintDialogString] ( &dialogstring_05EC95 )
    RTL 
}

dialogstring_05EC47 `[DEF][TPL:0]砂のなかに 何か タイルのような[N]ものが うまっている···[FIN]テムのフエが ふれたとたん 何か[N]ごうおんが とどろきはじめた![PAL:0][END]`

dialogstring_05EC95 `[DEF][TPL:6]ニール:[N]テムっ! まだ調べるな![N]何が あるかわからないぞっ!![PAL:0][END]`

dialogstring_05ECC2 `[DEF][TPL:3]エリック:[N]わあっ! 上から何かでっかいものが[N]おりてくるようっ!!![PAL:0][END]`

dialogstring_05ECEF `[TPL:E][TPL:1]カレン:[N]きゃあっ! テムっ!![N]テムーーーーーーーーーーっ!!![PAL:0][PAU:28][CLD]`

code_05ED20 {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$0C0C )
    COP [SetFlagByte] ( #0D )
    COP [SetEntryContinue]
    RTL 
}

code_05ED4A {
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0014, Y
    CMP #$0008
    BEQ loc_05ED6A
    CMP #$03F8
    BEQ loc_05ED71
    LDA $0016, Y
    CMP #$0020
    BEQ loc_05ED78
    CMP #$0400
    BEQ loc_05ED7F
    RTL 

  loc_05ED6A:
    COP [BranchIfButton] ( #$0200, &code_05ED86 )
    RTL 

  loc_05ED71:
    COP [BranchIfButton] ( #$0100, &code_05ED86 )
    RTL 

  loc_05ED78:
    COP [BranchIfButton] ( #$0800, &code_05ED86 )
    RTL 

  loc_05ED7F:
    COP [BranchIfButton] ( #$0400, &code_05ED86 )
    RTL 
}

code_05ED86 {
    COP [PrintDialogString] ( &dialogstring_05ED8B )
    RTL 
}

dialogstring_05ED8B `[DEF][TPL:0]テム:[N]ナスカ平原は 広いらしいし あまり[N]遠くへ 行かないほうがいいな···[PAL:0][END]`

actor_def_05EDC1 [
  actor-def < #12, #00, #10, {

  code_05EDC4:
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05EE77 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_05EE3E )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetOnInteract] ( &code_05EE43 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [CallScript] ( &code_05EE4B )
    COP [SetOnInteract] ( &code_05EE72 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #16, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #16, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetFlagByte] ( #0B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05EE3E {
    COP [PrintDialogString] ( &dialogstring_05EF5A )
    RTL 
}

code_05EE43 {
    COP [PrintDialogString] ( &dialogstring_05EF8A )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_05EE4B {
    COP [PrintDialogString] ( &dialogstring_05F0C5 )

  loc_05EE4F:
    COP [PrintDialogString] ( &dialogstring_05F100 )
    COP [DialogueOptions] ( #04, #00, &code_list_05EE59 )
}

code_list_05EE59 [
  &code_05EE63   ;00
  &code_05EE63   ;01
  &code_05EE63   ;02
  &code_05EE69   ;03
  &code_05EE63   ;04
]

code_05EE63 {
    COP [PrintDialogString] ( &dialogstring_05F15A )
    BRA loc_05EE4F
}

code_05EE69 {
    COP [PrintDialogString] ( &dialogstring_05F183 )
    COP [SetFlagByte] ( #09 )
    COP [RestoreSavedPtr]
}

code_05EE72 {
    COP [PrintDialogString] ( &dialogstring_05F1CF )
    RTL 
}

dialogstring_05EE77 `[DEF][TPL:6]ニール:[N]遠い道のりだったけど みんな[N]よく がんばったな.[FIN]ここが ナスカの地上絵の中で[N]最も有名な コンドルの絵だよ.[N]聞いたことくらいは あるだろう?[FIN]古代人たちは いったい 何のために[N]こんなものを えがいたのか 今だに[N]わかってないんだ.[FIN]まあ 何にせよ ここへくるたび[N]スケールの でかさには あっとう[N]されるよ.[FIN]まずは みんなも 自分の足で歩いて[N]見てくるといいさ.[PAL:0][END]`

dialogstring_05EF5A `[DEF][TPL:6]ニール:[N]はっはっは.[N]そうあせらず みんなと いっしょに[N]見物しておいで.[PAL:0][END]`

dialogstring_05EF8A `[DEF][TPL:6]ニール:[N]さーて みんな もどったところで[N]本題に入ろう.[FIN]テムの言う ミステリードールは[N]この平原の どこかにあるって[N]わけだろ?[FIN][CLD][PAU:28][DEF][TPL:3]エリック:[N]さっき 地上絵を 見てたとき[N]思ったんだけど,[FIN]この コンドルの絵って なんとなく[N]白鳥の形に 見えないかなあ?[FIN][CLD][PAU:14][DEF][TPL:6]ニール:[N]なるほどっ![N]それは 気づかなかったっ!![FIN]われわれは あの星の ならびを[N]白鳥にたとえているけど[N]ナスカの 古代人たちにとっては[N]コンドルだったのかもしれない···[END]`

dialogstring_05F09D `[DEF][TPL:6]ニール:[N]さーて みんな もどったところで[N]本題に入ろう.[FIN]`

dialogstring_05F0C5 `[DEF][TPL:6]ニール: なるほどっ![N]白鳥座の星の数は 9コ.[N]石の数も たしかに 9コだ···[FIN]`

dialogstring_05F100 `[CLR][TPL:0]すると 最近 見え始めたっていう[N]赤い星の 場所は···?[FIN] コンドルの頭[N] コンドルの右足[N] コンドルの左足[N] コンドルのしっぽ`

dialogstring_05F15A `[CLR][TPL:0]テム: いや まてよ.[N]白鳥座の 下の方だったはずだ···[FIN]`

dialogstring_05F183 `[CLR][TPL:0]テム: そうだっ![N]ちょうど 左足の 関節のあたりだ![FIN][TPL:6]ニール:[N]よしっ![N]その 左足の部分を 調べてみよう![PAL:0][END]`

dialogstring_05F1CF `[DEF][TPL:6]ニール:[N]たまには こういうのもいいな.[N]発明してるときみたいに ドキドキ[N]するよ.[PAL:0][END]`

actor_def_05F205 [
  actor-def < #1B, #00, #10, {

  code_05F208:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F2C0 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F2C5 )
    LDA #$0200
    TSB $12
    COP [ExitIfFlagByte] ( #05, #01 )
    LDA #$0200
    TRB $12
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #1E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #05, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F2CD )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #13, #09 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F2C0 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F2D5 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #1E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #0D, #01 )
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F2C0 {
    COP [PrintDialogString] ( &dialogstring_05F2DA )
    RTL 
}

code_05F2C5 {
    COP [PrintDialogString] ( &dialogstring_05F321 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_05F2CD {
    COP [PrintDialogString] ( &dialogstring_05F375 )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_05F2D5 {
    COP [PrintDialogString] ( &dialogstring_05F3D1 )
    RTL 
}

dialogstring_05F2DA `[DEF][TPL:1]カレン:[N]こんな風に 自然のキャンバスの上に[N]思いっきり おっきい絵を かいたら[N]気持ちいいんだろうなあ.[PAL:0][END]`

dialogstring_05F321 `[DEF][TPL:1]カレン:[N]なんだか こうしてみると 運動会の[N]白線みたい.[FIN]案外 古代ナスカ人たちは[N]ここで 100M走を やっていたり[N]してね.[END]`

dialogstring_05F375 `[DEF][TPL:1]カレン:[N]ここが ちょうど コンドルのお腹の[N]あたりよね.[N]ほったら 卵でも 出てこないかな.[FIN]じょ じょうだんよ(芺)[N]本気にして さがしまわらないでよ.[END]`

dialogstring_05F3D1 `[DEF][TPL:1]カレン:[N]こんなに ドキドキするようなことを[N]たいけんできるなんて···[PAL:0][END]`

actor_def_05F3FF [
  actor-def < #03, #00, #10, {

  code_05F402:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F481 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #06, #0B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #11, #09 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F486 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #06, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F481 {
    COP [PrintDialogString] ( &dialogstring_05F48B )
    RTL 
}

code_05F486 {
    COP [PrintDialogString] ( &dialogstring_05F4F0 )
    RTL 
}

dialogstring_05F48B `[DEF][TPL:4]ロブ:[N]おれ こないだまで 每日 学校へ[N]かよって 勉強したり あそんだり[N]してたんだよな.[FIN]自分が ここにいることは[N]夢なんじゃないかって 思うことが[N]あるよ···[PAL:0][END]`

dialogstring_05F4F0 `[DEF][TPL:4]ロブ:[N]今まで 探険家や 考古学者たちが[N]とけなかったナゾを おれたちが[N]今 あかそうとしてるんだよな··[PAL:0][END]`

actor_def_05F538 [
  actor-def < #23, #00, #10, {

  code_05F53B:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F605 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #26, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F60A )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #10, #09 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F605 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_05F67B )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #08 )
    LDA #$0002
    JSL $@chunk_008000.dialogstring_00C829
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05F6A1 )
    COP [SetFlagByte] ( #0A )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F612 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #07, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #29, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #0D, #01 )
    COP [StageSpriteMoveX] ( #29, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F605 {
    COP [PrintDialogString] ( &dialogstring_05F617 )
    RTL 
}

code_05F60A {
    COP [PrintDialogString] ( &dialogstring_05F647 )
    COP [SetFlagByte] ( #07 )
    RTL 
}

code_05F612 {
    COP [PrintDialogString] ( &dialogstring_05F6E5 )
    RTL 
}

dialogstring_05F617 `[DEF][TPL:2]リリィ:[N]すごいよねえ. 古代の人って.[N]どうやって 書いたんだろ···[PAL:0][END]`

dialogstring_05F647 `[DEF][TPL:2]リリィ: この ところどころに[N]ころがっている石って なんだか[N]不自然じゃない?[PAL:0][END]`

dialogstring_05F67B `[DEF][TPL:2]リリィ:[N]あーーーーーーーーーーっ!![N]わかったっ!!!!![END]`

dialogstring_05F6A1 `[PAU:28][DEF][TPL:2]見て 見てっ![N]この地面にある 石の場所っ!![FIN]これって ぜったい[N]白鳥座の 星の位置だよお![PAL:0][END]`

dialogstring_05F6E5 `[DEF][TPL:2]リリィ:[N]星座の中に ナゾが かくされてる[N]なんて なんだかロマンチックだね.[PAL:0][END]`

actor_def_05F71B [
  actor-def < #0B, #00, #10, {

  code_05F71E:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F78B )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #14, #09 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F790 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F795 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #07, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F78B {
    COP [PrintDialogString] ( &dialogstring_05F79A )
    RTL 
}

code_05F790 {
    COP [PrintDialogString] ( &dialogstring_05F7C4 )
    RTL 
}

code_05F795 {
    COP [PrintDialogString] ( &dialogstring_05F7EE )
    RTL 
}

dialogstring_05F79A `[DEF][TPL:3]エリック:[N]なんだか こわいや···[N]ニールのそばに いよっと.[PAL:0][END]`

dialogstring_05F7C4 `[DEF][TPL:3]エリック:[N]何が おこるんだろう···[N]ワクワクしちゃうなあ.[PAL:0][END]`

dialogstring_05F7EE `[DEF][TPL:3]エリック:[N]何が おこるんだろう···[N]ワクワクしちゃうなあ.[PAL:0][END]`

actor_def_05F818 [
  actor-def < #32, #00, #30, {

  code_05F81B:
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [ExitIfFlagByte] ( #07, #01 )
    LDA #$2000
    TRB $10
    LDA #$0200
    TSB $12
    COP [LoopInit] ( #03 )

  loc_05F830:
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #02, &code_05F83C )
    BRA loc_05F830
} >
]

code_05F83C {
    COP [AddPosition] ( #70, #00 )
    COP [LoopNext]
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #13 )
    COP [PrintDialogString] ( &dialogstring_05F872 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #02 )
    COP [StageSpriteLoopMoveXY] ( #32, #02, #11, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #32, #02, #01, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #32, #0D, #03, #04 )
    COP [AnimLoop]
    COP [Die]
}

dialogstring_05F872 `[DEF]クッククククク····[END]`

actor_def_05F881 [
  actor-def < #3C, #00, #10, {

  code_05F884:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F897 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F897 {
    COP [PrintDialogString] ( &dialogstring_05F89C )
    RTL 
}

dialogstring_05F89C `[DEF]月の種族:[N]また 会ったわね. クッククク.[N]こんなところまで うろうろと[N]元気な ぼうやだこと.[END]`

actor_def_05F8D7 [
  actor-def < #3C, #00, #10, {

  code_05F8DA:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F8ED )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F8ED {
    COP [PrintDialogString] ( &dialogstring_05F8F2 )
    RTL 
}

dialogstring_05F8F2 `[DEF]月の種族:[N]この空中庭園は あたしたちの[N]のりもの.[FIN]4つの地域に 安置される 4つの[N]クリスタルボール.[N]時計まわりに めぐって 手に入れる[N]ことね. クッククク···[END]`

actor_def_05F95C [
  actor-def < #3C, #00, #10, {

  code_05F95F:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F972 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F972 {
    COP [PrintDialogString] ( &dialogstring_05F977 )
    RTL 
}

dialogstring_05F977 `[DEF]月の種族:[N]空中庭園の 裹と表.[N]ガケから とびおりれば そこは[N]もう さかさまの世界···[END]`

dialogstring_05F9B4 `いが┌[A9]がぐご(ぐ[END]`

dialogstring_05F9BE `[RET]`

dialogstring_05F9BF `[F9]ぐぢぐ[DLG:2,80]いぐ[89]ぅぐ[BF][PRT][F9]ぅ[DEF]月の種族:[N]クリスタルバードが 3度 鳴き声を[N]あげるとき 戦いをいどんだら?[END]`

actor_def_05FA01 [
  actor-def < #35, #01, #03, {

  code_05FA04:
    COP [SpawnAfterAbsFlags] ( @code_05FA1F, #$0168, #$00E0, #$2301 )
    COP [BranchIfFlagByte] ( #60, #01, &code_05FA53 )
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #60, #01 )
    BRA loc_05FA4C
} >
]

code_05FA1F {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #60, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

actor_def_05FA30 [
  actor-def < #35, #01, #03, {

  code_05FA33:
    COP [SpawnAfterAbsFlags] ( @code_05FA5D, #$0168, #$0120, #$2301 )
    COP [BranchIfFlagByte] ( #61, #01, &code_05FA53 )
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #61, #01 )

  loc_05FA4C:
    COP [StageSpriteLoopMoveX] ( #35, #80, #12 )
    COP [AnimLoop]
} >
]

code_05FA53 {
    LDA #$0100
    STA $14
    COP [ClearAllHere]
    COP [SetEntryContinue]
    RTL 
}

code_05FA5D {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #61, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

actor_def_05FA6E [
  actor-def < #35, #01, #03, {

  code_05FA71:
    COP [SpawnAfterAbsFlags] ( @code_05FA8C, #$0098, #$00C0, #$2301 )
    COP [BranchIfFlagByte] ( #62, #01, &code_05FAC0 )
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #62, #01 )
    BRA loc_05FAB9
} >
]

code_05FA8C {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #62, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

actor_def_05FA9D [
  actor-def < #35, #01, #03, {

  code_05FAA0:
    COP [SpawnAfterAbsFlags] ( @code_05FACA, #$0098, #$0100, #$2301 )
    COP [BranchIfFlagByte] ( #63, #01, &code_05FAC0 )
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #63, #01 )

  loc_05FAB9:
    COP [StageSpriteLoopMoveX] ( #35, #80, #11 )
    COP [AnimLoop]
} >
]

code_05FAC0 {
    LDA #$0100
    STA $14
    COP [ClearAllHere]
    COP [SetEntryContinue]
    RTL 
}

code_05FACA {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #63, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

actor_def_05FADB [
  actor-def < #0F, #01, #01, {

  code_05FADE:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfFlagWord] ( #$0126, #01, &code_05FB24 )

  code_05FB04:
    COP [SetHitCallback] ( &code_05FB24 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #90 )
    COP [ApplyBgChange]
    COP [ClearFlagWord] ( #$0125 )
    COP [ClearFlagWord] ( #$0126 )
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05FB24 {
    COP [SetHitCallback] ( &code_05FB04 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #26 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0125 )
    COP [SetFlagWord] ( #$0126 )
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
}

actor_def_05FB44 [
  actor-def < #0F, #01, #01, {

  code_05FB47:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [BranchIfFlagWord] ( #$0127, #01, &code_05FB7B )
    BRA loc_05FBAA

  code_05FB61:
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #28 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0127 )
    COP [SetFlagWord] ( #$0128 )
    COP [ClearFlagWord] ( #$0129 )
    COP [ClearFlagWord] ( #$012A )
} >
]

code_05FB7B {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05FB90 )
    COP [SetEntryContinue]
    RTL 
}

code_05FB90 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #2A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0129 )
    COP [SetFlagWord] ( #$012A )
    COP [ClearFlagWord] ( #$0127 )
    COP [ClearFlagWord] ( #$0128 )

  loc_05FBAA:
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05FB61 )
    COP [SetEntryContinue]
    RTL 
}

actor_def_05FBBF [
  actor-def < #00, #00, #20, {

  code_05FBC2:
    COP [BranchIfFlagWord] ( #$012E, #01, &code_05FBE7 )

  loc_05FBC9:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05FBFD )
    COP [BranchIfActorAt] ( #03, #$0258, #$0330, &code_05FBDA )
    RTL 
} >
]

code_05FBDA {
    COP [StageBgChange] ( #2E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$012D )
    COP [SetFlagWord] ( #$012E )
}

code_05FBE7 {
    LDY #$1090
    LDA #$0258
    STA $0014, Y
    LDA #$0330
    STA $0016, Y
    COP [ClearLowAbs] ( #38, #32 )
    COP [SetEntryContinue]
    RTL 
}

code_05FBFD {
    COP [PrintDialogString] ( &dialogstring_05FC0B )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05FC0A )
    BRA loc_05FBC9
}

code_05FC0A {
    RTL 
}

dialogstring_05FC0B `[DEF]このタイルを ふむと[N]何か音がするようだ···[END]`

actor_def_05FC28 [
  actor-def < #00, #00, #20, {

  code_05FC2B:
    COP [BranchIfFlagWord] ( #$012F, #01, &code_05FC47 )
    COP [SetEntryContinue]
    COP [BranchIfActorAt] ( #03, #$0348, #$02E0, &code_05FC3E )
    RTL 
} >
]

code_05FC3E {
    COP [StageBgChange] ( #2F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$012F )
}

code_05FC47 {
    COP [Die]

  loc_05FC49:
    RTL 
}

actor_def_05FC4A [
  actor-def < #00, #00, #20, {

  code_05FC4D:
    PHX 
    LDX #$0000

  loc_05FC51:
    LDA $@loc_05FC9A, X
    CMP #$FFFF
    BEQ loc_05FC97
    CMP $sceneCurrent
    BNE loc_05FC71
    LDA $@loc_05FC9A+2, X
    CMP $playerWallType
    BNE loc_05FC71
    LDA $@loc_05FC9A+4, X
    CMP $playerSpeedEw
    BEQ loc_05FC79

  loc_05FC71:
    TXA 
    CLC 
    ADC #$0006
    TAX 
    BRA loc_05FC51

  loc_05FC79:
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C613
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_05FC97:
    PLX 
    COP [Die]

  loc_05FC9A:
    EOR $dmaSkipFlag
    ORA $90, S
    COP [WorldMapStream3] ( #$5800 )
    COP [BranchIfFlagByte] ( #03, #4D, &code_059800 )
    BRK #$D0
    ORA $4E, S
    BRK #$E8
    BRK #$80
    COP [WorldMapStream4] ( #$9800 )
    ORA ($C0, X)
    ORA $4E, S
    BRK #$58
    ORA $C0, S
    ORA $4F, S
    BRK #$38
    ORA $10, S
    ORA ($4F, X)
    BRK #$58
    ORA ($F0, X)
    BRK #$4F
    BRK #$F8
    ORA ($80, X)
    COP [CopyPalette] ( @chunk_008000.thinker_def_00B7FF+1, #00, #01, #50 )
    BRK #$98
    COP [Die]

  loc_05FCDB:
    BRK #$50
    BRK #$F8
    ORA ($70, X)
    COP [Decompress] ( @chunk_028000.loc_02A7F5+B, @gfx_greatwall_sprites+140 )
    BRK #$E8
    BRK #$00
    ORA ($51, X)
    BRK #$58
    ORA $C0, S
    ORA $52, S
    BRK #$48
    ORA ($30, X)
    ORA ($52, X)
    BRK #$08
    ORA $F0, S
    BRK #$52
    BRK #$98
    BRK #$B0
    ORA $53, S
    BRK #$08
    COP [StagePlayerMoveX] ( #02, #53 )
    BRK #$68
    BRK #$E0
    ORA $53, S
    BRK #$E8
    COP [Die]

  loc_05FD17:
    COP [TickMove]
    BRK #$A8
    BRK #$00
    ORA ($54, X)
    BRK #$E8
    ORA ($70, X)
    COP [SetAnimScratch] ( @chunk_038000.dialogstring_0387F9+M )
    BNE loc_05FD2D
    MVN #$00, #$08

  loc_05FD2D:
    ORA ($F0, X)
    COP [SetAnimScratch] ( $034800 )
    BEQ loc_05FD36

  loc_05FD36:
    SBC $@chunk_028000.code_02ADC9+36, X
    ASL $85
    ASL $A9, X
    BRK #$00
    STA $chatPtr, X

  code_05FD44:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@loc_058C8F, X
    STA $0000
    LDA $@loc_058C8F+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_05FD66
    XBA 
    DEC 
    XBA 

  loc_05FD66:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_05FD3D
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_05FD92
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $16
    STA $16
    STA $cameraTargetY
    RTL 

  loc_05FD92:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    JMP $&code_05FD44
} >
]

actor_def_05FD9F [
  actor-def < #3D, #00, #01, {

  code_05FDA2:
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )

  loc_05FDBB:
    COP [SetHitCallback] ( &code_05FDC9 )
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05FDC9 {
    LDA $slopeCurvePtrB
    BIT #$0002
    BEQ loc_05FDBB
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

actor_def_05FDD6 [
  actor-def < #00, #00, #30, {

  code_05FDD9:
    COP [BranchIfFlagByte] ( #6C, #01, &code_05FDF5 )
    COP [SetFlagByte] ( #6C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05FDF7 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05FDF5 {
    COP [Die]
}

dialogstring_05FDF7 `[TPL:E][TPL:0]テム:[N]インカの ラライのガケには[N]すさまじい風が ふきあれていた.[FIN]これが 長老の言っていた 神の息[N]なのだろうか···[FIN]このガケのどこかに 風のない場所が[N]ひっそりと ねむっているのだろう.[N]ボクは 胸の高なりを 感じた.[PAL:0][END]`

actor_def_05FE87 [
  actor-def < #00, #00, #30, {

  code_05FE8A:
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $sceneCurrent
    CMP #$003E
    BEQ loc_05FEA5
    CMP #$004C
    BEQ loc_05FEB7

  code_05FE9D:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]

  loc_05FEA5:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05FE9D )
    COP [SetFlagByte] ( #6A )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05FEC9 )
    BRA code_05FE9D

  loc_05FEB7:
    COP [BranchIfFlagByte] ( #6B, #01, &code_05FE9D )
    COP [SetFlagByte] ( #6B )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05FF2D )
    BRA code_05FE9D
} >
]

dialogstring_05FEC9 `[TPL:A][TPL:0]テム:[N]鉱山の中は 不気味なまでに[N]静まりかえっている.[FIN]どうくつの おくの方から ときおり[N]聞こえる ドレイたちの 悲鳴に[N]背筋が 寒くなった···[PAL:0][END]`

dialogstring_05FF2D `[TPL:E][TPL:0]テム:[N]ナスカの上空には 不思議な庭園が[N]うかんでいた···[FIN]地上では ニールたちが 右往左往[N]しているのが米つぶのように見える.[FIN]ナスカの地上絵は この空中庭園の[N]ための 飛行場だったのだろうか?[PAL:0][END]`