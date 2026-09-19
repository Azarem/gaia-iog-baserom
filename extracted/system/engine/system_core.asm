; Core system loop and CPU interrupt vectors.
; 
; Contains the SNES reset vector (emulation → native mode switch), COP/NMI/IRQ dispatchers, the full hardware initialization and boot sequence (SystemInit), and the main game loop that orchestrates all per-frame subsystems: VBlank sync, scene management, actor processing, sprite composition, camera scrolling, HUD updates, and display list flushing.
; 
; Also provides three context-specific frame update variants:
; - UpdateFrameDialogue: lightweight update during text/dialogue display
; - UpdateFrameRender: minimal render-only update for menus/transitions
; - UpdateFrameFull: complete subsystem tick during music transitions
; 
; The NMI handler manages all VRAM DMA transfers (scroll registers, tilemap strips, CGRAM, OAM, sprite tiles, event blocks) and handles joypad polling and SPC audio I/O.
; 
; UpdateHUD manages the in-game heads-up display — HP recovery animation with 8-frame tick throttling, stat display dirty-checking (HP, max HP, gems) with BG3 redraw via BCD conversion, and a three-phase enemy health bar timer chain (25-frame display, 60-frame hold, 30-frame fadeout). UpdateFrameCounters maintains the invincibility timer and global frame counter.
; 
; Utility routines include scroll register upload with layer priority support, VRAM DMA execution, and WRAM block fill for OAM clearing.
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

!invincibilityTimer             040C
!globalFrameTimer               040E
!sceneNext                      0642
!worldReadyFlag                 0654
!joypadRaw                      0660
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!scrollOverrideH                06C6
!scrollOverrideV                06CA
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!sfxQueueCh1                    06F8
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!sceneStateHelper               099F
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!enemyHpDisplay                 09E4
!enemyHpPending                 09EA
!displayModeFlags               09EC
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
!damageFlashTimer               0B22
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
; 1. Sets native 65816 mode with 16-bit registers
; 2. Initializes direct page ($0000), stack ($01FF), data bank ($81)
; 3. Enables FastROM access speed
; 4. Calls hardware register init, system variable init, SPC engine load
; 5. Enables display and sets world-ready flag
; 6. Checks warmboot signature at $000100 for scene selection
; 7. Initializes gameplay defaults: movement speeds, defense, HP, slope curves, ability slots
; 8. Sets starting scene to $FB (title screen)
; 
; Main loop (infinite):
; 1. VBlank wait and joypad read
; 2. Scene management and warp/chest checks
; 3. Actor AI processing and sprite composition
; 4. Camera scrolling for both BG layers
; 5. HUD update and display list flush
; 6. Enable NMI and loop

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
    LDA $000100           ; Check warmboot signature byte at $000100
    LDY #$0000
    CMP #$83              ; Warmboot marker = $83; Y = starting scene if match
    BEQ loc_00804C
    LDY #$0000

  loc_00804C:
    TYA 
    STA $sceneNext        ; Store initial scene ID from warmboot result (Y=0 default)
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
    LDA #$&math_lookup_tables.scene_flag_table ; Default slope acceleration curve pointer
    STA $slopeCurvePtrA
    STA $slopeCurvePtrB
    LDA #$&math_lookup_tables.scene_flag_table+20 ; Default slope deceleration curve pointer (+$14 offset)
    STA $09C0
    STA $09BE
    STA $09C4
    STA $decelCurvePtr
    LDA #$FFFF            ; $FFFF sentinel — clear all 6 ability slot registers
    STA $0B28
    STA $0B2A
    STA $0B2C
    STA $0B2E
    STA $0B30
    STA $0B32
    SEP #$20              ; Scene $FB = title screen startup
    LDA #$FB              ; Scene $FB = title screen / initial game startup
    STA $sceneNext
    LDA #$00              ; Clear ability bitmask — no abilities unlocked
    STA $abilityBitmask   ; Clear ability bitmask — no abilities unlocked at start

  loc_0080B5:
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; === Main game loop entry: VBlank sync + joypad read ===
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@thinker_execution.RunThinkers_TypeA ; Run general-purpose thinkers (ambient effects, palette cycling)
    JSL $@scene_lifecycle.CheckSceneTransition ; Check if scene transition is pending
    JSL $@warps_interaction.CheckWarpAndChest ; Check warp triggers and treasure chests
    JSL $@GlobalInputHandler ; Process global input (menu, ability shortcuts)
    JSR $&UpdateFrameCounters
    JSL $@actor_execution.RunActors_Normal ; Run all active actor AI scripts
    LDX $00D8             ; OAM write index — terminate sprite list with $FF sentinels
    LDA #$FF
    STA $oamComposeBuffer, X ; $FF sentinels terminate OAM composition buffer
    STA $7F3101, X
    JSL $@sprite_composition.SortActorsByDepth ; Sort actors by Y-depth for sprite layering
    JSL $@combat_collision.RunCombatCollision ; Combat collision: player attacks + enemy contact
    JSL $@combat_collision.RunInteractionCollision ; Interaction collision: NPC/object touch triggers
    JSL $@combat_collision.CheckPlayerDeath ; Check if player HP is zero → game over
    JSL $@combat_collision.ProcessDodgeCallbacks ; Process B-button dodge callbacks
    LDX #$0000            ; Scroll camera BG1 (X=0 selects horizontal layer)
    JSL $@camera_tilemap.CameraSmoothScroll
    LDX #$0002            ; Scroll camera BG2 (X=2 selects vertical layer)
    JSL $@camera_tilemap.CameraSmoothScroll
    JSL $@hdma_dma_spc.ResetHdmaState ; Reset HDMA state for this frame
    JSL $@thinker_execution.RunThinkers_TypeB ; Run deferred thinkers (secondary effects)
    JSL $@sprite_composition.ComposeAllSprites ; Compose all sprites into OAM buffer
    JSL $@UpdateHUD       ; Update HUD: HP bar, stats, enemy health
    JSL $@hdma_dma_spc.LoadMusicFromTransitionState ; Process music fade/transition state
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Enable NMI + joypad auto-read
    BRL loc_0080B5        ; Branch always — infinite main loop

