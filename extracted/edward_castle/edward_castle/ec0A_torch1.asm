?INCLUDE 'table_0EDA00'

---------------------------------------------

ec0A_torch1 [
  actor-def < #00, #00, #18, {

  code_04BF93:
    COP [BranchIfFlagByte] ( #21, #00, &code_04BFB8 )
    COP [AddPosition] ( #04, #03 )
    COP [SetMetasprite] ( @table_0EDA00 )
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