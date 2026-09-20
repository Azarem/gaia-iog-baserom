; Hidden journal in the fireplace at Lance's father's house.
; 
; Interactive object: "There's a journal in a crack in the
; fireplace." Reveals backstory about Lance's father's
; expedition — key lore item connecting to Will's father Olman.
---------------------------------------------

---------------------------------------------

fireplace_journal [
  actor-def < #22, #00, #10, {

  code_07B4BE:
    COP [BranchOnFlagByte] ( #8F, #01, &code_07B4D4 )
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #03, #00 )
    COP [SetInteractHandler] ( &code_07B4D6 )
    COP [SetEntryHere]
    RTL 
} >
]

code_07B4D4 {
    COP [Die]
}

code_07B4D6 {
    COP [PrintDialogString] ( &dialogstring_07B4E5 )
    COP [SetFlagByte] ( #8F )
    COP [GiveItem] ( #15, &code_07B4E4 )
    COP [Die]
}

code_07B4E4 {
    RTL 
}

dialogstring_07B4E5 `[DEF][TPL:0][SFX:10]There's a journal in a[N]crack in the fireplace.[FIN][SFX:0]He gets the journal.[PAL:0][END]`