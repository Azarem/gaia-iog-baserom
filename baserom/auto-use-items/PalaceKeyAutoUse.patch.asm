
sp5A_door [
    actor-def < #00, #00, #10, {
    COP [BranchOnFlagWord] ( #0138, #01, &sp5A_door_die )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &sp5A_door_interact )
    COP [WaitOnFlagWord] ( #0138, #01 )

  sp5A_door_die:
    COP [Die]

  sp5A_door_interact:
    LDA $0B58
    BIT #$2000
    BNE sp5A_door_use
    COP [BranchIfHasItem] ( #10, &sp5A_door_use )
    RTL

  sp5A_door_use:
    LDA #&code_03915D
    JSL $@ItemUseStub
    COP [Die]
  } >
]


scene_event_0CA55D+ [
  actor-spawn < #2F, #19, #3B, @sp5A_door >
]