; Left-side flame decoration in the Angel Village tunnels.
; 
; Static torch sprite on the left wall. Ambient lighting
; for the tunnel corridors.
---------------------------------------------

---------------------------------------------

av6D_flame_left [
  actor-def < #19, #00, #18, {

  code_06D572:
    COP [NudgePosition] ( #09, #03 )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    RTL 
} >
]