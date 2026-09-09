?INCLUDE 'chunk_008000'

---------------------------------------------

h_it1A_moon_tribe1 [
  actor-def < #00, #00, #30, {

  code_04F262:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #2A, #01, &code_04F2A1 )
    PHX 
    LDX #$00E0
    LDA #$0000

  loc_04F274:
    STA $7F0B00, X
    INX 
    INX 
    CPX #$0100
    BNE loc_04F274
    PLX 
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_04F288 )
    RTL 
} >
]

code_04F288 {
    COP [PrintWideString] ( &widestring_04F366 )
    COP [DialogueOptions] ( #03, #01, &code_list_04F292 )
}

code_list_04F292 [
  &code_04F29A   ;00
  &code_04F29A   ;01
  &code_04F29A   ;02
  &code_04F29A   ;03
]

code_04F29A {
    COP [PrintWideString] ( &widestring_04F40B )
    COP [WaitByte] ( #27 )
}

code_04F2A1 {
    LDA #$2000
    TRB $10
    COP [SetFlagByte] ( #2A )
    COP [SpawnThinker] ( @chunk_008000.code_00B8AB )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04F33D )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
}

actor_def_04F2BD [
  actor-def < #00, #00, #30, {

  code_04F2C0:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04F342 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_04F2DD [
  actor-def < #00, #00, #30, {

  code_04F2E0:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04F347 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_04F2FD [
  actor-def < #00, #00, #30, {

  code_04F300:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04F35C )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

actor_def_04F31D [
  actor-def < #00, #00, #30, {

  code_04F320:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04F361 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

code_04F33D {
    COP [PrintWideString] ( &widestring_04F451 )
    RTL 
}

code_04F342 {
    COP [PrintWideString] ( &widestring_04F4B9 )
    RTL 
}

code_04F347 {
    COP [PrintWideString] ( &widestring_04F565 )
    COP [DialogueOptions] ( #02, #01, &code_list_04F351 )
}

code_list_04F351 [
  &code_04F357   ;00
  &code_04F357   ;01
  &code_04F357   ;02
]

code_04F357 {
    COP [PrintWideString] ( &widestring_04F596 )
    RTL 
}

code_04F35C {
    COP [PrintWideString] ( &widestring_04F5BE )
    RTL 
}

code_04F361 {
    COP [PrintWideString] ( &widestring_04F61B )
    RTL 
}

widestring_04F366 `[DEF]ふしぎな声:[N]こんばんわー,こんばんわー···[N]お散歩ですかぁー?[FIN][TPL:0]テム:[N]だれだ?![FIN][PAL:0]ふしぎな声:[N]上よ,うえ.[N]空気より かるい このカラダ.[FIN][PAL:4]テム:[N]ナニモノだ?![FIN][PAL:0]ふしぎな声: 当ててみてよ.[N] ワタガシのしんせき[N] 鳥人間[N] 死人のたましい`

widestring_04F40B `[CLR]ふしぎな声:[N]ブーーーーーーーーーッ はずれっ.[N]実は わたくしたちは 月の種族.[N]またの名を カゲ といいますの.[END]`

widestring_04F451 `[DEF]月の種族:[N]光のあるところ 必ずカゲがある.[FIN]すい星の光を ー度だけ あびて[N]すっかり 変わっちゃった[N]あたしたち···[FIN]以来 光のない世界で[N]ひっそりと 生きるもの.[END]`

widestring_04F4B9 `[DEF]月の種族:[N]すい星は すべての はかい者.[N]その光は すべての生物を[N]変容させてしまう よくない光よ.[FIN]月の種族:[N]はるかむかし[N]ひどいひどい戦争があって[N]その兵器の なごりなのよ.[FIN][TPL:0]テム:[N]世界が ひどくなるの?[FIN][PAL:0]月の種族:[N]そうとも. お利口だけど[N]まだまだ幼い ぼうや.[END]`

widestring_04F565 `[DEF]わたしたちの 仲間が ひとり[N]ぬすまれた.[FIN]行く先を ごぞんじない?[N] はい[N] いいえ`

widestring_04F596 `[CLR]月の種族:[N]あなたを 追ってくるかもよ.[N]クックククククク···[END]`

widestring_04F5BE `[DEF]800年ごとの すい星の接近は[N]今度で4回目.[N]その力をあびるほど ヤミの力は[N]強くなる···[FIN]今度の光で いったい[N]なにが 生まれることやら···[END]`

widestring_04F61B `[DEF]月の種族:[N]あたしたちは 時をこえて[N]永遠に 生き続ける···[FIN]インカ王国の ほろびゆく姿も[N]この目で しっかりと 見てきたわ.[FIN]インカの神像は この下のどうくつに[N]ねむっているの···[N]わたしたちが あなたを気に入れば[N]さしあげても よろしくてよ.[FIN]とにかく どうくつに 行って[N]ごらんなさいな.[N]クックククククク···[END]`