---------------------------------------------

sine_hdma_slow_wave [
  thinker-def < #04, #08, {

  code_00BE1A:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BE1A )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]