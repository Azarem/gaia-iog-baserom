; Altar object 2 in the Mu altar room — smaller puzzle element.
; 
; Second altar piece in the room. Works in conjunction with
; altar1 to complete the altar room puzzle sequence.
---------------------------------------------

---------------------------------------------

mu66_altar2 [
  actor-def < #2D, #00, #30, {

  code_069C70:
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #81, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]