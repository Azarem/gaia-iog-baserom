; Sine HDMA effect for the ending comet scene.
; 
; Screen distortion during the comet's final moments.
; Creates a warping visual as the comet's power dissipates.
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
    COP [SetEntryHereAndYield]
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]