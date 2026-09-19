; Exported JSL flag helper library and core flag routines for the eventFlags ($0A00) and wramFlags ($0A80) bitfields (Bank $00, 7 core routines + 12 JSL offset wrappers + 1 data table).
; 
; Core routines: SetEventFlag/ClearEventFlag/TestEventFlag decompose a flag index into byte (÷8) and bit (AND $07) indices using the bitmasks_bit_position lookup table, then OR/AND/test the corresponding bit in the eventFlags array at $0A00. SetWramFlag/TestWramFlag perform the same operation on the wramFlags array at $0A80.
; 
; JSL offset wrappers add base offsets ($0100, $0200, $0300, $0510) before calling the core routines, providing scoped flag access for different game systems: $0100 for boss/dungeon defeat flags, $0200 for persistent world events (chests, Red Jewels), $0300 for scene-scoped state, $0510 for late-game progression. TestFlagRaw/SetFlagRaw/ClearFlagRaw access flags without offset.
; 
; ClearAllWramFlags zero-fills the entire $20-byte wramFlags region. bitmasks_bit_position is a shared 8-byte table mapping indices 0–7 to mask bytes $01–$80.
; 
; The COP handlers that call these routines (SetFlagByte/Word, ClearFlagByte/Word, BranchOnFlagByte/Word, WaitOnFlagByte/Word, GiveItem, RemoveItem, BranchIfMissingItem, BranchIfItemEquipped, SetDungeonKillFlag) are in cop_handlers_flow.
---------------------------------------------

?BANK 00

!L_wramFlags                    000A80
!eventFlags                     0A00
!wramFlags                      0A80

---------------------------------------------

; JSL helper (not COP-dispatched) that tests a WRAM flag in the $0100–$0107 bit-flag range. Expects the flag index (0–7) in A, masks to three bits, adds base $0100, and calls TestWramFlag; returns carry set if the flag is set, carry clear otherwise. Used by boss and dungeon scripts to check defeat/reward flags.

TestWramFlag_Offset100 {
    AND #$0007            ; Mask to 3-bit flag index (0–7)
    CLC 
    ADC #$0100            ; Add $0100 base for boss/dungeon flag region
    JSR $&TestWramFlag    ; Call TestWramFlag to check flag in $0A80 bitfield
    RTL 
}

---------------------------------------------
; JSL helper that sets a WRAM flag at base $0100. Masks the index to 3 bits, adds $0100, and calls SetWramFlag. Pairs with TestWramFlag_Offset100 for boss/dungeon defeat flags.

SetWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&SetWramFlag
    RTL 
}

---------------------------------------------
; Core JSR routine that sets one bit in the wramFlags ($0A80) bitfield. Decomposes the flag index: byte = index÷8 (LSR×3), bit = index AND $07, then ORs the corresponding bitmasks_bit_position entry into the wramFlags byte. Called by SetDungeonKillFlag and all SetWramFlag JSL wrappers.

