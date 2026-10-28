
!key_item_flags      0B58

------------------------------------------------

sp5A_door [
  actor-def < #00, #00, #30, {
    COP [BranchOnFlagWord] ( #0138, #01, &sp5A_door_die )
    COP [NudgePosition] ( #08, #08 )
    COP [SetInteractHandler] ( &sp5A_door_interact )
    COP [WaitOnFlagWord] ( #0138, #01 )

  sp5A_door_die:
    COP [Die]

  sp5A_door_interact:
    LDA $key_item_flags+1
    BIT #$0020
    BNE sp5A_door_use
    COP [BranchIfHasItem] ( #10, &sp5A_door_use )
    COP [PrintDialogString] ( &sp5A_door_interact_str )
    RTL

  sp5A_door_use:
    LDA #&code_03915D
    JML $@ItemUseStub
  } >
]

sp5A_door_interact_str `[DEF]What a strange door...[END]`

scene_5A_actors+= [
  actor-spawn < #2F, #19, #3B, @sp5A_door >
]