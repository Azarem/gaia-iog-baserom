; VRAM buffer clear — zeroes the VRAM staging buffer at $7F:0200 (192618–192652, Bank 02).
; 
; Two entry points for clearing the VRAM write buffer used by the engine's deferred VRAM update system:
; 
; - ClearVramBufferPartial: Zeroes from offset $0140 to $0800 (skips the first 320 bytes, preserving persistent/HUD data at the start of the buffer)
; - ClearVramBufferFull: Zeroes the entire buffer from offset $0000 to $0800 (2048 bytes total)
; 
; Both share a common word-write loop. The buffer at $7F:0200 accumulates VRAM write commands during the frame, which are flushed to VRAM during VBlank.
---------------------------------------------

---------------------------------------------

; Clear VRAM buffer from offset $0140 to $0800. Preserves the first 320 bytes of the buffer (persistent HUD/status data). Shares the write loop with ClearVramBufferFull.

ClearVramBufferPartial {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$0140            ; Partial clear: start at $0140 — skip first 320 bytes (HUD/status)
    BRA loc_02F07E        ; Join shared zero-fill loop
}

---------------------------------------------
; Clear entire VRAM buffer ($7F:0200) from offset $0000 to $0800 (2048 bytes). Writes zero words in a loop. The buffer accumulates deferred VRAM write commands during the active frame, flushed during VBlank.

ClearVramBufferFull {
    PHX 
    PHP 
    REP #$20
    LDA #$0000            ; Full clear: zero-fill entire $7F:0200 VRAM staging buffer
    TAX 

  loc_02F07E:
    STA $7F0200, X        ; Write $0000 word to buffer slot, advance X by 2
    INX 
    INX 
    CPX #$0800            ; Loop until X=$0800 (2048 bytes total)
    BNE loc_02F07E
    PLP 
    PLX 
    RTL 
}