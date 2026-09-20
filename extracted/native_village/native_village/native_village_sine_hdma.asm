; Sine wave HDMA effect for the Native Village heat haze.
; 
; Technical thinker that applies a wavy heat distortion
; effect to the screen. Creates the tropical heat shimmer
; atmosphere for the village area.
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