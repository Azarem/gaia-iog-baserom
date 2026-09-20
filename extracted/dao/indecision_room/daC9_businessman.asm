; Indecisive businessman in Dao — labor trade moral dilemma.
; 
; NPC: "You've come all the way to this town to buy labor...
; I can't make up my mind if I should do business here."
; Represents the moral conflict of participating in
; the slave trade for profit.
---------------------------------------------

?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

daC9_businessman [
  actor-def < #02, #00, #10, {

  code_08A8FE:
    COP [SetInteractHandler] ( &code_08A919 )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_08A90D:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_08A90D
} >
]

code_08A919 {
    COP [PrintDialogString] ( &dialogstring_08A91E )
    RTL 
}

dialogstring_08A91E `[DEF]You've come all the way[N]to this town to[N]buy labor...[FIN]I can't make up my mind[N]if I should do business[N]with you. You can't [N]put a price on people...[END]`