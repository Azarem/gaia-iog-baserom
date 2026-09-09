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
    COP [PrintWideString] ( &widestring_09C90D )
    RTL 
}

widestring_09C90D `[DEF][TPL:0]There's some kind[N]of journal...[FIN][PAL:0][N]  Note about the Incas[FIN]They have no written[N]language. They've left[N]their legends in sound.[FIN]I have succeeded in [N]deciphering the Incan [N]Melody of the Wind. [FIN]"Chant in the Golden[N]Room.ˮ Does that[N]mean to play the Melody[N]of the Wind...?[END]`