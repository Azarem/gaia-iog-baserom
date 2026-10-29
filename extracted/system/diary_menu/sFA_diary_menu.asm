; Diary / save menu actor for scene $FA (Bank 0B, 778810-783347 plus the dialog strings): the 4-tab menu shown after the title screen - Start Journey, Erase Trip Diary, Copy Trip Diary, Change Snd/Buttons - over the three save slots.
; 
; Entry: TitleToDiaryTransition (sFC_title_start_handler) queues scene $FA at ($100,$370); the prologue scenes $8C-$8F also spawn the Start-poll actor sFC_title_start_poll, so Start there lands here too. The scene background is the overworld map (scene_meta_00FA: display-mode #08, set_overworld / map_overworld_main, music bgm_beautiful_world). DiaryCameraPan scrolls it to the location stored in diary_entry_table for the highlighted slot's source scene.
; 
; === DISPLAY SETUP (DiaryMenuInit) ===
; 
; TM = $01 (BG1), TS = $04 (BG3 on the sub screen), so the BG3 text is colour-math-blended over BG1: CGWSEL = $82 (main screen forced black inside the colour window, addend = sub screen), CGADSUB = $41 (add, half intensity, BG1 only). WOBJSEL = $22 enables window 1 for the colour window and the OBJ window; WH0/WH1 are fed by diary_menu_window_dma, which draws the highlight bands (see that file). W34SEL = $88 enables window 2 for BG3/BG4. The camera starts at ($80,$300); displayModeFlags |= $4001 (bit 14 = HUD off, bit 0 = full BG3 upload). Start and Select are masked out of joypadCurrent ($3000 in joypadMaskStd), playerFlags $2800 (script lock $0800 + guard stance $2000) is set until the menu leaves, and the D-pad auto-repeats ($0F00 in joypadMaskInv). The black-inside-window look is decoded from the registers, not observed.
; RunBg3Script consolestring_01EADC draws the button legend box (A Button: Enter / B Button: Cancel).
; 
; === DIARY STATE BLOCK ($0D74-$0D9E) ===
; 
; | Address | Purpose |
; |---------|---------|
; | $0D74/76/78 | Source scene ID (sourceSceneId $0B12 of the slot's save page) for slots 1/2/3; 0 = empty or invalid |
; | $0D7A/7C/7E | Max HP (playerMaxHp $0ACA) for slots 1/2/3 |
; | $0D80/82/84 | DEF (playerDef $0ADC) for slots 1/2/3 |
; | $0D86/88/8A | STR (playerStr $0ADE) for slots 1/2/3 |
; | $0D8C | Active / last-used slot (0-2), mirrored in SRAM $306000 |
; | $0D8E | Button type setting (0 = Type 1, 1 = Type 2); saved in the slot page at $0B26 |
; | $0D90 | Sound setting (0 = stereo, 1 = mono); saved in the slot page at $0B24 |
; | $0D92 | Slot cursor (0-2, $FFFF = none); drives the slot band |
; | $0D94 | Slot being edited (Snd/Buttons editor, arrangement screen, erase prompt) |
; | $0D96 | Copy target slot ($FFFF = none); drives a second slot band |
; | $0D98 | Tab cursor (0-3) or settings-row cursor (0-2), $FFFF = none; drives the narrow band |
; | $0D9A/9C/9E | BCD scratch for the stat strings: HP / STR / DEF |
; 
; === SRAM LAYOUT ===
; 
; $306000 holds the last-used slot (0-2). Slot n's page is $306200 + n*512: a copy of WRAM $0A00-$0BFB (508 bytes). Its additive checksum is at $3063FC + n*512 and its XOR checksum at $3063FE + n*512 (both seeded with $3652, computed by save_system.ComputeSaveChecksum with X = n*512). The two settings live inside the page at $0B24 (sound) and $0B26 (button type).
; 
; === BUTTON TYPES ===
; 
; ApplySoundAndRemap (run when a game starts) reads sound $0B24 and button type $0B26. Type 1 (0) sets remapA = $8000, remapB = $4000, remapX = 0, remapY = $0040; Type 2 (1) only sets remapX = 0 and leaves the other remaps at their current values (the engine defaults). The on-screen legend (dialogstring_0BF63F / 0BF653) reads 'Type 1: A, B, SEL, Y' and 'Type 2: B, Y, SEL, A' against the rows Attack/Talk, Item/Cancel, Item palette, Not used. This baserom's system_init transform changes the default remaps (remapA $8080, remapB $4008, remapY $0040, remapX $0004) and the menu's own button tests ($8000 confirm, $4000 cancel), so what Type 2 does here is unverified.
; The erase prompt temporarily remaps B/Y in vanilla; transforms.json strips those stubs from the plain extraction, but multi-line rules do not apply under extract:lt (OQ-I026-1), so the stubs stay visible in the line-tracked text.
; 
; === UNREFERENCED CODE ===
; 
; Nine routines carry the _noref suffix and have no callers: a BG3 cursor engine (DiaryCursorNav_noref; its helpers DiaryCursorApplyMove ... DiaryClearAllCursors and diary_cursor_menu_table are only reached from it), a controller-2 debug set at 782712-783013 (DiaryJoypadFilter_noref, DiaryResetCounter_noref, DiaryIncCounter_noref, DiaryDigitDisplay_noref, DiaryUnused24B_noref, DiaryReadJoy2_noref, DiaryNullHandler_noref, DiaryAwaitButtonRelease_noref). DiaryMenuVBlankHandler is a copy of VBlankWaitAndJoypad whose only caller is the unreferenced DiaryAwaitButtonRelease_noref; the live menu uses the engine's VBlankWaitAndJoypad and its remap.
---------------------------------------------

?BANK 0B

?INCLUDE 'diary_entry_table'
?INCLUDE 'oam_digit_compose'
?INCLUDE 'save_system'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!menuModeFlag                   00EE
!sceneNext                      0642
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!bg1ScrollH                     068A
!mapScrollV                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!scrollModeFlags                06EF
!playerActor                    09AA
!joypadInject                   09AC
!playerFlags                    09AE
!displayModeFlags               09EC
!globalScriptIndex              0AAC
!remapR                         0DA6
!remapL                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapX                         0DB0
!remapStart                     0DB2
!remapSelect                    0DB4
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
!bg3TilemapBuffer               7F0200
!cgramPalette                   7F0A00
!scratch1010                    7F1010
!free101C                       7F101C
!L_RDNMI                        804210

---------------------------------------------

sFA_diary_menu [
  actor-def < #00, #00, #28, {

; Scene $FA actor entry: black backdrop and no layers, all three cursors set to none ($FFFF), display configured as described in the block note, main-menu text and button legend printed, the three SRAM slots scanned, then a poll of worldReadyFlag until the scene is ready, after which it joins the tab loop at loc_0BE2D0.

  DiaryMenuInit:
    LDA #$0000            ; A = 0: colour 0 (backdrop) := black in the palette staging; also TM = 0 below
    STA $cgramPalette
    SEP #$20
    STA $TM               ; Disable all layers initially
    REP #$20
    LDA #$FFFF            ; Initialize cursor states to "none"
    STA $0D92
    STA $0D96
    STA $0D98
    LDA #$4001            ; displayModeFlags: bit 14 = HUD off, bit 0 = full BG3 upload request
    TSB $displayModeFlags
    SEP #$20
    LDA #$88              ; W34SEL: window 2 enabled for BG3 and BG4
    STA $W34SEL
    LDA #$22              ; WOBJSEL: window 1 enabled for OBJ and for the colour window
    STA $WOBJSEL
    REP #$20
    LDA #$0000
    STA $cgramPalette
    STA $0B04             ; Clear saved frame delay
    LDA #$0001
    STA $menuModeFlag     ; Enable menu mode flag
    SEP #$20
    LDA #$01              ; BG1 on main screen
    STA $TM
    LDA #$04              ; BG3 on sub screen (text overlay)
    STA $TS
    LDA #$82              ; CGWSEL: main screen black inside the colour window, addend = sub screen
    STA $CGWSEL
    LDA #$41              ; CGADSUB: add, half intensity, BG1 only
    STA $CGADSUB
    REP #$20
    LDA #$0080            ; Camera X = 128 (Mode 7 center)
    STA $bg1ScrollH
    STA $cameraTargetX
    LDA #$0300            ; Camera Y = 768 (Mode 7 perspective)
    STA $mapScrollV
    STA $cameraTargetY
    LDA #$3000            ; Mask Start + Select out of joypadCurrent
    TSB $joypadMaskStd
    LDA #$2800            ; playerFlags: script/ability lock ($0800) + guard stance ($2000)
    TSB $playerFlags
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC ) ; Draw the button legend box (A Button: Enter / B Button: Cancel)
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 ) ; "Start Journey / Erase / Copy / Change"
    JSR $&DiaryScanSramSlots ; Scan SRAM: validate checksums, read slot data
    LDA #$0F00            ; Enable auto-repeat on D-pad
    STA $joypadMaskInv
    STZ $18               ; Clear $18 (blink counter of the unreferenced cursor code)
    COP [SetEntryHere]
    LDA $worldReadyFlag   ; Wait for the scene to be ready, then join the tab loop at loc_0BE2D0
    BNE loc_0BE2CA
    RTL 

; Scene ready: skip the menu reprint (init already drew it) and join the tab-select setup at loc_0BE2D0.

  loc_0BE2CA:
    BRA loc_0BE2D0
} >
]
---------------------------------------------

