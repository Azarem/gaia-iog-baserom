; Diary/save menu system — scene $FA title screen menu with save management and settings.
; 
; Implements four menu tabs accessed from the title screen's Start button:
; 1. Start Journey (code_0BE354) — load a saved game from one of 3 diary slots
; 2. Erase Trip Diary (code_0BEA55) — delete a save slot with confirmation
; 3. Copy Trip Diary (DiaryCopyTab) — copy one diary to an empty slot
; 4. Change Snd/Buttons (DiarySndBtnTab) — toggle stereo/mono and button remapping
; 
; === DISPLAY SETUP ===
; 
; Uses Mode 7 scrolling for the diary background. TM=$01 (BG1), TS=$04 (BG3 sub).
; Color math: CGWSEL=$82 (sub=fixed, always apply), CGADSUB=$41 (add BG1+backdrop).
; Window registers: W34SEL=$88, WOBJSEL=$22 for dialogue box masking.
; Camera positioned at ($80, $300) for the Mode 7 perspective view.
; 
; === DIARY STATE BLOCK ($0D74–$0D98) ===
; 
; | Address | Purpose |
; |---------|---------|
; | $0D74/76/78 | Scene IDs for slots 1/2/3 (0 = empty) |
; | $0D7A/7C/7E | Max HP values for slots 1/2/3 |
; | $0D80/82/84 | STR values for slots 1/2/3 |
; | $0D86/88/8A | DEF values for slots 1/2/3 |
; | $0D8C | Active save slot (0–2, stored in SRAM $306000) |
; | $0D8E | Button type toggle (0=layout A, 1=layout B) |
; | $0D90 | Sound mode toggle (0=stereo, 1=mono) |
; | $0D92 | Current menu cursor position |
; | $0D94 | Selected slot for copy/erase operations |
; | $0D96 | Target slot for copy operation |
; | $0D98 | Sub-menu cursor / tab selection |
; 
; === SRAM LAYOUT ===
; 
; $306000: Active slot number (0–2)
; $306200 + (slot × 512): Event flag data (508 bytes)
; $3063FC + (slot × 4): Dual checksums (additive + XOR, seeded with $3652)
; 
; === BUTTON REMAP ===
; 
; Two button layouts stored in $0B26:
; - Layout A (0): A=confirm($8000), B=cancel($4000), Y=item palette($0040)
; - Layout B (1): Default engine mapping (no remap)
; 
; DiaryMenuVBlankHandler provides a custom VBlank handler that reads raw joypad input and applies
; the remap table to produce joypadCurrent. Also handles Mode 7 register writes and
; auto-repeat timing (12-frame threshold).
---------------------------------------------

?BANK 0B

?INCLUDE 'oam_digit_compose'
?INCLUDE 'save_system'
?INCLUDE 'strings_0BF706'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!sceneNext                      0642
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!scrollModeFlags                06EF
!playerActor                    09AA
!joypadInject                   09AC
!playerFlags                    09AE
!displayModeFlags               09EC
!remapSelect                    0DA6
!remapX                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapStart                     0DB0
!remapL                         0DB2
!remapR                         0DB4
!M7A                            211B
!M7B                            211C
!M7C                            211D
!M7D                            211E
!M7X                            211F
!M7Y                            2120
!W34SEL                         2124
!WOBJSEL                        2125
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!APUIO0                         2140
!JOY2L                          421A
!animScratch                    7F0000
!cgramPalette                   7F0A00
!scratch1010                    7F1010
!free101C                       7F101C
!L_RDNMI                        804210

---------------------------------------------

sFA_diary_menu [
  actor-def < #00, #00, #28, {

  DiaryMenuInit:
    LDA #$0000            ; Clear CGRAM
    STA $cgramPalette
    SEP #$20
    STA $TM               ; Disable all layers initially
    REP #$20
    LDA #$FFFF            ; Initialize cursor states to "none"
    STA $0D92
    STA $0D96
    STA $0D98
    LDA #$4001            ; Bits 14+0: menu display mode
    TSB $displayModeFlags
    SEP #$20
    LDA #$88              ; Window 3/4 config for dialogue masking
    STA $W34SEL
    LDA #$22              ; OBJ window config
    STA $WOBJSEL
    REP #$20
    LDA #$0000
    STA $cgramPalette
    STA $0B04             ; Clear saved frame delay
    LDA #$0001
    STA $00EE             ; Enable menu mode flag
    SEP #$20
    LDA #$01              ; BG1 on main screen
    STA $TM
    LDA #$04              ; BG3 on sub screen (text overlay)
    STA $TS
    LDA #$82              ; Sub=fixed color, math always
    STA $CGWSEL
    LDA #$41              ; Add BG1 + backdrop
    STA $CGADSUB
    REP #$20
    LDA #$0080            ; Camera X = 128 (Mode 7 center)
    STA $bg1ScrollH
    STA $cameraTargetX
    LDA #$0300            ; Camera Y = 768 (Mode 7 perspective)
    STA $bg2ScrollH
    STA $cameraTargetY
    LDA #$3000            ; Mask L+R shoulder buttons
    TSB $joypadMaskStd
    LDA #$2800            ; Set running + ability-active flags
    TSB $playerFlags
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC ) ; Draw BG3 text overlay
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 ) ; "Start Journey / Erase / Copy / Change"
    JSR $&DiaryScanSramSlots ; Scan SRAM: validate checksums, read slot data
    LDA #$0F00            ; Enable auto-repeat on D-pad
    STA $joypadMaskInv
    STZ $18               ; Clear frame counter
    COP [SetEntryContinue]
    LDA $worldReadyFlag
    BNE loc_0BE2CA
    RTL 

  loc_0BE2CA:
    BRA loc_0BE2D0
} >
]
---------------------------------------------

