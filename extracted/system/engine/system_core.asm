; Core system loop and CPU interrupt vectors.
; 
; Contains the SNES reset vector (emulation → native mode switch), the COP/NMI/IRQ vectors, the hardware initialization and boot sequence (SystemInit), and the main game loop that runs the per-frame subsystems: VBlank sync, scene management, actor processing, sprite composition, camera scrolling, HUD update and the music-upload hook.
; 
; Also provides three context-specific frame update variants (all re-entrant, callable from COP handlers and from the NMI):
; - UpdateFrameDialogue: lightweight update during text/dialogue display
; - UpdateFrameRender: render-only update (sprite sort/compose, HDMA reset, HUD, cutscene thinkers) for menus and transitions
; - UpdateFrameFull: complete subsystem tick run from inside the NMI handler while the main loop is blocked in a music upload (musicTransitionState > 0)
; 
; The NMI handler manages VRAM DMA (scroll registers, dirty tilemap strips, CGRAM, OAM, the partial BG3 upload, then either the player tiles or the normal queued writes), reads the joypad auto-read result and sends the queued SFX byte to the SPC.
; 
; UpdateHUD runs the heads-up display: HP recovery animation (every 8th frame), stat dirty-checking (HP, max HP, gems) with a BG3 redraw, and the enemy health bar timer (a 60-frame hold, then the bar is cleared; the 25- and 30-frame values stored along the way are overwritten at once). UpdateFrameCounters maintains the invincibility timer and the capped global frame timer.
; 
; Utility routines: scroll register upload with layer priority support and the one-shot VRAM DMA (ExecuteVramDma). OamFillE0_unused/OamFillConstant_unused (an OAM fill) have no caller in extracted/.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_execution'
?INCLUDE 'camera_tilemap'
?INCLUDE 'combat_collision'
?INCLUDE 'cop_dispatch'
?INCLUDE 'event_blocks'
?INCLUDE 'GlobalInputHandler'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'math_lookup_tables'
?INCLUDE 'scene_lifecycle'
?INCLUDE 'spc_transfer'
?INCLUDE 'sprite_composition'
?INCLUDE 'system_init'
?INCLUDE 'system_strings'
?INCLUDE 'thinker_execution'
?INCLUDE 'vblank_joypad'
?INCLUDE 'warps_interaction'

!frameCounter                   0036
!oamWriteOffset                 00D8
!invincibilityTimer             040C
!globalFrameTimer               040E
!sceneNext                      0642
!worldReadyFlag                 0654
!joypadRaw                      0660
!bg1ScrollH                     068A
!mapScrollV                     068E
!scrollOverrideH                06C6
!scrollOverrideV                06CA
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!sfxQueueCh1                    06F8
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!sceneStateHelper               099F
!playerStateByte                09AF
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!enemyHpDisplay                 09E4
!enemyHpCurrentDisplay          09E6
!enemyHpPending                 09EA
!displayModeFlags               09EC
!hudDisableFlag                 09ED
!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!cachedPrevMaxHp                0ACC
!playerHp                       0ACE
!cachedPrevHp                   0AD0
!gemCount                       0AD6
!gemHundredsDigit               0AD8
!cachedPrevGems                 0ADA
!playerDef                      0ADC
!playerStr                      0ADE
!enemyHealthTimer               0AE4
!hpToHeal                       0B22
!hieroglyphSlots                0B28
!BG1HOFS                        210D
!BG1VOFS                        210E
!VMAIN                          2115
!VMADDL                         2116
!APUIO2                         2142
!WMADDL                         2181
!WMADDH                         2183
!MDMAEN                         420B
!HDMAEN                         420C
!MEMSEL                         420D
!HVBJOY                         4212
!JOY1L                          4218
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!oamComposeBuffer               7F3100

---------------------------------------------

; CPU reset entry point. Disables interrupts, clears carry, switches from 65816 emulation mode to native mode via XCE, then jumps long to SystemInit.

ResetVector {
    SEI 
    CLC 
    XCE 
    JML $@SystemInit
}

---------------------------------------------
; COP software interrupt vector. Jumps to the COP dispatch handler which implements the game's scripting command system.

CopVector {
    JML $@cop_dispatch.CopDispatch
}

