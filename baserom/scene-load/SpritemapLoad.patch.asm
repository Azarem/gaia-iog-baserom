; ==============================================================================
; Scene spritemap load (opcode $10) - signed size and uncompressed spm data
; ==============================================================================
; What it does: Reads the 16-bit size word from the script stream indirectly via
;   LoadScriptPointer (skips the 3-byte inline size field vanilla read from
;   [$3A],Y); treats negative size as absolute byte count; skips LZ when the
;   compressed pointer is $0000 or negative.
; Vanilla behavior: Loaded size from [$3A],Y into $0666; only null pointer
;   bypassed QuintetLzDecompress (uncompressed path at loc_028C1B).
; Hooks (overrides): scene_script.SceneCmd_LoadSpriteTiles (full handler body
;   through decompress call; vanilla exit/DMA paths unchanged below patch).
; Depends on: ?INCLUDE scene_script; CheckSourceCacheHit slot $0684,
;   LoadScriptPointer, QuintetLzDecompress, DmaRomToWram (vanilla tail).
; State: gfxSrcEnd $0666; source cache $0684; decompress size $78; staging $7E:4000.
; Hazards/notes: Bank $02; patch truncates before loc_028C19 PLP/RTS (merged with vanilla).
; ==============================================================================
?BANK 02

?INCLUDE 'scene_script'

!SPTR		$3E

-----------------------------------------------------

scene_script.SceneCmd_LoadSpriteTiles! {
    PHP 
    REP #$20
    ;LDA [$3A], Y
    ;STA $0666
    ;SEP #$20
    INY 
    INY 
    INY 
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA [$3E]
    BPL store_size
    
    LDA #$0000
    SEC
    SBC [$3E]

  store_size:
    STA $0666

    LDX #$0684
    JSR $&CheckSourceCacheHit
    BCC loc_028C19
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028C1B
    BMI loc_028C1B
    STA $78
    SEP #$20
    LDX #$4000
    STX $7A
    JSL $@QuintetLzDecompress
}
