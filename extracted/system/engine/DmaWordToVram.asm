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
; Caller must pre-set VMADDL ($2116) to the target VRAM word address.

DmaWordToVram {
    STX $A1T0L            ; DmaWordToVram: configure DMA ch0 word transfer (caller sets VMADDL)
    STA $A1B0             ; Source address: A1T0L=X, A1B0=bank in A
    STY $DAS0L            ; Transfer byte count in DAS0L (Y)
    LDA #$01
    STA $DMAP0            ; DMAP0=$01: fixed address, increment after word write
    LDA #$18
    STA $BBAD0            ; BBAD0=$18: B-bus target VDATA ($2118/$2119)
    LDA #$01
    STA $MDMAEN           ; MDMAEN=$01: start channel 0 DMA
    RTL 
}