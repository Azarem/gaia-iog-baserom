---------------------------------------------

h_ir28_bones [
  actor-def < #2E, #01, #10, {

  code_058461:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &chunk_058000.code_05846F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05846F {
    COP [PrintWideString] ( &chunk_058000.widestring_058474 )
    RTL 
}

widestring_058474 `[DEF][TPL:0]インカの 黄金船を 求めた[N]探険家だろうか···?[FIN]トラップに かかって[N]命を 落としたんだ····[END]`