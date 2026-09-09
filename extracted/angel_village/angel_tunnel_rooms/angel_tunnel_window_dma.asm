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