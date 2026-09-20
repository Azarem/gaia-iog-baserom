; Villager longing for the ocean in Angel Village.
; 
; NPC: "I don't know when we started living here. But when
; I look at the ocean, I feel an ache..." Expresses the
; Angel Tribe's yearning for the surface world they left.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

av6B_ocean_ache [
  actor-def < #02, #00, #10, {

  code_06C6DD:
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_06C6FC )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_06C6F0:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_06C6F0
} >
]

code_06C6FC {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C707 )
}

code_list_06C707 [
  &code_06C70F   ;00
  &code_06C70F   ;01
  &code_06C70F   ;02
  &code_06C70F   ;03
]

code_06C70F {
    COP [PrintDialogString] ( &dialogstring_06C714 )
    RTL 
}

dialogstring_06C714 `[TPL:9]I don't know when we[N]started living here.[FIN]But when I look at the [N]ocean, my heart aches. [END]`