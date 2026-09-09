?INCLUDE 'dm_func_0ADB6B'

---------------------------------------------

dm41_actor_05D70A [
  actor-def < #30, #00, #00, {

  code_05D70D:
    LDA #$0011
    TSB $12

  loc_05D712:
    COP [WaitWhileOffscreen] ( #0D )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @dm_func_0ADB6B, #00, #CE, #$0202 )
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_05D712

  loc_05D732:
    TSB $1000
    RTL 
} >
]