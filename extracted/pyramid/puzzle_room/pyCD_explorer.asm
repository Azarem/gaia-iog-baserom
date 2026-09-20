; Explorer NPC in the Pyramid puzzle room — warning about traps.
; 
; Interactable NPC: "There are traps scattered around to
; prevent entry. There's a booby trap in this room too."
; Warns the player about the puzzle room's dangers.
---------------------------------------------

---------------------------------------------

pyCD_explorer [
  actor-def < #1F, #00, #10, {

  code_08C200:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_08C254 )
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #C2, #01, &code_08C250 )
    COP [BranchOnFlagByte] ( #C3, #01, &code_08C250 )
    COP [BranchOnFlagByte] ( #C4, #01, &code_08C250 )
    COP [BranchOnFlagByte] ( #C5, #01, &code_08C250 )
    COP [BranchOnFlagByte] ( #C6, #01, &code_08C250 )
    COP [BranchOnFlagByte] ( #C7, #01, &code_08C250 )
    COP [BranchIfMissingItem] ( #1E, &code_08C250 )
    COP [BranchIfMissingItem] ( #1F, &code_08C250 )
    COP [BranchIfMissingItem] ( #20, &code_08C250 )
    COP [BranchIfMissingItem] ( #21, &code_08C250 )
    COP [BranchIfMissingItem] ( #22, &code_08C250 )
    COP [BranchIfMissingItem] ( #23, &code_08C250 )
    COP [SetEntryHere]
    RTL 
} >
]

code_08C250 {
    COP [ClearSolidHere]
    COP [Die]
}

code_08C254 {
    COP [PrintDialogString] ( &dialogstring_08C259 )
    RTL 
}

dialogstring_08C259 `[DEF]Explorer: There are[N]traps scattered around[N]to prevent entry.[FIN]There's a booby trap in[N]this room that responds[N]to sound.....So[N]don't make any noise...[END]`