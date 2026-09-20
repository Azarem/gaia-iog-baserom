; Curtain decoration in the vampire lair entrance.
; 
; Visual prop that reveals the lair behind it. No dialog.
; Animated curtain sprite for atmosphere.
---------------------------------------------

---------------------------------------------

mu67_lair_curtain [
  actor-def < #03, #00, #30, {

  code_06A82B:
    COP [WaitOnFlagByte] ( #88, #01 )
    COP [WaitByte] ( #1D )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
} >
]