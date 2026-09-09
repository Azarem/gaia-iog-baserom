---------------------------------------------

crF7_proc_09F330 [
  thinker-def < #04, #08, {

  code_09F332:
    LDA $7F2104, X
    INC 
    STA $7F2104, X
    LSR 
    BCC loc_09F34B
    LDA $0720
    STA $0722
    COP [QueueHdma] ( @dma_channel_09F358, #12 )
    RTL 

  loc_09F34B:
    LDA $0720
    STA $0724
    COP [QueueHdma] ( @dma_channel_09F35C, #12 )
    RTL 
} >
]

dma_channel_09F358 [
  dma-channel < #01, #22, #07 >
]

dma_channel_09F35C [
  dma-channel < #01, #24, #07 >
]