?INCLUDE 'func_06B9F2'
?INCLUDE 'music_actors'
?INCLUDE 'npc_wander_ai'

!playerFlags                    09AE
!displayModeFlags               09EC
!currentHp                      7F0026

---------------------------------------------

sp5A_villagers [
  actor-def < #02, #00, #10, {

  code_068A5C:
    COP [BranchIfFlagByte] ( #70, #00, &code_068A8E )
    LDA #$0008
    TSB $playerFlags
    LDA $0E
    AND #$0030
    LSR 
    CLC 
    ADC #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_068A90 )

  loc_068A82:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_068A82
} >
]

code_068A8E {
    COP [Die]
}

code_068A90 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_068A9B )
}

code_list_068A9B [
  &code_068AB7   ;00
  &code_068ABC   ;01
  &code_068AC1   ;02
  &code_068AC6   ;03
  &code_068ACB   ;04
  &code_068AD0   ;05
  &code_068AD5   ;06
  &code_068ADA   ;07
  &code_068ADF   ;08
  &code_068AE4   ;09
  &code_068AE9   ;0A
  &code_068B13   ;0B
  &code_068B18   ;0C
  &code_068B1D   ;0D
]

code_068AB7 {
    COP [PrintDialogString] ( &dialogstring_068B22 )
    RTL 
}

code_068ABC {
    COP [PrintDialogString] ( &dialogstring_068BB6 )
    RTL 
}

code_068AC1 {
    COP [PrintDialogString] ( &dialogstring_068C33 )
    RTL 
}

code_068AC6 {
    COP [PrintDialogString] ( &dialogstring_068CBD )
    RTL 
}

code_068ACB {
    COP [PrintDialogString] ( &dialogstring_068CF6 )
    RTL 
}

code_068AD0 {
    COP [PrintDialogString] ( &dialogstring_068D29 )
    RTL 
}

code_068AD5 {
    COP [PrintDialogString] ( &dialogstring_068D7A )
    RTL 
}

code_068ADA {
    COP [PrintDialogString] ( &dialogstring_068DD0 )
    RTL 
}

code_068ADF {
    COP [PrintDialogString] ( &dialogstring_068E20 )
    RTL 
}

code_068AE4 {
    COP [PrintDialogString] ( &dialogstring_068E67 )
    RTL 
}

code_068AE9 {
    COP [BranchIfFlagByte] ( #85, #01, &code_068B13 )
    JSL $@music_actors.IsMusicPlaying
    BCS loc_068B0D
    COP [GiveItem] ( #10, &code_068B0E )
    COP [SetFlagByte] ( #85 )
    COP [PrintDialogString] ( &dialogstring_068EA9 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_068ED4 )

  loc_068B0D:
    RTL 
}

code_068B0E {
    COP [PrintDialogString] ( &dialogstring_068F02 )
    RTL 
}

code_068B13 {
    COP [PrintDialogString] ( &dialogstring_068F53 )
    RTL 
}

code_068B18 {
    COP [PrintDialogString] ( &dialogstring_068F89 )
    RTL 
}

code_068B1D {
    COP [PrintDialogString] ( &dialogstring_068FC0 )
    RTL 
}

dialogstring_068B22 `[DEF]Saved!![N]Thank you!![FIN]I was brought to this [N]palace from Freejia and [N]changed to a demon... [FIN][TPL:2]Lilly speaks from[N]his pocket.[FIN]What?! All the demons[N]we saw before were[N]human beings...?[PAL:0][END]`

dialogstring_068BB6 `[DEF]I know now what[N]it feels like to be [N]close to death. [N]Death is terrifying! [FIN]I wonder if the [N]animals we eat feel the [N]same way I felt right [N]before death. [END]`

dialogstring_068C33 `[DEF]We were labor traders,[N]arrested for the crime[N]of buying and selling[N]human beings...[FIN]But the party officials[N]sold us to a vampire![N]I can't believe it...[END]`

dialogstring_068CBD `[DEF]Well, well. This is the[N]result of being tempted[N]by a beautiful woman...[END]`

dialogstring_068CF6 `[DEF]A nice guy asked me,[N]so I followed him...[N]I don't trust men![END]`

dialogstring_068D29 `[DEF]The man sleeping in[N]this coffin is surely a[N]vampire. They're[N]plotting something...[END]`

dialogstring_068D7A `[DEF]A vampire couple lives [N]in the coffins. [FIN]They bring people here,[N]turn them into demons,[N]and use them for labor.[END]`

dialogstring_068DD0 `[DEF]This palace is connected[N]to the land of Mu.[N]The vampires are looking[N]for something there...[END]`

dialogstring_068E20 `[DEF]We were almost changed [N]into demons. I'm afraid of[N]what might have happened [N]if you had come later... [END]`

dialogstring_068E67 `[DEF]I overheard the vampires[N]say something like [N]the Mystic Statue can [N]be found in Mu. [END]`

dialogstring_068EA9 `[DEF]I stole a key from the[N]vampire woman.[N]Here, take it.[FIN]`

dialogstring_068ED4 `[CLR][SFX:0][DLY:9]You received the key to [N]the Seaside Palace![PAU:78][END]`

dialogstring_068F02 `[DEF]I stole a key from the[N]vampire woman. I'd like[N]to give it to you, but[N]your inventory's full...[END]`

dialogstring_068F53 `[DEF]On the top floor of the[N]palace is a passageway[N]leading to Mu.[END]`

dialogstring_068F89 `[DEF]What will we do now,[N]deserted in the middle[N]of the ocean...[END]`

dialogstring_068FC0 `[DEF]Maybe we could seize[N]the palace and live[N]there together...[END]`