---------------------------------------------
; NMI (V-Blank) interrupt vector. Jumps to the NMI handler for per-frame DMA transfers and display updates.

NmiVector {
    JML $@NmiHandler
}

---------------------------------------------
; Hardware IRQ vector. Jumps to IrqHandler (currently a stub — hardware IRQs are unused).

IrqVector {
    JML $@IrqHandler
}

---------------------------------------------
; IRQ handler stub. Returns immediately via RTI since no hardware IRQ sources are enabled.

IrqHandler {
    RTI 
}

---------------------------------------------
; Full system boot sequence and main game loop.
; 
; Boot phase:
; 1. Native 65816 mode, 16-bit registers
; 2. Direct page $0000, stack $01FF, data bank $81
; 3. FastROM access (MEMSEL = 1)
; 4. InitHardwareRegisters, InitSystemVariables, SpcLoadBuiltinEngine, EnterForcedBlank (the display stays off until the first scene transition)
; 5. Sets worldReadyFlag bit 7 (permits scene loading)
; 6. Reads the byte at $000100 and compares it with $83, but both outcomes leave Y = 0, so sceneNext = 0 for the first ExecuteSceneTransition: no scene is selected. No writer of $83 at $0100 was found (dialog_string_scanner uses $0100 as scratch).
; 7. Gameplay defaults: max speed 9 per axis, HP 8/8, Str 1, Def 0, slope curve pointers, the six hieroglyph plate slots ($0B28-$0B32) = $FFFF, abilityBitmask = 0
; 8. sceneNext = $FB (title screen), then falls into the main loop
; 
; Main loop (infinite):
; 1. VBlankWaitAndJoypad, EnableNmiOnly
; 2. Type-A thinkers, scene transition check, warp/chest check, global input, UpdateFrameCounters
; 3. RunActors_Normal, OAM terminator, depth sort, combat/interaction collision, death check, dodge callbacks
; 4. CameraSmoothScroll for layer 0 (BG1), then layer 1 (BG2)
; 5. ResetHdmaState, type-B thinkers, ComposeAllSprites, UpdateHUD
; 6. LoadMusicFromTransitionState (blocking SPC upload when a track ID is staged)
; 7. EnableNmiAndJoypad and loop

