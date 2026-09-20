; Decorative flower in Watermia — ambient visual.
; 
; Non-interactable animated flower sprite for town decoration.
---------------------------------------------

---------------------------------------------

wa78_flower [
  actor-def < #1E, #00, #18, {

  code_079B6A:
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryHereAndYield]
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    RTL 
} >
]