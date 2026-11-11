; Animated wall torch in Edward Castle (instance 2, eleven placements in scene $0A).
; 
; Same script as ec0A_torch1 with another position nudge: with flag $21 CLEAR the actor dies at spawn, so the torches exist only after the throne scene.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

ec0A_torch2 [
  actor-def < #00, #00, #18, {

  code_04BFBD:
    COP [BranchOnFlagByte] ( #21, #00, &code_04BFE2 )
    COP [NudgePosition] ( #FE, #03 )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #06 )
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryHereAndYield]

  loc_04BFD8:
    COP [WaitWhileOffscreen] ( #03 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_04BFD8
} >
]

code_04BFE2 {
    COP [Die]
}