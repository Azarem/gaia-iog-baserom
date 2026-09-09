---------------------------------------------

sE7_thinker_0CEB5B [
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