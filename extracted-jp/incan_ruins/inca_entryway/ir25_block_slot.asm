---------------------------------------------

h_ir25_block_slot [
  actor-def < #1D, #01, #23, {

  code_04FDCD:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #2F, #01, &code_04FDDE )
    COP [ExitIfFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )
} >
]

code_04FDDE {
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}