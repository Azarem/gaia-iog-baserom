; Graphics-loading COP handlers (Bank $00): AdhocVramDma (#4F), CopyPalette (#50), Decompress (#51) and SetScratchPointer (#54).
; 
; AdhocVramDma stages a one-shot VRAM transfer in the adhoc DMA block ($7F0C03 source word, then adhocVramDmaBank, adhocVramDmaDest, adhocVramDmaSize) and waits for the NMI (DmaAdhocVramBlock) to run it and zero the destination word. It yields by rewinding the actor entry address ($00) to the COP itself, so every call after the first is a poll; extendedFlags bit 0 marks "staged".
; 
; CopyPalette copies colors into the cgramPalette staging ($7F0A00) with the RAM block-move stub at $0402 (PHB, MVN, PLB, RTS; written by system_init). Decompress runs QuintetLzDecompress from a ROM source into a WRAM output buffer, then clears the actor render list. SetScratchPointer stores a long pointer in animScratch for the actor's own code.
---------------------------------------------

?BANK 00

?INCLUDE 'QuintetLzDecompress'
?INCLUDE 'sprite_composition'

!animScratch                    7F0000
!extendedFlags                  7F002A
!adhocVramDma                   7F0C03
!adhocVramDmaBank               7F0C05
!adhocVramDmaDest               7F0C07
!adhocVramDmaSize               7F0C09

---------------------------------------------

; COP #4F with a long source Address, a VRAM destination word and a size word (7 operand bytes). First call: if the staging block is free (adhocVramDmaDest = 0) it copies the operands into adhocVramDma / adhocVramDmaBank / adhocVramDmaDest / adhocVramDmaSize, sets extendedFlags bit 0 and yields. Later calls (bit 0 set) compare the COP's destination operand with adhocVramDmaDest, which the NMI zeroes when DmaAdhocVramBlock runs; once they differ the transfer is done, bit 0 is cleared and the script resumes after the 7 operand bytes. If the block is busy with another transfer it yields without staging. Every yield rewinds the actor entry address ($00) to this COP so it runs again next frame.
; 
; The destination word is written before the size word, but the NMI fires on a nonzero destination (see OQ-45).

AdhocVramDma {
    TYX 
    LDA $extendedFlags, X ; Check extendedFlags bit 0 (adhoc VRAM DMA already staged)
    BIT #$0001
    BNE loc_00990E
    LDA $adhocVramDmaDest ; adhocVramDmaDest = 0: no transfer pending, safe to stage
    BEQ loc_0098D1        ; Zero: stage the transfer; otherwise busy, fall through to rewind and yield
    LDA $0A               ; Busy: set the actor entry ($00) back to this COP (PC − 2) and yield (PLA PLA RTL)
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D1:
    LDA $0A               ; Stage: rewind the entry address to this COP (PC − 2 → $00) so later calls poll
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Operand 1: source address word → adhocVramDma ($7F0C03)
    INC $0A
    INC $0A
    STA $adhocVramDma
    LDA [$0A]             ; Operand 1: source bank byte → adhocVramDmaBank
    INC $0A
    AND #$00FF
    STA $adhocVramDmaBank
    LDA [$0A]             ; Operand 2: VRAM destination word → adhocVramDmaDest (also the NMI trigger: nonzero = pending)
    INC $0A
    INC $0A
    STA $adhocVramDmaDest
    LDA [$0A]             ; Operand 3: byte count → adhocVramDmaSize (written after the trigger word)
    INC $0A
    INC $0A
    STA $adhocVramDmaSize
    LDA $extendedFlags, X
    ORA #$0001            ; Set extendedFlags bit 0 (DMA pending)
    STA $extendedFlags, X
    PLA 
    PLA 
    RTL 

  loc_00990E:
    LDY #$0003            ; Polling path: Y = 3 = offset of the destination word in the operands
    LDA [$0A], Y          ; Our destination operand
    CMP $adhocVramDmaDest ; Still equal to the staged destination: the NMI has not run the DMA yet, yield
    BNE loc_00991C
    PLA 
    PLA 
    RTL 

  loc_00991C:
    LDA $extendedFlags, X ; DMA complete (the NMI zeroed adhocVramDmaDest)
    AND #$FFFE            ; Clear extendedFlags bit 0 (staged flag)
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0007            ; Resume after the 7 operand bytes
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #50 with a long source Address (word + bank), a byte source color index, a byte destination color index and a byte color count. Copies count colors from source + 2 × srcIndex to cgramPalette ($7F0A00) + 2 × dstIndex with the RAM MVN stub at $0402: source bank → $0405, destination bank $7F → $0404, X = source, Y = destination, A = bytes − 1.

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
    STA $0405             ; Source bank → MVN operand $0405
    REP #$20
    LDA [$0A]             ; Read source palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for word-sized palette entries
    CLC                   ; Add to source base → X = source palette address
    ADC $01, S            ; Add the source base (pushed above) → X = source address
    TAX 
    PLA 
    LDA [$0A]             ; Read destination palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for CGRAM word entries
    CLC 
    ADC #$0A00            ; Add $0A00, the base of cgramPalette ($7F0A00) → Y = destination
    TAY 
    SEP #$20
    LDA #$7F              ; Destination bank $7F (cgramPalette)
    STA $0404             ; MVN destination-bank operand $0404
    REP #$20
    LDA [$0A]             ; Read palette entry count
    INC $0A
    AND #$00FF
    ASL                   ; Count × 2 = bytes; DEC next gives the MVN length − 1
    DEC 
    JSR $0402             ; JSR $0402: RAM stub PHB / MVN / PLB / RTS (X = source, Y = destination, A = length − 1)
    PLX                   ; Restore X = actor slot (pushed as Y)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #51 with a long source Address (word + bank) and a long destination Address. Only the destination word is used: the WRAM output buffer address (bank $7E, e.g. mode7Tilemap or mapLayerTilemap); its bank byte is read and discarded. Stores the source in $3E/$40 and the output address in $7A for QuintetLzDecompress, reads the 2-byte size header (decompressed byte count) into $78, decompresses, then calls ClearActorRenderList before resuming the script.

Decompress {
    PHY 
    PHD 
    LDA [$0A]             ; Read the LZ source pointer word
    INC $0A
    INC $0A
    STA $003E             ; Source address → $3E (read by QuintetLzDecompress)
    LDA [$0A]             ; Read source bank byte
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0040             ; Store source bank at DP $40
    REP #$20
    LDA [$0A]             ; Read the output buffer address word (WRAM, bank $7E)
    INC $0A
    INC $0A
    STA $007A             ; Output buffer address → $7A
    LDA [$0A]             ; Read and discard the destination bank byte (the output bank is always $7E)
    INC $0A
    AND #$00FF
    LDA #$0000
    TCD                   ; Zero DP for decompression workspace
    LDA [$3E]             ; Read the 2-byte size header: decompressed byte count
    STA $78               ; $78 = decompressed size
    INC $3E               ; Skip the header: [$3E] now points at the compressed stream
    INC $3E
    JSL $@QuintetLzDecompress ; Decompress the Quintet LZ stream into the WRAM output buffer
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