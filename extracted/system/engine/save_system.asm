; SRAM save/load system — game-state persistence with dual-checksum validation (252182–252392, Bank 03).
; 
; Provides the save slot infrastructure. Four save slots are supported, each occupying 512 bytes of SRAM at $306200 + (slot × 512): 508 bytes of data followed by two checksum words at +$1FC and +$1FE.
; 
; === SAVE/LOAD ===
; 
; SaveGameState_Scene copies 508 bytes of WRAM ($0A00–$0BFB) to SRAM after storing the current scene ID at $0B06. LoadGameState_Scene reverses the process after verifying integrity. Both routines mask the slot number to 0–3 and compute the SRAM offset via XBA + ASL (slot × 256 × 2 = slot × 512).
; 
; The saved range is named eventFlags ($0A00) but holds more than event flags: it also contains the player stats and inventory state the engine keeps in that page (e.g. abilityBitmask $0AA2, playerMaxHp $0ACA, playerHp $0ACE, gemCount $0AD6) and the hieroglyph plate slots ($0B28–$0B32).
; 
; === INTEGRITY VERIFICATION ===
; 
; ComputeSaveChecksum generates two checksums over each slot's 508 bytes (254 words):
; - Additive checksum ($0018): running sum of all data words
; - XOR checksum ($001C): running XOR of all data words
; 
; Both are seeded with the constant $3652, so a zeroed slot computes $3652/$3652 and never matches the stored zeros. Both are order-independent, so swapped words go undetected; the pair mainly guards against corrupted or missing data.
; 
; === SLOT MANAGEMENT ===
; 
; ClearSaveSlot fills an entire 512-byte slot with zeros, erasing both the data and the stored checksums, so LoadGameState_Scene fails the checksum compare (carry set).
; 
; Load returns carry CLEAR on success, carry SET on failure (corrupt or empty). ClearSaveSlot returns carry SET to match the empty-slot convention.
---------------------------------------------

?BANK 03

!sceneCurrent                   0644
!eventFlags                     0A00

---------------------------------------------

; Save current game state (WRAM $0A00–$0BFB plus the scene ID) to an SRAM save slot.
; 
; Slot number passed in A (masked to 0–3). Computes the SRAM offset as (slot & 3) × 512 via XBA + ASL.
; 
; First stores the current scene number (sceneCurrent → $0B06) so it is part of the saved data. Then copies 508 bytes ($01FC) from $0A00 to SRAM at $306200 + offset.
; 
; Calls ComputeSaveChecksum and stores the additive checksum at $3063FC and the XOR checksum at $3063FE (+ slot offset). Both are verified on load.

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
; Two running accumulators, both seeded with $3652 (non-zero, so a zeroed slot does not match its stored zero checksums):
; - $0018: additive checksum — sum of all data words
; - $001C: XOR checksum — running XOR of all data words
; 
; Both are order-independent, so swapping two words is not detected. Uses DP $0018, $001C and $000E as scratch.

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