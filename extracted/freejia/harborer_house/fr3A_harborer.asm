; Man harboring the escaped laborer — afraid of being discovered.
; 
; NPC in the harborer's house. Says: "There was nothing he could
; do about being found. He's the laborer who ran away..." Links
; to the escaped laborer subplot from the slave traders.
---------------------------------------------

---------------------------------------------

fr3A_harborer [
  actor-def < #02, #00, #10, {

  code_05BC59:
    COP [BranchOnFlagByte] ( #5A, #01, &code_05BC68 )
    COP [SetInteractHandler] ( &code_05BC6A )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05BC68 {
    COP [Die]
}

code_05BC6A {
    COP [PrintDialogString] ( &dialogstring_05BC6F )
    RTL 
}

dialogstring_05BC6F `[TPL:A]There was nothing he[N]could do about being[N]found.[FIN]He's the laborer[N]who ran away yesterday.[FIN]I should tell the labor[N]traders.[FIN]I was prepared[N]for the worst[N]when I did it.[END]`