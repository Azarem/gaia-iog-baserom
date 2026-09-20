; Angel villager group 2 — emotionless existence.
; 
; NPC: "We have no emotions... I've neither laughed nor cried
; since the day I was born." Reveals the Angel Tribe's
; emotional numbness — a key theme of their devolution.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

av6B_villagers2 [
  actor-def < #0A, #00, #10, {

  code_06CACD:
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_06CAEC )
    LDA #$000A
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_06CAE0:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_06CAE0
} >
]

code_06CAEC {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06CAF7 )
}

code_list_06CAF7 [
  &code_06CAFD   ;00
  &code_06CB02   ;01
  &code_06CAFD   ;02
]

code_06CAFD {
    COP [PrintDialogString] ( &dialogstring_06CB07 )
    RTL 
}

code_06CB02 {
    COP [PrintDialogString] ( &dialogstring_06CB5E )
    RTL 
}

dialogstring_06CB07 `[TPL:A]We have no emotions...[FIN]I've neither laughed[N]nor cried since the day[N]I was born.[FIN]I just survive...[END]`

dialogstring_06CB5E `[TPL:A]Once a human woman  [N]named Kara came here. [FIN]Ishtar praised her[N]beauty. Then she went[N]to his studio.[END]`