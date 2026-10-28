; Boot-time hardware and RAM initialisation plus two per-frame VBlank DMA routines (Bank 02).
; 
; - InitHardwareRegisters and InitSystemVariables are boot code: SystemInit (system_core) calls them once, in that order, with DBR = $81 (so the absolute $0000,Y stores below reach the LowRAM mirror and the $2100/$4200 registers).
; - UploadCgramPalette and UploadOamTable are NOT boot code: the NMI handler calls them every VBlank (steps 5 and 6 of NmiHandler); UploadCgramPalette is also called by the camera refresh (camera_tilemap) and by the inventory overlay. They assume the NMI register state: A already 8-bit, index registers 16-bit (they contain no REP/SEP for X).
; - DmaFixedByteFill is the zero-fill helper of InitSystemVariables.
; 
; === WRAM clear ===
; Three fixed-source DMA passes through the WRAM port ($2180): $0000-$00FF ($100 bytes), then from $0200 for $FF00 bytes (7E:0200 up to 7F:00FF; the WRAM address is 17 bits wide and keeps counting across the bank boundary), then the next $FF00 bytes without resetting the address (7F:0100-7F:FFFF). Total $1FF00 bytes: all 128 KB except the stack page $0100-$01FF. The zero byte is read from the ROM (first byte of math_lookup_tables.sine_table_8bit, sin(0) = $00; the older comment said slope_curve_table).
; 
; === SystemInitConstants (34 word writes, ;00-;21) ===
; Layer map bases mapTilemapBaseA/B = $A000/$C000; DP $80-$82 = the collision map long pointer $7F:C000 (see AGENTS: never corrupt it); bgTilemapVramBase = $1000/$1800 (matches BG1SC/BG2SC below); metatileDefBase = $2000 (layer 0) and $06B0 = $2800 (layer 1, unnamed second word of the same array); strip staging pointers; collisionFlagTableL0/L1 = $0000/$0100 (offsets inside bank $7F); scene_meta pointer in $3A/$3C; the RAM stub bytes $0402 = 8B 54 and $0406 = AB 60 (PHB; MVN; PLB; RTS with the two MVN bank bytes filled in at $0404/$0405 when used); $5E/$60/$62 = 0/$0081/0 (consumers not traced); gfxCacheIdxB = 1, gfxCacheIdxA = $0404 (also the address of the stub's MVN operand pair); the joypad remap words remapL $0020, remapR $0010, remapB $4008, remapA $8080, remapY $0040, remapX $0004, remapSelect $2000, remapStart $1000 (db-us/transforms.json rewrites the four face-button defaults from the vanilla ROM values); $0B14 = $003C (no reader found anywhere in extracted); inventoryEquippedIndex = $FFFF; $0B04 = 0 (saved dialog frame delay that DialogStringRenderer restores).
; 
; === PpuRegisterInitTable (76 writes, ;00-;4B) ===
; Disables DMA/HDMA, INIDISP $80 (forced blank), OBJSEL $02, BGMODE $09 (mode 1 with BG3 on top), BG1SC $11 / BG2SC $19 (VRAM $1000 / $1800, 64x32), BG3SC $78, BG12NBA $22, BG34NBA $06 (BG3 characters at $6000: the dialog font), zeroed scroll/Mode 7 registers (the two writes per register fill both bytes of the write-twice ports; M7A = $0100), VMAIN $80, window masks $33 with WH1 $FF, TM $04 (only BG3 on the main screen), CGWSEL $82, COLDATA $E0, NMITIMEN 0, WRIO $FF, and MEMSEL 0 as the LAST entry. SystemInit stores MEMSEL = 1 before calling InitHardwareRegisters, so this entry switches FastROM timing back off; sFB_boot_logo turns it on again later. Data ports and CGADD data ($2104, $2118/9, $2122) are not part of the table.
---------------------------------------------

?BANK 02

?INCLUDE 'math_lookup_tables'
?INCLUDE 'scene_meta'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!mapTilemapBaseA                069E
!mapTilemapBaseB                06A0
!collisionFlagTableL0           06AA
!collisionFlagTableL1           06AC
!metatileDefBase                06AE
!colStripStagingPtr             06B2
!rowStripStagingPtr             06B6
!bgTilemapVramBase              06BA
!inventoryEquippedIndex         0AC4
!remapR                         0DA6
!remapL                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapX                         0DB0
!remapStart                     0DB2
!remapSelect                    0DB4
!INIDISP                        2100
!OBJSEL                         2101
!OAMADDL                        2102
!OAMADDH                        2103
!BGMODE                         2105
!MOSAIC                         2106
!BG1SC                          2107
!BG2SC                          2108
!BG3SC                          2109
!BG4SC                          210A
!BG12NBA                        210B
!BG34NBA                        210C
!BG1HOFS                        210D
!BG1VOFS                        210E
!BG2HOFS                        210F
!BG2VOFS                        2110
!BG3HOFS                        2111
!BG3VOFS                        2112
!BG4HOFS                        2113
!BG4VOFS                        2114
!VMAIN                          2115
!VMADDL                         2116
!VMADDH                         2117
!M7SEL                          211A
!M7A                            211B
!M7B                            211C
!M7C                            211D
!M7D                            211E
!M7X                            211F
!M7Y                            2120
!CGADD                          2121
!W12SEL                         2123
!W34SEL                         2124
!WOBJSEL                        2125
!WH0                            2126
!WH1                            2127
!WH2                            2128
!WH3                            2129
!WBGLOG                         212A
!WOBJLOG                        212B
!TM                             212C
!TS                             212D
!TMW                            212E
!TSW                            212F
!CGWSEL                         2130
!CGADSUB                        2131
!COLDATA                        2132
!SETINI                         2133
!WMADDL                         2181
!WMADDH                         2183
!NMITIMEN                       4200
!WRIO                           4201
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVH                         4205
!WRDIVB                         4206
!HTIMEL                         4207
!HTIMEH                         4208
!VTIMEL                         4209
!VTIMEH                         420A
!MDMAEN                         420B
!HDMAEN                         420C
!MEMSEL                         420D
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!backdropColors                 7F0C00

---------------------------------------------

; VBlank DMA (called by NmiHandler every frame, by the camera refresh and by the inventory overlay): CGADD = 0, then 512 bytes from WRAM $7F:0A00 through DMA channel 0 to CGRAM ($2122). Afterwards the three bytes at $7F:0C00-$7F:0C02 are written verbatim to COLDATA ($2132); each byte must therefore carry its own channel-select bits (blue $80, green $40, red $20) and a 5-bit intensity. Entry contract: A 8-bit, X 16-bit (no REP/SEP for X).

UploadCgramPalette {
    PHP 
    SEP #$20              ; A becomes 8-bit; X must already be 16-bit (the NMI leaves it that way)
    STZ $CGADD            ; CGADD=0: palette write starts at index 0
    STZ $DMAP0            ; DMAP0 = 0: CPU to PPU, incrementing source, one register per unit
    LDA #$22              ; BBAD0=$22: CGRAM data write register
    STA $BBAD0
    LDX #$0A00            ; Source: palette buffer at WRAM $7F0A00
    STX $A1T0L
    LDA #$7F
    STA $A1B0
    LDX #$0200            ; 512 bytes = 256 colors × 2 bytes each
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    LDA $backdropColors   ; Three bytes from $7F0C00-$7F0C02 go to COLDATA verbatim: each carries its own channel-select bits (blue $80, green $40, red $20)
    STA $COLDATA
    LDA $7F0C01
    STA $COLDATA
    LDA $7F0C02
    STA $COLDATA
    PLP 
    RTL 
}

---------------------------------------------
; VBlank DMA (called by NmiHandler every frame): OAMADD = 0, then $0220 bytes (512 main table + 32 high-table bytes) from WRAM $0422 through DMA channel 0 to the OAM port ($2104). Entry contract: X 16-bit, A 8-bit as left by the NMI.

UploadOamTable {
    PHP 
    LDX #$0000            ; OAM address word = 0 (X is 16-bit on entry)
    STX $OAMADDL          ; OAM address = 0: start at first sprite entry
    STZ $DMAP0
    LDA #$04              ; BBAD0=$04: OAM data register
    STA $BBAD0
    LDX #$0422            ; Source: OAM staging buffer at $0422
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDX #$0220            ; 544 bytes: 512 main table + 32 high-table attribute bytes
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTL 
}

---------------------------------------------
; Boot only (SystemInit). Zeroes all WRAM except the stack page $0100-$01FF with three DmaFixedByteFill passes ($1FF00 bytes in total; see the block note), then copies the 34 word entries of SystemInitConstants to their destinations (negative destination ends the table).

InitSystemVariables {
    PHP 
    REP #$20
    LDA #$0000
    SEP #$20
    STA $WMADDH
    REP #$20
    STA $WMADDL           ; Begin zero-fill at WRAM $0000
    LDY #$0100            ; Fill $0100 bytes (direct page area)
    JSR $&DmaFixedByteFill
    LDA #$0200            ; Skip stack ($0100-$01FF), resume fill at $0200
    STA $WMADDL
    LDY #$FF00            ; Second pass: $FF00 bytes from 7E:0200, ending at 7F:00FF (the WRAM address is 17 bits and crosses the bank)
    JSR $&DmaFixedByteFill
    LDY #$FF00            ; Third pass continues at 7F:0100 (address not reset) through 7F:FFFF: all WRAM except the stack page is zero
    JSR $&DmaFixedByteFill
    LDX #$0000

  loc_029E6F:
    LDA $@SystemInitConstants, X ; Read destination address from init constant table
    BMI loc_029E83        ; Negative address = end-of-table sentinel
    TAY 
    LDA $@SystemInitConstants+2, X ; Load initialization value to WRAM destination
    STA $0000, Y
    INX 
    INX 
    INX 
    INX 
    BRA loc_029E6F

  loc_029E83:
    PLP 
    RTL 
}

---------------------------------------------
; 34 entries of [destination word, value word] terminated by a destination word with bit 15 set (a lone FFFF in the ROM). See the block note for the meaning of each group.

SystemInitConstants [
  wram-init < $mapTilemapBaseA, #$A000 >   ;00
  wram-init < $mapTilemapBaseB, #$C000 >   ;01
  wram-init < $0080, #$C000 >   ;02
  wram-init < $0082, #$007F >   ;03
  wram-init < $bgTilemapVramBase, #$1000 >   ;04
  wram-init < $bgTilemapVramBase+2, #$1800 >   ;05
  wram-init < $metatileDefBase, #$2000 >   ;06
  wram-init < $06B0, #$2800 >   ;07
  wram-init < $colStripStagingPtr, #$3100 >   ;08
  wram-init < $colStripStagingPtr+2, #$3288 >   ;09
  wram-init < $rowStripStagingPtr, #$3184 >   ;0A
  wram-init < $rowStripStagingPtr+2, #$330C >   ;0B
  wram-init < $collisionFlagTableL0, #$0000 >   ;0C
  wram-init < $collisionFlagTableL1, #$0100 >   ;0D
  wram-init < $003A, &scene_meta >   ;0E
  wram-init < $003C, *scene_meta >   ;0F
  wram-init < $0402, #$548B >   ;10
  wram-init < $0406, #$60AB >   ;11
  wram-init < $005E, #$0000 >   ;12
  wram-init < $0060, #$0081 >   ;13
  wram-init < $0062, #$0000 >   ;14
  wram-init < $gfxCacheIdxB, #$0001 >   ;15
  wram-init < $gfxCacheIdxA, #$0404 >   ;16
  wram-init < $remapL, #$0020 >   ;17
  wram-init < $remapR, #$0010 >   ;18
  wram-init < $remapB, #$4008 >   ;19
  wram-init < $remapA, #$8080 >   ;1A
  wram-init < $remapY, #$0040 >   ;1B
  wram-init < $remapX, #$0004 >   ;1C
  wram-init < $remapSelect, #$2000 >   ;1D
  wram-init < $remapStart, #$1000 >   ;1E
  wram-init < $0B14, #$003C >   ;1F
  wram-init < $inventoryEquippedIndex, #$FFFF >   ;20
  wram-init < $0B04, #$0000 >   ;21
]

---------------------------------------------
; Fills Y bytes of WRAM, starting at the current WMADD address, with a zero byte read from ROM. DMA channel 0 mode $08 (fixed source address, one register), B-bus $80 (WRAM data port), source = first byte of math_lookup_tables.sine_table_8bit (sin 0 = $00). The WRAM address advances across banks, so the caller does not have to reset it between passes.

DmaFixedByteFill {
    PHP 
    SEP #$20
    STY $DAS0L
    LDA #$08              ; DMA mode $08: fixed-source byte fill
    STA $DMAP0
    LDA #$80              ; B-bus $80 = WRAM data port ($2180)
    STA $BBAD0
    LDA #$^math_lookup_tables.sine_table_8bit ; Source: first byte of math_lookup_tables.sine_table_8bit, sin(0) = $00 (not slope_curve_table)
    STA $A1B0
    LDX #$&math_lookup_tables.sine_table_8bit
    STX $A1T0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Boot only (SystemInit). Walks PpuRegisterInitTable: 3-byte entries [register address word, value byte] until a negative address, writing each value with STA $0000,Y (DBR = $81). It covers only the registers listed in the table (not every PPU register); the last entry, MEMSEL = 0, turns FastROM timing off again.

InitHardwareRegisters {
    PHP 
    LDX #$0000

  loc_029F35:
    REP #$20              ; Read 16-bit register address from PPU init table
    LDA $@PpuRegisterInitTable, X ; Table entry address word; a negative value ends the table
    BMI loc_029F4C        ; Negative address = end-of-table sentinel
    TAY 
    SEP #$20
    LDA $@PpuRegisterInitTable+2, X ; Load 8-bit initialization value to hardware register
    STA $0000, Y
    INX 
    INX 
    INX 
    BRA loc_029F35

  loc_029F4C:
    PLP 
    RTL 
}

---------------------------------------------
; ROM table of 4 three-byte entries (slot index 0, 1, 2, 3, then two zero bytes). Its only reader is scene_script.RestoreCachedVram, which takes the slot index, converts it to a WRAM source address $4000 + slot x $2000 (the 4-slot VRAM cache ring) and DMAs it back to VRAM; X selects the entry (3 bytes per entry).

CacheSlotIndices #000000010000020000030000

---------------------------------------------
; 76 register writes of [address word, value byte] terminated by a negative address. Order: MDMAEN, HDMAEN, then the PPU registers $2100-$2133 in address order (write-twice registers appear twice), then NMITIMEN, WRIO, the multiply/divide inputs, H/V timers and finally MEMSEL = 0. Selected values: INIDISP $80, OBJSEL $02, BGMODE $09, BG1SC $11, BG2SC $19, BG3SC $78, BG12NBA $22, BG34NBA $06, VMAIN $80, M7SEL $80, windows $33 / WH1 $FF, TM $04, CGWSEL $82, COLDATA $E0, NMITIMEN 0, WRIO $FF.

PpuRegisterInitTable [
  register-init < $MDMAEN, #00 >   ;00
  register-init < $HDMAEN, #00 >   ;01
  register-init < $INIDISP, #80 >   ;02
  register-init < $OBJSEL, #02 >   ;03
  register-init < $OAMADDL, #00 >   ;04
  register-init < $OAMADDH, #00 >   ;05
  register-init < $BGMODE, #09 >   ;06
  register-init < $MOSAIC, #00 >   ;07
  register-init < $BG1SC, #11 >   ;08
  register-init < $BG2SC, #19 >   ;09
  register-init < $BG3SC, #78 >   ;0A
  register-init < $BG4SC, #00 >   ;0B
  register-init < $BG12NBA, #22 >   ;0C
  register-init < $BG34NBA, #06 >   ;0D
  register-init < $BG1HOFS, #00 >   ;0E
  register-init < $BG1HOFS, #00 >   ;0F
  register-init < $BG1VOFS, #00 >   ;10
  register-init < $BG1VOFS, #00 >   ;11
  register-init < $BG2HOFS, #00 >   ;12
  register-init < $BG2HOFS, #00 >   ;13
  register-init < $BG2VOFS, #00 >   ;14
  register-init < $BG2VOFS, #00 >   ;15
  register-init < $BG3HOFS, #00 >   ;16
  register-init < $BG3HOFS, #00 >   ;17
  register-init < $BG3VOFS, #00 >   ;18
  register-init < $BG3VOFS, #00 >   ;19
  register-init < $BG4HOFS, #00 >   ;1A
  register-init < $BG4HOFS, #00 >   ;1B
  register-init < $BG4VOFS, #00 >   ;1C
  register-init < $BG4VOFS, #00 >   ;1D
  register-init < $VMAIN, #80 >   ;1E
  register-init < $VMADDL, #00 >   ;1F
  register-init < $VMADDH, #00 >   ;20
  register-init < $M7SEL, #80 >   ;21
  register-init < $M7A, #01 >   ;22
  register-init < $M7A, #00 >   ;23
  register-init < $M7B, #00 >   ;24
  register-init < $M7B, #00 >   ;25
  register-init < $M7C, #00 >   ;26
  register-init < $M7C, #00 >   ;27
  register-init < $M7D, #00 >   ;28
  register-init < $M7D, #00 >   ;29
  register-init < $M7X, #00 >   ;2A
  register-init < $M7X, #00 >   ;2B
  register-init < $M7Y, #00 >   ;2C
  register-init < $M7Y, #00 >   ;2D
  register-init < $CGADD, #00 >   ;2E
  register-init < $W12SEL, #33 >   ;2F
  register-init < $W34SEL, #33 >   ;30
  register-init < $WOBJSEL, #33 >   ;31
  register-init < $WH0, #00 >   ;32
  register-init < $WH1, #FF >   ;33
  register-init < $WH2, #00 >   ;34
  register-init < $WH3, #00 >   ;35
  register-init < $WBGLOG, #00 >   ;36
  register-init < $WOBJLOG, #00 >   ;37
  register-init < $TM, #04 >   ;38
  register-init < $TS, #00 >   ;39
  register-init < $TMW, #00 >   ;3A
  register-init < $TSW, #00 >   ;3B
  register-init < $CGWSEL, #82 >   ;3C
  register-init < $CGADSUB, #00 >   ;3D
  register-init < $COLDATA, #E0 >   ;3E
  register-init < $SETINI, #00 >   ;3F
  register-init < $NMITIMEN, #00 >   ;40
  register-init < $WRIO, #FF >   ;41
  register-init < $WRMPYA, #00 >   ;42
  register-init < $WRMPYB, #00 >   ;43
  register-init < $WRDIVL, #00 >   ;44
  register-init < $WRDIVH, #00 >   ;45
  register-init < $WRDIVB, #00 >   ;46
  register-init < $HTIMEL, #00 >   ;47
  register-init < $HTIMEH, #00 >   ;48
  register-init < $VTIMEL, #00 >   ;49
  register-init < $VTIMEH, #00 >   ;4A
  register-init < $MEMSEL, #00 >   ;4B
]