; DMA setup for the ending comet scene.
; 
; Technical actor configuring DMA transfers for the visual
; display during the comet's disappearance in the epilogue.
---------------------------------------------

---------------------------------------------

ending_comet_dma_setup [
  thinker-def < #04, #08, {

  code_00BCE1:
    COP [QueueDma] ( @dma_channel_00BCE8, #10 )
    RTL 
} >
]

dma_channel_00BCE8 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #10, #00, #00 >   ;01
  dma-channel < #01, #00, #00 >   ;02
  dma-channel < #01, #00, #00 >   ;03
]