; Shy guard NPC in Edward Castle.
; 
; Humorous single dialog where the guard stammers a love confession.
; Part of the caring maid subplot.
---------------------------------------------

---------------------------------------------

ec0A_shy_guard [
  actor-def < #1B, #00, #10, {

  code_04C8B3:
    COP [AddPosition] ( #10, #00 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04C8C5 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C8C5 {
    COP [PrintDialogString] ( &dialogstring_04C8CA )
    RTL 
}

dialogstring_04C8CA `[TPL:B][TPL:7]I... I love... you...[PAL:0][END]`