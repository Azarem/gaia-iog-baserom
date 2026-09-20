; Creepy man in Freejia — sinister dialog about understanding the city.
; 
; NPC with flag-gated states. Initial dialog: "Ha ha ha. You
; understand this place. Sometimes what you think is unimportant."
; Later: shorter "Ha ha ha." Hints at the dark underbelly of
; Freejia's slave trade.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

---------------------------------------------

fr32_creep [
  actor-def < #1A, #00, #10, {

  code_05B6C3:
    COP [SetOnInteract] ( &code_05B6CC )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05B6CC {
    COP [BranchIfFlagByte] ( #E1, #01, &code_05B6E3 )
    COP [PrintDialogString] ( &dialogstring_05B6E8 )
    COP [GiveItem] ( #01, &code_05B6DF )
    COP [SetFlagByte] ( #E1 )
    RTL 
}

code_05B6DF {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_05B6E3 {
    COP [PrintDialogString] ( &dialogstring_05B78C )
    RTL 
}

dialogstring_05B6E8 `[DEF]Ha ha ha. You[N]understand this place.[FIN]Sometimes what you think[N]is unimportant is the[N]most important thing.[N]Life is like that.[FIN]This is a gift.[N]Please take it.[FIN]The old man secretly put[N]something in Will's[N]bags![END]`

dialogstring_05B78C `[DEF]Ha  ha  ha.[END]`