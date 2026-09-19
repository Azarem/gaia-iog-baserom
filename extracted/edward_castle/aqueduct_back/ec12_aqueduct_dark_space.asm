?INCLUDE 'dark_space'

---------------------------------------------

ec12_aqueduct_dark_space [
  actor-def < #00, #00, #23, {

  code_09BF6E:
    COP [BranchIfFlagWord] ( #$0116, #01, &code_09BF7D )
    COP [ExitIfFlagWord] ( #$0116, #01 )
    COP [WaitByte] ( #B3 )
} >
]

code_09BF7D {
    COP [SpawnAfterAbsFlags] ( @dark_space.DarkSpacePortalInit, #$00A8, #$04C0, #$0B00 )
    LDA #$0001
    STA $0024, Y
    COP [Die]
}