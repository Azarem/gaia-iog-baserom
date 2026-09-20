; Right-side flame decoration in the Angel Village tunnels.
; 
; Static torch sprite on the right wall. Paired with
; flame_left for symmetrical corridor lighting.
---------------------------------------------

---------------------------------------------

av6D_flame_right [
  actor-def < #19, #00, #18, {

  code_06D581:
    COP [ToggleHMirror]
    COP [NudgePosition] ( #09, #03 )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #99 )
    COP [AnimOnce]
    RTL 
} >
]