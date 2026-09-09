---------------------------------------------

h_ec0A_torch2 [
  actor-def < #00, #00, #18, {

  code_04BB7D:
    COP [BranchIfFlagByte] ( #21, #00, &code_04BBA2 )
    COP [AddPosition] ( #FE, #03 )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #06 )
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]

  loc_04BB98:
    COP [WaitWhileOffscreen] ( #03 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_04BB98
} >
]

code_04BBA2 {
    COP [Die]
}