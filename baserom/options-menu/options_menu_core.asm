; =============================================================================
; Options Menu Core — button mapping + registered settings inside the inventory screen
; =============================================================================
;
; Implements the "Optn." tab of the restructured inventory menu.
;
;   LEFT PANEL   Eight action rows with their current button assignments.
;                Confirm on a row enters assignment mode (press a button).
;   RIGHT PANEL  Registered settings (see SETTING REGISTRY below). Each setting
;                is a label row plus a value row. Confirm on a setting drops the
;                cursor onto the value row; the D-pad changes the value;
;                Confirm (8000) commits, Cancel (4000) reverts.
;
; Architecture:
;   - TabHoverOptions: preview when hovering over the Optn. tab
;   - OptionsTab: confirmed tab — full interactive options menu
;   - OptionsDrawAll: draws both panels (shared by hover and tab redraw)
;   - OptionsPrepareWram: fills WRAM with button display indices
;   - optstr_rows_left: console string rendering the action rows via TBL lookups
;   - Settings are rendered per-record through ConsoleStringRenderer
;     (OptRenderString) at a position computed from the record index.
;
; =============================================================================
; SETTING REGISTRY
; =============================================================================
;
; InventoryOptionSetups is a flat array: a head word (record stride, 24), then
; fixed-size records, then InventoryOptionSetupDelimiter (#$FFFF). The UI draws
; one setting per two tile rows starting at tile row 5; the panel fits 5 records
; (OptCountSettings clamps to 5).
;
; Every setting lives entirely in its OWN patch file: its strings, option table,
; registration record and the code that consumes the value. A setting registers
; by splicing a record in next to one of two anchors (separate blocks laid out
; contiguously in application order):
;
;     OptionSettingPreset- [ ...record... ]      ; before Btn. Preset (the usual form)
;     InventoryOptionSetups+ [ ...record... ]    ; at the very start of the list
;
; Place the registration at the END of the patch file, after the file's other
; override labels: any unsuffixed block that follows an override label is
; chain-inserted into that override's target file instead of staying in the patch.
; Patches are applied in layer order (baserom, base project, modules), so with
; the first form earlier registrations are listed first and Btn. Preset always
; stays last. The head word keeps InventoryOptionSetups non-empty, which the
; patch engine requires for merging.
;
; Record layout (offsets in bytes, 24 bytes total):
;
;   +00  render   @console string (3-byte pointer) drawn at the setting's start
;                 position. It must NOT contain [POS]. Typical form:
;                   |[PAL:0]Label[N] [PAL:14][TBL:@Choices,<temp>][PAL:0]|
;   +03  desc     @console string (3-byte pointer) with its own [POS:96,5], shown
;                 in the lower right panel while the cursor is on the setting
;   +06  temp     WRAM word used as the TBL index (the "option value switch").
;                 Must equal <temp> in the render string and live in $0000-$1FFF.
;                 Allocation: $0BE0 Names, $0BE2 Text Speed, $0BE4 Auto-Jewels,
;                 $0BE6 Run Button, $0BE8 Btn. Preset, $0BEA+ is reserved for
;                 the button preview buffer.
;   +08  store    WRAM address of the packed persistent byte (inside the save
;                 block $0A00-$0BFB), or 0 when the handlers manage storage
;   +0A  shift    bit position of the field inside the stored byte
;   +0C  mask     field mask before shifting (e.g. 0003 for 2 bits)
;   +0E  xor      value = stored field XOR xor. Set it to the default value so
;                 that zeroed storage (new game / old save) reads as the default
;   +10  count    number of choices (TBL entries); value is clamped below it
;   +12  load     &routine or 0. Fills the temp word (and may raise opt_count)
;   +14  change   &routine or 0. Runs after each D-pad step (live preview)
;   +16  commit   &routine or 0. Persists the temp word
;
; A zero handler selects the built-in packed-bits behaviour (OptLoadPacked /
; OptCommitPacked). Handlers are plain subroutines (end in RTS) invoked through
; OptCallHandler with X = D = actor id (COPs are allowed), 16-bit A/X/Y, and may
; clobber A, X and Y. Handler pointers are 2-byte (same bank as OptCallHandler),
; so a setting that needs handlers either keeps them in this file or reaches its
; own code with a JSL trampoline.
;
; The strings and TBL option table may live in any bank (no ?BANK needed). The
; renderer reads the temp word through the data bank, which is set to the
; string's own bank, and banks $00-$3F / $80-$BF all mirror WRAM $0000-$1FFF.
; This holds while the ROM stays at or below 4 MB (every bank < $40).
;
; =============================================================================
; DISPLAY HOOK
; =============================================================================
;
; OptionDisplayPrologue / OptionDisplayEpilogue form a fall-through code chain
; that runs at the end of every OptionsDrawAll, after the panels and all
; registered settings are drawn. Insert stubs between them with:
;
;     OptionDisplayPrologue+ {
;         COP [RunBg3Script] ( @my_extra_string )
;     }
;
; Stubs run with 16-bit A/X/Y and X = D = actor id (COPs allowed). They must
; leave X = actor id and must not end in RTS. The epilogue returns to the caller
; of OptionsDrawAll. As with registrations, put the hook splice at the END of
; the patch file.
;
; Persistent storage map (inside the saved WRAM block):
;   $0B24        Names (legacy, retranslation base): bit 0, 1 = English
;   $0B34-$0B39  button mapping
;   $0B3A        Text Speed (bits 0-1), Run Button (bits 2-3), Auto-Jewels (bit 4)
;
; All BG3 rendering goes through ConsoleStringRenderer. No direct writes to the
; BG3 buffer except OptClearSetting, which blanks a setting's two rows.

?BANK 02

?INCLUDE 'options_input_remap'
?INCLUDE 'system_strings'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'vblank_joypad'
?INCLUDE 'ConsoleStringRenderer'

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

; WRAM scratch (inside $0BD0-$0BFB, the same scratch zone the debug menu uses).
;   $0BD0-$0BDF  8 words: button display index per action row (TBL index into
;                ButtonDisplayTable: 0 = blank, 1 = A, 2 = B, 3 = X, 4 = Y,
;                5 = L, 6 = R)
;   $0BE0-$0BE9  5 words: setting temp values (see record +04)
;   $0BEA-$0BEF  6 bytes: button map preview buffer (options_input_remap)
;   $0BF0        byte offset of the currently selected record
;   $0BF2        number of choices of the current setting (opt_count)
;   $0BF4        bank byte of the string handed to OptRenderString
!opt_wram_base                  0BD0
!opt_temp_preset                0BE8
!opt_map                        0BEA
!opt_rec                        0BF0
!opt_count                      0BF2
!opt_str_bank                   0BF4

; Record field offsets (see SETTING REGISTRY)
!ro_render                      0000
!ro_desc                        0003
!ro_temp                        0006
!ro_store                       0008
!ro_shift                       000A
!ro_mask                        000C
!ro_xor                         000E
!ro_count                       0010
!ro_load                        0012
!ro_change                      0014
!ro_commit                      0016
!ro_stride                      0018

---------------------------------------------
; Console strings for the options menu.
;
; LAYOUT: BG3 text is drawn over the BG1 status background (bg1ConfigMode=0).
; The upper content panel (rows 4-14) is cleared with consolestring_01E8E2
; before drawing, to remove any residual BG3 content from other tabs.
;
; POS coordinate reference (POS:lo,hi → offset (hi<<8)|lo, 64 bytes per tile row):
;   Row 5, col 2 = $0104 → POS:04,1   (header line)
;   Row 7, col 3 = $01C6 → POS:C6,1   (first action row)
;   Row 22, col 11 = $0596 → POS:96,5 (description area)
; Settings start at row 5, col 19 (offset $0166) and advance 2 rows per setting.
optstr_pane |[PAL:0][POS:04,1]Button Mapping[N]--------------|

; Bottom-right description text
optstr_description |[PAL:0][POS:96,5]A to edit.[DBL]Assign buttons[DBL]to actions.|

; "Press a button..." prompt — replaces description during assignment mode
optstr_press_text |[PAL:0][POS:96,5]Press a[DBL]button...|

; Shown while a setting value is being edited
optstr_edit_hint |[PAL:0][POS:96,5]D-pad: change[DBL]A: confirm[DBL]B: cancel|

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
; Each is a 1-character console string used by optstr_rows_left.

btn_blank | |
BtnNameA   |A|
BtnNameB   |B|
BtnNameX   |X|
BtnNameY   |Y|
BtnNameL   |L|
BtnNameR   |R|

---------------------------------------------
; Action rows (left panel) rendered entirely through the ConsoleStringRenderer.
; Static action names are inline. One TBL lookup per row shows the
; assigned button letter, reading WRAM at $0BD0 + row*2.
;
; Row order matches ActionBitMasks: Confirm, Attack, Cancel, Use Item,
; Block, Block2, Run, Cycle Item.

optstr_rows_left |[PAL:0][POS:C6,1]\
Act/Confirm [TBL:@ButtonDisplayTable,BD0][N]\
Attack      [TBL:@ButtonDisplayTable,BD2][N]\
Cancel      [TBL:@ButtonDisplayTable,BD4][N]\
Use Item    [TBL:@ButtonDisplayTable,BD6][N]\
Block       [TBL:@ButtonDisplayTable,BD8][N]\
[PAL:14]Block2      [PAL:0][TBL:@ButtonDisplayTable,BDA][N]\
[PAL:14]Run         [PAL:0][TBL:@ButtonDisplayTable,BDC][N]\
[PAL:14]Cycle Item  [PAL:0][TBL:@ButtonDisplayTable,BDE]|

---------------------------------------------
; Btn. Preset — built-in setting (not persisted).
;
; Choices: Classic A, Classic B and, only while the live mapping matches
; neither, Custom. The record count is 2; OptPresetLoad raises opt_count to 3
; when the mapping is custom. Stepping previews the preset's buttons in the left
; panel; Confirm copies the preset into $0B34-$0B39, Cancel redraws from the
; untouched live mapping.

ButtonPresetOptions [
  &preset_classic_a
  &preset_classic_b
  &preset_custom
]

preset_classic_a |Classic A|
preset_classic_b |Classic B|
preset_custom    |Custom|

optstr_preset_render |[PAL:0]Btn. Preset[N] [PAL:14][TBL:@ButtonPresetOptions,BE8][PAL:0]|
optstr_preset_desc |[PAL:0][POS:96,5]Preset layouts for[DBL]all buttons.[DBL]A to choose.|

---------------------------------------------
; Setting registry (see header). Head word, then the records, then the
; delimiter. Btn. Preset is the built-in last record.

InventoryOptionSetups [
  #$0018                  ; record stride in bytes (records start after this word)
]

OptionSettingPreset [
  @optstr_preset_render   ;+00 render
  @optstr_preset_desc     ;+03 desc
  #$0BE8                  ;+06 temp
  #$0000                  ;+08 store (not persisted)
  #$0000                  ;+0A shift
  #$0000                  ;+0C mask
  #$0000                  ;+0E xor
  #$0002                  ;+10 count (OptPresetLoad adds Custom)
  &OptPresetLoad          ;+12 load
  &OptPresetChange        ;+14 change
  &OptPresetCommit        ;+16 commit
]

InventoryOptionSetupDelimiter #$FFFF

---------------------------------------------
; Cursor positions for SelectionCursorActor (X, Y pixel pairs) for the left
; panel. 8 rows at tile rows 7-14, spaced 8px (one tile row).
; X = 8px, one tile left of data column 3.
; Right panel cursors are computed (OptionsPositionCursor).
OptionsCursorPositions [
  screen-pos < #$0008, #$0045 >   ;00 row 7  Y=56
  screen-pos < #$0008, #$004D >   ;01 row 8  Y=64
  screen-pos < #$0008, #$0055 >   ;02 row 9  Y=72
  screen-pos < #$0008, #$005D >   ;03 row 10 Y=80
  screen-pos < #$0008, #$0065 >   ;04 row 11 Y=88
  screen-pos < #$0008, #$006D >   ;05 row 12 Y=96
  screen-pos < #$0008, #$0075 >   ;06 row 13 Y=104
  screen-pos < #$0008, #$007D >   ;07 row 14 Y=112
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
    LDA #$0000
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_description )
    JSR $&OptionsDrawAll
    LDA #$0001
    TSB $displayModeFlags
    RTL
}

