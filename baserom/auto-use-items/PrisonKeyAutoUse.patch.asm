

ec0B_side_door [
  actor-def < #00, #00, #10, {
    COP [BranchOnFlagByte] ( #42, #01, &ec0B_side_door_die )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &ec0B_side_door_interact )
    COP [WaitOnFlagByte] ( #42, #01 )

  ec0B_side_door_die:
    COP [Die]

  ec0B_side_door_interact:
    LDA #&code_0385FF
    JSL $@ItemUseStub
    COP [Die]
  }
]


code_04DB15!:
    COP [BranchOnFlagByte] ( #24, #01, &ec0B_door_die )
    LDA #$0200
    TSB $12
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_04DB24 )
    COP [WaitOnFlagByte] ( #02, #01 )
    
    LDA $24
    BEQ ec0B_door_die
    COP [SetInteractHandler] ( &ec0B_door_interact_key )
    COP [WaitOnFlagByte] ( #24, #01 )

ec0B_door_die:
    COP [Die]

code_04DB24! {
    COP [PrintDialogString] ( &dialogstring_04DB2D )
    COP [SetFlagByte] ( #02 )
    LDA $24
    BEQ ec0B_door_die
    RTL
}

ec0B_door_interact_key {
    LDA #$0B58
    BIT #$0001
    BNE ec0B_door_use_key
    COP [BranchIfHasItem] ( #02, &ec0B_door_use_key )
    COP [PrintDialogString] ( &dialogstring_04DB2D )
    RTL
}

ec0B_door_use_key {
    LDA #&code_0385DC
    JSL $@ItemUseStub
    COP [Die]
}

scene_event_0C8612+ [
  actor-spawn < #09, #18, #00, @ec0B_side_door >   ;09
]