; Lightweight frame update called during dialogue and text display.
; 
; Saves and restores full register context (B, A, X, Y, D) for safe re-entrant calling from within COP script handlers. Runs actor rendering (RunActors_CutsceneOnly variant), OAM termination, sprite composition, camera scrolling, HDMA updates, display sync, and scene tick — but skips the full actor AI pass and warp/chest checks that the main loop performs.
; 
; Clears bit 3 of displayModeFlags after rendering to signal dialogue frame completion.

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
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
    JSL $@sprite_composition.SortActorsByDepth
    LDX #$0000
    JSL $@camera_tilemap.CameraSmoothScroll
    LDX #$0002
    JSL $@camera_tilemap.CameraSmoothScroll
    JSL $@hdma_dma_spc.ResetHdmaState
    JSL $@thinker_execution.RunThinkers_TypeD
    JSL $@sprite_composition.ComposeAllSprites
    LDA #$08              ; Clear bit 3 — dialogue frame rendering complete
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
; Saves full register context. Runs only sprite composition, palette/display processing, HDMA updates, HUD update, VBlank sync, and scene tick. Does not run actor AI, camera scrolling, or OAM termination — assumes those are handled by the caller's context.

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
; Complete single-frame update used during music transitions.
; 
; Runs all subsystems including VBlank partial wait, scene tick, actor AI (RunActors_OverlayOnly variant), OAM termination, sprite composition, camera scrolling for both BG layers, HDMA updates, and display list processing. Called from within the NMI handler when musicTransitionState is positive, allowing visual animation to continue during music fade sequences.

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
    JSL $@actor_execution.RunActors_OverlayOnly ; Run overlay actors during music fade
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
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
; Manages the in-game heads-up display for HP, gems, and enemy health.
; 
; First checks $09ED bit 6 (HUD suppression flag) — returns immediately if set.
; 
; HP recovery animation:
; - Skipped if secondary lock ($09AF bit 1) is set or not on an 8-frame boundary
; - Decrements damageFlashTimer and increments displayed HP (playerHp) toward max (playerMaxHp)
; - Plays sound effect $0D on each recovery tick
; - Stops when current HP equals max HP
; 
; Stat display update:
; - Compares current HP, max HP, and gem count against cached values
; - If any changed: sets VRAM dirty flag (bit 4), converts gem count to decimal via repeated /100, redraws stat counters via BG3 script
; 
; Enemy health display:
; - When enemyHpPending is nonzero, sets display timer and redraws
; - Timer chain: 25 frames (display) → 60 frames (hold) → 30 frames (fadeout) → clear
; 
; Finally caches all stat values for next-frame dirty detection and restores the original status bar visibility flag.

