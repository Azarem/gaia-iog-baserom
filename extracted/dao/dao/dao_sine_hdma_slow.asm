---------------------------------------------

dao_sine_hdma_slow [
  thinker-def < #04, #08, {

  code_00BED3:
    LDA #$0010
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BED3 )
    COP [TickSineHdma] ( #00, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]