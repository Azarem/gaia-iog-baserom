---------------------------------------------

fireplace_journal [
  actor-def < #22, #00, #10, {

  code_07B4BE:
    COP [BranchIfFlagByte] ( #8F, #01, &code_07B4D4 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #03, #00 )
    COP [SetOnInteract] ( &code_07B4D6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07B4D4 {
    COP [Die]
}

code_07B4D6 {
    COP [PrintWideString] ( &widestring_07B4E5 )
    COP [SetFlagByte] ( #8F )
    COP [GiveItem] ( #15, &code_07B4E4 )
    COP [Die]
}

code_07B4E4 {
    RTL 
}

widestring_07B4E5 `[DEF][TPL:0][SFX:10]There's a journal in a[N]crack in the fireplace.[FIN][SFX:0]He gets the journal.[PAL:0][END]`