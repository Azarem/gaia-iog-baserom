?INCLUDE 'func_06B9F2'

---------------------------------------------

daC5_weaver [
  actor-def < #26, #00, #18, {

  code_08B467:
    LDA #$0200
    TSB $12
    LDA $0E
    AND #$0010
    STA $26
    JSL $@func_06B9F2
    LDA $26
    BEQ loc_08B482
    LDA $0E
    ORA #$4000
    STA $0E

  loc_08B482:
    COP [SetOnInteract] ( &code_08B49C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RngByte]
    AND #$001F
    STA $08
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B49C {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08B4A7 )
}

code_list_08B4A7 [
  &code_08B4AF   ;00
  &code_08B4B4   ;01
  &code_08B4B9   ;02
  &code_08B4BE   ;03
]

code_08B4AF {
    COP [PrintWideString] ( &widestring_08B4C3 )
    RTL 
}

code_08B4B4 {
    COP [PrintWideString] ( &widestring_08B4F0 )
    RTL 
}

code_08B4B9 {
    COP [PrintWideString] ( &widestring_08B51D )
    RTL 
}

code_08B4BE {
    COP [PrintWideString] ( &widestring_08B54A )
    RTL 
}

widestring_08B4C3 `[TPL:E][TPL:0]She didn't understand. [N]She just kept working.[PAL:0][END]`

widestring_08B4F0 `[TPL:E][TPL:0]She didn't understand. [N]She just kept working.[PAL:0][END]`

widestring_08B51D `[TPL:E][TPL:0]She didn't understand. [N]She just kept working.[PAL:0][END]`

widestring_08B54A `[TPL:E][TPL:0]She didn't understand. [N]She just kept working.[PAL:0][END]`