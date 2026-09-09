---------------------------------------------

crF7_proc_09F360 [
  thinker-def < #04, #08, {

  code_09F362:
    COP [QueueHdma] ( @dma_channel_09F3D4, #11 )
    COP [QueueDma] ( @dma_channel_09F36F, #11 )
    RTL 
} >
]

dma_channel_09F36F [
  dma-channel < #01, #05, #00 >   ;00
  dma-channel < #01, #FB, #FF >   ;01
  dma-channel < #01, #05, #00 >   ;02
  dma-channel < #01, #FB, #FF >   ;03
  dma-channel < #01, #04, #00 >   ;04
  dma-channel < #01, #FC, #FF >   ;05
  dma-channel < #01, #04, #00 >   ;06
  dma-channel < #01, #FC, #FF >   ;07
  dma-channel < #01, #03, #00 >   ;08
  dma-channel < #01, #FD, #FF >   ;09
  dma-channel < #01, #03, #00 >   ;0A
  dma-channel < #01, #FD, #FF >   ;0B
  dma-channel < #01, #03, #00 >   ;0C
  dma-channel < #01, #FD, #FF >   ;0D
  dma-channel < #01, #02, #00 >   ;0E
  dma-channel < #01, #FE, #FF >   ;0F
  dma-channel < #01, #02, #00 >   ;10
  dma-channel < #01, #FE, #FF >   ;11
  dma-channel < #01, #02, #00 >   ;12
  dma-channel < #01, #FE, #FF >   ;13
  dma-channel < #01, #01, #00 >   ;14
  dma-channel < #01, #FF, #FF >   ;15
  dma-channel < #01, #01, #00 >   ;16
  dma-channel < #01, #FF, #FF >   ;17
  dma-channel < #01, #01, #00 >   ;18
  dma-channel < #01, #FF, #FF >   ;19
  dma-channel < #01, #01, #00 >   ;1A
  dma-channel < #01, #FF, #FF >   ;1B
  dma-channel < #01, #00, #00 >   ;1C
]

dma_channel_09F3C7 [
  dma-channel < #01, #00, #00 >   ;00
  dma-channel < #01, #00, #00 >   ;01
  dma-channel < #01, #00, #00 >   ;02
  dma-channel < #01, #00, #00 >   ;03
]

dma_channel_09F3D4 [
  dma-channel < #27, #20, #07 >   ;00
  dma-channel < #01, #46, #07 >   ;01
  dma-channel < #01, #42, #07 >   ;02
  dma-channel < #01, #3E, #07 >   ;03
  dma-channel < #01, #3A, #07 >   ;04
  dma-channel < #01, #36, #07 >   ;05
  dma-channel < #01, #32, #07 >   ;06
  dma-channel < #01, #2E, #07 >   ;07
  dma-channel < #01, #2A, #07 >   ;08
  dma-channel < #01, #2C, #07 >   ;09
  dma-channel < #01, #30, #07 >   ;0A
  dma-channel < #01, #34, #07 >   ;0B
  dma-channel < #01, #38, #07 >   ;0C
  dma-channel < #01, #3C, #07 >   ;0D
  dma-channel < #01, #40, #07 >   ;0E
  dma-channel < #01, #44, #07 >   ;0F
  dma-channel < #01, #48, #07 >   ;10
  dma-channel < #01, #26, #07 >   ;11
  dma-channel < #01, #28, #07 >   ;12
  dma-channel < #01, #26, #07 >   ;13
  dma-channel < #01, #28, #07 >   ;14
  dma-channel < #01, #26, #07 >   ;15
  dma-channel < #01, #28, #07 >   ;16
  dma-channel < #01, #26, #07 >   ;17
  dma-channel < #01, #28, #07 >   ;18
  dma-channel < #01, #26, #07 >   ;19
  dma-channel < #01, #28, #07 >   ;1A
  dma-channel < #01, #26, #07 >   ;1B
  dma-channel < #01, #28, #07 >   ;1C
  dma-channel < #01, #26, #07 >   ;1D
  dma-channel < #01, #28, #07 >   ;1E
  dma-channel < #01, #26, #07 >   ;1F
  dma-channel < #01, #28, #07 >   ;20
  dma-channel < #01, #26, #07 >   ;21
  dma-channel < #01, #28, #07 >   ;22
  dma-channel < #01, #26, #07 >   ;23
  dma-channel < #01, #28, #07 >   ;24
  dma-channel < #01, #26, #07 >   ;25
  dma-channel < #01, #28, #07 >   ;26
  dma-channel < #01, #26, #07 >   ;27
  dma-channel < #01, #28, #07 >   ;28
  dma-channel < #01, #26, #07 >   ;29
  dma-channel < #01, #28, #07 >   ;2A
  dma-channel < #01, #26, #07 >   ;2B
  dma-channel < #01, #28, #07 >   ;2C
  dma-channel < #01, #26, #07 >   ;2D
  dma-channel < #01, #28, #07 >   ;2E
  dma-channel < #01, #26, #07 >   ;2F
  dma-channel < #01, #28, #07 >   ;30
  dma-channel < #01, #26, #07 >   ;31
  dma-channel < #01, #28, #07 >   ;32
  dma-channel < #01, #26, #07 >   ;33
  dma-channel < #01, #28, #07 >   ;34
  dma-channel < #01, #26, #07 >   ;35
  dma-channel < #01, #28, #07 >   ;36
  dma-channel < #01, #26, #07 >   ;37
  dma-channel < #01, #28, #07 >   ;38
  dma-channel < #01, #26, #07 >   ;39
  dma-channel < #01, #28, #07 >   ;3A
  dma-channel < #01, #26, #07 >   ;3B
  dma-channel < #01, #28, #07 >   ;3C
  dma-channel < #01, #26, #07 >   ;3D
  dma-channel < #01, #28, #07 >   ;3E
  dma-channel < #01, #26, #07 >   ;3F
  dma-channel < #01, #28, #07 >   ;40
  dma-channel < #01, #26, #07 >   ;41
  dma-channel < #01, #28, #07 >   ;42
  dma-channel < #01, #26, #07 >   ;43
  dma-channel < #01, #28, #07 >   ;44
  dma-channel < #01, #26, #07 >   ;45
  dma-channel < #01, #28, #07 >   ;46
]