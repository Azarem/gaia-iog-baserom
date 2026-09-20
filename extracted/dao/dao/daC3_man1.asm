; Town greeter NPC in Dao — introduces the desert village.
; 
; Says: "This is Dao, the desert village. Children don't come
; to places like this very often." Establishes the remote,
; adult-oriented nature of the desert trade town.
---------------------------------------------

?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

daC3_man1 [
  actor-def < #02, #00, #10, {

  code_08A7F9:
    COP [SetInteractHandler] ( &code_08A814 )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_08A808:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_08A808
} >
]

code_08A814 {
    COP [PrintDialogString] ( &dialogstring_08A819 )
    RTL 
}

dialogstring_08A819 `[DEF]This is Dao, the desert[N]village. Children don't[N]come to places like this[N]very often.[END]`