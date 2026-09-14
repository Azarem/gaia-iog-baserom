; Composite block of HDMA configuration tables and ramp motion curves. Contains the DMA transfer mode lookup (64 bytes), parallax scroll speed parameters (13 bytes), and two pre-computed acceleration/deceleration curves for slope/stair movement.
---------------------------------------------

?BANK 01

---------------------------------------------

; DMA transfer mode lookup table for HDMA channel configuration — 64 byte entries. Each byte is a DMAP register value (transfer mode + direction bits): $00 = 1-byte single register, $01 = 2-byte register pair, $02 = 2-byte same register, $80/$81/$82 = same with indirect flag. Referenced by SetupHdmaChannel_Indirect/Direct in hdma_dma_spc.asm, parallax_thinker.asm, and cop_handlers_collision.asm.

hdma_channel_config [
  #00   ;00
  #00   ;01
  #01   ;02
  #01   ;03
  #02   ;04
  #00   ;05
  #00   ;06
  #00   ;07
  #00   ;08
  #00   ;09
  #00   ;0A
  #00   ;0B
  #00   ;0C
  #02   ;0D
  #02   ;0E
  #02   ;0F
  #02   ;10
  #02   ;11
  #02   ;12
  #02   ;13
  #02   ;14
  #00   ;15
  #01   ;16
  #01   ;17
  #01   ;18
  #01   ;19
  #00   ;1A
  #02   ;1B
  #02   ;1C
  #02   ;1D
  #02   ;1E
  #02   ;1F
  #02   ;20
  #00   ;21
  #02   ;22
  #00   ;23
  #00   ;24
  #00   ;25
  #01   ;26
  #01   ;27
  #01   ;28
  #01   ;29
  #00   ;2A
  #00   ;2B
  #00   ;2C
  #00   ;2D
  #00   ;2E
  #00   ;2F
  #00   ;30
  #00   ;31
  #00   ;32
  #00   ;33
  #80   ;34
  #80   ;35
  #80   ;36
  #80   ;37
  #82   ;38
  #81   ;39
  #81   ;3A
  #82   ;3B
  #82   ;3C
  #82   ;3D
  #80   ;3E
  #80   ;3F
]
---------------------------------------------

; Parallax scroll speed parameters — 13 bytes. Contains shift/scale values used by parallax_thinker to calculate per-layer scroll rates. Values include mode bytes, speed divisors, and $FF/$7F sentinel markers. Referenced alongside hdma_channel_config by parallax_thinker.asm.

parallax_speed_config [
  #02   ;00
  #03   ;01
  #03   ;02
  #05   ;03
  #05   ;04
  #64   ;05
  #00   ;06
  #FF   ;07
  #7F   ;08
  #FF   ;09
  #7F   ;0A
  #FF   ;0B
  #7F   ;0C
]
---------------------------------------------

; Pre-computed acceleration/deceleration curves for ramp movement — 2 ramp-motion entries, each pointing to a binary curve. Entry 0: 64-frame curve (values $F0→$00→$10, slow ramp). Entry 1: 32-frame curve (values $F8→$00→$08, fast ramp). Used by ramps.asm to smoothly accelerate the player when stepping onto slopes/stairs.

ramp_motion_curves [
  ramp-motion < &binary_01D911, #40 >   ;00
  ramp-motion < &binary_01D951, #20 >   ;01
]

binary_01D911 #F0F0F2F2F4F4F5F5F6F6F7F7F8F8FAFAFBFBFCFCFDFDFEFEFFFFFFFF00000000000000000101010102020303040405050606080809090A0A0B0B0C0C0E0E1010

binary_01D951 #F8F8FAFAFCFCFDFDFEFEFFFFFFFF000000010101010202030304040606080808