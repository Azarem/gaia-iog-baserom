; VRAM buffer clear — zeroes the BG3 tilemap staging buffer at $7F:0200 (192618–192652, Bank 02).
; 
; The buffer is a 32×32-word BG3 tilemap (2048 bytes, 64 bytes per tilemap row). The HUD, dialogue, console-text, menu and radar renderers write tilemap words into it; when displayModeFlags bit 0 is set the engine DMAs it to VRAM $7800 (BG3SC = $78).
; 
; Two entry points:
; 
; - ClearVramBufferPartial: Zeroes offsets $0140–$07FF. The first $0140 bytes (160 words = 5 tilemap rows) are kept — that is exactly the span LoadHudTilemap fills (HudTilemapData expands to 159 words), so the HUD survives overlay teardown (inferred from the stream length).
; - ClearVramBufferFull: Zeroes the whole buffer, offsets $0000–$07FF.
; 
; Both share one word-write loop. Clobbers A; preserves X and P. Assembled for 16-bit index registers (it does not REP #$10 itself).
---------------------------------------------

!bg3TilemapBuffer               7F0200

---------------------------------------------

; Clear the BG3 staging buffer from offset $0140 to $0800. Keeps the first 320 bytes (the HUD rows written by LoadHudTilemap). Shares the write loop with ClearVramBufferFull.

ClearVramBufferPartial {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$0140            ; Partial clear: start at $0140 — skip first 320 bytes (HUD rows)
    BRA loc_02F07E        ; Join shared zero-fill loop
}

---------------------------------------------
; Clear the entire BG3 staging buffer ($7F:0200) from offset $0000 to $0800 (2048 bytes) by writing zero words in a loop. A following flush (displayModeFlags bit 0) uploads the cleared words to BG3.

ClearVramBufferFull {
    PHX 
    PHP 
    REP #$20
    LDA #$0000            ; Full clear: zero-fill entire $7F:0200 VRAM staging buffer
    TAX                   ; X = 0 — start at buffer offset $0000

  loc_02F07E:
    STA $bg3TilemapBuffer, X ; Write $0000 word to buffer slot, advance X by 2
    INX 
    INX 
    CPX #$0800            ; Loop until X=$0800 (2048 bytes total)
    BNE loc_02F07E
    PLP 
    PLX 
    RTL 
}