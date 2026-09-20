; Remus in the Freejia slave market — tells about famine and hunting.
; 
; Multi-state NPC. Says: "I am Remus. Our game disappeared and
; we had nothing to eat. We had no choice." Later: "How can
; things like this happen?" Provides context about why people
; were vulnerable to the slavers.
---------------------------------------------

---------------------------------------------

fr3C_remus [
  actor-def < #28, #00, #10, {

  code_05BFAD:
    COP [BranchOnFlagByte] ( #6A, #01, &code_05BFC1 )
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BFD4 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05BFC1 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BFD9 )
    COP [SetEntryHere]
    RTL 
}

code_05BFD4 {
    COP [PrintDialogString] ( &dialogstring_05BFDE )
    RTL 
}

code_05BFD9 {
    COP [PrintDialogString] ( &dialogstring_05C059 )
    RTL 
}

dialogstring_05BFDE `[DEF][TPL:5]I am Remus. Our game[N]disappeared and we had[N]nothing to eat.[FIN]We had no choice but[N]to become laborers.[FIN]We didn't know where we [N]would be taken or what [N]would happen...[PAL:0][END]`

dialogstring_05C059 `[DEF]How can things like[N]this happen?[END]`