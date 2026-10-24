?BANK 02

?INCLUDE 'scene_script'

!SPTR		$3E

-----------------------------------------------------

SceneCmd_LoadCharTiles! {
    PHP 
    JSR $&ReadScriptByte
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    REP #$20
    LDA [$3E]
    STA $00
    INC $3E
    INC $3E
    LDA [$3E]
    XBA 
    ORA $00
    INC $3E
    INC $3E
    SEP #$20
    JSL $@SignedMultiply
    REP #$20
    STA $00
    XBA 
    ASL 
    ASL 
    ASL 
    STA $0666
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028C81
    BMI loc_028C81
    STA $78
    SEP #$20
    LDX #$7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$7E
    STA $40
    BRA loc_028C87
}

loc_028C81! {
    SEP #$20
}
