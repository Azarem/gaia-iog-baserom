; Space background parallax scroll for the space flight.
; 
; Manages the scrolling starfield background during
; the approach to the comet. Multi-layer parallax
; for depth effect in space.
---------------------------------------------

---------------------------------------------

sE7_space_bg_scroll [
  thinker-def < #04, #08, {

  code_0CEB5D:
    COP [SetEntryExit]
    LDA $0720
    CLC 
    ADC #$FFF8
    STA $0720
    COP [QueueHdma] ( @dma_channel_0CEB70, #0E )
    RTL 
} >
]

dma_channel_0CEB70 [
  dma-channel < #20, #20, #07 >
]