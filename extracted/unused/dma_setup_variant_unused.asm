---------------------------------------------

dma_setup_variant_unused [
  thinker-def < #04, #08, {

  code_00BC99:
    COP [QueueDma] ( @dma_channel_00BCA0, #12 )
    RTL 
} >
]

dma_channel_00BCA0 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #40, #00, #00 >   ;01
  dma-channel < #0C, #04, #00 >   ;02
  dma-channel < #0C, #08, #00 >   ;03
  dma-channel < #20, #0C, #00 >   ;04
  dma-channel < #20, #00, #00 >   ;05
]