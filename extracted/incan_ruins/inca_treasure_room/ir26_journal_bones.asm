; Explorer skeleton with journal — hints at Melody of the Wind puzzle.
; 
; Solid interactable prop. When examined, shows a journal about
; deciphering the Incan Melody of the Wind and the clue:
; "Chant in the Golden Room. Does that mean to play the Melody
; of the Wind...?" This hints at the Wind Melody puzzle solution.
---------------------------------------------

---------------------------------------------

ir26_journal_bones [
  actor-def < #2E, #01, #10, {

  code_09C8FA:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09C908 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09C908 {
    COP [PrintDialogString] ( &dialogstring_09C90D )
    RTL 
}

dialogstring_09C90D `[DEF][TPL:0]There's some kind[N]of journal...[FIN][PAL:0][N]  Note about the Incas[FIN]They have no written[N]language. They've left[N]their legends in sound.[FIN]I have succeeded in [N]deciphering the Incan [N]Melody of the Wind. [FIN]"Chant in the Golden[N]Room.ˮ Does that[N]mean to play the Melody[N]of the Wind...?[END]`