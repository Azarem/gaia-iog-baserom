---------------------------------------------

dm3F_elevator_sign [
  actor-def < #36, #01, #10, {

  code_05D6AB:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D6B9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D6B9 {
    COP [PrintDialogString] ( &dialogstring_05D6BE )
    RTL 
}

dialogstring_05D6BE `[DEF](Elevator Entrance)[N]Use that door to[N]get to the elevator.[END]`