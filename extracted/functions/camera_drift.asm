!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerFlags                    09AE

---------------------------------------------

CameraDriftLoopSimple {
    COP [LoopInit] ( #78 )
    COP [RngByte]
    AND #$0003
    SEC 
    SBC #$0001
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    COP [LoopNext]
    COP [Die]

  CameraDriftLoopShip:
    LDA #$1000
    TSB $12
    STZ $26
    COP [LoopInit] ( #78 )
    LDA $playerFlags
    BIT #$0100
    BNE loc_00CFE0
    LDA $cameraDeltaY
    SEC 
    SBC $26
    STA $cameraDeltaY
    COP [RngByte]
    AND #$0003
    STA $26
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY

  loc_00CFE0:
    COP [LoopNext]
    COP [SetEntryExit]
    LDA $cameraDeltaY
    SEC 
    SBC $26
    STA $cameraDeltaY
    COP [Die]

  CameraDriftPatterned:
    COP [RngByte]
    STA $28
    LDA #$0002
    STA $2A
    COP [SetEntryContinue]
    PHB 
    PHK 
    PLB 
    LDA $28
    INC $28
    AND #$0007
    ASL 
    TAY 
    LDA $&binary_00D068, Y
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    BPL loc_00D016
    STZ $cameraTargetY

  loc_00D016:
    LDA $24
    CMP #$FFFF
    BEQ loc_00D02C
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    BPL loc_00D02D
    STZ $cameraDeltaY
    BRA loc_00D02D

  loc_00D02C:
    PLA 

  loc_00D02D:
    LDA $28
    AND #$0007
    ASL 
    TAY 
    LDA $&binary_00D068, Y
    PHA 
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    BPL loc_00D044
    STZ $cameraTargetX

  loc_00D044:
    LDA $24
    CMP #$FFFF
    BEQ loc_00D05A
    PLA 
    CLC 
    ADC $cameraDeltaX
    STA $cameraDeltaX
    BPL loc_00D05B
    STZ $cameraDeltaX
    BRA loc_00D05B

  loc_00D05A:
    PLA 

  loc_00D05B:
    PLB 
    LDA #$0003
    STA $08
    DEC $2A
    BMI loc_00D066
    RTL 

  loc_00D066:
    COP [Die]
}

binary_00D068 #0100FFFFFEFF010002000000FEFF01000500FCFFFEFF04000100FBFF0400FDFF