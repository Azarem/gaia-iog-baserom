; Erik at the Dao hotel — can't go outside in sandstorm.
; 
; NPC: "I can't go outside in a sandstorm like this."
; Erik is stuck indoors during the desert weather.
---------------------------------------------

---------------------------------------------

daC4_erik [
  actor-def < #0A, #00, #10, {

  code_08A56A:
    COP [BranchIfFlagByte] ( #D2, #01, &code_08A579 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A57B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A579 {
    COP [Die]
}

code_08A57B {
    COP [PrintDialogString] ( &dialogstring_08A580 )
    RTL 
}

dialogstring_08A580 `[TPL:A][TPL:3]Erik: [N]I can't go outside in [N]a sandstorm like this.[PAL:0][END]`