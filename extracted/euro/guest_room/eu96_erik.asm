; Erik in the Euro guest room — scared of the big house.
; 
; NPC: "I'm scared! What if I have to go to the bathroom
; and I can't find it?" Comic relief — Erik overwhelmed
; by the Rolek mansion's size.
---------------------------------------------

---------------------------------------------

eu96_erik [
  actor-def < #0A, #00, #10, {

  code_07DAA0:
    COP [BranchIfFlagByte] ( #AC, #01, &code_07DAAF )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DAB1 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07DAAF {
    COP [Die]
}

code_07DAB1 {
    COP [BranchIfFlagByte] ( #AA, #01, &code_07DABC )
    COP [PrintDialogString] ( &dialogstring_07DAC1 )
    RTL 
}

code_07DABC {
    COP [PrintDialogString] ( &dialogstring_07DB09 )
    RTL 
}

dialogstring_07DAC1 `[TPL:B][TPL:3]Erik: I'm scared! [N]What if I have to go [N]to the bathroom and [N]I can't find it?[PAL:0][END]`

dialogstring_07DB09 `[TPL:A][TPL:3]Erik: I just [N]don't understand women.[PAL:0][END]`