?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

daC3_man1 [
  actor-def < #02, #00, #10, {

  code_08A7F9:
    COP [SetOnInteract] ( &code_08A814 )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_08A808:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_08A808
} >
]

code_08A814 {
    COP [PrintWideString] ( &widestring_08A819 )
    RTL 
}

widestring_08A819 `[DEF]This is Dao, the desert[N]village. Children don't[N]come to places like this[N]very often.[END]`