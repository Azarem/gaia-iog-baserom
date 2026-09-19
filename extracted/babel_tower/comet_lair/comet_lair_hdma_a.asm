; Primary Comet Lair sine HDMA distortion layer, slot #03 in the Lair thinker stack.
; 
; Seeds counter #$0001, initializes sine table at $7E8800 with amplitude 8, zeroes $7E8C30/$7E8E30, and supports full re-init when flag #FF is clear. Ticks at speed #05 and binds $7E8C00 to HDMA channel #10 each frame, producing fast BG scroll/window oscillation. Works alongside comet_lair_hdma_b and comet_lair_hdma_c_timed as one of three overlapping wave layers in the Lair.
---------------------------------------------

---------------------------------------------

comet_lair_hdma_a [
  thinker-def < #04, #08, {

  code_00BCF7:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    LDA #$0000
    STA $7E8C30
    STA $7E8E30
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BCF7 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]