SetWramFlag {
    PHX 
    STA $0000             ; Save flag index in scratch for bit decomposition
    LSR                   ; LSR ×3: flag index ÷ 8 → byte offset in wramFlags
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000             ; Recover low 3 bits of flag index for bit position
    AND #$07
    TAX 
    LDA $wramFlags, Y     ; Flag bit index = operand AND #$07; byte = operand ÷ 8
    ORA $@bitmasks_bit_position, X ; OR bitmask: set the targeted bit
    STA $wramFlags, Y     ; Write updated byte back to wramFlags
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Core JSR routine that tests one bit in the wramFlags ($0A80) bitfield. Uses the same byte/bit decomposition as SetWramFlag, ANDs the bit mask against the wramFlags byte, and returns carry set if the flag is set, carry clear otherwise.

TestWramFlag {
    PHX 
    STA $0000             ; Save flag index for bit decomposition
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X ; Look up single-bit mask for flag position 0–7
    AND $wramFlags, Y     ; AND mask with wramFlags byte: nonzero = flag set
    SEC 
    BNE loc_00B0B3        ; Nonzero → carry set (flag is set); zero → carry clear
    CLC 

  loc_00B0B3:
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Core JSR routine that sets one bit in the eventFlags ($0A00) bitfield. Decomposes the flag index into byte (÷8) and bit (AND $07) indices, ORs the bitmasks_bit_position entry into the eventFlags byte. Called by all SetFlag COP handlers and JSL offset wrappers.

SetEventFlag {
    PHX 
    STA $0000             ; Save flag index
    LSR                   ; LSR ×3: flag index ÷ 8 → byte index in eventFlags ($0A00)
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $eventFlags, Y    ; ORA bitmasks[X]: set one bit in eventFlags byte
    ORA $@bitmasks_bit_position, X ; ORA bitmask: set the targeted event flag bit
    STA $eventFlags, Y    ; Write back to eventFlags
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Core JSR routine that clears one bit in the eventFlags ($0A00) bitfield. Loads the bitmasks_bit_position entry, inverts it via EOR #$FF to create a clear mask, then ANDs against the eventFlags byte. Called by ClearFlag COP handlers and JSL wrappers.

ClearEventFlag {
    PHX 
    STA $0000             ; Save flag index for clear
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X ; EOR #$FF mask: clear one bit in eventFlags byte
    EOR #$FF              ; EOR #$FF: invert mask to create clear pattern
    AND $eventFlags, Y    ; AND: clear one bit, preserve all others
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Core JSR routine that tests one bit in the eventFlags ($0A00) bitfield. ANDs the bitmasks_bit_position entry against the eventFlags byte, then uses SEC/BNE/CLC to return carry set if the bit is set, carry clear if clear. Called by BranchOnFlag, WaitOnFlag COP handlers and all TestFlag JSL wrappers.

TestEventFlag {
    PHX 
    STA $0000             ; Save flag index for test
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X ; Load single-bit mask for flag position
    AND $eventFlags, Y    ; AND with eventFlags byte: nonzero = flag set
    SEC                   ; Presume flag set; CLC below clears carry if AND was zero
    BNE loc_00B119
    CLC 

  loc_00B119:
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Shared 8-byte lookup table mapping bit indices 0–7 to single-bit mask bytes: $01, $02, $04, $08, $10, $20, $40, $80. Used by all Set/Clear/Test flag routines for bit-level access to the eventFlags and wramFlags arrays.

bitmasks_bit_position [
  #01   ;00
  #02   ;01
  #04   ;02
  #08   ;03
  #10   ;04
  #20   ;05
  #40   ;06
  #80   ;07
]
---------------------------------------------

; JSL helper (not COP-dispatched) that sets a persistent event flag in the $0200+ eventFlags array. Expects the flag index in A, adds base $0200, and calls SetEventFlag to OR the corresponding bit. Called from warps_interaction chest handling and hidden_red_jewel to permanently mark one-shot world events.

SetEventFlag_0200 {
    CLC 
    ADC #$0200            ; Offset $0200: persistent world events (chests, Red Jewels)
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag at base $0200 (persistent world events). Masks to byte, adds $0200, and calls TestEventFlag. Returns carry set if set.

TestEventFlag_0200 {
    REP #$20
    AND #$00FF
    CLC 
    ADC #$0200
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag at base $0300 (scene-scoped flags). Masks to byte, adds $0300, and calls TestEventFlag.

TestFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300            ; Offset $0300: scene-scoped state flags
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that sets an event flag at base $0300 (scene-scoped flags). Masks to byte, adds $0300, and calls SetEventFlag.

SetFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300            ; Offset $0300: set scene-scoped flag
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag at base $0510 (late-game progression). Masks to byte, adds $0510, and calls TestEventFlag.

TestFlag_0510 {
    AND #$00FF
    CLC 
    ADC #$0510            ; Offset $0510: late-game progression flags
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag without adding a base offset. Masks to byte and calls TestEventFlag directly.

TestFlagRaw {
    AND #$00FF
    JSR $&TestEventFlag   ; InitSmoothMovement: zero direction sign accumulator
    RTL 
}

---------------------------------------------
; JSL helper that sets an event flag without adding a base offset. Masks to byte and calls SetEventFlag directly.

SetFlagRaw {
    AND #$00FF
    JSR $&SetEventFlag    ; Read animation index operand
    RTL 
}

---------------------------------------------
; JSL helper that clears an event flag without adding a base offset. Masks to byte and calls ClearEventFlag directly.

ClearFlagRaw {
    AND #$00FF            ; $FF = keep current animation unchanged
    JSR $&ClearEventFlag
    RTL                   ; ProcessAnimFlag: set $28 with directional flip
}

---------------------------------------------
; JSL helper that zero-fills the entire $20-byte wramFlags region at $0A80. Uses a word-wide STA loop (16 iterations × 2 bytes = 32 bytes). Called on scene transitions to reset all temporary WRAM flags.

ClearAllWramFlags {
    PHX 
    LDX #$0000            ; X delta: moveXAlt (target) - actor.X
    LDA #$0000            ; Zero accumulator for 16-word fill loop

  loc_00B4D3:
    STA $L_wramFlags, X   ; Zero $20 bytes (16 words) of wramFlags at $0A80 via word-wide STA loop
    INX 
    INX                   ; ROR $0004: shift X sign bit into tracking word
    CPX #$0020            ; $20 bytes = 16 word-wide iterations
    BNE loc_00B4D3
    PLX 
    RTL 
}

---------------------------------------------
; JSL helper that sets an event flag at base $0100 (boss/dungeon defeat flags). Masks to byte, adds $0100, and calls SetEventFlag.

SetFlag_0100 {
    AND #$00FF            ; Store absolute X distance to moveXAlt
    CLC                   ; Y delta: moveYAlt (target) - actor.Y
    ADC #$0100            ; Offset $0100: boss/dungeon defeat flags
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that clears an event flag at base $0100. Masks to byte, adds $0100, and calls ClearEventFlag.

ClearFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100            ; Offset $0100: clear boss/dungeon defeat flag
    JSR $&ClearEventFlag  ; Compare Y vs X: larger axis is primary travel direction
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag at base $0100. Masks to byte, adds $0100, and calls TestEventFlag.

TestFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100            ; Offset $0100: test boss/dungeon flag
    JSR $&TestEventFlag   ; Read frame-count operand (duration in ticks)
    RTL 
}