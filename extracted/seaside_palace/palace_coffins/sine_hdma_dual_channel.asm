; Dual-channel sine HDMA shimmer for Seaside Palace coffin room.
; 
; Initializes counter #$0002, builds sine tables at $7E8800 and $7E8C00 with amplitude 8, ticks at speed #02 (faster than the slow-wave template). Binds $7E8800 to HDMA channel #0F and $7E8C00 to channel #10, creating overlapping dual-layer BG scroll/window oscillation. Often paired with palace_coffin_hdma_table and palace_scroll_brightness for the full coffin room visual stack.
---------------------------------------------

---------------------------------------------

sine_hdma_dual_channel [
  thinker-def < #04, #08, {

  code_00BE85:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BE85 )
    COP [TickSineHdma] ( #02, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]