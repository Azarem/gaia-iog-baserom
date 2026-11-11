; King Edward -- the throne room audience scene (scene $0A).
; 
; Spawns solid at his throne (nudged +8 in X). Talk: 'You're Will? You look so...shabby. Well, did you bring the Crystal Ring?' with two answers; they print different lines ('How dare you say such a thing to me!!' for the first, 'Good. An honest lad. Give me the Ring.' ... 'Are you lying to me, young whelp?!' for the second) and both end with 'Guards!! Throw this impudent weasel in prison!!' and set scratch $05. The main script waits on $05, locks the joypad ($CFFC), sets scratch $0A and prints 'Soldier: Yes, sir!'; the throne guards start on $0A and release the lock at the end of the sequence.
; 
; Edward sets only scene scratch flags. The persistent flag of this scene, $21, is set by the fade-out helper of ec0A_throne_guard2 just before the prison scene is queued.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

ec0A_edward [
  actor-def < #2A, #00, #10, {

  code_04C3CB:
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &code_04C3EC )
    COP [WaitOnFlagByte] ( #05, #01 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #0A )
    COP [PrintDialogString] ( &dialogstring_04C556 )
    COP [SetEntryHere]
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