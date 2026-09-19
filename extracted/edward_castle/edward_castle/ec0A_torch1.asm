; Animated torch actor in Edward Castle (instance 1).
; 
; Cosmetic flickering torch sprite for castle ambiance.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

ec0A_torch1 [
  actor-def < #00, #00, #18, {

  code_04BF93:
    COP [BranchIfFlagByte] ( #21, #00, &code_04BFB8 )
    COP [AddPosition] ( #04, #03 )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #06 )
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]

  loc_04BFAE:
    COP [WaitWhileOffscreen] ( #02 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_04BFAE
} >
]

code_04BFB8 {
    COP [Die]
}