; COP handlers for input polling, button-wait loops, world-map staging, dialogue rendering, and BG3 UI (Bank $00, 11 handlers).
; 
; WaitForButton/WaitForRelease yield via RTL until a button mask matches joypadCurrent or joypadRaw. BranchIfPressed/BranchIfNotPressed branch based on current button state.
; 
; StageWorldMapMove/Choice/MoveIds write destination coordinates, scene IDs, and companion bytes into WRAM staging fields ($0D52–$0D5E) for the world-map transition system.
; 
; RunBg3Script switches data bank and calls ConsoleStringRenderer for BG3 overlay text, then sets displayModeFlags bit 0. DialogueOptions sets dialogue mode ($2000), masks inventory input, and calls MenuSelectionHandler for branching choices. PrintDialogString/PrintDialogStringAlt render dialogue text via DialogStringRenderer with status bar hiding and joypad cleanup; the Alt variant omits dialogue-mode setup and UpdateFrameRender.
---------------------------------------------

?BANK 00

!joypadCurrent                  0656
!joypadRaw                      0660

---------------------------------------------

; COP #3E (script name WaitUntilButton) blocking input wait taking one word operand: a button mask. Bit 0 of the mask selects joypadRaw (held-edge) versus joypadCurrent (latched state); loops via RTL yield until any masked button is pressed. Used in actor dialogue and prompt scripts that must pause until the player confirms.

WaitForButton {
    TYX 
    LDA [$0A]             ; Read button mask word operand
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects joypad source: 0=joypadCurrent, 1=joypadRaw
    BNE loc_009498
    BIT $joypadCurrent    ; Test mask against joypadCurrent (latched state)
    BNE loc_00949D        ; Any masked button pressed → advance script via RTI
    BRA loc_0094A2

  loc_009498:
    BIT $joypadRaw        ; Test mask against joypadRaw (held-edge state)
    BEQ loc_0094A2

  loc_00949D:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094A2:
    LDA $0A               ; No button pressed: rewind script PC by 4 bytes (re-enter next frame)
    SEC 
    SBC #$0004
    STA $00
    PLA                   ; Pop COP frame and yield RTL until button detected
    PLA 
    RTL 
}

---------------------------------------------
; COP #3F with one word operand (button mask). Bit 0 selects joypadRaw vs joypadCurrent; yields via RTL (rewinding script PC) until all masked buttons are released, then RTI-advances.

WaitForRelease {
    TYX 
    LDA [$0A]             ; Read button mask word
    INC $0A
    INC $0A
    BIT #$0001            ; Bit 0 selects joypad source for release detection
    BNE loc_0094C0
    BIT $joypadCurrent    ; Test mask against joypadCurrent — zero means all released
    BEQ loc_0094C5        ; All masked buttons released → advance script
    BRA loc_0094CA

  loc_0094C0:
    BIT $joypadRaw        ; Test mask against joypadRaw
    BNE loc_0094CA

  loc_0094C5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094CA:
    LDA $0A               ; Buttons still held: rewind PC and yield RTL
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #40 with one word (button mask) plus one &Code branch target. Bit 0 selects joypad source; jumps to the branch offset if any masked button is pressed, otherwise skips the two-byte branch operand.

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
; COP #41 with one word (button mask) plus one &Code branch target. Jumps to the branch offset when no masked buttons are held in the selected joypad source, otherwise skips the branch operand.

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