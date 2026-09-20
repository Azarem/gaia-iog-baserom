?BANK 00

?INCLUDE 'QuintetLzDecompress'
?INCLUDE 'sprite_composition'

!animScratch                    7F0000
!extendedFlags                  7F002A
!adhocVramDma                   7F0C03

---------------------------------------------

; COP #4F with staged operands on first use: reads source word, byte, dest word, and size word into adhocVramDma staging and sets extendedFlags bit 0, then yields RTL. Later calls while bit 0 is set poll completion against the staged size; clears bit 0 and RTI to resume when done.

AdhocVramDma {
    TYX 
    LDA $extendedFlags, X ; Check extendedFlags bit 0 (adhoc VRAM DMA already staged)
    BIT #$0001
    BNE loc_00990E
    LDA $7F0C07           ; Check if DMA staging area is clear ($7F0C07 = 0)
    BEQ loc_0098D1        ; Check if DMA staging area clear ($7F0C07)
    LDA $0A               ; DMA busy: rewind and yield RTL
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D1:
    LDA $0A               ; First call: rewind PC and stage all DMA operands
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read source address word into adhocVramDma ($7F0C03)
    INC $0A
    INC $0A
    STA $adhocVramDma
    LDA [$0A]             ; Read source bank byte into $7F0C05
    INC $0A
    AND #$00FF
    STA $7F0C05
    LDA [$0A]             ; Read VRAM destination word into $7F0C07
    INC $0A
    INC $0A
    STA $7F0C07
    LDA [$0A]             ; Read transfer size word into $7F0C09
    INC $0A
    INC $0A
    STA $7F0C09
    LDA $extendedFlags, X
    ORA #$0001            ; Set extendedFlags bit 0 (DMA pending)
    STA $extendedFlags, X
    PLA 
    PLA 
    RTL 

  loc_00990E:
    LDY #$0003            ; Polling path: compare current VRAM dest against staged dest
    LDA [$0A], Y          ; Polling: compare current VRAM dest vs staged
    CMP $7F0C07           ; If staged and current match → DMA still pending, yield
    BNE loc_00991C
    PLA 
    PLA 
    RTL 

  loc_00991C:
    LDA $extendedFlags, X ; DMA complete: clear bit 0 and skip 7-byte operand block
    AND #$FFFE            ; DMA complete: clear bit 0, skip 7-byte operand block
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0007
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #50 with five operands: word source base, byte bank, byte source palette index, byte dest palette index, byte count. Copies palette entries through the $0402 DMA helper into CGRAM staging (indices scaled ×2, dest base $0A00).

CopyPalette {
    PHY 
    LDA [$0A]             ; Read palette source base address (word)
    INC $0A
    INC $0A
    PHA 
    LDA [$0A]             ; Read palette source bank byte
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0405             ; Store bank byte to DMA helper register $0405
    REP #$20
    LDA [$0A]             ; Read source palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for word-sized palette entries
    CLC                   ; Add to source base → X = source palette address
    ADC $01, S            ; Palette copy: source index ×2 into CGRAM staging buffer
    TAX 
    PLA 
    LDA [$0A]             ; Read destination palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for CGRAM word entries
    CLC 
    ADC #$0A00            ; Add $0A00 (CGRAM staging base) → Y = dest address
    TAY 
    SEP #$20
    LDA #$7F              ; Set source bank to $7F (animScratch region)
    STA $0404
    REP #$20
    LDA [$0A]             ; Read palette entry count
    INC $0A
    AND #$00FF
    ASL                   ; Count ×2 for word-sized entries, DEC for loop counter
    DEC 
    JSR $0402             ; Call DMA helper at $0402 to copy palette data
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #51 with word source pointer, byte source bank, and word VRAM destination. Calls QuintetLzDecompress then ClearActorRenderList before resuming the script.

Decompress {
    PHY 
    PHD 
    LDA [$0A]             ; Decompress: read LZ source pointer word
    INC $0A
    INC $0A
    STA $003E             ; Store source address at DP $3E for QuintetLzDecompress
    LDA [$0A]             ; Read source bank byte
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0040             ; Store source bank at DP $40
    REP #$20
    LDA [$0A]             ; Read VRAM destination word
    INC $0A
    INC $0A
    STA $007A             ; Store VRAM dest at DP $7A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA #$0000
    TCD                   ; Zero DP for decompression workspace
    LDA [$3E]             ; Read compressed data length word from source stream
    STA $78
    INC $3E
    INC $3E
    JSL $@QuintetLzDecompress ; Decompress Quintet LZ data to VRAM staging
    JSL $@sprite_composition.ClearActorRenderList ; Clear actor render list after graphics rewrite
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #54 with one word plus one byte operand. Stores the far pointer in animScratch ($7F0000 word, $7F0002 bank) for later use by handler or callback code.

SetScratchPointer {
    TYX 
    LDA [$0A]             ; Read far pointer word for animScratch
    INC $0A
    INC $0A
    STA $animScratch, X   ; Store pointer to animScratch ($7F0000+X)
    LDA [$0A]             ; Read bank byte for far pointer
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bank to animScratch+2 ($7F0002+X)
    LDA $0A
    STA $02, S
    RTI 
}