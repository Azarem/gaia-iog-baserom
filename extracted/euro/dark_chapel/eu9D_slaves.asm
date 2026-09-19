?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

eu9D_slaves [
  actor-def < #36, #00, #10, {

  code_07D09C:
    LDA #$0200
    TSB $12
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_07D0AE )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07D0AE {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07D0B9 )
}

code_list_07D0B9 [
  &code_07D0C3   ;00
  &code_07D0C8   ;01
  &code_07D0CD   ;02
  &code_07D0D2   ;03
  &code_07D0D7   ;04
]

code_07D0C3 {
    COP [PrintDialogString] ( &dialogstring_07D0DC )
    RTL 
}

code_07D0C8 {
    COP [PrintDialogString] ( &dialogstring_07D167 )
    RTL 
}

code_07D0CD {
    COP [PrintDialogString] ( &dialogstring_07D196 )
    RTL 
}

code_07D0D2 {
    COP [PrintDialogString] ( &dialogstring_07D1D3 )
    RTL 
}

code_07D0D7 {
    COP [PrintDialogString] ( &dialogstring_07D207 )
    RTL 
}

dialogstring_07D0DC `[DEF]Near our homes, [N]various diseases are [N]increasing... [FIN]Terrible diseases[N]that turn your body[N]to stone...[FIN]Though I'm a laborer,[N]I'm going to run away...[END]`

dialogstring_07D167 `[DEF]I miss speaking my own[N]language. But I'll [N]have to fight...[END]`

dialogstring_07D196 `[DEF]Those skeletons over[N]there are our friends.[N]It was by orders...[END]`

dialogstring_07D1D3 `[DEF]We learned the language[N]here. We can be sold[N]somewhere else...[END]`

dialogstring_07D207 `[DEF]I speak only a little[N]of the language. We[N]came from far away...[END]`