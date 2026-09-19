; One-shot window register DMA setup for Angel Village tunnel rooms.
; 
; Queues a 2-channel DMA burst via QueueDma: first entry targets register #$6F (WH0/WH1 horizontal window positions) with bytes #$15/#$70, second targets #$15 (WBGLOG window area logic) with #$01/#$00. Configures SNES window registers to mask background layers, producing the tunnel light-beam clipping effect. Runs once on scene entry then RTL.
---------------------------------------------

---------------------------------------------

angel_tunnel_window_dma [
  thinker-def < #04, #08, {

  code_00B87D:
    COP [QueueDma] ( @dma_channel_00B884, #2C )
    RTL 
} >
]

dma_channel_00B884 [
  dma-channel < #6F, #15, #70 >   ;00
  dma-channel < #15, #01, #00 >   ;01
]