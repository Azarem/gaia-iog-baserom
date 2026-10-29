; COP handlers for BG3 console scripts and dialogue text (Bank $00).
; 
; RunBg3Script (COP #BD), DialogueOptions (COP #BE), PrintDialogString (COP #BF) and PrintDialogStringAlt (COP #6B). Each reads its operands through [$0A] and returns to the actor script by writing the advanced $0A into the return frame ($02,S) and executing RTI.
; 
; The three dialogue handlers save and clear two pieces of state while the renderer runs and restore them afterwards: actor $10 bit 11 ($0800, cutscene-active; cleared so that RunActors_CutsceneOnly, run by the renderer's frame updates, does not re-run this actor — inferred) and joypadMaskStd (the buttons suppressed from joypadCurrent; cleared so the renderer sees every button).
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
!displayModeFlags               09EC

---------------------------------------------

; COP #BD BG3 console-script runner taking one Address operand: a far pointer to a BG3 tilemap command stream.
; 
; Switches the data bank, calls ConsoleStringRenderer with the direct page zeroed, then sets displayModeFlags bit 0 (full BG3 staging-buffer upload request). Used by the diary menu, title screen and boot-logo actors, and by UpdateHUD for the HUD counters.

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
    TSB $displayModeFlags ; Set displayModeFlags bit 0: request a full BG3 staging-buffer upload
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BE with two byte operands (read together as one word and passed to MenuSelectionHandler as its menu parameters, e.g. the grid encoding; not a pointer) plus one word (branch table base).
; 
; Requires worldReadyFlag == $000F (otherwise it rewinds the script pointer and yields). Sets displayModeFlags bit 13 ($2000; no reader of this bit was found), sets joypadMaskInv = $0F00 (the D-pad buttons are the auto-repeat ones while the menu is open), clears joypadMaskStd and actor $10 bit 11 for the duration, calls MenuSelectionHandler, and branches through the table entry for the chosen option (table base + choice × 2).

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
    LDA #$2000            ; Set displayModeFlags bit 13 ($2000); no reader of this bit was found
    TSB $displayModeFlags
    LDA #$0F00
    STA $joypadMaskInv    ; joypadMaskInv = $0F00: D-pad directions are the auto-repeat buttons during menu navigation
    PHB 
    SEP #$20
    LDA $0C               ; Load script bank for PLB to set text data bank
    PHA 
    PLB 
    REP #$20
    LDA $joypadMaskStd    ; Save joypadMaskStd (the buttons suppressed from joypadCurrent)
    STZ $joypadMaskStd    ; Clear it so the menu handler sees every button
    PHA 
    LDA $10
    AND #$0800            ; Save actor $10 bit 11 ($0800, cutscene-active)
    PHA 
    LDA #$0800
    TRB $10               ; Clear it so RunActors_CutsceneOnly skips this actor while the menu runs (inferred)
    LDA [$0A]             ; Read the two byte operands as one word: menu parameters for MenuSelectionHandler (not a pointer)
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
    TSB $10               ; Restore the saved bit
    PLA 
    STA $joypadMaskStd    ; Restore standard joypad mask
    STZ $joypadMaskInv    ; Clear the auto-repeat mask
    LDA #$2000            ; Clear dialogue mode $2000
    TRB $displayModeFlags
    LDA $0000, Y          ; Read branch target from table and RTI to chosen path
    PLB 
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BF with one word operand (text pointer).
; 
; Sets displayModeFlags bit 13 ($2000; no reader found), calls UpdateFrameRender to sync the display, clears actor $10 bit 11 and joypadMaskStd, renders the text via DialogStringRenderer, then restores the mask, re-applies it to joypadCurrent (TRB) and clears the D-pad bits ($0F00) in joypadHeld.

PrintDialogString {
    TYX 
    LDA #$2000            ; Set displayModeFlags bit 13 ($2000); no reader found (HUD suppression is hudDisableFlag, not this bit)
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
    AND #$0800            ; Save actor $10 bit 11 ($0800, cutscene-active)
    PHA 
    LDA #$0800
    TRB $10               ; Clear it for the duration of the text (inferred reason)
    LDA $joypadMaskStd    ; Save joypadMaskStd (suppressed buttons)
    STZ $joypadMaskStd    ; Clear it so the text renderer sees every button (A/B to advance)
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
    STA $joypadMaskStd    ; Restore the suppress mask
    TRB $joypadCurrent    ; A = restored mask: re-suppress those buttons in joypadCurrent so the dialogue's presses do not leak out
    LDA #$0F00
    TRB $joypadHeld       ; Clear the D-pad bits in joypadHeld
    LDA #$2000            ; Clear displayModeFlags bit 13
    TRB $displayModeFlags
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #6B with one word operand (text pointer).
; 
; Like PrintDialogString but without the bit 13 set/clear and the UpdateFrameRender sync, and it does not re-apply the mask to joypadCurrent; it still clears actor $10 bit 11 and joypadMaskStd while rendering and clears the D-pad bits in joypadHeld afterwards.

PrintDialogStringAlt {
    TYX 
    LDA $10
    AND #$0800            ; Save actor $10 bit 11 ($0800, cutscene-active)
    PHA 
    LDA #$0800            ; Hide status bar ($0800) during alt text render
    TRB $10               ; Clear it while the text renders
    LDA $joypadMaskStd    ; Save joypadMaskStd (suppressed buttons)
    STZ $joypadMaskStd    ; Clear it so the text renderer sees every button
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
    LDA #$0F00            ; Clear the D-pad bits in joypadHeld
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}