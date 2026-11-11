; Animated wall torch in Edward Castle (instance 1, ten placements in scene $0A).
; 
; The torch exists only after the throne scene: with flag $21 CLEAR the actor dies at spawn; with $21 set it runs the flame loop (RNG-phase start, WaitWhileOffscreen, frame #06 animation).
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

ec0A_torch1 [
  actor-def < #00, #00, #18, {

  code_04BF93:
    COP [BranchOnFlagByte] ( #21, #00, &code_04BFB8 )
    COP [NudgePosition] ( #04, #03 )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #06 )
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryHereAndYield]

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