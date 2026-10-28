; Composite block of HDMA configuration tables and ramp motion curves (121022-121201, Bank 01). Parts: hdma_channel_config (64 bytes, the DMAP transfer mode per B-bus register), hdma_entry_stride_by_mode (13 bytes, of which entries 00-02 are the HDMA entry stride per transfer mode) and the two ramp arc curves behind ramp_motion_curves (64 and 32 frames). The parts are unrelated except for sharing the block; the name hdma_ramp_tables only describes them as a group.
---------------------------------------------

?BANK 01

---------------------------------------------

; DMAP transfer mode for each PPU B-bus register — 64 byte entries indexed by the register's low byte ($2100 + index; the HDMA COP ops pass that byte, e.g. #0F = BG2HOFS, #26 = WH0). The low 3 bits are the DMAP transfer mode: 0 = one register, 1 = two registers (p, p+1), 2 = one register written twice. Matches the PPU map: 2 for the scroll registers $0D–$14, the mode 7 registers $1B–$20 and CGDATA $22, 1 for the VRAM address/data pairs $16–$19 and the window pairs $26–$29. The indirect-HDMA flag ($40) is not stored here; SetupHdmaChannel_Indirect and QueueHdmaChannel OR it in. Entries $34–$3F cover the read-only PPU registers (MPY, SLHV, OAMDATAREAD, VMDATAREAD, CGDATAREAD, OPHCT/OPVCT, STAT77/78) and carry bit 7 ($80/$81/$82), the DMAP PPU-to-CPU direction bit. Referenced by SetupHdmaChannel_Indirect/Direct in hdma_dma_spc.asm, QueueHdmaChannel in cop_handlers_hdma_dma.asm, and scanline_band_hdma_thinker.asm (which masks with AND #$07).

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

; HDMA entry stride (count byte + data bytes) indexed by the DMAP transfer mode: mode 0 = 2, modes 1 and 2 = 3. ParallaxResolveEntryStride (scanline_band_hdma_thinker) looks up hdma_channel_config[register index] & 7 and stores the result in DP $04, where the band writers use it to step the buffer write pointer. It is a stride, not a scroll speed. Only entries 00-02 ($02, $03, $03) are reachable because every config byte has a low-3-bit value of 0-2; entries 03-0C ($05, $05, $64, $00, then $FF / $7F pairs) have no reader (the FF 7F pattern resembles HDMA line-count data, inferred).

hdma_entry_stride_by_mode [
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

; Two arc entries (3 bytes each: curve address, frame count) used by RampArcDriver in ramps.asm. The ramp's arc child reads the player's statsPtr (0 or 1, set from the ramp's spawn type byte) x 3, then adds one sign-extended curve byte per frame to the PLAYER's Y ($16, confirmed: the child's $04 link is the spawner, the player). Values are pixel deltas. Entry 0: 64 frames, rises up to 204 pixels (frame 28) and returns, net 0. Entry 1: 32 frames, rises up to 50 pixels (frame 14), net +8 (ends 8 pixels lower). Both curves repeat most values twice in a row.

ramp_motion_curves [
  ramp-motion < &ramp_curve_arc_64, #40 >   ;00
  ramp-motion < &ramp_curve_arc_32, #20 >   ;01
]

---------------------------------------------
; Entry 0 of ramp_motion_curves: 64 signed Y deltas in pixels, one per frame, -16 at the start, 0 around frames 29-36 and +16 at the end. Cumulative rise peaks at -204 (up) at frame 28; the sum is 0. Used by the Itory ramp pair (spawn type 1).

ramp_curve_arc_64 #F0F0F2F2F4F4F5F5F6F6F7F7F8F8FAFAFBFBFCFCFDFDFEFEFFFFFFFF00000000000000000101010102020303040405050606080809090A0A0B0B0C0C0E0E1010

---------------------------------------------
; Entry 1 of ramp_motion_curves: 32 signed Y deltas in pixels, -8 at the start, 0 at frames 15-17 and +8 at the end. Cumulative rise peaks at -50 (up) at frame 14; the sum is +8, so the player lands 8 pixels lower. Used by all other east/west ramps (spawn type 3).

ramp_curve_arc_32 #F8F8FAFAFCFCFDFDFEFEFFFFFFFF000000010101010202030304040606080808