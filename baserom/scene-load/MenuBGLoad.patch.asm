; ==============================================================================
; Scene char-tile load (opcode $17) - uncompressed menu/BG CHR
; ==============================================================================
; What it does: After reading the compressed-data pointer, treats $0000 or a
;   negative size word as uncompressed ROM data (skip QuintetLzDecompress) before
;   the existing VRAM targeting logic in SceneCmd_LoadCharTiles continues.
; Vanilla behavior: Only a null pointer ($0000) skipped LZ; any other non-zero size
;   header triggered QuintetLzDecompress to $7E:7000.
; Hooks (overrides): scene_script.SceneCmd_LoadCharTiles (pointer/size gate),
;   loc_028C81 (uncompressed entry aligns stream pointer).
; Depends on: ?INCLUDE scene_script; LoadScriptPointer, Multiply8x8Unsigned,
;   QuintetLzDecompress, downstream loc_028C87 VRAM DMA path (vanilla).
; State: gfxLayerFlags $066A from script; transfer size $0666; source $3E/$40;
;   decompress dest $7E:7000 when compression is used.
; Hazards/notes: Bank $02; handler saves P via PHP at entry (vanilla).
; ==============================================================================
?BANK 02

?INCLUDE 'scene_script'

!SPTR		$3E

-----------------------------------------------------

scene_script.SceneCmd_LoadCharTiles! {
    PHP 
    JSR $&ReadScriptByte
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    REP #$20
    LDA [$3E]
    STA $00
    INC $3E
    INC $3E
    LDA [$3E]
    XBA 
    ORA $00
    INC $3E
    INC $3E
    SEP #$20
    JSL $@Multiply8x8Unsigned
    REP #$20
    STA $00
    XBA 
    ASL 
    ASL 
    ASL 
    STA $0666
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028C81
    BMI loc_028C81
    STA $78
    SEP #$20
    LDX #$7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$7E
    STA $40
    BRA loc_028C87
}

scene_script.loc_028C81! {
    SEP #$20
}
