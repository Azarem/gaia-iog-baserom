?BANK 07

?INCLUDE 'array_01D3F7'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_068000'
?INCLUDE 'chunk_088000'
?INCLUDE 'parallax_table'
?INCLUDE 'scene_warps'
?INCLUDE 'table_018000'
?INCLUDE 'table_0EE000'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!cameraBoundsY                  06DC
!layerPriorityFlag              06EE
!playerWallType                 09B0
!playerSpeedEw                  09B2
!decelStepCounter               09B8
!abilityBitmask                 0AA2
!jewelsCollected                0AB0
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!playerStr                      0ADE
!DMAP4                          4340
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!currentHp                      7F0026

---------------------------------------------

actor_def_078000 [
  actor-def < #00, #00, #38, {

  code_078003:
    COP [BranchIfFlagByte] ( #8D, #01, &code_07808E )
    LDA #$0008
    TSB $12
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0800
    TSB $10
    COP [SpawnLastRel] ( @code_0780AD, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @code_078090, #$2800 )
    COP [StageSpriteLoopMoveY] ( #07, #08, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #07, #10, #11, #02 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetFlagByte] ( #8D )
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_078138 )
    COP [WaitByte] ( #3B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #00, #$1100 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_07808E {
    COP [Die]
}

code_078090 {
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0080
    STA $cameraTargetX
    STA $cameraDeltaX
    LDA $0016, Y
    SEC 
    SBC #$0080
    STA $cameraTargetY
    STA $cameraDeltaY
    RTL 
}

code_0780AD {
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0780B6 )
    COP [Die]
}

widestring_0780B6 `[DEF][TPL:0][SFX:10]ぼくらは 水上都市ウォータミアに[N]やってきた.[PAU:78][N]イカダの上に 家が たちならび[N]それは 美しい町だった.[PAU:78][CLR]町の人々も 親切で[N]ぼくらは ルークという青年の家に[N]とめてもらうことになった.[PAU:B4][PAL:0][CLD]`

widestring_078138 `[DEF][CLR][TPL:0][SFX:10]そして ここが ルークの家.[N]彼は 漁師をやっている 好青年だ.[FIN]遠洋航海で 長期間 海に出るため[N]その間 家を使わせてもらうことに[N]なったというわけだ.[PAL:0][END]`

actor_def_0781A3 [
  actor-def < #00, #00, #2B, {

  code_0781A6:
    LDA #$1000
    TSB $12
    LDA #$0400
    STA $cameraBoundsY
    COP [ExitIfFlagByte] ( #8D, #01 )
    LDA $cameraTargetY
    STA $16

  loc_0781BA:
    LDA #$0000
    STA $chatPtr, X

  loc_0781C1:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@loc_07821D, X
    STA $0000
    LDA $@loc_07821D+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_0781E3
    XBA 
    DEC 
    XBA 

  loc_0781E3:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_0781BA
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_078211
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    STA $cameraDeltaY
    RTL 

  loc_078211:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_0781C1

  loc_07821D:
    ORA ($04, X)
    COP [StartMusic] ( #03 )
    ORA $04, S
    ORA $05, S
    COP [PlaySoundCh2] ( #02 )
    ORA [$02]
    PHP 
    COP [WriteApuIo1] ( #04 )
    ASL 
    COP [SolidHighHere]
    COP [ClearLowHere]
    COP [SolidHighOffset] ( #02, #0E )
    ORA $0F, S
    ORA $10, S
    TSB $11
    TSB $11
    BIT $0411, X
    BPL loc_078249
    ORA $030E03

  loc_078249:
    ORA $0C02
    COP [SolidHighHere]
    COP [WriteApuIo0] ( #02 )
    ORA #$0804
    COP [PlaySoundCh1] ( #02 )
    ASL $02
    ORA $02
    TSB $03
    ORA $03, S
    COP [StartMusic] ( #01 )
    TSB $00
    BIT $0000, X
} >
]

actor_def_078267 [
  actor-def < #02, #00, #10, {

  code_07826A:
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_078289 )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_07827D:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07827D
} >
]

code_078289 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078294 )
}

code_list_078294 [
  &code_078298   ;00
  &code_07829D   ;01
]

code_078298 {
    COP [PrintWideString] ( &widestring_0782A2 )
    RTL 
}

code_07829D {
    COP [PrintWideString] ( &widestring_078338 )
    RTL 
}

widestring_0782A2 `[DEF][SFX:10]男:[N]万里の長城には サンドファンガー[N]っていう でっけえ むかでが[N]生息してるって話だ.[FIN]そいつの体液は どんな 病気も[N]直す力が あるらしいぜ.[FIN]漢方藥の原料には 不気味なもんが[N]多いけど 虫の生き血だけは[N]飲みたかねえなあ···[END]`

widestring_078338 `[DEF][SFX:10]命をかけた 人生最大の かけごと[N]ロシアンルーレットは 每月[N]満月の夜に 行われるのさ.[FIN]でも ぼうやは まだ 若い.[N]わざわざ 命を すてることは[N]ないと 思うけどな.[END]`

actor_def_0783A1 [
  actor-def < #02, #00, #10, {

  code_0783A4:
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_0783C3 )
    LDA #$000A
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_0783B7:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_0783B7
} >
]

code_0783C3 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0783CE )
}

code_list_0783CE [
  &code_0783D0
]

code_0783D0 {
    COP [BranchIfFlagByte] ( #96, #01, &code_0783DB )
    COP [PrintWideString] ( &widestring_0783E0 )
    RTL 
}

code_0783DB {
    COP [PrintWideString] ( &widestring_078419 )
    RTL 
}

widestring_0783E0 `[DEF][SFX:10]女:[N]ここは ウォータミア.[N]家は みんな イカダの上だから[N]ひっこしなんて 楽なものよ.[END]`

widestring_078419 `[DEF][SFX:10]女:[N]さっき ピンク色の服を着た女の子が[N]そこの ハスの葉の上で 何か[N]おいのりしてたわよ.[END]`

actor_def_078458 [
  actor-def < #12, #00, #10, {

  code_07845B:
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07847A )
    LDA #$0012
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_07846E:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07846E
} >
]

code_07847A {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078485 )
}

code_list_078485 [
  &code_078487
]

code_078487 {
    COP [PrintWideString] ( &widestring_07848C )
    RTL 
}

widestring_07848C `[DEF][SFX:10]子供: ぼくたちは[N]この水を 飲んで[N]この水で ごはんを作って[N]この水で せんたくをするんだ.[END]`

actor_def_0784C6 [
  actor-def < #02, #00, #10, {

  code_0784C9:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0002
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_0784EB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0784EB {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0784F6 )
}

code_list_0784F6 [
  &code_07850E   ;00
  &code_078513   ;01
  &code_078518   ;02
  &code_07851D   ;03
  &code_078555   ;04
  &code_07855A   ;05
  &code_07855F   ;06
  &code_078564   ;07
  &code_078569   ;08
  &code_07856E   ;09
  &code_078573   ;0A
  &code_078573   ;0B
]

code_07850E {
    COP [PrintWideString] ( &widestring_07857D )
    RTL 
}

code_078513 {
    COP [PrintWideString] ( &widestring_0785B6 )
    RTL 
}

code_078518 {
    COP [PrintWideString] ( &widestring_07860A )
    RTL 
}