SystemInit {
    CLD 
    REP #$30              ; 16-bit A and X/Y for initialization sequence
    LDA #$0000
    TCD                   ; Direct page = $0000
    LDA #$01FF
    TCS                   ; Stack pointer = $01FF
    SEP #$20
    LDA #$81
    PHA 
    PLB                   ; Data bank = $81 (FastROM mirror of bank $01)
    LDA #$01
    STA $MEMSEL           ; Enable FastROM access speed (3.58 MHz for banks $80+)
    JSL $@system_init.InitHardwareRegisters
    JSL $@system_init.InitSystemVariables
    JSL $@spc_transfer.SpcLoadBuiltinEngine
    JSL $@vblank_joypad.EnterForcedBlank
    SEC 
    ROR $worldReadyFlag   ; Bit 7 = world-ready flag; permits scene loading
    LDA $000100           ; Read the byte at $000100 (the 'warmboot signature'); no writer of $83 there was found (OQ-50)
    LDY #$0000
    CMP #$83              ; Compare with $83: both outcomes leave Y = 0 (the second LDY #$0000 is identical), so no scene is selected
    BEQ loc_00804C
    LDY #$0000            ; Non-warmboot path: Y = 0 again, identical to the matching path

  loc_00804C:
    TYA 
    STA $sceneNext        ; sceneNext = 0 (low byte of Y) for the first ExecuteSceneTransition
    JSL $@scene_lifecycle.ExecuteSceneTransition ; Execute initial scene transition
    STZ $worldReadyFlag
    LDA #$20              ; Default sceneStateHelper: $20 palette bits
    STA $sceneStateHelper
    REP #$20
    LDA #$0009            ; Default max walk speed = 9 per axis
    STA $maxSpeedEw
    STA $maxSpeedNs
    LDA #$0008            ; Initial max HP and current HP = 8
    STA $playerMaxHp
    STA $playerHp
    LDA #$0001
    STA $playerStr
    LDA #$0000
    STA $playerDef
    LDA #$&math_lookup_tables.slope_curve_table ; Default slope acceleration curve pointer
    STA $slopeCurvePtrA
    STA $slopeCurvePtrB
    LDA #$&math_lookup_tables.slope_curve_table+20 ; Deceleration curve pointer = same table + $20 (the +20 operand is hexadecimal)
    STA $09C0             ; $09C0, $09BE, $09C4 get the same pointer; no other reference to them was found (OQ-52)
    STA $09BE
    STA $09C4
    STA $decelCurvePtr
    LDA #$FFFF            ; $FFFF = empty: clear the six hieroglyph plate slots $0B28-$0B32
    STA $hieroglyphSlots
    STA $0B2A
    STA $0B2C
    STA $0B2E
    STA $0B30
    STA $0B32
    SEP #$20
    LDA #$FB              ; Scene $FB = title screen / initial game startup
    STA $sceneNext
    LDA #$00
    STA $abilityBitmask   ; Clear ability bitmask — no abilities unlocked at start

; The main game loop: one pass per frame, entered after SystemInit and never left (the last instruction is BRL MainLoop).
; 
; Order of one pass: VBlankWaitAndJoypad (frame sync and joypad read), EnableNmiOnly, RunThinkers_TypeA, CheckSceneTransition, CheckWarpAndChest, GlobalInputHandler, UpdateFrameCounters, RunActors_Normal, the $FF terminator for the OAM compose buffer, SortActorsByDepth, the four collision passes (RunCombatCollision, RunInteractionCollision, CheckPlayerDeath, ProcessDodgeCallbacks), CameraSmoothScroll for layer 0 and layer 1, ResetHdmaState, RunThinkers_TypeB, ComposeAllSprites, UpdateHUD, LoadMusicFromTransitionState, EnableNmiAndJoypad.

  MainLoop:
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; === Main game loop entry: VBlank sync + joypad read ===
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@thinker_execution.RunThinkers_TypeA ; Run general-purpose thinkers (ambient effects, palette cycling)
    JSL $@scene_lifecycle.CheckSceneTransition ; Check if scene transition is pending
    JSL $@warps_interaction.CheckWarpAndChest ; Check warp triggers and treasure chests
    JSL $@GlobalInputHandler ; Process global input (menu, ability shortcuts)
    JSR $&UpdateFrameCounters
    JSL $@actor_execution.RunActors_Normal ; Run all active actor AI scripts
    LDX $oamWriteOffset   ; OAM write index — terminate sprite list with $FF sentinels
    LDA #$FF
    STA $oamComposeBuffer, X ; $FF sentinels terminate OAM composition buffer
    STA $oamComposeBuffer+1, X
    JSL $@sprite_composition.SortActorsByDepth ; Sort actors by Y-depth for sprite layering
    JSL $@combat_collision.RunCombatCollision ; Combat collision: player attacks + enemy contact
    JSL $@combat_collision.RunInteractionCollision ; Interaction collision: NPC/object touch triggers
    JSL $@combat_collision.CheckPlayerDeath ; Check if player HP is zero → game over
    JSL $@combat_collision.ProcessDodgeCallbacks ; Process B-button dodge callbacks
    LDX #$0000            ; Scroll layer 0 (BG1); X is the layer index and each call handles both axes
    JSL $@camera_tilemap.CameraSmoothScroll
    LDX #$0002            ; Scroll layer 1 (BG2)
    JSL $@camera_tilemap.CameraSmoothScroll
    JSL $@hdma_dma_spc.ResetHdmaState ; Reset HDMA state for this frame
    JSL $@thinker_execution.RunThinkers_TypeB ; Run deferred thinkers (secondary effects)
    JSL $@sprite_composition.ComposeAllSprites ; Compose all sprites into OAM buffer
    JSL $@UpdateHUD       ; Update HUD: HP bar, stats, enemy health
    JSL $@hdma_dma_spc.LoadMusicFromTransitionState ; Start a pending music change: blocking SPC upload while musicTransitionState > 0 (NMI runs UpdateFrameFull meanwhile)
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Enable NMI + joypad auto-read
    BRL MainLoop          ; Branch always — infinite main loop

; Lightweight frame update called during dialogue and text display.
; 
; Saves and restores the full register context (B, A, X, Y, D) so it can be called re-entrantly from COP script handlers. Runs RunActors_CutsceneOnly, the OAM terminator, depth sort, camera scroll for both layers, ResetHdmaState, the type-D thinkers and sprite composition, then clears displayModeFlags bit 3 (player-tile DMA pending) so the NMI of this frame does the normal VRAM path, waits for VBlank and runs the type-C thinkers. It skips the full actor AI pass and the warp/chest checks of the main loop.

  UpdateFrameDialogue:
    PHB                   ; Full register save for re-entrant dialogue frame update
    PHA 
    XBA 
    PHA 
    PHX 
    PHY 
    PHD 
    REP #$20
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@actor_execution.RunActors_CutsceneOnly ; Run cutscene-only actors (skip full AI pass)
    LDX $oamWriteOffset
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $oamComposeBuffer+1, X
    JSL $@sprite_composition.SortActorsByDepth
    LDX #$0000
    JSL $@camera_tilemap.CameraSmoothScroll
    LDX #$0002
    JSL $@camera_tilemap.CameraSmoothScroll
    JSL $@hdma_dma_spc.ResetHdmaState
    JSL $@thinker_execution.RunThinkers_TypeD
    JSL $@sprite_composition.ComposeAllSprites
    LDA #$08              ; Clear bit 3 (player-tile DMA pending) so this frame's NMI does the normal VRAM path, not DmaPlayerTilesToVram
    TRB $displayModeFlags
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@thinker_execution.RunThinkers_TypeC ; Run cutscene primary thinkers
    PLD 
    PLY 
    PLX 
    PLA 
    XBA 
    PLA 
    PLB 
    RTL 
}

