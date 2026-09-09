!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerFlags                    09AE
!playerActorDp                  09F4

---------------------------------------------

camera_scroll_controller [
  actor-def < #00, #00, #2C, {

  code_00EAF0:
    LDA #$1000
    TSB $12
    COP [SetEntryContinue]
    LDA $layerPriorityFlag
    BIT #$0200
    BEQ loc_00EB00
    RTL 

  loc_00EB00:
    PHD 
    LDA $playerActorDp
    TCD 
    LDA $14
    SEC 
    SBC #$0008
    STA $playerXPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $16
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $playerFlags
    BIT #$0100
    BNE loc_00EB85
    LDA $14
    SEC 
    SBC #$0080
    BMI loc_00EB4D
    CMP $cameraOffsetX
    BMI loc_00EB4D
    CLC 
    ADC #$0100
    CMP $cameraBoundsX
    BMI loc_00EB52
    LDA $cameraBoundsX
    BRA loc_00EB52

  loc_00EB48:
    LDA $cameraBoundsX
    BRA loc_00EB52

  loc_00EB4D:
    LDA $cameraOffsetX
    BRA loc_00EB56

  loc_00EB52:
    SEC 
    SBC #$0100

  loc_00EB56:
    STA $cameraTargetX
    LDA $16
    SEC 
    SBC #$0080
    BMI loc_00EB79
    CMP $cameraOffsetY
    BMI loc_00EB79
    CLC 
    ADC #$0100
    CMP $cameraBoundsY
    BMI loc_00EB7E
    LDA $cameraBoundsY
    BRA loc_00EB7E

  loc_00EB74:
    LDA $cameraBoundsY
    BRA loc_00EB7E

  loc_00EB79:
    LDA $cameraOffsetY
    BRA loc_00EB82

  loc_00EB7E:
    SEC 
    SBC #$0100

  loc_00EB82:
    STA $cameraTargetY

  loc_00EB85:
    LDA $cameraTargetX
    SEC 
    SBC $bg1ScrollH
    STA $effectDeltaX
    LDA $cameraTargetY
    SEC 
    SBC $bg2ScrollH
    STA $effectDeltaY
    PLD 
    RTL 
} >
]