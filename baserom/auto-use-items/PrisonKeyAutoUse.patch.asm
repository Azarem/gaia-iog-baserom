
!key_item_flags      0B58

------------------------------------------------

ec0B_side_door {
    COP [BranchOnFlagByte] ( #42, #01, &ec0B_side_door_die )
    COP [SetInteractHandler] ( &ec0B_side_door_interact )
    COP [WaitOnFlagByte] ( #42, #01 )

  ec0B_side_door_die:
    COP [Die]

  ec0B_side_door_interact:
    LDA #&code_0385FF
    JML $@ItemUseStub
}

----------------------------------------------

code_04DB15!:
    COP [SpawnAfterAbsFlags] ( @ec0B_side_door, #$0090, #$0180, #$7000 )
    COP [BranchOnFlagByte] ( #24, #01, &ec0B_door_die )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04DB24 )
    COP [WaitOnFlagByte] ( #02, #01 )

    LDA $14
    CMP #$00F9
    BCS ec0B_door_die
    CMP #$00E8
    BCC ec0B_door_die

    COP [SetInteractHandler] ( &ec0B_door_interact_key )
    COP [WaitOnFlagByte] ( #24, #01 )

ec0B_door_die:
    COP [Die]

code_04DB24! {
    COP [PrintDialogString] ( &dialogstring_04DB2D )
    COP [SetFlagByte] ( #02 )
    RTL
}

ec0B_door_interact_key {
    LDA $key_item_flags
    BIT #$0001
    BNE ec0B_door_use_key
    COP [BranchIfHasItem] ( #02, &ec0B_door_use_key )
    ;COP [PrintDialogString] ( &dialogstring_04DB2D )
    RTL
}

ec0B_door_use_key {
    LDA #&code_0385DC
    JML $@ItemUseStub
}

;scene_0B_actors+ [
;  actor-spawn < #09, #18, #00, @ec0B_side_door >   ;09
;]

