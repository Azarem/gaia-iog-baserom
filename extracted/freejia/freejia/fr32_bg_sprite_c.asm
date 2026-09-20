; Background decorative sprite C in Freejia town.
; 
; Non-interactive animated sprite with different frame count.
; No dialog.
---------------------------------------------

---------------------------------------------

fr32_bg_sprite_c [
  actor-def < #24, #02, #10, {

  code_05CF13:
    COP [NudgePosition] ( #08, #00 )
    COP [WaitWhileOffscreen] ( #07 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    RTL 
} >
]