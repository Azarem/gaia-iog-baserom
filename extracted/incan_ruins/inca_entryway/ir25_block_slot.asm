---------------------------------------------

ir25_block_slot [
  actor-def < #1D, #01, #23, {

  code_09C3A2:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #2F, #01, &code_09C3B3 )
    COP [ExitIfFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )
} >
]

code_09C3B3 {
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}