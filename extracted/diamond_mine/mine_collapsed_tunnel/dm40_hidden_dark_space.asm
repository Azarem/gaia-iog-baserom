?BANK 05

?INCLUDE 'dark_space'

---------------------------------------------

dm40_hidden_dark_space [
  actor-def < #24, #00, #20, {

  code_05D621:
    COP [BranchIfFlagWord] ( #$0132, #01, &code_05D62D )
    COP [ExitIfFlagWord] ( #$0132, #01 )
} >
]

code_05D62D {
    COP [SpawnAfterFlags] ( @dark_space.DarkSpacePortalInit, #$2B00 )
    LDA #$0001
    STA $0024, Y
    LDA #$2000
    STA $000E, Y
    COP [Die]
}