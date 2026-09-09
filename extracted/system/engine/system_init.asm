; Hardware and system variable initialization for boot sequence.
; 
; Called during SystemInit to prepare all SNES hardware and game state. Contains:
; - UploadCgramPalette: DMA transfer of 256-color palette buffer from WRAM $7F0A00 to CGRAM, plus backdrop color writes to COLDATA fixed-color registers for color math.
; - UploadOamTable: DMA transfer of 544-byte OAM staging buffer ($0422) to PPU OAM.
; - InitSystemVariables: Zeroes all 128KB of WRAM (skipping the stack at $0100-$01FF), then loads initial values from a constant table into designated WRAM addresses.
; - DmaFixedByteFill: Utility for DMA fixed-source byte fills to WRAM.
; - InitHardwareRegisters: Table-driven initialization of all PPU registers ($2100-$213F) and CPU I/O registers ($4200-$420D).
; 
; Data tables include the system variable initialization constants, PPU register init table, and graphics cache slot indices.
---------------------------------------------

?BANK 02

?INCLUDE 'binary_01C384'
?INCLUDE 'scene_meta'

!OAMADDL                        2102
!CGADD                          2121
!COLDATA                        2132
!WMADDL                         2181
!WMADDH                         2183
!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!backdropColors                 7F0C00

---------------------------------------------

; Transfers the full 256-color palette from WRAM buffer to CGRAM via DMA.
; 
; DMA setup: CGADD=0 (start at palette 0), source=$7F0A00, size=512 bytes, target=CGRAM data register ($2122), mode=single-register increment.
; 
; After the bulk DMA, separately writes the three backdrop color components from $7F0C00-$7F0C02 to the COLDATA fixed-color register ($2132). These control the backdrop/screen color used by the SNES color math hardware for subscreen blending.

UploadCgramPalette {
    PHP 
    SEP #$20
    STZ $CGADD            ; CGADD=0: palette write starts at index 0
    STZ $DMAP0
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
    LDA $backdropColors   ; Write backdrop color components to COLDATA fixed-color registers
    STA $COLDATA
    LDA $7F0C01
    STA $COLDATA
    LDA $7F0C02
    STA $COLDATA
    PLP 
    RTL 
}

---------------------------------------------
; Transfers the 544-byte OAM staging buffer to the PPU's Object Attribute Memory via DMA.
; 
; DMA setup: OAM address=0 (first entry), source=$0422, size=$0220 (544 bytes: 512 main table + 32 high-table bytes), target=OAM data register ($2104), mode=single-register increment.

