; ==============================================================================
; Prison Key auto-use (Edward Castle prison) - side door + main door interact
; ==============================================================================
; What it does: Side door actor auto-uses Prison Key via ItemUseStub at
;   code_0385FF. Main ec0B_door actor spawns the side door, keeps Will's locked
;   dialog on flag byte #02, and adds keyhole interact that stubs to code_0385DC
;   when key_item_flags bit $01 or item #02 is owned.
; Vanilla behavior: ec0B_door code_04DB15 sets script lock $0200 on $12, handler
;   code_04DB24 prints locked dialog and sets flag #02 then dies; Prison Key use
;   only from inventory at tile regions for doors A/B.
; Hooks (overrides): ec0B_door.code_04DB15! replaces entry with side-door spawn
;   and extended door logic; ec0B_door.code_04DB24! RTL after dialog (no Die).
; Adds: ec0B_side_door, ec0B_door_interact_key / _use_key; JML ItemUseStub with
;   #&code_0385FF (side) or #&code_0385DC (main keyhole).
; Depends on: !key_item_flags $0B58; ItemUseStub; flag bytes #02, #24, #42.
; State: Player Y band $E8-$F9 on main door for keyhole handler; flag #24 main
;   door open; flag #42 side door; item #02 Prison Key.
; Hazards/notes: code_04DB24 override must RTL (actor stays alive for WaitOnFlag);
;   COP SetInteractHandler on main door uses mixed flag bytes vs vanilla.
; ==============================================================================

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

ec0B_door.code_04DB15!:
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

ec0B_door.code_04DB24! {
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

