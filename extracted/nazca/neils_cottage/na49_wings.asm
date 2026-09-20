; Airplane wings in Neil's cottage — the flying machine.
; 
; Interactive object. Neil: "Those are airplane wings. It's part
; of a machine that will fulfill man's dream of flying."
; Foreshadows Neil's airplane used in the Sky Garden descent
; and the Tower of Babel approach.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

na49_wings [
  actor-def < #00, #00, #30, {

  code_05E3F6:
    COP [NudgePosition] ( #08, #00 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_05E40B )
    COP [SetEntryHere]
    RTL 
} >
]

code_05E40B {
    COP [PrintDialogString] ( &dialogstring_05E419 )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    RTL 
}

dialogstring_05E419 `[TPL:B][TPL:6]Neil: Those are [N]airplane wings. [FIN]It's part of a machine[N]that will fulfill man's[N]dream of flying in the[N]air like a bird.[FIN]The body's too big, and[N]you need a runway to[N]take off, so it's[N]hidden in the desert.[PAL:0][END]`