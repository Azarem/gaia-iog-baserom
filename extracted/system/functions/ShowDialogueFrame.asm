; Bank-1 dialogue rendering wrapper — sets data bank and renders one dialogue frame (192584–192618, Bank 02).
; 
; A thin wrapper that bridges the bank-2 game engine to the DialogStringRenderer in bank 1 ($81 in HiROM). The SNES dialogue system stores its string data and rendering tables in bank $01/$81, so the data bank register (DBR) must be set to $81 before calling DialogStringRenderer for DB-relative data access to work correctly.
; 
; === SEQUENCE ===
; 
; 1. Save processor flags and data bank (PHP, PHB)
; 2. Save joypadMaskStd and zero it — unmasks all buttons during dialogue rendering so the dialogue system can check for button presses without interference from the game's input mask
; 3. Set DBR = $81 (PHA #$81, PLB) — dialogue data lives in bank $01/$81
; 4. UpdateFrameRender — renders one complete game frame (sprite composition, VRAM DMA, palette upload) before processing dialogue
; 5. DialogStringRenderer — the actual bank-1 dialogue engine that processes dialogue string commands, renders text glyphs, handles dialogue box open/close, and manages text scrolling
; 6. Restore joypadMaskStd, data bank, and processor flags
; 
; Called by various dialogue-triggering systems (chest interaction, NPC scripts, cutscenes) whenever a dialogue string needs to be displayed with a frame of rendering.
---------------------------------------------

?INCLUDE 'DialogStringRenderer'
?INCLUDE 'system_core'

!joypadMaskStd                  065A

---------------------------------------------

; Bank-1 dialogue rendering wrapper. Sets DBR to $81 (bank 1) for dialogue data access, temporarily clears joypadMaskStd to unmask all buttons during dialogue processing, calls UpdateFrameRender (one frame of game rendering), then calls DialogStringRenderer (the bank-1 dialogue engine). Restores joypad mask and data bank on return.
; 
; The bank switch is necessary because DialogStringRenderer uses DB-relative addressing to access dialogue string data, glyph tables, and rendering state stored in bank $01/$81.

ShowDialogueFrame {
    PHP                   ; Save processor state (P/M/X) and data bank for dialogue wrapper
    PHB 
    REP #$20
    LDA $joypadMaskStd    ; Save joypadMaskStd and zero it — unmask all buttons during dialogue
    STZ $joypadMaskStd
    PHA 
    SEP #$20              ; Set DBR = $81 — dialogue string data and tables live in bank $01/$81
    LDA #$81
    PHA 
    PLB 
    JSL $@system_core.UpdateFrameRender ; Render one game frame before processing dialogue (UpdateFrameRender)
    REP #$20
    JSL $@DialogStringRenderer ; DialogStringRenderer — text commands, glyph render, box open/close
    PLA 
    STA $joypadMaskStd    ; Restore saved joypadMaskStd
    PLB                   ; Restore data bank and processor state
    PLP 
    RTL 
}