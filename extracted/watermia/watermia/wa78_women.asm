?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

wa78_women [
  actor-def < #0A, #00, #10, {

  code_078965:
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
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_078987 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_078987 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078992 )
}

code_list_078992 [
  &code_07899E   ;00
  &code_0789A3   ;01
  &code_0789A8   ;02
  &code_0789AD   ;03
  &code_0789B2   ;04
  &code_0789C2   ;05
]

code_07899E {
    COP [PrintDialogString] ( &dialogstring_0789C7 )
    RTL 
}

code_0789A3 {
    COP [PrintDialogString] ( &dialogstring_078A26 )
    RTL 
}

code_0789A8 {
    COP [PrintDialogString] ( &dialogstring_078A73 )
    RTL 
}

code_0789AD {
    COP [PrintDialogString] ( &dialogstring_078ABA )
    RTL 
}

code_0789B2 {
    COP [BranchIfFlagByte] ( #95, #01, &code_0789BD )
    COP [PrintDialogString] ( &dialogstring_078AF8 )
    RTL 
}

code_0789BD {
    COP [PrintDialogString] ( &dialogstring_078B3B )
    RTL 
}

code_0789C2 {
    COP [PrintDialogString] ( &dialogstring_078B73 )
    RTL 
}

dialogstring_0789C7 `[DEF][SFX:10]Water never stays in[N]the same place. It's[N]always moving and[N]cleansing itself.[FIN]We want to live[N]like the water.[END]`

dialogstring_078A26 `[DEF][SFX:10]Nana: We haven't [N]heard from our father [N]since his last letter [N]six months ago... [FIN]I hope he's OK...[END]`

dialogstring_078A73 `[DEF][SFX:10]Human life is not such[N]a simple thing.[FIN]You shouldn't waste your[N]life on gambling.[END]`

dialogstring_078ABA `[DEF]As you can see, it's a[N]drinking contest. They[N]bet on who will win.[END]`

dialogstring_078AF8 `[DEF]Woman: Soon the baby[N]will be born. Our family[N]goes about their jobs[N]in high spirits.[END]`

dialogstring_078B3B `[DEF]Woman: We don't need[N]money. Real joy is being[N]with those you love.[END]`

dialogstring_078B73 `[DEF]The crazy old man has[N]grey hair, but they say[N]he's still young.[FIN]Maybe something bad[N]happened to him.[END]`