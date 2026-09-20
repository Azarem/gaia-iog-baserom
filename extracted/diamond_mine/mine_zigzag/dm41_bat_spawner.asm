; Bat spawner in the mine zigzag area — periodically spawns homing mines.
; 
; Invisible actor that loops: waits until offscreen is false (#0D),
; plays a 3-frame opening animation (frames #2F → #30 → #31), spawns
; a dm_follower_behavior child at relative offset (0, -$32) that
; chases the player, then waits $3B frames before repeating.
---------------------------------------------

?INCLUDE 'dm_follower_behavior'

---------------------------------------------

dm41_bat_spawner [
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
    COP [SpawnListAppend] ( @dm_follower_behavior, #00, #CE, #$0202 )
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_05D712

  loc_05D732:
    TSB $1000
    RTL 
} >
]