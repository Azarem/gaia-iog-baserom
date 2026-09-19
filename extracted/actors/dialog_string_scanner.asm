; Dialog string scanner — scans ROM banks $85–$0B for the $BF02 dialog marker,
; then renders each found dialog string via DialogStringRenderer.
; 
; Used as a development/debug tool to enumerate and preview all dialog strings
; in the ROM. Waits for worldReadyFlag to be set and positive before starting.
; Scans each bank by setting DBR via PHA/PLB, searching byte-by-byte for $BF02
; (the dialog string header marker). When a marker is found, the next word is
; checked against $8000 (IsStringPointer) — values below $8000 are treated as string
; pointers and passed to DialogStringRenderer for on-screen rendering.
; 
; Enters an infinite NOP loop (loc_0BE200) if all banks are exhausted without
; finding more strings — effectively halts the actor.
---------------------------------------------

?INCLUDE 'DialogStringRenderer'
?INCLUDE 'system_core'

!worldReadyFlag                 0654

---------------------------------------------

dialog_string_scanner [
  actor-def < #00, #00, #20, {

  code_0BE1C8:
    LDA $worldReadyFlag   ; Wait for world to be ready
    BNE loc_0BE1CE
    RTL 

  loc_0BE1CE:
    BPL loc_0BE1D1        ; Skip if negative (loading)
    RTL 

  loc_0BE1D1:
    LDA #$0085            ; Start scanning from bank $85
    STA $24
    LDY #$8000            ; Begin at $8000 (LoROM data start)
    BRA loc_0BE1DE

  loc_0BE1DB:
    LDY #$0000            ; Reset Y for next bank (start at $0000)

  loc_0BE1DE:
    SEP #$20              ; Set DBR = current scan bank
    LDA $24
    PHA 
    PLB 
    REP #$20
    BRA loc_0BE1EB

  loc_0BE1E8:
    REP #$20
    PLA 

  loc_0BE1EB:
    LDA #$BF02            ; Dialog string header marker
    CMP $0000, Y          ; Compare against current position
    BEQ loc_0BE204        ; Found marker — process string
    INY 
    BNE loc_0BE1EB        ; Continue scanning this bank
    LDA $24               ; Bank exhausted — advance to next
    INC 
    STA $24
    CMP #$000C            ; Stop at bank $0C
    BNE loc_0BE1DB

  loc_0BE200:
    NOP                   ; All banks scanned — halt
    NOP 
    BRA loc_0BE200

  loc_0BE204:
    LDA $0002, Y          ; Read word after marker
    INY 
    JSR $&IsStringPointer ; Check if it's a string pointer (< $8000)
    BCS loc_0BE1EB        ; Not a string — skip
    PHA                   ; Save string pointer
    PHB 
    TYA 
    STA $0100             ; Save scan position
    LDA $01, S
    STA $0102             ; Save bank
    PLB 
    PLA 
    INY 
    INY 
    INY 
    PHY                   ; Save resume position
    TAY                   ; Y = string pointer
    SEP #$20
    JSL $@system_core.UpdateFrameRender ; Render frame before dialog
    REP #$20
    JSL $@DialogStringRenderer ; Display the dialog string
    PLY 
    BRA loc_0BE1EB        ; Continue scanning
} >
]

---------------------------------------------
; Address check — returns carry clear if value < $8000 (valid string pointer)

IsStringPointer {
    CMP #$8000
    BCC loc_0BE235        ; Below $8000: valid string pointer (SEC)
    CLC                   ; At or above $8000: not a string (CLC)
    RTS 

  loc_0BE235:
    SEC 
    RTS 
}