; Guard blocking the prison entrance in the castle (scene $0A).
; 
; $21 clear: solid two tiles high; talk: 'This is the underground prison. Innocent people can't enter.' $21 set (after the throne scene): the actor dies at spawn.
---------------------------------------------

---------------------------------------------

ec0A_prison_guard [
  actor-def < #1D, #00, #10, {

  code_04D1A0:
    COP [BranchOnFlagByte] ( #21, #01, &code_04D1B7 )
    COP [SetInteractHandler] ( &code_04D1B9 )
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #01 )
    COP [NudgePosition] ( #00, #08 )
    COP [SetEntryHere]
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