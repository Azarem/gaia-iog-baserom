---------------------------------------------

h_ec0B_moss [
  actor-def < #00, #00, #10, {

  code_04D4ED:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D4F9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D4F9 {
    COP [PrintDialogString] ( &dialogstring_04D502 )
    COP [SetFlagByte] ( #03 )
    COP [Die]
}

dialogstring_04D502 `[TPL:E][TPL:0]テム: このコケは 数え切れない[N]ほどの しゅうじんたちを[N]見てきたんだろうな···[FIN]彼らも このコケを[N]心のささえにして[N]くらしていたのかもしれない···[PAL:0][END]`