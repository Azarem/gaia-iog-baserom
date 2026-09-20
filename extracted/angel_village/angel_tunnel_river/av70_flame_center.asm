; Center flame decoration in the Angel Village river tunnel.
; 
; Animated torch sprite in the center of a tunnel room.
; Ambient visual element.
---------------------------------------------

---------------------------------------------

av70_flame_center [
  actor-def < #18, #00, #18, {

  code_06D592:
    COP [NudgePosition] ( #09, #03 )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]