; Dual-channel sine HDMA thinker for the Ending Comet flight sequence, paired with ending_comet_dma_setup.
; 
; Initializes an 8-frame counter, builds a sine table at $7E8800 with amplitude 8 via InitSineHdma, and zeroes auxiliary offsets $7E8C30/$7E8E30. Each frame ticks at speed #05 and binds $7E8800 to HDMA channel #0F and $7E8C00 to channel #10, oscillating BG scroll/window registers for the starfield distortion. Fast dual-layer wave motion creates the comet-approach visual warp during Tim's flight cutscene.
---------------------------------------------

---------------------------------------------

ending_comet_sine_hdma [
  thinker-def < #04, #08, {

  code_00BCB5:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    LDA #$0000
    STA $7E8C30
    STA $7E8E30
    COP [SetEntryExit]
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]