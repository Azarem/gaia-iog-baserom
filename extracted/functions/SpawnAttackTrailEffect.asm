; Combat floating damage-number effect that spawns ghost copies of digit sprites interpolated between the attacker's previous and current position using oam_digit_compose.ComposeDigitSprites.
; 
; Renders 16 frames at position then 16 more frames drifting upward. Called by combat_collision when the player or enemies take damage. Renders the classic IOG floating damage numbers.
---------------------------------------------

?INCLUDE 'oam_digit_compose'

---------------------------------------------

SpawnAttackTrailEffect {
    LDA #$3200
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF0
    STA $16
    LDY $24
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    COP [LoopInit] ( #10 )
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $20
    CLC 
    ADC $14
    STA $14
    LDA $0016, Y
    SEC 
    SBC $22
    CLC 
    ADC $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    LDA $28
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopNext]
    COP [Die]
}