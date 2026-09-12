?INCLUDE 'func_06B9F2'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

eu91_women2 [
  actor-def < #2A, #00, #10, {

  code_07CA68:
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_07CA87 )
    LDA #$002A
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_07CA7B:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_07CA7B
} >
]

code_07CA87 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07CA92 )
}

code_list_07CA92 [
  &code_07CA9C   ;00
  &code_07CAA1   ;01
  &code_07CA9C   ;02
  &code_07CAA6   ;03
  &code_07CAAB   ;04
]

code_07CA9C {
    COP [PrintDialogString] ( &dialogstring_07CAB0 )
    RTL 
}

code_07CAA1 {
    COP [PrintDialogString] ( &dialogstring_07CAE0 )
    RTL 
}

code_07CAA6 {
    COP [PrintDialogString] ( &dialogstring_07CB09 )
    RTL 
}

code_07CAAB {
    COP [PrintDialogString] ( &dialogstring_07CB60 )
    RTL 
}

dialogstring_07CAB0 `[DEF]There are many back[N]alleys between the[N]houses in town.[END]`

dialogstring_07CAE0 `[DEF]There are [N]many people confined [N]under the shrine. [END]`

dialogstring_07CB09 `[DEF]Luggage is piled up in[N]the company next door.[FIN]Sometimes you hear[N]groans from the luggage[N]they're moving. Odd...[END]`

dialogstring_07CB60 `[DEF]I saw that. There are [N]many people confined [N]under the school. [END]`