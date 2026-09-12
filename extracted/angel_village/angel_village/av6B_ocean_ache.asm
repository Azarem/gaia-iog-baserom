?INCLUDE 'func_06B9F2'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

av6B_ocean_ache [
  actor-def < #02, #00, #10, {

  code_06C6DD:
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_06C6FC )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_06C6F0:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
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