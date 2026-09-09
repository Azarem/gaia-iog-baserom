---------------------------------------------

comet_lair_hdma_b [
  thinker-def < #04, #08, {

  code_00BD23:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8400, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &comet_lair_hdma_b )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0F )
    RTL 
} >
]