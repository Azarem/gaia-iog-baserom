---------------------------------------------

h_it15_elder [
  actor-def < #22, #00, #30, {

  code_04E1BD:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #41, #01, &code_04E1E9 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #04, #1C, #07, #1E, &code_04E1D3 )
    RTL 
} >
]

code_04E1D3 {
    COP [PrintDialogString] ( &dialogstring_04E290 )
    COP [SetFlagByte] ( #41 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #08, #19, #0D, #1A, &code_04E1E5 )
    RTL 
}

code_04E1E5 {
    COP [PrintDialogString] ( &dialogstring_04E2D4 )
}

code_04E1E9 {
    COP [SetOnInteract] ( &code_04E20B )
    COP [SpawnAfterRelFlags] ( @code_04E1FB, #$0000, #$0004, #$0B00 )
    COP [SetEntryContinue]
    RTL 
}

code_04E1FB {
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #22, #14 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    RTL 
}

code_04E20B {
    COP [BranchIfFlagByte] ( #44, #01, &code_04E282 )
    COP [BranchIfNoItem] ( #04, &code_04E26D )
    COP [BranchIfNoItem] ( #03, &code_04E272 )
    COP [BranchIfFlagByte] ( #47, #01, &code_04E265 )
    COP [BranchIfFlagByte] ( #0E, #01, &code_04E24D )
    COP [BranchIfFlagByte] ( #0F, #01, &code_04E231 )
    COP [PrintDialogString] ( &dialogstring_04E306 )
}

code_04E231 {
    COP [PrintDialogString] ( &dialogstring_04E494 )
    COP [DialogueOptions] ( #02, #02, &code_list_04E23B )
}

code_list_04E23B [
  &code_04E241   ;00
  &code_04E249   ;01
  &code_04E241   ;02
]

code_04E241 {
    COP [PrintDialogString] ( &dialogstring_04E4B9 )
    COP [SetFlagByte] ( #0F )
    RTL 
}

code_04E249 {
    COP [PrintDialogString] ( &dialogstring_04E4ED )
}

code_04E24D {
    COP [PrintDialogString] ( &dialogstring_04E515 )
    COP [DialogueOptions] ( #02, #01, &code_list_04E257 )
}

code_list_04E257 [
  &code_04E25D   ;00
  &code_04E265   ;01
  &code_04E25D   ;02
]

code_04E25D {
    COP [PrintDialogString] ( &dialogstring_04E52F )
    COP [SetFlagByte] ( #0E )
    RTL 
}

code_04E265 {
    COP [PrintDialogString] ( &dialogstring_04E556 )
    COP [SetFlagByte] ( #47 )
    RTL 
}

code_04E26D {
    COP [PrintDialogString] ( &dialogstring_04E73E )
    RTL 
}

code_04E272 {
    COP [PrintDialogString] ( &dialogstring_04E607 )

  loc_04E276:
    COP [DialogueOptions] ( #02, #01, &code_list_04E27C )
}

code_list_04E27C [
  &code_04E282   ;00
  &code_04E288   ;01
  &code_04E282   ;02
]

code_04E282 {
    COP [PrintDialogString] ( &dialogstring_04E6E9 )
    BRA loc_04E276
}

code_04E288 {
    COP [PrintDialogString] ( &dialogstring_04E6F0 )
    COP [SetFlagByte] ( #44 )
    RTL 
}

dialogstring_04E290 `[DLG:3,11][SIZ:D,2,0]テムの 後ろから[N]かぼそい声が 聞こえてきた···[FIN][TPL:D][TPL:4]不思議な声:[N]よくきた,テム···[PAL:0][END]`

dialogstring_04E2D4 `[TPL:E][TPL:4]長老: ここじゃ,ここじゃ.[N]花の中じゃよ.[N]あまりに 長生きしすぎてな.[PAL:0][END]`

dialogstring_04E306 `[DEF][TPL:4]長老: こうやって 花の精たちに[N]守ってもらわないと[N]生きておれんのじゃ.[FIN]ところで おまえは[N]父親に よく似ておるのう.[FIN]おまえの父親が この村に[N]やってきたのが きのうのことの[N]ようだ.[FIN][TPL:0]テム:[N]とうさんが···[FIN][TPL:4]長老:[N]おまえの かあさん··つまり[N]おまえの祖父母 ビルとローラの[N]ー人娘シーラはたいそうな美人でな.[FIN]おまえの父親は ー目ぼれして[N]この村から うばっていって[N]しまったのじゃ.[FIN]イトリー族の者は みな不思議な力を[N]もっているが,シーラは とりわけ[N]その力が強かった.[FIN]この村に 結界をはって 外から[N]見えなくしたのも あの娘だったが[N]おまえの 父さんは[N]いともたやすく 入ってきおった.[FIN]思えば,あの男も[N]不思議な人間じゃった···[FIN]`

dialogstring_04E494 `[DEF][TPL:4]それで,おまえは[N]父に よばれたのじゃな?[N][PAL:0] はい[N] いいえ`

dialogstring_04E4B9 `[CLR][TPL:4]長老: 何? よばれていないと··[N]では 悪いしるしは[N]マチガイだったのか···[PAL:0][END]`

dialogstring_04E4ED `[CLR][TPL:4]長老: なるほど···[N]では ローラの予感はあたったのか.[FIN]`

dialogstring_04E515 `[DEF][TPL:4]で,ゆくつもりなのか?[N][PAL:0] はい[N] いいえ`

dialogstring_04E52F `[DEF][CLR][TPL:4]長老: なんと.[N]父親に似ず おとなしい子じゃのう.[PAL:0][END]`

dialogstring_04E556 `[DEF][CLR][TPL:4]長老: よかろう.[N]ならば おまえに この村に伝わる[N]インカの神像をたくすことにしよう.[FIN]インカの なぞをとく カギとなる[N]2体の神像···[N]それらは 数百年の間 人の手に[N]ふれておらぬ.[FIN]神像のひとつは この下のどうくつに[N]安置されておる.[N]ちえをふりしぼって 手に入れるが[N]よい.[PAL:0][END]`

dialogstring_04E607 `[DEF][TPL:4]長老:[N]おおっ それこそ インカの神像![N]よくぞ 見つけ出した![FIN]おまえは インカのナゾを[N]とくために この世に生まれたのかも[N]しれんな···[FIN]では この村に伝わる[N]伝說を ひとつ おしえよう.[FIN][::]遺跡の地下の┌ラライのガケ┘にて[N]神の息のとどかぬところへ[N]インカの神をおさめよ.[FIN]谷風が その者を 黄金の船のもとへ[N]導くであろう.[FIN]わかったかな?[N][PAL:0] はい[N] いいえ`

dialogstring_04E6E9 `[DEF][CLR][TPL:4][JMP:&it15_elder.dialogstring_04E607+M]`

dialogstring_04E6F0 `[CLR][TPL:4]長老:[N]もうーつは 月の種族が もつと[N]言われておる.[FIN]そこへは リリィに 道案内[N]してもらうがよい.[N]気をつけてな.[PAL:0][END]`

dialogstring_04E73E `[DEF][CLR][JMP:&it15_elder.dialogstring_04E6F0]`