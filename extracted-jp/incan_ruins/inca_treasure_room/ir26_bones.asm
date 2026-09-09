---------------------------------------------

h_ir26_bones [
  actor-def < #2E, #01, #10, {

  code_05839D:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &chunk_058000.code_0583AB )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0583AB {
    COP [PrintWideString] ( &chunk_058000.widestring_0583B0 )
    RTL 
}

widestring_0583B0 `[DEF][TPL:0]インカの 黄金船を 求めた[N]探険家だろうか···?[FIN]白骨化した その手には お守りの[N]ようなものが にぎられている.[N][PAU:28]中には 紙きれが入っており[N]こんなことが 書かれていた.[FIN][PAL:0][SFX:0]お父さん 死なないでね.  ナナ[N][N]黄金船を見つけたら,[N]クルックを買おうね.  サーバス[END]`