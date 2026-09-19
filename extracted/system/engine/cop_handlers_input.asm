; COP handlers for input polling, button-wait loops, world-map staging, dialogue rendering, and BG3 UI (Bank $00, 11 handlers).
; 
; WaitForButton/WaitForRelease yield via RTL until a button mask matches joypadCurrent or joypadRaw. BranchIfPressed/BranchIfNotPressed branch based on current button state.
; 
; StageWorldMapMove/Choice/MoveIds write destination coordinates, scene IDs, and companion bytes into WRAM staging fields ($0D52–$0D5E) for the world-map transition system.
; 
; RunBg3Script switches data bank and calls ConsoleStringRenderer for BG3 overlay text, then sets displayModeFlags bit 0. DialogueOptions sets dialogue mode ($2000), masks inventory input, and calls MenuSelectionHandler for branching choices. PrintDialogString/PrintDialogStringAlt render dialogue text via DialogStringRenderer with status bar hiding and joypad cleanup; the Alt variant omits dialogue-mode setup and UpdateFrameRender.
---------------------------------------------

?BANK 00

?INCLUDE 'ConsoleStringRenderer'
?INCLUDE 'DialogStringRenderer'
?INCLUDE 'MenuSelectionHandler'
?INCLUDE 'system_core'

!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRaw                      0660
!displayModeFlags               09EC

---------------------------------------------

; COP #3E (script name WaitUntilButton) blocking input wait taking one word operand: a button mask. Bit 0 of the mask selects joypadRaw (held-edge) versus joypadCurrent (latched state); loops via RTL yield until any masked button is pressed. Used in actor dialogue and prompt scripts that must pause until the player confirms.

WaitForButton {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009498
    BIT $joypadCurrent
    BNE loc_00949D
    BRA loc_0094A2

  loc_009498:
    BIT $joypadRaw
    BEQ loc_0094A2

  loc_00949D:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094A2:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #3F with one word operand (button mask). Bit 0 selects joypadRaw vs joypadCurrent; yields via RTL (rewinding script PC) until all masked buttons are released, then RTI-advances.

WaitForRelease {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094C0
    BIT $joypadCurrent
    BEQ loc_0094C5
    BRA loc_0094CA

  loc_0094C0:
    BIT $joypadRaw
    BNE loc_0094CA

  loc_0094C5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094CA:
    LDA $0A
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
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094E8
    BIT $joypadCurrent
    BNE loc_0094F8
    BRA loc_0094ED

  loc_0094E8:
    BIT $joypadRaw
    BNE loc_0094F8

  loc_0094ED:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0094F8:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #41 with one word (button mask) plus one &Code branch target. Jumps to the branch offset when no masked buttons are held in the selected joypad source, otherwise skips the branch operand.

BranchIfNotPressed {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009514
    BIT $joypadCurrent
    BEQ loc_00951B
    BRA loc_009524

  loc_009514:
    BIT $joypadRaw
    BEQ loc_00951B
    BRA loc_009524

  loc_00951B:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009524:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #65 world-map relocation stager taking two word and two byte operands: destination pixel X, pixel Y, destination scene/area ID, and companion byte. Writes WRAM staging fields consumed by the world-map transition system. Does not warp immediately. Used by party-member NPC scripts across Dao, Itory, Watermia, and Freejia.

StageWorldMapMove {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    STZ $0D58
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #66 with two word operands (destination X, Y) plus one byte (choice ID). Writes staging fields $0D52, $0D56, and $0D58 for the world-map transition system without warping immediately.

StageWorldMapChoice {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D58
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #67 with two byte operands (scene/area ID, companion byte). Writes $0D5E and $0D5A for world-map relocation staging consumed by the transition system.

StageWorldMapMoveIds {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #BD BG3 console-script runner taking one Address operand: a far pointer to a BG3 tilemap command stream. Switches data bank, calls ConsoleStringRenderer with direct page zeroed, then sets displayModeFlags bit 0 to mark HUD/console rendering active. Used by the diary menu, title screen, and boot-logo actors for text and menu drawing.

RunBg3Script {
    PHY 
    PHB 
    LDA [$0A]             ; Read Address operand: 2-byte text pointer into Y, 1-byte bank
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    REP #$20
    LDA #$0000            ; Zero direct page for ConsoleStringRenderer workspace
    TCD 
    JSL $@ConsoleStringRenderer
    PLB 
    PLA                   ; Restore caller data bank, actor ID (X), and direct page from stack
    TAX 
    TCD 
    LDA #$0001
    TSB $displayModeFlags ; Bit 0: mark BG3 console overlay active for HUD rendering
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BE with one word (option layout pointer) plus one word (branch table base). Requires worldReadyFlag == $000F; sets dialogue mode ($2000), masks inventory input ($0F00), calls MenuSelectionHandler, and branches into the table entry for the chosen option.

DialogueOptions {
    TYX 
    LDA $worldReadyFlag   ; Require worldReadyFlag $000F; yield RTL until all subsystems ready
    CMP #$000F
    BEQ loc_00A8A6
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00A8A6:
    LDA #$2000
    TSB $displayModeFlags
    LDA #$0F00
    STA $joypadMaskInv    ; Mask inventory input ($0F00) during menu navigation
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA $joypadMaskStd
    STZ $joypadMaskStd    ; Save and clear standard joypad mask — menu controls its own input
    PHA 
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@MenuSelectionHandler ; Returns chosen option index in A; ASL doubles for word table
    ASL 
    PHA 
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $01, S            ; Branch table base + (choice × 2) → target script address
    TAY 
    PLA 
    PLA 
    TSB $10
    PLA 
    STA $joypadMaskStd
    STZ $joypadMaskInv
    LDA #$2000
    TRB $displayModeFlags
    LDA $0000, Y          ; Read branch target from table entry and RTI to chosen dialogue path
    PLB 
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BF with one word operand (text pointer). Sets dialogue mode ($2000), calls UpdateFrameRender, hides the status bar ($0800), renders via DialogStringRenderer, then clears directional joypad state in joypadCurrent and joypadHeld.

PrintDialogString {
    TYX 
    LDA #$2000            ; Set dialogue mode ($2000) — suppress HUD updates during text
    TSB $displayModeFlags
    LDA $0A
    PHA                   ; Save script state — UpdateFrameRender clobbers direct page
    SEP #$20
    LDA $0C
    PHA 
    JSL $@system_core.UpdateFrameRender
    PLA 
    STA $0C
    REP #$20
    PLA 
    STA $0A
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10               ; Hide status bar ($0800) during text rendering
    LDA $joypadMaskStd
    STZ $joypadMaskStd    ; Block standard joypad input during text rendering
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]             ; Read text pointer operand; switch DBR to script bank for string data
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd
    TRB $joypadCurrent    ; Clear directional inputs ($0F00) so D-pad state doesn't leak into gameplay
    LDA #$0F00
    TRB $joypadHeld       ; Also clear held D-pad state in joypadHeld
    LDA #$2000
    TRB $displayModeFlags
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #6B with one word operand (text pointer). Like PrintDialogString but omits dialogue-mode setup and UpdateFrameRender; still hides the status bar, renders text, and clears joypadHeld directions.

PrintDialogStringAlt {
    TYX 
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd
    LDA #$0F00
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}