; Development tool: walks the ROM for COP PrintDialogString calls and shows each dialog string (Bank 0B, 778693-778807). No scene, script or table references it (an unscened actor).
; 
; HOW IT FINDS STRINGS: the word $BF02 is the byte pair 02 BF, a COP instruction with signature $BF = PrintDialogString (copdef), followed by its 2-byte operand, a pointer to the string in the script's own bank (&DialogString). The scanner compares a word at every offset, reads the operand after a hit and shows the string through DialogStringRenderer with DBR = the scanned bank, so the pointer resolves in the right bank. The old header called $BF02 a 'dialog string header marker'.
; 
; POINTER TEST: IsNotLoromAddress sets carry for values BELOW 0x8000 and clears it for 0x8000 and up, and the caller skips a hit on carry set (BCS). A string is therefore shown only when the operand is at least 0x8000 (a LoROM address). The old header and the inline notes had this reversed.
; 
; SCAN RANGE: the bank counter $24 is a 16-bit word that starts at $85 and is incremented per bank. The loop ends only when it equals $000C, which happens after the word wraps through $FFFF. Each pass takes the LOW byte as the bank (PHA / PLB), so banks $85-$FF come first, then banks $00-$FF again and again; the old 'banks $85 to $0B' (and the doc's '$85-$8C') do not match the code. Banks after the first are scanned from offset $0000, which on LoROM is not ROM for banks $80-$BF. In practice the halt loop is not reached.
; 
; SAVED STATE: $0100 = the hit offset + 1 (the offset of the $BF signature byte: the INY after the operand read runs before TYA / STA $0100), $0102 = a 16-bit copy of the stack top (the bank byte plus the low byte of the pointer). The scan resumes at the hit offset + 4, the Y that PHY pushes after three more INY. Only system_core's startup check reads $0100 (a leftover resume test).
; 
; START: runs only while worldReadyFlag ($0654) is nonzero and positive (negative = loading); until then it returns every frame.
---------------------------------------------

?INCLUDE 'DialogStringRenderer'
?INCLUDE 'system_core'

!worldReadyFlag                 0654

---------------------------------------------

dialog_string_scanner [
  actor-def < #00, #00, #20, {

  code_0BE1C8:
    LDA $worldReadyFlag   ; Wait until the world is ready ($0654 nonzero ...
    BNE loc_0BE1CE
    RTL 

  loc_0BE1CE:
    BPL loc_0BE1D1
    RTL 

  loc_0BE1D1:
    LDA #$0085            ; Bank counter starts at $85 ...
    STA $24
    LDY #$8000            ; First bank starts at offset 0x8000
    BRA loc_0BE1DE

  loc_0BE1DB:
    LDY #$0000            ; Later banks start at offset $0000

  loc_0BE1DE:
    SEP #$20              ; 8-bit A: the bank is the LOW byte of $24; PHA / PLB sets DBR to it
    LDA $24
    PHA 
    PLB 
    REP #$20
    BRA loc_0BE1EB

  loc_0BE1E8:
    REP #$20              ; Unused entry (no branch reaches it)
    PLA 

  loc_0BE1EB:
    LDA #$BF02            ; $BF02 = bytes 02 BF = COP #$BF = PrintDialogString
    CMP $0000, Y          ; Word at the current offset in the scanned bank; a hit is a PrintDialogString call
    BEQ loc_0BE204
    INY 
    BNE loc_0BE1EB        ; Until Y wraps past $FFFF
    LDA $24
    INC 
    STA $24
    CMP #$000C            ; Halt only when the 16-bit counter equals $000C
    BNE loc_0BE1DB

  loc_0BE200:
    NOP                   ; Halt loop, not reached in practice
    NOP 
    BRA loc_0BE200

  loc_0BE204:
    LDA $0002, Y          ; Operand of the COP: the string pointer (word after the 2 opcode bytes)
    INY 
    JSR $&IsNotLoromAddress ; IsNotLoromAddress: carry set for a value below 0x8000 (not a LoROM address), then keep scanning
    BCS loc_0BE1EB
    PHA 
    PHB 
    TYA 
    STA $0100             ; $0100 = hit offset + 1 (Y after the INY above); the resume offset, hit + 4, is pushed later by PHY
    LDA $01, S            ; Stack top: the bank byte plus the low pointer byte ...
    STA $0102
    PLB 
    PLA 
    INY                   ; Y + 3: past the 2 opcode bytes and the 2 operand bytes, saved as the resume offset
    INY 
    INY 
    PHY 
    TAY                   ; Y = string pointer for the renderer
    SEP #$20
    JSL $@system_core.UpdateFrameRender ; Render a frame first
    REP #$20
    JSL $@DialogStringRenderer ; Show the dialog string (modal; DBR = scanned bank)
    PLY 
    BRA loc_0BE1EB
} >
]

---------------------------------------------
; Carry SET for a value below 0x8000, carry CLEAR for 0x8000 and up. The caller treats carry set as 'not a LoROM address, skip it', so only operands of 0x8000 or more are shown.

IsNotLoromAddress {
    CMP #$8000
    BCC loc_0BE235
    CLC 
    RTS 

  loc_0BE235:
    SEC 
    RTS 
}