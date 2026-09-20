; Chained slave in the Freejia labor cells — lost faith dialog.
; 
; Static NPC. Says: "I don't believe in the spirits. If there
; were spirits, things like this wouldn't happen." Challenges
; the game's spiritual themes through hopelessness.
---------------------------------------------

---------------------------------------------

fr35_slave3 [
  actor-def < #27, #00, #10, {

  code_05C3FB:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05C409 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05C409 {
    COP [PrintDialogString] ( &dialogstring_05C40E )
    RTL 
}

dialogstring_05C40E `[TPL:A]I don't believe in the [N]spirits.[FIN]If there were spirits,[N]things like status [N]wouldn't matter....[END]`