UpdateHUD {
    LDA $09ED
    BIT #$40              ; Bit 6 = HUD suppression; if set, skip entire update
    BEQ loc_00820E
    RTL 

  loc_00820E:
    PHP 
    LDX #$0000
    SEP #$20
    LDA $displayModeFlags ; Load current status bar visibility (bit 0) on stack
    AND #$01              ; Save displayModeFlags bit 0 (status bar visibility)
    PHA 
    LDA $09AF
    BIT #$02              ; Bit 1 = secondary HUD lock; skip HP recovery anim if set
    BNE loc_008244
    LDA $0036
    BIT #$07              ; Throttle HP recovery to every 8 frames (BIT #$07)
    BNE loc_008244
    LDA $damageFlashTimer ; Check damageFlashTimer: 0 = no recovery animation
    BEQ loc_008244
    DEC 
    STA $damageFlashTimer
    LDA $playerHp
    CMP $playerMaxHp
    BNE loc_00823E
    STZ $damageFlashTimer
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
    LDA #$10              ; Set bit 4 — flag HUD VRAM data as dirty for redraw
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
    LDA #$0019            ; Enemy HP display timer = 25 frames when damage is pending
    STA $enemyHealthTimer
    COP [RunBg3Script] ( @system_strings.consolestring_01E818 )
    LDA #$0010
    TSB $displayModeFlags
    LDA #$003C            ; Enemy HP hold timer = 60 frames after bar display
    STA $enemyHealthTimer
    BRA loc_0082BD

  loc_008299:
    LDA $enemyHealthTimer
    BEQ loc_0082BD
    DEC $enemyHealthTimer ; Decrement hold; 0 → begin 30-frame fadeout
    BNE loc_0082BD
    LDA #$001E            ; Enemy HP fadeout timer = 30 frames
    STA $enemyHealthTimer
    STZ $09E6             ; Clear pending enemy HP accumulator after display period expires
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
    AND #$FE              ; Restore original bit 0 of displayModeFlags from stack
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
; V-Blank interrupt handler — the critical per-frame DMA orchestration routine.
; 
; Execution order during V-Blank:
; 1. Save registers and set data bank to $81
; 2. Disable HDMA to prevent bus conflicts
; 3. Upload scroll registers to PPU
; 4. DMA tilemap strip updates (dirty column/row data)
; 5. DMA CGRAM palette (512 bytes from $7F0A00)
; 6. DMA OAM table (544 bytes from $0422)
; 7. DMA sprite VRAM tiles
; 8. Configure VRAM DMA mode ($80 word-access, $18 target, $01 two-reg)
; 9. Conditional: full tilemap DMA or skip based on displayModeFlags bit 3
; 10. Execute queued VRAM writes and pending DMA
; 11. Re-enable HDMA channels
; 12. Poll joypad (spin-wait for auto-read completion)
; 13. Handle music transition state (run full frame update if fading)
; 14. Send audio commands to SPC on alternate frames
; 15. Increment frame parity counter and restore registers

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
    JSL $@camera_tilemap.SpriteVramDma ; DMA sprite tile data to VRAM
    LDA #$80              ; VMAIN=$80: word-mode VRAM access, auto-increment high byte
    STA $VMAIN
    LDA #$18              ; BBAD0=$18: VRAM data write port target
    STA $BBAD0
    LDA #$01              ; DMAP0=$01: two-register DMA (word increment mode)
    STA $DMAP0
    LDA $displayModeFlags
    BIT #$08              ; Bit 3 of displayModeFlags = dialogue mode: skip full tilemap DMA
    BNE loc_00834A
    LDA $dmaSkipFlag      ; Secondary DMA skip flag for partial VRAM bypass
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
    LDA $musicTransitionState ; Music state: 0=idle, positive=fading, negative=complete
    BEQ loc_00836E
    BMI loc_00837F
    JSL $@UpdateFrameFull ; Run full frame update during music fade for visual continuity
    BRA loc_00837F

  loc_00836E:
    LDA $36
    LSR                   ; Frame parity bit — SPC I/O writes on odd frames only
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
; - Direct mode (bit 3 set): Writes bg1ScrollH/bg2ScrollH directly to BG1HOFS/BG1VOFS registers, masking high bytes to 7 bits.

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
    LDA $bg2ScrollH
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
    LDA $bg2ScrollH, X
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
; Fills the OAM staging buffer at WRAM $0422 with the byte value $E0 via DMA.
; 
; Uses DMA fixed-source mode ($08) to repeat a single byte across 512 bytes of the OAM buffer. The fill value $E0 sets all sprite Y positions to 224 (off the bottom of the visible 224-line display), effectively hiding all OAM entries before sprite composition begins each frame.
; 
; Target: WRAM data port ($2180), size: $0200 (512 bytes = 128 OAM entries × 4 bytes).

FillWramBlock {
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
    LDA #$^WramFillConstant
    STA $A1B0
    LDX #$&WramFillConstant
    STX $A1T0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS                   ; Fill value $E0: offscreen Y position (224 = bottom edge)
}

---------------------------------------------
; Single-byte constant ($E0) used as the fixed DMA source for OAM buffer clearing. Value $E0 = 224 decimal places sprites at the bottom screen edge (offscreen in 224-line mode).

WramFillConstant #E0