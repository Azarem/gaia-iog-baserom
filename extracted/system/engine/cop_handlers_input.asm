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
---------------------------------------------

; COP #65 world-map relocation stager taking two word and two byte operands: destination pixel X, pixel Y, destination scene/area ID, and companion byte. Writes WRAM staging fields consumed by the world-map transition system. Does not warp immediately. Used by party-member NPC scripts across Dao, Itory, Watermia, and Freejia.

StageWorldMapMove {
    TYX 
    LDA [$0A]             ; Read destination X pixel position (word)
    INC $0A
    INC $0A
    STA $0D52             ; Store to world-map staging $0D52 (destination X)
    LDA [$0A]             ; Read destination Y pixel position (word)
    INC $0A
    INC $0A
    STA $0D56             ; Store to $0D56 (destination Y)
    LDA [$0A]             ; Read scene/area ID byte
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E (area identifier)
    LDA [$0A]             ; Read companion byte
    INC $0A
    AND #$00FF
    STA $0D5A             ; Store to $0D5A (companion/party member index)
    STZ $0D58             ; Clear $0D58 (choice ID = none for direct relocation)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #66 with two word operands (destination X, Y) plus one byte (choice ID). Writes staging fields $0D52, $0D56, and $0D58 for the world-map transition system without warping immediately.

StageWorldMapChoice {
    TYX 
    LDA [$0A]             ; Read destination X (word)
    INC $0A
    INC $0A
    STA $0D52             ; Store to world-map staging $0D52
    LDA [$0A]             ; Read destination Y (word)
    INC $0A
    INC $0A
    STA $0D56             ; Store to $0D56
    LDA [$0A]             ; Read choice ID byte
    INC $0A
    AND #$00FF
    STA $0D58             ; Store to $0D58 (world-map choice selection)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #67 with two byte operands (scene/area ID, companion byte). Writes $0D5E and $0D5A for world-map relocation staging consumed by the transition system.

StageWorldMapMoveIds {
    TYX 
    LDA [$0A]             ; Read scene/area ID byte
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E
    LDA [$0A]             ; Read companion byte
    INC $0A
    AND #$00FF
    STA $0D5A             ; Store to $0D5A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #BD BG3 console-script runner taking one Address operand: a far pointer to a BG3 tilemap command stream. Switches data bank, calls ConsoleStringRenderer with direct page zeroed, then sets displayModeFlags bit 0 to mark HUD/console rendering active. Used by the diary menu, title screen, and boot-logo actors for text and menu drawing.

RunBg3Script {
    PHY 
    PHB 
    LDA [$0A]             ; Read Address operand: 2-byte pointer + 1-byte bank
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20              ; Switch to 8-bit to push bank byte to DBR
    PHA                   ; Push bank byte for PLB
    PLB                   ; Set data bank to script text bank
    REP #$20
    LDA #$0000            ; Zero direct page for ConsoleStringRenderer workspace
    TCD 
    JSL $@ConsoleStringRenderer ; Render BG3 console text commands
    PLB 
    PLA                   ; Restore caller data bank, actor X, and direct page
    TAX 
    TCD 
    LDA #$0001
    TSB $displayModeFlags ; Set displayModeFlags bit 0 (BG3 console overlay active)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BE with one word (option layout pointer) plus one word (branch table base). Requires worldReadyFlag == $000F; sets dialogue mode ($2000), masks inventory input ($0F00), calls MenuSelectionHandler, and branches into the table entry for the chosen option.

DialogueOptions {
    TYX 
    LDA $worldReadyFlag   ; Read worldReadyFlag — must be $000F for all subsystems ready
    CMP #$000F
    BEQ loc_00A8A6        ; Ready: proceed to menu setup
    LDA $0A               ; Not ready: rewind script pointer and yield RTL
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00A8A6:
    LDA #$2000            ; Set dialogue mode $2000 on displayModeFlags
    TSB $displayModeFlags
    LDA #$0F00
    STA $joypadMaskInv    ; Mask inventory input ($0F00) during menu navigation
    PHB 
    SEP #$20
    LDA $0C               ; Load script bank for PLB to set text data bank
    PHA 
    PLB 
    REP #$20
    LDA $joypadMaskStd    ; Load and clear standard joypad mask — menu handles input
    STZ $joypadMaskStd    ; Save and clear standard joypad mask — menu controls its own input
    PHA 
    LDA $10
    AND #$0800            ; Save and clear status bar bit $0800 during menu
    PHA 
    LDA #$0800
    TRB $10
    LDA [$0A]             ; Read menu layout pointer word
    INC $0A
    INC $0A
    JSL $@MenuSelectionHandler ; Returns chosen option index in A; ASL doubles for word table
    ASL                   ; ASL: double choice index for word-sized table entries
    PHA 
    LDA [$0A]             ; Read branch table base pointer word
    INC $0A
    INC $0A
    CLC                   ; Branch table base + (choice × 2) → table entry address
    ADC $01, S            ; Branch table base + (choice × 2) → target script address
    TAY                   ; Y = address of chosen entry in branch table
    PLA 
    PLA 
    TSB $10
    PLA 
    STA $joypadMaskStd    ; Restore standard joypad mask
    STZ $joypadMaskInv    ; Clear inventory input mask
    LDA #$2000            ; Clear dialogue mode $2000
    TRB $displayModeFlags
    LDA $0000, Y          ; Read branch target from table and RTI to chosen path
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
    LDA $0A               ; Load script pointer — UpdateFrameRender clobbers DP
    PHA                   ; Save script state — UpdateFrameRender clobbers direct page
    SEP #$20
    LDA $0C
    PHA 
    JSL $@system_core.UpdateFrameRender ; Render one frame to sync display before text output
    PLA 
    STA $0C
    REP #$20
    PLA 
    STA $0A
    LDA $10
    AND #$0800            ; Save status bar state and hide it ($0800) during dialogue
    PHA 
    LDA #$0800
    TRB $10               ; Hide status bar ($0800) during text rendering
    LDA $joypadMaskStd    ; Load and clear joypad mask — input blocked during text
    STZ $joypadMaskStd    ; Block standard joypad input during text rendering
    PHA 
    PHB 
    SEP #$20
    LDA $0C               ; Switch DBR to script bank for string data access
    PHA 
    PLB 
    REP #$20
    LDA [$0A]             ; Read text pointer operand word
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer ; Render dialogue text via DialogStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd    ; Restore joypad mask after text complete
    TRB $joypadCurrent    ; Clear directional D-pad in joypadCurrent (prevent input leak)
    LDA #$0F00
    TRB $joypadHeld       ; Clear held D-pad in joypadHeld
    LDA #$2000            ; Clear dialogue mode $2000
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
    LDA #$0800            ; Hide status bar ($0800) during alt text render
    TRB $10
    LDA $joypadMaskStd    ; Load and clear joypad mask
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C               ; Switch DBR to script bank
    PHA 
    PLB 
    REP #$20
    LDA [$0A]             ; Read text pointer and render via DialogStringRenderer
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd
    LDA #$0F00            ; Clear D-pad held state in joypadHeld after rendering
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}