code_07851D {
    COP [PrintWideString] ( &widestring_078644 )
    COP [DialogueOptions] ( #02, #02, &code_list_078527 )
}

code_list_078527 [
  &code_07852D   ;00
  &code_07852D   ;01
  &code_078532   ;02
]

code_07852D {
    COP [PrintWideString] ( &widestring_0786A2 )
    RTL 
}

code_078532 {
    COP [PrintWideString] ( &widestring_0786BD )
    LDA #$000D
    STA $0D60
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$02D4, #$01A4, #00, #22 )
    COP [QueueMapChange] ( #01, #$00F0, #$02E0, #03, #$4300 )
    RTL 
}

code_078555 {
    COP [PrintWideString] ( &widestring_0786EC )
    RTL 
}

code_07855A {
    COP [PrintWideString] ( &widestring_078718 )
    RTL 
}

code_07855F {
    COP [PrintWideString] ( &widestring_078758 )
    RTL 
}

code_078564 {
    COP [PrintWideString] ( &widestring_078793 )
    RTL 
}

code_078569 {
    COP [PrintWideString] ( &widestring_0787E2 )
    RTL 
}

code_07856E {
    COP [PrintWideString] ( &widestring_078838 )
    RTL 
}

code_078573 {
    COP [PrintWideString] ( &widestring_07883A )
    RTL 
}

code_078578 {
    COP [PrintWideString] ( &widestring_07889A )
    RTL 
}

widestring_07857D `[DEF][SFX:10]男:[N]ここは ウォータミア.[N]家は みんな イカダの上だから[N]ひっこしなんて 楽なもんさ.[END]`

widestring_0785B6 `[DEF][SFX:10]男:[N]この動物は クルックって言うんだ.[FIN]長期間 飲まず食わずでも 生きて[N]いられるから 砂ばくを わたるのに[N]ちょうど いいんだよ.[END]`

widestring_07860A `[DEF][SFX:10]男:[N]ここは とばく場.[N]子供なのに こんなところへくるとは[N]よっぽど お金に困ってるんだな··[END]`

widestring_078644 `[DEF]私は 大空の運び屋.[N]私のかいならした鳥たちは 遠くの町[N]まで 連れていってくれるのさ.[FIN]どうだね?[N]サウスケープの町まで 行くかい?[N] やめる[N] 行くっ`

widestring_0786A2 `[CLR]そうかい···[N]なら そのうち 使ってくれよな.[END]`

widestring_0786BD `[CLR]鳥よ 鳥よ 鳥たちよ···[N]この人を サウスケープまで 運んで[N]おくれっ!![END]`

widestring_0786EC `[DEF]このハスの葉は 定員オーバーだよ.[N]乗るなら 他を あたってくれ.[END]`

widestring_078718 `[DEF][SFX:10]ルーク: やあ.[N]家は 気に入ってくれたかい?[N]ぼくが 航海にでてるあいだは[N]自由に 使ってくれよ.[END]`

widestring_078758 `[DEF]もし 大きな金が 欲しいのなら[N]この建物の 裹側に うかんでいる[N]イカダへ 行ってみるんだな.[END]`

widestring_078793 `[DEF][SFX:10]少しばかりの金を かけても[N]大きな金は 手に入らないものさ.[FIN]もし 命をかける気があるなら[N]ばく大な財産が 手に入るかもな.[END]`

widestring_0787E2 `[DEF]人生なんて かけごとと同じさ.[N]ちょっと 判断を まちがえれば[N]じごくへの道を まっさかさまだ.[FIN]人間 それを 無意識のうちに[N]やってるもんさね.[END]`

widestring_078838 `[DEF][END]`

widestring_07883A `[DEF]この町の おくの家には[N]頭が おかしくなっちまった[N]じいさんが 住んでるよ.[FIN]なんでも オールマン探険隊の[N]バベルの塔 調査に参加してただとか[N]何だとか.[END]`

widestring_07889A `[DEF][END]`

actor_def_07889C [
  actor-def < #0A, #00, #10, {

  code_07889F:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$000A
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_0788C1 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0788C1 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0788CC )
}

code_list_0788CC [
  &code_0788D8   ;00
  &code_0788DD   ;01
  &code_0788E2   ;02
  &code_0788E7   ;03
  &code_0788EC   ;04
  &code_0788FC   ;05
]

code_0788D8 {
    COP [PrintWideString] ( &widestring_078901 )
    RTL 
}

code_0788DD {
    COP [PrintWideString] ( &widestring_078956 )
    RTL 
}

code_0788E2 {
    COP [PrintWideString] ( &widestring_0789A1 )
    RTL 
}

code_0788E7 {
    COP [PrintWideString] ( &widestring_0789DD )
    RTL 
}

code_0788EC {
    COP [BranchIfFlagByte] ( #95, #01, &code_0788F7 )
    COP [PrintWideString] ( &widestring_078A03 )
    RTL 
}

code_0788F7 {
    COP [PrintWideString] ( &widestring_078A40 )
    RTL 
}

code_0788FC {
    COP [PrintWideString] ( &widestring_078A79 )
    RTL 
}

widestring_078901 `[DEF][SFX:10]水は 同じ場所に とどまって[N]いないわ. たえまなく 動いて[N]自分を きれいに しようとするの.[FIN]わたしたちも 水のように[N]生きたいものね···[END]`

widestring_078956 `[DEF][SFX:10]ナナ:[N]お父さんの 最後の手紙を[N]受けとってから もう 半年も[N]音さたがないの···[FIN]無事だと いいのだけれど···[END]`

widestring_0789A1 `[DEF][SFX:10]人の命って そんな かんたんなもの[N]じゃないはず.[FIN]つまらない かけごとで[N]命を そまつにしないようにね.[END]`

widestring_0789DD `[DEF]見てのとおり お酒の飲みくらべよ.[N]どっちが かつか かけてるの.[END]`

widestring_078A03 `[DEF]女:[N]もうじき 赤ちゃんが生まれるの.[N]うちの人ったら 楽しみにしちゃって[N]はりきって 仕事をしてるわ.[END]`

widestring_078A40 `[DEF]女: お金なんて いらない···[N]本当の幸せって 好きな人と[N]いっしょに いられることなのよね.[END]`

widestring_078A79 `[DEF]頭のおかしい おじいさんって[N]すごい しらがだけど[N]本当は まだ 若いんですって.[FIN]何か よっぽど こわいめに[N]会ったのかしら···[END]`

actor_def_078AC3 [
  actor-def < #12, #00, #10, {

  code_078AC6:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_078AE8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_078AE8 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078AF3 )
}

code_list_078AF3 [
  &code_078AFD   ;00
  &code_078B02   ;01
  &code_078B07   ;02
  &code_078B0C   ;03
  &code_078B11   ;04
]

code_078AFD {
    COP [PrintWideString] ( &widestring_078B16 )
    RTL 
}

code_078B02 {
    COP [PrintWideString] ( &widestring_078B55 )
    RTL 
}

code_078B07 {
    COP [PrintWideString] ( &widestring_078BAB )
    RTL 
}

code_078B0C {
    COP [PrintWideString] ( &widestring_078BEA )
    RTL 
}

code_078B11 {
    COP [PrintWideString] ( &widestring_078C32 )
    RTL 
}

widestring_078B16 `[DEF][SFX:10]子供:[N]ヘビにかまれたら めちゃくちゃに[N]走りまわれば いいのさ.[N]そしたら ポロっと 落っこちるよ.[END]`

widestring_078B55 `[DEF][SFX:10]子供:[N]前に 万里の長城に 行ったとき[N]ヘビに かまれたんだ···[FIN]このあたりの ヘビは ー度[N]かみつくと なかなか[N]はなさないんだよ.[END]`

widestring_078BAB `[DEF][SFX:10]サーバス:[N]ぼくの お父さんは 探険家なんだ.[N]もうじき 黄金の船を 見つけて[N]来るんだよっ!![END]`

widestring_078BEA `[DEF][SFX:10]子供:[N]いいことを 教えてあげる.[FIN]とばく場の 右の裹手で しばらく[N]待っててごらん.[N]ハスの葉が やってくるよ.[END]`

widestring_078C32 `[DEF][SFX:10]子供:[N]ここは ウォータミア.[END]`

actor_def_078C49 [
  actor-def < #2C, #00, #10, {

  code_078C4C:
    COP [BranchIfFlagByte] ( #95, #01, &code_078C85 )
    COP [BranchIfFlagByte] ( #97, #01, &code_078C61 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_078CCE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_078C61 {
    COP [SetFlagByte] ( #95 )
    LDA #$2000
    TSB $10
    COP [SetTilePos] ( #00, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_078CFE )
    COP [GiveItem] ( #18, &code_078C87 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_078C85 {
    COP [Die]
}

code_078C87 {
    COP [BranchIfNoItem] ( #01, &code_078C91 )
    COP [BranchIfNoItem] ( #06, &code_078CBA )
}

code_078C91 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    COP [GiveItem] ( #18, &code_078CAE )
}

code_078CAE {
    COP [PrintWideString] ( &widestring_078DBF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_078CBA {
    COP [RemoveItem] ( #06 )
    COP [GiveItem] ( #18, &code_078CC2 )
}

code_078CC2 {
    COP [PrintWideString] ( &widestring_078E1C )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_078CCE {
    COP [PrintWideString] ( &widestring_078CD3 )
    RTL 
}

widestring_078CD3 `[TPL:A]男: ゴホッ ゴホッ[N]なーに ちょっと カゼをひいた[N]だけさ.[END]`

widestring_078CFE `[TPL:B]女:[N]あなたが ロシアングラスの[N]対戦者だった方ね.[FIN]主人は いい仕事が見つかったから[N]苦労はかけないと 言っていたのに[N]まさか あんなことを···[FIN]これ 主人の遺書です.[N]表紙には┌対戦者の人へ┘と書かれて[N]いるの.[N]どうぞ お読みになって下さい.[FIN]それと 外に クルックが 4頭[N]いますから 使ってくださいな.[END]`

widestring_078DBF `[TPL:B]女: あら···[N]持ち物が いっぱいなのね···[FIN]じゃあ あなたの 赤い宝石をーつ[N]あずからせてもらうわね.[N]宝石商さんに 送っておくから[N]心配しないで.[END]`

widestring_078E1C `[TPL:B]女: あら···[N]持ち物が いっぱいなのね···[FIN]じゃあ あなたの もっている[N]藥草をーつ 記念に もらって[N]いいかしら.[END]`

actor_def_078E64 [
  actor-def < #02, #00, #10, {

  code_078E67:
    COP [BranchIfFlagByte] ( #96, #01, &code_078E88 )
    COP [SetOnInteract] ( &code_0790D4 )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_078E7C:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_078E7C
} >
]

code_078E88 {
    COP [SpawnAfterAbsFlags] ( @code_0793B0, #$0478, #$0070, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0793FD, #$04A8, #$0070, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079453, #$04C8, #$00C0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079609, #$0458, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_07963F, #$0458, #$00B0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0796A0, #$0478, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0797B6, #$0488, #$0080, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0797F3, #$0498, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079830, #$04A8, #$0080, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_07986D, #$04B8, #$0090, #$1000 )
    COP [SetOnInteract] ( &code_0790D9 )
    COP [SetTilePos] ( #48, #0B )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0000
    STA $0AA6
    LDA $0AA6
    BIT #$0004
    BNE loc_078F6D
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #1D )
    COP [WriteApuIo1] ( #08 )
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07920E )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_0790E1 )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #03, #01 )

  loc_078F6D:
    LDA $0AA6
    BIT #$0010
    BNE loc_078FC2
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07920E )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0010
    STA $0AA6
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_0790EF )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #04, #01 )

  loc_078FC2:
    LDA $0AA6
    BIT #$0002
    BNE loc_07901B
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #31, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07920E )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    COP [StageSpriteLoopMoveY] ( #2E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #30, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_0790FD )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #05, #01 )

  loc_07901B:
    LDA $0AA6
    BIT #$0008
    BNE loc_079066
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07920E )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    COP [StageSpriteLoopMoveY] ( #2E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_07910B )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #06, #01 )

  loc_079066:
    LDA $0AA6
    BIT #$0001
    BNE loc_0790CC
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #31, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0792A1 )
    LDA $0AA6
    ORA #$0001
    STA $0AA6
    COP [SetFlagByte] ( #08 )
    COP [WaitByte] ( #7F )
    COP [PrintWideString] ( &widestring_07934F )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #77 )
    LDA #$0408
    STA $gfxCacheIdxB
    LDA #$0203
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #7D, #$0070, #$0080, #00, #$1100 )
    COP [ClearFlagByte] ( #96 )
    COP [SetFlagByte] ( #97 )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_0790CC:
    COP [SetEntryContinue]
    RTL 
}

code_0790CF {
    COP [PrintWideString] ( &widestring_079279 )
    RTL 
}

code_0790D4 {
    COP [PrintWideString] ( &widestring_079119 )
    RTL 
}

code_0790D9 {
    COP [PrintWideString] ( &widestring_079180 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_0790E1 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_0790CF )
    COP [PrintWideString] ( &widestring_07924F )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_0790EF {
    COP [BranchIfFlagByte] ( #0F, #01, &code_0790CF )
    COP [PrintWideString] ( &widestring_07924F )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_0790FD {
    COP [BranchIfFlagByte] ( #0F, #01, &code_0790CF )
    COP [PrintWideString] ( &widestring_07924F )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_07910B {
    COP [BranchIfFlagByte] ( #0F, #01, &code_0790CF )
    COP [PrintWideString] ( &widestring_07924F )
    COP [SetFlagByte] ( #06 )
    RTL 
}

widestring_079119 `[DEF][SFX:10]命をかけた 人生最大の かけごと[N]ロシアングラスは 每月[N]満月の夜に 行われるのさ.[FIN]でも ぼうやは まだ 若い.[N]わざわざ 命を すてることは[N]ないと 思うけどな.[END]`

widestring_079180 `[DEF][SFX:10][TPL:4]対戦者:[N]けっ.[N]また 命しらずが きやがった.[FIN]ルールは 簡単だ.[N]5つのグラスの どれかーつに[N]毒藥が 入っている.[FIN]それを こうごに 飲んでいく.[N]最後まで 生き残った方が 勝ちと[N]いうわけだ.[FIN]じゃあ おれから いくぜっ![END]`

widestring_07920E `[DEF][SFX:10][TPL:4]対戦者:[N]うおおおおおおおおおっ!![FIN][SFX:0]対戦者は グラスの中身を[N]ー気に 飲みほした···[END]`

widestring_07924F `[DEF][SFX:10][TPL:4]対戦者:[N]けっ! 運のいいやつめ···[N]次は おれの番だな.[END]`

widestring_079279 `[DEF][SFX:10][TPL:4]対戦者:[N]ほら おめえの番だぜ![N]びびって にげだすなよ!![END]`

widestring_0792A1 `[DEF][SFX:10][TPL:4]対戦者:[N]残りのグラスは これーつ···[WAI][CLD][PAU:3C][DEF][TPL:6][DLY:2]観客:[N]もう いい···[N]この 少年の 勝ちだ···[FIN][DLY:1]観客:[N]そうよ![N]もう やめてっ!![FIN][TPL:4][DLY:3]対戦者: いや···[N][PAU:1E]おれは 負け犬になって[N]はじを さらすつもりはない···[FIN][SFX:0][DLY:2][TPL:6]男は グラスを 手にとった···[END]`

widestring_07934F `[DEF][SFX:10][TPL:6][DLY:0]観客: よせっ![N]もう お前の 負けなんだっ!![N]死に急ぐなっ!![FIN][SFX:0][DLY:3]男は 観客の 言葉も聞かず[N]グラスの中身を 静かに流しこんだ![PAL:0][END]`

code_0793B0 {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0793D8 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_0793D8 {
    COP [PrintWideString] ( &widestring_0793DD )
    RTL 
}

widestring_0793DD `[DEF]あんた まだ 若いのに[N]こんなことに 命をかけるなんて.[END]`

code_0793FD {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_079424 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_079424 {
    COP [PrintWideString] ( &widestring_079429 )
    RTL 
}

widestring_079429 `[DEF]こんな エキサイティングな 遊びは[N]他にないわ.[N]ゾクゾクしちゃう.[END]`

code_079453 {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_079487 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_0794B7 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_079487 {
    COP [WriteApuIo0] ( #7F )
    COP [PrintWideString] ( &widestring_0794BC )
    COP [DialogueOptions] ( #02, #02, &code_list_079494 )
}

code_list_079494 [
  &code_07949A   ;00
  &code_07949F   ;01
  &code_07949A   ;02
]

code_07949A {
    COP [PrintWideString] ( &widestring_0794E9 )
    RTL 
}

code_07949F {
    COP [PrintWideString] ( &widestring_079511 )
    COP [DialogueOptions] ( #02, #02, &code_list_0794A9 )
}

code_list_0794A9 [
  &code_07949A   ;00
  &code_0794AF   ;01
  &code_07949A   ;02
]

code_0794AF {
    COP [PrintWideString] ( &widestring_07957B )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_0794B7 {
    COP [PrintWideString] ( &widestring_0795EA )
    RTL 
}

widestring_0794BC `[DEF]ここは ロシアングラスの会場.[N]あんた 出場するのかね?[N] はい[N] いいえ`

widestring_0794E9 `[CLR]ならば かえるんだな.[N]そして ここで 見たことは[N]すべて 忘れるんだ.[END]`

widestring_079511 `[CLR]なんと その若い命を かけて[N]ロシアングラスを やろうと[N]いうのかっ![FIN]これは 遊びじゃない.[N]命が かかっているんだぜ.[FIN]もうー度 聞く.[N]本当に こうかいしないな?[N] はい[N] いいえ`

widestring_07957B `[CLR]よかろう.[N]そこに いるのが 対戦相手だ.[FIN]彼は 百戦れんまの 強者.[N]彼を越える 運を もちあわせている[N]人間を 私は 見たことがない.[FIN]さあ.[N]彼から ルールを 聞くがいい.[END]`

widestring_0795EA `[DEF]今夜も 若い命がーつ 散ろうと[N]している···[END]`

code_079609 {
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_07962B )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_07962B {
    COP [PrintWideString] ( &widestring_079630 )
    RTL 
}

widestring_079630 `[DEF]勇気が あるんですね.[END]`

code_07963F {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_079661 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #11, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_079661 {
    COP [PrintWideString] ( &widestring_079666 )
    RTL 
}

widestring_079666 `[DEF]あなたの 対戦者の人は ずいぶんと[N]お金を もうけているみたい.[N]いったい 何につかうのかしら···[END]`

code_0796A0 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0796BF )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0010
    BNE loc_0796BB
    RTL 

  loc_0796BB:
    COP [ClearLowHere]
    COP [Die]
}

code_0796BF {
    COP [BranchIfFlagByte] ( #0F, #00, &code_0796DC )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0010
    STA $0AA6
    COP [PrintWideString] ( &widestring_0796DD )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_0796DC {
    RTL 
}

widestring_0796DD `[DEF][CLR][TPL:0]テム:[N]ぼくは 目をつぶって グラスを[N]ー気に のみほした![PAL:0][END]`

widestring_079709 `[DEF][TPL:0]テム: おや?[N]グラスの中の 飲み物が[N]血に 染まって見える···[FIN]これも ぼくの体に やどっている[N]力なのか···?[FIN][PAL:0]グラスの中身を 飲みますか?[N] はい[N] いいえ`

widestring_079773 `[DEF][CLR][TPL:0]テム:[N]このグラスは やめておこう···[PAL:0][END]`

widestring_079792 `[DEF][TPL:0]テム: うっ···[N]体が だんだん しびれてきた···[PAL:0][END]`

code_0797B6 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0797D5 )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0008
    BNE loc_0797D1
    RTL 

  loc_0797D1:
    COP [ClearLowHere]
    COP [Die]
}

code_0797D5 {
    COP [BranchIfFlagByte] ( #0F, #00, &code_0797F2 )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    COP [PrintWideString] ( &widestring_0796DD )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_0797F2 {
    RTL 
}

code_0797F3 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079812 )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0004
    BNE loc_07980E
    RTL 

  loc_07980E:
    COP [ClearLowHere]
    COP [Die]
}

code_079812 {
    COP [BranchIfFlagByte] ( #0F, #00, &code_07982F )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    COP [PrintWideString] ( &widestring_0796DD )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_07982F {
    RTL 
}

code_079830 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07984F )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0002
    BNE loc_07984B
    RTL 

  loc_07984B:
    COP [ClearLowHere]
    COP [Die]
}

code_07984F {
    COP [BranchIfFlagByte] ( #0F, #00, &code_07986C )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    COP [PrintWideString] ( &widestring_0796DD )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_07986C {
    RTL 
}

code_07986D {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07988C )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0001
    BNE loc_079888
    RTL 

  loc_079888:
    COP [ClearLowHere]
    COP [Die]
}

code_07988C {
    COP [BranchIfFlagByte] ( #0F, #00, &code_0798B2 )
    COP [PrintWideString] ( &widestring_079709 )
    COP [DialogueOptions] ( #02, #01, &code_list_07989C )
}

code_list_07989C [
  &code_0798AD   ;00
  &code_0798A2   ;01
  &code_0798AD   ;02
]

code_0798A2 {
    COP [PrintWideString] ( &widestring_0796DD )
    COP [PlaySoundCh1] ( #2E )
    STZ $playerHp
    RTL 
}

code_0798AD {
    COP [PrintWideString] ( &widestring_079773 )
    RTL 
}

code_0798B2 {
    RTL 
}

actor_def_0798B3 [
  actor-def < #1A, #00, #10, {

  code_0798B6:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0798CA )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    RTL 
} >
]

code_0798CA {
    COP [PrintWideString] ( &widestring_0798CF )
    RTL 
}

widestring_0798CF `[DEF]キューイ キューイ[END]`

actor_def_0798DE [
  actor-def < #1A, #00, #10, {

  code_0798E1:
    COP [BranchIfFlagByte] ( #94, #01, &code_079901 )
    COP [BranchIfFlagByte] ( #97, #00, &code_079901 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_079903 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    RTL 
} >
]

code_079901 {
    COP [Die]
}

code_079903 {
    COP [PrintWideString] ( &widestring_079908 )
    RTL 
}

widestring_079908 `[DEF][TPL:0]これが ゆずってくれるっていう[N]クルックだな···[N]さっそく みんなに 知らせ[N]なくちゃ.[PAL:0][END]`

actor_def_07993E [
  actor-def < #1E, #00, #18, {

  code_079941:
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryExit]
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_079953 [
  actor-def < #1F, #01, #10, {

  code_079956:
    COP [AddPosition] ( #08, #00 )
    COP [ClearAllHere]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07995F [
  actor-def < #1F, #01, #10, {

  code_079962:
    COP [SpawnAfterFlags] ( @code_0784C9, #$1000 )
    LDA #$0048
    STA $0014, Y
    LDA #$0004
    STA $000E, Y
    COP [AddPosition] ( #08, #00 )

  code_079979:
    COP [LoopInit] ( #B0 )
    COP [StageSpriteMoveX] ( #1F, #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    LDY $06
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    COP [LoopInit] ( #B0 )
    COP [StageSpriteMoveX] ( #1F, #02 )
    COP [AnimOnce]
    LDY $06
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    COP [StageSpriteMoveY] ( #1F, #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JMP $&code_079979
} >
]

actor_def_0799CC [
  actor-def < #00, #00, #30, {

  code_0799CF:
    COP [SetOnInteract] ( &code_0799D6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0799D6 {
    COP [PrintWideString] ( &widestring_0799F0 )
    COP [DialogueOptions] ( #02, #02, &code_list_0799E0 )
}

code_list_0799E0 [
  &code_0799E6   ;00
  &code_0799EB   ;01
  &code_0799E6   ;02
]

code_0799E6 {
    COP [PrintWideString] ( &widestring_079A1A )
    RTL 
}

code_0799EB {
    COP [PrintWideString] ( &widestring_079A41 )
    RTL 
}

widestring_0799F0 `[DEF][TPL:0]カレンの日記が かくしてある···[N]読みますか?[N] はい[N] いいえ`

widestring_079A1A `[CLR]そうだな.[N]勝手に読むのも 気がとがめるし[N]やめておこう···[PAL:0][END]`

widestring_079A41 `[CLR][TPL:1]X月 X日[N]長い長い 道のりだったけど[N]水の都 ウォータミアへ やっと[N]たどり着いた.[FIN]とちゅう のどがカラカラだったけど[N]がまんしたし, くつずれが[N]できたけど ハンカチで 包带をして[N]がんばったわ.[FIN]前だったら 文句ばっかり 言ってた[N]かもしれないけど 言わなかった.[N]あたしって この旅で ずいぶん[N]変わったと思う···[FIN]だれかのために いっしょうけんめい[N]になれる 今の 自分が ちょっぴり[N]気に入っているの.[FIN]さっき 町の人から[N]こんな 言い伝えを 聞いちゃった.[FIN]┌満月の夜に ハスの葉の上で[N] おいのりすると 好きな人が[N] 自分に ふりむいてくれる···[FIN]すてきな 言い伝えよね.[N]そのうち ためしてみよっかな···[PAL:0][END]`

widestring_079BB1 `れぼれぴれぺれ,[NAM:8B][E2] [BF]ぜが:せ[AB][TPL:20][BF]づが:[AA][BD]がが[E2] そ[FF]ぴ[85]ぺ[EB]そ[FF]ぴ[85],[BD]ごがそ[FF]ぴ[85]ぼ[BD]じがそ[FF]ぴ[85]ぴ[TPL:20][AB][FA]ぐ[DLG:A5,26][F0]げつ[9C][9C][A4]D[B9]ばがX[E5]ぺ[8D]ぼが[B9]ばがぼろぺ[8D]ぴが[B9]ぶがX[E5],[8D]ぺが[B9]ぶがぼろ,[8D],が[AC][B8]ぞ[B9]ばがぼぁぜが[N]ぼが[90]を[B9]ばがX[E9]ぜが[N]ぴが[B0]む[B9]ぶが[N]ぺが[90]の[B9]ぶがX[E9]┌が[N],が[B0]す[A4]D[A9]がが[99]Fが じ[9D][AC][B8]ぞ[B9]ばがX[E9]ぜが[N]ぼが[B0]ぎぅ[B9]ばがぼぁぜが[N]ぴが[90]ぎぅ[B9]ぶがX[E9]┌が[N]ぺが[B0]ぎぅ[B9]ぶが[N],が[90]ぎぅ[A4]D[A9]ぐが[99]Fがぅ[A4]D[A9]ぎが[99]Fがぅぐ[DLG:A5,26][CLR]げつ[EE][9B][A4]D[B9]FがZ[CLR]ぎぅ じ[9D][AC][B8]ぞ[B9]ばがX[E9]ぜが[N]ぼが[B0]だ[AD]ぼがぼぁぜが[99]ばが[B9]ばがぼぁぜが[N]ぴが[90]だ[AD]ぴがX[E9]ぜが[99]ばが[B9]ぶがX[E9]┌が[N]ぺが[B0]だ[AD]ぺがぼぁ┌が[99]ぶが[B9]ぶが[N],が[B0]ぎぅ[AD],が[99]ぶがぅ[A4]D[B9]ばがX[E5]ぼ[8D]ぼが[B9]ばがぼろぼ[8D]ぴが[B9]ぶがX[E5]ぴ[8D]ぺが[B9]ぶがぼろぴ[8D],がよ`

actor_def_079D2D [
  actor-def < #1F, #01, #03, {

  code_079D30:
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #8D, #01 )
    COP [SpawnBefore] ( @widestring_079BB1 )
    COP [SetEntryExit]
    STZ $26
    COP [ClearAllHere]
    COP [ClearLowHere]

  loc_079D45:
    COP [WaitByte] ( #77 )
    JSL $@code_079DA7
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    JSL $@code_079DD0
    LDA $26
    DEC 
    BEQ loc_079D75
    COP [SetEntryExit]
    COP [KillNext]

  loc_079D75:
    COP [WaitByte] ( #77 )
    JSL $@code_079DA7
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    JSL $@code_079DD0
    LDA $26
    DEC 
    BEQ loc_079D45
    COP [SetEntryExit]
    COP [KillNext]
    BRA loc_079D45
} >
]

code_079DA7 {
    LDA $26
    BNE loc_079DAF
    PHB 
    PLA 
    PLA 
    RTL 

  loc_079DAF:
    DEC 
    BEQ loc_079DC5
    COP [SpawnAfterFlags] ( @code_079DEE, #$2000 )
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y

  loc_079DC5:
    COP [SolidHighHere]
    LDY $04
    LDA #$0001
    STA $0026, Y
    RTL 
}

code_079DD0 {
    LDA $26
    DEC 
    BEQ loc_079DE1
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y

  loc_079DE1:
    LDY $04
    LDA #$0000
    STA $0026, Y
    COP [ClearAllHere]
    COP [ClearLowHere]
    RTL 
}

code_079DEE {
    LDY $24
    LDA $0014, Y
    PHA 
    SEC 
    SBC $14
    LDY $decelStepCounter
    CLC 
    ADC $0014, Y
    STA $0014, Y
    PLA 
    STA $14
    LDY $24
    LDA $0016, Y
    PHA 
    SEC 
    SBC $16
    LDY $decelStepCounter
    CLC 
    ADC $0016, Y
    STA $0016, Y
    PLA 
    STA $16
    RTL 
}

actor_def_079E1B [
  actor-def < #22, #00, #10, {

  code_079E1E:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079E31 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]

code_079E31 {
    COP [PrintWideString] ( &widestring_079E36 )
    RTL 
}

widestring_079E36 `[DEF]2年前 頭のおかしい じいさんが[N]この町へ やってきたんだ.[N]それ以来 バベルの塔が どうとか[N]変なことを 口走ってばかりさ.[END]`

actor_def_079E83 [
  actor-def < #05, #00, #10, {

  code_079E86:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_079F31, #$0010, #$0000, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$000C, #$FFF6, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$0018, #$0008, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$0020, #$0002, #$1000 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079EC0 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_079EC0 {
    COP [PrintWideString] ( &widestring_079EC5 )
    RTL 
}

widestring_079EC5 `[TPL:A]うおーーーーーっ![N]まだまだ いけるぞっ!!![END]`

actor_def_079EE1 [
  actor-def < #24, #00, #10, {

  code_079EE4:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_079F31, #$FFEE, #$FFF4, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$FFF4, #$0008, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$FFE8, #$0000, #$1000 )
    COP [SpawnAfterRelFlags] ( @code_079F31, #$FFE0, #$FFF6, #$1000 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079F1E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_079F1E {
    COP [PrintWideString] ( &widestring_079F23 )
    RTL 
}

widestring_079F23 `[TPL:A]うーん うーん[END]`

code_079F31 {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

actor_def_079F3B [
  actor-def < #14, #00, #10, {

  code_079F3E:
    COP [BranchIfFlagByte] ( #94, #01, &code_079F67 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #97, #01, &code_079F60 )
    COP [BranchIfFlagByte] ( #96, #01, &code_079F59 )
    COP [SetOnInteract] ( &code_079F69 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_079F59 {
    COP [SetOnInteract] ( &code_079F6E )
    COP [SetEntryContinue]
    RTL 
}

code_079F60 {
    COP [SetOnInteract] ( &code_079F73 )
    COP [SetEntryContinue]
    RTL 
}

code_079F67 {
    COP [Die]
}

code_079F69 {
    COP [PrintWideString] ( &widestring_079FB6 )
    RTL 
}

code_079F6E {
    COP [PrintWideString] ( &widestring_079FEA )
    RTL 
}

code_079F73 {
    COP [BranchIfFlagByte] ( #01, #01, &code_079F7E )
    COP [PrintWideString] ( &widestring_07A06B )
    RTL 
}

code_079F7E {
    COP [PrintWideString] ( &widestring_07A126 )
    COP [SetFlagByte] ( #94 )
    LDA #$0007
    STA $0D60
    LDA #$0008
    STA $0D62
    LDA #$0009
    STA $0D64
    LDA #$000A
    STA $0D66
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$02D4, #$01A4, #00, #15 )
    COP [QueueMapChange] ( #91, #$0370, #$0430, #06, #$5400 )
    RTL 
}

widestring_079FB6 `[TPL:A][TPL:6]ニ-ル:[N]このイカダの家は 新たな 発明の[N]ヒントに なりそうだなあ···[END]`

widestring_079FEA `[TPL:A][TPL:6]ニ-ル: ここから 西へ行くには[N]広大な さばくが 立ちはだかって[N]いるんだよ.[FIN]クルックでも いないかぎり[N]人間の足では とても わたりきれる[N]もんじゃない.[FIN]さあ どうやって クルックを[N]手にいれるかだな···[PAL:0][END]`

widestring_07A06B `[TPL:A][TPL:6]ニ-ル:[N]クルックをゆずってもらったって!?[N]あんな高価なものを···?[FIN]そんな さびしそうな目をして[N]どうしたんだよ···[N]まあ わけは深く聞かないでおこう.[FIN]それでだ.[N]ぼくらは 西のエウロという町へ[N]向かおうと おもうんだが···[FIN]ロブと リリィが この町に残るって[N]いうんだ.[N]まあ わけは二人から聞いてくれ.[END]`

widestring_07A126 `[TPL:B][TPL:6]ニ-ル:[N]男の子と 女の子が ひかれあう[N]しゅんかんっていうのは すてきな[N]まほうだと思う.[FIN]この気持ちは いつまでも[N]忘れずに 信じていたいもんだね.[FIN]それでだ.[N]エウロには ぼくの実家があってね,[N]あそこへ行けば 何か テムの力に[N]なれると思うんだ.[FIN]さあ エウロへ出発するぞっ!![END]`

actor_def_07A1D3 [
  actor-def < #0A, #00, #10, {

  code_07A1D6:
    COP [BranchIfFlagByte] ( #94, #01, &code_07A1F5 )
    COP [BranchIfFlagByte] ( #97, #01, &code_07A204 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A1F7 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A211 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A1F5 {
    COP [Die]
}

code_07A1F7 {
    COP [SetTilePos] ( #05, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A216 )
    COP [SetEntryContinue]
    RTL 
}

code_07A204 {
    COP [SetTilePos] ( #05, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A21B )
    COP [SetEntryContinue]
    RTL 
}

code_07A211 {
    COP [PrintWideString] ( &widestring_07A220 )
    RTL 
}

code_07A216 {
    COP [PrintWideString] ( &widestring_07A27A )
    RTL 
}

code_07A21B {
    COP [PrintWideString] ( &widestring_07A2B9 )
    RTL 
}

widestring_07A220 `[TPL:A][TPL:3]エリック: えへへ.[N]さっき いいもの 見つけちゃった.[FIN]そとへ出て この家の裹側を 調べて[N]ごらんよ. ちょっとばかり[N]良心が とがめるけどね···[END]`

widestring_07A27A `[TPL:A][TPL:3]エリック: 今日は 満月の夜.[N]なんか いつもと 町の樣子が[N]ちがうような 気がするなあ.[PAL:0][END]`

widestring_07A2B9 `[TPL:A][TPL:3]エリック:[N]ここで ロブや リリィと[N]お别れなんて···[PAL:0][END]`

actor_def_07A2E3 [
  actor-def < #1D, #00, #10, {

  code_07A2E6:
    COP [BranchIfFlagByte] ( #94, #01, &code_07A34A )
    COP [BranchIfFlagByte] ( #97, #01, &code_07A3A2 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A399 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #91, #01, &code_07A34C )
    COP [SetOnInteract] ( &code_07A3AB )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #28 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_07A5F5, #$0010, #$FFF2, #$1002 )
    COP [StageSpriteLoop] ( #1D, #3C )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07A446 )
    COP [SetFlagByte] ( #03 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A34A {
    COP [Die]
}

code_07A34C {
    COP [BranchIfFlagByte] ( #92, #01, &code_07A38D )
    COP [GiveItem] ( #16, &code_07A359 )
    BRA code_07A377
}

code_07A359 {
    COP [BranchIfNoItem] ( #01, &code_07A363 )
    COP [BranchIfNoItem] ( #06, &code_07A394 )
}

code_07A363 {
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 

  loc_07A372:
    COP [GiveItem] ( #16, &code_07A377 )
}

code_07A377 {
    COP [SetFlagByte] ( #92 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07A537 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_07A38D {
    COP [SetOnInteract] ( &code_07A3B0 )
    COP [SetEntryContinue]
    RTL 
}

code_07A394 {
    COP [RemoveItem] ( #06 )
    BRA loc_07A372
}

code_07A399 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A3B5 )
    COP [SetEntryContinue]
    RTL 
}

code_07A3A2 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A3BA )
    COP [SetEntryContinue]
    RTL 
}

code_07A3AB {
    COP [PrintWideString] ( &widestring_07A3BF )
    RTL 
}

code_07A3B0 {
    COP [PrintWideString] ( &widestring_07A56C )
    RTL 
}

code_07A3B5 {
    COP [PrintWideString] ( &widestring_07A599 )
    RTL 
}

code_07A3BA {
    COP [PrintWideString] ( &widestring_07A5BC )
    RTL 
}

widestring_07A3BF `[TPL:A][TPL:1][SFX:1B]カレン: ウォータミアは すごく[N]きれいな町だけど ちょっと いやな[N]うわさを 耳にしたの···[FIN]人の命を もてあそぶとか···[N]なんだとか···[FIN]花の都も そうだったけど[N]美しいものには 必ず 裹の顔が[N]あるのかしら···[PAL:0][END]`

widestring_07A446 `[TPL:A][TPL:1][SFX:1B]カレン:[N]はいっ. バースディケーキ![N]ニールが 作ってくれたの.[FIN][TPL:6][SFX:1A]ニール: ははは.[N]ケーキを 作ったのは 初めてさ.[FIN]飛行機を作るより ずっと[N]むずかしかったよ.[FIN][TPL:2][SFX:19]リリィ:[N]ありがとう··· みんな···[FIN]あたし 今日は 世界でいちばん[N]しあわせな 女の子かも.[FIN][TPL:0][SFX:10]こうして リリィの ささやかな[N]たんじょう日パーティーは[N]はじまった.[FIN]そして パーティーが終わるころ··[PAL:0][END]`

widestring_07A537 `[TPL:A][TPL:0]テム:[N]そして 翌朝····[FIN]目がさめたとき ロブの姿も[N]消えていた···[PAL:0][END]`

widestring_07A56C `[TPL:A][TPL:1]カレン:[N]ロブと リリィ どうしたのかしら.[N]心配よね···[PAL:0][END]`

widestring_07A599 `[TPL:A][TPL:1]カレン:[N]クルックって 変な動物よね···[PAL:0][END]`

widestring_07A5BC `[TPL:A][TPL:1]カレン:[N]ニールの実家って エウロの町で[N]貿易会社を やってるんですって.[PAL:0][END]`

code_07A5F5 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #37, #20, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

actor_def_07A602 [
  actor-def < #22, #00, #10, {

  code_07A605:
    COP [BranchIfFlagByte] ( #97, #01, &code_07A699 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A688 )
    COP [BranchIfFlagByte] ( #91, #01, &code_07A686 )
    COP [SetOnInteract] ( &code_07A6AA )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoop] ( #24, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #28 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07A714 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [PrintWideString] ( &widestring_07A79E )
    COP [StageSpriteLoopMoveX] ( #29, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07A7BA )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #26, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #27, #11 )
    COP [AnimOnce]
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #7F, #$02E0, #$00B0, #00, #$4500 )
} >
]

code_07A686 {
    COP [Die]
}

code_07A688 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A6AF )
    COP [SetEntryContinue]
    RTL 
}

code_07A699 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A6B4 )
    COP [SetEntryContinue]
    RTL 
}

code_07A6AA {
    COP [PrintWideString] ( &widestring_07A6C4 )
    RTL 
}

code_07A6AF {
    COP [PrintWideString] ( &widestring_07A7D7 )
    RTL 
}

code_07A6B4 {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07A6BF )
    COP [PrintWideString] ( &widestring_07A7FF )
    RTL 
}

code_07A6BF {
    COP [PrintWideString] ( &widestring_07A835 )
    RTL 
}

widestring_07A6C4 `[TPL:A][TPL:2][SFX:19]リリィ: ロブはね なんか[N]町の中で だれか 知っている人を[N]見かけたんだって.[FIN]で その人を さがしに[N]行ったみたいだよ.[END]`

widestring_07A714 `[TPL:A][TPL:2]リリィ: えっ? えっ?[N]みんな あたしの たんじょう日を[N]覚えてて くれたの···?[FIN][TPL:3]エリック:[N]あたりまえじゃない![FIN]びっくりさせようと思って[N]みんなで ないしょに してたんだ.[FIN][TPL:6]ニール: ほら カレン.[N]あれを もっておいで.[PAL:0][END]`

widestring_07A79E `[TPL:A][TPL:2]リリィ: ??[N]なんだろ? いったい···[END]`

widestring_07A7BA `[TPL:A][TPL:2]リリィ:[N]ごめんね.[N]ちょっと いってくる.[END]`

widestring_07A7D7 `[TPL:A][TPL:2]リリィ:[N]ロブの お父さんが はやく[N]よくなるといいね.[PAL:0][END]`

widestring_07A7FF `[TPL:A][TPL:2]リリィ: あたしも[N]この町に残ることにしたの.[FIN]わけはね···[N]ロブから聞いて.[PAL:0][END]`

widestring_07A835 `[TPL:A][TPL:2]リリィ:[N]おっきい星が しょうとつするとか[N]いやなうわさが 飛びかってるわ.[FIN]そんな うわさ話[N]あたしは ぜったい 信じないもん.[PAL:0][END]`

actor_def_07A883 [
  actor-def < #15, #00, #10, {

  code_07A886:
    COP [BranchIfFlagByte] ( #90, #01, &code_07A8D6 )
    COP [SetOnInteract] ( &code_07A8D8 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #90, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #07, #08, #0A, &code_07A8A1 )
    RTL 
} >
]

code_07A8A1 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07A979 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #16, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #11 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_07A8D6 {
    COP [Die]
}

code_07A8D8 {
    COP [BranchIfFlagByte] ( #01, #01, &code_07A8E9 )
    COP [WriteApuIo0] ( #7F )
    STZ $0688
    COP [PrintWideString] ( &widestring_07A8F1 )
    RTL 
}

code_07A8E9 {
    COP [PrintWideString] ( &widestring_07A92B )
    COP [SetFlagByte] ( #90 )
    RTL 
}

widestring_07A8F1 `[TPL:A][TPL:4][SFX:1C]ロブ: テム···[N]この人に 見覚えはないか···?[FIN]そう おれの おやじだよ···[PAL:0][END]`

widestring_07A92B `[TPL:A][TPL:4][SFX:1C]ロブ: どうやら 頭を[N]やられちまっているみたいだ···[FIN]行方不明のおやじに やっと[N]会えたと思ったら これだもんな··[PAL:0][END]`

widestring_07A979 `[TPL:A][TPL:4][SFX:1C]ロブ:[N]テム まってくれ.[N]おれも いくよ.[FIN]今日は これから リリィの[N]たんじょう日 パーティーだしな.[N]暗くなっちゃいられないさ.[FIN]さあ 部屋へ もどろうぜ.[PAL:0][END]`

actor_def_07A9E1 [
  actor-def < #03, #00, #10, {

  code_07A9E4:
    COP [BranchIfFlagByte] ( #97, #01, &code_07AA51 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07AA3B )
    COP [BranchIfFlagByte] ( #91, #01, &code_07AA39 )
    COP [BranchIfFlagByte] ( #90, #00, &code_07AA39 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07AA96 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #27 )
    COP [PrintWideString] ( &widestring_07AACA )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #11 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #04 )
} >
]

code_07AA39 {
    COP [Die]
}

code_07AA3B {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_07AA67 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetEntryContinue]
    RTL 
}

code_07AA51 {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07AA6C )
    COP [SetEntryContinue]
    RTL 
}

code_07AA67 {
    COP [PrintWideString] ( &widestring_07AB01 )
    RTL 
}

code_07AA6C {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07AA7A )
    COP [PrintWideString] ( &widestring_07AB3F )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_07AA7A {
    COP [BranchIfFlagByte] ( #E2, #01, &code_07AA91 )
    COP [PrintWideString] ( &widestring_07AC2D )
    COP [GiveItem] ( #01, &code_07AA8D )
    COP [SetFlagByte] ( #E2 )
    RTL 
}

code_07AA8D {
    JML $@chunk_008000.code_00C7E3
}

code_07AA91 {
    COP [PrintWideString] ( &widestring_07ACEB )
    RTL 
}

widestring_07AA96 `[TPL:A][TPL:4]ロブ: さあ みんな そろった[N]ところで リリィのたんじょう日を[N]祝うとしようか.[END]`

widestring_07AACA `[TPL:A][TPL:4]ロブ: リリィさあ.[N]ちょっと 話があるんだけど[N]いいかな?[FIN]先に 外で 待ってる.[END]`

widestring_07AB01 `[TPL:A][TPL:4]ロブ: さっき[N]おやじに 藥をあたえてきたよ.[FIN]これから ゆっくりと[N]回復していくと思うんだ···[PAL:0][END]`

widestring_07AB3F `[TPL:B][TPL:4]ロブ: みんなには 悪いけど[N]おれは ここに 残るよ.[N]あんな おやじを 放っておくわけに[N]いかないしな.[FIN]それからさ···[N][DLY:2]うーん なんか てれるなあ···[FIN]おれさ.[N]リリィと つきあうことにしたんだ.[FIN]もちろん いいかげんな気持ちじゃ[N]ないさ. ずっと いっしょに[N]いたいと 思ってる.[FIN]で リリィも いっしょに 残りたい[N]っていうからさ.[FIN]みんなと 旅ができて楽しかったよ.[N]テムの 旅の成功をいのってるよ.[PAL:0][END]`

widestring_07AC2D `[TPL:B][TPL:4]ロブ:[N]おやじは 日に日に よくなって[N]いくみたいだ···[FIN]もう ふつうに しゃべれるように[N]なったしな.[N]テムも はやく おやじに[N]会えるといいよな.[FIN]そうそう.[N]たしか テムは 赤い宝石を[N]集めてたんだよな.[FIN]おやじの 持ち物の中から[N]赤い宝石が 見つかったんだよ.[N]もっていきな.[FIN]テムは 赤い宝石をもらった![PAL:0][END]`

widestring_07ACEB `[TPL:B][TPL:4]テムも はやく おやじに[N]会えるといいよな.[PAL:0][END]`

actor_def_07AD0B [
  actor-def < #05, #00, #10, {

  code_07AD0E:
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnAfterRelFlags] ( @code_07AEEF, #$000A, #$FFF4, #$1002 )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07ADE3 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07AE15 )
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_07AE3A )
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @code_07ADB8, #$2000 )
    LDA #$0800
    TSB $10
    LDA #$02F8
    STA $moveXAlt, X
    LDA #$0120
    STA $moveYAlt, X
    COP [MoveToward] ( #06, #02 )
    LDA #$0800
    TRB $10
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_07ADBE, #$2000 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoop] ( #02, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #06, #14 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07ADB8 {
    COP [PrintWideString] ( &widestring_07AE82 )
    COP [Die]
}

code_07ADBE {
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_07AEA1 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #91 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #00, #$1100 )
    COP [Die]
}

widestring_07ADE3 `[DEF][TPL:4]ロブ: うん.[N]早口言葉なんかより ずっと[N]むずかしい 言葉なんだけど···[END]`

widestring_07AE15 `[DEF][TPL:4][DLY:2]ロブ:[N]リリィ···[N][PAU:1E]君のことが 好きだ···[END]`

widestring_07AE3A `[DEF][TPL:4][DLY:2]ロブ:[N]すぐ 返事を してくれなくても[N]いい···[FIN]でもさ [PAU:1E]自分の気持ちを 伝えて[N]おきたかったんだ···[PAL:0][END]`

widestring_07AE82 `[TPL:A][TPL:4][DLY:0]ロブ:[N]リリィ! まってくれっ!![PAU:3C][CLD]`

widestring_07AEA1 `[TPL:A][TPL:0]テム:[N]そんな 事件があったなんて[N]ぼくらは ちっとも 知らなかった.[FIN]その日 リリィは[N]部屋へ もどってこなかった···[PAL:0][END]`

code_07AEEF {
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [Die]

  code_07AEFA:
    COP [StageSpriteFrame] ( #BA )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [Die]
}

actor_def_07AF05 [
  actor-def < #24, #00, #10, {

  code_07AF08:
    COP [AddPosition] ( #08, #00 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07AFA4 )
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #27 )
    COP [PrintWideString] ( &widestring_07B032 )
    COP [StageSpriteMoveX] ( #28, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterRelFlags] ( @code_07AEFA, #$FFF7, #$FFF5, #$1002 )
    COP [StageSpriteLoop] ( #39, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07B075 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [StageSpriteMoveXY] ( #33, #13, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #33, #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #33, #01, #03 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveXY] ( #33, #08, #01, #03 )
    COP [AnimLoop]
    COP [Die]
} >
]

widestring_07AFA4 `[DEF][TPL:2]リリィ: なあに?[FIN]いつもの ロブらしくないよ.[N]なんだか かしこまっちゃってさ.[FIN][TPL:4]ロブ:[N]そうだろ. おれも 自分が[N]自分じゃない みたいだよ.[FIN]これ たんじょう日の プレゼント.[N]いろいろ 考えたんだけど[N]気に入って もらえるかな?[PAL:0][END]`

widestring_07B032 `[DEF][TPL:2]リリィ:[N]わあ. すごおおい.[N]バラの 花たばだっ![FIN]つぼみのバラ···[N]これから 花が開くところなんだね.[END]`

widestring_07B075 `[DEF][TPL:2]リリィ:[N]すてきな かおり···[FIN]ありがとう.[N]すっごく うれしい···[FIN][TPL:4]ロブ: それからさ···[N]プレゼントといっしょに どうしても[N]伝えたい 言葉があるんだ···[FIN][TPL:2]リリィ:[N]なあに?[END]`

actor_def_07B0E5 [
  actor-def < #24, #00, #10, {

  code_07B0E8:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_07B0FA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_07B0FA {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07B108 )
    COP [PrintWideString] ( &widestring_07B10D )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_07B108 {
    COP [PrintWideString] ( &widestring_07B14A )
    RTL 
}

widestring_07B10D `[TPL:B][TPL:3][SFX:10]ロブの父:[N]ぼくね こないだ おともだちと[N]たんけんにいったの.[N]こわかったけど たのしかったあ.[PAL:0][END]`

widestring_07B14A `[TPL:B][TPL:3][SFX:10]ロブの父:[N]おお··· テムじゃないか.[N]心配をかけて すまんかったな.[FIN]ロブと リリィは 本当に[N]いっしょうけんめい かんびょう[N]してくれる···[FIN]むかしは 子供に 自分の人生を[N]左右されたくないと 思っていたが[N]いざ こうなってみると 実の子[N]っていうのは いいもんだよ.[PAL:0][END]`

widestring_07B1F5 `Bが┌ぐ[CLR][8F]ぎど[B2][A9]がぐご(ぐ[BC]げがぐ[END]`

widestring_07B209 `┌[B2]ぐ[DLG:6B,2][E0]ぐ[BF].[B2]ぐ`

widestring_07B216 `[8F]ぐビ"[B2]グ[E0]ゥ[DEF][TPL:0][SFX:10]ダンロノスキマニ╳手帳ガ[N]カクシテアル\\\[FIN][SFX:0]青イ手帳ヲ╳手ニイレタ̋”[PAL:0][END]`

actor_def_07B252 [
  actor-def < #00, #00, #30, {

  code_07B255:
    COP [BranchIfFlagByte] ( #9D, #01, &code_07B271 )
    COP [SetFlagByte] ( #9D )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07B273 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07B271 {
    COP [Die]
}

widestring_07B273 `[TPL:9][TPL:0]ロブの 足どりを追って[N]ぼくは 万里の長城へ やってきた.[FIN]わたりロウカは 地平線のかなたまで[N]果てしなく 続いている···[END]`

actor_def_07B2C5 [
  actor-def < #02, #01, #10, {

  code_07B2C8:
    LDA #$0200
    TSB $12
    LDA $0E
    STA $24
    PHX 
    TAX 
    LDA $@code_07B31C, X
    AND #$00FF
    PLX 
    JSL $@chunk_008000.code_00B565
    BCS loc_07B316
    LDA #$2000
    STA $0E
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetOnInteract] ( &code_07B2F9 )

  loc_07B2EF:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_07B2EF
} >
]

code_07B2F9 {
    COP [PrintWideString] ( &widestring_07B338 )
    COP [BranchIfNoItem] ( #17, &code_07B307 )
    COP [GiveItem] ( #17, &code_07B318 )
}

code_07B307 {
    PHX 
    LDX $24
    LDA $@code_07B31C, X
    AND #$00FF
    PLX 
    JSL $@chunk_008000.code_00B56C

  loc_07B316:
    COP [Die]
}

code_07B318 {
    JML $@chunk_008000.code_00CAD3
}

code_07B31C {
    TYA 
    STA $&scene_warps.warp_def_019B80+1A, Y
    STZ $0AC2
    REP #$00
    EOR ($64, X)
    BIT $&table_018000+4F, X
    EOR ($80, S), Y
    ORA ($00)
    JSR $4B3F
    EOR $633C
    ORA $@gfx_000000+C3, X
}

widestring_07B338 `[TPL:A][TPL:0]きれいな小石が おちている.[FIN]ハッ! これは ロブが[N]リリィのために 作っていた[N]ネックレスのー部だ···[FIN]ネックレスの石を ひろいあげた.[PAL:0][END]`

actor_def_07B395 [
  actor-def < #00, #00, #30, {

  code_07B398:
    COP [BranchIfFlagByte] ( #93, #01, &code_07B41B )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #3B, #08, #3D, #0B, &code_07B3A9 )
    RTL 
} >
]

code_07B3A9 {
    LDA #$0080
    TSB $09FA
    COP [SetFlagByte] ( #93 )
    LDA #$2000
    TRB $10
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintWideString] ( &widestring_07B41D )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteLoopMoveX] ( #33, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #33, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #33, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #33, #13 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07B427 )
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
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07B455 )
    LDA #$EFF0
    TRB $joypadMaskStd
    LDA #$0080
    TRB $09FA
}

code_07B41B {
    COP [Die]
}

widestring_07B41D `[TPL:C][TPL:2]まって!![END]`

widestring_07B427 `[TPL:D][TPL:2]リリィ:[N]ロブを さがしに行くんでしょ?[FIN]あたしも いっしょにいくっ!![END]`

widestring_07B455 `[TPL:E][TPL:2]リリィ: えへへ.[N]こうして テムの ポケットを[N]かりるのも 久しぶりだよね.[FIN]さ 行こっ.[END]`

actor_def_07B490 [
  actor-def < #05, #00, #10, {

  code_07B493:
    COP [BranchIfFlagByte] ( #C8, #01, &code_07B516 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #17, #09, #1B, &code_07B4A6 )
    RTL 
} >
]

code_07B4A6 {
    COP [SpawnAfterFlags] ( @code_07B79D, #$1000 )
    COP [SetOnInteract] ( &code_07B518 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #12, #17, #14, #1B, &code_07B4C0 )
    RTL 
}

code_07B4C0 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [FadeThenStartMusic] ( #15 )
    COP [WaitByte] ( #B3 )
    COP [PrintWideString] ( &widestring_07B654 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07B6A3 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07B708 )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveX] ( #09, #0A, #01 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #96 )
    COP [SetFlagByte] ( #C8 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #80, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_07B516 {
    COP [Die]
}

code_07B518 {
    COP [BranchIfFlagByte] ( #02, #01, &code_07B535 )
    COP [RemoveItem] ( #17 )
    COP [PrintWideString] ( &widestring_07B5BD )
    COP [SetFlagByte] ( #02 )
    LDA #$0200
    TSB $layerPriorityFlag
    LDA #$2000
    TSB $joypadMaskStd

  loc_07B534:
    RTL 
}

code_07B535 {
    COP [PrintWideString] ( &widestring_07B60C )
    COP [SetEntryContinue]
    RTL 
}

code_07B53C {
    REP #$0A
    REP #$02
    PEI ($62)
    PER loc_078AAF
    ADC $@25D4CD, X
    ASL $D5, X
    EOR ($20, S), Y
    TRB $40
    ROR $&parallax_table.binary_01CD36+47
    BRA loc_07B581

  loc_07B554:
    BRA loc_07B4F7

  loc_07B556:
    LSR $4A
    ASL $6F
    EOR $@3D6E3C
    ADC $59D1, X
    EOR $5053, X
    JSR $0B81
    EOR $64
    PHK 
    ADC $@214A6E
    CMP $3D0E
    EOR [$63]
    EOR ($60, S), Y
    ROR $7D7D
    CMP ($C2), Y
    TSB $D4
    ADC $16
    CMP $7F, X
    CMP $685A
    EOR $802050
    AND $&scene_warps.warp_def_01A17E+2
    RTI 
    EOR $4A, S
    EOR ($54, S), Y
    BRA loc_07B5D0

  loc_07B591:
    RTI 
    ROR $4E4A
    CMP $&scene_warps+64
    ROR $634D
    ORA $@map_gs2E+1BE, X
    JSR $5E3F
    ASL $53
    BRA loc_07B543

  loc_07B5A6:
    BRA loc_07B5E5

  loc_07B5A8:
    ADC [$80]
    STZ $&table_018000+47, X
    EOR ($00, X)
    CMP $0280
    BVC loc_07B534
    ORA $@284A6E
    ASL 
    ORA $@gfx_000000+C3, X
}

widestring_07B5BD `[TPL:A][TPL:4]ロブ:[N]あっ その石は·`

loc_07B5D0 {
    ROR $&parallax_table.binary_01D174+A, X
    REP #$00
    PEI ($4D)
    TCD 
    CMP $7F, X
    JSR $5344
    BRA loc_07B5F1

  loc_07B5DF:
    MVP #$65, #$67
    LSR 
    ASL $4D6E
    EOR ($4A, X)
    ADC ($CD, X)
    MVP #$44, #$50
    JSR $3C4C
    LSR 

  loc_07B5F1:
    PLA 
    ASL 
    ORA $@gfx_kress+CD, X
    MVN #$20, #$D4
    ADC $16
    CMP $50, X
    STA ($DE, X)
    EOR [$60]
    ORA $@215820, X
    ROR $&parallax_table.binary_01D21D+2
    INY 
    CMP #$C23C
    ASL 
    REP #$04
    DEC $00, X
    CMP $&array_01D3F7+B, Y
    ADC $16
    CMP $00, X
    JSR $5380
    BRA loc_07B63C

  loc_07B61E:
    ORA $4520
    EOR $5E
    WDM 
    ROR $7E7E, X
    CMP ($D4), Y
    ADC $16
    CMP $7F, X
    CMP $4DD4
    TCD 
    CMP $7E, X
    ROR $207E, X
    PHK 
    ADC ($6E), Y
    LSR $&table_018000+53

  loc_07B63C:
    ORA $0A
    EOR $CD, S
    PEI ($62)
    PER loc_078BAF
    LSR $7520
    BRA loc_07B679

  loc_07B64A:
    BVC loc_07B692
    EOR $6442
    EOR $0F403C
    CPY #$0AC2
    REP #$04
    CMP $&array_01D3F7+B, Y
    ADC $16
    CMP $7F, X
    CMP $5344
    BRA loc_07B676

  loc_07B664:
    EOR ($20, S), Y
    AND $0D0340, X
    JSR $643F
    MVN #$CD, #$80
    ORA $40, S
    ROR $684A
    ASL 

  loc_07B676:
    RTS 
}

code_07B677 {
    EOR $7E7E7E
    CMP ($81), Y
    CMP ($54), Y
    JSR $6444
    JSR $62D4
    PER loc_078BF2
    EOR ($4A, S), Y
    JML $802050
    LDA $6E, S
    LSR 
    CMP $52D4
    ROR $6442
    EOR [$D5]
    JSR $6E0A
    LSR 
    PLA 
    ASL 
    ROR $7E7E, X
    CPY #$0AC2
    REP #$04
    PEI ($65)
    ASL $D5, X
    ADC $@gfx_goldship+22A6, X
    ROR $6442
    EOR [$D5]
    EOR ($80, S), Y
    ORA ($00)
    JSR $3C07
    ASL $68, X
    CMP $2B80
    EOR $@2E4F42
    PHK 
    ADC $@gfx_cliff_enemies+152
    ASL $&table_018000+20
    DEX 
    EOR $4E, S
    ROR $&parallax_table.binary_01CD36+17
    WDM 
    STZ $4F
    BIT $0F40, X
    CMP ($D6), Y
    BRK #$C2
    ASL $D4
    ADC $16
    CMP $54, X
    JSR $52D4
    ROR $6442
    EOR [$D5]
    ADC [$20]
    JMP $014F
    BRA loc_07B68F

  loc_07B6F1:
    LSR $CD
    EOR #$4E6E
    JSR $62D4
    PER loc_078C66
    EOR ($81, S), Y
    SEP #$50
    JSR $DMAP4
    LSR 
    ROR $7E7E, X
    CPY #$C2
    ASL 
    REP #$04
    CMP $&array_01D3F7+9, Y
    ADC $16
    CMP $7F, X
    JSR $5E3C
    ROR $&array_01D3F7+61
    ADC ($D5, S), Y
    ROR $7D7D
    CMP $01D9
    MVP #$68, #$4F
    JSR $3D80
    BRA loc_07B6E7

  loc_07B729:
    ROR $204D
    MVN #$06, #$5C
    EOR $6E0A
    ADC $&parallax_table.binary_01D174+9, X
    STA ($E3, X)
    STA ($E4, X)
    BRK #$20
    STA ($E5, X)
    BRA loc_07B756

  loc_07B73F:
    PHY 
    BVC loc_07B791
    ROR $4E4A
    EOR ($53, X)
    CMP $7374
    ADC ($80, S), Y
    LSR $&01E681, X
    WDM 
    ADC ($3C, X)
    JSR $643D
    LSR $3C
    RTS 
}

code_07B758 {
    ROR $&parallax_table.binary_01D174+9
    REP #$02
    CMP $&array_01D3F7+A, Y
    PER loc_0821C5
    CMP $7F, X
    CMP $4742
    ROR $&parallax_table.binary_01CCD7+48
    TSC 
    LSR 
    LSR $5D
    JSR $683F
    EOR $802006
    AND $3780, X
    PHK 
    ORA $3B45D1, X
    JSR $4980
    BVC loc_07B7A3
    EOR $620E, X
    EOR $7146, Y
    ORA $@2E41CD, X
    LSR $5A20
    PLA 

  loc_07B791:
    EOR $@2D8020
    BRA loc_07B738

  loc_07B797:
    LSR $4D
    ADC $60, S
    ORA $@30A9C0, X
    CMP $065A0C

  loc_07B7A3:
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0068
    STA $moveXAlt, X
    LDA #$01A0
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintWideString] ( &code_07B53C )
    COP [SetFlagByte] ( #01 )
    COP [SetOnInteract] ( &code_07B864 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #28, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #24, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07B891 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07B928 )
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_07B99B )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteLoopMoveX] ( #29, #0A, #01 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_07B864 {
    COP [PrintWideString] ( &widestring_07B869 )
    RTL 
}

widestring_07B869 `[TPL:A][TPL:2]リリィ:[N]もう··· ロブは[N]自分勝手なんだから···[END]`

widestring_07B891 `[TPL:A][TPL:4][DLY:0]ロブ: あっ···[WAI][CLD][PAU:3C][TPL:A][TPL:2][DLY:2]リリィ:[N]今度は にげないから···[FIN]このあいだは とつぜんのことだから[N]びっくりして どうしていいか[N]わからなかったの···[FIN]今は ロブに こんな顔を[N]見られたくないだけ.[FIN]うれしくって なみだが[N]あふれて くるんだもの···[END]`

widestring_07B928 `[TPL:A][TPL:2][DLY:2]リリィ: ロブにはね··[N]はじめて 会ったときから[N]何か ちがうものを感じてたよ···[FIN]そして その 何かが[N]今 わかったような気がするの···[FIN]このあいだの 返事···[N]させてもらうね···[END]`

widestring_07B99B `[TPL:A][TPL:2]リリィ:[N][DLY:3]あたしも ロブのことが好き···[FIN][DLY:2]ずっと いっしょに いられたら[N]いいね···[END]`

actor_def_07B9D5 [
  actor-def < #1C, #00, #02, {

  loc_07B9D8:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearFlagByte] ( #01 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07B9D8
} >
]

actor_def_07BA04 [
  actor-def < #1C, #00, #02, {

  loc_07BA07:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearFlagByte] ( #02 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BA07
} >
]

actor_def_07BA33 [
  actor-def < #1C, #00, #02, {

  loc_07BA36:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearFlagByte] ( #03 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BA36
} >
]

actor_def_07BA62 [
  actor-def < #1C, #00, #02, {

  loc_07BA65:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearFlagByte] ( #04 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BA65
} >
]

actor_def_07BA91 [
  actor-def < #00, #00, #30, {

  code_07BA94:
    COP [BranchIfFlagWord] ( #$0152, #01, &code_07BAD3 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    LDA #$2000
    TRB $10
    LDA #$0278
    STA $moveXAlt, X
    LDA #$0190
    STA $moveYAlt, X
    COP [StageMove] ( #29, #04, #FF )
    COP [TickMove]
    COP [SpawnAfterFlags] ( @chunk_008000.widestring_00CB00, #$2000 )
    COP [StageBgChange] ( #52 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0152 )
} >
]

code_07BAD3 {
    COP [Die]
}

actor_def_07BAD5 [
  actor-def < #00, #00, #30, {

  code_07BAD8:
    COP [BranchIfFlagWord] ( #$0174, #01, &code_07BAF6 )
    COP [SetEntryContinue]
    LDA $0A9F
    AND #$00FF
    CMP #$003F
    BEQ loc_07BAED
    RTL 

  loc_07BAED:
    COP [StageBgChange] ( #74 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0174 )
} >
]

code_07BAF6 {
    COP [SpawnAfterAbsFlags] ( @chunk_088000.code_08D1C3, #$01C8, #$0280, #$0B00 )
    LDA #$0001
    STA $0024, Y
    LDA #$2000
    STA $000E, Y
    COP [Die]
}

actor_def_07BB0F [
  actor-def < #00, #00, #38, {

  code_07BB12:
    COP [BranchIfFlagByte] ( #A5, #01, &code_07BB9F )
    LDA #$0008
    TSB $12
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0800
    TSB $10
    COP [SpawnLastRel] ( @code_07BBBE, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @code_07BBA1, #$2800 )
    COP [WaitByte] ( #27 )
    COP [StageSpriteLoopMoveX] ( #08, #10, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #1E, #02 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetFlagByte] ( #A5 )
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07BCF3 )
    COP [WaitByte] ( #3B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #96, #$00A0, #$0090, #03, #$1100 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_07BB9F {
    COP [Die]
}

code_07BBA1 {
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0080
    STA $cameraTargetX
    STA $cameraDeltaX
    LDA $0016, Y
    SEC 
    SBC #$0080
    STA $cameraTargetY
    STA $cameraDeltaY
    RTL 
}

code_07BBBE {
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07BBC7 )
    COP [Die]
}

widestring_07BBC7 `[DEF][TPL:0][SFX:10][DLY:2]ぼくらは 砂あらしの ふきすさぶ[N]砂ばくを越え エウロの町に[N]たどり着いた.[PAU:78][CLR]エウロは ぼくの 想像をはるかに[N]越えた 大都市で 人々は みな[N]いそがしそうに 動きまわっている.[PAU:B4][CLR]この町には ニールの両親が[N]住んでおり ローレック株式会社を[N]営んでいる.[PAU:78][CLR]ニールは 3年ぶりの 帰宅で[N]両親の かんげいぶりといったら[N]すさまじいものがあった···[PAU:78][CLR]花火は 打ち上がるわ[N]ラインダンサーは 登場するわ[N]もう 町をあげての お祭りが[N]はじまったという 感じだった.[PAU:B4][PAL:0][CLD]`

widestring_07BCF3 `[DEF][TPL:0][SFX:10][DLY:2]そして ここが ニールの両親の[N]住む おやしき.[N]ぼくらは 客間に とおされた.[PAL:0][END]`

actor_def_07BD2C [
  actor-def < #00, #00, #10, {

  code_07BD2F:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    STA $24
    LDA $0E
    AND #$000F
    CLC 
    ADC #$001B
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$3000
    STA $0E
    COP [SetOnInteract] ( &code_07BD5C )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07BD5C {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07BD67 )
}

code_list_07BD67 [
  &code_07BD77   ;00
  &code_07BD78   ;01
  &code_07BD90   ;02
  &code_07BD95   ;03
  &code_07BD9A   ;04
  &code_07BD9F   ;05
  &code_07BDA4   ;06
  &code_07BDA9   ;07
]

code_07BD77 {
    RTL 
}

code_07BD78 {
    COP [BranchIfNoItem] ( #28, &code_07BD87 )
    COP [PrintWideString] ( &widestring_07BDC3 )
    COP [GiveItem] ( #28, &code_07BD8C )
    RTL 
}

code_07BD87 {
    COP [PrintWideString] ( &widestring_07BDAE )
    RTL 
}

code_07BD8C {
    JML $@chunk_008000.code_00CAD3
}

code_07BD90 {
    COP [PrintWideString] ( &widestring_07BDFA )
    RTL 
}

code_07BD95 {
    COP [PrintWideString] ( &widestring_07BE09 )
    RTL 
}

code_07BD9A {
    COP [PrintWideString] ( &widestring_07BE23 )
    RTL 
}

code_07BD9F {
    COP [PrintWideString] ( &widestring_07BE46 )
    RTL 
}

code_07BDA4 {
    COP [PrintWideString] ( &widestring_07BE71 )
    RTL 
}

code_07BDA9 {
    COP [PrintWideString] ( &widestring_07BE94 )
    RTL 
}

widestring_07BDAE `[DEF]あまくておいしい リンゴはいかが?[END]`

widestring_07BDC3 `[DEF]そんな ほしそうな目をして···[N]わかったわよ. ーつ あげるわ.[FIN]テムは リンゴをもらった![END]`

widestring_07BDFA `[DEF]これは 青リンゴよ.[END]`

widestring_07BE09 `[DEF]うちの フルーツは やわらかくて[N]うまいぞ.[END]`

widestring_07BE23 `[DEF]これは お酒.[N]ぼうやには ちょっと はやいかも[N]しれないわね.[END]`

widestring_07BE46 `[DEF]ここは 魚屋.[N]ウォータミアから届く 新せんな魚を[N]売っているの.[END]`

widestring_07BE71 `[DEF]これは とうもろこしの粉.[N]パンの 原料に なるんだよ.[END]`

widestring_07BE94 `[DEF]これは ティアポット.[N]わかりやすく言うと ┌なみだつぼ┘[N]ということになる.[FIN]かつて この町は 戦争に[N]まきこまれたことが あってね,[FIN]女たちは 夫を兵士として 送り[N]出したあと なみだを このツボに[N]ためて 帰りを まっていたという[N]エピソードのある ものなんだ.[END]`

actor_def_07BF2D [
  actor-def < #24, #00, #10, {

  code_07BF30:
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07BF3D [
  actor-def < #25, #00, #10, {

  code_07BF40:
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07BF4D [
  actor-def < #12, #00, #10, {

  code_07BF50:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    LDA #$6000
    STA $0E
    COP [SetOnInteract] ( &code_07BFA6 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07BF7C [
  actor-def < #12, #00, #10, {

  code_07BF7F:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07BFA6 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07BFA6 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07BFB1 )
}

code_list_07BFB1 [
  &code_07BFC7   ;00
  &code_07BFCC   ;01
  &code_07BFD1   ;02
  &code_07BFD6   ;03
  &code_07BFDB   ;04
  &code_07BFE0   ;05
  &code_07BFE5   ;06
  &code_07BFEA   ;07
  &code_07BFEF   ;08
  &code_07BFF4   ;09
  &code_07BFF9   ;0A
]

code_07BFC7 {
    COP [PrintWideString] ( &widestring_07BFFE )
    RTL 
}

code_07BFCC {
    COP [PrintWideString] ( &widestring_07C031 )
    RTL 
}

code_07BFD1 {
    COP [PrintWideString] ( &widestring_07C033 )
    RTL 
}

code_07BFD6 {
    COP [PrintWideString] ( &widestring_07C035 )
    RTL 
}

code_07BFDB {
    COP [PrintWideString] ( &widestring_07C037 )
    RTL 
}

code_07BFE0 {
    COP [PrintWideString] ( &widestring_07C039 )
    RTL 
}

code_07BFE5 {
    COP [PrintWideString] ( &widestring_07C03B )
    RTL 
}

code_07BFEA {
    COP [PrintWideString] ( &widestring_07C03D )
    RTL 
}

code_07BFEF {
    COP [PrintWideString] ( &widestring_07C03F )
    RTL 
}

code_07BFF4 {
    COP [PrintWideString] ( &widestring_07C041 )
    RTL 
}

code_07BFF9 {
    COP [PrintWideString] ( &widestring_07C043 )
    RTL 
}

widestring_07BFFE `[DEF]こらこら こっち側に きちゃ[N]ダメだよ.[N]お客さんは 反対側に まわって[N]おくれっ![END]`

widestring_07C031 `[DEF][END]`

widestring_07C033 `[DEF][END]`

widestring_07C035 `[DEF][END]`

widestring_07C037 `[DEF][END]`

widestring_07C039 `[DEF][END]`

widestring_07C03B `[DEF][END]`

widestring_07C03D `[DEF][END]`

widestring_07C03F `[DEF][END]`

widestring_07C041 `[DEF][END]`

widestring_07C043 `[DEF][END]`

actor_def_07C045 [
  actor-def < #1A, #00, #10, {

  code_07C048:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07C05A )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_07C05A {
    COP [PrintWideString] ( &widestring_07C05F )
    RTL 
}

widestring_07C05F `[DEF]こらこら こっち側に きちゃ[N]ダメだよ.[N]お客さんは 反対側に まわって[N]おくれっ![END]`

actor_def_07C092 [
  actor-def < #17, #00, #10, {

  code_07C095:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_07C0A8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #97 )
    COP [AnimOnce]
    RTL 
} >
]

code_07C0A8 {
    COP [PrintWideString] ( &widestring_07C0AD )
    RTL 
}

widestring_07C0AD `[DEF]こういう お客さんが いるから[N]あたしらは やっていけるんだよ.[END]`

actor_def_07C0D0 [
  actor-def < #02, #00, #10, {

  code_07C0D3:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0002
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07C0F5 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C0F5 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C100 )
}

code_list_07C100 [
  &code_07C112   ;00
  &code_07C117   ;01
  &code_07C11C   ;02
  &code_07C121   ;03
  &code_07C126   ;04
  &code_07C12B   ;05
  &code_07C130   ;06
  &code_07C135   ;07
  &code_07C13A   ;08
]

code_07C112 {
    COP [PrintWideString] ( &widestring_07C14E )
    RTL 
}

code_07C117 {
    COP [PrintWideString] ( &widestring_07C170 )
    RTL 
}

code_07C11C {
    COP [PrintWideString] ( &widestring_07C194 )
    RTL 
}

code_07C121 {
    COP [PrintWideString] ( &widestring_07C1BC )
    RTL 
}

code_07C126 {
    COP [PrintWideString] ( &widestring_07C212 )
    RTL 
}

code_07C12B {
    COP [PrintWideString] ( &widestring_07C246 )
    RTL 
}

code_07C130 {
    COP [PrintWideString] ( &widestring_07C292 )
    RTL 
}

code_07C135 {
    COP [PrintWideString] ( &widestring_07C2BE )
    RTL 
}

code_07C13A {
    COP [PrintWideString] ( &widestring_07C37B )
    RTL 
}

code_07C13F {
    COP [PrintWideString] ( &widestring_07C3C0 )
    RTL 
}

code_07C144 {
    COP [PrintWideString] ( &widestring_07C3C2 )
    RTL 
}

code_07C149 {
    COP [PrintWideString] ( &widestring_07C3C4 )
    RTL 
}

widestring_07C14E `[DEF]ここは エウロ.[N]人口の多い 商人たちの町です.[END]`

widestring_07C170 `[DEF]この先は 居住区.[N]町の人間以外は 入れません.[END]`

widestring_07C194 `[DEF]ここは 市場です.[N]めずらしい品物が 見つかるかも[N]しれませんよ.[END]`

widestring_07C1BC `[DEF]この町が うるおっているのは[N]ローレック株式会社の おかげ.[FIN]悪いうわさも けっこうあるけど[N]ぼくは やっぱり あの会社は[N]すごいと 思いますよ.[END]`

widestring_07C212 `[DEF]ここは 礼拝堂.[N]社長ご夫妻は 信心深い方で[N]よく ここへ いらっしゃいます.[END]`

widestring_07C246 `[DEF]ここはローレック株式会社の事務所.[N]この町で 売られている品物の[N]ほとんどは この会社が 仕入れて[N]いるんですよ.[END]`

widestring_07C292 `[DEF]男: いやあ この会社は[N]何でも あつかってくれるから[N]ほんと 助かるよ.[END]`

widestring_07C2BE `[DEF]小さいころ 兄きと ケレス山に[N]遊びにいったとき 聖域と言われる[N]場所に 迷いこんだことがあるんだ.[FIN]でっかいキノコと 植物のクキが[N]まるで 迷路のように生えてたっけ.[FIN]キノコのしずくを クキのとぎれた[N]場所にたらすと とつぜん 植物が[N]動き出して 通路ができたんだ.[N]これも みんな すてきな思い出さ.[END]`

widestring_07C37B `[DEF]キノコのしずくは 聖域の[N]あちこちに 点在してたんだっけ··[FIN]あーあ 早く 大人になんか[N]なるもんじゃないなあ.[END]`

widestring_07C3C0 `[DEF][END]`

widestring_07C3C2 `[DEF][END]`

widestring_07C3C4 `[DEF][END]`

actor_def_07C3C6 [
  actor-def < #0A, #00, #10, {

  code_07C3C9:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$002A
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07C3EB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C3EB {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C3F6 )
}

code_list_07C3F6 [
  &code_07C3FC   ;00
  &code_07C401   ;01
  &code_07C41B   ;02
]

code_07C3FC {
    COP [PrintWideString] ( &widestring_07C42F )
    RTL 
}

code_07C401 {
    COP [PrintWideString] ( &widestring_07C4A7 )
    COP [DialogueOptions] ( #02, #01, &code_list_07C40B )
}

code_list_07C40B [
  &code_07C411   ;00
  &code_07C416   ;01
  &code_07C411   ;02
]

code_07C411 {
    COP [PrintWideString] ( &widestring_07C536 )
    RTL 
}

code_07C416 {
    COP [PrintWideString] ( &widestring_07C4C3 )
    RTL 
}

code_07C41B {
    COP [PrintWideString] ( &widestring_07C552 )
    RTL 
}

code_07C420 {
    COP [PrintWideString] ( &widestring_07C577 )
    RTL 
}

code_07C425 {
    COP [PrintWideString] ( &widestring_07C579 )
    RTL 
}

code_07C42A {
    COP [PrintWideString] ( &widestring_07C57B )
    RTL 
}

widestring_07C42F `[DEF]この家には 世界的に 有名な[N]大文学者 ロフスキーと[N]バイオリニスト エラスケスが[N]住んでいるの.[FIN]でも 二人は いつもケンカばかり.[N]天才っていうのは 気むずかしい人が[N]多いものね.[END]`

widestring_07C4A7 `[DEF]あなた うらないは 信じるほう?[N] はい[N] いいえ`

widestring_07C4C3 `[CLR]あのね.[N]未来を うらなってもらったら[N]真っ暗なんですって···[FIN]ものすごく 大きい ほうき星が[N]地のふちを かすめて[N]人間は 死に絕えるんですって··[FIN]もう こうなったら[N]やけ食いするしかないわっ!![END]`

widestring_07C536 `[CLR]いいわねえ.[N]あたし 何でも 信じちゃうの···[END]`

widestring_07C552 `[DEF][SFX:10]この町には 力を強くしてくれる[N]人が 住むといいますよ.[END]`

widestring_07C577 `[DEF][END]`

widestring_07C579 `[DEF][END]`

widestring_07C57B `[DEF][END]`

actor_def_07C57D [
  actor-def < #02, #00, #10, {

  code_07C580:
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07C59F )
    LDA #$0002
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_07C593:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07C593
} >
]

code_07C59F {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C5AA )
}

code_list_07C5AA [
  &code_07C5B4   ;00
  &code_07C5B9   ;01
  &code_07C5BE   ;02
  &code_07C5B9   ;03
  &code_07C5B9   ;04
]

code_07C5B4 {
    COP [PrintWideString] ( &widestring_07C5C3 )
    RTL 
}

code_07C5B9 {
    COP [PrintWideString] ( &widestring_07C62D )
    RTL 
}

code_07C5BE {
    COP [PrintWideString] ( &widestring_07C658 )
    RTL 
}

widestring_07C5C3 `[DEF]何日か前に ブラックパンサーとか[N]名乗る男が ふらりと やってきて[N]いろいろと 聞きまわっていたよ.[FIN]あの目つきは 殺し屋に まちがい[N]ないなあ.[N]いったいだれを 追っているんだか.[END]`

widestring_07C62D `[DEF]これは ローレック株式会社の[N]社長夫妻の住む おやしきです.[END]`

widestring_07C658 `[DEF]この町も ずいぶん 変わったよ.[N]ローレック株式会社が 世界的に[N]急成長してから ここは 商人たちの[N]きょ点となっちまった.[FIN]急成長する会社っていうのは[N]必ず 何か 裹があるもんさね.[END]`

actor_def_07C6CF [
  actor-def < #2A, #00, #10, {

  code_07C6D2:
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07C6F1 )
    LDA #$002A
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D

  loc_07C6E5:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07C6E5
} >
]

code_07C6F1 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C6FC )
}

code_list_07C6FC [
  &code_07C706   ;00
  &code_07C70B   ;01
  &code_07C706   ;02
  &code_07C710   ;03
  &code_07C715   ;04
]

code_07C706 {
    COP [PrintWideString] ( &widestring_07C71A )
    RTL 
}

code_07C70B {
    COP [PrintWideString] ( &widestring_07C752 )
    RTL 
}

code_07C710 {
    COP [PrintWideString] ( &widestring_07C788 )
    RTL 
}

code_07C715 {
    COP [PrintWideString] ( &widestring_07C7E3 )
    RTL 
}

widestring_07C71A `[DEF]この町には 細い裹路地が多いわよ.[N]家と 家の すきまに 入りこめたり[N]することもあるの.[END]`

widestring_07C752 `[DEF]あたし 見ちゃったの···[N]礼拝堂の地下に たくさんの人が[N]閉じこめられているのを···[END]`

widestring_07C788 `[DEF]となりの会社には 荷物が たくさん[N]つんであるでしょう?[FIN]ときどき 中から うなり声のする[N]荷物が 運ばれていったりするの.[N]何だか 気味が悪いわ···[END]`

widestring_07C7E3 `[DEF]あたし 見ちゃったの···[N]礼拝堂の地下に たくさんの人が[N]閉じこめられているのを···[END]`

actor_def_07C819 [
  actor-def < #04, #00, #10, {

  code_07C81C:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07C862 )
    COP [BranchIfPlayerAt] ( #$0170, #$00D0, &code_07C82D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C82D {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07C885 )
    COP [SpawnAfterFlags] ( @code_07C857, #$2000 )
    COP [StageSpriteMoveY] ( #06, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_07C857 {
    LDY $decelStepCounter
    LDA $0016, Y
    INC 
    STA $0016, Y
    RTL 
}

code_07C862 {
    COP [PrintWideString] ( &widestring_07C867 )
    RTL 
}

widestring_07C867 `[TPL:A]店員: お帰りですか?[N]ありがとうございました.[END]`

widestring_07C885 `[TPL:A]店員: お客さまっ![N]こっちは 出口でございます.[N]入口の方へ まわってください![END]`

actor_def_07C8B9 [
  actor-def < #2C, #00, #03, {

  code_07C8BC:
    COP [BranchIfPlayerAt] ( #$0170, #$00D0, &code_07C906 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #30, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07C908 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$002A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
} >
]

code_07C906 {
    COP [Die]
}

widestring_07C908 `[TPL:A]店員:[N]あなたは ニールぼっちゃまと[N]この町へ いらした方ですね!![FIN]この お店も ローレック株式会社が[N]営んでいるんですよ.[FIN]連らくは 受けております.[N]お好きな品物を もっていって[N]くださいな.[END]`

actor_def_07C981 [
  actor-def < #00, #00, #30, {

  code_07C984:
    COP [AddPosition] ( #08, #00 )
    COP [SpawnMarkedAfterRel] ( @code_07CA50, #00, #EC, #$1000 )
    COP [SetOnInteract] ( &code_07C998 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C998 {
    COP [BranchIfFlagByte] ( #F0, #01, &code_07C9C2 )
    COP [PrintWideString] ( &widestring_07C9C7 )
    COP [DialogueOptions] ( #02, #02, &code_list_07C9A8 )
}

code_list_07C9A8 [
  &code_07C9AE   ;00
  &code_07C9B3   ;01
  &code_07C9AE   ;02
]

code_07C9AE {
    COP [PrintWideString] ( &widestring_07CA1A )
    RTL 
}

code_07C9B3 {
    COP [SetFlagByte] ( #F0 )
    INC $playerMaxHp
    INC $playerHp
    COP [PrintWideString] ( &widestring_07C9EB )
    COP [Die]
}

code_07C9C2 {
    COP [PrintWideString] ( &widestring_07CA30 )
    RTL 
}

widestring_07C9C7 `[DEF]それは 命の藥です.[N]お飲みに なりますか?[N] はい[N] いいえ`

widestring_07C9EB `[CLR][TPL:0]それは 口が ねじまがりそうな[N]味だった···[FIN]しかし 体力が 上がった!![END]`

widestring_07CA1A `[CLR]そうですか···[N]お気にめしませんか?[END]`

widestring_07CA30 `[DEF]ごめんなさい···[N]おー人樣 ひとつかぎりにしてるの.[END]`

code_07CA50 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    RTL 
}

actor_def_07CA56 [
  actor-def < #00, #00, #30, {

  code_07CA59:
    COP [BranchIfFlagByte] ( #F1, #01, &code_07CA9D )
    COP [AddPosition] ( #08, #00 )
    COP [SpawnMarkedAfterRel] ( @code_07CB68, #00, #EC, #$1000 )
    COP [SetOnInteract] ( &code_07CA73 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07CA73 {
    COP [PrintWideString] ( &widestring_07CAA4 )
    COP [DialogueOptions] ( #02, #02, &code_list_07CA7D )
}

code_list_07CA7D [
  &code_07CA83   ;00
  &code_07CA88   ;01
  &code_07CA83   ;02
]

code_07CA83 {
    COP [PrintWideString] ( &widestring_07CB52 )
    RTL 
}

code_07CA88 {
    LDA $0B1C
    CMP #$0002
    BEQ loc_07CA9F
    LDA #$0001
    STA $0B1C
    COP [SetFlagByte] ( #F1 )
    COP [PrintWideString] ( &widestring_07CAD0 )
}

code_07CA9D {
    COP [Die]

  loc_07CA9F:
    COP [PrintWideString] ( &widestring_07CB2B )
    RTL 
}

widestring_07CAA4 `[DEF]それは ヤミの藥とよばれています.[N]お飲みに なりますか?[N] はい[N] いいえ`

widestring_07CAD0 `[CLR][TPL:0]それは 鼻が ねじまがりそうな[N]においだった···[FIN]しかし フリーダンの ヤミの力が[N]上がったようだ.[FIN][PAL:0]ダークフライヤーの パワーが[N]上がった!![END]`

widestring_07CB2B `[CLR]しかし ダークフライヤーのパワーは[N]じゅうぶん 強いようだ···[END]`

widestring_07CB52 `[CLR]そうですか···[N]お気にめしませんか?[END]`

code_07CB68 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    RTL 
}

actor_def_07CB6E [
  actor-def < #15, #00, #10, {

  code_07CB71:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07CB8E )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #06, #07, #07, #08, &code_07CB87 )
    RTL 
} >
]

code_07CB87 {
    COP [PrintWideString] ( &widestring_07CBDD )
    COP [SetEntryContinue]
    RTL 
}

code_07CB8E {
    COP [PrintWideString] ( &widestring_07CB93 )
    RTL 
}

widestring_07CB93 `[TPL:A][TPL:4]会社の人:[N]あわわ····[N]なんだ 子供か····[FIN]おじさんたちは お仕事の話を[N]してるんだから あっちへいって[N]なさい![END]`

widestring_07CBDD `[TPL:A][SFX:0][TPL:0]何か 仕事の話ををしている[N]ようだな···[FIN][SFX:10][PAL:0]男: この会社と 明り引きすれば[N]どんなものでも 手に入ると[N]聞いたんですけど···[FIN][TPL:4]会社の人: ええ.[N]うちは 何でも やってますよ.[N]お茶や くだものから 毛皮···[FIN]あとは 大きい声では 言えませんが[N]労働力や 女も···[PAL:0][END]`

actor_def_07CC8E [
  actor-def < #02, #00, #10, {

  code_07CC91:
    COP [AddPosition] ( #08, #00 )
    COP [SetSpritePriority] ( #10 )

  loc_07CC98:
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveY] ( #06, #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoopMoveX] ( #02, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #02, #04 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    BRA loc_07CC98

  loc_07CCC9:
    COP [GenHdmaSine]
    BPL loc_07CCCF
    LDY $&01FE00, X
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07CCD6 [
  actor-def < #36, #00, #10, {

  code_07CCD9:
    LDA #$0200
    TSB $12
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07CCEB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07CCEB {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07CCF6 )
}

code_list_07CCF6 [
  &code_07CD00   ;00
  &code_07CD05   ;01
  &code_07CD0A   ;02
  &code_07CD0F   ;03
  &code_07CD14   ;04
]

code_07CD00 {
    COP [PrintWideString] ( &widestring_07CD19 )
    RTL 
}

code_07CD05 {
    COP [PrintWideString] ( &widestring_07CD85 )
    RTL 
}

code_07CD0A {
    COP [PrintWideString] ( &widestring_07CDAB )
    RTL 
}

code_07CD0F {
    COP [PrintWideString] ( &widestring_07CDDD )
    RTL 
}

code_07CD14 {
    COP [PrintWideString] ( &widestring_07CE0B )
    RTL 
}

widestring_07CD19 `[DEF]わたしたちの こきょう[N]近ごろ いろんな 病気[N]はやりだした···[FIN]ひどい 病気だと[N]体が 石に かわっていく[N]ものもある····[FIN]だから わたし ドレイとしてでも[N]遠くの国に にげる···[END]`

widestring_07CD85 `[DEF]母国の言葉 しゃべりたい··[N]でも そうすると たたかれる···[END]`

widestring_07CDAB `[DEF]そこに ころがっている骨[N]わたしたちの 仲間···[N]命皮に したがわないと そうなる.[END]`

widestring_07CDDD `[DEF]わたしたち ここで 言葉を[N]教えこまれ また 别のところへ[N]売られていく···[END]`

widestring_07CE0B `[DEF]わたし 少しだけ 言葉 わかる.[N]わたしたち 遠い場所から ここへ[N]つれてこられた···[END]`

actor_def_07CE3F [
  actor-def < #02, #00, #10, {

  code_07CE42:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #04 )
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_07CE5A [
  actor-def < #00, #00, #30, {

  code_07CE5D:
    LDA #$0188
    TSB $12
    LDA $0E
    LSR 
    AND #$0038
    CLC 
    ADC #$0002
    STA $26
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@chunk_068000.code_06B7AB
    COP [SetOnInteract] ( &code_07CFA2 )
    TXY 
    LDA $24
    STA $0000
    BEQ loc_07CE8F

  loc_07CE86:
    LDA $0004, Y
    TAY 
    DEC $0000
    BNE loc_07CE86

  loc_07CE8F:
    TYA 
    STA $20
    COP [SolidHighHere]
    BRA loc_07CF01

  code_07CE96:
    COP [SetTilePos] ( #2C, #40 )
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [AnimOneFrame]

  loc_07CEAE:
    LDA $16
    CMP #$0420
    BEQ loc_07CEF3
    BRA loc_07CEB9

  code_07CEB7:
    COP [SetEntryExit]

  loc_07CEB9:
    JSR $&code_07D102
    BCS code_07CEB7
    COP [BranchIfSolidSouth] ( &code_07CEB7 )
    JSR $&code_07D182
    BCC code_07CEB7
    COP [SolidHighOffset] ( #00, #01 )
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [StageForceMoveY] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [AnimOneFrame]
    JSR $&code_07D0EE
    BCS loc_07CEAE
    COP [ClearLowOffset] ( #00, #FF )
    BRA loc_07CEAE

  loc_07CEF3:
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]

  loc_07CF01:
    LDA $14
    CMP #$0228
    BEQ loc_07CF46
    BRA loc_07CF0C

  code_07CF0A:
    COP [SetEntryExit]

  loc_07CF0C:
    JSR $&code_07D144
    BCS code_07CF0A
    COP [BranchIfSolidWest] ( &code_07CF0A )
    JSR $&code_07D172
    BCC code_07CF0A
    COP [SolidHighOffset] ( #FF, #00 )
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [StageForceMoveX] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [AnimOneFrame]
    JSR $&code_07D130
    BCS loc_07CF01
    COP [ClearLowOffset] ( #01, #00 )
    BRA loc_07CF01

  loc_07CF46:
    LDA $16
    CMP #$0400
    BEQ loc_07CF98
    BRA loc_07CF51

  code_07CF4F:
    COP [SetEntryExit]

  loc_07CF51:
    JSR $&code_07D0EE
    BCS code_07CF4F
    JSR $&code_07D18A
    BCC code_07CF4F
    COP [BranchIfSolidNorth] ( &code_07CF4F )
    LDA $16
    CMP #$0410
    BNE loc_07CF6A
    COP [BranchIfSolidNorth] ( &code_07CF4F )

  loc_07CF6A:
    LDA $26
    CLC 
    ADC #$0005
    STA $28
    STZ $2A
    COP [SolidHighOffset] ( #00, #FF )
    COP [StageForceMoveY] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0005
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSR $&code_07D102
    BCS loc_07CF46
    COP [ClearLowOffset] ( #00, #01 )
    BRA loc_07CF46

  loc_07CF98:
    LDA #$2000
    TSB $10
    COP [SetEntryExitNow] ( @code_07CE96 )
} >
]

code_07CFA2 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07CFAD )
}

code_list_07CFAD [
  &code_07CFB9   ;00
  &code_07CFBE   ;01
  &code_07CFC3   ;02
  &code_07CFC8   ;03
  &code_07CFCD   ;04
  &code_07CFD2   ;05
]

code_07CFB9 {
    COP [PrintWideString] ( &widestring_07CFD7 )
    RTL 
}

code_07CFBE {
    COP [PrintWideString] ( &widestring_07CFF5 )
    RTL 
}

code_07CFC3 {
    COP [PrintWideString] ( &widestring_07D021 )
    RTL 
}

code_07CFC8 {
    COP [PrintWideString] ( &widestring_07D03D )
    RTL 
}

code_07CFCD {
    COP [PrintWideString] ( &widestring_07D068 )
    RTL 
}

code_07CFD2 {
    COP [PrintWideString] ( &widestring_07D094 )
    RTL 
}

widestring_07CFD7 `[DEF]このお店では すてきなものが[N]売られているんですよ.[END]`

widestring_07CFF5 `[DEF]人間っていうのは 行列を見ると[N]どうして ならびたくなるん[N]ですかね···[END]`

widestring_07D021 `[DEF]わたしなんか もう 何回 ならんで[N]いることか.[END]`

widestring_07D03D `[DEF]苦労して 手に入れたものは[N]それだけ よろこびが 大きいもん[N]ですねえ.[END]`

widestring_07D068 `[DEF]人間っていうのは 行列を見ると[N]どうして ならびたくなるん[N]ですかね···[END]`

widestring_07D094 `[DEF]このお店では 命の藥とかいうものが[N]売られているんだよ.[FIN]本当に 効くのかどうかは わからんが[N]長く生きたいという 気持ちは[N]だれでも もっているからね.[END]`

code_07D0EE {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    BRA loc_07D114
}

code_07D102 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $16
    CLC 
    ADC #$0010
    STA $001C

  loc_07D114:
    LDA $001C
    CMP $0016, Y
    BNE loc_07D123
    LDA $14
    CMP $0014, Y
    BEQ loc_07D12E

  loc_07D123:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_07D114
    CLC 
    RTS 

  loc_07D12E:
    SEC 
    RTS 
}

code_07D130 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    BRA loc_07D156
}

code_07D144 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018

  loc_07D156:
    LDA $0018
    CMP $0014, Y
    BNE loc_07D165
    LDA $16
    CMP $0016, Y
    BEQ loc_07D170

  loc_07D165:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_07D156
    CLC 
    RTS 

  loc_07D170:
    SEC 
    RTS 
}

code_07D172 {
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    BRA loc_07D198
}

code_07D182 {
    LDA $16
    CLC 
    ADC #$0010
    BRA loc_07D190
}

code_07D18A {
    LDA $16
    SEC 
    SBC #$0010

  loc_07D190:
    STA $001C
    LDA $14
    STA $0018

  loc_07D198:
    LDA $playerWallType
    CLC 
    ADC #$0008
    SEC 
    SBC $0018
    BPL loc_07D1A9
    EOR #$FFFF
    INC 

  loc_07D1A9:
    CMP #$000D
    BCC loc_07D1AF
    RTS 

  loc_07D1AF:
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    SEC 
    SBC $001C
    BPL loc_07D1C0
    EOR #$FFFF
    INC 

  loc_07D1C0:
    CMP #$000D
    RTS 
}

actor_def_07D1C4 [
  actor-def < #00, #00, #20, {

  loc_07D1C7:
    COP [SetEntryContinue]
    COP [BranchIfSolid] ( &code_07D1CE )
    RTL 
} >
]

code_07D1CE {
    COP [WaitWord] ( #$0707 )
    COP [ClearLowHere]
    BRA loc_07D1C7
}

actor_def_07D1D6 [
  actor-def < #24, #00, #10, {

  code_07D1D9:
    COP [BranchIfFlagByte] ( #9E, #01, &code_07D1F5 )
    COP [SetFlagByte] ( #9E )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07D29B )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07D1F5 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D1FE )
    COP [SetEntryContinue]
    RTL 
}

code_07D1FE {
    COP [BranchIfNoItem] ( #19, &code_07D208 )
    COP [PrintWideString] ( &widestring_07D20D )
    RTL 
}

code_07D208 {
    COP [PrintWideString] ( &widestring_07D338 )
    RTL 
}

widestring_07D20D `[TPL:B][TPL:3]ロフスキー:[N]今 口論になっておったのは[N]ケレス山の聖域に まつられている[N]ティアポットのことなんじゃよ.[FIN]ケレス山には かつて 神の流した[N]なみだが 安置されていてな,[N]それが 人類を救うという 言い伝え[N]があるんじゃ.[PAL:0][END]`

widestring_07D29B `[TPL:9][TPL:0]老人 二人が なにやら[N]言い争っている···[WAI][CLD][PAU:1E][TPL:B][TPL:3]ロフスキー:[N]何が 天才 バイオリニストじゃ![N]天災みたいな音を たておってっ!![FIN][TPL:3][TPL:4]エラスケス:[N]ふん! おまえこそ ウソばかり[N]書きちらす 三文モノカキのくせに[N]大口たたくなっ!![END]`

widestring_07D338 `[TPL:A][TPL:3]ロフスキー:[N]おお それこそ ティアポット···[N]実在するものであったのか···[PAL:0][END]`

actor_def_07D36D [
  actor-def < #2D, #00, #10, {

  code_07D370:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D379 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07D379 {
    COP [BranchIfNoItem] ( #19, &code_07D391 )
    COP [BranchIfFlagByte] ( #9F, #01, &code_07D38C )
    COP [SetFlagByte] ( #9F )
    COP [PrintWideString] ( &widestring_07D396 )
    RTL 
}

code_07D38C {
    COP [PrintWideString] ( &widestring_07D475 )
    RTL 
}

code_07D391 {
    COP [PrintWideString] ( &widestring_07D4A7 )
    RTL 
}

widestring_07D396 `[TPL:B][TPL:4]エラスケス: そこの お前···[N]そなたからは 何か 不思議な力を[N]感じる···[FIN]わしの目は もう 見えんのじゃが[N]そうなると 感が さえてきてな[N]特别なものには びんかんに 反応[N]するんじゃよ.[FIN]ちょうど いい.[N]ケレス山の聖域へ行って[N]ティアポットの樣子を 見てきて[N]くれんか?[FIN][TPL:0]ロフスキーは テムの地図に[N]ケレス山の場所を 書きこんで[N]くれた![PAL:0][END]`

widestring_07D475 `[TPL:B][TPL:4]エラスケス:[N]ティアポットの 神のなみだは[N]真実の姿を うつすという.[PAL:0][END]`

widestring_07D4A7 `[TPL:A][TPL:4]エラスケス:[N]町の いずこからか まものの気配が[N]ただよってくる···[FIN]わしは まものが 町の人に[N]すりかわっているような 気がする[N]んじゃよ.[FIN]それは 広場の往来の人かもしれんし[N]お前の 友達かもしれんし[N]わしかもしれん.[FIN]お前が あやしいと思う人物に[N]ティアポットを 使ってみるがよい.[PAL:0][END]`

actor_def_07D556 [
  actor-def < #1A, #00, #10, {

  code_07D559:
    COP [BranchIfFlagByte] ( #AC, #01, &code_07D595 )
    COP [BranchIfFlagByte] ( #AB, #01, &code_07D58C )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D597 )
    COP [AddPosition] ( #00, #FE )
    COP [ExitIfFlagByte] ( #AA, #01 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
} >
]

code_07D58C {
    COP [SetOnInteract] ( &code_07D59C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_07D595 {
    COP [Die]
}

code_07D597 {
    COP [PrintWideString] ( &widestring_07D5D1 )
    RTL 
}

code_07D59C {
    COP [PrintWideString] ( &widestring_07D611 )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0004
    STA $0D64
    LDA #$0006
    STA $0D66
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$01D4, #$0134, #00, #19 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    RTL 
}

widestring_07D5D1 `[TPL:A][TPL:1]カレン: すっごい 家よね···[N]最近は 国王より 民間人の方が[N]お金もちなのかしら···[PAL:0][END]`

widestring_07D611 `[TPL:A][TPL:1]カレン: ここから 西に向かうと[N]アンコールワットの 遺跡が[N]あるらしいわ.[FIN]ちょうど そのあたりが[N]ドレイたちの こきょうに あたる[N]みたい.[FIN]さあ いってみましょ!![PAL:0][END]`

actor_def_07D677 [
  actor-def < #0A, #00, #10, {

  code_07D67A:
    COP [BranchIfFlagByte] ( #AC, #01, &code_07D689 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D68B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07D689 {
    COP [Die]
}

code_07D68B {
    COP [BranchIfFlagByte] ( #AA, #01, &code_07D696 )
    COP [PrintWideString] ( &widestring_07D69B )
    RTL 
}

code_07D696 {
    COP [PrintWideString] ( &widestring_07D6D2 )
    RTL 
}

widestring_07D69B `[TPL:A][TPL:3]エリック: こんな 広い家だと[N]夜 おしっこに いきたくなったら[N]どうするんだろ···[PAL:0][END]`

widestring_07D6D2 `[TPL:A][TPL:3]エリック:[N]女の子って つくづくわかんないよ.[PAL:0][END]`

actor_def_07D6F4 [
  actor-def < #13, #00, #10, {

  code_07D6F7:
    COP [BranchIfFlagByte] ( #AC, #01, &code_07D72C )
    COP [BranchIfFlagByte] ( #AB, #01, &code_07D7A1 )
    COP [BranchIfFlagByte] ( #AA, #01, &code_07D72E )
    COP [BranchIfFlagByte] ( #A4, #01, &code_07D72C )
    COP [SetFlagByte] ( #A4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07D7B8 )
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07D72C {
    COP [Die]
}

code_07D72E {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetTilePos] ( #0A, #11 )
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07D802 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_07D827 )
    COP [WaitByte] ( #27 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07D92E )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #10 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07D982 )
    COP [SpawnAfterRelFlags] ( @code_07DA7E, #$0000, #$0020, #$1800 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StartMusic] ( #02 )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_07D99D )
    COP [SetFlagByte] ( #AB )
    COP [SetOnInteract] ( &code_07D7B3 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_07D7A1 {
    COP [SetTilePos] ( #0A, #0A )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D7B3 )
    COP [SetEntryContinue]
    RTL 
}

code_07D7B3 {
    COP [PrintWideString] ( &widestring_07DA65 )
    RTL 
}

widestring_07D7B8 `[TPL:A][TPL:6]ニール:[N]じゃあ この部屋で ゆっくり[N]しててくれよ.[FIN]ぼくは 両親と しばらく[N]話してくる.[N]もう 3年ぶりだしね.[PAL:0][END]`

widestring_07D802 `[TPL:A][TPL:0]そして 翌朝.[N]残念な出来事が 待っていた···[END]`

widestring_07D827 `[TPL:B][TPL:6]ニール: おはよう.[N]みんなには 心配かけたな···[FIN]ー晚中 考えたんだけど[N]この会社は やっぱり ぼくが[N]つがなきゃいけないと思うんだ.[FIN]なんとかして ドレイ貿易を[N]やめさせたいし,[N]それには まず ドレイ貿易を始めた会社が 動くべきだと思う···[FIN]人の不幸と ひきかえに お金を[N]手に入れたって しかたがないしね.[FIN][TPL:1]カレン:[N]じゃ ニールは 社長になるわけね?[N]すごおおおおい!![FIN][TPL:6]ニール: えへへ.[N]なんだか 照れちゃうな.[END]`

widestring_07D92E `[TPL:A][TPL:6]ニール: あ それからさ カレン.[N]君を たずねてきてる人がいるんだ.[N]むかしの 恋人だって話だぜ.[FIN][TPL:1]カレン:[N]えっ!!!!!!!?[END]`

widestring_07D982 `[TPL:A][TPL:6]ニール:[N]おーい 入っておいでっ![END]`

widestring_07D99D `[TPL:A][TPL:1][DLY:0]カレン:[N]ペギーっ!!![FIN][TPL:6][DLY:1]ブヒブヒッ!![FIN][TPL:1]どうしたのっ?![N]元気だった?![FIN][TPL:6]ニール: ははは.[N]君を 追っかけて はるばる[N]旅してきた みたいだぜ.[FIN]リリィが 水上都市で 発見して[N]送って来たのさ.[N]ローレックの配達便を 使ってね.[FIN]ぼくが 旅の仲間から ぬけても[N]力強い 味方が 增えたろ?[PAL:0][END]`

widestring_07DA65 `[TPL:A][TPL:6]ニール:[N]みんな 元気でな.[PAL:0][END]`

code_07DA7E {
    COP [StageSpriteMoveY] ( #2F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #02, #12 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DAA7 )
    COP [SetFlagByte] ( #02 )
    COP [SetEntryContinue]
    RTL 
}

code_07DAA7 {
    COP [PrintWideString] ( &widestring_07DAAC )
    RTL 
}

widestring_07DAAC `[TPL:8][TPL:1]ブヒブヒッ[PAL:0][END]`

actor_def_07DABA [
  actor-def < #14, #00, #10, {

  code_07DABD:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DAC6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07DAC6 {
    COP [BranchIfFlagByte] ( #D6, #01, &code_07DAE9 )
    COP [PrintWideString] ( &widestring_07DB30 )
    COP [DialogueOptions] ( #02, #02, &code_list_07DAD6 )
}

code_list_07DAD6 [
  &code_07DADC   ;00
  &code_07DAE4   ;01
  &code_07DADC   ;02
]

code_07DADC {
    COP [PrintWideString] ( &widestring_07DC2B )
    COP [SetFlagByte] ( #D6 )
    RTL 
}

code_07DAE4 {
    COP [PrintWideString] ( &widestring_07DBE6 )
    RTL 
}

code_07DAE9 {
    COP [BranchIfFlagByte] ( #E5, #01, &code_07DB2B )
    COP [BranchIfNoItem] ( #28, &code_07DAF9 )
    COP [PrintWideString] ( &widestring_07DC6B )
    RTL 
}

code_07DAF9 {
    COP [BranchIfFlagByte] ( #E3, #00, &code_07DB19 )
    COP [BranchIfFlagByte] ( #E4, #00, &code_07DB1E )
    COP [RemoveItem] ( #28 )
    COP [PrintWideString] ( &widestring_07DC9E )
    COP [GiveItem] ( #01, &code_07DB15 )
    COP [SetFlagByte] ( #E5 )
    RTL 
}

code_07DB15 {
    JML $@chunk_008000.code_00C7E3
}

code_07DB19 {
    COP [SetFlagByte] ( #E3 )
    BRA loc_07DB23
}

code_07DB1E {
    COP [SetFlagByte] ( #E4 )
    BRA loc_07DB23

  loc_07DB23:
    COP [RemoveItem] ( #28 )
    COP [PrintWideString] ( &widestring_07DC72 )
    RTL 
}

code_07DB2B {
    COP [PrintWideString] ( &widestring_07DD2B )
    RTL 
}

widestring_07DB30 `[TPL:B][TPL:1]アン: 何日か前のことだけど[N]青黒いマントを はおった男が[N]入ってきてね,[FIN]カレンという娘が この町に[N]きてないかって 言うのよ.[FIN]あの こおりそうな目を 見ただけで[N]あたし ちぢみ あがっちゃった.[FIN]このこと カレンに[N]話しても いいんだけどさ···[N] 勝手にすれば![N] お願いだから話さないでくれっ!`

widestring_07DBE6 `[CLR]あの カレンって娘 どことなく[N]おじょう樣ぶってて 気にくわない[N]のよ.[FIN]あなたが そういうなら[N]いじめちゃおっかなあ.[PAL:0][END]`

widestring_07DC2B `[CLR]えへへ.[N]弱みを にぎっちゃった.[FIN][::]あーあ.[N]あたし リンゴが 食べたいなあ.[N]市場で 買ってきてっ![PAL:0][END]`

widestring_07DC6B `[TPL:B][TPL:1][JMP:&chunk_078000.widestring_07DC2B+M]`

widestring_07DC72 `[TPL:B][TPL:1]アン: ありがと.[N]あたし もういっこ 食べたく[N]なっちゃったなあ.[PAL:0][END]`

widestring_07DC9E `[TPL:B][TPL:1]アン:[N]どうして そんなに 何度も[N]市場と 往復して リンゴを[N]もってきてくれるの··?[FIN]カレンっていう 女の子のため··?[N]それとも···?[FIN]まあ いいわ.[N]おれいに この宝石をあげる.[FIN]テムは 赤い宝石を 手に入れた![PAL:0][END]`

widestring_07DD2B `[TPL:B][TPL:1]アン:[N]カレンを 大切にしてあげてね···[PAL:0][END]`

actor_def_07DD4D [
  actor-def < #02, #00, #10, {

  code_07DD50:
    COP [BranchIfFlagByte] ( #A8, #01, &code_07DDAD )
    LDA #$1200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DDAF )
    COP [AddPosition] ( #00, #FE )
    COP [ExitIfFlagByte] ( #A8, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [ClearLowHere]
    COP [AddPosition] ( #00, #F0 )
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2F, #06 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07DDE6 )
    LDA #$0268
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #01 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #77 )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_07DDAD {
    COP [Die]
}

code_07DDAF {
    COP [PrintWideString] ( &widestring_07DDB4 )
    RTL 
}

widestring_07DDB4 `[TPL:A]ニールの父:[N]ローレック株式会社の あとを[N]ついで そんは ないと思うぞ.[END]`

widestring_07DDE6 `[TPL:A]月の種族: クックククククク···[N]もうじき この世界も ヤミに[N]つつまれる.[FIN]さっきの体の持ち主は 礼拝堂の[N]地下で 骨となってねむっているよ.[END]`

actor_def_07DE44 [
  actor-def < #0D, #00, #10, {

  code_07DE47:
    COP [BranchIfFlagByte] ( #A8, #01, &code_07DE81 )
    LDA #$1200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DE83 )
    COP [ExitIfFlagByte] ( #A8, #01 )
    COP [ClearLowHere]
    COP [AddPosition] ( #00, #F0 )
    COP [StageSpriteLoopMoveY] ( #2F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2F, #06 )
    COP [AnimLoop]
    LDA #$0268
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #01 )
} >
]

code_07DE81 {
    COP [Die]
}

code_07DE83 {
    COP [PrintWideString] ( &widestring_07DE88 )
    RTL 
}

widestring_07DE88 `[TPL:B]ニールの母:[N]あたしたちは もう お金も[N]いっぱい もうけたし あとは[N]余生を 遊んでくらしたいのよ.[FIN]後を ついでくれないかねえ··[END]`

actor_def_07DED6 [
  actor-def < #1A, #00, #10, {

  code_07DED9:
    COP [BranchIfFlagByte] ( #AA, #01, &code_07DEEC )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DEEE )
    COP [AddPosition] ( #00, #FE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07DEEC {
    COP [Die]
}

code_07DEEE {
    COP [BranchIfFlagByte] ( #A8, #01, &code_07DEF9 )
    COP [PrintWideString] ( &widestring_07DF11 )
    RTL 
}

code_07DEF9 {
    COP [PrintWideString] ( &widestring_07DF45 )
    COP [SetFlagByte] ( #AA )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #96, #$00A0, #$0090, #03, #$1100 )
    RTL 
}

widestring_07DF11 `[TPL:B]ニール:[N]自分のために 生きるべきか[N]人のために 生きるべきかって[N]ことだよな···[END]`

widestring_07DF45 `[TPL:B][TPL:6][DLY:2]ニール:[N]···········[FIN]しばらく 家を はなれていて[N]やっと 親の ありがたさが[N]わかったというのに···[FIN]テム···[N]悪いけど しばらく ー人に[N]しておいてくれ···[FIN][TPL:0][DLY:1]ニ-ルは そう言うと うつむいて[N]しまった···[N]ぼくは こんな ニールを見るのは[N]初めてだった···[END]`

actor_def_07DFED [
  actor-def < #27, #00, #10, {

  code_07DFF0:
    LDA #$0200
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetOnInteract] ( &code_07DFFF )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07DFFF {
    COP [PrintWideString] ( &widestring_07E004 )
    RTL 
}

widestring_07E004 `[DEF]それは ロフスキーという人が書いた[N]本だよ.[N]人類の未来を 予言しているのさ.[END]`

actor_def_07E038 [
  actor-def < #02, #00, #10, {

  code_07E03B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07E044 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E044 {
    COP [BranchIfFlagByte] ( #A6, #01, &code_07E059 )
    COP [SetFlagByte] ( #A6 )
    COP [PrintWideString] ( &widestring_07E05E )
    LDA $playerStr
    INC 
    STA $playerStr
    RTL 
}

code_07E059 {
    COP [PrintWideString] ( &widestring_07E092 )
    RTL 
}

widestring_07E05E `[DEF]よく ここが わかりましたね.[N]あなたの のぞみは わかります.[N]さっそく 力を 上げましょう.[END]`

widestring_07E092 `[DEF]さあ いきなさい.[END]`

actor_def_07E09D [
  actor-def < #00, #00, #30, {

  code_07E0A0:
    COP [SetOnInteract] ( &code_07E0D1 )

  code_07E0A4:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_07E0BC )
    COP [BranchIfPlayerInAbsTiles] ( #0F, #07, #10, #09, &code_07E0B8 )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_07E0B8 {
    COP [SetFlagByte] ( #00 )
    RTL 
}

code_07E0BC {
    COP [PlaySoundBoth] ( #$0101 )
    COP [StageBgChange] ( #69 )
    COP [ApplyBgChange]
    COP [SetOnInteract] ( #$0000 )
    COP [ClearFlagByte] ( #01 )
    COP [SetEntryExitNow] ( @code_07E0A4 )
}

code_07E0D1 {
    COP [PrintWideString] ( &widestring_07E0EE )
    COP [DialogueOptions] ( #02, #01, &code_list_07E0DB )
}

code_list_07E0DB [
  &code_07E0E1   ;00
  &code_07E0E6   ;01
  &code_07E0E1   ;02
]

code_07E0E1 {
    COP [PrintWideString] ( &widestring_07E12E )
    RTL 
}

code_07E0E6 {
    COP [PrintWideString] ( &widestring_07E12E )
    COP [SetFlagByte] ( #01 )
    RTL 
}

widestring_07E0EE `[DEF][TPL:0]テム: おや?[N]神像のうしろから 風が 吹きこんで[N]いるみたいだ···[FIN]調べてみますか?[N] はい[N] いいえ`

widestring_07E12E `[CLD]`

actor_def_07E130 [
  actor-def < #0A, #00, #10, {

  code_07E133:
    COP [BranchIfFlagByte] ( #A7, #01, &code_07E142 )
    COP [SetOnInteract] ( &code_07E144 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E142 {
    COP [Die]
}

code_07E144 {
    COP [PrintWideString] ( &widestring_07E149 )
    RTL 
}

widestring_07E149 `[DEF]フリーゼル:[N]私は 探険家のフリーゼル.[FIN]いだいなる探険家 オールマンが[N]バベルの塔を 発見したように[N]私も 歷史に名を残すつもりだよ.[END]`

actor_def_07E1A6 [
  actor-def < #05, #00, #10, {

  code_07E1A9:
    COP [BranchIfFlagByte] ( #A7, #01, &code_07E142 )
    COP [SetOnInteract] ( &code_07E1B8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E1B8 {
    COP [PrintWideString] ( &widestring_07E1BD )
    RTL 
}

widestring_07E1BD `[DEF]マックス:[N]今度は どこへ 探険に 連れて[N]いかれるんだろう···[FIN]まったく 隊長の 気まぐれにも[N]困ったもんだよ. トホホ.[END]`

actor_def_07E20B [
  actor-def < #04, #00, #10, {

  code_07E20E:
    COP [BranchIfFlagByte] ( #A7, #01, &code_07E142 )
    COP [SetOnInteract] ( &code_07E21D )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E21D {
    COP [PrintWideString] ( &widestring_07E222 )
    RTL 
}

widestring_07E222 `[DEF]ルディー: 遺跡っていうのは[N]本当に いいもんですよ.[N]心を そう大な旅に つれだして[N]くれますからねえ.[END]`

actor_def_07E262 [
  actor-def < #00, #00, #30, {

  code_07E265:
    COP [BranchIfFlagByte] ( #A7, #01, &code_07E281 )
    COP [SetFlagByte] ( #A7 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07E283 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07E281 {
    COP [Die]
}

widestring_07E283 `[TPL:E][TPL:0]ケレス山の 山頂付近には[N]不思議な場所が 広がっていた.[FIN]ぼくの 何倍もあるキノコが 乱立し[N]見たこともない 植物のクキが[N]入り乱れて 走っている···[PAL:0][END]`

actor_def_07E2F1 [
  actor-def < #00, #00, #30, {

  code_07E2F4:
    COP [BranchIfFlagWord] ( #$0159, #01, &code_07E33F )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #54 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #55 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #56 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #57 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #58 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #59 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0159 )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_07E33F {
    COP [Die]
}

actor_def_07E341 [
  actor-def < #00, #00, #30, {

  code_07E344:
    COP [BranchIfFlagWord] ( #$015F, #01, &code_07E33F )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5A )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5B )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5C )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5D )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5E )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$015F )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

actor_def_07E391 [
  actor-def < #00, #00, #30, {

  code_07E394:
    COP [BranchIfFlagWord] ( #$0167, #01, &code_07E33F )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #60 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #61 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #61 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #62 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #63 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #64 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #65 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #66 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #67 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0167 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

actor_def_07E3F9 [
  actor-def < #00, #00, #30, {

  code_07E3FC:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0458, #$00D0, &code_07E407 )
    RTL 
} >
]

code_07E407 {
    LDA $characterForm
    BNE loc_07E414
    LDA $abilityBitmask
    BIT #$0004
    BEQ loc_07E415

  loc_07E414:
    RTL 

  loc_07E415:
    LDY $decelStepCounter
    LDA #$03C0
    STA $0014, Y
    RTL 
}

code_07E41F {
    SBC $@3FFFFF, X
}