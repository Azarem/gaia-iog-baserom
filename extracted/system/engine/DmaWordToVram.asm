; DMA word transfer to VRAM — single-routine utility (164770–164795, Bank 02).
; 
; Configures DMA channel 0 for a word-size (16-bit) transfer to VRAM register $2118/$2119. Input: X = source address (low 16 bits), A = source bank byte, Y = transfer size in bytes. Sets DMAP0 to mode $01 (word transfer, auto-increment), B-bus target $18 (VDATA), then fires DMA channel 0 via MDMAEN. Caller must set VMADDL ($2116) to the target VRAM address before calling.
---------------------------------------------

?BANK 02

!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305

---------------------------------------------

; DMA channel 0 word transfer to VRAM.
; 
; Input: X = source address (16-bit), A = source bank byte, Y = transfer byte count.
; Configures: DMAP0 = $01 (word transfer mode, 2-register write to $2118/$2119), BBAD0 = $18 (VDATA port).
; Fires DMA via MDMAEN bit 0.
; Caller must pre-set VMADDL ($2116) to the target VRAM word address, and VMAIN ($2115) must already be configured (this routine does not touch it).
; Register width on entry: A 8-bit (bank byte, `LDA #$01` immediates), X/Y 16-bit. Callers: LoadPlayerGraphics (scene_lifecycle) and the inventory overlay.

DmaWordToVram {
    STX $A1T0L            ; Source offset = X (A1T0L/A1T0H)
    STA $A1B0             ; Source bank = A
    STY $DAS0L            ; Transfer byte count = Y
    LDA #$01
    STA $DMAP0            ; DMAP0=$01: A-bus -> B-bus, A-bus address increments, two registers per unit ($2118 then $2119)
    LDA #$18
    STA $BBAD0            ; BBAD0=$18: B-bus base = VMDATAL ($2118)
    LDA #$01
    STA $MDMAEN           ; Start channel 0 now (CPU halts until the transfer finishes)
    RTL 
}