; Sympathetic woman harboring the laborer — begs for secrecy.
; 
; NPC pleading: "Please! Don't tell! I don't care about myself,
; I just don't want to get this man in trouble." Emotional
; scene showing civilians resisting the slave trade.
---------------------------------------------

---------------------------------------------

fr3A_sympathetic [
  actor-def < #27, #00, #10, {

  code_05C311:
    COP [BranchOnFlagByte] ( #5A, #01, &code_05C325 )
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05C327 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05C325 {
    COP [Die]
}

code_05C327 {
    COP [PrintDialogString] ( &dialogstring_05C32F )
    COP [SetFlagByte] ( #59 )
    RTL 
}

dialogstring_05C32F `[TPL:A]Please! [N]Don't tell! [FIN]I don't care about myself,[N]I just don't want to get [N]him in trouble...[END]`