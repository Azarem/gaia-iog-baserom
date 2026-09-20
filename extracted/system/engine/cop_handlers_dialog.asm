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
!displayModeFlags               09EC

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