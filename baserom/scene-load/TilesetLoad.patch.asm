; ==============================================================================
; Scene metatile-set load (opcode $05) - uncompressed tileset blob
; ==============================================================================
; What it does: When loading metatile sets, treats compressed pointer $0000 or
;   negative as uncompressed ROM data (skip QuintetLzDecompress) before layer
;   DMA and BuildMetatileFlagTable (vanilla code after loc_02878A).
; Vanilla behavior: BEQ loc_02878A skipped LZ only on exact zero pointer; any
;   other value ran QuintetLzDecompress to $7E:7000 first.
; Hooks (overrides): scene_script.loc_028768 (pointer read and decompress gate).
; Depends on: ?INCLUDE scene_script; CheckSourceCacheHit, DmaRomToWram,
;   BuildMetatileFlagTable (downstream vanilla).
; State: gfxLayerFlags $066A; decompress size $78; staging $7E:7000; WRAM $2000/$2800.
; Hazards/notes: Bank $02; patch ends at loc_028768 block close (merged tail).
; ==============================================================================
?BANK 02

?INCLUDE 'scene_script'

!SPTR		$3E
!DCMP_SIZE	$78

-----------------------------------------------------

scene_script.loc_028768! {
    LDA $066A
    BEQ loc_0287BA
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_02878A
    BMI loc_02878A
    LDX #$7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40
}
