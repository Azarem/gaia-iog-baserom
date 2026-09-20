; Pyramid arrangement puzzle controller (~169 lines).
; 
; Tile/object arrangement puzzle. "Nothing happened... Maybe
; they're arranged wrong. Try it again from the beginning."
; Success: "There was a sound from over the entrance!"
; Player must arrange elements in the correct order.
; Tracks attempt state and validates the solution.
---------------------------------------------

?INCLUDE 'inventory_mgmt'

!joypadMaskStd                  065A

---------------------------------------------

pyCD_puzzle [
  actor-def < #00, #00, #30, {

  code_08CB9D:
    PHX 
    LDY #$0000

  loc_08CBA1:
    LDA $0B28, Y
    BMI loc_08CBBA
    TAX 
    SEP #$20
    LDA $@byte_08CB94, X
    PHX 
    PHA 
    TYA 
    LSR 
    TAX 
    PLA 
    STA $7EA065, X
    PLX 
    REP #$20

  loc_08CBBA:
    INY 
    INY 
    CPY #$000C
    BNE loc_08CBA1
    PLX 

  code_08CBC2:
    COP [BranchOnFlagByte] ( #D1, #01, &code_08CC09 )
    COP [SetEntryHere]
    LDY #$0000

  loc_08CBCD:
    LDA $0B28, Y
    BMI loc_08CBDB
    INY 
    INY 
    CPY #$000C
    BNE loc_08CBCD
    BRA loc_08CBDC

  loc_08CBDB:
    RTL 

  loc_08CBDC:
    LDY #$0000
    LDA #$0000

  loc_08CBE2:
    CMP $0B28, Y
    BNE loc_08CC0B
    INY 
    INY 
    INC 
    CMP #$0006
    BNE loc_08CBE2
    COP [SetFlagByte] ( #D1 )
    COP [PlaySoundBoth] ( #$0F0F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_08CD0B )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_08CC09 {
    COP [Die]

  loc_08CC0B:
    COP [PlaySoundCh1] ( #12 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08CCC4 )
    LDA $0B28
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCC loc_08CC2B
    JMP $&code_08CCB7

  loc_08CC2B:
    LDA #$FFFF
    STA $0B28
    COP [DrawMetatileAbs] ( #05, #06, #87 )
    LDA $0B2A
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS code_08CCB7
    LDA #$FFFF
    STA $0B2A
    COP [DrawMetatileAbs] ( #06, #06, #87 )
    LDA $0B2C
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS code_08CCB7
    LDA #$FFFF
    STA $0B2C
    COP [DrawMetatileAbs] ( #07, #06, #87 )
    LDA $0B2E
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS code_08CCB7
    LDA #$FFFF
    STA $0B2E
    COP [DrawMetatileAbs] ( #08, #06, #87 )
    LDA $0B30
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS code_08CCB7
    LDA #$FFFF
    STA $0B30
    COP [DrawMetatileAbs] ( #09, #06, #87 )
    LDA $0B32
    CLC 
    ADC #$001E
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS code_08CCB7
    LDA #$FFFF
    STA $0B32
    COP [DrawMetatileAbs] ( #0A, #06, #87 )
    LDA #$EFF0
    TRB $joypadMaskStd
    JMP $&code_08CBC2
}

code_08CCB7 {
    COP [PrintDialogString] ( &dialogstring_08CD37 )
    LDA #$EFF0
    TRB $joypadMaskStd
    JMP $&code_08CBC2
}

dialogstring_08CCC4 `[DEF]Nothing happened...[N]Maybe they're arranged[N]wrong. Try it again[N]from the beginning.[END]`

dialogstring_08CD0B `[DEF][TPL:0]There was a sound from[N]over the entrance![PAL:0][END]`

dialogstring_08CD37 `[DEF][CLR]Oh, no! Your inventory[N]is full, you can't take[N]all of it![END]`
---------------------------------------------

byte_08CB94 [
  #84   ;00
  #85   ;01
  #86   ;02
  #8C   ;03
  #8D   ;04
  #8E   ;05
]