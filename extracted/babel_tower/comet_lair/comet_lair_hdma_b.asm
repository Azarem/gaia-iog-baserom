; Secondary Comet Lair sine HDMA distortion layer, slot #04.
; 
; Uses counter init #$0008 and a distinct WRAM table base at $7E8400 (amplitude 8), re-initing when flag #FF is clear. Ticks at speed #05 and binds $7E8400 to HDMA channel #0F, creating a second independent scroll/window oscillation. Combined with variant A on channel #10, produces overlapping dual-layer background warp in the Comet Lair.
---------------------------------------------

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