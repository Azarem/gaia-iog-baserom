; Composite block of HDMA configuration tables and ramp motion curves (121022–121201, Bank 01). Contains the DMA transfer mode lookup (64 bytes), parallax scroll speed parameters (13 bytes), and two pre-computed per-frame Y-offset arcs (64 and 32 frames) used by the ramp actors. The three parts are unrelated except for sharing the block; the name hdma_ramp_tables only describes them as a group.
---------------------------------------------

?BANK 01

---------------------------------------------

; DMAP transfer mode for each PPU B-bus register — 64 byte entries indexed by the register's low byte ($2100 + index; the HDMA COP ops pass that byte, e.g. #0F = BG2HOFS, #26 = WH0). The low 3 bits are the DMAP transfer mode: 0 = one register, 1 = two registers (p, p+1), 2 = one register written twice. Matches the PPU map: 2 for the scroll registers $0D–$14, the mode 7 registers $1B–$20 and CGDATA $22, 1 for the VRAM address/data pairs $16–$19 and the window pairs $26–$29. The indirect-HDMA flag ($40) is not stored here; SetupHdmaChannel_Indirect and QueueHdmaChannel OR it in. Entries $34–$3F cover the read-only PPU registers (MPY, SLHV, OAMDATAREAD, VMDATAREAD, CGDATAREAD, OPHCT/OPVCT, STAT77/78) and carry bit 7 ($80/$81/$82), the DMAP PPU-to-CPU direction bit. Referenced by SetupHdmaChannel_Indirect/Direct in hdma_dma_spc.asm, QueueHdmaChannel in cop_handlers_hdma_dma.asm, and parallax_thinker.asm (which masks with AND #$07).

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

; Parallax scroll speed parameters — 13 bytes. ParallaxResolveChannelSpeed (parallax_thinker.asm) indexes this table with the low 3 bits of the hdma_channel_config byte for the layer's config ID and stores the byte as that layer's speed value (DP $04). Because every config byte has a low-3-bit value of 0–2, only entries 00–02 ($02, $03, $03) are reachable that way; entries 03–0C ($05, $05, $64, $00, then $FF/$7F pairs) have no reader (E1 analysis; the FF 7F pattern resembles HDMA line-count data, inferred).

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

; Per-frame vertical offset arcs for ramp motion — 2 ramp-motion entries (3 bytes each: curve pointer, frame count), each pointing to a run of signed bytes. ramp_motion_curve_step in ramps.asm sign-extends one byte per frame and adds it to the Y position ($16) of the actor linked through the ramp actor's $04 field (the player, inferred), so the values are pixel deltas, not accelerations. Entry 0: 64 frames, −16 rising to 0 and on to +16, net 0 (returns to the starting height). Entry 1: 32 frames, −8 to +8, net +8 (ends 8 pixels lower). Curve 0 repeats most values twice in a row.

ramp_motion_curves [
  ramp-motion < &ramp_curve_arc_64, #40 >   ;00
  ramp-motion < &ramp_curve_arc_32, #20 >   ;01
]

---------------------------------------------
; Entry 0 of ramp_motion_curves: 64 signed Y deltas in pixels, one per frame, running from $F0 (−16) through 0 to $10 (+16): the slow arc.

ramp_curve_arc_64 #F0F0F2F2F4F4F5F5F6F6F7F7F8F8FAFAFBFBFCFCFDFDFEFEFFFFFFFF00000000000000000101010102020303040405050606080809090A0A0B0B0C0C0E0E1010

---------------------------------------------
; Entry 1 of ramp_motion_curves: 32 signed Y deltas in pixels, one per frame, running from $F8 (−8) through 0 to $08 (+8): the fast arc.

ramp_curve_arc_32 #F8F8FAFAFCFCFDFDFEFEFFFFFFFF000000010101010202030304040606080808