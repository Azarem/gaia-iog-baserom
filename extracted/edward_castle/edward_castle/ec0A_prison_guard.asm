---------------------------------------------

ec0A_prison_guard [
  actor-def < #1D, #00, #10, {

  code_04D1A0:
    COP [BranchIfFlagByte] ( #21, #01, &code_04D1B7 )
    COP [SetOnInteract] ( &code_04D1B9 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #01 )
    COP [AddPosition] ( #00, #08 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D1B7 {
    COP [Die]
}

code_04D1B9 {
    COP [PrintDialogString] ( &dialogstring_04D1BE )
    RTL 
}

dialogstring_04D1BE `[TPL:B]Soldier:[N]This is the underground[N]prison. Innocent people[N]can't enter.[END]`