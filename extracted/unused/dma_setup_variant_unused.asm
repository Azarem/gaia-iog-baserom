; Unreferenced DMA setup thinker nearly identical to inventory_dma_setup but with a different channel table layout.
; 
; Appears to be an alternate inventory or menu DMA layout that was replaced by inventory_dma_setup.
---------------------------------------------

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