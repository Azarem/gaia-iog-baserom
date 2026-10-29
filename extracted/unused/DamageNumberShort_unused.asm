; Unreferenced shortened variant of SpawnDamageNumberEffect.
; 
; Composes only 4 upward digit-sprite frames plus 32 more (vs 16+16), with a smaller Y offset ($FFF8). Would have rendered a shorter floating damage number. Never called by combat_collision or any actor script.
---------------------------------------------

?INCLUDE 'oam_digit_compose'

---------------------------------------------

DamageNumberShort_unused {
    LDA #$3200
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF8
    STA $16
    COP [LoopStart] ( #04 )
    LDA $16
    CLC 
    ADC #$0002
    STA $16
    LDA $28
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopEnd]
    COP [LoopStart] ( #20 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $28
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopEnd]
    COP [Die]
}