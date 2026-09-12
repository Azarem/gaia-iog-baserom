---------------------------------------------

h_it15_fable_man [
  actor-def < #03, #00, #10, {

  code_04D7FF:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D80D )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D80D {
    COP [PrintDialogString] ( &dialogstring_04D812 )
    RTL 
}

dialogstring_04D812 `[DEF]ここは その むかし[N]世界が ほろびかけたとき[N]救世主が あらわれた場所と[N]いわれています.[END]`