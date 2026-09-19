!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

RandomPlayerOffset {
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $playerXPos
    STA $14
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $playerYPos
    STA $16
    LDA #$003C
    STA $08
    RTL 
}