---------------------------------------------

h_ir1D_bones [
  actor-def < #2E, #01, #10, {

  code_04FC9B:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04FCA9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04FCA9 {
    COP [PrintWideString] ( &widestring_04FCAE )
    RTL 
}

widestring_04FCAE `[DEF][TPL:0]遺体の 近くの 地面に[N]何か かかれているようだ···[FIN][PAL:0]あの 黄金像さえ 動かせれば[N]先へ 進むことができたのに···[END]`