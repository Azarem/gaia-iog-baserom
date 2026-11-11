; Wandering woman of Watermia (scene $78, spawn parameter #01).
; 
; The actor walks with NpcRandomWanderAI. Her interact handler has two texts chosen by flag $96 (the festival night, set by the Great Wall reunion and cleared when the Russian Glass game ends): with $96 clear she says 'This is Watermia. The houses are built on rafts. We like to move around.'; with $96 set she says 'A woman in pink chanted over that lotus leaf.'.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

wa78_moving_woman [
  actor-def < #02, #00, #10, {

  code_0783F0:
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_07840F )
    LDA #$000A
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_078403:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA loc_078403
} >
]

code_07840F {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07841A )
}

code_list_07841A [
  &code_07841C
]

code_07841C {
    COP [BranchOnFlagByte] ( #96, #01, &code_078427 )
    COP [PrintDialogString] ( &dialogstring_07842C )
    RTL 
}

code_078427 {
    COP [PrintDialogString] ( &dialogstring_07846A )
    RTL 
}

dialogstring_07842C `[DEF][SFX:10]Woman: This is[N]Watermia. The houses are[N]built on rafts. We like[N]to move around.[END]`

dialogstring_07846A `[DEF][SFX:10]Woman:[N]A woman in pink[N]chanted over[N]that lotus leaf.[END]`