

mu63_pedestal1 [
  actor-def < #00, #00, #30, {
    COP [BranchOnFlagByte] ( #7B, #01, &mu63_pedestal1_die )
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &mu63_pedestal1_interact )
    COP [WaitOnFlagByte] ( #7B, #01 )

  mu63_pedestal1_die:
    COP [Die]

  mu63_pedestal1_interact:
    LDA $0B58
    BIT #$4000
    BNE mu63_pedestal1_use
    COP [BranchIfHasItem] ( #12, &mu63_pedestal1_use )
    COP [PrintDialogString] ( &mu63_interact_str )
    RTL

  mu63_pedestal1_use:
    LDA #&hope_statue_dialog_stub2
    JSL $@ItemUseStub
    COP [Die]
  } >
]

--------------------------------------------------

mu63_interact_str `[DEF]There is an altar here.[N]What could it be for...[END]`

----------------------------------------------

mu63_pedestal2 [
  actor-def < #00, #00, #30, {
    COP [BranchOnFlagByte] ( #7E, #01, &mu63_pedestal2_die )
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &mu63_pedestal2_interact )
    COP [WaitOnFlagByte] ( #7E, #01 )

  mu63_pedestal2_die:
    COP [Die]

  mu63_pedestal2_interact:
    LDA $0B58
    BIT #$8000
    BNE mu63_pedestal2_use
    COP [BranchIfHasItem] ( #12, &mu63_pedestal2_use )
    COP [PrintDialogString] ( &mu63_interact_str )
    RTL

  mu63_pedestal2_use:
    LDA #&hope_statue_dialog_stub1
    JSL $@ItemUseStub
    COP [Die]
  } >
]

--------------------------------------------------

scene_event_0CAB28+ [
  actor-spawn < #07, #07, #00, @mu63_pedestal1 >
  actor-spawn < #17, #07, #00, @mu63_pedestal2 >
]

--------------------------------------------------

code_0392B7! {
    COP [BranchOnFlagByte] ( #7E, #01, &code_0392D9 )
    COP [RemoveItem] ( #12 )
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7E )
    RTS 
}

hope_statue_dialog_stub1 {
    COP [PrintDialogString] ( &dialogstring_0392DE )
    BRA code_0392B7
}

--------------------------------------------------

code_0392C8! {
    COP [BranchOnFlagByte] ( #7B, #01, &code_0392D9 )
    COP [RemoveItem] ( #12 )
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7B )
    RTS 
}

hope_statue_dialog_stub2 {
    COP [PrintDialogString] ( &dialogstring_0392DE )
    BRA code_0392C8
}