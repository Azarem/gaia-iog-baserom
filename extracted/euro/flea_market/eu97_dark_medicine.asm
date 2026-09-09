---------------------------------------------

eu97_dark_medicine [
  actor-def < #00, #00, #30, {

  code_07CDDD:
    COP [BranchIfFlagByte] ( #F1, #01, &code_07CE21 )
    COP [AddPosition] ( #08, #00 )
    COP [SpawnMarkedAfterRel] ( @code_07CEF4, #00, #EC, #$1000 )
    COP [SetOnInteract] ( &code_07CDF7 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07CDF7 {
    COP [PrintWideString] ( &widestring_07CE28 )
    COP [DialogueOptions] ( #02, #02, &code_list_07CE01 )
}

code_list_07CE01 [
  &code_07CE07   ;00
  &code_07CE0C   ;01
  &code_07CE07   ;02
]

code_07CE07 {
    COP [PrintWideString] ( &widestring_07CEDD )
    RTL 
}

code_07CE0C {
    LDA $0B1C
    CMP #$0002
    BEQ loc_07CE23
    LDA #$0001
    STA $0B1C
    COP [SetFlagByte] ( #F1 )
    COP [PrintWideString] ( &widestring_07CE54 )
}

code_07CE21 {
    COP [Die]

  loc_07CE23:
    COP [PrintWideString] ( &widestring_07CEB6 )
    RTL 
}

widestring_07CE28 `[DEF]That's called Dark[N]Medicine. Try some?[N] Yes[N] No`

widestring_07CE54 `[CLR][TPL:0]The smell makes my[N]nose turn up.[FIN]But Freedan's Dark Power[N]has increased![FIN][PAL:0]The Dark Friar's power[N]is increased![END]`

widestring_07CEB6 `[CLR]The Dark Friar's power[N]is strong enough![END]`

widestring_07CEDD `[CLR]Really...[N]Don't you like it?[END]`

code_07CEF4 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    RTL 
}