; Dark Medicine in the Euro flea market (scene $97): a free one-time Dark Friar power gift.
; 
; $F1 set: the actor dies at spawn. Otherwise it asks 'That's called Dark Medicine. Try some?' (rows Yes/No). Yes: if $0B1C is 2 it prints 'The Dark Friar's power is strong enough!' and changes nothing; otherwise it writes $0B1C := 1, sets $F1 and prints 'Freedan's Dark Power has increased! The Dark Friar's power is increased!'. The text reports an increase; the code writes 1 even when $0B1C already holds 1.
---------------------------------------------

---------------------------------------------

eu97_dark_medicine [
  actor-def < #00, #00, #30, {

  code_07CDDD:
    COP [BranchOnFlagByte] ( #F1, #01, &code_07CE21 )
    COP [NudgePosition] ( #08, #00 )
    COP [SpawnAfterOffsetMarked] ( @code_07CEF4, #00, #EC, #$1000 )
    COP [SetInteractHandler] ( &code_07CDF7 )
    COP [SetEntryHere]
    RTL 
} >
]

code_07CDF7 {
    COP [PrintDialogString] ( &dialogstring_07CE28 )
    COP [DialogueOptions] ( #02, #02, &code_list_07CE01 )
}

code_list_07CE01 [
  &code_07CE07   ;00
  &code_07CE0C   ;01
  &code_07CE07   ;02
]

code_07CE07 {
    COP [PrintDialogString] ( &dialogstring_07CEDD )
    RTL 
}

code_07CE0C {
    LDA $0B1C
    CMP #$0002
    BEQ loc_07CE23
    LDA #$0001
    STA $0B1C
    COP [SetFlagByte] ( #F1 )
    COP [PrintDialogString] ( &dialogstring_07CE54 )
}

code_07CE21 {
    COP [Die]

  loc_07CE23:
    COP [PrintDialogString] ( &dialogstring_07CEB6 )
    RTL 
}

dialogstring_07CE28 `[DEF]That's called Dark[N]Medicine. Try some?[N] Yes[N] No`

dialogstring_07CE54 `[CLR][TPL:0]The smell makes my[N]nose turn up.[FIN]But Freedan's Dark Power[N]has increased![FIN][PAL:0]The Dark Friar's power[N]is increased![END]`

dialogstring_07CEB6 `[CLR]The Dark Friar's power[N]is strong enough![END]`

dialogstring_07CEDD `[CLR]Really...[N]Don't you like it?[END]`

code_07CEF4 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    RTL 
}