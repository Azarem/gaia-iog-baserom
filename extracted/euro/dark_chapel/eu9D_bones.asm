; Bones decoration in the Euro dark chapel.
; 
; Non-interactive prop in the chapel. Visual atmosphere
; element suggesting the chapel's dark history.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

eu9D_bones [
  actor-def < #02, #00, #10, {

  code_07D23A:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [NudgePosition] ( #00, #04 )
    COP [SetEntryHere]
    RTL 
} >
]