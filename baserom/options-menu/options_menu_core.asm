; =============================================================================
; Options Menu Core — Button mapping UI within the inventory screen
; =============================================================================
;
; Implements the "Optn." tab of the restructured inventory menu.
; Displays 8 action rows with their current button assignments.
; Allows the player to enter assignment mode to remap buttons.
;
; Architecture:
;   - TabHoverOptions: preview when hovering over the Optn. tab
;   - OptionsTab: confirmed tab — full interactive options menu
;   - OptionsPrepareWram: fills WRAM with button display indices
;   - optstr_rows: console string renders all rows via TBL lookups
;
; All BG3 rendering goes through COP [RunBg3Script] and the
; ConsoleStringRenderer. No direct writes to the BG3 buffer.
; Dynamic button assignments use [TBL:@ButtonDisplayTable,wram].

?BANK 02

?INCLUDE 'options_input_remap'
?INCLUDE 'system_strings'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'vblank_joypad'

!joypadHeld                     0658
!joypadRaw                      0660
!L_JOY1L                        004218
!displayModeFlags               09EC
!bg1ConfigMode                  0AE6
!inventoryTabIndex              0AFA

!btnMapA                        0B34
!btnMapB                        0B35
!btnMapX                        0B36
!btnMapY                        0B37
!btnMapL                        0B38
!btnMapR                        0B39

; WRAM scratch for button display indices (8 words = 16 bytes).
; One 16-bit TBL index per action row into ButtonDisplayTable.
; 0 = blank, 1 = A, 2 = B, 3 = X, 4 = Y, 5 = L, 6 = R.
!opt_wram_base                  0BD0
!opt_wram_settings              0BE0

---------------------------------------------
; Console strings for the options menu.
;
; LAYOUT: BG3 text is drawn over the BG1 status background (bg1ConfigMode=0).
; The upper content panel (rows 4-14) is cleared with consolestring_01E8E2
; before drawing, to remove any residual BG3 content from other tabs.
;
; POS coordinate reference (POS:lo,hi → offset (hi<<8)|lo):
;   Row 5, col 2 = $0104 → POS:04,1   (header line)
;   Row 7, col 4 = $01C8 → POS:C8,1   (first data row)
;   Row 22, col 11 = $0596 → POS:96,5  (description area)
optstr_pane |[PAL:0][POS:04,1]Button Mapping[N]--------------|

; Bottom-right description text
optstr_description |[PAL:0][POS:96,5]A to edit.[DBL]Assign buttons[DBL]to actions.|

; "Press a button..." prompt — replaces description during assignment mode
optstr_press_text |[PAL:0][POS:96,5]Press a[DBL]button...|

---------------------------------------------
; Button display table for TBL lookups.
; Index 0 = not assigned (space), 1-6 = physical button letter.
; Each entry is a pointer to a console string.

ButtonDisplayTable [
  &btn_blank
  &BtnNameA
  &BtnNameB
  &BtnNameX
  &BtnNameY
  &BtnNameL
  &BtnNameR
]

---------------------------------------------
; Button name strings for TBL lookup via ButtonDisplayTable.
; Each is a 1-character console string used by optstr_rows.

btn_blank | |
BtnNameA   |A|
BtnNameB   |B|
BtnNameX   |X|
BtnNameY   |Y|
BtnNameL   |L|
BtnNameR   |R|

---------------------------------------------

InventoryOptionSetups [

]

InventoryOptionSetupDelimiter #$FFFF

TextSpeedOptions [
  &text_speed_normal
  &text_speed_fast
  &text_speed_instant
  &text_speed_runinstant
]

text_speed_normal     |Normal|
text_speed_fast       |Fast|
text_speed_instant    |Instant|
text_speed_runinstant |Run Instant|

---------------------------------------------
; Action rows rendered entirely through the ConsoleStringRenderer.
; Static action names are inline. One TBL lookup per row shows the
; assigned button letter, reading WRAM at $0BD0 + row*2.
;
; Row order matches target: Interact, Confirm, Cancel, Attack,
; Block, Run, Use Item, Cycle Item.

