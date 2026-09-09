---------------------------------------------

h_ir26_journal_bones [
  actor-def < #2E, #01, #10, {

  code_0584BA:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &chunk_058000.code_0584C8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0584C8 {
    COP [PrintWideString] ( &chunk_058000.widestring_0584CD )
    RTL 
}

widestring_0584CD `[DEF][TPL:0]遺体は 何か 手帳のようなものを[N]もっているようだ···[FIN][PAL:0][N]  インカについてわかったこと[FIN]インカ地方には 文字が 存在[N]しなかった.[N]そのため 人々は 音で 言い伝えを[N]後世に 残したようである.[FIN]私は インカの谷風が メロディを[N]かなでていることに 気がつき[N]その解読に 成功した.[FIN]┌黄金の しきつめられた部屋にて[N] われを となえよ···┘[N]谷風がかなでるメロディを そこで[N]吹けということだろうか···[END]`