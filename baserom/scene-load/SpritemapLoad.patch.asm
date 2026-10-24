?BANK 02

?INCLUDE 'scene_script'

!SPTR		$3E

-----------------------------------------------------

SceneCmd_LoadSpriteTiles! {
    PHP 
    REP #$20
    ;LDA [$3A], Y
    ;STA $0666
    ;SEP #$20
    INY 
    INY 
    INY 
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA [$3E]
    BPL store_size
    
    LDA #$0000
    SEC
    SBC [$3E]

  store_size:
    STA $0666

    LDX #$0684
    JSR $&CheckSourceCacheHit
    BCC loc_028C19
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028C1B
    BMI loc_028C1B
    STA $78
    SEP #$20
    LDX #$4000
    STX $7A
    JSL $@QuintetLzDecompress
}
