; Water-drinking child in Watermia — daily life dialog.
; 
; NPC: "We drink this water, cook with it, wash with it."
; Shows how central water is to Watermia's daily life.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

wa78_water_kid [
  actor-def < #12, #00, #10, {

  code_07849E:
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_0784BD )
    LDA #$0012
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_0784B1:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_0784B1
} >
]

code_0784BD {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0784C8 )
}

code_list_0784C8 [
  &code_0784CA
]

code_0784CA {
    COP [PrintDialogString] ( &dialogstring_0784CF )
    RTL 
}

dialogstring_0784CF `[DEF][SFX:10]Child:[N]We drink this water,[N]cook with it,[N]wash with it.[END]`