; ==============================================================================
; Scene layer map load (opcode $06) - uncompressed tilemap and raw tile paths
; ==============================================================================
; What it does: When loading scene layer maps, treats a 2-byte size of $0001 as
;   "uncompressed geometry" (skip Quintet LZ) and DMAs raw map bytes; also allows
;   a null compressed tileset pointer to DMA ROM tile CHR without decompressing.
; Vanilla behavior: Zero size ($0000) entered HandleEmptyGeometry; non-zero sizes
;   always went through QuintetLzDecompress in StoreMapAndDecompress / DmaLowVramTileset.
; Hooks (overrides): scene_script.loc_02883D (map size gate and layer decompress path),
;   WriteMapBounds (empty-geometry DMA setup), DmaLowVramTileset (tile-only VRAM upload).
; Depends on: ?INCLUDE scene_script; StoreMapAndDecompress, DmaRomToWram,
;   Multiply8x8Unsigned, QuintetLzDecompress (unchanged call sites).
; State: Reads gfxLayerFlags $066A, script source pointer $3E/$40; writes map bounds
;   $0692/$0696, meta sizes $0666/$0668/$069A, decompress size $78, WRAM $7E:A000/C000.
; Hazards/notes: Bank $02; 16-bit A in overridden entry paths; preserve layer bit tests
;   ($01 layer 0, $02 layer 1) matching vanilla routing.
; ==============================================================================
?BANK 02

?INCLUDE 'scene_script'

!sptr		                    3E
!DCMP_SIZE	                    78
!META_SIZE                      0666
!DST_OFF                        0668
!map_bounds_x                   0692
!map_bounds_y                   0696
!A1T0L                          4302
!A1B0                           4304

---------------------------------------------

scene_script.loc_02883D! {
    REP #$20
    
    LDA [$sptr]
    INC $sptr
    INC $sptr
    CMP #$0001
    BMI HandleEmptyGeometry
    STA $DCMP_SIZE
    STA $META_SIZE

    SEP #$20
    LDA $066A
    BIT #$01
    BEQ loc_02888E
    LDX #$0000
    JSR $&StoreMapAndDecompress
    LDA $066A
    BIT #$02
    BEQ loc_028894
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram
    LDA $01
    STA $0695
    XBA 
    LDA $03
    STA $0699
    JSL $@Multiply8x8Unsigned
    STA $069D
    BRA loc_028894
}

---------------------------------------------

scene_script.WriteMapBounds! {
    REP #$20
    LDA $00
    STA $map_bounds_x, X    -- copy stored width
    LDA $02
    STA $map_bounds_y, X    -- copy stored height
    LDA $META_SIZE
    STA $069A, X            -- copy stored multiply result (used by 0 index)
    STZ $DST_OFF             -- zero dest offset

    JSR $&DmaRomToWram
    SEP #$20
    RTS
}

---------------------------------------------

scene_script.DmaLowVramTileset! {
    REP #$20
    LDA [$sptr]
    INC $sptr
    INC $sptr
    CMP #$0000
    BMI do_copy
    BNE do_copy
    STA $DCMP_SIZE
    BRA loc_028943
    
  do_copy:
    SEP #$20
    LDX $sptr
    STX $A1T0L
    LDA $40
    STA $A1B0
    BRA loc_028959
}