optstr_rows |[PAL:0]\
[POS:C6,1]Act/Confirm [TBL:@ButtonDisplayTable,BD0]\
[POS:06,2]Attack      [TBL:@ButtonDisplayTable,BD2]\
[POS:46,2]Cancel      [TBL:@ButtonDisplayTable,BD4]\
[POS:86,2]Use Item    [TBL:@ButtonDisplayTable,BD6]\
[POS:C6,2]Block       [TBL:@ButtonDisplayTable,BD8]\
[POS:06,3][PAL:14]Block2      [PAL:0][TBL:@ButtonDisplayTable,BDA]\
[POS:46,3][PAL:14]Run         [PAL:0][TBL:@ButtonDisplayTable,BDC]\
[POS:86,3][PAL:14]Cycle Item  [PAL:0][TBL:@ButtonDisplayTable,BDE]\
[POS:66,1]Names\
[POS:A8,1][PAL:14]English[PAL:0]\
[POS:26,2]Text Speed\
[POS:68,2][PAL:14][TBL:@TextSpeedOptions,BE0][PAL:0]\
[POS:E6,2]Auto Run\
[POS:28,3][PAL:14]Off[PAL:0]\
[POS:A6,3]Btn. Preset\
[POS:E8,3][PAL:14]Classic 1[PAL:0]|

---------------------------------------------
; Cursor positions for SelectionCursorActor (X, Y pixel pairs).
; 8 rows at tile rows 7-14 = pixels Y 56-112, spaced 8px (one tile row).
; X = 32px (one tile left of data column 5 at pixel 40).
OptionsCursorPositions [
  screen-pos < #$0008, #$0045 >   ;00 row 7  Y=56
  screen-pos < #$0008, #$004D >   ;01 row 8  Y=64
  screen-pos < #$0008, #$0055 >   ;02 row 9  Y=72
  screen-pos < #$0008, #$005D >   ;03 row 10 Y=80
  screen-pos < #$0008, #$0065 >   ;04 row 11 Y=88
  screen-pos < #$0008, #$006D >   ;05 row 12 Y=96
  screen-pos < #$0008, #$0075 >   ;06 row 13 Y=104
  screen-pos < #$0008, #$007D >   ;07 row 14 Y=112
  screen-pos < #$0088, #$003D >
  screen-pos < #$0088, #$0055 >
  screen-pos < #$0088, #$006D >
  screen-pos < #$0088, #$0085 >
]

; Action bit masks (one byte per action, indexed by row 0-7)
ActionBitMasks [
  #$80   ;00 Act/Confirm
  #$20   ;01 Attack
  #$40   ;02 Cancel
  #$02   ;03 Use Item
  #$08   ;04 Block1
  #$04   ;05 Block2
  #$10   ;06 Run
  #$01   ;07 Cycle Item
]

---------------------------------------------
; TabHoverOptions — preview display when hovering over Optn. tab.

TabHoverOptions {
    JSR $&HideAllItemSlots
    JSR $&HideEquipCursor
    JSR $&HideStatusActors
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @optstr_pane )
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_description )
    LDA #$0000
    STA $bg1ConfigMode
    JSR $&OptionsPrepareWram
    COP [RunBg3Script] ( @optstr_rows )
    LDA #$0001
    TSB $displayModeFlags
    RTL
}

---------------------------------------------
; OptionsTab — confirmed options tab. Full interactive menu.

