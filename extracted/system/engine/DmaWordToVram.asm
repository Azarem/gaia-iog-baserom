?BANK 02

!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305

---------------------------------------------

DmaWordToVram {
    STX $A1T0L
    STA $A1B0
    STY $DAS0L
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$01
    STA $MDMAEN
    RTL 
}