---------------------------------------------
; Minimal frame update for render-only contexts such as menus and screen transitions.
; 
; Saves the full register context. Runs only SortActorsByDepth, ComposeAllSprites, ResetHdmaState, the type-D thinkers, UpdateHUD, the VBlank sync and the type-C thinkers. Does not run actor AI, camera scrolling or the OAM terminator; the caller is expected to have handled those.

UpdateFrameRender {
    PHB 
    PHA 
    XBA 
    PHA 
    PHX 
    PHY 
    PHD 
    REP #$20
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@sprite_composition.SortActorsByDepth ; Render-only: sort and compose sprites without AI pass
    JSL $@sprite_composition.ComposeAllSprites
    JSL $@hdma_dma_spc.ResetHdmaState
    JSL $@thinker_execution.RunThinkers_TypeD
    JSL $@UpdateHUD       ; Update HUD in render-only mode
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@thinker_execution.RunThinkers_TypeC
    PLD 
    PLY 
    PLX 
    PLA 
    XBA 
    PLA 
    PLB 
    RTL 
}

---------------------------------------------
; Complete single-frame update run from inside the NMI handler while the main loop is blocked in a music upload.
; 
; NmiHandler calls it when musicTransitionState is positive, i.e. while LoadMusicFromTransitionState is running SpcBlockTransfer with NMI enabled. Runs the type-C thinkers, RunActors_OverlayOnly, the OAM terminator, depth sort, camera scroll for both layers, ResetHdmaState, the type-D thinkers and sprite composition, between EnableNmiOnly/VBlankPartial and EnableNmiAndJoypad, so the screen keeps animating during the transfer.

UpdateFrameFull {
    PHP 
    SEP #$20
    JSL $@vblank_joypad.EnableNmiOnly ; Enable NMI for partial V-Blank during music transition
    PHB 
    LDA #$81
    PHA 
    PLB 
    JSL $@vblank_joypad.VBlankPartial
    JSL $@thinker_execution.RunThinkers_TypeC
    JSL $@actor_execution.RunActors_OverlayOnly ; Run the overlay-only actor pass; UpdateFrameFull is driven from the NMI while the blocking SPC music upload runs
    LDX $oamWriteOffset
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $oamComposeBuffer+1, X
    JSL $@sprite_composition.SortActorsByDepth
    LDX #$0000
    JSL $@camera_tilemap.CameraSmoothScroll
    LDX #$0002
    JSL $@camera_tilemap.CameraSmoothScroll
    JSL $@hdma_dma_spc.ResetHdmaState
    JSL $@thinker_execution.RunThinkers_TypeD
    JSL $@sprite_composition.ComposeAllSprites
    PLB 
    JSL $@vblank_joypad.EnableNmiAndJoypad
    PLP 
    RTL 
}

