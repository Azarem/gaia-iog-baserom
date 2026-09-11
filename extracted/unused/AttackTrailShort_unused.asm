?INCLUDE 'oam_digit_compose'

---------------------------------------------

AttackTrailShort_unused {
    LDA #$3200
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF8
    STA $16
    COP [LoopInit] ( #04 )
    LDA $16
    CLC 
    ADC #$0002
    STA $16
    LDA $28
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopNext]
    COP [LoopInit] ( #20 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $28
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopNext]
    COP [Die]
}