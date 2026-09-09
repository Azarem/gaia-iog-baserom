!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

StopPlayerOnDeathAssign {
    LDA #$0000
    STA $playerSpeedEw
    STA $playerSpeedNs
    STA $0008, Y
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}