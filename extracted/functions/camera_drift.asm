; Camera drift effect library with three actor scripts.
; 
; CameraDriftLoopSimple applies random ±1 vertical drift for 120 frames; CameraDriftLoopShip adds player flag $0100 gating for ship scenes; CameraDriftPatterned walks an 8-entry binary offset table for structured sway. Used in Incan Ruins Castoth fight, pyramid danger rooms, Angel Village underwater tunnel, and other atmospheric sequences. Creates subtle unsettling camera movement during set-piece scenes.
---------------------------------------------

!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerFlags                    09AE

---------------------------------------------

CameraDriftLoopSimple {
    COP [LoopInit] ( #78 ) ; CameraDriftLoopSimple: 120-frame loop applies RNG offset −1..+2 to cameraTargetY
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
    LDA #$1000            ; CameraDriftLoopShip: TSB $12 bit $1000; skip drift when playerFlags $0100 set
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
    COP [RngByte]         ; CameraDriftPatterned: walk 8-entry binary_00D068 table for structured sway
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
    LDA $24               ; Clamp cameraTargetY at zero if accumulated offset goes negative
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