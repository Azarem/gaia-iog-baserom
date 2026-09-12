---------------------------------------------

dm3F_elevator_door [
  actor-def < #35, #01, #30, {

  code_05D645:
    COP [AddPosition] ( #08, #FE )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D661 )
    COP [ExitIfFlagByte] ( #69, #01 )
    COP [StageBgChange] ( #7B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$017B )
    COP [Die]
} >
]

code_05D661 {
    COP [BranchIfEquipped] ( #0F, &code_05D66B )
    COP [PrintDialogString] ( &dialogstring_05D676 )
    RTL 
}

code_05D66B {
    COP [SetFlagByte] ( #69 )
    COP [RemoveItem] ( #0F )
    COP [PrintDialogString] ( &dialogstring_05D696 )
    RTL 
}

dialogstring_05D676 `[DEF]There's one keyhole[N]in this door.[END]`

dialogstring_05D696 `[DEF]You used the[N]elevator key![END]`