DiaryMainMenuEntry {
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 )

  loc_0BE2D0:
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D98

  DiaryTabSelectLoop:
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0800, &DiaryTabCursorUp ) ; Up → previous tab
    COP [BranchIfButton] ( #$0400, &DiaryTabCursorDown ) ; Down → next tab
    COP [BranchIfButton] ( #$0080, &DiaryTabConfirm ) ; A → confirm selection
    RTL 
}

DiaryTabCursorUp {
    COP [PlaySoundCh2] ( #10 ) ; Cursor move SFX
    LDA $0D98
    DEC 
    BPL loc_0BE302
    LDA #$0003            ; Wrap to bottom

  loc_0BE302:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryTabCursorDown {
    COP [PlaySoundCh2] ( #10 ) ; Cursor move SFX
    LDA $0D98
    INC 
    CMP #$0004
    BCC loc_0BE31E
    LDA #$0000            ; Wrap to top

  loc_0BE31E:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryTabConfirm {
    COP [PlaySoundCh2] ( #11 ) ; Confirm SFX
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    AND #$0003
    STA $0000
    LDA #$FFFF
    STA $0D98
    COP [SwitchCase] ( #$0000, &code_list_0BE34C )
}

code_list_0BE34C [
  &DiaryStartJourney   ;00
  &DiaryEraseTab   ;01
  &DiaryCopyTab   ;02
  &DiarySndBtnTab   ;03
]

DiaryStartJourney {
    JSR $&DiaryMenuClearVram ; Clear VRAM buffer
    COP [PrintDialogStringAlt] ( &dialogstring_0BF437 ) ; "Which Diary?" with 3 slots
    COP [CallScript] ( &DiaryRenderSlotStats ) ; Draw slot stats (HP/STR/DEF)
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D8C             ; Last used slot
    AND #$0003
    STA $0D92             ; Pre-select it

  DiaryStartSlotLoop:
    COP [SetEntryExit]
    LDA #$000C            ; 12 frames per camera pan step
    STA $free101C, X
    COP [CallScript] ( &DiaryCameraPan ) ; Animate camera pan to slot position
    COP [SetEntryContinueDeferred] ( @DiaryStartSlotLoop )
    COP [BranchIfButton] ( #$0800, &DiaryStartSlotUp ) ; Up → previous slot
    COP [BranchIfButton] ( #$0400, &DiaryStartSlotDown ) ; Down → next slot
    COP [BranchIfButton] ( #$0080, &DiaryStartLoadConfirm ) ; A → confirm slot
    COP [BranchIfButton] ( #$8000, &DiaryStartCancel ) ; B → cancel, return to main menu
    RTL 
}

DiaryStartSlotUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE3A4
    LDA #$0002

  loc_0BE3A4:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryStartSlotDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE3C0
    LDA #$0000

  loc_0BE3C0:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryStartCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

DiaryStartLoadConfirm {
    COP [PlaySoundCh2] ( #11 ) ; Confirm SFX
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92             ; Selected slot
    STA $0D8C             ; Set as active slot
    LDA #$FFFF
    STA $0D92
    LDA $0D8C
    STA $306000           ; Write active slot to SRAM
    JSL $@save_system.LoadGameState_Scene ; Load event flags from SRAM
    BCS loc_0BE433        ; Carry set → corrupt/empty slot
    JSR $&ApplySoundAndRemap ; Apply sound mode + button remap
    LDA $0AB2             ; Restore Dark Space layout variant
    STA $0AAC
    LDA #$00E6            ; Scene $E6 = Dark Space
    STA $sceneNext
    LDA #$0078            ; Camera X = 120px
    STA $064C
    LDA #$0090            ; Camera Y = 144px
    STA $064E
    LDA #$0003            ; Transition flags
    STA $0650
    LDA #$1100            ; Transition auxiliary data
    STA $0652
    LDA #$2800            ; Clear running + ability flags
    TRB $playerFlags
    COP [Die]             ; Kill menu actor → scene transition fires

; Load failed (corrupt/empty slot) — show settings arrangement screen instead.
; Presents sound/button config for a new game start.

  loc_0BE433:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D8E
    STA $0D90
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF5AD )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D98

  DiaryNewGameSettingsLoop:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &DiarySettingsToggle )
    COP [BranchIfButton] ( #$0800, &DiarySettingsUp )
    COP [BranchIfButton] ( #$0400, &DiarySettingsDown )
    COP [BranchIfButton] ( #$8000, &DiaryNewGameCancel )
    RTL 
}

DiaryNewGameCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    STA $0D92
    JMP $&DiaryStartJourney
}

DiarySettingsToggle {
    LDA #$0380
    TSB $joypadHeld
    LDA $0D98
    BEQ loc_0BE4E7
    DEC 
    BNE loc_0BE4C5
    COP [PlaySoundCh2] ( #0D )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&DiaryNewGameSettingsLoop

  loc_0BE4C5:
    DEC 
    BNE loc_0BE4E7
    COP [PlaySoundCh2] ( #0D )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&DiaryNewGameSettingsLoop

  loc_0BE4E7:
    COP [BranchIfButton] ( #$0080, &DiaryNewGameStart )
    RTL 
}

DiaryNewGameStart {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D90             ; Save sound mode to persistent storage
    STA $0B24
    LDA $0D8E             ; Save button layout to persistent storage
    STA $0B26
    JSR $&ApplySoundAndRemap ; Apply sound + button remap
    LDA #$0008            ; Scene $08 = game opening
    STA $sceneNext
    COP [QueueMapChange] ( #08, #$0050, #$00A0, #00, #$1200 ) ; Start at ($50,$A0)
    LDA #$2800            ; Clear flags
    TRB $playerFlags
    COP [Die]
}

DiaryCameraPan {
    PHX 
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    ASL 
    TAX 
    LDA $@strings_0BF706, X
    SEC 
    SBC #$&strings_0BF706
    TAX 
    SEP #$20

  loc_0BE53D:
    LDA $@strings_0BF706, X
    INX 
    CMP #$CA
    BNE loc_0BE53D
    REP #$20
    LDA $@strings_0BF706, X
    TAY 
    LDA $@strings_0BF706+2, X
    PLX 
    STA $7F100E, X
    TYA 
    STA $7F100C, X
    SEC 
    SBC $cameraTargetX
    BMI loc_0BE56E
    STA $7F100C, X
    LDA #$0001
    STA $animScratch, X
    BRA loc_0BE57D

  loc_0BE56E:
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA #$FFFF
    STA $animScratch, X

  loc_0BE57D:
    LDA $7F100E, X
    SEC 
    SBC $cameraTargetY
    BMI loc_0BE596
    STA $7F100E, X
    BEQ loc_0BE590
    LDA #$0001

  loc_0BE590:
    STA $animScratch+2, X
    BRA loc_0BE5A7

  loc_0BE596:
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BEQ loc_0BE5A3
    LDA #$FFFF

  loc_0BE5A3:
    STA $animScratch+2, X

  loc_0BE5A7:
    LDA $7F100C, X
    CMP $7F100E, X
    BCC loc_0BE612
    LDA $7F100C, X
    BEQ loc_0BE610
    STA $scratch1010+4, X
    LSR 
    STA $scratch1010, X
    LDA $7F100E, X
    STA $scratch1010+2, X
    COP [SetEntryContinue]
    LDA $free101C, X
    STA $0000

  loc_0BE5D1:
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    LDA $scratch1010, X
    SEC 
    SBC $scratch1010+2, X
    STA $scratch1010, X
    BPL loc_0BE5FF
    CLC 
    ADC $7F100C, X
    STA $scratch1010, X
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY

  loc_0BE5FF:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE610
    DEC $0000
    BNE loc_0BE5D1
    RTL 

  loc_0BE610:
    COP [RestoreSavedPtr]

  loc_0BE612:
    LDA $7F100E, X
    BEQ loc_0BE671
    STA $scratch1010+4, X
    LSR 
    STA $scratch1010+2, X
    LDA $7F100C, X
    STA $scratch1010, X
    COP [SetEntryContinue]
    LDA $free101C, X
    STA $0000

  loc_0BE632:
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    LDA $scratch1010+2, X
    SEC 
    SBC $scratch1010, X
    STA $scratch1010+2, X
    BPL loc_0BE660
    CLC 
    ADC $7F100E, X
    STA $scratch1010+2, X
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX

  loc_0BE660:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE671
    DEC $0000
    BNE loc_0BE632
    RTL 

  loc_0BE671:
    COP [RestoreSavedPtr]
}
---------------------------------------------

ApplySoundAndRemap {
    LDA #$0000
    STA $0B04             ; Clear frame delay
    STZ $00EE             ; Clear menu mode flag
    LDA $0B24             ; Sound mode from save
    BNE loc_0BE68C        ; Nonzero → mono
    SEP #$20
    LDA #$91              ; SPC command: stereo mode
    STA $APUIO0
    REP #$20
    BRA loc_0BE695

  loc_0BE68C:
    SEP #$20
    LDA #$90              ; SPC command: mono mode
    STA $APUIO0
    REP #$20

  loc_0BE695:
    LDA $0B26             ; Button layout from save
    BNE loc_0BE6B3        ; Nonzero → layout B (no remap)
    LDA #$8000            ; Layout A: remap A→B (confirm=$8000)
    STA $remapA
    LDA #$4000            ; Layout A: remap B→Y (cancel=$4000)
    STA $remapB
    LDA #$0000
    STA $remapStart
    LDA #$0040            ; Layout A: remap Y→X (item palette=$0040)
    STA $remapY
    RTS 

  loc_0BE6B3:
    LDA #$0000            ; Layout B: clear Start remap only
    STA $remapStart
    RTS 
}
---------------------------------------------

DiarySndBtnTab {
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF476 )
    COP [CallScript] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D92

  DiarySndBtnSlotLoop:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &DiaryEraseSlotUp )
    COP [BranchIfButton] ( #$0400, &DiaryEraseSlotDown )
    COP [BranchIfButton] ( #$0080, &DiarySndBtnSlotConfirm )
    COP [BranchIfButton] ( #$8000, &DiarySndBtnCancel )
    RTL 
}

DiarySndBtnCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

DiarySndBtnSlotConfirm {
    COP [PlaySoundCh2] ( #12 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE714
    RTL 

  loc_0BE714:
    COP [PlaySoundCh2] ( #11 )
    LDA $0D92
    STA $0D94
    JSR $&ReadSramSettings
    LDA #$FFFF
    STA $0D92
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF538 )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D98

  DiarySndBtnEditLoop:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &DiarySndBtnOptionToggle )
    COP [BranchIfButton] ( #$0800, &DiarySettingsUp )
    COP [BranchIfButton] ( #$0400, &DiarySettingsDown )
    COP [BranchIfButton] ( #$8000, &DiarySndBtnEditCancel )
    RTL 
}

DiarySettingsUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    DEC 
    BPL loc_0BE770
    LDA #$0002

  loc_0BE770:
    STA $0D98
    RTL 
}

DiarySettingsDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    INC 
    CMP #$0003
    BCC loc_0BE78C
    LDA #$0000

  loc_0BE78C:
    STA $0D98
    RTL 
}

DiarySndBtnEditCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    JMP $&DiarySndBtnTab
}

DiarySndBtnOptionToggle {
    LDA $0D98
    BEQ loc_0BE7EE
    DEC 
    BNE loc_0BE7CC
    COP [PlaySoundCh2] ( #10 )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&DiarySndBtnEditLoop

  loc_0BE7CC:
    DEC 
    BNE loc_0BE7EE
    COP [PlaySoundCh2] ( #10 )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&DiarySndBtnEditLoop

  loc_0BE7EE:
    COP [BranchIfButton] ( #$0080, &DiarySndBtnSaveConfirm )
    RTL 
}

DiarySndBtnSaveConfirm {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    JSR $&WriteSramSettings
    PHX 
    LDA $0D94
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum
    LDA $0018
    STA $3063FC, X
    LDA $001C
    STA $3063FE, X
    PLX 
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF476 )
    COP [CallScript] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D94
    STA $0D92
    JMP $&DiarySndBtnSlotLoop
}
---------------------------------------------

ReadSramSettings {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002
    BCC loc_0BE85C
    LDA #$0000

  loc_0BE85C:
    STA $0D90
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002
    BCC loc_0BE876
    LDA #$0000

  loc_0BE876:
    STA $0D8E
    PLX 
    PLX 
    RTS 
}
---------------------------------------------

WriteSramSettings {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D90
    STA $306200, X
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D8E
    STA $306200, X
    PLX 
    PLX 
    RTS 
}
---------------------------------------------

DiaryCopyTab {
    LDA $0D74             ; Check if all slots occupied
    BEQ loc_0BE8D4        ; Slot 1 empty → proceed
    LDA $0D76
    BEQ loc_0BE8D4        ; Slot 2 empty → proceed
    LDA $0D78
    BEQ loc_0BE8D4        ; Slot 3 empty → proceed
    LDA #$0002
    STA $0D98
    STZ $00EE
    COP [PrintDialogStringAlt] ( &dialogstring_0BF679 )
    LDA #$0001
    STA $00EE
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 )
    JMP $&DiaryTabSelectLoop

  loc_0BE8D4:
    JSR $&DiaryMenuClearVram
    LDA #$0000
    STA $0D92

  DiaryCopySourceLoop:
    COP [PrintDialogStringAlt] ( &dialogstring_0BF48C )
    COP [CallScript] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &DiaryCopySourceUp )
    COP [BranchIfButton] ( #$0400, &DiaryCopySourceDown )
    COP [BranchIfButton] ( #$0080, &DiaryCopySourceConfirm )
    COP [BranchIfButton] ( #$8000, &DiaryCopyCancel )
    RTL 
}

DiaryCopySourceUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE911
    LDA #$0002

  loc_0BE911:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryCopySourceDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE92D
    LDA #$0000

  loc_0BE92D:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryCopyCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA #$8000
    TSB $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

DiaryCopySourceConfirm {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE960
    RTL 

  loc_0BE960:
    LDY #$0000

  loc_0BE963:
    LDA $0D74, Y
    BEQ loc_0BE972
    INY 
    INY 
    CPY #$0006
    BCC loc_0BE963
    BNE loc_0BE972
    RTL 

  loc_0BE972:
    TYA 
    LSR 
    STA $0D96
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &DiaryCopyTargetUp )
    COP [BranchIfButton] ( #$0400, &DiaryCopyTargetDown )
    COP [BranchIfButton] ( #$0080, &DiaryCopyExecute )
    COP [BranchIfButton] ( #$8000, &DiaryCopyTargetCancel )
    RTL 
}

DiaryCopyTargetUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE998:
    DEC 
    BPL loc_0BE99E
    LDA #$0002

  loc_0BE99E:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE998
    ASL 
    TAY 
    LDA $0D74, Y
    BNE DiaryCopyTargetUp
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryCopyTargetDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE9BD:
    INC 
    CMP #$0003
    BCC loc_0BE9C6
    LDA #$0000

  loc_0BE9C6:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE9BD
    ASL 
    TAY 
    LDA $0D74, Y
    BNE DiaryCopyTargetDown
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryCopyTargetCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    LDA #$FFFF
    STA $0D96
    JMP $&DiaryCopySourceLoop
}

DiaryCopyExecute {
    LDA $0D96
    ASL 
    TAY 
    LDA $0D74, Y
    BEQ loc_0BEA04
    JMP $&DiaryCopySourceConfirm

  loc_0BEA04:
    COP [PlaySoundCh2] ( #29 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    PHX 
    LDA $0D92
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAX 
    LDA $0D96
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAY 
    SEP #$20
    LDA #$30
    STA $0405
    LDA #$30
    STA $0404
    REP #$20
    LDA #$01FF
    JSR $0402
    PLX 
    LDA $0D96
    STA $0D92
    LDA #$FFFF
    STA $0D96
    JSR $&DiaryScanSramSlots
    JSR $&DiaryMenuClearVram
    JMP $&DiaryCopySourceLoop
}

DiaryEraseTab {
    JSR $&DiaryMenuClearVram

  DiaryEraseSelectLoop:
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4A7 )
    COP [CallScript] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D92

  DiaryEraseInputLoop:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &DiaryEraseSlotUp )
    COP [BranchIfButton] ( #$0400, &DiaryEraseSlotDown )
    COP [BranchIfButton] ( #$0080, &DiaryEraseSlotConfirm )
    COP [BranchIfButton] ( #$8000, &DiaryEraseCancel )
    RTL 
}

DiaryEraseSlotUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BEA92
    LDA #$0002

  loc_0BEA92:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryEraseSlotDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BEAAE
    LDA #$0000

  loc_0BEAAE:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

DiaryEraseCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

DiaryEraseSlotConfirm {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BEAF0
    COP [PlaySoundCh2] ( #12 )
    LDA $0D92
    JSL $@save_system.ClearSaveSlot
    JMP $&DiaryEraseInputLoop

  loc_0BEAF0:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF6B3 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D94
    ASL 
    TAY 
    LDA $0D7A, Y
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9A
    LDA $0D80, Y
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9E
    LDA $0D86, Y
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9C
    COP [PrintDialogStringAlt] ( &dialogstring_0BF6A4 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$4000
    STA $remapB
    STZ $remapY
    COP [DialogueOptions] ( #02, #03, &code_list_0BEB46 )
}

code_list_0BEB46 [
  &DiaryEraseDecline   ;00
  &DiaryEraseDecline   ;01
  &DiaryEraseExecute   ;02
]

DiaryEraseDecline {
    LDA #$8000
    TSB $joypadHeld
    LDA #$8000
    STA $remapB
    LDA #$4000
    STA $remapY
    JMP $&DiaryEraseTab
}

DiaryEraseExecute {
    LDA #$8000
    STA $remapB
    LDA #$4000
    STA $remapY
    COP [PlaySoundCh2] ( #13 )
    COP [SetEntryContinue]
    LDA $0D94
    JSL $@save_system.ClearSaveSlot
    COP [WaitByte] ( #1D )
    LDA $1C
    STA $1A
    STZ $1C
    JSR $&DiaryMenuClearVram
    JSR $&DiaryScanSramSlots
    JMP $&DiaryEraseSelectLoop
}

DiaryRenderSlotStats {
    LDA $0D74
    BEQ loc_0BEBAF
    LDA $0D7A
    JSR $&FormatBcdNumber
    STA $0D9A
    LDA $0D80
    JSR $&FormatBcdNumber
    STA $0D9E
    LDA $0D86
    JSR $&FormatBcdNumber
    STA $0D9C
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4C3 )

  loc_0BEBAF:
    LDA $0D76
    BEQ loc_0BEBD3
    LDA $0D7C
    JSR $&FormatBcdNumber
    STA $0D9A
    LDA $0D82
    JSR $&FormatBcdNumber
    STA $0D9E
    LDA $0D88
    JSR $&FormatBcdNumber
    STA $0D9C
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4EA )

  loc_0BEBD3:
    LDA $0D78
    BEQ loc_0BEBF7
    LDA $0D7E
    JSR $&FormatBcdNumber
    STA $0D9A
    LDA $0D84
    JSR $&FormatBcdNumber
    STA $0D9E
    LDA $0D8A
    JSR $&FormatBcdNumber
    STA $0D9C
    COP [PrintDialogStringAlt] ( &dialogstring_0BF511 )

  loc_0BEBF7:
    COP [RestoreSavedPtr]
}
---------------------------------------------

DiaryMenuClearVram {
    PHP 
    PHX 
    PHD 
    SEP #$20
    JSL $@vram_buffer_clear.ClearVramBufferFull
    PLX 
    PLD 
    PLP 
    RTS 
}
---------------------------------------------

DiaryCursorNav_noref {
    COP [BranchIfButton] ( #$8000, &DiaryCursorConfirm )
    COP [BranchIfButton] ( #$6040, &DiaryCursorCancel )
    COP [BranchIfButton] ( #$0800, &DiaryCursorMoveUp )
    COP [BranchIfButton] ( #$0400, &DiaryCursorMoveDown )
    LDA $14
    CMP #$0002
    BCS loc_0BEC31
    COP [BranchIfButton] ( #$0200, &DiaryCursorPageUp )
    COP [BranchIfButton] ( #$0100, &DiaryCursorPageDown )

  loc_0BEC31:
    LDA $18
    INC $18
    BIT #$000F
    BEQ loc_0BEC53
    LDA $1A
    CLC 
    RTS 
}
---------------------------------------------

DiaryCursorApplyMove {
    STA $1A
    JSR $&DiaryClearAllCursors
    STZ $18
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $18

  loc_0BEC53:
    BIT #$0010
    BNE loc_0BEC5F
    JSR $&DiaryDrawCursorHighlight
    LDA $1A
    CLC 
    RTS 

  loc_0BEC5F:
    JSR $&DiaryClearCursor
    LDA #$0001
    TSB $displayModeFlags
    LDA $1A
    CLC 
    RTS 
}

DiaryCursorMoveUp {
    LDA $1A
    SEC 
    SBC #$0001
    BRA DiaryCursorApplyMove
}

DiaryCursorMoveDown {
    LDA $1A
    CLC 
    ADC #$0001
    BRA DiaryCursorApplyMove
}

DiaryCursorPageUp {
    LDA $1A
    SEC 
    SBC #$0002
    BRA DiaryCursorApplyMove
}

DiaryCursorPageDown {
    LDA $1A
    CLC 
    ADC #$0002
    BRA DiaryCursorApplyMove
}

DiaryCursorConfirm {
    JSR $&DiaryDrawCursorHighlight
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA $1A
    SEC 
    RTS 
}

DiaryCursorCancel {
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA #$FFFF
    SEC 
    RTS 
}
---------------------------------------------

DiaryDrawCursorHighlight {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@table_0BED3C+2, X
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

DiaryClearCursor {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@table_0BED3C+2, X
    TAX 
    LDA #$2040
    STA $7F0200, X
    PLX 
    RTS 
}
---------------------------------------------

DiaryClearAllCursors {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    TAX 
    LDA $1A
    BPL loc_0BED12
    CLC 
    ADC $@table_0BED3C, X

  loc_0BED12:
    CMP $@table_0BED3C, X
    BCC loc_0BED1D
    SEC 
    SBC $@table_0BED3C, X

  loc_0BED1D:
    STA $1A
    LDA $@table_0BED3C, X
    TAY 
    DEY 
    INX 
    INX 

  loc_0BED27:
    LDA $@table_0BED3C, X
    PHX 
    TAX 
    LDA #$2040
    STA $7F0200, X
    PLX 
    INX 
    INX 
    DEY 
    BPL loc_0BED27
    PLX 
    RTS 
}
---------------------------------------------

table_0BED3C [
  &word_0BED44   ;00
  &word_0BED4E   ;01
  &word_0BED54   ;02
  &word_0BED5C   ;03
]

word_0BED44 [
  #$0004   ;00
  #$014A   ;01
  #$01CA   ;02
  #$0160   ;03
  #$01E0   ;04
]

word_0BED4E [
  #$0002   ;00
  #$01CE   ;01
  #$01D8   ;02
]

word_0BED54 [
  #$0003   ;00
  #$02CA   ;01
  #$044A   ;02
  #$05CA   ;03
]

word_0BED5C [
  #$0003   ;00
  #$034A   ;01
  #$03CA   ;02
  #$044A   ;03
]
---------------------------------------------

DiaryScanSramSlots {
    PHX 
    LDA #$0000
    STA $0D74
    STA $0D76
    STA $0D78
    STA $0D7A
    STA $0D7C
    STA $0D7E
    STA $0D80
    STA $0D82
    STA $0D84
    STA $0D80
    STA $0D82
    STA $0D84
    LDA #$0002
    STA $24
    STZ $26
    LDA $306000
    CMP #$0003
    BCC loc_0BEDA3
    LDA #$0000
    STA $306000

  loc_0BEDA3:
    STA $0D8C

  DiaryScanSramLoop:
    LDA $24
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum
    LDA $0018
    CMP $3063FC, X
    BNE loc_0BEE11
    LDA $001C
    CMP $3063FE, X
    BNE loc_0BEE11
    PHX 
    LDA $24
    ASL 
    TAY 
    TXA 
    CLC 
    ADC #$0B12
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D74, Y
    LDA $01, S
    CLC 
    ADC #$0ACA
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D7A, Y
    LDA $01, S
    CLC 
    ADC #$0ADC
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D80, Y
    LDA $01, S
    CLC 
    ADC #$0ADE
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D86, Y
    PLA 
    SEC 
    BRA loc_0BEE12

  loc_0BEE11:
    CLC 

  loc_0BEE12:
    ROL $26
    LDA $24
    DEC 
    STA $24
    BMI loc_0BEE1E
    JMP $&DiaryScanSramLoop

  loc_0BEE1E:
    PLX 
    RTS 
}
---------------------------------------------

DiaryJoypadFilter_noref {
    LDA $00E0
    AND $00E2
    STA $00E2
    LDA $00E2
    TRB $00E0
    LDA $00E0
    BIT #$0040
    BEQ loc_0BF1A1
    LDY $playerActor
    LDA $0010, Y
    EOR #$0008
    STA $0010, Y
    LDA #$0040
    TSB $00E2

  loc_0BF1A1:
    RTL 
}
---------------------------------------------

DiaryResetCounter_noref {
    STZ $00DE
    RTL 
}
---------------------------------------------

DiaryIncCounter_noref {
    INC $00DE
    RTL 
}
---------------------------------------------

DiaryDigitDisplay_noref {
    LDA $00E0
    BIT #$8000
    BNE loc_0BF1B3
    RTL 

  loc_0BF1B3:
    LDA $00DE
    JSR $&FormatBcdNumber
    STA $0000
    LDA $bg1ScrollH
    CLC 
    ADC #$0010
    STA $0018
    LDA $bg2ScrollH
    CLC 
    ADC #$0070
    STA $001C
    LDA #$3200
    STA $0002
    JSL $@oam_digit_compose.ComposeDigits_Continuation
    RTL 
}
---------------------------------------------

FormatBcdNumber {
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8
    BCS loc_0BF245
    CMP #$01F4
    BCC loc_0BF1F8
    SEC 
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_0BF1F8:
    CMP #$0064
    BCC loc_0BF206
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_0BF1F8

  loc_0BF206:
    PHA 
    LDA $0000
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20
    CMP #$32
    BCC loc_0BF222
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_0BF222:
    CMP #$0A
    BCC loc_0BF22E
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_0BF222

  loc_0BF22E:
    PHA 
    LDA $0000
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $01, S
    STA $01, S
    PLA 
    REP #$20
    STA $01, S
    STY $0000
    PLA 
    CLC 
    RTS 

  loc_0BF245:
    STY $0000
    PLA 
    SEC 
    RTS 
}
---------------------------------------------

DiaryUnused24B_noref {
    LDA $00E1
    BIT #$F040
    ASL $A9
    TSB $22
    CMP #$8281
    RTL 
}
---------------------------------------------

DiaryReadJoy2_noref {
    LDA $JOY2L
    STA $00E0
    RTL 
}
---------------------------------------------

DiaryNullHandler_noref {
    RTL 
}
---------------------------------------------

DiaryAwaitButtonRelease_noref {
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF2A5

  loc_0BF269:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF269

  loc_0BF27D:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF27D

  loc_0BF291:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF291

  loc_0BF2A5:
    RTL 
}
---------------------------------------------

DiaryMenuVBlankHandler {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

  loc_0BF2B0:
    LDA $L_RDNMI
    BPL loc_0BF2B0
    LDA $L_RDNMI
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_0BF309
    LDA $C2
    STA $M7A
    LDA $C3
    STA $M7A
    LDA $C4
    STA $M7B
    LDA $C5
    STA $M7B
    LDA $C6
    STA $M7C
    LDA $C7
    STA $M7C
    LDA $C8
    STA $M7D
    LDA $C9
    STA $M7D
    LDA $CA
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE
    STX $CE
    LDX $C0
    STX $D0

  loc_0BF309:
    REP #$20
    LDA $joypadInject
    BEQ loc_0BF319
    STA $joypadCurrent
    STZ $joypadInject
    PLA 
    PLP 
    RTL 

  loc_0BF319:
    LDA $joypadRaw
    AND #$0F00
    STA $joypadRemapped
    LDA $remapL
    BEQ loc_0BF335
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0BF335
    LDA $remapL
    TSB $joypadRemapped

  loc_0BF335:
    LDA $remapR
    BEQ loc_0BF348
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0BF348
    LDA $remapR
    TSB $joypadRemapped

  loc_0BF348:
    LDA $remapB
    BEQ loc_0BF35B
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_0BF35B
    LDA $remapB
    TSB $joypadRemapped

  loc_0BF35B:
    LDA $remapY
    BEQ loc_0BF36E
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_0BF36E
    LDA $remapY
    TSB $joypadRemapped

  loc_0BF36E:
    LDA $remapA
    BEQ loc_0BF381
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF381
    LDA $remapA
    TSB $joypadRemapped

  loc_0BF381:
    LDA $remapStart
    BEQ loc_0BF394
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_0BF394
    LDA $remapStart
    TSB $joypadRemapped

  loc_0BF394:
    LDA $remapX
    BEQ loc_0BF3A7
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_0BF3A7
    LDA $remapX
    TSB $joypadRemapped

  loc_0BF3A7:
    LDA $remapSelect
    BEQ loc_0BF3BA
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_0BF3BA
    LDA $remapSelect
    TSB $joypadRemapped

  loc_0BF3BA:
    LDA $joypadRemapped
    STA $joypadCurrent
    STA $joypadRaw
    AND $joypadHeld
    STA $joypadHeld
    BEQ loc_0BF3E2
    AND $joypadMaskInv
    BEQ loc_0BF3E2
    LDA $joypadRepeatCounter
    INC 
    STA $joypadRepeatCounter
    CMP #$000C
    BNE loc_0BF3E5
    LDA $joypadMaskInv
    TRB $joypadHeld

  loc_0BF3E2:
    STZ $joypadRepeatCounter

  loc_0BF3E5:
    LDA $joypadHeld
    TRB $joypadCurrent
    LDA $joypadMaskStd
    TRB $joypadCurrent
    PLA 
    PLP 
    RTL 
}
---------------------------------------------

table_0BF6AD [
  &dialogstring_0BF4C3+M   ;00
  &dialogstring_0BF4EA+M   ;01
  &dialogstring_0BF511+M   ;02
]
---------------------------------------------

dialogstring_0BF3F4 `[DLG:6,A][SIZ:A,4]Start Journey[N]Erase Trip Diary[N]Copy Trip Diary[N]Change Snd/Buttons`

dialogstring_0BF437 `[DLG:2,8][SIZ:E,7]Which Diary?[N][::] Diary1 [ADR:&strings_0BF706,D74][N][N] Diary2 [ADR:&strings_0BF706,D76][N][N] Diary3 [ADR:&strings_0BF706,D78]`

dialogstring_0BF476 `[DLG:2,8][SIZ:E,7]Change Snd/Button[N][JMP:&dialogstring_0BF437+M]`

dialogstring_0BF48C `[DLG:2,8][SIZ:E,7]Move which Diary?[N][JMP:&dialogstring_0BF437+M]`

dialogstring_0BF4A7 `[DLG:2,8][SIZ:E,7]Erase which Diary?[N][JMP:&dialogstring_0BF437+M]`

dialogstring_0BF4C3 `[DLG:2,C][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

dialogstring_0BF4EA `[DLG:2,10][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

dialogstring_0BF511 `[DLG:2,14][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

dialogstring_0BF538 `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

dialogstring_0BF5AD `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

dialogstring_0BF625 `[DLG:D,C][SFX:0][ADR:&table_0BF667,D90]`

dialogstring_0BF630 `[DLG:11,E][SFX:0][ADR:&table_0BF63B,D8E]`
---------------------------------------------

table_0BF63B [
  &dialogstring_0BF63F   ;00
  &dialogstring_0BF653   ;01
]

dialogstring_0BF63F `1[DLG:8,10]A[DLG:8,12]B[DLG:8,14]SEL[DLG:8,16]Y`

dialogstring_0BF653 `2[DLG:8,10]B[DLG:8,12]Y[DLG:8,14]SEL[DLG:8,16]A`
---------------------------------------------

table_0BF667 [
  &dialogstring_0BF66B   ;00
  &dialogstring_0BF672   ;01
]

dialogstring_0BF66B `Stereo`

dialogstring_0BF672 `Mono  `
---------------------------------------------

dialogstring_0BF679 `[DLG:4,15][SIZ:C,2][DLY:FF]Diary not empty[N]Erase and select[FIN][CLD]`
---------------------------------------------

dialogstring_0BF6A4 `[DLG:4,A][ADR:&table_0BF6AD,D94]`
---------------------------------------------

dialogstring_0BF6B3 `[DLG:4,8][SIZ:D,5][ADR:&table_0BF6D9,D94][N][N]Erase diary? [N] No [N] Yes `
---------------------------------------------

table_0BF6D9 [
  &dialogstring_0BF6DF   ;00
  &dialogstring_0BF6EC   ;01
  &dialogstring_0BF6F9   ;02
]

dialogstring_0BF6DF `Diary1 [ADR:&strings_0BF706,D74]`

dialogstring_0BF6EC `Diary2 [ADR:&strings_0BF706,D76]`

dialogstring_0BF6F9 `Diary3 [ADR:&strings_0BF706,D78]`