---------------------------------------------
; Manages the in-game heads-up display for HP, gems and enemy health.
; 
; Returns at once if $09ED bit 6 (HUD off) is set. displayModeFlags bit 0 (full BG3 upload request) is saved on entry and restored on exit, so the BG3 redraw scripts below do not leave a full upload pending; the HUD uses the partial upload (bit 4) instead.
; 
; HP recovery animation:
; - Skipped when playerStateByte bit 1 (game over, playerFlags bit 9) is set, off an 8-frame boundary, or when hpToHeal is 0
; - Decrements hpToHeal and increments playerHp (the displayed HP) toward playerMaxHp, playing sound $0D on each tick; stops when HP equals max HP
; 
; Stat display update:
; - Compares HP, max HP and gem count with the cached previous values
; - On any change: sets displayModeFlags bit 4 (partial BG3 upload), counts the hundreds digit of the gem count by repeated subtraction of 100, and redraws the counters with a BG3 console script
; 
; Enemy health bar:
; - When enemyHpPending is nonzero: draws the bar and sets enemyHealthTimer to 60 (the $19 stored first is overwritten)
; - Otherwise the timer counts down; at 0 the displayed enemy HP is cleared and the bar redrawn at once (the $1E stored first is overwritten by the STZ, so there is no separate fadeout phase)
; 
; Finally caches HP, max HP and gems for the next frame's change detection and restores displayModeFlags bit 0.

