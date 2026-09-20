; Sam in the Freejia slave market — mentions Erik's rescue attempt.
; 
; NPC who says: "I am Sam. We were rescued last night by a man
; named Erik who was working here..." Links the slave market
; to Erik's capture subplot. Key information NPC.
---------------------------------------------

---------------------------------------------

fr3C_sam [
  actor-def < #28, #00, #10, {

  code_05C076:
    COP [BranchOnFlagByte] ( #6A, #01, &code_05C08A )
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05C08C )
    COP [SetEntryHere]
    RTL 
} >
]

code_05C08A {
    COP [Die]
}

code_05C08C {
    COP [PrintDialogString] ( &dialogstring_05C094 )
    COP [SetFlagByte] ( #66 )
    RTL 
}

dialogstring_05C094 `[DEF][TPL:5]I am Sam. [FIN]We were rescued last [N]night by a man named [N]Erik who was working [N]at the hotel. [FIN]But we were caught by[N]the labor traders...[FIN]He's being held in a[N]house on the corner of[N]a back street in town.[N]Please save him.[PAL:0][END]`