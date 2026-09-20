; Philosopher NPC in Freejia — reflects on honest living.
; 
; Simple NPC. Says: "A life lived honestly. A life of fun and
; laughter." Provides moral contrast to the corruption theme.
---------------------------------------------

---------------------------------------------

fr32_honest_life [
  actor-def < #35, #00, #10, {

  code_05BE11:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BE1F )
    COP [SetEntryHere]
    RTL 
} >
]

code_05BE1F {
    COP [PrintDialogString] ( &dialogstring_05BE24 )
    RTL 
}

dialogstring_05BE24 `[DEF]A life lived[N]honestly. A life[N]of fun and laughter.[END]`