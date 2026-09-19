; COP handlers for event/WRAM flag manipulation, inventory, and dungeon kill tracking — plus exported JSL flag helpers (Bank $00, 30 handlers/helpers).
; 
; SetFlagByte/Word and ClearFlagByte/Word set or clear bits in the eventFlags ($0A00) bitfield. BranchOnFlagByte/Word branch based on flag state. WaitOnFlagByte/Word yield until a flag condition is met.
; 
; GiveItem calls GiveItemToPlayer; on failure (inventory full) branches to the overflow address. RemoveItem calls RemoveItemFromInventory. BranchIfMissingItem/BranchIfItemEquipped test inventory state. SetDungeonKillFlag sets a WRAM flag indexed by enemyNum for dungeon clear tracking.
; 
; Exported JSL helpers (used by engine code outside COP context): SetEventFlag/ClearEventFlag/TestEventFlag operate on the eventFlags bitfield at various base offsets (_0200, _0300, _0510, _0100). SetWramFlag/TestWramFlag operate on wramFlags ($0A80). ClearAllWramFlags zeroes the entire $20-byte wramFlags region. TestFlagRaw/SetFlagRaw/ClearFlagRaw access flags without base offset.
; 
; bitmasks_bit_position is a shared 8-byte lookup table mapping bit indices 0–7 to mask bytes $01–$80.
---------------------------------------------

?BANK 00

!L_wramFlags                    000A80
!eventFlags                     0A00
!wramFlags                      0A80

---------------------------------------------

; JSL helper (not COP-dispatched) that tests a WRAM flag in the $0100–$0107 bit-flag range. Expects the flag index (0–7) in A, masks to three bits, adds base $0100, and calls TestWramFlag; returns carry set if the flag is set, carry clear otherwise. Used by boss and dungeon scripts to check defeat/reward flags.

TestWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&TestWramFlag
    RTL 
}

SetWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&SetWramFlag
    RTL 
}

SetWramFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $wramFlags, Y     ; Flag bit index = operand AND #$07; byte = operand ÷ 8
    ORA $@bitmasks_bit_position, X
    STA $wramFlags, Y
    REP #$20
    PLX 
    RTS 
}

TestWramFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X
    AND $wramFlags, Y
    SEC 
    BNE loc_00B0B3
    CLC 

  loc_00B0B3:
    REP #$20
    PLX 
    RTS 
}

SetEventFlag {
    PHX 
    STA $0000
    LSR                   ; LSR×3: event flag ID → byte index in $0A00 bitfield
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $eventFlags, Y    ; ORA bitmasks[X]: set one bit in eventFlags byte
    ORA $@bitmasks_bit_position, X
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

ClearEventFlag {
    PHX 
    STA $0000
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
    EOR #$FF
    AND $eventFlags, Y
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

TestEventFlag {
    PHX 
    STA $0000
    LSR                   ; SEC after AND: TestEventFlag returns carry = bit set
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X
    AND $eventFlags, Y
    SEC 
    BNE loc_00B119
    CLC 

  loc_00B119:
    REP #$20
    PLX 
    RTS 
}

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
    ADC #$0200
    JSR $&SetEventFlag
    RTL 
}

TestEventFlag_0200 {
    REP #$20
    AND #$00FF
    CLC 
    ADC #$0200
    JSR $&TestEventFlag
    RTL 
}

TestFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&TestEventFlag
    RTL 
}

SetFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&SetEventFlag
    RTL 
}

TestFlag_0510 {
    AND #$00FF
    CLC 
    ADC #$0510
    JSR $&TestEventFlag
    RTL 
}

TestFlagRaw {
    AND #$00FF
    JSR $&TestEventFlag
    RTL 
}

SetFlagRaw {
    AND #$00FF
    JSR $&SetEventFlag
    RTL 
}

ClearFlagRaw {
    AND #$00FF
    JSR $&ClearEventFlag
    RTL 
}

ClearAllWramFlags {
    PHX 
    LDX #$0000
    LDA #$0000

  loc_00B4D3:
    STA $L_wramFlags, X
    INX 
    INX 
    CPX #$0020
    BNE loc_00B4D3
    PLX 
    RTL 
}

SetFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&SetEventFlag
    RTL 
}

ClearFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&ClearEventFlag
    RTL 
}

TestFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&TestEventFlag
    RTL 
}