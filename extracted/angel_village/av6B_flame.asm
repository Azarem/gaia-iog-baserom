; Torch flame in Angel Village — animated fire decoration.
; 
; Looping flame sprite on a wall sconce. Provides ambient
; lighting in the dim underground village.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

av6B_flame [
  actor-def < #06, #00, #18, {

  code_06D55E:
    COP [NudgePosition] ( #09, #03 )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
} >
]