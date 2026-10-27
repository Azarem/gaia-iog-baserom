; COP handlers for joypad polling (Bank $00, 4 handlers, COP #3E–#41; the Branch pair has about 190 call sites in the vanilla scripts, the Wait pair none).
; 
; Every handler takes a 16-bit button mask operand (joypad bit layout: B $8000, Y $4000, Select $2000, Start $1000, Up $0800, Down $0400, Left $0200, Right $0100, A $0080, X $0040, L $0020, R $0010). Bit 0 of the mask is never a button, so it is used as the source selector:
; - bit 0 clear: test joypadCurrent, the held buttons minus any consumed or masked ones (joypadHeld, joypadMaskStd; see vblank_joypad)
; - bit 0 set: test joypadRaw, the remapped held state with no consumption or masking applied
; 
; WaitForButton/WaitForRelease (unused by the vanilla scripts) yield via RTL (re-running themselves next frame) until the test passes. BranchIfPressed/BranchIfNotPressed branch immediately on the same test. The world-map staging handlers are in cop_handlers_world_map; RunBg3Script and the dialogue handlers are in cop_handlers_dialog.
---------------------------------------------

?BANK 00

!joypadCurrent                  0656
!joypadRaw                      0660

---------------------------------------------

; COP #3E blocking input wait taking one word operand: a button mask (bit 0 selects joypadRaw instead of joypadCurrent, see the block note). Yields via RTL, re-running the op every frame, until any masked button is down. No vanilla extracted script uses it (the dialogue renderer has its own wait command, DialogCmd_WaitForButton); only the dispatch table references it.

WaitForButton {
    TYX 
    LDA [$0A]             ; Read button mask word operand
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects the source: 0 = joypadCurrent, 1 = joypadRaw
    BNE loc_009498
    BIT $joypadCurrent    ; Test the mask against joypadCurrent (held, minus consumed/masked)
    BNE loc_00949D        ; Any masked button pressed → advance script via RTI
    BRA loc_0094A2

  loc_009498:
    BIT $joypadRaw        ; Test the mask against joypadRaw (remapped held state)
    BEQ loc_0094A2

  loc_00949D:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094A2:
    LDA $0A               ; No button down: script PC − 4 (opcode + operand) → $00, so the op re-runs next frame
    SEC 
    SBC #$0004
    STA $00
    PLA                   ; Drop the COP frame and yield with RTL
    PLA 
    RTL 
}

---------------------------------------------
; COP #3F with one word operand (button mask, bit 0 selects joypadRaw instead of joypadCurrent). Yields via RTL (rewinding the script PC) until none of the masked buttons is down, then advances with RTI. With bit 0 clear a consumed or masked button already counts as released.

WaitForRelease {
    TYX 
    LDA [$0A]             ; Read button mask word
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects joypad source for release detection
    BNE loc_0094C0
    BIT $joypadCurrent    ; Test the mask against joypadCurrent — zero means released
    BEQ loc_0094C5        ; Nothing masked is down → advance the script
    BRA loc_0094CA

  loc_0094C0:
    BIT $joypadRaw        ; Test mask against joypadRaw
    BNE loc_0094CA

  loc_0094C5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094CA:
    LDA $0A               ; Still down: rewind the PC by 4 and yield with RTL
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #40 with one word (button mask, bit 0 selects joypadRaw) plus one &Code branch target (same bank as the script). Jumps to the target if any masked button is down, otherwise skips the two-byte target. Never yields; used heavily by the player actor (walk, ladder and shimmy state machines).

BranchIfPressed {
    TYX 
    LDA [$0A]             ; Read button mask word
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects joypad source
    BNE loc_0094E8
    BIT $joypadCurrent    ; Test mask against joypadCurrent
    BNE loc_0094F8        ; Any bit set → jump to branch target
    BRA loc_0094ED

  loc_0094E8:
    BIT $joypadRaw        ; Test mask against joypadRaw
    BNE loc_0094F8

  loc_0094ED:
    LDA [$0A]             ; No match: skip branch target operand (2 bytes)
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0094F8:
    LDA [$0A]             ; Match: read branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #41 with one word (button mask, bit 0 selects joypadRaw) plus one &Code branch target. Jumps to the target when none of the masked buttons is down in the selected source, otherwise skips the target operand. Inverse of BranchIfPressed.

BranchIfNotPressed {
    TYX 
    LDA [$0A]             ; Read button mask word
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects joypad source
    BNE loc_009514
    BIT $joypadCurrent    ; Test joypadCurrent — zero means not pressed
    BEQ loc_00951B        ; Not pressed → jump to branch target
    BRA loc_009524

  loc_009514:
    BIT $joypadRaw        ; Test joypadRaw for not-pressed check
    BEQ loc_00951B
    BRA loc_009524

  loc_00951B:
    LDA [$0A]             ; Not pressed: read and jump to branch target
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009524:
    LDA [$0A]             ; Pressed: skip branch target operand
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}