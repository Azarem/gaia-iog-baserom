; Bank-1 dialogue rendering wrapper — sets data bank and renders one dialogue frame (192584–192618, Bank 02).
; 
; A thin wrapper that bridges the bank-2 game engine to the DialogStringRenderer in bank 1 ($81 in HiROM). The dialogue system keeps its string data and rendering tables in bank $01/$81, so the data bank register (DBR) must be set to $81 before calling DialogStringRenderer for DB-relative data access to work correctly.
; 
; Input: Y = dialogue string pointer, passed through to DialogStringRenderer (UpdateFrameRender saves and restores Y).
; 
; === SEQUENCE ===
; 
; 1. Save processor flags and data bank (PHP, PHB)
; 2. Save joypadMaskStd and zero it — unmasks all buttons during dialogue rendering so the dialogue system can check for button presses without interference from the game's input mask
; 3. Set DBR = $81 (PHA #$81, PLB) — dialogue data lives in bank $01/$81
; 4. UpdateFrameRender — render-only frame update (sprite composition, palette/display processing, HDMA, HUD, VBlank sync; no actor AI) before processing dialogue
; 5. DialogStringRenderer — the actual bank-1 dialogue engine that processes dialogue string commands, renders text glyphs, handles dialogue box open/close, and manages text scrolling
; 6. Restore joypadMaskStd, data bank, and processor flags
; 
; Callers: treasure-chest handling (warps_interaction) and item-giving NPC interaction (combat_collision InteractionDamage_NPCChat), which show item-get / inventory-full strings.
---------------------------------------------

?INCLUDE 'DialogStringRenderer'
?INCLUDE 'system_core'

!joypadMaskStd                  065A

---------------------------------------------

; Bank-1 dialogue rendering wrapper. Sets DBR to $81 (bank 1) for dialogue data access, temporarily clears joypadMaskStd to unmask all buttons during dialogue processing, calls UpdateFrameRender (one render-only frame), then calls DialogStringRenderer (the bank-1 dialogue engine) with Y still holding the string pointer. Restores joypad mask and data bank on return.
; 
; The bank switch is necessary because DialogStringRenderer reads dialogue strings DB-relative (Y = pointer) from bank $01/$81.

ShowDialogueFrame {
    PHP                   ; Save processor status (data bank is saved by PHB next)
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