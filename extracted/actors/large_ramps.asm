; Invisible large-ramp speed booster actor (large_ramp_booster).
; 
; When the player is moving and within proximity zones #02 and #03, increments playerSpeedEw or playerSpeedNs in the current direction each frame. Placed on steep ramp tiles in scenes that need extra momentum. Complements the full ramp_climb actors with a simpler speed boost only.
---------------------------------------------

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
    COP [BranchIfPlayerNear] ( #02, &LargeRampBoostEastWest )
    RTL 
} >
]

LargeRampBoostEastWest {
    LDA $playerSpeedEw
    BMI loc_00C981
    INC $playerSpeedEw
    BRA loc_00C984

  loc_00C981:
    DEC $playerSpeedEw

  loc_00C984:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &LargeRampBoostNorthSouth )
    BRA loc_00C966
}

LargeRampBoostNorthSouth {
    RTL 
}