; Frozen Whirligig — static decorative obstacle in the wind tunnel (map $21).
; 
; Non-moving solid actor. Sets collision flag $0010, offsets position
; by (+8,+8), displays sprite frame #1B, then idles. Represents a
; whirligig blade that has stopped spinning (contrast with the active
; ir21_whirligig that spins and spawns projectiles).
---------------------------------------------

---------------------------------------------

ir21_frozen_whirligig [
  actor-def < #1B, #00, #00, {

  code_0A99C6:
    LDA #$0010
    TSB $12
    COP [AddPosition] ( #08, #08 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]