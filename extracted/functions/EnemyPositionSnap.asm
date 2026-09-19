!moveXAlt                       7F0018
!moveYAlt                       7F001A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002

---------------------------------------------

EnemyPositionSnap {
    LDA #$0000
    STA $onDodgeCallback, X
    STA $onHitCallback, X

  loc_0AA3B2:
    LDA $14
    SEC 
    SBC #$0008
    BIT #$0008
    BEQ loc_0AA3C6
    AND #$FFF0
    CLC 
    ADC #$0018
    BRA loc_0AA3CD

  loc_0AA3C6:
    AND #$FFF0
    CLC 
    ADC #$0008

  loc_0AA3CD:
    STA $moveXAlt, X
    LDA $16
    BIT #$0008
    BEQ loc_0AA3E1
    AND #$FFF0
    CLC 
    ADC #$0010
    BRA loc_0AA3E4

  loc_0AA3E1:
    AND #$FFF0

  loc_0AA3E4:
    STA $moveYAlt, X
    COP [SetEntryContinue]
    COP [MoveToward] ( #FF, #01 )
    LDA $14
    SEC 
    SBC #$0008
    ORA $16
    BIT #$000F
    BNE loc_0AA3B2
    COP [ResumeAfterSnap]
}