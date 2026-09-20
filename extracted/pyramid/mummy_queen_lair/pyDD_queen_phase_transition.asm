; Mummy Queen phase transition animation controller (~101 lines).
; 
; Manages the visual effects and timing between boss phases.
; Handles the queen's teleportation, invulnerability flash,
; and arena environment changes between phases.
---------------------------------------------

?BANK 0B

?INCLUDE 'pyDD_queen_debris'

!cameraTargetX                  06BE
!cameraTargetY                  06C2
!layerPriorityFlag              06EE

---------------------------------------------

pyDD_queen_phase_transition {
    COP [SpawnMarkedAfter] ( @code_0BACD8, #$2000 )
    STZ $24

  loc_0BACC5:
    COP [PaletteStart] ( #5F )
    COP [PaletteStep]
    LDA $24
    BEQ loc_0BACC5
    LDY $06
    LDA #$&code_0BACFE
    STA $0000, Y
    COP [Die]
}

code_0BACD8 {
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X
    COP [WaitByte] ( #0F )
    LDA $26
    INC 
    CMP #$0020
    BCC loc_0BACF8
    COP [SpawnAfterFlags] ( @pyDD_queen_debris, #$0202 )
    LDA #$0000

  loc_0BACF8:
    STA $26
    JSR $&code_0BAD13
    RTL 
}

code_0BACFE {
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X
    COP [LoopInit] ( #78 )
    JSR $&code_0BAD13
    COP [LoopNext]
    COP [Die]
}

code_0BAD13 {
    LDA $layerPriorityFlag
    BIT #$0200
    BNE loc_0BAD49
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X

  loc_0BAD26:
    COP [RngByte]
    PHA 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    PLA 
    LSR 
    LSR 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTS 

  loc_0BAD49:
    LDA $7F100C, X
    BNE loc_0BAD5F
    LDA $cameraTargetX
    STA $7F100C, X
    LDA $cameraTargetY
    STA $7F100E, X
    BRA loc_0BAD26

  loc_0BAD5F:
    STA $cameraTargetX
    LDA $7F100E, X
    STA $cameraTargetY
    BRA loc_0BAD26
}