; Background decorative sprite B in Freejia town.
; 
; Non-interactive animated sprite for street ambiance. No dialog.
---------------------------------------------

---------------------------------------------

fr32_bg_sprite_b [
  actor-def < #22, #02, #10, {

  code_05CF07:
    COP [WaitWhileOffscreen] ( #06 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    RTL 
} >
]