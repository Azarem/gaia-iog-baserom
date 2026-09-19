; SRAM save/load system — event flag persistence with dual-checksum validation (252182–252392, Bank 03).
; 
; Provides the complete save slot infrastructure for IOG’s game state persistence. Four save slots are supported, each occupying 512 bytes of SRAM at $306200 + (slot × 512).
; 
; === SAVE/LOAD ===
; 
; SaveGameState_Scene copies 508 bytes of event flags ($0A00–$0BFC) to SRAM after storing the current scene ID at $0B06. LoadGameState_Scene reverses the process, restoring event flags from SRAM after verifying data integrity. Both routines mask the slot number to 0–3 and compute the SRAM offset via XBA + ASL (slot × 256 × 2 = slot × 512).
; 
; === INTEGRITY VERIFICATION ===
; 
; ComputeSaveChecksum generates two independent checksums over each slot’s 508 bytes (254 words):
; - Additive checksum ($0018): running sum of all data words
; - XOR checksum ($001C): running XOR of all data words
; 
; Both are seeded with the magic constant $3652, which prevents blank (all-zero) SRAM from accidentally passing validation. The dual-checksum approach catches both stuck bits (detected by XOR) and value-preserving transpositions (detected by sum).
; 
; === SLOT MANAGEMENT ===
; 
; ClearSaveSlot fills an entire 512-byte slot with zeros, erasing both the event flag data and stored checksums. This makes the slot appear empty to LoadGameState_Scene (checksum mismatch → carry set → load failure).
; 
; Load returns carry CLEAR on success, carry SET on failure (corrupt or empty). ClearSaveSlot returns carry SET to match the empty-slot convention.
---------------------------------------------

?BANK 03

!sceneCurrent                   0644
!eventFlags                     0A00

---------------------------------------------

; Save current game state (event flags + scene ID) to an SRAM save slot.
; 
; Slot number passed in A (masked to 0–3). Computes SRAM offset as (slot & 3) × 512 via XBA + ASL.
; 
; First stores the current scene number ($sceneCurrent → $0B06) so it's included in the saved data. Then copies 508 bytes ($01FC) of event flags from $0A00 to SRAM at $306200 + offset.
; 
; Calls ComputeSaveChecksum to generate dual checksums over the saved data, and stores them at $3063FC and $3063FE for the slot. The checksums are verified on load to detect SRAM corruption.

SaveGameState_Scene {
    PHP 
    PHX 
    PHY 
    PHB 
    REP #$20              ; 16-bit A for SRAM word operations
    AND #$0003            ; Mask slot to 0–3, XBA+ASL → slot × 512 offset
    XBA 
    ASL 
    TAX 
    LDA $sceneCurrent     ; Load sceneCurrent to $0B06 as part of save data
    STA $0B06
    LDY #$0000
    PHX 

  loc_03D92C:
    LDA $eventFlags, Y    ; Copy loop: eventFlags $0A00,Y → SRAM $306200,X
    STA $306200, X
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC            ; 508 bytes ($01FC) of event flags per slot
    BNE loc_03D92C
    PLX 
    JSL $@ComputeSaveChecksum ; Compute dual checksums over saved data
    LDA $0018
    STA $3063FC, X        ; Store additive checksum → $3063FC, XOR → $3063FE
    LDA $001C
    STA $3063FE, X
    PLB 
    PLY 
    PLX 
    PLP 
    RTL 
}

---------------------------------------------
; Load game state from an SRAM save slot, verifying data integrity first.
; 
; Slot number passed in A (masked to 0–3). Computes SRAM offset the same way as SaveGameState_Scene.
; 
; Calls ComputeSaveChecksum to recompute checksums over the SRAM data. Compares both the additive ($0018) and XOR ($001C) checksums against the stored values at $3063FC/$3063FE. If either mismatches, returns with carry SET (load failure — corrupted or empty slot).
; 
; On valid checksum: copies 508 bytes from SRAM $306200+offset back to event flags at $0A00. Returns with carry CLEAR (success).

LoadGameState_Scene {
    PHP 
    PHX 
    PHB 
    REP #$20              ; 16-bit A for checksum comparison
    AND #$0003            ; Mask slot to 0–3, compute SRAM offset
    XBA 
    ASL 
    TAX 
    JSL $@ComputeSaveChecksum ; Recompute checksums for validation
    LDA $0018
    CMP $3063FC, X        ; Compare additive checksum vs stored $3063FC
    BNE loc_03D98F        ; Mismatch → load failure (carry set)
    LDA $001C
    CMP $3063FE, X        ; Compare XOR checksum vs stored $3063FE
    BNE loc_03D98F
    LDY #$0000
    PHX 

  loc_03D979:
    LDA $306200, X        ; Copy loop: SRAM $306200,X → eventFlags $0A00,Y
    STA $eventFlags, Y
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC            ; 508 bytes ($01FC) restored
    BNE loc_03D979
    PLX 
    PLB 
    PLX 
    PLP 
    CLC                   ; Carry clear = success
    RTL 

  loc_03D98F:
    PLB 
    PLX 
    PLP 
    SEC                   ; Carry set = failure (corrupt/empty slot)
    RTL 
}

---------------------------------------------
; Zero an entire SRAM save slot.
; 
; Slot number in A (masked to 0–3). Fills $0100 words (512 bytes) at $306200 + slot offset with zero. This erases both the event flag data and the checksums, making the slot appear empty to LoadGameState_Scene.
; 
; Returns with carry set (convention — matches the load failure return).

ClearSaveSlot {
    PHP 
    PHX 
    PHB 
    REP #$20              ; 16-bit A, mask slot 0–3, compute offset
    AND #$0003
    XBA 
    ASL 
    TAX 
    LDY #$0000
    PHX 
    LDA #$0000            ; A=0 — zero-fill SRAM slot

  loc_03D9A6:
    STA $306200, X        ; Zero loop: $306200,X for $0100 words (512 bytes)
    INX 
    INX 
    INY 
    CPY #$0100
    BNE loc_03D9A6
    PLX 
    PLB 
    PLX 
    PLP 
    SEC                   ; Return with carry set (empty slot convention)
    RTL 
}

---------------------------------------------
; Compute dual checksums over SRAM save data for integrity verification.
; 
; Operates on $00FE words (254 entries = 508 bytes) starting at $306200,X where X is the pre-computed slot offset.
; 
; Two running accumulators, both seeded with $3652 (a non-zero constant to distinguish valid saves from blank SRAM):
; - $0018: Additive checksum — sum of all data words
; - $001C: XOR checksum — running XOR of all data words
; 
; The dual-checksum approach catches both stuck bits (XOR) and value-preserving transpositions (sum). The $3652 seed ensures a fully-zeroed slot doesn't accidentally pass validation.

ComputeSaveChecksum {
    PHP 
    PHX 
    REP #$20
    LDA #$3652            ; Seed both checksums with magic $3652
    STA $0018
    STA $001C
    LDA #$00FE
    STA $000E             ; $00FE words (508 bytes) to hash

  loc_03D9CB:
    LDA $306200, X        ; Hash loop: load word from SRAM $306200,X
    PHA 
    CLC 
    ADC $0018             ; Additive: $0018 += word
    STA $0018
    PLA 
    EOR $001C             ; XOR: $001C ^= word
    STA $001C
    INX 
    INX 
    DEC $000E
    BNE loc_03D9CB
    PLX 
    PLP 
    RTL 
}