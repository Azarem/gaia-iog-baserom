?INCLUDE 'func_06B9F2'
?INCLUDE 'npc_wander_ai'

!currentHp                      7F0026

---------------------------------------------

wa78_centipede_man [
  actor-def < #02, #00, #10, {

  code_078285:
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_0782A4 )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_078298:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_078298
} >
]

code_0782A4 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0782AF )
}

code_list_0782AF [
  &code_0782B3   ;00
  &code_0782B8   ;01
]

code_0782B3 {
    COP [PrintDialogString] ( &dialogstring_0782BD )
    RTL 
}

code_0782B8 {
    COP [PrintDialogString] ( &dialogstring_078371 )
    RTL 
}

dialogstring_0782BD `[DEF][SFX:10]Man: I heard that a[N]huge centipede called a[N]Sand Fanger lives in[N]the Great Wall of China.[FIN]They say fluid from it's [N]body can cure anything. [FIN]Chinese medicine has[N]many strange things,[N]but drinking an insect's[N]bodily fluids...[END]`

dialogstring_078371 `[DEF][SFX:10]On full moon nights they [N]play Russian Glass, [N]the most dangerous [N]game you can play. [FIN]But you're still young.[N]I don't think you'd[N]throw away your life.[END]`