
; ==============================================================================
; Dialog string renderer - extended accent glyph table
; ==============================================================================
; What it does: Bytes $E0-$FF map through accent_table to font tile pairs in
;   the VRAM dialog buffer instead of passing through as raw tile indices.
; Vanilla behavior: $E0+ treated like ordinary characters in loc_03E27C path.
; Hooks (overrides): DialogStringRenderer entry, CharLoop, loc_03E27C; adds
;   do_accent_table branch and accent_table data in bank 03.
; Depends on: chunk_03BAE1, DialogStringCommandTable for $C0-$DF commands.
; State: $0998 VRAM write index, $0986/$0987 palette attrs, $7F0200/$7F0240 rows.
; Hazards/notes: CharLoop RTS dispatch unchanged for $C0-$DF; accent uses SEP ORA.
; ==============================================================================

-------------------------------------------
?INCLUDE 'chunk_03BAE1'
-------------------------------------------

DialogStringRenderer.DialogStringRenderer! {
    PHP 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDX $0998

  DialogStringRenderer.DialogString_CharLoop!:
    SEP #$20
    LDA $0000, Y
    CMP #$E0
    BCS do_accent_table
    CMP #$C0
    BCC loc_03E27C
    REP #$20
    INY 
    PEA $&DialogString_CharLoop-1
    AND #$001F
    ASL 
    PHX 
    TAX 
    LDA $@DialogStringCommandTable, X
    PLX 
    DEC 
    PHA 
    RTS 
}

DialogStringRenderer.loc_03E27C! {
    REP #$20
    AND #$00FF
    INY 
    STA $00
    ORA $0986
    ORA #$2100
    LDX $0998
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
  character_print_stub:
    INX 
    INX 
    STX $0998
    LDA $0654
    BEQ DialogString_CharLoop
    LDA $00
    PHA 
    LDA #$0001
    TSB $09EC
    JSR $&WaitNFrames_PerChar
    PLA 
    CMP #$00AC
    BEQ DialogString_CharLoop
    LDA $06F8
    AND #$FF00
    ORA $0996
    STA $06F8
    BRA DialogString_CharLoop
}

do_accent_table {
    INY
    REP #$20
    AND #$001F
    ASL
    TAX
    LDA $@accent_table, X
    SEP #$20
    LDX $0998
    STA $7F0200, X
    LDA #$21
    ORA $0987
    STA $7F0201, X
    STA $7F0241, X
    XBA
    STA $7F0240, X
    REP #$20
    BRA character_print_stub
}

accent_table [
    #E090
    #E190
    #E290
    #E390
    #E450
    #E550

    #E694
    #E794
    #E894
    #E950

    #82EA
    
    #EB5E
    #EC54
    #ED54
    #EE58
    #EF75
    
    #F098
    #F198
    #F298
    #F3BC
    
    #F49E
    #F59E
    #F69E
    #F79E
    #F8BC
    
    #F9B5
    #FAB5
    #FBB5
    
    #FC5E
    #FD5E
    #42FE
    #FF50
]
