; Floor spike trap in Mu — timed hazard on the floor.
; 
; Environmental trap that extends spikes at timed intervals.
; Damages the player on contact during the extended phase.
; Uses a simple timer loop for the extend/retract cycle.
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!statsPtr                       7F0020

---------------------------------------------

mu60_floor_spikes [
  actor-def < #28, #01, #03, {

  code_069CEC:
    COP [BranchIfSolidHere] ( &code_069D1D )
    LDA #$&enemy_stats_table
    STA $statsPtr, X

  loc_069CF7:
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    LDA #$0101
    TRB $10
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDA #$0101
    TSB $10
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    BRA loc_069CF7
} >
]

code_069D1D {
    COP [Die]
}