---------------------------------------------
; OptionsTab — confirmed options tab. Full interactive menu.

OptionsTab {
    LDA #$0000
    STA $bg1ConfigMode
    JSR $&HideAllItemSlots
    JSR $&HideEquipCursor
    JSR $&HideStatusActors
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22

  opt_redraw:
    JSR $&OptionsDrawAll
    LDA #$0001
    TSB $displayModeFlags

  opt_position:
    JSR $&OptionsPositionCursor
    JSR $&OptShowDescription
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
; OptionsCursorUp — move cursor up. Left column rows 0-7, right column rows
; 8..(7+settings). Both columns wrap.

OptionsCursorUp {
    LDA #$0800
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    CMP #$0008
    BCS ocu_right
    DEC
    BPL ocu_store
    LDA #$0007
    BRA ocu_store

  ocu_right:
    DEC
    CMP #$0008
    BCS ocu_store
    JSR $&OptCountSettings
    CLC
    ADC #$0007

  ocu_store:
    STA $22
    JMP opt_position
}

---------------------------------------------
; OptionsCursorDown — move cursor down with wrap inside the current column.

OptionsCursorDown {
    LDA #$0400
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    CMP #$0008
    BCS ocd_right
    INC
    CMP #$0008
    BCC ocd_store
    LDA #$0000
    BRA ocd_store

  ocd_right:
    INC
    PHA
    JSR $&OptCountSettings
    CLC
    ADC #$0008
    STA $0000
    PLA
    CMP $0000
    BCC ocd_store
    LDA #$0008

  ocd_store:
    STA $22
    JMP opt_position
}

---------------------------------------------
; OptionsCursorLeft — from a setting, jump to the action row at a similar height.

OptionsCursorLeft {
    LDA #$0200
    TSB $joypadHeld
    LDA $22
    CMP #$0008
    BCC ocl_done
    COP [PlaySoundCh2] ( #10 )
    SEC
    SBC #$0008
    ASL
    SEC
    SBC #$0002
    BPL ocl_store
    LDA #$0000

  ocl_store:
    STA $22

  ocl_done:
    JMP opt_position
}

---------------------------------------------
; OptionsCursorRight — from an action row, jump to the setting at a similar height.

OptionsCursorRight {
    LDA #$0100
    TSB $joypadHeld
    LDA $22
    CMP #$0008
    BCS ocr_done
    COP [PlaySoundCh2] ( #10 )
    CLC
    ADC #$0002
    LSR
    STA $0000
    JSR $&OptCountSettings
    DEC
    CMP $0000
    BCC ocr_clamp
    LDA $0000

  ocr_clamp:
    CLC
    ADC #$0008
    STA $22

  ocr_done:
    JMP opt_position
}

---------------------------------------------
; OptionsRowConfirm — Confirm on the selected row. Action rows enter assignment
; mode; setting rows enter value editing.

OptionsRowConfirm {
    LDA $22
    CMP #$0008
    BCC orc_assign
    JMP $&OptionsSettingEdit

  orc_assign:
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

    ; Redraw everything (also re-detects the Btn. Preset value)
    JMP opt_redraw
}

---------------------------------------------
; OptionsSettingEdit — value editing for the setting under the cursor ($22 >= 8).
;
; The cursor drops one tile row onto the value text. Left/Up step backwards,
; Right/Down step forwards (wrapping at opt_count). Confirm commits through the
; record's commit handler, Cancel discards the temp value. Both leave through
; opt_redraw, which reloads every temp word from storage.

OptionsSettingEdit {
    LDA #$8000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )
    LDA $22
    SEC
    SBC #$0008
    JSR $&OptSelectSetting
    JSR $&OptLoadSetting

    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @optstr_edit_hint )

  ose_position:
    JSR $&OptionsPositionEditCursor
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$8000, &OptEditCommit )
    COP [BranchIfPressed] ( #$4000, &OptEditCancel )
    COP [BranchIfPressed] ( #$0200, &OptEditPrev )
    COP [BranchIfPressed] ( #$0800, &OptEditPrev )
    COP [BranchIfPressed] ( #$0100, &OptEditNext )
    COP [BranchIfPressed] ( #$0400, &OptEditNext )
    RTL
}

OptEditPrev {
    LDA #$0A00
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA #$FFFF
    JSR $&OptEditStep
    JMP ose_position
}

OptEditNext {
    LDA #$0500
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA #$0001
    JSR $&OptEditStep
    JMP ose_position
}

OptEditCommit {
    LDA #$8000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )
    JSR $&OptCommitSetting
    JMP opt_redraw
}

OptEditCancel {
    LDA #$4000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    JMP opt_redraw
}

---------------------------------------------
; OptEditStep — step the selected setting and redraw only its two rows.
; Entry: A = +1 or -1 ($FFFF). $0BF0 already selects the record.

OptEditStep {
    JSR $&OptStepSetting
    LDA $22
    SEC
    SBC #$0008
    JSR $&OptRenderSetting
    RTS
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
; OptionsPositionCursor — position the selection cursor actor on row $22.
; Rows 0-7: table lookup. Rows 8+: setting label row (X=$88, Y=$35 + 16*n).

OptionsPositionCursor {
    PHX
    LDY $20
    LDA $22
    CMP #$0008
    BCS opc_setting
    ASL
    ASL
    TAX
    LDA $@OptionsCursorPositions, X
    STA $0014, Y
    LDA $@OptionsCursorPositions+2, X
    STA $0016, Y
    BRA opc_done

  opc_setting:
    SEC
    SBC #$0008
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC #$0035
    STA $0016, Y
    LDA #$0088
    STA $0014, Y

  opc_done:
    PLX
    RTS
}

---------------------------------------------
; OptionsPositionEditCursor — cursor on the value row of the setting under edit
; (one tile row below its label, one tile right: X=$90, Y=$3D + 16*n).

OptionsPositionEditCursor {
    PHX
    LDY $20
    LDA $22
    SEC
    SBC #$0008
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC #$003D
    STA $0016, Y
    LDA #$0090
    STA $0014, Y
    PLX
    RTS
}

---------------------------------------------
; OptionsDrawAll — draw the left panel and every registered setting.

OptionsDrawAll {
    REP #$20
    LDA #$0000
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @optstr_pane )
    LDA #$0000
    JSR $&OptionsPrepareWram
    COP [RunBg3Script] ( @optstr_rows_left )

    JSR $&OptCountSettings
    BEQ oda_done
    PHA                         ; [S+3] setting count
    LDA #$0000
    PHA                         ; [S+1] current index

  oda_loop:
    LDA $01, S
    JSR $&OptSelectSetting
    JSR $&OptLoadSetting
    LDA $01, S
    JSR $&OptRenderSetting
    LDA $01, S
    INC
    STA $01, S
    CMP $03, S
    BCC oda_loop
    PLA
    PLA

  oda_done:
    JMP $&OptionDisplayPrologue
}

---------------------------------------------
; OptionDisplayPrologue / OptionDisplayEpilogue — display hook chain (see header).
; Contiguous blocks: stubs spliced in with OptionDisplayPrologue+ execute in
; order, and the epilogue returns to the caller of OptionsDrawAll.

OptionDisplayPrologue {
    REP #$20
}

OptionDisplayEpilogue {
    RTS
}

---------------------------------------------
; OptShowDescription — redraw the lower-right description for the cursor row.

OptShowDescription {
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDA $22
    CMP #$0008
    BCS osd_setting
    SEP #$20
    LDA #$^optstr_description
    STA $opt_str_bank
    REP #$20
    LDA #$&optstr_description
    BRA osd_draw

  osd_setting:
    SEC
    SBC #$0008
    JSR $&OptSelectSetting
    LDA #$ro_desc
    JSR $&OptRecLong

  osd_draw:
    LDY #$0000
    JSR $&OptRenderString
    RTS
}

---------------------------------------------
; OptRenderString — run ConsoleStringRenderer on a string in any bank.
;
; Entry: A = string pointer (word), $opt_str_bank = its bank byte,
;        Y = starting VRAM buffer offset (0 when the string carries its own
;        [POS]). The offset is also stored as the [N] anchor.
; Preserves X. Sets displayModeFlags bit 0 so BG3 is flushed.
; DBR is switched to the string's bank (the renderer reads TBL temp words
; through DBR, which reaches WRAM $0000-$1FFF in banks $00-$3F and $80-$BF).

OptRenderString {
    PHP
    REP #$20
    PHX
    PHD
    PHB
    STY $09A0
    TYX
    TAY
    SEP #$20
    LDA $opt_str_bank
    PHA
    PLB
    REP #$20
    LDA #$0000
    TCD
    JSL $@ConsoleStringRenderer
    PLB
    PLD
    PLX
    LDA #$0001
    TSB $displayModeFlags
    PLP
    RTS
}

---------------------------------------------
; OptRenderSetting — clear and redraw one setting.
; Entry: A = setting index. Leaves $0BF0 selecting that record.

OptRenderSetting {
    PHX
    PHY
    PHA
    JSR $&OptSelectSetting
    PLA
    XBA
    LSR                         ; index * $80 (two tile rows)
    CLC
    ADC #$0166                  ; row 5, col 19
    TAY
    JSR $&OptClearSetting
    LDA #$ro_render
    JSR $&OptRecLong
    JSR $&OptRenderString
    PLY
    PLX
    RTS
}

---------------------------------------------
; OptClearSetting — blank 12 tiles on both rows of a setting.
; Entry: Y = VRAM buffer offset of the label row start.

OptClearSetting {
    PHX
    PHY
    TYX
    LDY #$000C
    LDA #$0000

  ocs_loop:
    STA $7F0200, X
    STA $7F0240, X
    INX
    INX
    DEY
    BNE ocs_loop
    PLY
    PLX
    RTS
}

---------------------------------------------
; OptCountSettings — number of registered settings (clamped to the 5 the panel
; can show). Exit: A = count, Z set when there are none.

OptCountSettings {
    PHX
    PHY
    LDX #$0002              ; skip the head word
    LDY #$0000

  ocn_loop:
    LDA $@InventoryOptionSetups, X
    CMP #$FFFF
    BEQ ocn_done
    INY
    TXA
    CLC
    ADC #$ro_stride
    TAX
    BRA ocn_loop

  ocn_done:
    TYA
    CMP #$0005
    BCC ocn_return
    LDA #$0005

  ocn_return:
    PLY
    PLX
    CMP #$0000
    RTS
}

---------------------------------------------
; OptSelectSetting — select a record. Entry: A = index.
; Sets $0BF0 = 2 + index * 24 (offset into InventoryOptionSetups, past the head word).

OptSelectSetting {
    PHX
    ASL
    ASL
    ASL                         ; 8n
    STA $0000
    ASL                         ; 16n
    CLC
    ADC $0000                   ; 24n
    ADC #$0002                  ; skip the head word
    STA $opt_rec
    PLX
    RTS
}

---------------------------------------------
; OptRecWord — read one word of the selected record.
; Entry: A = field offset (ro_*). Exit: A = word. Preserves X.
; Flags are NOT meaningful afterwards (compare explicitly).

OptRecWord {
    PHX
    CLC
    ADC $opt_rec
    TAX
    LDA $@InventoryOptionSetups, X
    PLX
    RTS
}

---------------------------------------------
; OptRecLong — read a 3-byte pointer field of the selected record.
; Entry: A = field offset (ro_render / ro_desc).
; Exit:  A = pointer word, $opt_str_bank = bank byte. Preserves X and Y.

OptRecLong {
    PHX
    CLC
    ADC $opt_rec
    TAX
    INX
    INX
    SEP #$20
    LDA $@InventoryOptionSetups, X
    STA $opt_str_bank
    REP #$20
    DEX
    DEX
    LDA $@InventoryOptionSetups, X
    PLX
    RTS
}

---------------------------------------------
; OptCallHandler — call a record handler.
; Entry: A = handler address (bank-02 subroutine ending in RTS).
; Restores X = D (the actor id) first so handlers may use COPs. The handler's
; RTS returns straight to the caller of OptCallHandler.

OptCallHandler {
    PHA
    TDC
    TAX
    PLA
    DEC
    PHA
    RTS
}

---------------------------------------------
; OptLoadSetting — refresh the selected setting's temp word from storage.
; Also resets opt_count to the record's count (handlers may raise it).

OptLoadSetting {
    PHX
    LDA #$ro_count
    JSR $&OptRecWord
    STA $opt_count
    LDA #$ro_load
    JSR $&OptRecWord
    CMP #$0000
    BEQ ols_packed
    JSR $&OptCallHandler
    BRA ols_done

  ols_packed:
    JSR $&OptLoadPacked

  ols_done:
    PLX
    RTS
}

---------------------------------------------
; OptCommitSetting — persist the selected setting's temp word.

OptCommitSetting {
    PHX
    LDA #$ro_commit
    JSR $&OptRecWord
    CMP #$0000
    BEQ ocm_packed
    JSR $&OptCallHandler
    BRA ocm_done

  ocm_packed:
    JSR $&OptCommitPacked

  ocm_done:
    PLX
    RTS
}

---------------------------------------------
; OptStepSetting — move the temp value by A (+1 / -1), wrapping inside
; opt_count, then run the record's change handler.

OptStepSetting {
    PHX
    STA $0000                   ; step direction
    LDA #$ro_temp
    JSR $&OptRecWord
    TAX                         ; X = temp word address
    LDA $0000, X
    CLC
    ADC $0000
    BPL oss_high
    LDA $opt_count              ; stepped below zero: wrap to the last choice
    DEC
    BRA oss_store

  oss_high:
    CMP $opt_count
    BCC oss_store
    LDA #$0000                  ; stepped past the last choice: wrap to zero

  oss_store:
    STA $0000, X
    LDA #$ro_change
    JSR $&OptRecWord
    CMP #$0000
    BEQ oss_done
    JSR $&OptCallHandler

  oss_done:
    PLX
    RTS
}

---------------------------------------------
; OptLoadPacked — default load: temp = ((storage >> shift) & mask) XOR xor,
; forced to 0 when it is not below opt_count.

OptLoadPacked {
    LDA #$ro_store
    JSR $&OptRecWord
    STA $0000                   ; storage address
    LDA #$ro_temp
    JSR $&OptRecWord
    STA $0002                   ; temp address
    LDA #$ro_shift
    JSR $&OptRecWord
    STA $0004
    LDA #$ro_mask
    JSR $&OptRecWord
    STA $0006
    LDA #$ro_xor
    JSR $&OptRecWord
    STA $0008

    PHX
    LDX $0000
    LDA $0000, X                ; storage word (neighbour bits are masked off)
    LDY $0004
    BEQ olp_shifted

  olp_shift:
    LSR
    DEY
    BNE olp_shift

  olp_shifted:
    AND $0006
    EOR $0008
    CMP $opt_count
    BCC olp_store
    LDA #$0000

  olp_store:
    LDX $0002
    STA $0000, X
    PLX
    RTS
}

---------------------------------------------
; OptCommitPacked — default commit: write ((temp XOR xor) & mask) << shift into
; the storage byte, leaving the other bits of that byte untouched.

OptCommitPacked {
    LDA #$ro_store
    JSR $&OptRecWord
    STA $0000                   ; storage address
    LDA #$ro_temp
    JSR $&OptRecWord
    STA $0002                   ; temp address
    LDA #$ro_shift
    JSR $&OptRecWord
    STA $0004
    LDA #$ro_mask
    JSR $&OptRecWord
    STA $0006
    LDA #$ro_xor
    JSR $&OptRecWord
    STA $0008

    PHX
    LDX $0002
    LDA $0000, X                ; temp value
    EOR $0008
    AND $0006
    LDY $0004
    BEQ ocp_value_ready

  ocp_value_shift:
    ASL
    DEY
    BNE ocp_value_shift

  ocp_value_ready:
    STA $000A                   ; new field bits, already shifted
    LDA $0006
    LDY $0004
    BEQ ocp_mask_ready

  ocp_mask_shift:
    ASL
    DEY
    BNE ocp_mask_shift

  ocp_mask_ready:
    EOR #$FFFF
    STA $000C                   ; inverted shifted mask
    LDX $0000
    SEP #$20
    LDA $0000, X
    AND $000C
    ORA $000A
    STA $0000, X
    REP #$20
    PLX
    RTS
}

---------------------------------------------
; Btn. Preset handlers (registered record at the top of this file).
;
; temp ($0BE8): 0 = Classic A, 1 = Classic B, 2 = Custom.

OptPresetLoad {
    JSL $@options_input_remap.DetectPreset
    STA $opt_temp_preset
    CMP #$0002
    BCC opl_done
    LDA #$0003                  ; live mapping is custom: offer the Custom choice
    STA $opt_count

  opl_done:
    RTS
}

; Preview the highlighted preset in the left panel. Custom shows the player's
; own mapping again.
OptPresetChange {
    LDA $opt_temp_preset
    CMP #$0002
    BCS opch_live
    INC                         ; 0 -> source 1 (Classic A), 1 -> source 2 (Classic B)
    BRA opch_draw

  opch_live:
    LDA #$0000

  opch_draw:
    JSR $&OptionsPrepareWram
    COP [RunBg3Script] ( @optstr_rows_left )
    RTS
}

; Classic A/B overwrite the live mapping; Custom leaves it untouched.
OptPresetCommit {
    LDA $opt_temp_preset
    CMP #$0002
    BCS opcm_done
    JSL $@options_input_remap.SetButtonPreset
    JSL $@options_input_remap.ApplyButtonMapping

  opcm_done:
    RTS
}

---------------------------------------------
; OptionsPrepareWram — populate WRAM with button display indices.
;
; Entry: A = mapping source (see LoadButtonMapPreview): 0 = live mapping,
;            1 = Classic A, 2 = Classic B.
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

    REP #$20
    JSL $@options_input_remap.LoadButtonMapPreview

    STZ $0004              ; $04 = WRAM output offset (0, 2, 4, ..., 14)
    LDX #$0000            ; X = row index (0..7)
    SEP #$20

  opw_row:
    LDA $@ActionBitMasks, X
    STA $0000              ; $0000 = action bit mask for this row
    STX $0006              ; save row index

    LDY #$0000             ; Y = button index (0..5)

  opw_btn:
    LDA $opt_map, Y        ; preview byte for this button
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
