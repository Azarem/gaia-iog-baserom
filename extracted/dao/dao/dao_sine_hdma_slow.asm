; Gentle ambient sine HDMA for Dao Village's tranquil atmosphere, slot #00, paired with dao_window_mask.
; 
; Uses the slowest tick speed (#00, one table step per frame), amplitude 40 at $7E8800, and counter init #$0010 (16 frames). Binds $7E8800 to HDMA channel #0D (BG1 horizontal scroll offset) each frame via SetEntryExit. Produces an almost imperceptible background sway — the subtlest sine wave variant in the engine.
---------------------------------------------

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