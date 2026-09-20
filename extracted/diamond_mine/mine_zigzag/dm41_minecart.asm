; Minecart decoration actors that scroll across the mine background.
; 
; Three actor variants with different initial velocity vectors.
; dm41_minecart: velocity (2, 1). dm41_actor_0AA4F5: velocity (0, 1)
; with +5 X offset. dm41_actor_0AA50C: velocity (1, 0).
; Each saves its absolute position in orbitAngle/orbitDiameter and
; moves by adding velocity each frame. Screen position is computed
; relative to camera (subtracts cameraDelta, adds cameraTarget).
; Bounces off screen edges by negating the velocity component
; that went out of bounds.
---------------------------------------------

!effectBoundsX                  0694
!effectBoundsY                  0698
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

dm41_minecart [
  actor-def < #34, #02, #10, {

  code_0AA4E5:
    LDA #$0002
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    BRA loc_0AA51D
} >
]

dm41_actor_0AA4F5 [
  actor-def < #34, #02, #10, {

  code_0AA4F8:
    COP [NudgePosition] ( #05, #00 )
    LDA #$0000
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    BRA loc_0AA51D
} >
]

dm41_actor_0AA50C [
  actor-def < #34, #02, #10, {

  code_0AA50F:
    LDA #$0001
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X

  loc_0AA51D:
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    COP [SetEntryHere]
    LDA $orbitAngle, X
    CLC 
    ADC $moveXAlt, X
    STA $orbitAngle, X
    SEC 
    SBC $cameraDeltaX
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $orbitDiameter, X
    CLC 
    ADC $moveYAlt, X
    STA $orbitDiameter, X
    SEC 
    SBC $cameraDeltaY
    CLC 
    ADC $cameraTargetY
    STA $16
    LDA $14
    BMI loc_0AA56C
    CMP $effectBoundsX
    BCS loc_0AA589
    LDA $16
    BMI loc_0AA56C
    CMP $effectBoundsY
    BCS loc_0AA589
    RTL 

  loc_0AA56C:
    LDA $moveXAlt, X
    BPL loc_0AA57A
    EOR #$FFFF
    INC 
    STA $moveXAlt, X

  loc_0AA57A:
    LDA $moveYAlt, X
    BPL loc_0AA588
    EOR #$FFFF
    INC 
    STA $moveYAlt, X

  loc_0AA588:
    RTL 

  loc_0AA589:
    LDA $moveXAlt, X
    BMI loc_0AA597
    EOR #$FFFF
    INC 
    STA $moveXAlt, X

  loc_0AA597:
    LDA $moveYAlt, X
    BMI loc_0AA5A5
    EOR #$FFFF
    INC 
    STA $moveYAlt, X

  loc_0AA5A5:
    RTL 
} >
]