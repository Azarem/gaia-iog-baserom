?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

sc01_roof_man [
  actor-def < #0D, #00, #10, {

  code_048497:
    LDA #$000A
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP
    COP [SetOnInteract] ( &code_0484B2 )

  loc_0484A6:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_0484A6
} >
]

code_0484B2 {
    COP [PrintWideString] ( &widestring_0484B7 )
    RTL 
}

widestring_0484B7 `[DEF]Hey, Will. How many[N]times have I told you[N]not to come up here...[FIN]You have a habit of[N]jumping down from[N]places. Well, I guess[N]I can't really stop you.[END]`