; Main menu re-entry — redraws the 4-option menu and enters the tab selection loop.
; Navigation: Up/Down cycle through 4 tabs ($0D98), A confirms, dispatches via SwitchCase.

DiaryMainMenuEntry {
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 )

; Reset the cursors for the tab loop: slot cursor ($0D92) off, tab cursor ($0D98) = 0.

  loc_0BE2D0:
    LDA #$FFFF            ; Slot cursor off
    STA $0D92
    LDA #$0000            ; Tab cursor := first tab
    STA $0D98

; Tab loop: redraw the legend, re-enter every frame, Up/Down move the tab cursor (which drives the narrow window band), A confirms.

  DiaryTabSelectLoop:
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0800, &DiaryTabCursorUp ) ; Up → previous tab
    COP [BranchIfPressed] ( #$0400, &DiaryTabCursorDown ) ; Down → next tab
    COP [BranchIfPressed] ( #$8000, &DiaryTabConfirm ) ; A → confirm selection
    RTL 
}

---------------------------------------------
; Tab cursor Up — decrement with wraparound (0→3).

DiaryTabCursorUp {
    COP [PlaySoundCh2] ( #10 ) ; Cursor move SFX
    LDA $0D98
    DEC 
    BPL loc_0BE302
    LDA #$0003            ; Wrap to bottom

; Store the wrapped tab cursor, then consume the current buttons in joypadHeld so the press does not repeat until auto-repeat fires.

  loc_0BE302:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Tab cursor Down — increment with wraparound (3→0).

DiaryTabCursorDown {
    COP [PlaySoundCh2] ( #10 ) ; Cursor move SFX
    LDA $0D98
    INC 
    CMP #$0004
    BCC loc_0BE31E
    LDA #$0000            ; Wrap to top

; Store the wrapped tab cursor, then consume the current buttons in joypadHeld.

  loc_0BE31E:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Tab confirm — dispatches to the selected tab handler via SwitchCase on $0D98.

DiaryTabConfirm {
    COP [PlaySoundCh2] ( #11 ) ; Confirm SFX
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    AND #$0003            ; Tab index for SwitchCase
    STA $0000
    LDA #$FFFF            ; Tab cursor off (hides the narrow band)
    STA $0D98
    COP [SwitchCase] ( #$0000, &diary_tab_dispatch_table )
}

---------------------------------------------
; SwitchCase targets for DiaryTabConfirm, indexed by the tab cursor: 0 = Start Journey, 1 = Erase, 2 = Copy, 3 = Change Snd/Buttons.

diary_tab_dispatch_table [
  &DiaryStartJourney   ;00
  &DiaryEraseTab   ;01
  &DiaryCopyTab   ;02
  &DiarySndBtnTab   ;03
]

---------------------------------------------
; Start Journey tab — diary slot selection, save validation, and game load.
; Displays 3 diary slots with HP/STR/DEF stats. On confirm, validates the SRAM checksum,
; loads event flags, and transitions to scene $E6 (Dark Space) to resume gameplay.
; Camera pan animation (DiaryCameraPan) scrolls to the selected slot's world position.

DiaryStartJourney {
    JSR $&DiaryMenuClearVram ; Clear VRAM buffer
    COP [PrintDialogStringAlt] ( &dialogstring_0BF437 ) ; "Which Diary?" with 3 slots
    COP [CallNear] ( &DiaryRenderSlotStats ) ; Draw slot stats (HP/STR/DEF)
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D8C             ; Last used slot
    AND #$0003
    STA $0D92             ; Pre-select it

; Slot-list loop of Start Journey: every frame set the pan speed, run DiaryCameraPan toward the highlighted slot's location, re-arm this loop, then poll Up/Down (move), A (load) and B (back).

  DiaryStartSlotLoop:
    COP [SetEntryHereAndYield]
    LDA #$000C            ; Pan speed: 12 steps (pixels) per frame
    STA $free101C, X
    COP [CallNear] ( &DiaryCameraPan ) ; Animate camera pan to slot position
    COP [SetEntryFar] ( @DiaryStartSlotLoop ) ; Re-arm the slot loop (DiaryCameraPan set its own entry while panning)
    COP [BranchIfPressed] ( #$0800, &DiaryStartSlotUp ) ; Up → previous slot
    COP [BranchIfPressed] ( #$0400, &DiaryStartSlotDown ) ; Down → next slot
    COP [BranchIfPressed] ( #$8000, &DiaryStartLoadConfirm ) ; A → confirm slot
    COP [BranchIfPressed] ( #$4000, &DiaryStartCancel ) ; B → cancel, return to main menu
    RTL 
}

---------------------------------------------
; Slot cursor up (wraps 0 -> 2); plays the cursor SFX and consumes the press.

DiaryStartSlotUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE3A4
    LDA #$0002

; Store the slot cursor and consume the current buttons in joypadHeld.

  loc_0BE3A4:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Slot cursor down (wraps 2 -> 0); plays the cursor SFX and consumes the press.

DiaryStartSlotDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE3C0
    LDA #$0000

; Store the slot cursor and consume the current buttons in joypadHeld.

  loc_0BE3C0:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; B on the slot list: clear the text and return to the main menu.

DiaryStartCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

---------------------------------------------
; Load confirmed — validate SRAM, apply settings, and transition to Dark Space.

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
    JSL $@save_system.LoadGameState_Scene ; Verify both checksums, then copy the slot's 508 bytes to $0A00
    BCS loc_0BE433        ; Carry set → corrupt/empty slot
    JSR $&ApplySoundAndRemap ; Apply sound mode + button remap
    LDA $0AB2             ; $0AB2 = Dark Space layout variant saved in the slot
    STA $globalScriptIndex
    LDA #$00E6            ; Scene $E6 = Dark Space
    STA $sceneNext
    LDA #$0078            ; warpDestX = 120 px
    STA $warpDestX
    LDA #$0090            ; warpDestY = 144 px
    STA $warpDestY
    LDA #$0003            ; warpFacing = 3 (facing byte of the warp)
    STA $warpFacing
    LDA #$1100            ; warpScrollParams = $1100 (scroll/transition word)
    STA $warpScrollParams
    LDA #$2800            ; Clear $0800 + $2000 (set in DiaryMenuInit)
    TRB $playerFlags
    COP [Die]             ; Kill menu actor → scene transition fires

; Load failed (corrupt/empty slot) — show settings arrangement screen instead.
; Presents sound/button config for a new game start.

  loc_0BE433:
    LDA $0D92             ; Slot the player picked (empty or failed the checksum)
    STA $0D94
    LDA #$FFFF
    STA $0D92
    LDA #$0000            ; New-game defaults: button type 0 ($0D8E) and stereo ($0D90)
    STA $0D8E
    STA $0D90
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF5AD ) ; 'Arrangement OK?' screen: Start Journey / Sound / Button Type
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 ) ; Current sound text
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 ) ; Current button-type legend
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000            ; Row cursor := row 0 (Start Journey)
    STA $0D98

; Loop of the 'Arrangement OK?' screen: A / Left / Right act on the row (DiarySettingsToggle), Up / Down move the row cursor, B goes back to the slot list.

  DiaryNewGameSettingsLoop:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$8300, &DiarySettingsToggle ) ; A / Left / Right: act on the current row
    COP [BranchIfPressed] ( #$0800, &DiarySettingsUp ) ; Up: previous row
    COP [BranchIfPressed] ( #$0400, &DiarySettingsDown ) ; Down: next row
    COP [BranchIfPressed] ( #$4000, &DiaryNewGameCancel ) ; B: back to the slot list
    RTL 
}

---------------------------------------------
; B on the arrangement screen: row cursor off, restore the slot cursor from $0D94 and show the slot list again.

DiaryNewGameCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94             ; Restore the slot cursor
    STA $0D92
    JMP $&DiaryStartJourney
}

---------------------------------------------
; A / Left / Right on the arrangement screen. Row 0 (Start Journey): only A acts (loc_0BE4E7 -> DiaryNewGameStart). Row 1 (Sound): toggle $0D90 and redraw its text. Row 2 (Button Type): toggle $0D8E (loc_0BE4C5) and redraw its legend.

DiarySettingsToggle {
    LDA #$8300
    TSB $joypadHeld
    LDA $0D98
    BEQ loc_0BE4E7        ; Row 0 (Start Journey): only A acts
    DEC 
    BNE loc_0BE4C5
    COP [PlaySoundCh2] ( #0D )
    LDA $0D90             ; Row 1 (Sound): toggle 0 / 1
    INC 
    AND #$0001
    STA $0D90
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$8300
    TSB $joypadHeld
    JMP $&DiaryNewGameSettingsLoop

; Row 2 (Button Type): toggle $0D8E, redraw the type legend and return to the loop.

  loc_0BE4C5:
    DEC 
    BNE loc_0BE4E7
    COP [PlaySoundCh2] ( #0D )
    LDA $0D8E             ; Row 2 (Button Type): toggle 0 / 1
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$8300
    TSB $joypadHeld
    JMP $&DiaryNewGameSettingsLoop

; Row 0 (or no value row): A starts the game.

  loc_0BE4E7:
    COP [BranchIfPressed] ( #$8000, &DiaryNewGameStart )
    RTL 
}

---------------------------------------------
; New game confirmed on the arrangement screen: store the sound / button settings in $0B24 / $0B26, apply them (ApplySoundAndRemap), queue scene $08 (its spawn list holds sc08_priest, sc08_lance, sc08_seth and sc08_erik) at ($50,$A0), clear the playerFlags bits set by the menu and Die.

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
    LDA #$0008            ; Scene $08 (spawn list: sc08_priest, sc08_lance, sc08_seth, sc08_erik)
    STA $sceneNext
    COP [QueueMapChange] ( #08, #$0050, #$00A0, #00, #$1200 ) ; Start at ($50,$A0)
    LDA #$2800            ; Clear $0800 + $2000 (set in DiaryMenuInit)
    TRB $playerFlags
    COP [Die]
}

---------------------------------------------
; Camera pan toward the highlighted slot's map location, one call per frame (called with COP CallNear). The slot's scene ID ($0D74,Y) indexes diary_entry_table; the entry is a name string ended by $CA followed by two words, the camera target X and Y. |dx| / |dy| and their signs go to $7F100C / $7F100E and animScratch, then a Bresenham walk moves cameraTargetX/Y one pixel per step along the longer axis, $free101C steps per frame (12 from the slot loop). Mid-pan it re-arms itself with SetEntryHere; when the target is reached (or was already there) RestoreSavedPtr returns to the CallNear caller.

DiaryCameraPan {
    PHX                   ; Save X (actor slot); pulled again after the table lookup
    LDA $0D92             ; Slot cursor -> Y = slot * 2
    ASL 
    TAY 
    LDA $0D74, Y          ; Scene ID of the slot
    ASL 
    TAX 
    LDA $@diary_entry_table, X ; Entry pointer for that scene (one word per scene)
    SEC 
    SBC #$&diary_entry_table
    TAX 
    SEP #$20

; Scan the entry's name string up to its $CA terminator; the next two words are the camera target.

  loc_0BE53D:
    LDA $@diary_entry_table, X
    INX 
    CMP #$CA              ; Skip the name string up to its $CA terminator
    BNE loc_0BE53D
    REP #$20
    LDA $@diary_entry_table, X ; Entry word 1 = camera target X
    TAY 
    LDA $@diary_entry_table+2, X ; Entry word 2 = camera target Y
    PLX                   ; X = actor slot again
    STA $7F100E, X        ; Stash target Y at $7F100E
    TYA 
    STA $7F100C, X        ; Stash target X at $7F100C
    SEC 
    SBC $cameraTargetX    ; dx = target X - cameraTargetX
    BMI loc_0BE56E
    STA $7F100C, X        ; $7F100C := |dx|
    LDA #$0001
    STA $animScratch, X   ; X sign (+1) in animScratch
    BRA loc_0BE57D

; dx negative: |dx| = -dx, sign = -1.

  loc_0BE56E:
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA #$FFFF
    STA $animScratch, X   ; X sign (-1) in animScratch

; Same for dy: |dy| and its sign (0 when dy = 0).

  loc_0BE57D:
    LDA $7F100E, X
    SEC 
    SBC $cameraTargetY    ; dy = target Y - cameraTargetY
    BMI loc_0BE596
    STA $7F100E, X        ; $7F100E := |dy|
    BEQ loc_0BE590
    LDA #$0001

; Store the dy sign (+1, or 0 when dy = 0).

  loc_0BE590:
    STA $animScratch+2, X ; Y sign (+1, or 0 when dy = 0) in animScratch+2
    BRA loc_0BE5A7

; dy negative: |dy| = -dy, sign = -1 (0 when |dy| = 0).

  loc_0BE596:
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BEQ loc_0BE5A3
    LDA #$FFFF

; Store the dy sign.

  loc_0BE5A3:
    STA $animScratch+2, X ; Y sign (-1, or 0 when dy = 0) in animScratch+2

; Choose the major axis: |dx| >= |dy| steps X (below), otherwise Y (loc_0BE612).

  loc_0BE5A7:
    LDA $7F100C, X
    CMP $7F100E, X        ; |dx| < |dy|: Y-major loop at loc_0BE612
    BCC loc_0BE612
    LDA $7F100C, X
    BEQ loc_0BE610        ; |dx| = 0 means also |dy| = 0: already there
    STA $scratch1010+4, X ; Step counter = |dx|
    LSR 
    STA $scratch1010, X   ; Error accumulator = |dx| / 2
    LDA $7F100E, X
    STA $scratch1010+2, X ; Minor delta = |dy|
    COP [SetEntryHere]    ; Resume here each frame while panning
    LDA $free101C, X      ; Step budget for this frame ($free101C)
    STA $0000

; X-major step loop: cameraTargetX += sign(dx); error -= |dy|; when it goes negative, error += |dx| and cameraTargetY += sign(dy). $0000 holds this frame's step budget ($free101C).

  loc_0BE5D1:
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX    ; cameraTargetX += sign(dx)
    STA $cameraTargetX
    LDA $scratch1010, X
    SEC 
    SBC $scratch1010+2, X ; error -= |dy|
    STA $scratch1010, X
    BPL loc_0BE5FF
    CLC 
    ADC $7F100C, X        ; Error went negative: error += |dx| and step Y
    STA $scratch1010, X
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY    ; cameraTargetY += sign(dy)
    STA $cameraTargetY

; Count the step; stop after |dx| steps, otherwise continue until the frame's step budget is spent, then yield (RTL resumes at the SetEntryHere above).

  loc_0BE5FF:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE610
    DEC $0000
    BNE loc_0BE5D1
    RTL                   ; Budget spent: yield, resume at the SetEntryHere above

; Pan finished: RestoreSavedPtr returns to the CallNear caller.

  loc_0BE610:
    COP [RestoreSavedPtr] ; Done: return to the CallNear caller

; Y-major setup: step counter = |dy|, error = |dy| / 2, minor delta = |dx|, then SetEntryHere and the same per-frame budget.

  loc_0BE612:
    LDA $7F100E, X
    BEQ loc_0BE671
    STA $scratch1010+4, X ; Step counter = |dy|
    LSR 
    STA $scratch1010+2, X ; Error accumulator = |dy| / 2
    LDA $7F100C, X
    STA $scratch1010, X   ; Minor delta = |dx|
    COP [SetEntryHere]
    LDA $free101C, X
    STA $0000

; Y-major step loop (mirror of loc_0BE5D1 with the axes swapped).

  loc_0BE632:
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY    ; cameraTargetY += sign(dy)
    STA $cameraTargetY
    LDA $scratch1010+2, X
    SEC 
    SBC $scratch1010, X   ; error -= |dx|
    STA $scratch1010+2, X
    BPL loc_0BE660
    CLC 
    ADC $7F100E, X        ; Error went negative: error += |dy| and step X
    STA $scratch1010+2, X
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX    ; cameraTargetX += sign(dx)
    STA $cameraTargetX

; Count the step; stop after |dy| steps or when the frame's step budget is spent.

  loc_0BE660:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE671
    DEC $0000
    BNE loc_0BE632
    RTL                   ; Budget spent: yield, resume at the SetEntryHere above

; Pan finished (Y-major): RestoreSavedPtr.

  loc_0BE671:
    COP [RestoreSavedPtr] ; Done: return to the CallNear caller
}
---------------------------------------------

; Apply the saved sound and button settings when a game starts (called from DiaryStartLoadConfirm and DiaryNewGameStart). Clears $0B04 and menuModeFlag. Sound: $0B24 = 0 sends SPC command $91 (stereo), nonzero sends $90 (mono) through APUIO0. Buttons: $0B26 = 0 (Type 1) sets remapA = $8000, remapB = $4000, remapX = 0, remapY = $0040; nonzero (Type 2) only clears remapX and leaves the other remaps unchanged.

ApplySoundAndRemap {
    LDA #$0000
    STA $0B04             ; Clear frame delay
    STZ $menuModeFlag     ; Clear menu mode flag
    LDA $0B24             ; Sound mode from save
    BNE loc_0BE68C        ; Nonzero → mono
    SEP #$20
    LDA #$91              ; SPC command $91: stereo ($32 := 0 in the SPC engine)
    STA $APUIO0
    REP #$20
    BRA loc_0BE695

; Mono: SPC command $90.

  loc_0BE68C:
    SEP #$20
    LDA #$90              ; SPC command $90: mono ($32 := 1 in the SPC engine)
    STA $APUIO0
    REP #$20

; Button type: 0 = Type 1 remaps below, nonzero = Type 2 (loc_0BE6B3).

  loc_0BE695:
    LDA $0B26             ; Button layout from save
    BNE loc_0BE6B3        ; Nonzero → layout B (no remap)
    LDA #$8000            ; Type 1: remapA := the attack/confirm bit (physical A)
    STA $remapA
    LDA #$4000            ; Type 1: remapB := $4000 (physical B = item/cancel bit)
    STA $remapB
    LDA #$0000            ; Type 1: remapX := 0 (X unused)
    STA $remapX
    LDA #$0040            ; Type 1: remapY := $0040
    STA $remapY
    RTS 

; Type 2: only remapX := 0; remapA / remapB / remapY keep their current values.

  loc_0BE6B3:
    LDA #$0000            ; Type 2: only remapX := 0; remapA / B / Y keep their values
    STA $remapX
    RTS 
}
---------------------------------------------

; Change Snd/Buttons tab — toggle stereo/mono sound and button layout assignment.
; After confirming, saves settings to the active save slot's SRAM and recomputes checksums.

DiarySndBtnTab {
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF476 )
    COP [CallNear] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D92

; Slot picker of the Snd/Buttons tab; it shares the Erase tab's Up/Down handlers. A opens the editor for a used slot, B returns to the main menu.

  DiarySndBtnSlotLoop:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0800, &DiaryEraseSlotUp )
    COP [BranchIfPressed] ( #$0400, &DiaryEraseSlotDown )
    COP [BranchIfPressed] ( #$8000, &DiarySndBtnSlotConfirm )
    COP [BranchIfPressed] ( #$4000, &DiarySndBtnCancel )
    RTL 
}

---------------------------------------------
; B on the slot picker: clear the text and return to the main menu.

DiarySndBtnCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

---------------------------------------------
; A on a slot: plays SFX #12; an empty slot (scene ID 0) is ignored. Otherwise remember the slot in $0D94, load its sound / button settings (ReadSramSettings) and show the editor (End Changes / Sound / Button Type).

DiarySndBtnSlotConfirm {
    COP [PlaySoundCh2] ( #12 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y          ; Scene ID 0 = empty slot: ignored
    BNE loc_0BE714
    RTL 

; Used slot: confirm SFX, remember the slot, load its settings and draw the editor.

  loc_0BE714:
    COP [PlaySoundCh2] ( #11 )
    LDA $0D92
    STA $0D94             ; Slot being edited
    JSR $&ReadSramSettings ; Load that slot's $0B24 / $0B26 into $0D90 / $0D8E
    LDA #$FFFF
    STA $0D92
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF538 )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF625 )
    COP [PrintDialogStringAlt] ( &dialogstring_0BF630 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D98

; Editor loop: A / Left / Right act on the row (DiarySndBtnOptionToggle), Up / Down move the row cursor ($0D98, rows 0-2), B abandons the edit.

  DiarySndBtnEditLoop:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$8300, &DiarySndBtnOptionToggle )
    COP [BranchIfPressed] ( #$0800, &DiarySettingsUp )
    COP [BranchIfPressed] ( #$0400, &DiarySettingsDown )
    COP [BranchIfPressed] ( #$4000, &DiarySndBtnEditCancel )
    RTL 
}

---------------------------------------------
; Row cursor up (rows 0-2, wraps); shared by the arrangement screen and the Snd/Buttons editor.

DiarySettingsUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    DEC 
    BPL loc_0BE770
    LDA #$0002

; Store the wrapped row cursor.

  loc_0BE770:
    STA $0D98
    RTL 
}

---------------------------------------------
; Row cursor down (rows 0-2, wraps); shared with the arrangement screen.

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

; Store the wrapped row cursor.

  loc_0BE78C:
    STA $0D98
    RTL 
}

---------------------------------------------
; B in the editor: discard the edit and return to the slot picker (DiarySndBtnTab).

DiarySndBtnEditCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    JMP $&DiarySndBtnTab
}

---------------------------------------------
; A / Left / Right in the editor. Row 1 toggles sound ($0D90), row 2 toggles the button type ($0D8E) (loc_0BE7CC); on row 0 (End Changes) A saves (loc_0BE7EE).

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
    LDA #$8300
    TSB $joypadHeld
    JMP $&DiarySndBtnEditLoop

; Row 2 (Button Type): toggle $0D8E, redraw its legend and return to the editor loop.

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
    LDA #$8300
    TSB $joypadHeld
    JMP $&DiarySndBtnEditLoop

; Row 0 (End Changes): A saves via DiarySndBtnSaveConfirm.

  loc_0BE7EE:
    COP [BranchIfPressed] ( #$8000, &DiarySndBtnSaveConfirm )
    RTL 
}

---------------------------------------------
; Save: write both settings into the slot's SRAM page (WriteSramSettings), recompute both checksums and store them at $3063FC / $3063FE + slot*512, then redraw the slot picker with the cursor back on that slot.

DiarySndBtnSaveConfirm {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    JSR $&WriteSramSettings ; Store $0D90 / $0D8E into the slot page (A = slot)
    PHX 
    LDA $0D94
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum ; Recompute both checksums (X = slot * 512)
    LDA $0018
    STA $3063FC, X        ; Additive checksum -> slot page + $1FC
    LDA $001C
    STA $3063FE, X        ; XOR checksum -> slot page + $1FE
    PLX 
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF476 )
    COP [CallNear] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D94
    STA $0D92
    JMP $&DiarySndBtnSlotLoop
}
---------------------------------------------

; Read sound/button settings from SRAM for the selected slot.
; Extracts $0B24 (sound mode) and $0B26 (button layout) from the slot's save data.

ReadSramSettings {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24            ; $0B24 (sound) minus $0A00 = offset inside the slot page
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002            ; Clamp: values of 2 or more become 0
    BCC loc_0BE85C
    LDA #$0000

; Store the sound setting (values >= 2 were clamped to 0) and continue with the button type.

  loc_0BE85C:
    STA $0D90
    LDA $01, S
    CLC 
    ADC #$0B26            ; $0B26 (button type) minus $0A00 = offset inside the slot page
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002
    BCC loc_0BE876
    LDA #$0000

; Store the button type (values >= 2 were clamped to 0).

  loc_0BE876:
    STA $0D8E
    PLX 
    PLX 
    RTS 
}
---------------------------------------------

; Write sound/button settings to SRAM for the selected slot.
; Stores $0D90 (sound mode) and $0D8E (button layout) into the slot's save data.

WriteSramSettings {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24            ; $0B24 (sound) minus $0A00 = offset inside the slot page
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D90
    STA $306200, X
    LDA $01, S
    CLC 
    ADC #$0B26            ; $0B26 (button type) minus $0A00 = offset inside the slot page
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

; Copy Trip Diary tab — copy a diary slot's SRAM data to an empty slot.
; First checks if all 3 slots are occupied — if so, shows "Diary not empty" and returns.
; Otherwise enters source slot selection, then target slot selection (skips occupied slots).
; Uses SRAM block copy (JSR $0402) to transfer 512 bytes between slot offsets.

DiaryCopyTab {
    LDA $0D74             ; Check if all slots occupied
    BEQ loc_0BE8D4        ; Slot 1 empty → proceed
    LDA $0D76
    BEQ loc_0BE8D4        ; Slot 2 empty → proceed
    LDA $0D78
    BEQ loc_0BE8D4        ; Slot 3 empty → proceed
    LDA #$0002            ; All slots used: pre-select tab 2 (Erase)
    STA $0D98
    STZ $menuModeFlag
    COP [PrintDialogStringAlt] ( &dialogstring_0BF679 ) ; 'Diary not empty / Erase and select'
    LDA #$0001
    STA $menuModeFlag
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 )
    JMP $&DiaryTabSelectLoop

; At least one slot is empty: start the copy flow with the source cursor on slot 1.

  loc_0BE8D4:
    JSR $&DiaryMenuClearVram
    LDA #$0000
    STA $0D92

; Source-slot loop: prints 'Move which Diary?' (the string that heads the Copy tab), redraws the stats and the legend, then polls Up / Down / A / B.

  DiaryCopySourceLoop:
    COP [PrintDialogStringAlt] ( &dialogstring_0BF48C ) ; 'Move which Diary?' (title of the Copy tab)
    COP [CallNear] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0800, &DiaryCopySourceUp )
    COP [BranchIfPressed] ( #$0400, &DiaryCopySourceDown )
    COP [BranchIfPressed] ( #$8000, &DiaryCopySourceConfirm )
    COP [BranchIfPressed] ( #$4000, &DiaryCopyCancel )
    RTL 
}

---------------------------------------------
; Source cursor up (wraps 0 -> 2).

DiaryCopySourceUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE911
    LDA #$0002

; Store the source cursor and consume the current buttons.

  loc_0BE911:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Source cursor down (wraps 2 -> 0).

DiaryCopySourceDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE92D
    LDA #$0000

; Store the source cursor.

  loc_0BE92D:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; B on the source list: consume the press, clear the text and return to the main menu.

DiaryCopyCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA #$4000
    TSB $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

---------------------------------------------
; A on the source slot: ignored when the slot is empty. Otherwise find the first empty slot (scene ID 0), put the target cursor ($0D96) on it and enter the target loop.

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

; Used source: search the three slots for the first empty one.

  loc_0BE960:
    LDY #$0000            ; Search for the first empty slot

; Search loop over $0D74,Y (Y = slot * 2).

  loc_0BE963:
    LDA $0D74, Y          ; Scene ID 0 = empty
    BEQ loc_0BE972
    INY 
    INY 
    CPY #$0006
    BCC loc_0BE963
    BNE loc_0BE972
    RTL                   ; No empty slot: nothing to do

; Found an empty slot (Y = its offset): the target cursor = Y / 2, then yield into the target loop.

  loc_0BE972:
    TYA 
    LSR 
    STA $0D96             ; Target cursor := first empty slot
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0800, &DiaryCopyTargetUp )
    COP [BranchIfPressed] ( #$0400, &DiaryCopyTargetDown )
    COP [BranchIfPressed] ( #$8000, &DiaryCopyExecute )
    COP [BranchIfPressed] ( #$4000, &DiaryCopyTargetCancel )
    RTL 
}

---------------------------------------------
; Target cursor up: steps back (wrapping over 3 slots) until it lands on an empty slot other than the source.

DiaryCopyTargetUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

; Step the target cursor back by one (wraps 0 -> 2).

  loc_0BE998:
    DEC 
    BPL loc_0BE99E
    LDA #$0002

; Store the target cursor; skip the source slot and occupied slots.

  loc_0BE99E:
    STA $0D96
    CMP $0D92             ; Skip the source slot
    BEQ loc_0BE998
    ASL 
    TAY 
    LDA $0D74, Y
    BNE DiaryCopyTargetUp ; Occupied target: keep stepping
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Target cursor down: steps forward (wrapping over 3 slots) until it lands on an empty slot other than the source.

DiaryCopyTargetDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

; Step the target cursor forward by one (wraps 2 -> 0).

  loc_0BE9BD:
    INC 
    CMP #$0003
    BCC loc_0BE9C6
    LDA #$0000

; Store the target cursor; skip the source slot and occupied slots.

  loc_0BE9C6:
    STA $0D96
    CMP $0D92             ; Skip the source slot
    BEQ loc_0BE9BD
    ASL 
    TAY 
    LDA $0D74, Y
    BNE DiaryCopyTargetDown ; Occupied target: keep stepping
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; B on the target list: clear the target cursor ($FFFF) and go back to the source list.

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

---------------------------------------------
; A on the target slot: copy the source slot's whole 512-byte SRAM page (data plus both checksums) to the target with the RAM block-move stub at $0402 (MVN, banks $30 -> $30), move the cursor to the new slot, rescan the slots and show the source list again.

DiaryCopyExecute {
    LDA $0D96
    ASL 
    TAY 
    LDA $0D74, Y          ; Target must be empty (the cursor skips used slots)
    BEQ loc_0BEA04
    JMP $&DiaryCopySourceConfirm ; Target used (not reachable via the cursor): treat as a source confirm

; Target is empty (the normal path): do the copy.

  loc_0BEA04:
    COP [PlaySoundCh2] ( #29 ) ; Copy SFX
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    PHX 
    LDA $0D92
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200            ; Source page offset in bank $30: $6200 + slot * 512
    TAX 
    LDA $0D96
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200            ; Destination page offset in bank $30: $6200 + slot * 512
    TAY 
    SEP #$20
    LDA #$30              ; MVN source bank = $30 (SRAM)
    STA $0405
    LDA #$30              ; MVN destination bank = $30 (SRAM)
    STA $0404
    REP #$20
    LDA #$01FF            ; 512 bytes - 1 (whole page including both checksums)
    JSR $0402             ; RAM block-move stub at $0402 (PHB, MVN, PLB, return)
    PLX 
    LDA $0D96             ; Cursor follows the copy to the new slot
    STA $0D92
    LDA #$FFFF
    STA $0D96
    JSR $&DiaryScanSramSlots ; Rescan so the new slot shows its stats
    JSR $&DiaryMenuClearVram
    JMP $&DiaryCopySourceLoop
}

---------------------------------------------
; Erase Trip Diary tab — select a diary slot and optionally delete it.
; Shows slot stats before confirming. Empty slots are erased immediately via ClearSaveSlot.
; Occupied slots show a yes/no confirmation prompt with stat preview.

DiaryEraseTab {
    JSR $&DiaryMenuClearVram

; Redraw the Erase title, stats and legend; slot cursor := 0.

  DiaryEraseSelectLoop:
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4A7 )
    COP [CallNear] ( &DiaryRenderSlotStats )
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA #$0000
    STA $0D92

; Erase slot list: Up / Down move (shared handlers with the Snd/Buttons slot picker), A selects, B returns to the main menu.

  DiaryEraseInputLoop:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0800, &DiaryEraseSlotUp )
    COP [BranchIfPressed] ( #$0400, &DiaryEraseSlotDown )
    COP [BranchIfPressed] ( #$8000, &DiaryEraseSlotConfirm )
    COP [BranchIfPressed] ( #$4000, &DiaryEraseCancel )
    RTL 
}

---------------------------------------------
; Slot cursor up (wraps 0 -> 2); shared with the Snd/Buttons slot picker.

DiaryEraseSlotUp {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BEA92
    LDA #$0002

; Store the slot cursor and consume the current buttons.

  loc_0BEA92:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; Slot cursor down (wraps 2 -> 0); shared with the Snd/Buttons slot picker.

DiaryEraseSlotDown {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BEAAE
    LDA #$0000

; Store the slot cursor and consume the current buttons.

  loc_0BEAAE:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

---------------------------------------------
; B on the erase list: clear the text and return to the main menu.

DiaryEraseCancel {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&DiaryMenuClearVram
    JMP $&DiaryMainMenuEntry
}

---------------------------------------------
; A on a slot. An empty slot is cleared at once with ClearSaveSlot (no prompt). A used slot opens the 'Erase diary? No / Yes' prompt: the slot name via diary_erase_slot_name_table, its HP / STR / DEF via diary_erase_stat_line_table, and COP DialogueOptions with the targets in diary_erase_confirm_table.

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
    COP [PlaySoundCh2] ( #12 ) ; Empty slot: SFX #12, cleared without a prompt
    LDA $0D92
    JSL $@save_system.ClearSaveSlot ; Clear the slot (A = slot)
    JMP $&DiaryEraseInputLoop

; Used slot: remember it in $0D94, redraw, format its HP / DEF / STR to BCD and open the Yes / No prompt.

  loc_0BEAF0:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    JSR $&DiaryMenuClearVram
    COP [PrintDialogStringAlt] ( &dialogstring_0BF6B3 ) ; 'Erase diary? No / Yes' with the slot name
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    LDA $0D94
    ASL 
    TAY 
    LDA $0D7A, Y          ; Max HP of the slot -> BCD -> $0D9A
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9A
    LDA $0D80, Y          ; DEF of the slot -> BCD -> $0D9E
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9E
    LDA $0D86, Y          ; STR of the slot -> BCD -> $0D9C
    PHY 
    JSR $&FormatBcdNumber
    PLY 
    STA $0D9C
    COP [PrintDialogStringAlt] ( &dialogstring_0BF6A4 ) ; Stat line of the slot being erased
    COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
    COP [DialogueOptions] ( #02, #03, &diary_erase_confirm_table ) ; Yes / No prompt: index + 1 returned (0 = cancel)
}

---------------------------------------------
; DialogueOptions targets, indexed by the returned value (index + 1, 0 = cancel): cancel and 'No' -> DiaryEraseDecline, 'Yes' -> DiaryEraseExecute.

diary_erase_confirm_table [
  &DiaryEraseDecline   ;00
  &DiaryEraseDecline   ;01
  &DiaryEraseExecute   ;02
]

---------------------------------------------
; No / cancel: consume the press and return to the Erase tab. The vanilla button-remap restore that follows in the line-tracked text is stripped from the plain extraction by transforms.json.

DiaryEraseDecline {
    LDA #$4000
    TSB $joypadHeld
    JMP $&DiaryEraseTab
}

---------------------------------------------
; Yes: erase SFX #13, ClearSaveSlot for the slot in $0D94, wait 30 ticks (WaitByte #1D), rescan the slots, clear the text and return to the Erase list. The vanilla remap-restore stub at the top is stripped from the plain extraction by transforms.json.

DiaryEraseExecute {
    COP [PlaySoundCh2] ( #13 ) ; Erase SFX
    COP [SetEntryHere]
    LDA $0D94
    JSL $@save_system.ClearSaveSlot
    COP [WaitByte] ( #1D ) ; WaitByte #1D = 30 ticks
    LDA $1C
    STA $1A
    STZ $1C
    JSR $&DiaryMenuClearVram
    JSR $&DiaryScanSramSlots
    JMP $&DiaryEraseSelectLoop
}

---------------------------------------------
; Render diary slot stats — for each non-empty slot, reads the saved HP/STR/DEF values,
; converts them to BCD via FormatBcdNumber, and prints them using the stat display templates.

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
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4C3 ) ; Slot 1 stat line

; Slot 2 stat line (skipped when the slot is empty).

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
    COP [PrintDialogStringAlt] ( &dialogstring_0BF4EA ) ; Slot 2 stat line

; Slot 3 stat line (skipped when the slot is empty).

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
    COP [PrintDialogStringAlt] ( &dialogstring_0BF511 ) ; Slot 3 stat line

; Done: RestoreSavedPtr returns to the CallNear caller.

  loc_0BEBF7:
    COP [RestoreSavedPtr]
}
---------------------------------------------

; Clear VRAM buffer — wrapper that preserves registers across ClearVramBufferFull call.

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

; Unreferenced BG3 cursor engine entry (DP $14 = menu index into diary_cursor_menu_table, $18 = blink counter, $1A = cursor position). A confirms, $0020 cancels, Up / Down move by one, Left / Right move by two when the menu index is below 2. Returns A = position with carry clear while choosing, carry set once confirmed (or cancelled with A = $FFFF).

DiaryCursorNav_noref {
    COP [BranchIfPressed] ( #$8000, &DiaryCursorConfirm )
    COP [BranchIfPressed] ( #$0020, &DiaryCursorCancel )
    COP [BranchIfPressed] ( #$0800, &DiaryCursorMoveUp )
    COP [BranchIfPressed] ( #$0400, &DiaryCursorMoveDown )
    LDA $14
    CMP #$0002
    BCS loc_0BEC31
    COP [BranchIfPressed] ( #$0200, &DiaryCursorPageUp )
    COP [BranchIfPressed] ( #$0100, &DiaryCursorPageDown )

; No button: advance the blink counter ($18) and redraw the cursor every 16 frames.

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

; Apply a move: wrap $1A (DiaryClearAllCursors blanks every position), reset the blink counter, consume the D-pad press and play SFX #10.

DiaryCursorApplyMove {
    STA $1A
    JSR $&DiaryClearAllCursors
    STZ $18
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $18

; Blink: counter bit 4 clear draws the cursor tile, set erases it.

  loc_0BEC53:
    BIT #$0010
    BNE loc_0BEC5F
    JSR $&DiaryDrawCursorHighlight
    LDA $1A
    CLC 
    RTS 

; Erase phase: blank the cursor tile and request a full BG3 upload.

  loc_0BEC5F:
    JSR $&DiaryClearCursor
    LDA #$0001
    TSB $displayModeFlags
    LDA $1A
    CLC 
    RTS 
}

---------------------------------------------
; $1A -= 1, then DiaryCursorApplyMove.

DiaryCursorMoveUp {
    LDA $1A
    SEC 
    SBC #$0001
    BRA DiaryCursorApplyMove
}

---------------------------------------------
; $1A += 1, then DiaryCursorApplyMove.

DiaryCursorMoveDown {
    LDA $1A
    CLC 
    ADC #$0001
    BRA DiaryCursorApplyMove
}

---------------------------------------------
; $1A -= 2, then DiaryCursorApplyMove.

DiaryCursorPageUp {
    LDA $1A
    SEC 
    SBC #$0002
    BRA DiaryCursorApplyMove
}

---------------------------------------------
; $1A += 2, then DiaryCursorApplyMove.

DiaryCursorPageDown {
    LDA $1A
    CLC 
    ADC #$0002
    BRA DiaryCursorApplyMove
}

---------------------------------------------
; Confirm: draw the cursor, SFX #11, consume the press, return A = $1A with carry set.

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

---------------------------------------------
; Cancel: consume the press, return A = $FFFF with carry set.

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

; Draw cursor highlight — writes tile $202B (highlight arrow) at the cursor's VRAM position.

DiaryDrawCursorHighlight {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@diary_cursor_menu_table, X
    SEC 
    SBC #$&diary_cursor_menu_table
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@diary_cursor_menu_table+2, X
    TAX 
    LDA #$202B
    STA $bg3TilemapBuffer, X
    PLX 
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

; Clear cursor — writes blank tile $2040 at the cursor's VRAM position to erase the highlight.

DiaryClearCursor {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@diary_cursor_menu_table, X
    SEC 
    SBC #$&diary_cursor_menu_table
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@diary_cursor_menu_table+2, X
    TAX 
    LDA #$2040
    STA $bg3TilemapBuffer, X
    PLX 
    RTS 
}
---------------------------------------------

; Clear all cursor positions in a sub-menu — writes blank tiles to every selectable row.
; Wraps the cursor index within the valid range using the count from diary_cursor_menu_table[0].

DiaryClearAllCursors {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@diary_cursor_menu_table, X
    SEC 
    SBC #$&diary_cursor_menu_table
    TAX 
    LDA $1A
    BPL loc_0BED12
    CLC 
    ADC $@diary_cursor_menu_table, X

; Wrap $1A into 0 .. count-1 (count = first word of the menu's list).

  loc_0BED12:
    CMP $@diary_cursor_menu_table, X
    BCC loc_0BED1D
    SEC 
    SBC $@diary_cursor_menu_table, X

; Store the wrapped position, then blank every cursor position of the menu.

  loc_0BED1D:
    STA $1A
    LDA $@diary_cursor_menu_table, X
    TAY 
    DEY 
    INX 
    INX 

; Blank loop: write tile $2040 at each BG3 tilemap offset of the menu.

  loc_0BED27:
    LDA $@diary_cursor_menu_table, X
    PHX 
    TAX 
    LDA #$2040
    STA $bg3TilemapBuffer, X
    PLX 
    INX 
    INX 
    DEY 
    BPL loc_0BED27
    PLX 
    RTS 
}
---------------------------------------------

; Menu table of the unreferenced cursor engine: four word pointers (menu index $14 = 0-3) to word lists [count, BG3 tilemap byte offsets of the cursor positions].

diary_cursor_menu_table [
  &word_0BED44   ;00
  &word_0BED4E   ;01
  &word_0BED54   ;02
  &word_0BED5C   ;03
]

---------------------------------------------
; Menu 0: 4 positions at BG3 tilemap offsets $014A, $01CA, $0160, $01E0 (rows 5 and 7, columns 5 and 16 of the 32-tile map).

word_0BED44 [
  #$0004   ;00
  #$014A   ;01
  #$01CA   ;02
  #$0160   ;03
  #$01E0   ;04
]

---------------------------------------------
; Menu 1: 2 positions at offsets $01CE and $01D8 (row 7, columns 7 and 12).

word_0BED4E [
  #$0002   ;00
  #$01CE   ;01
  #$01D8   ;02
]

---------------------------------------------
; Menu 2: 3 positions at offsets $02CA, $044A, $05CA (column 5, rows 11, 17 and 23).

word_0BED54 [
  #$0003   ;00
  #$02CA   ;01
  #$044A   ;02
  #$05CA   ;03
]

---------------------------------------------
; Menu 3: 3 positions at offsets $034A, $03CA, $044A (column 5, rows 13, 15 and 17).

word_0BED5C [
  #$0003   ;00
  #$034A   ;01
  #$03CA   ;02
  #$044A   ;03
]
---------------------------------------------

; Scan the three SRAM slots into the diary state block. The scene-ID, HP and DEF fields ($0D74-$0D84) are zeroed first (the second block of three stores repeats $0D80-$0D84, so the STR fields $0D86-$0D8A are never zeroed; they are only shown for slots with a nonzero scene ID, which overwrites them). Reads $306000 (last-used slot, reset to 0 when >= 3) into $0D8C. For slots 2, 1, 0 it recomputes both checksums and, when they match, copies sourceSceneId ($0B12), playerMaxHp ($0ACA), playerDef ($0ADC) and playerStr ($0ADE) from the slot page; $26 collects one validity bit per slot (bit n = slot n).

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
    STA $0D80             ; Repeats $0D80-$0D84; $0D86-$0D8A are not cleared
    STA $0D82
    STA $0D84
    LDA #$0002            ; $24 = slot counter, 2 down to 0
    STA $24
    STZ $26               ; $26 = validity bit mask (bit n = slot n)
    LDA $306000           ; Last-used slot (reset to 0 when 3 or more)
    CMP #$0003
    BCC loc_0BEDA3
    LDA #$0000
    STA $306000

; Store the last-used slot in $0D8C.

  loc_0BEDA3:
    STA $0D8C

; Per-slot loop: $24 = slot (2 down to 0), X = slot * 512.

  DiaryScanSramLoop:
    LDA $24
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum
    LDA $0018
    CMP $3063FC, X        ; Additive checksum vs stored $3063FC + slot * 512
    BNE loc_0BEE11
    LDA $001C
    CMP $3063FE, X        ; XOR checksum vs stored $3063FE + slot * 512
    BNE loc_0BEE11
    PHX 
    LDA $24
    ASL 
    TAY 
    TXA 
    CLC 
    ADC #$0B12            ; sourceSceneId ($0B12) -> $0D74,Y
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D74, Y
    LDA $01, S
    CLC 
    ADC #$0ACA            ; playerMaxHp ($0ACA) -> $0D7A,Y
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D7A, Y
    LDA $01, S
    CLC 
    ADC #$0ADC            ; playerDef ($0ADC) -> $0D80,Y
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D80, Y
    LDA $01, S
    CLC 
    ADC #$0ADE            ; playerStr ($0ADE) -> $0D86,Y
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D86, Y
    PLA 
    SEC                   ; Carry set = valid slot
    BRA loc_0BEE12

; Checksum mismatch: slot stays empty (carry clear).

  loc_0BEE11:
    CLC 

; Shift this slot's validity bit (carry) into $26 and move to the next slot.

  loc_0BEE12:
    ROL $26               ; Shift the validity bit into $26
    LDA $24
    DEC 
    STA $24
    BMI loc_0BEE1E
    JMP $&DiaryScanSramLoop

; All three slots scanned.

  loc_0BEE1E:
    PLX 
    RTS 
}
---------------------------------------------

; Unreferenced debug input filter for controller 2 ($E0 = pad word, $E2 = held mask): keeps only newly pressed buttons in $E0 and, on a fresh X ($0040), toggles bit 3 ($0008) of the player actor's $10 field.

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

; Return.

  loc_0BF1A1:
    RTL 
}
---------------------------------------------

; Unreferenced: $DE := 0.

DiaryResetCounter_noref {
    STZ $00DE
    RTL 
}
---------------------------------------------

; Unreferenced: $DE += 1.

DiaryIncCounter_noref {
    INC $00DE
    RTL 
}
---------------------------------------------

; Unreferenced debug display: while controller 2's B ($8000 in $E0) is held, show $DE as BCD digit sprites (ComposeDigitSprites_AtCursor) at the BG1 scroll + ($10, $70).

DiaryDigitDisplay_noref {
    LDA $00E0
    BIT #$8000
    BNE loc_0BF1B3
    RTL 

; B held: format $DE as BCD and compose the digit sprites.

  loc_0BF1B3:
    LDA $00DE
    JSR $&FormatBcdNumber
    STA $0000
    LDA $bg1ScrollH
    CLC 
    ADC #$0010
    STA $0018
    LDA $mapScrollV
    CLC 
    ADC #$0070
    STA $001C
    LDA #$3200
    STA $0002
    JSL $@oam_digit_compose.ComposeDigitSprites_AtCursor
    RTL 
}
---------------------------------------------

; BCD number formatter — converts a 16-bit value to packed hundreds:tens:ones format.
; Returns carry clear on success, carry set if value ≥ 1000 (overflow).
; Output: high byte = hundreds (×$100), low byte = tens (×$10) | ones.
; Values 500+ get pre-subtracted 500 with hundreds starting at 5.

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

; Hundreds: subtract 100 repeatedly, counting in $0000.

  loc_0BF1F8:
    CMP #$0064
    BCC loc_0BF206
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_0BF1F8

; Move the hundreds count to the high byte of $0000, then switch to 8-bit A for the tens.

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

; Tens: subtract 10 repeatedly, counting in $0000 (it starts at 5 when the remainder was 50 or more).

  loc_0BF222:
    CMP #$0A
    BCC loc_0BF22E
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_0BF222

; Pack tens:ones into the low byte, merge the hundreds byte, replace the saved input on the stack with the result and restore $0000.

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

; Value >= 1000: restore $0000, return the input unchanged with carry set.

  loc_0BF245:
    STY $0000
    PLA 
    SEC 
    RTS 
}
---------------------------------------------

; Unreferenced bytes extracted as code with the wrong register width. Read with 8-bit A they are LDA $E1 / BIT #$40 / BEQ (to the RTL) / LDA #$04 / JSL $82:81C9 (WaitFrames) / RTL: holding Y ($4000 in the $E0 word) on controller 2 adds a 4-frame wait (slow motion). An overrides.json M = 1 entry at 782923 would extract it correctly.

DiaryUnused24B_noref {
    LDA $00E1
    BIT #$F040
    ASL $A9
    TSB $22
    CMP #$8281
    RTL 
}
---------------------------------------------

; Unreferenced: read controller 2 (JOY2L/JOY2H, $421A/$421B) into $E0 for the debug routines above.

DiaryReadJoy2_noref {
    LDA $JOY2L
    STA $00E0
    RTL 
}
---------------------------------------------

; Unreferenced stub (RTL).

DiaryNullHandler_noref {
    RTL 
}
---------------------------------------------

; Unreferenced pause helper: if A is down ($0080 in joypadRaw) wait for it to be released, then for a fresh press, then for the release again, running the diary VBlank handler each frame - a press-A-to-pause toggle.

DiaryAwaitButtonRelease_noref {
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF2A5

; Wait for A to be released.

  loc_0BF269:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF269

; Wait for a new A press (paused).

  loc_0BF27D:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF27D

; Wait for A to be released again.

  loc_0BF291:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@DiaryMenuVBlankHandler
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF291

; Return.

  loc_0BF2A5:
    RTL 
}
---------------------------------------------

; Copy of the engine's VBlankWaitAndJoypad: waits for VBlank (RDNMI), uploads the Mode 7 registers when scrollModeFlags bit 3 is set, honours joypadInject, builds joypadRemapped from the D-pad plus each remap word (remapStart ... remapR), publishes it to joypadCurrent / joypadRaw, and applies the consumption mask, the 12-frame auto-repeat on joypadMaskInv and joypadMaskStd. Its only caller is the unreferenced DiaryAwaitButtonRelease_noref, so the live menu never runs it.

DiaryMenuVBlankHandler {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

; Poll RDNMI until bit 7 (VBlank) is set.

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

; Joypad part: honour joypadInject, otherwise remap.

  loc_0BF309:
    REP #$20
    LDA $joypadInject
    BEQ loc_0BF319
    STA $joypadCurrent
    STZ $joypadInject
    PLA 
    PLP 
    RTL 

; Start remapped joypad word: D-pad bits from joypadRaw, then Start.

  loc_0BF319:
    LDA $joypadRaw
    AND #$0F00
    STA $joypadRemapped
    LDA $remapStart
    BEQ loc_0BF335
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0BF335
    LDA $remapStart
    TSB $joypadRemapped

; Select remap: when remapSelect is nonzero and the raw bit is down, OR it in.

  loc_0BF335:
    LDA $remapSelect
    BEQ loc_0BF348
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0BF348
    LDA $remapSelect
    TSB $joypadRemapped

; B remap (remapB, raw bit $8000).

  loc_0BF348:
    LDA $remapB
    BEQ loc_0BF35B
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_0BF35B
    LDA $remapB
    TSB $joypadRemapped

; Y remap (remapY, raw bit $4000).

  loc_0BF35B:
    LDA $remapY
    BEQ loc_0BF36E
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_0BF36E
    LDA $remapY
    TSB $joypadRemapped

; A remap (remapA, raw bit $0080).

  loc_0BF36E:
    LDA $remapA
    BEQ loc_0BF381
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF381
    LDA $remapA
    TSB $joypadRemapped

; X remap (remapX, raw bit $0040).

  loc_0BF381:
    LDA $remapX
    BEQ loc_0BF394
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_0BF394
    LDA $remapX
    TSB $joypadRemapped

; L remap (remapL, raw bit $0020).

  loc_0BF394:
    LDA $remapL
    BEQ loc_0BF3A7
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_0BF3A7
    LDA $remapL
    TSB $joypadRemapped

; R remap (remapR, raw bit $0010).

  loc_0BF3A7:
    LDA $remapR
    BEQ loc_0BF3BA
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_0BF3BA
    LDA $remapR
    TSB $joypadRemapped

; Publish the remapped word to joypadCurrent / joypadRaw, update the consumption mask and start the auto-repeat counter for masked directions.

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

; Reset the auto-repeat counter.

  loc_0BF3E2:
    STZ $joypadRepeatCounter

; Remove consumed buttons and joypadMaskStd from joypadCurrent.

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

; Pointer table indexed by $0D94: the three slot stat-line strings (dialogstring_0BF4C3 / 0BF4EA / 0BF511) for the erase prompt.

diary_erase_stat_line_table [
  &dialogstring_0BF4C3+M   ;00
  &dialogstring_0BF4EA+M   ;01
  &dialogstring_0BF511+M   ;02
]
---------------------------------------------

; Main menu: the four tab names (Start Journey / Erase Trip Diary / Copy Trip Diary / Change Snd/Buttons).

dialogstring_0BF3F4 `[DLG:6,A][SIZ:A,4]Start Journey[N]Erase Trip Diary[N]Copy Trip Diary[N]Change Snd/Buttons`

---------------------------------------------
; Start Journey slot list: 'Which Diary?' and three rows, each naming the slot's location via diary_entry_table indexed by $0D74 / $0D76 / $0D78. The other slot-list titles JMP into its rows.

dialogstring_0BF437 `[DLG:2,8][SIZ:E,7]Which Diary?[N][::] Diary1 [ADR:&diary_entry_table,D74][N][N] Diary2 [ADR:&diary_entry_table,D76][N][N] Diary3 [ADR:&diary_entry_table,D78]`

---------------------------------------------
; Snd/Buttons slot picker title ('Change Snd/Button'), then the shared slot rows.

dialogstring_0BF476 `[DLG:2,8][SIZ:E,7]Change Snd/Button[N][JMP:&dialogstring_0BF437+M]`

---------------------------------------------
; 'Move which Diary?': the title of the Copy tab's source list, then the shared slot rows.

dialogstring_0BF48C `[DLG:2,8][SIZ:E,7]Move which Diary?[N][JMP:&dialogstring_0BF437+M]`

---------------------------------------------
; 'Erase which Diary?': the title of the Erase list, then the shared slot rows.

dialogstring_0BF4A7 `[DLG:2,8][SIZ:E,7]Erase which Diary?[N][JMP:&dialogstring_0BF437+M]`

---------------------------------------------
; Slot-1 stat line: HP / STR / DEF as BCD from $0D9A / $0D9C / $0D9E.

dialogstring_0BF4C3 `[DLG:2,C][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

---------------------------------------------
; Slot-2 stat line (same fields, one slot row lower).

dialogstring_0BF4EA `[DLG:2,10][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

---------------------------------------------
; Slot-3 stat line (same fields, one slot row lower).

dialogstring_0BF511 `[DLG:2,14][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

---------------------------------------------
; Snd/Buttons editor screen: rows End Changes / Sound / Button Type with the legend of the four button rows (Attack/Talk, Item/Cancel, Item palette, Not used).

dialogstring_0BF538 `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

---------------------------------------------
; 'Arrangement OK?' screen shown for a new game: rows Start Journey / Sound / Button Type with the same legend.

dialogstring_0BF5AD `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

---------------------------------------------
; Current sound value: diary_sound_value_table indexed by $0D90.

dialogstring_0BF625 `[DLG:D,C][SFX:0][ADR:&diary_sound_value_table,D90]`

---------------------------------------------
; Current button type legend: diary_button_legend_table indexed by $0D8E.

dialogstring_0BF630 `[DLG:11,E][SFX:0][ADR:&diary_button_legend_table,D8E]`
---------------------------------------------

; Button-type legend strings: Type 1 (0) and Type 2 (1).

diary_button_legend_table [
  &dialogstring_0BF63F   ;00
  &dialogstring_0BF653   ;01
]

---------------------------------------------
; Type 1 legend: A, B, SEL, Y against Attack/Talk, Item/Cancel, Item palette, Not used.

dialogstring_0BF63F `1[DLG:8,10]A[DLG:8,12]B[DLG:8,14]SEL[DLG:8,16]Y`

---------------------------------------------
; Type 2 legend: B, Y, SEL, A against the same four rows.

dialogstring_0BF653 `2[DLG:8,10]B[DLG:8,12]Y[DLG:8,14]SEL[DLG:8,16]A`
---------------------------------------------

; Sound value strings: Stereo (0), Mono (1).

diary_sound_value_table [
  &dialogstring_0BF66B   ;00
  &dialogstring_0BF672   ;01
]

dialogstring_0BF66B `Stereo`

dialogstring_0BF672 `Mono  `
---------------------------------------------

; Shown by the Copy tab when all three slots are used: 'Diary not empty / Erase and select'.

dialogstring_0BF679 `[DLG:4,15][SIZ:C,2][DLY:FF]Diary not empty[N]Erase and select[FIN][CLD]`
---------------------------------------------

; Stat line of the slot being erased: diary_erase_stat_line_table indexed by $0D94.

dialogstring_0BF6A4 `[DLG:4,A][ADR:&diary_erase_stat_line_table,D94]`
---------------------------------------------

; Erase prompt: the slot name (diary_erase_slot_name_table indexed by $0D94) then 'Erase diary? / No / Yes'.

dialogstring_0BF6B3 `[DLG:4,8][SIZ:D,5][ADR:&diary_erase_slot_name_table,D94][N][N]Erase diary? [N] No [N] Yes `
---------------------------------------------

; Slot-name strings for the erase prompt, indexed by $0D94.

diary_erase_slot_name_table [
  &dialogstring_0BF6DF   ;00
  &dialogstring_0BF6EC   ;01
  &dialogstring_0BF6F9   ;02
]

dialogstring_0BF6DF `Diary1 [ADR:&diary_entry_table,D74]`

dialogstring_0BF6EC `Diary2 [ADR:&diary_entry_table,D76]`

dialogstring_0BF6F9 `Diary3 [ADR:&diary_entry_table,D78]`