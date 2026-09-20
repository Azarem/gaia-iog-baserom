; Male townspeople group 2 in Euro — Jackal warning.
; 
; NPC: "The other day, a man called the Jackal was asking
; questions. He had the face of a killer." Warning about
; the mysterious Jackal antagonist lurking in Euro.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

eu91_men2 [
  actor-def < #02, #00, #10, {

  code_07C92D:
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_07C94C )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_07C940:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07C940
} >
]

code_07C94C {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C957 )
}

code_list_07C957 [
  &code_07C961   ;00
  &code_07C966   ;01
  &code_07C96B   ;02
  &code_07C966   ;03
  &code_07C966   ;04
]

code_07C961 {
    COP [PrintDialogString] ( &dialogstring_07C970 )
    RTL 
}

code_07C966 {
    COP [PrintDialogString] ( &dialogstring_07C9DB )
    RTL 
}

code_07C96B {
    COP [PrintDialogString] ( &dialogstring_07C9FF )
    RTL 
}

dialogstring_07C970 `[DEF]The other day, a man [N]called the Jackal[N]was asking questions. [FIN]He had the look of [N]evil. I think [N]he was chasing someone.[END]`

dialogstring_07C9DB `[DEF]The president of Rolek[N]lives in this mansion.[END]`

dialogstring_07C9FF `[DEF]The town has changed.[N]Rolek's sudden growth[N]has brought many[N]merchants to the town.[FIN]There is something[N]behind the success.[END]`