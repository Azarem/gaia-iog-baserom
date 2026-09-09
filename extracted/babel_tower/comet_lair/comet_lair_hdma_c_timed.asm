---------------------------------------------

comet_lair_hdma_c_timed [
  thinker-def < #04, #08, {

  code_00BD44:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &comet_lair_hdma_c_timed )
    COP [BranchIfFlagByte] ( #01, #01, &code_00BD69 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 
} >
]

code_00BD69 {
    LDA #$0070
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #04 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BD69 )
    LDA $7F0008, X
    DEC 
    STA $7F0008, X
    BEQ loc_00BD93
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 

  loc_00BD93:
    COP [SetEntryContinue]
    RTL 
}