OptionsTab {
    LDA #$0000
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @optstr_pane )
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_description )
    JSR $&HideAllItemSlots
    JSR $&HideEquipCursor
    JSR $&HideStatusActors
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22

  opt_redraw:
    JSR $&OptionsPrepareWram
    COP [RunBg3Script] ( @optstr_rows )
    LDA #$0001
    TSB $displayModeFlags

  opt_position:
    JSR $&OptionsPositionCursor
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$8000, &OptionsRowConfirm )
    COP [BranchIfPressed] ( #$0800, &OptionsCursorUp )
    COP [BranchIfPressed] ( #$0400, &OptionsCursorDown )
    COP [BranchIfPressed] ( #$0200, &OptionsCursorLeft )
    COP [BranchIfPressed] ( #$0100, &OptionsCursorRight )
    COP [BranchIfPressed] ( #$4000, &OptionsExit )
    RTL
}

---------------------------------------------
; OptionsCursorUp — move cursor up with wrap (0..7).

OptionsCursorUp {
    LDA #$0800
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC
    BMI ocu_roll_down_left
    CMP #$0007
    BNE ocu_ok
    LDA #$000B
    BRA ocu_ok

  ocu_roll_down_left:
    LDA #$0007

  ocu_ok:
    STA $22
    BRA opt_position
}

---------------------------------------------
; OptionsCursorDown — move cursor down with wrap (0..7).

OptionsCursorDown {
    LDA #$0400
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC
    CMP #$0008
    BEQ ocd_roll_up_left
    CMP #$000C
    BCC ocd_ok
    LDA #$0008
    BRA ocd_ok
    
  ocd_roll_up_left:
    LDA #$0000

  ocd_ok:
    STA $22
    BRA opt_position
}

---------------------------------------------
; OptionsCursorLeft — move cursor down with wrap (0..7).

OptionsCursorLeft {
    LDA #$0200
    TSB $joypadHeld
    LDA $22
    CMP #$0007
    BCC ocl_ok
    COP [PlaySoundCh2] ( #10 )
    LDA #$0000

  ocl_ok:
    STA $22
    JMP opt_position
}

---------------------------------------------
; OptionsCursorRight — move cursor down with wrap (0..7).

OptionsCursorRight {
    LDA #$0100
    TSB $joypadHeld
    LDA $22
    CMP #$0007
    BCS ocr_ok
    COP [PlaySoundCh2] ( #10 )
    LDA #$0008

  ocr_ok:
    STA $22
    JMP opt_position
}

---------------------------------------------
; OptionsRowConfirm — enter assignment mode for the selected row.

OptionsRowConfirm {
    LDA #$8000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )

    ; Show "Press a button..." in the bottom-right description area
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_press_text )

    ; Wait for all buttons to be released first.
    ; Read JOY1L directly — joypadRaw has remapped action bits, not physical buttons.
  orc_wait_release:
    COP [SetEntryHereAndYield]
    LDA $L_JOY1L
    AND #$C0F0
    BNE orc_wait_release

    ; Now wait for a new button press
  orc_wait_press:
    COP [SetEntryHereAndYield]
    LDA $L_JOY1L
    AND #$C0F0
    BEQ orc_wait_press

    ; Determine which button was pressed and toggle the action
    LDA #$C000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )
    JSR $&OptionsToggleMapping

    ; Rebuild remap words from updated save bytes
    JSL $@options_input_remap.ApplyButtonMapping

    ; Redraw everything
    COP [RunBg3Script] ( @optstr_pane )
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_description )
    JMP $&opt_redraw
}

---------------------------------------------
; OptionsExit — cancel out of options tab, return to main menu.

OptionsExit {
    COP [PlaySoundCh2] ( #11 )
    LDA #$4000
    TSB $joypadHeld
    COP [KillNext]
    JMP $&InventoryMainLoop
}

---------------------------------------------
; OptionsPositionCursor — position the selection cursor actor at row $22.

OptionsPositionCursor {
    PHX
    LDY $20
    LDA $22
    ASL
    ASL
    TAX
    LDA $@OptionsCursorPositions, X
    STA $0014, Y
    LDA $@OptionsCursorPositions+2, X
    STA $0016, Y
    PLX
    RTS
}

---------------------------------------------
; OptionsPrepareWram — populate WRAM with button display indices.
;
; For each of the 8 action rows, finds which physical button (if any)
; has that action's bit set, and stores a single TBL index at $0BD0+row*2:
;   0 = not assigned, 1 = A, 2 = B, 3 = X, 4 = Y, 5 = L, 6 = R
;
; Each action maps to at most one button (exclusive assignment).
;
; NOTE: ActionBitMasks is in ROM. DBR=$81 during actor code, so we
; MUST use long,X addressing ($@) for the ROM table read.
; Y is used for button iteration (WRAM reads are DBR-safe).

OptionsPrepareWram {
    PHP
    PHX
    PHY

    STZ $0004              ; $04 = WRAM output offset (0, 2, 4, ..., 14)
    LDX #$0000            ; X = row index (0..7)
    SEP #$20

  opw_row:
    LDA $@ActionBitMasks, X
    STA $0000              ; $0000 = action bit mask for this row
    STX $0006              ; save row index

    LDY #$0000             ; Y = button index (0..5)

  opw_btn:
    LDA $btnMapA, Y        ; button save byte at $0B34 + button index
    AND $0000              ; test action bit
    BNE opw_found          ; this button has the action
    INY
    CPY #$0006
    BNE opw_btn

    ; No button found — store 0 (blank)
    LDX $0004
    STZ $opt_wram_base, X
    BRA opw_next

  opw_found:
    TYA                    ; button index (0..5)
    INC                    ; +1 → display index (1=A, 2=B, 3=X, 4=Y, 5=L, 6=R)
    LDX $0004
    STA $opt_wram_base, X

  opw_next:
    INX
    INX
    STX $0004              ; save updated WRAM offset
    LDX $0006              ; restore row index
    INX
    CPX #$0008
    BNE opw_row
    
    ;Populate other settings variables

    ;Text speed
;    LDA $0B24
;    AND #$0003
;    STA $opt_wram_settings
    
    ;Autorun
;    LDA $0B24
;    BIT #$0040
;    BEQ opw_no_autorun
;    LDX #$0001
;    BRA opw_store_autorun
    
;  opw_no_autorun:
;    LDX #$0000

;  opw_store_autorun:
;    STA $opt_wram_settings+2

    PLY
    PLX
    PLP
    RTS
}

---------------------------------------------
; OptionsToggleMapping — assign an action exclusively to one button.
;
; Entry: $22 = selected action row (0-7)
;        joypadRaw ($0660) has the pressed physical button
;
; Clears the action from ALL buttons, then sets it on the pressed
; button (unless it was already on that button — toggle off).
; This enforces one button per action.

OptionsToggleMapping {
    PHX

    ; Determine which physical button was pressed.
    ; Read JOY1L directly — joypadRaw has remapped action bits, not physical buttons.
    LDA $L_JOY1L
    BIT #$0080
    BNE otm_btn_a
    BIT #$8000
    BNE otm_btn_b
    BIT #$0040
    BNE otm_btn_x
    BIT #$4000
    BNE otm_btn_y
    BIT #$0020
    BNE otm_btn_l
    BIT #$0010
    BNE otm_btn_r
    PLX
    RTS                    ; no recognized button

  otm_btn_a:
    LDX #$0000
    BRA otm_toggle
  otm_btn_b:
    LDX #$0001
    BRA otm_toggle
  otm_btn_x:
    LDX #$0002
    BRA otm_toggle
  otm_btn_y:
    LDX #$0003
    BRA otm_toggle
  otm_btn_l:
    LDX #$0004
    BRA otm_toggle
  otm_btn_r:
    LDX #$0005

  otm_toggle:
    ; X = button index (0-5), $22 = action row (0-7)
    ; Load the action bit mask for the selected row.
    ; Must use long,X ($@) because DBR=$81 during actor code.
    PHX
    LDA $22
    AND #$00FF
    TAX
    LDA $@ActionBitMasks, X
    AND #$00FF
    STA $0000              ; action bit mask
    PLX

    ; Check if pressed button already has this action
    SEP #$20
    LDA $btnMapA, X
    AND $0000
    STA $0002              ; non-zero if was already set

    ; Clear the action from all 6 buttons
    LDA $0000
    EOR #$FF               ; invert mask
    STA $0006
    PHY
    LDY #$0005
  otm_clear:
    LDA $btnMapA, Y
    AND $0006
    STA $btnMapA, Y
    DEY
    BPL otm_clear
    PLY

    ; If button already had the action, leave cleared (toggle off)
    LDA $0002
    BEQ otm_assign
    LDA $22
    CMP #$05
    BCS otm_done

    ; Assign: set the action on the pressed button
  otm_assign:
    LDA $btnMapA, X
    ORA $0000
    STA $btnMapA, X

  otm_done:
    REP #$20
    PLX
    RTS
}