UploadOamTable {
    PHP 
    LDX #$0000
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
; Zeroes all 128KB of WRAM then loads initial values from a constant table.
; 
; WRAM clear sequence:
; 1. Fill $0100 bytes from $0000 (direct page area)
; 2. Skip $0100-$01FF (stack — must not be zeroed while in use)
; 3. Fill $FF00 bytes from $0200 (first WRAM bank remainder)
; 4. Fill $FF00 bytes (second WRAM bank)
; Total: $1FF00 bytes = 128KB minus 256-byte stack area.
; 
; Then iterates the system_init_constants table, loading each 4-byte entry (destination address + 16-bit value) and storing to WRAM until a negative address sentinel is reached.

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
    LDY #$FF00            ; Fill $FF00 bytes covering $0200 through first WRAM bank
    JSR $&DmaFixedByteFill
    LDY #$FF00            ; Fill remaining $FF00 bytes — clears all 128KB minus stack
    JSR $&DmaFixedByteFill
    LDX #$0000

  loc_029E6F:
    LDA $@SystemInitConstants, X ; Read destination address from init constant table
    BMI loc_029E83        ; Negative address = end-of-table sentinel
    TAY 
    LDA $@SystemInitConstants+2, X ; Store initialization value to WRAM destination
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
; Initialization constant table loaded during system boot.
; 
; Each 4-byte entry: [destination_addr:u16, value:u16]. Terminated by a negative address.
; 
; Sets up critical system variables including: VRAM layout addresses, BG tilemap/charset pointers, DMA channel defaults, actor system base addresses, scene metadata pointer, input configuration, and various engine parameters.

SystemInitConstants [
  wram-init < #$069E, #$A000 >   ;00
  wram-init < #$06A0, #$C000 >   ;01
  wram-init < #$0080, #$C000 >   ;02
  wram-init < #$0082, #$007F >   ;03
  wram-init < #$06BA, #$1000 >   ;04
  wram-init < #$06BC, #$1800 >   ;05
  wram-init < #$06AE, #$2000 >   ;06
  wram-init < #$06B0, #$2800 >   ;07
  wram-init < #$06B2, #$3100 >   ;08
  wram-init < #$06B4, #$3288 >   ;09
  wram-init < #$06B6, #$3184 >   ;0A
  wram-init < #$06B8, #$330C >   ;0B
  wram-init < #$06AA, #$0000 >   ;0C
  wram-init < #$06AC, #$0100 >   ;0D
  wram-init < #$003A, &scene_meta >   ;0E
  wram-init < #$003C, *scene_meta >   ;0F
  wram-init < #$0402, #$548B >   ;10
  wram-init < #$0406, #$60AB >   ;11
  wram-init < #$005E, #$0000 >   ;12
  wram-init < #$0060, #$0081 >   ;13
  wram-init < #$0062, #$0000 >   ;14
  wram-init < #$064A, #$0001 >   ;15
  wram-init < #$0648, #$0404 >   ;16
  wram-init < #$0DA8, #$0020 >   ;17
  wram-init < #$0DA6, #$0010 >   ;18
  wram-init < #$0DAA, #$8000 >   ;19
  wram-init < #$0DAC, #$0080 >   ;1A
  wram-init < #$0DAE, #$4000 >   ;1B
  wram-init < #$0DB0, #$0040 >   ;1C
  wram-init < #$0DB4, #$2000 >   ;1D
  wram-init < #$0DB2, #$1000 >   ;1E
  wram-init < #$0B14, #$003C >   ;1F
  wram-init < #$0AC4, #$FFFF >   ;20
  wram-init < #$0B04, #$0000 >   ;21
]

---------------------------------------------
; DMA utility that fills a WRAM region with a fixed zero byte.
; 
; Uses DMA mode $08 (fixed source address) to repeatedly write a zero byte from ROM to WRAM via the WRAM data port ($2180). The byte count is passed in Y. Called by InitSystemVariables to bulk-clear WRAM during boot.

DmaFixedByteFill {
    PHP 
    SEP #$20
    STY $DAS0L
    LDA #$08              ; DMA mode $08: fixed-source byte fill
    STA $DMAP0
    LDA #$80              ; B-bus $80 = WRAM data port ($2180)
    STA $BBAD0
    LDA #$^binary_01C384.binary_01C455 ; Source: known zero byte in ROM (binary_01C384)
    STA $A1B0
    LDX #$&binary_01C384.binary_01C455
    STX $A1T0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Table-driven initialization of PPU and CPU I/O registers.
; 
; Iterates the ppu_register_init_table, reading 3-byte entries: [register_addr:u16, value:u8]. Writes each value to the corresponding hardware register. Table is terminated by a negative address sentinel.
; 
; Covers all PPU registers ($2100-$2133): display brightness, OBJ settings, BG mode, tilemap/charset addresses, window masks, color math, and screen designation. Also initializes CPU I/O registers ($4200-$420D): NMI/IRQ enables, H/V timer, DMA/HDMA channels.

InitHardwareRegisters {
    PHP 
    LDX #$0000

  loc_029F35:
    REP #$20              ; Read 16-bit register address from PPU init table
    LDA $@PpuRegisterInitTable, X
    BMI loc_029F4C        ; Negative address = end-of-table sentinel
    TAY 
    SEP #$20
    LDA $@PpuRegisterInitTable+2, X ; Write 8-bit initialization value to hardware register
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
; Pre-initialized 4-entry cache slot index array (values: 0, 1, 2, 3). Used by the graphics tile cache system to track VRAM cache slot assignments.

CacheSlotIndices #000000010000020000030000

---------------------------------------------
; Hardware register initialization table for system boot.
; 
; Each 3-byte entry contains: [register_address:u16, value:u8]. Covers:
; - PPU registers $2100-$2133: display mode, BG configuration, window masks, color math, mosaic, scroll initial values
; - CPU I/O registers $4200-$420D: interrupt enables, H/V count targets, DMA channel defaults
; 
; Terminated by a negative address sentinel. Total: 76 entries.

PpuRegisterInitTable [
  register-init < #$420B, #00 >   ;00
  register-init < #$420C, #00 >   ;01
  register-init < #$2100, #80 >   ;02
  register-init < #$2101, #02 >   ;03
  register-init < #$2102, #00 >   ;04
  register-init < #$2103, #00 >   ;05
  register-init < #$2105, #09 >   ;06
  register-init < #$2106, #00 >   ;07
  register-init < #$2107, #11 >   ;08
  register-init < #$2108, #19 >   ;09
  register-init < #$2109, #78 >   ;0A
  register-init < #$210A, #00 >   ;0B
  register-init < #$210B, #22 >   ;0C
  register-init < #$210C, #06 >   ;0D
  register-init < #$210D, #00 >   ;0E
  register-init < #$210D, #00 >   ;0F
  register-init < #$210E, #00 >   ;10
  register-init < #$210E, #00 >   ;11
  register-init < #$210F, #00 >   ;12
  register-init < #$210F, #00 >   ;13
  register-init < #$2110, #00 >   ;14
  register-init < #$2110, #00 >   ;15
  register-init < #$2111, #00 >   ;16
  register-init < #$2111, #00 >   ;17
  register-init < #$2112, #00 >   ;18
  register-init < #$2112, #00 >   ;19
  register-init < #$2113, #00 >   ;1A
  register-init < #$2113, #00 >   ;1B
  register-init < #$2114, #00 >   ;1C
  register-init < #$2114, #00 >   ;1D
  register-init < #$2115, #80 >   ;1E
  register-init < #$2116, #00 >   ;1F
  register-init < #$2117, #00 >   ;20
  register-init < #$211A, #80 >   ;21
  register-init < #$211B, #01 >   ;22
  register-init < #$211B, #00 >   ;23
  register-init < #$211C, #00 >   ;24
  register-init < #$211C, #00 >   ;25
  register-init < #$211D, #00 >   ;26
  register-init < #$211D, #00 >   ;27
  register-init < #$211E, #00 >   ;28
  register-init < #$211E, #00 >   ;29
  register-init < #$211F, #00 >   ;2A
  register-init < #$211F, #00 >   ;2B
  register-init < #$2120, #00 >   ;2C
  register-init < #$2120, #00 >   ;2D
  register-init < #$2121, #00 >   ;2E
  register-init < #$2123, #33 >   ;2F
  register-init < #$2124, #33 >   ;30
  register-init < #$2125, #33 >   ;31
  register-init < #$2126, #00 >   ;32
  register-init < #$2127, #FF >   ;33
  register-init < #$2128, #00 >   ;34
  register-init < #$2129, #00 >   ;35
  register-init < #$212A, #00 >   ;36
  register-init < #$212B, #00 >   ;37
  register-init < #$212C, #04 >   ;38
  register-init < #$212D, #00 >   ;39
  register-init < #$212E, #00 >   ;3A
  register-init < #$212F, #00 >   ;3B
  register-init < #$2130, #82 >   ;3C
  register-init < #$2131, #00 >   ;3D
  register-init < #$2132, #E0 >   ;3E
  register-init < #$2133, #00 >   ;3F
  register-init < #$4200, #00 >   ;40
  register-init < #$4201, #FF >   ;41
  register-init < #$4202, #00 >   ;42
  register-init < #$4203, #00 >   ;43
  register-init < #$4204, #00 >   ;44
  register-init < #$4205, #00 >   ;45
  register-init < #$4206, #00 >   ;46
  register-init < #$4207, #00 >   ;47
  register-init < #$4208, #00 >   ;48
  register-init < #$4209, #00 >   ;49
  register-init < #$420A, #00 >   ;4A
  register-init < #$420D, #00 >   ;4B
]