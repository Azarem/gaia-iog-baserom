; Explorer skeleton in the ceiling trap room — flavor text object.
; 
; Solid interactable prop. When examined, displays: "An explorer who
; sought the Incan Gold Ship...? He lost his life in a trap..."
---------------------------------------------

---------------------------------------------

ir28_bones [
  actor-def < #2E, #01, #10, {

  code_09C8A0:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_09C8AE )
    COP [SetEntryHere]
    RTL 
} >
]

code_09C8AE {
    COP [PrintDialogString] ( &dialogstring_09C8B3 )
    RTL 
}

dialogstring_09C8B3 `[DEF][TPL:0]An explorer who sought [N]the Incan Gold Ship...? [FIN]He lost his life in [N]a trap... [END]`