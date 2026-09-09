---------------------------------------------

h_ec0A_torch1 [
  actor-def < #00, #00, #18, {

  code_04BB53:
    COP [BranchIfFlagByte] ( #21, #00, &code_04BB78 )
    COP [AddPosition] ( #04, #03 )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #06 )
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]

  loc_04BB6E:
    COP [WaitWhileOffscreen] ( #02 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_04BB6E
} >
]

code_04BB78 {
    COP [Die]
}