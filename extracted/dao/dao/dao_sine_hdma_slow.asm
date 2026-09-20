; Slow sine wave HDMA effect for Dao's heat haze.
; 
; Technical thinker creating a gentle heat distortion
; effect for the desert town atmosphere.
---------------------------------------------

---------------------------------------------

dao_sine_hdma_slow [
  thinker-def < #04, #08, {

  code_00BED3:
    LDA #$0010
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BED3 )
    COP [TickSineHdma] ( #00, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]