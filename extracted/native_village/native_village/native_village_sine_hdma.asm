; Jungle canopy sway sine HDMA for Native Village / Amazon area.
; 
; Initializes counter #$0004, builds sine table at $7E8800 with amplitude 20, ticks at speed #04. Binds $7E8C00 to both HDMA channel #0E and channel #10 simultaneously, doubling the effective oscillation amplitude on the same table. Creates visible background sway suggesting wind through the jungle canopy.
---------------------------------------------

---------------------------------------------

native_village_sine_hdma [
  thinker-def < #04, #08, {

  code_00BEF4:
    LDA #$0004
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #20 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BEF4 )
    COP [TickSineHdma] ( #04, #02 )
    COP [BindSineHdma] ( $7E8C00, #0E )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]