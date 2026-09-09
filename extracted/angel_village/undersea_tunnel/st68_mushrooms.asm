---------------------------------------------

st68_mushrooms [
  actor-def < #36, #00, #10, {

  code_06B843:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06B84F )
} >
]

code_list_06B84F [
  &code_06B855   ;00
  &code_06B86C   ;01
  &code_06B86C   ;02
]

code_06B855 {
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B863 )
    COP [SetEntryContinue]
    RTL 
}

code_06B863 {
    COP [PrintWideString] ( &widestring_06B86E )
    COP [ClearLowHere]
    COP [SetFlagByte] ( #02 )
}

code_06B86C {
    COP [Die]
}

widestring_06B86E `[TPL:A][TPL:0]These mushrooms grow all[N]over in the tunnel.[N]It's our only food.[FIN]Yesterday baked[N]mushroom.[FIN]The day before,[N]boiled mushroom.[FIN]Before that, raw.[N]Awfully tasteless...[FIN]We can't ask too much. [N]I'll do it to live. [N]We have to eat...[PAL:0][END]`