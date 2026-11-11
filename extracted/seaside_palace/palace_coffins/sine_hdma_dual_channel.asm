; Dual-channel sine HDMA wave of the Seaside Palace.
; 
; Thinker of the palace scenes $5A, $5B and $5C and of scene $6F. It starts a sine HDMA (InitSineHdma #$8800, #08) and restarts it every frame while scene setup flag $FF is clear; once $FF is set it ticks the wave (TickSineHdma #02, #02) and binds the wave tables $7E8800 and $7E8C00 (BindSineHdma, #0F and #10) each frame.
---------------------------------------------

---------------------------------------------

sine_hdma_dual_channel [
  thinker-def < #04, #08, {

  code_00BE85:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BE85 )
    COP [TickSineHdma] ( #02, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]