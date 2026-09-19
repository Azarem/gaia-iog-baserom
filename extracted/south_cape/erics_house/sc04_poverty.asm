; Erik's house NPC (neighbor/visitor) with a philosophy dialog.
; 
; Comments about how small things make you rich or poor.
---------------------------------------------

?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

sc04_poverty [
  actor-def < #15, #00, #10, {

  code_048F7D:
    LDA #$0012
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP
    COP [SetOnInteract] ( &code_048F98 )

  loc_048F8C:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_048F8C
} >
]

code_048F98 {
    COP [PrintDialogString] ( &dialogstring_048F9D )
    RTL 
}

dialogstring_048F9D `[DEF]It's the little things[N]in life that make you[N]rich or poor.[FIN]Well, heard any good[N]stories?[END]`