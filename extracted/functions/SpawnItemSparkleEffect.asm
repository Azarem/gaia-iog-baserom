; Item-effect sparkle actor (Bank 00, 56579-56667). One spawn is a 24-frame effect that draws two small tiles side by side at the actor's position: 8 frames standing still, then 16 frames rising one pixel per frame. The old text ('four tile entries flanking the hit position', 'spawned during inventory-screen hit feedback') is wrong: it writes two compose-buffer entries per frame and its only spawn site is GiveItemToPlayer.
; 
; === SPAWN ===
; 
; inventory_mgmt.GiveItemToPlayer, special-item branch: effect index >= 6 (item id $86 and up) adds 5 to hpToHeal, runs COP SpawnListAppend ( @SpawnItemSparkleEffect, #00, #00, #$2F00 ) after PHD / TXA / TCD, then plays sound #22. The fourth operand is the flags word for the child's $10. The child copies position from the actor whose slot is in X when the item is given (the in-line comment there says the player; not verified). No item id of $86 or more was found in the chest tables or GiveItem operands of extracted/, so whether this path is reachable in the shipped game is open (OQ-I042-1).
; 
; === BODY ===
; 
; SpawnItemSparkleEffect: LoopStart #08 (8 frames) calling AppendSparkleOamEntries, then LoopStart #10 (16 frames) that first subtracts 1 from $16 and then calls it again; LoopEnd yields every iteration; then Die. There is no initial Y offset (unlike the damage numbers).
; AppendSparkleOamEntries writes two 6-byte entries at the compose-buffer cursor oamWriteOffset ($00D8) in the buffer at $7F3100: X - 4 with tile word $327A, and X + 4 with tile word $327B, both at Y = $16. The tile words are tile $7A and $7B with attribute $3200 (the same priority 3 / palette 1 as the damage digits; tiles $70-$79 are the digits). The cursor advances by $0C. No terminator is written here; the main loop writes $FF after all actors have run.
; 
; What tiles $7A / $7B look like was not checked (OQ-I042-2).
---------------------------------------------

!oamWriteOffset                 00D8
!oamComposeBuffer               7F3100

---------------------------------------------

; Child actor entry: 8 frames at the spawn position, then 16 frames moving up one pixel per frame, calling AppendSparkleOamEntries each frame.

SpawnItemSparkleEffect {
    COP [LoopStart] ( #08 ) ; 8 frames standing at the spawn position
    JSR $&AppendSparkleOamEntries
    COP [LoopEnd]
    COP [LoopStart] ( #10 ) ; 16 frames rising
    LDA $16
    CLC 
    ADC #$FFFF            ; -1 per frame: rise one pixel per frame
    STA $16
    JSR $&AppendSparkleOamEntries
    COP [LoopEnd]
    COP [Die]
}

---------------------------------------------
; Append two compose-buffer entries (X - 4 / tile $327A and X + 4 / tile $327B, both at Y = $16) at oamWriteOffset, then oamWriteOffset += $0C. Preserves X.

AppendSparkleOamEntries {
    PHX 
    LDX $oamWriteOffset   ; X := compose-buffer write cursor oamWriteOffset ($00D8)
    LDA #$327A            ; Tile word $327A: tile $7A, attribute $3200 (priority 3, palette 1)
    STA $oamComposeBuffer+4, X ; Entry layout: +0 X, +2 Y, +4 tile word; entry 1 is drawn at X - 4
    LDA $14
    SEC 
    SBC #$0004
    STA $oamComposeBuffer, X
    LDA $16
    STA $oamComposeBuffer+2, X
    LDA #$327B
    STA $oamComposeBuffer+A, X ; Entry 2 (+6 X, +8 Y, +A tile word $327B) is drawn at X + 4
    LDA $14
    CLC 
    ADC #$0004
    STA $oamComposeBuffer+6, X
    LDA $16
    STA $oamComposeBuffer+8, X
    LDA $oamWriteOffset
    CLC 
    ADC #$000C            ; Two 6-byte entries: advance the cursor by $0C
    STA $oamWriteOffset
    PLX 
    RTS 
}