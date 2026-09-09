?INCLUDE 'stats_01ABF0'

!statsPtr                       7F0020

---------------------------------------------

mu60_floor_spikes [
  actor-def < #28, #01, #03, {

  code_069CEC:
    COP [BranchIfSolid] ( &code_069D1D )
    LDA #$&stats_01ABF0
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