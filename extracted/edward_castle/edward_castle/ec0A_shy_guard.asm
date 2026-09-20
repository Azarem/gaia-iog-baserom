; Shy guard NPC in Edward Castle.
; 
; Humorous single dialog where the guard stammers a love confession.
; Part of the caring maid subplot.
---------------------------------------------

---------------------------------------------

ec0A_shy_guard [
  actor-def < #1B, #00, #10, {

  code_04C8B3:
    COP [NudgePosition] ( #10, #00 )
    COP [MarkSolidHere]
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04C8C5 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04C8C5 {
    COP [PrintDialogString] ( &dialogstring_04C8CA )
    RTL 
}

dialogstring_04C8CA `[TPL:B][TPL:7]I... I love... you...[PAL:0][END]`