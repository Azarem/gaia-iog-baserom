!WH0                            2126

---------------------------------------------

diary_menu_window_dma [
  thinker-def < #04, #08, {

  code_00BBB1:
    LDA $0D96
    BMI loc_00BBBC
    LDA $0036
    LSR 
    BCC loc_00BBC7

  loc_00BBBC:
    LDA $0D92
    BPL loc_00BBCF
    LDA #$00FF
    STA $WH0

  loc_00BBC7:
    COP [QueueDma] ( @dma_channel_00BC4C, #26 )
    BRA loc_00BBEC

  loc_00BBCF:
    BNE loc_00BBD9
    COP [QueueDma] ( @dma_channel_00BC4D, #26 )
    BRA loc_00BBEC

  loc_00BBD9:
    DEC 
    BNE loc_00BBE4
    COP [QueueDma] ( @dma_channel_00BC57, #26 )
    BRA loc_00BBEC

  loc_00BBE4:
    COP [QueueDma] ( @dma_channel_00BC61, #26 )
    BRA loc_00BBEC

  loc_00BBEC:
    LDA $0D96
    BPL loc_00BBFF
    LDA #$00FF
    STA $WH0
    COP [QueueDma] ( @dma_channel_00BC4C, #26 )
    BRA loc_00BC1C

  loc_00BBFF:
    BNE loc_00BC09
    COP [QueueDma] ( @dma_channel_00BC4D, #26 )
    BRA loc_00BC1C

  loc_00BC09:
    DEC 
    BNE loc_00BC14
    COP [QueueDma] ( @dma_channel_00BC57, #26 )
    BRA loc_00BC1C

  loc_00BC14:
    COP [QueueDma] ( @dma_channel_00BC61, #26 )
    BRA loc_00BC1C

  loc_00BC1C:
    LDA $0D98
    BPL loc_00BC28
    COP [QueueDma] ( @dma_channel_00BC6E, #26 )
    RTL 

  loc_00BC28:
    BNE loc_00BC31
    COP [QueueDma] ( @dma_channel_00BC6F, #26 )
    RTL 

  loc_00BC31:
    DEC 
    BNE loc_00BC3B
    COP [QueueDma] ( @dma_channel_00BC79, #26 )
    RTL 

  loc_00BC3B:
    DEC 
    BNE loc_00BC45
    COP [QueueDma] ( @dma_channel_00BC83, #26 )
    RTL 

  loc_00BC45:
    COP [QueueDma] ( @dma_channel_00BC8D, #26 )
    RTL 
} >
]

dma_channel_00BC4C [
]

dma_channel_00BC4D [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BC57 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BC61 [
  dma-channel < #10, #FF, #00 >   ;00
  dma-channel < #7F, #FF, #00 >   ;01
  dma-channel < #1F, #10, #F0 >   ;02
  dma-channel < #60, #FF, #00 >   ;03
]

dma_channel_00BC6E [
]

dma_channel_00BC6F [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BC79 [
  dma-channel < #5F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BC83 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BC8D [
  dma-channel < #7F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]