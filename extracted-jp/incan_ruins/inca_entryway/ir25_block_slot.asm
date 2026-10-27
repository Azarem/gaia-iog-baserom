---------------------------------------------

h_ir25_block_slot [
  actor-def < #1D, #01, #23, {

  code_04FDCD:
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_04FDDE )
    COP [WaitOnFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )
} >
]

code_04FDDE {
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}