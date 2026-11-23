; GaiaLabs Retranslation border art and lookup. BOR takes one byte before
; the box-opening command. FIN retains the frame; teardown restores style 0.
?BANK 03
?INCLUDE 'DialogStringRenderer'
!border_state 09F8
border_lookup [
    &DialogueBorderTiles
    &border_index_1
    &border_index_2
    &border_index_3
    &border_index_4
    &border_index_5
    &border_index_6
    &border_index_7
    &border_index_8
    &border_index_9
    &border_index_A
    &border_index_B
    &border_index_C
    &border_index_D
]

border_index_1 #1320142013601520156013A014A013E0
border_index_2 #1620172016601820186016A017A016E0
border_index_3 #19201A2019601B201B6019A01AA019E0
border_index_4 #A320A420A360A520A560A3A0A4A0A3E0
border_index_5 #A620A720A6601C201C60A6A0A7A0A6E0
border_index_6 #A020A120A060A220A260A0A0A1A0A0E0
border_index_7 #B020B120B060B220B260B0A0B1A0B0E0
border_index_8 #B320B420B360B520B560B3A0B4A0B3E0
border_index_9 #B620B720B660B820B860B6A0B7A0B6E0
border_index_A #B920BA20B960BB20BB60B9A0BAA0B9E0
border_index_B #A920AA20A960AB20AB60A9A0AAA0A9E0
border_index_C #C920CA20C960CB20CB60C9A0CAA0C9E0
border_index_D #C620C720C660C820C860C6A0C7A0C6E0


DialogStringRenderer.DialogStringCommandTable+= [
    &SetDialogueBorder
]

SetDialogueBorder {
    LDA $0000, Y
    INY
    AND #$00FF
    CMP #$000E
    BCC store_dialogue_border
    LDA #$0000
  store_dialogue_border:
    STA $border_state
    RTS
}

DialogStringRenderer.DialogCmd_ClearDialogueBox-= {
    JSL $@RestoreDialogueBorderPalette
}

RestoreDialogueBorderPalette {
    ; Native teardown restores the glyph colors. The themed frames also
    ; change entries 1-3 of the standard dialogue palette (fx_palette_198040).
    LDA $border_state
    BEQ cape_palette_restored
    LDA #$7FFF
    STA $7F0A02
    LDA #$7A94
    STA $7F0A04
    LDA #$0000
    STA $7F0A06
    STZ $border_state
  cape_palette_restored:
    RTL
}

DialogStringRenderer.OpenDialogueBox_Body! {
    PHY 
    PHX 
    LDA $0B04             ; Restore text speed from saved frame delay ($0B04 → $007E)
    STA $007E
    LDA #$0010            ; Default per-character SFX = $10 (typing click)
    STA $0996
    STZ $00DC             ; Clear $00DC (no reader found; purpose unproven) and reset the line counter ($099C)
    STZ $099C
    LDA $097A             ; Load column/row origins: $097A→$097E, $097C→$0980
    STA $097E
    LDA $097C
    STA $0980
    XBA                   ; Compute box content origin: row×32 + column×2 → $099A
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    STA $099A
    STZ $0986
    LDA $border_state
    ASL
    TAX
    LDA $@border_lookup, X
    STA $3E
    LDA #$*border_lookup
    STA $40
    LDA $0982             ; Width and height doubled: 2 tiles per column, 2 tile rows per text row
    ASL 
    STA $18
    PHA 
    LDA $0984
    ASL 
    STA $1C
    LDA $0998             ; Position at border top-left: cursor − 2 bytes (1 col) − $40 (1 row)
    DEC 
    DEC 
    SEC 
    SBC #$0040
    STA $00
    TAX 
    JSR $&DrawDialogueBorderRow ; Draw: top border → body rows with side borders → bottom border
    PLX 
    PHX 
    STX $18
    JSR $&DrawDialogueBodyRows
    PLY 
    STY $18
    JSR $&DrawDialogueBorderRow
    LDA #$0001
    TSB $displayModeFlags
    LDA $sceneCurrent     ; Skip WaitOneFrame on scene $FA (diary menu)
    AND #$00FF
    CMP #$00FA
    BEQ loc_03E4CB
    JSR $&WaitOneFrame
}

