?INCLUDE 'chunk_088000'

---------------------------------------------

h_ec12_actor_04F9DC [
  actor-def < #00, #00, #23, {

  code_04F9DF:
    COP [BranchIfFlagWord] ( #$0116, #01, &code_04F9EE )
    COP [ExitIfFlagWord] ( #$0116, #01 )
    COP [WaitByte] ( #B3 )
} >
]

code_04F9EE {
    COP [SpawnAfterAbsFlags] ( @chunk_088000.code_08D1C3, #$00A8, #$04C0, #$0B00 )
    LDA #$0001
    STA $0024, Y
    COP [Die]
}