; Turbo the dog in Oakton — Kara's dog companion.
; 
; Simple NPC. Says: "Woof woof!!" Kara introduces him:
; "This dog's name is Turbo. Isn't he cute?" Part of the
; Oakton landing scene after the Gold Ship drift.
---------------------------------------------

---------------------------------------------

dc30_dog [
  actor-def < #48, #00, #10, {

  code_05AA6F:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05AA89 )
    COP [MarkSolidHere]

  loc_05AA7A:
    COP [ClearFlagByte] ( #01 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [StageSpriteLoop] ( #48, #10 )
    COP [AnimLoop]
    BRA loc_05AA7A
} >
]

code_05AA89 {
    COP [PrintDialogString] ( &dialogstring_05AA91 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05AA91 `[DEF]Woof woof!![END]`