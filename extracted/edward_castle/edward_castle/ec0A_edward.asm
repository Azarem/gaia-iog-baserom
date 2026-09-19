; King Edward -- the throne room audience scene.
; 
; Major story cutscene: Edward asks Will about the Crystal Ring,
; interrogates him, and ultimately sends him to prison. Multi-choice
; dialog with yes/no prompts. Sets prison story flags.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

ec0A_edward [
  actor-def < #2A, #00, #10, {

  code_04C3CB:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04C3EC )
    COP [ExitIfFlagByte] ( #05, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #0A )
    COP [PrintDialogString] ( &dialogstring_04C556 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C3EC {
    COP [PrintDialogString] ( &dialogstring_04C40E )
    COP [DialogueOptions] ( #02, #02, &code_list_04C3F6 )
}

code_list_04C3F6 [
  &code_04C3FC   ;00
  &code_04C402   ;01
  &code_04C3FC   ;02
]

code_04C3FC {
    COP [PrintDialogString] ( &dialogstring_04C4D5 )
    BRA loc_04C406
}

code_04C402 {
    COP [PrintDialogString] ( &dialogstring_04C460 )

  loc_04C406:
    COP [PrintDialogString] ( &dialogstring_04C4FB )
    COP [SetFlagByte] ( #05 )
    RTL 
}

dialogstring_04C40E `[TPL:F][TPL:4]King Edward: [N]You're Will? [N]You look so...shabby.[FIN]Well, did you bring[N]the Crystal Ring?[N][PAL:0] Yes[N] No`

dialogstring_04C460 `[CLR][TPL:4]Good. An honest lad.[N]Give me the Ring.[FIN][TPL:0]Will: [N].............[FIN][TPL:4]King Edward:[N]Hmm?[N][PAU:3C]Are you lying [N]to me, young whelp?![FIN]`

dialogstring_04C4D5 `[CLR][TPL:4]How dare you say such[N]a thing to me!![FIN]`

dialogstring_04C4FB `[CLR][TPL:4]Guards!! Throw this[N]impudent weasel in[N]prison!![FIN]Then go to Will's house[N]and find the Ring![END]`

dialogstring_04C556 `[PAU:1E][TPL:8][PAL:0]Soldier: Yes,sir![PAU:28][CLD]`