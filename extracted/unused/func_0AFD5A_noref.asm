?BANK 0A

---------------------------------------------

func_0AFD5A_noref {
    COP [RngByte]
    STA $14
    COP [RngByte]
    ASL 
    STA $16
    LDA #$003C
    STA $08
    RTL 
}