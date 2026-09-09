---------------------------------------------

h_it15_fable_woman [
  actor-def < #0B, #00, #10, {

  code_04D84C:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D85A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D85A {
    COP [PrintWideString] ( &widestring_04D85F )
    RTL 
}

widestring_04D85F `[DEF]このところ 世界中の町で[N]原因不明の 病気にかかる人や[N]行方不明者が 增えているみたい··[FIN]この星が いつまでも 平和で[N]ありますように.[END]`