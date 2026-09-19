; One-shot PPU register DMA initializer for Ending Comet and Comet Lair entry.
; 
; Queues a 4-entry DMA table writing to registers #$70, #$10, #$01, and #$01 — configuring VMADD, VMAIN, and related video port settings for bitmap-mode display. Runs once on scene entry to set up VRAM access and video hardware before the comet flight or lair visuals render. No per-frame behavior; paired with ending_comet_sine_hdma and ambient palette thinkers in the comet scene stack.
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