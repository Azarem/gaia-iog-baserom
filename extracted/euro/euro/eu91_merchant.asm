?INCLUDE 'func_06B9F2'

---------------------------------------------

eu91_merchant [
  actor-def < #12, #00, #10, {

  code_07C289:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@func_06B9F2
    LDA #$6000
    STA $0E
    COP [SetOnInteract] ( &code_07C2DF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

eu91_merchant2 [
  actor-def < #12, #00, #10, {

  code_07C2B8:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_07C2DF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C2DF {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C2EA )
}

code_list_07C2EA [
  &code_07C300   ;00
  &code_07C305   ;01
  &code_07C30A   ;02
  &code_07C30F   ;03
  &code_07C314   ;04
  &code_07C319   ;05
  &code_07C31E   ;06
  &code_07C323   ;07
  &code_07C328   ;08
  &code_07C32D   ;09
  &code_07C332   ;0A
]

code_07C300 {
    COP [PrintWideString] ( &widestring_07C337 )
    RTL 
}

code_07C305 {
    COP [PrintWideString] ( &widestring_07C361 )
    RTL 
}

code_07C30A {
    COP [PrintWideString] ( &widestring_07C363 )
    RTL 
}

code_07C30F {
    COP [PrintWideString] ( &widestring_07C365 )
    RTL 
}

code_07C314 {
    COP [PrintWideString] ( &widestring_07C367 )
    RTL 
}

code_07C319 {
    COP [PrintWideString] ( &widestring_07C369 )
    RTL 
}

code_07C31E {
    COP [PrintWideString] ( &widestring_07C36B )
    RTL 
}

code_07C323 {
    COP [PrintWideString] ( &widestring_07C36D )
    RTL 
}

code_07C328 {
    COP [PrintWideString] ( &widestring_07C36F )
    RTL 
}

code_07C32D {
    COP [PrintWideString] ( &widestring_07C371 )
    RTL 
}

code_07C332 {
    COP [PrintWideString] ( &widestring_07C373 )
    RTL 
}

widestring_07C337 `[DEF]Hey! Don't ever go[N]over there.[N]Cross over to[N]the other side![END]`

widestring_07C361 `[DEF][END]`

widestring_07C363 `[DEF][END]`

widestring_07C365 `[DEF][END]`

widestring_07C367 `[DEF][END]`

widestring_07C369 `[DEF][END]`

widestring_07C36B `[DEF][END]`

widestring_07C36D `[DEF][END]`

widestring_07C36F `[DEF][END]`

widestring_07C371 `[DEF][END]`

widestring_07C373 `[DEF][END]`

eu91_merchant3 [
  actor-def < #1A, #00, #10, {

  code_07C378:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07C38A )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_07C38A {
    COP [PrintWideString] ( &widestring_07C38F )
    RTL 
}

widestring_07C38F `[DEF]Hey! Don't ever go[N]over there.[N]Cross over to[N]the other side![END]`

eu91_merchant4 [
  actor-def < #17, #00, #10, {

  code_07C3BC:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_07C3CF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #97 )
    COP [AnimOnce]
    RTL 
} >
]

code_07C3CF {
    COP [PrintWideString] ( &widestring_07C3D4 )
    RTL 
}

widestring_07C3D4 `[DEF]Thanks to customers like [N]this, we can survive.[END]`