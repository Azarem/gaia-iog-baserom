; Thinker that initializes an 8-step sine HDMA wave on channel $8800 (40-byte table), ticks it slowly (speed #01, amplitude #02), and binds to HDMA register $0D.
; 
; Spawned on Dao and ending-comet scene groups. Creates a gentle vertical sine-wave distortion effect on background layers.
---------------------------------------------

---------------------------------------------

sine_hdma_slow_wave [
  thinker-def < #04, #08, {

  code_00BE1A:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BE1A )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]