; Event-flag and WRAM-flag bit helpers (Bank $00).
; 
; All flags live in one bit array starting at eventFlags ($0A00): flag N is bit (N AND 7) of byte $0A00 + N÷8 (masks from bitmasks_bit_position). Flag indices are 16-bit. The helper names carry the base that is added to the index in A:
;   $0000 (…Raw: TestFlagRaw/SetFlagRaw/ClearFlagRaw) — bytes $0A00–$0A1F; the index is masked to a byte
;   $0100 (…_0100) — bytes $0A20–$0A3F, event/trigger flags: StandardEnemyDefeatHandler, EnemyDefeatDispatch and some boss/puzzle actors; this is the 32-byte field that event_blocks.ApplyAllEventBlocks scans, so flag $0100+n triggers event block n
;   $0200 (…_0200) — bytes $0A40–$0A5F, persistent world events: chests opened (byte 3 of scene_chest_table records) and hidden Red Jewels
;   $0300 (…_0300) — bytes $0A60–$0A7F, one flag per scene ID: the scene's clear reward has been claimed (radar, StandardEnemyDefeatHandler, boss_clear_reward_handler)
;   $0400 (SetWramFlag/TestWramFlag) — bytes $0A80–$0A9F = wramFlags, 256 flags indexed by enemy number (SetDungeonKillFlag, CheckEnemyDefeatedFlag); ClearAllWramFlags zero-fills exactly this block
;   $0500 (TestWramFlag_Offset100/SetWramFlag_Offset100 with index 0–7, and TestFlag_0510) — bytes $0AA0 and up: boss reward flags $0500–$0507 and ability unlock flags $0510+ (TestAbilityFlag: characterForm×4 + slot)
; 
; wramFlags is therefore just the $0400–$04FF slice of the event flag array, accessed with its own base. ClearAllWramFlags is called only by WorldMapController (on entering the world map) and by the scripts st68_kara and sp58_red_eye, and game_over_sequence clears the same block inline on a true death; no reset at ordinary scene changes was found, so these flags outlive a single scene. The _Offset100 variants add $0100 to the index and so land at $0AA0, outside the cleared block.
; 
; Calling convention: the flag index is in A (16-bit); the core routines (SetEventFlag, ClearEventFlag, TestEventFlag, SetWramFlag, TestWramFlag) are JSR-only, preserve X, clobber Y and WRAM scratch $0000, and the Test routines return carry = flag set and A = the isolated bit. The JSL wrappers add the base and call the cores. TestWramFlag has no caller outside this file (CheckEnemyDefeatedFlag in actor_execution repeats the logic inline with its own BitMaskTable_Wram).
---------------------------------------------

?BANK 00

!L_wramFlags                    000A80
!eventFlags                     0A00
!wramFlags                      0A80

---------------------------------------------

; JSL helper (not COP-dispatched) that tests wramFlags bit $0100 + (A AND 7) and returns carry set when the flag is set.
; 
; Index $0100–$0107 gives byte index $20, so it reads $0A80 + $20 = $0AA0 (event flags $0500–$0507) — outside the $20-byte block that ClearAllWramFlags clears. Callers: boss_clear_reward_handler and the boss lair scripts (castoth, sand fanger, vampires, mummy queen, viper) to check a boss's reward/defeat flag.

TestWramFlag_Offset100 {
    AND #$0007            ; Mask to 3-bit flag index (0–7)
    CLC 
    ADC #$0100            ; Index $0100+n → byte wramFlags+$20 = $0AA0 (flags $0500-$0507), outside the block ClearAllWramFlags clears
    JSR $&TestWramFlag    ; Call TestWramFlag to check flag in $0A80 bitfield
    RTL 
}

---------------------------------------------
; JSL helper that sets wramFlags bit $0100 + (A AND 7) (byte $0AA0, event flags $0500–$0507). Pairs with TestWramFlag_Offset100; the only caller is boss_clear_reward_handler, which marks a boss as rewarded.

SetWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100            ; Index $0100+n → byte $0AA0 (flags $0500-$0507), see TestWramFlag_Offset100
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
    LDA $wramFlags, Y     ; Load current wramFlags byte at computed offset
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
    LDA $eventFlags, Y    ; Load current eventFlags byte at computed offset
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
    LDA $@bitmasks_bit_position, X ; Load single-bit mask for flag position
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

; JSL helper that sets persistent event flag $0200 + A (bytes $0A40–$0A5F) via SetEventFlag. A is not masked, so callers must pass a 0–$FF index. Callers: warps_interaction (chest opened) and hidden_red_jewel.

SetEventFlag_0200 {
    CLC 
    ADC #$0200            ; Add $0200 base: persistent world events (chests, Red Jewels)
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
; JSL helper that tests event flag $0300 + (A AND $FF), bytes $0A60–$0A7F. Most callers pass a scene ID: the flag means this scene's clear reward was already claimed.

TestFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300            ; $0300 + scene ID → bytes $0A60-$0A7F (one flag per scene)
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that sets event flag $0300 + (A AND $FF); used to mark a scene's clear reward as claimed (reward_actors, boss_clear_reward_handler).

SetFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300            ; $0300 + scene ID → bytes $0A60-$0A7F
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests event flag $0510 + (A AND $FF). inventory_menu's TestAbilityFlag is the only caller: index = characterForm×4 + slot, so these are the ability unlock flags.

TestFlag_0510 {
    AND #$00FF
    CLC 
    ADC #$0510            ; $0510+: ability unlock flags (characterForm×4 + slot)
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests an event flag without adding a base offset. Masks to byte and calls TestEventFlag directly.

TestFlagRaw {
    AND #$00FF
    JSR $&TestEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that sets an event flag without adding a base offset. Masks to byte and calls SetEventFlag directly.

SetFlagRaw {
    AND #$00FF
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that clears an event flag without adding a base offset. Masks to byte and calls ClearEventFlag directly.

ClearFlagRaw {
    AND #$00FF
    JSR $&ClearEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that zero-fills the $20-byte wramFlags block ($0A80–$0A9F, event flags $0400–$04FF) with a word loop (16 iterations).
; 
; Callers: WorldMapController (twice, when the world map is entered), st68_kara and sp58_red_eye; game_over_sequence clears the same $20 bytes inline on a true death. No call at ordinary scene changes was found.

ClearAllWramFlags {
    PHX 
    LDX #$0000
    LDA #$0000            ; Zero accumulator for 16-word fill loop

  loc_00B4D3:
    STA $L_wramFlags, X   ; Zero 2 bytes of wramFlags ($0A80) per iteration
    INX 
    INX 
    CPX #$0020            ; $20 bytes = 16 word-wide iterations
    BNE loc_00B4D3
    PLX 
    RTL 
}

---------------------------------------------
; JSL helper that sets event/trigger flag $0100 + (A AND $FF), bytes $0A20–$0A3F (callers: StandardEnemyDefeatHandler, EnemyDefeatDispatch, wall walker, mystic ball).

SetFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100            ; $0100+n: event/trigger flags (bytes $0A20-$0A3F)
    JSR $&SetEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that clears event/trigger flag $0100 + (A AND $FF). No caller was found in the extracted code.

ClearFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100            ; $0100+n: clear an event/trigger flag
    JSR $&ClearEventFlag
    RTL 
}

---------------------------------------------
; JSL helper that tests event/trigger flag $0100 + (A AND $FF), bytes $0A20–$0A3F (callers include StandardEnemyDefeatHandler, EnemyDefeatDispatch, wall walker, mystic ball and the pyramid Dark Space portal).

TestFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100            ; $0100+n: test an event/trigger flag
    JSR $&TestEventFlag
    RTL 
}