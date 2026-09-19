---------------------------------------------

fr32_bg_sprite_a [
  actor-def < #22, #02, #10, {

  code_05CEFB:
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]