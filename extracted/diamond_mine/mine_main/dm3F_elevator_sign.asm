; Elevator entrance sign — readable wall sign in the mine main area.
; 
; Solid interactable sprite. When examined, displays:
; "(Elevator Entrance) Use that door to get to the elevator."
---------------------------------------------

---------------------------------------------

dm3F_elevator_sign [
  actor-def < #36, #01, #10, {

  code_05D6AB:
    COP [MarkSolidHere]
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05D6B9 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05D6B9 {
    COP [PrintDialogString] ( &dialogstring_05D6BE )
    RTL 
}

dialogstring_05D6BE `[DEF](Elevator Entrance)[N]Use that door to[N]get to the elevator.[END]`