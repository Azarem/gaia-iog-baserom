!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraDeltaY                   06C4

---------------------------------------------

camera_delta_oscillator [
  actor-def < #00, #00, #20, {

  code_08B57A:
    COP [SetEntryContinue]
    LDA $cameraTargetX
    STA $cameraDeltaX
    LDA $0036
    AND #$0200
    BEQ loc_08B58E
    INC $cameraDeltaY
    RTL 

  loc_08B58E:
    DEC $cameraDeltaY
    RTL 
} >
]