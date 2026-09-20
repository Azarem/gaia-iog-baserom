; Dual-channel sine HDMA effect for the coffin room.
; 
; Two-channel HDMA creating overlapping wave distortions
; for the supernatural atmosphere of the coffin area.
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