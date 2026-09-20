; Collision layer tile renderer for the Pyramid trap rooms.
; 
; Technical actor (~116 lines) that draws the collision layer
; tiles visible in the Pyramid's trap corridors. Reads collision
; data and renders walkable/hazard tiles as visible sprites,
; allowing the player to see which tiles are safe to walk on.
---------------------------------------------

?INCLUDE 'hardware_math'

!collisionLayer                 7FC000
!S_effectLayerTilemap           C000

---------------------------------------------

CollisionLayerRenderer {
    PHX 
    PHD 
    PHB 
    PHP 
    REP #$20
    LDA #$0000
    TCD 
    LDA #$0100
    STA $3E
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDA #$7F
    STA $40
    LDA $06BF
    SEC 
    SBC $06C1
    STA $18
    LDA $06C3
    SEC 
    SBC $06C5
    STA $1C
    STZ $19
    STZ $1D

  loc_09BB46:
    LDA $19
    CLC 
    ADC $18
    BMI loc_09BB89
    CMP $0693
    BCS loc_09BB93
    LDA $1D
    CLC 
    ADC $1C
    BMI loc_09BB93
    CMP $0697
    BCS loc_09BB9F
    LDA $1D
    XBA 
    LDA $0695
    JSL $@hardware_math.SignedMultiply
    CLC 
    ADC $19
    XBA 
    LDA #$00
    TAY 
    LDA $1D
    CLC 
    ADC $1C
    XBA 
    LDA $0693
    JSL $@hardware_math.SignedMultiply
    CLC 
    ADC $19
    CLC 
    ADC $18
    XBA 
    LDA #$00
    TAX 
    JSR $&code_09BBA4

  loc_09BB89:
    LDA $19
    INC 
    STA $19
    CMP $0695
    BCC loc_09BB46

  loc_09BB93:
    STZ $19
    LDA $1D
    INC 
    STA $1D
    CMP $0699
    BCC loc_09BB46

  loc_09BB9F:
    PLP 
    PLB 
    PLD 
    PLX 
    RTL 
}

code_09BBA4 {
    LDA $S_effectLayerTilemap, Y
    BEQ loc_09BBB1
    STA $3E
    LDA [$3E]
    STA $collisionLayer, X

  loc_09BBB1:
    INY 
    INX 
    TXA 
    BNE code_09BBA4
    RTS 
}