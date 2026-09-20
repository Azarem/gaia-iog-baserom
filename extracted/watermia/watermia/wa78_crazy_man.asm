; Crazy old man in Watermia — talks about the Tower of Babel.
; 
; NPC: "A crazy old man came here two years ago. He just talked
; on about the Tower of Babel." Reference to someone who may
; have returned from the Babel expedition.
---------------------------------------------

---------------------------------------------

wa78_crazy_man [
  actor-def < #22, #00, #10, {

  code_07A08F:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07A0A2 )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]

code_07A0A2 {
    COP [PrintDialogString] ( &dialogstring_07A0A7 )
    RTL 
}

dialogstring_07A0A7 `[DEF]A crazy old man came [N]here two years ago. He [N]just talked on about [N]the Tower of Babel. [END]`