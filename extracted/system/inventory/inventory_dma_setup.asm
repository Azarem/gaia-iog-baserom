---------------------------------------------

inventory_dma_setup [
  thinker-def < #04, #08, {

  code_00BB90:
    COP [QueueDma] ( @dma_channel_00BB97, #12 )
    RTL 
} >
]

dma_channel_00BB97 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #30, #00, #00 >   ;01
  dma-channel < #0C, #0B, #00 >   ;02
  dma-channel < #0C, #0F, #00 >   ;03
  dma-channel < #0C, #13, #00 >   ;04
  dma-channel < #0C, #17, #00 >   ;05
  dma-channel < #40, #20, #00 >   ;06
]