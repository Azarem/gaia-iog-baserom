; Chained slave in the Freejia labor cells — broken spirit dialog.
; 
; Static NPC. Says: "I've tried not to think. The more I think,
; the more empty I become..." One of the emotionally heavy NPCs
; in the slavery theme.
---------------------------------------------

---------------------------------------------

fr35_slave2 [
  actor-def < #27, #00, #10, {

  code_05C3A8:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C3B6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C3B6 {
    COP [PrintDialogString] ( &dialogstring_05C3BB )
    RTL 
}

dialogstring_05C3BB `[TPL:B]I've tried not to think. [N]The more I think, the [N]more empty I become...[END]`