UpdateHUD {
    LDA $hudDisableFlag
    BIT #$40              ; Bit 6 = HUD suppression; if set, skip entire update
    BEQ UpdateHUD_Active
    RTL 

; Body of UpdateHUD, entered when hudDisableFlag bit 6 (HUD off) is clear: it saves displayModeFlags bit 0 and runs the HP recovery animation, the stat-change redraw, the enemy health bar timer and the cache update described in the UpdateHUD note.

  UpdateHUD_Active:
    PHP 
    LDX #$0000
    SEP #$20
    LDA $displayModeFlags ; Save displayModeFlags bit 0 (full BG3 upload request); restored at exit
    AND #$01              ; Isolate bit 0; the HUD redraw scripts set it and it is put back below
    PHA 
    LDA $playerStateByte
    BIT #$02              ; playerStateByte bit 1 = playerFlags bit 9 ($0200, game over): no HP recovery animation
    BNE loc_008244
    LDA $frameCounter
    BIT #$07              ; Throttle HP recovery to every 8 frames (BIT #$07)
    BNE loc_008244
    LDA $hpToHeal         ; Check hpToHeal: 0 = no recovery animation
    BEQ loc_008244
    DEC 
    STA $hpToHeal
    LDA $playerHp
    CMP $playerMaxHp
    BNE loc_00823E
    STZ $hpToHeal
    BRA loc_008244

  loc_00823E:
    INC $playerHp         ; Animate: increment displayed HP toward max
    COP [PlaySoundCh2] ( #0D ) ; Play HP recovery tick sound ($0D)

  loc_008244:
    LDA $playerHp
    CMP $cachedPrevHp
    BNE loc_00825C
    LDA $playerMaxHp
    CMP $cachedPrevMaxHp
    BNE loc_00825C
    LDA $gemCount
    CMP $cachedPrevGems
    BEQ loc_008279

  loc_00825C:
    LDA #$10              ; Bit 4: request the partial BG3 upload ($0140 bytes to VRAM $7840, camera_tilemap.Bg3TilemapVramDma)
    TSB $displayModeFlags
    REP #$20
    STZ $gemHundredsDigit ; Zero the hundreds digit accumulator
    LDA $gemCount

  loc_008269:
    SEC                   ; Repeated subtraction by 100 to extract hundreds digit
    SBC #$0064
    BMI loc_008274
    INC $gemHundredsDigit
    BRA loc_008269

  loc_008274:
    COP [RunBg3Script] ( @system_strings.consolestring_01E7F6 ) ; Redraw gem/stat counters via BG3 console script

  loc_008279:
    REP #$20
    LDA $enemyHpPending   ; Enemy HP pending? nonzero → refresh display
    BEQ loc_008299
    LDA #$0019            ; Timer preset $19 (25); overwritten with $3C below, so it never takes effect (OQ-53)
    STA $enemyHealthTimer
    COP [RunBg3Script] ( @system_strings.consolestring_01E818 )
    LDA #$0010
    TSB $displayModeFlags
    LDA #$003C            ; Timer = 60 frames: the real hold time before the bar is cleared
    STA $enemyHealthTimer
    BRA loc_0082BD

  loc_008299:
    LDA $enemyHealthTimer
    BEQ loc_0082BD
    DEC $enemyHealthTimer ; Count the hold down; at 0 the bar is cleared at once (no fadeout phase)
    BNE loc_0082BD
    LDA #$001E            ; $1E (30) is overwritten by the STZ enemyHealthTimer below: no 30-frame fadeout exists (OQ-53)
    STA $enemyHealthTimer
    STZ $enemyHpCurrentDisplay ; Clear the displayed enemy HP values (enemyHpCurrentDisplay, enemyHpDisplay)
    STZ $enemyHpDisplay
    COP [RunBg3Script] ( @system_strings.consolestring_01E818 )
    LDA #$0010
    TSB $displayModeFlags
    STZ $enemyHealthTimer

  loc_0082BD:
    LDA $playerHp         ; Cache current stats for next-frame change detection
    STA $cachedPrevHp
    LDA $playerMaxHp
    STA $cachedPrevMaxHp
    LDA $gemCount
    STA $cachedPrevGems
    SEP #$20
    LDA $displayModeFlags
    AND #$FE              ; Restore bit 0 as saved on entry (drops full-upload requests raised by the HUD scripts)
    ORA $01, S
    STA $displayModeFlags
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Per-frame timer maintenance subroutine (called via JSR from main loop).
; 
; Decrements the invincibility timer if it's non-negative (bit 15 clear = active). Increments the global frame timer, capping it at $0100 to prevent overflow. Both operations use 16-bit mode.

UpdateFrameCounters {
    PHP 
    REP #$20
    LDA $invincibilityTimer ; Decrement invincibility timer if non-negative (bit 15 clear)
    BMI loc_0082EA
    DEC 
    STA $invincibilityTimer

  loc_0082EA:
    LDA $globalFrameTimer ; Global frame timer: increment, capped at $0100
    CMP #$0100
    BCS loc_0082F3
    INC 

  loc_0082F3:
    STA $globalFrameTimer
    PLP 
    RTS 
}

---------------------------------------------
; V-Blank interrupt handler — the per-frame DMA orchestration routine.
; 
; Execution order:
; 1. Save registers, data bank = $81
; 2. Disable HDMA (HDMAEN = 0) to avoid bus conflicts
; 3. UploadScrollRegisters
; 4. FlushDirtyTilemapStrips (dirty column/row data)
; 5. UploadCgramPalette (512 bytes from $7F0A00)
; 6. UploadOamTable (544 bytes from $0422)
; 7. Bg3TilemapVramDma: partial BG3 upload when displayModeFlags bit 4/5 is set
; 8. VMAIN = $80, BBAD0 = $18, DMAP0 = $01 (word writes to VRAM)
; 9. If displayModeFlags bit 3 is set: DmaPlayerTilesToVram only. Otherwise DmaAdhocVramBlock, FlushVramWriteQueue and ExecuteVramDma; with dmaSkipFlag set, only FlushVramWriteQueue
; 10. Re-enable the HDMA channels from the mask in $66
; 11. Spin until the joypad auto-read finishes, store JOY1L in joypadRaw
; 12. If musicTransitionState is positive (SPC music upload in progress in the main loop): run UpdateFrameFull
; 13. Otherwise write APUIO2: 0 on odd frames, the dequeued sfxQueueCh1 byte on even frames
; 14. Increment the frame parity counter ($36) and restore registers

NmiHandler {
    PHP 
    PHB 
    REP #$20
    PHA 
    PHX 
    PHY 
    CLD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    STZ $HDMAEN           ; Disable HDMA during V-Blank DMA transfers
    JSR $&UploadScrollRegisters
    JSL $@camera_tilemap.FlushDirtyTilemapStrips ; DMA dirty tilemap strip columns/rows to VRAM
    JSL $@system_init.UploadCgramPalette ; Upload 512-byte CGRAM palette from $7F0A00
    JSL $@system_init.UploadOamTable ; Upload 544-byte OAM table from $0422
    JSL $@camera_tilemap.Bg3TilemapVramDma ; Bg3TilemapVramDma: partial BG3 upload when displayModeFlags bit 4/5 is set
    LDA #$80              ; VMAIN=$80: word-mode VRAM access, auto-increment high byte
    STA $VMAIN
    LDA #$18              ; BBAD0=$18: VRAM data write port target
    STA $BBAD0
    LDA #$01              ; DMAP0=$01: two-register DMA (word increment mode)
    STA $DMAP0
    LDA $displayModeFlags
    BIT #$08              ; Bit 3 = player-tile DMA pending: do DmaPlayerTilesToVram instead of the normal VRAM path
    BNE loc_00834A
    LDA $dmaSkipFlag      ; dmaSkipFlag nonzero: skip adhoc DMA and ExecuteVramDma, still flush the write queue
    BNE loc_008344
    JSL $@hdma_dma_spc.DmaAdhocVramBlock
    JSL $@event_blocks.FlushVramWriteQueue
    JSR $&ExecuteVramDma
    BRA loc_00834E

  loc_008344:
    JSL $@event_blocks.FlushVramWriteQueue
    BRA loc_00834E

  loc_00834A:
    JSL $@hdma_dma_spc.DmaPlayerTilesToVram

  loc_00834E:
    LDA $66               ; Re-enable HDMA channels from cached mask (DP $66)
    STA $HDMAEN
    REP #$20

  loc_008355:
    LDA $HVBJOY           ; Spin-wait until auto-joypad read completes
    ROR 
    BCS loc_008355
    LDA $JOY1L            ; Latch hardware joypad register to joypadRaw
    STA $joypadRaw
    LDA $musicTransitionState ; musicTransitionState: 0 idle, > 0 SPC upload in progress, $FFFF finished
    BEQ loc_00836E
    BMI loc_00837F
    JSL $@UpdateFrameFull ; SPC upload in progress in the main loop: run a full frame update from NMI so the game keeps animating
    BRA loc_00837F

  loc_00836E:
    LDA $36
    LSR                   ; Frame parity bit: odd frames write 0 to APUIO2, even frames send the dequeued SFX ID
    LDA #$0000
    BCS loc_00837C
    LDA $sfxQueueCh1      ; Dequeue pending sound effect for SPC transfer
    STZ $sfxQueueCh1

  loc_00837C:
    STA $APUIO2           ; Write audio command to SPC I/O port 2 ($2142)

  loc_00837F:
    INC $36               ; Increment frame parity counter
    PLY 
    PLX 
    PLA 
    PLB 
    PLP 
    RTI 
}

---------------------------------------------
; Writes BG1 and BG2 scroll positions to PPU hardware registers.
; 
; Two modes based on scrollModeFlags bit 3:
; - Normal mode: Uses WriteBgScroll with indexed layer data. Respects layerPriorityFlag — when negative, swaps the order BG1/BG2 are written to handle layer priority changes.
; - Direct mode (bit 3 set): Writes bg1ScrollH/mapScrollV directly to BG1HOFS/BG1VOFS registers, masking high bytes to 7 bits.

UploadScrollRegisters {
    LDA $scrollModeFlags
    BIT #$08              ; Bit 3 = direct scroll write mode (bypass indexed system)
    BNE loc_0083B7
    LDA $layerPriorityFlag ; Negative priority flag = swap BG1/BG2 write order
    BMI loc_0083A4
    LDX #$0000
    LDY #$0000
    JSR $&WriteBgScroll
    LDX #$0002
    LDY #$0002
    BRA loc_0083B3

  loc_0083A4:
    LDX #$0002
    LDY #$0000
    JSR $&WriteBgScroll
    LDX #$0000
    LDY #$0002

  loc_0083B3:
    JSR $&WriteBgScroll
    RTS 

  loc_0083B7:
    LDA $bg1ScrollH       ; Direct scroll mode: write registers without layer indexing
    STA $BG1HOFS
    LDA $068B
    AND #$7F
    STA $BG1HOFS
    LDA $mapScrollV
    STA $BG1VOFS
    LDA $068F
    AND #$7F
    STA $BG1VOFS
    RTS 
}

---------------------------------------------
; Writes horizontal and vertical scroll values for one background layer.
; 
; X index selects the scroll data source (0=BG1, 2=BG2). Y index selects the PPU register target.
; 
; For each axis (H and V), checks an override flag at $06C7+X / $06CB+X:
; - If negative (bit 7 set): uses the scroll override value instead of normal scroll
; - If positive: uses the standard scroll position
; 
; High bytes are masked to 2 bits (10-bit scroll position for Mode 1 backgrounds).

WriteBgScroll {
    LDA $06C7, X          ; Check horizontal scroll override flag for this layer
    BPL loc_0083E4
    LDA $scrollOverrideH, X
    STA $BG1HOFS, Y
    LDA $06C7, X
    BRA loc_0083ED

  loc_0083E4:
    LDA $bg1ScrollH, X
    STA $BG1HOFS, Y
    LDA $068B, X

  loc_0083ED:
    AND #$03              ; Mask to 2 bits — high portion of 10-bit scroll position
    STA $BG1HOFS, Y
    LDA $06CB, X          ; Check vertical scroll override flag for this layer
    BPL loc_008402
    LDA $scrollOverrideV, X
    STA $BG1VOFS, Y
    LDA $06CB, X
    BRA loc_00840B

  loc_008402:
    LDA $mapScrollV, X
    STA $BG1VOFS, Y
    LDA $068F, X

  loc_00840B:
    AND #$03
    STA $BG1VOFS, Y
    RTS 
}

---------------------------------------------
; Executes a single VRAM DMA transfer using pre-staged parameters.
; 
; Reads transfer parameters from direct page:
; - $00B2: byte count (0 = skip)
; - $00B0: VRAM destination address
; - $00AC-$00AE: ROM/RAM source address (16-bit + bank)
; 
; Triggers DMA channel 0 and clears the byte count to prevent re-triggering.

ExecuteVramDma {
    LDX $00B2             ; Byte count at DP $B2; zero = no pending DMA transfer
    BNE loc_008417        ; Nonzero byte count at DP $B2: DMA transfer pending, branch to process
    RTS 

  loc_008417:
    STX $DAS0L            ; Set DMA transfer size from $B2
    LDX $00B0
    STX $VMADDL           ; Set VRAM destination from $B0
    LDX $00AC             ; Set source address from $AC/$AE
    STX $A1T0L
    LDA $00AE
    STA $A1B0
    LDA #$01              ; Trigger DMA channel 0
    STA $MDMAEN
    LDX #$0000            ; Clear byte count to prevent re-trigger
    STX $00B2
    RTS 
}

---------------------------------------------
; Fills the OAM staging buffer at WRAM $0422 with the byte $E0 via DMA.
; 
; Uses DMA fixed-source mode ($08) to repeat one byte across 512 bytes (128 OAM entries × 4 bytes) through the WRAM data port ($2180). $E0 puts every sprite Y at 224, below the visible area.
; 
; Unreferenced: no caller of OamFillE0_unused was found in extracted/.

OamFillE0_unused {
    PHP 
    SEP #$20
    LDA #$00
    STA $WMADDH
    REP #$20
    LDA #$0422            ; Target: WRAM $0422 (OAM staging buffer)
    STA $WMADDL
    LDY #$0200            ; $0200 = 512 bytes (128 OAM entries × 4 bytes each)
    STY $DAS0L
    SEP #$20
    LDA #$08              ; DMA mode $08: fixed-source fill
    STA $DMAP0
    LDA #$80              ; B-bus $80 = WRAM data port ($2180)
    STA $BBAD0
    LDA #$^OamFillConstant_unused
    STA $A1B0
    LDX #$&OamFillConstant_unused
    STX $A1T0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS                   ; Fill value $E0: offscreen Y position (224 = bottom edge)
}

---------------------------------------------
; Single-byte constant ($E0) used as the fixed DMA source by OamFillE0_unused (which has no caller). $E0 = 224 puts a sprite just below the 224-line display.

OamFillConstant_unused #E0