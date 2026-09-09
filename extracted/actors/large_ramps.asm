?BANK 00

!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

large_ramp_booster [
  actor-def < #00, #00, #20, {

  loc_00C966:
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE loc_00C96F
    RTL 

  loc_00C96F:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_00C977 )
    RTL 
} >
]

code_00C977 {
    LDA $playerSpeedEw
    BMI loc_00C981
    INC $playerSpeedEw
    BRA loc_00C984

  loc_00C981:
    DEC $playerSpeedEw

  loc_00C984:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_00C98D )
    BRA loc_00C966
}

code_00C98D {
    RTL 
}