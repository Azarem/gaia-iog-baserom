; Inventory screen overlay — full scene save/restore lifecycle for the pause-menu inventory (191746–192584, Bank 02).
; 
; Manages the complete lifecycle of opening and closing the inventory screen. The game's inventory is implemented as a separate scene ($FF) with its own actor system. Opening the inventory requires saving the ENTIRE game state (actors, map data, palettes, camera, input state) to backup WRAM, loading the inventory scene, running it, and then fully restoring the previous state afterward.
; 
; === OPEN FLOW (OpenInventoryScreen) ===
; 
; 1. DISABLE INTERRUPTS: EnableNmiOnly + EnableDisplay + disable HDMA. Prevents rendering during state transition.
; 
; 2. SAVE GAME STATE: SaveGameState bulk-copies all live game data to backup WRAM at $7E:3490+ and $7E:38xx using MVN block transfers:
;   - Joypad state ($0656/$0658/$065A) → $7E:38AC-38B1
;   - Active actor count ($0DBC) → $0DBE
;   - 8 DP words at $004E → $7E:389C (thinker/state variables)
;   - 6 camera words (cameraTargetX through cameraDeltaY) → $7E:3890
;   - Page $0E ($0E00-$0EFF, hardware shadows) → $7E:3490
;   - $7E:3000 page (actor pool) → $7E:3590
;   - Actor table ($00:1000-$1FFF, $1000 bytes) → $7F:E000
;   - $7F page $10-$1F → $7F:F000 (secondary backup)
;   - Page $0F ($0F00-$0FFF, variables) → $7E:3690
;   - $7F:0F00 page → $7E:3790
;   - Palette buffer ($7F:0A00, $203 bytes) → $7E:38B4
; 
; 3. PUSH STATE TO STACK: effectDeltaX, displayModeFlags, eventFlags, sceneCurrent pushed for restoration.
; 
; 4. CONFIGURE INVENTORY SCENE:
;   - sceneCurrent = $FF, sceneIndex $0646 = $01FE
;   - Clear $0A1F bit 7 (disable some visual flag)
;   - Zero all PPU window registers (W12SEL, W34SEL, WOBJSEL, WBGLOG, WOBJLOG)
;   - Set window 0: WH0 = 0, WH1 = $FF (full screen), WH2 = 0, WH3 = 0
;   - BG3SC = $78 (BG3 tilemap at $F000), zero BG3 scroll
;   - SceneScriptNoMusic loads scene $FF graphics without disturbing music
;   - BG2SC = $0C, BG1SC = bg1ConfigMode = $04
;   - Custom palette entries: $1B → $7F0A04, $5B → $7F0A05, then UploadCgramPalette
; 
; 5. ZERO ALL CAMERA/SCROLL: cameraTargetX/Y, cameraDeltaX/Y, bg1/bg2 scroll, scroll overrides.
; 
; 6. INITIALIZE ACTOR SYSTEM: ClearVramBufferFull, InitActorPool, SpawnSceneActors, SpawnSceneThinkers, ClearActorRenderList.
; 
; 7. RENDER TWO INITIAL FRAMES: RunActors_Normal × 2 (two ticks for layout settle), SortActorsByDepth, OAM sentinel ($FF), ComposeAllSprites, UpdateFrameDialogue.
; 
; 8. ENABLE DISPLAY: EnableNmiAndJoypad, VBlankWaitAndJoypad, INIDISP = $0F (full brightness).
; 
; 9. MAIN LOOP (code_02EE17): UpdateFrameDialogue per frame. Copies bg1ConfigMode → BG1SC (allows the inventory_menu actor to dynamically change BG1 tilemap base address between item grid and status views). Loops via BranchIfFlagByte until flag byte #00 becomes nonzero (set by inventory_menu TabCancel or menu exit via SetFlagByte).
; 
; === CLOSE FLOW ===
; 
; 10. CLEANUP: Zero BG3 scroll, EnableNmiOnly, EnableDisplay, disable HDMA.
; 
; 11. RESTORE GAME STATE: RestoreGameState reverses all MVN copies. Restore camera scroll positions from saved targets.
; 
; 12. POP STACK STATE: Restore sceneCurrent, eventFlags, displayModeFlags, effectDeltaX.
; 
; 13. RELOAD ORIGINAL SCENE: SceneScriptNoMusic (reloads the prior scene's graphics), ApplyAllEventBlocks (re-applies any active event tile changes), PlaceBarrierTiles.
; 
; 14. RESTORE VISUALS: RestorePaletteBuffer (palette from backup), LoadScenePalettes, LoadPlayerGraphics, ReloadAbilityFX (ability tile/palette reload based on $00EA).
; 
; 15. RESET HUD: ClearActorRenderList, ClearVramBufferFull, displayModeFlags |= $41, LoadHudTilemap, zero HP cache and joypad masks.
; 
; 16. FINALIZE: RunBg3Script (initial HUD), DrainActorQueue, ResetHdmaState, UpdateFrameRender × 2 with SetFlagByte $FF between, INIDISP $0F, return.
---------------------------------------------

?INCLUDE 'actor_execution'
?INCLUDE 'DmaWordToVram'
?INCLUDE 'event_blocks'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'scene_lifecycle'
?INCLUDE 'scene_script'
?INCLUDE 'sprite_composition'
?INCLUDE 'system_core'
?INCLUDE 'system_init'
?INCLUDE 'system_strings'
?INCLUDE 'thinker_execution'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'
?INCLUDE 'warps_interaction'

!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!effectDeltaX                   06E4
!displayModeFlags               09EC
!eventFlags                     0A00
!cachedPrevMaxHp                0ACC
!cachedPrevHp                   0AD0
!bg1ConfigMode                  0AE6
!activeActorCount               0DBC
!INIDISP                        2100
!BG1SC                          2107
!BG2SC                          2108
!BG3SC                          2109
!BG3HOFS                        2111
!BG3VOFS                        2112
!VMADDL                         2116
!W12SEL                         2123
!W34SEL                         2124
!WOBJSEL                        2125
!WH0                            2126
!WH1                            2127
!WH2                            2128
!WH3                            2129
!WBGLOG                         212A
!WOBJLOG                        212B
!HDMAEN                         420C
!oamComposeBuffer               7F3100

---------------------------------------------

; Main entry point for the inventory screen overlay. Implements the complete open→run→close lifecycle:
; 
; 1. Disable interrupts, save game state via SaveGameState
; 2. Push effectDeltaX/displayModeFlags/eventFlags/sceneCurrent to stack
; 3. Set sceneCurrent = $FF, configure PPU windows (full-screen, no clipping), BG3 tilemap at $F000
; 4. SceneScriptNoMusic loads scene $FF graphics; set BG1SC=$04, BG2SC=$0C, custom palette entries
; 5. Zero all camera/scroll state, initialize actor pool, spawn scene actors/thinkers
; 6. Run actors twice (layout settle), compose sprites, render one dialogue frame
; 7. Enable display at full brightness ($0F)
; 8. Main loop: UpdateFrameDialogue + copy bg1ConfigMode→BG1SC each frame; loops until flag byte #00 ≠ 0
; 9. On exit: restore game state, pop stack, SceneScriptNoMusic for original scene, ApplyAllEventBlocks, PlaceBarrierTiles
; 10. Restore palettes, player graphics, ability FX, HUD, drain actor queue, reset HDMA
; 11. SetFlagByte $FF, render two frames, full brightness, return

OpenInventoryScreen {
    PHP                   ; OpenInventoryScreen — inventory overlay entry; saves P and enters 8-bit mode
    SEP #$20
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@vblank_joypad.EnterForcedBlank ; EnterForcedBlank — halt PPU so inventory setup can DMA tiles/CGRAM
    STZ $HDMAEN           ; Disable HDMA during inventory scene (no scroll/window effects)
    JSR $&SaveGameState   ; SaveGameState — snapshot live WRAM before overlay mutates game state
    REP #$20              ; Push overlay stack: effectDeltaX, displayModeFlags, eventFlags, sceneCurrent
    LDA #$0F00            ; joypadMaskInv = $0F00 — D-pad + B/Y/A/X enabled for inventory input
    STA $joypadMaskInv
    LDA $effectDeltaX     ; Save effectDeltaX; zero until overlay closes
    PHA 
    STZ $effectDeltaX
    LDA $displayModeFlags ; Save displayModeFlags; force $4000 overlay rendering mode (bit 14)
    PHA 
    LDA #$4000
    STA $displayModeFlags
    LDA $eventFlags       ; Save eventFlags; suppress event processing during inventory
    PHA 
    STZ $eventFlags
    LDA $sceneCurrent     ; Push sceneCurrent low byte; sceneCurrent = $FF (inventory scene ID)
    AND #$00FF
    PHA 
    LDA #$00FF
    STA $sceneCurrent
    ASL                   ; Scene table index = sceneCurrent × 2 → $0646
    STA $0646
    SEP #$20
    LDA $0A1F             ; Clear $0A1F bit 7 — disable gameplay flag during inventory overlay
    AND #$7F
    STA $0A1F
    STZ $W12SEL           ; Zero all PPU window select and logic registers (disable windows)
    STZ $W34SEL
    STZ $WOBJSEL
    STZ $WBGLOG
    STZ $WOBJLOG
    STZ $WH0
    STZ $WH2
    STZ $WH3
    LDA #$FF              ; WH1 = $FF — full-screen window mask on BG1/BG2 layers
    STA $WH1
    LDA #$78              ; BG3SC = $78 — inventory UI tilemap base at VRAM $F000
    STA $BG3SC
    STZ $BG3HOFS          ; Zero BG3 horizontal scroll (HOFS write-twice)
    STZ $BG3HOFS
    STZ $BG3VOFS          ; Zero BG3 vertical scroll (VOFS write-twice)
    STZ $BG3VOFS
    JSL $@scene_script.SceneScriptNoMusic ; SceneScriptNoMusic — load scene $FF tilesets/palette without BGM change
    LDA #$0C              ; BG2SC = $0C — inventory middle-layer tilemap
    STA $BG2SC
    LDA #$04              ; BG1SC = $04 — inventory foreground tilemap
    STA $BG1SC
    STA $bg1ConfigMode    ; bg1ConfigMode = $04 — inventory_menu actor can swap BG1 tilemap per tab
    JSL $@scene_lifecycle.LoadScenePalettes
    LDA #$1B              ; Custom palette buffer: index $1B → $7F0A04, index $5B → $7F0A05
    STA $7F0A04
    LDA #$5B
    STA $7F0A05
    JSL $@system_init.UploadCgramPalette ; UploadCgramPalette — push inventory CGRAM from $7F:0A00 buffer
    LDX #$0000            ; Zero $0673/$0676 frame counters
    STX $0673
    STX $0676
    LDX #$0000            ; Zero camera targets/deltas and all scroll override state
    STX $cameraTargetX
    STX $cameraTargetY
    STX $cameraDeltaX
    STX $cameraDeltaY
    STX $bg1ScrollH       ; Zero bg1/bg2 scroll positions and savedCameraDelta
    STX $bg2ScrollH
    STX $bg1ScrollV
    STX $savedCameraDelta
    STX $scrollOverrideH
    STX $forcedScrollOverride
    STX $scrollOverrideV
    STX $06CC
    STX $00B2
    JSL $@vram_buffer_clear.ClearVramBufferFull ; ClearVramBufferFull — empty tile upload queue before actor spawn
    JSL $@actor_execution.InitActorPool ; InitActorPool — reset actor free list for inventory scene
    JSL $@actor_execution.SpawnSceneActors ; SpawnSceneActors — create inventory menu/cursor actors
    JSL $@thinker_execution.SpawnSceneThinkers ; SpawnSceneThinkers — create inventory logic controllers
    JSL $@sprite_composition.ClearActorRenderList ; ClearActorRenderList before first sprite compose
    JSL $@actor_execution.RunActors_Normal ; RunActors ×2 — two ticks so UI layout actors settle positions
    JSL $@actor_execution.RunActors_Normal
    JSL $@sprite_composition.SortActorsByDepth ; SortActorsByDepth — Z-order overlapping menu sprites
    LDA #$FF              ; OAM compose sentinel $FF at $7F3100 (end-of-list marker)
    STA $oamComposeBuffer ; Duplicate sentinel at $7F3101 (second compose slot guard)
    STA $7F3101
    JSL $@sprite_composition.ComposeAllSprites
    JSL $@system_core.UpdateFrameDialogue ; Initial UpdateFrameDialogue — prime text engine for inventory
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Enable NMI + joypad auto-read for interactive inventory loop
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; VBlankWaitAndJoypad — wait one frame before fade-in
    LDA #$0F              ; INIDISP = $0F — full brightness (fade inventory on screen)
    STA $INIDISP
    JSL $@vblank_joypad.EnableNmiOnly ; Return to NMI-only until main loop re-enables joypad

  code_02EE17:
    JSL $@system_core.UpdateFrameDialogue ; Main loop tick — UpdateFrameDialogue (input + actor scripts)
    LDA $bg1ConfigMode    ; bg1ConfigMode → BG1SC — tabs dynamically swap BG1 tilemap base
    STA $BG1SC
    COP [BranchIfFlagByte] ( #00, #00, &code_02EE17 ) ; BranchIfFlagByte #00 — loop while exit flag zero; inventory_menu sets on close
    STZ $BG3VOFS          ; Close path — zero BG3 vertical scroll before teardown
    STZ $BG3VOFS
    JSL $@vblank_joypad.EnableNmiOnly ; Re-enable NMI-only before RestoreGameState
    JSL $@vblank_joypad.EnterForcedBlank ; EnterForcedBlank for scene-reload and HUD restore phase
    STZ $HDMAEN           ; Disable HDMA again before copying backup WRAM
    JSR $&RestoreGameState ; RestoreGameState — copy all backup WRAM regions back to live
    LDX $cameraTargetX    ; cameraTargetX → bg1ScrollH
    STX $bg1ScrollH
    LDX $cameraTargetY    ; cameraTargetY → bg2ScrollH
    STX $bg2ScrollH
    LDX $cameraDeltaX     ; cameraDeltaX → bg1ScrollV
    STX $bg1ScrollV
    LDX $cameraDeltaY     ; cameraDeltaY → savedCameraDelta
    STX $savedCameraDelta
    REP #$20              ; Pop overlay stack: sceneCurrent, eventFlags, displayModeFlags, effectDeltaX
    PLA 
    STA $sceneCurrent
    ASL                   ; Recompute scene table index from restored sceneCurrent
    STA $0646
    PLA 
    STA $eventFlags
    PLA 
    STA $displayModeFlags
    PLA 
    STA $effectDeltaX
    SEP #$20
    JSL $@scene_script.SceneScriptNoMusic ; SceneScriptNoMusic — reload original scene graphics (no BGM)
    JSL $@event_blocks.ApplyAllEventBlocks ; ApplyAllEventBlocks — re-apply persistent scene event tile swaps
    JSL $@warps_interaction.PlaceBarrierTiles ; PlaceBarrierTiles — redraw warp/barrier collision markers
    JSR $&RestorePaletteBuffer ; RestorePaletteBuffer — copy saved palette $7E:38B4 → $7F:0A00
    JSL $@scene_lifecycle.LoadScenePalettes ; LoadScenePalettes — upload scene CGRAM from restored buffer
    JSL $@scene_lifecycle.LoadPlayerGraphics ; LoadPlayerGraphics — restore player sprite tiles to VRAM
    JSR $&ReloadAbilityFX ; ReloadAbilityFX — restore active ability VFX tiles if any
    JSL $@sprite_composition.ClearActorRenderList ; ClearActorRenderList for world-scene sprite compose
    JSL $@vram_buffer_clear.ClearVramBufferFull ; ClearVramBufferFull — flush stale tile upload queue
    LDA #$41              ; displayModeFlags |= $41 — re-enable HUD (bit 0) + dialogue (bit 6)
    TSB $displayModeFlags
    JSL $@scene_lifecycle.LoadHudTilemap ; LoadHudTilemap — restore overworld status bar BG tilemap
    LDX #$0000            ; Clear status cache vars $09CC/$09CE and cached HP values
    STX $09CC
    STX $09CE
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $joypadMaskInv    ; Clear inventory joypad mask and suppress bytes $00F4/$00F8
    STX $00F4
    STX $00F8
    COP [RunBg3Script] ( @system_strings.consolestring_01E818 ) ; RunBg3Script @consolestring_01E818 — draw initial HUD status text on BG3
    JSR $&DrainActorQueue ; DrainActorQueue — reset frame counters on actors queued during inventory
    JSL $@hdma_dma_spc.ResetHdmaState ; ResetHdmaState — re-init HDMA tables after overlay disable
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender — first post-inventory compose/upload frame
    COP [SetFlagByte] ( #FF ) ; SetFlagByte #FF — signal sprite compose pipeline ready
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender — second frame after flag set (clean OAM upload)
    LDA #$0F              ; INIDISP = $0F — ensure full brightness returning to gameplay
    STA $INIDISP
    PLP 
    RTL                   ; Return to caller — inventory overlay closed
}

---------------------------------------------
; Reload ability visual effect tiles and palette after returning from inventory.
; 
; Checks $00EA (active ability FX ID):
;   0 = no ability FX active → return immediately
;   1 = load misc_fx_1CC000 ($0480 bytes) to VRAM $4400 + palette fx_palette_198070 (16 colors at CGRAM $A0)
;   ≥2 = load misc_fx_1CC480 ($0600 bytes) to VRAM $4400 + palette fx_palette_198090 (7 colors at CGRAM $A9)
; 
; The ability FX tiles occupy VRAM $4400+ (sprite tile area). Without this reload, returning from inventory would leave ability graphics corrupted since the inventory scene overwrites sprite VRAM.

ReloadAbilityFX {
    LDA $00EA             ; ReloadAbilityFX — check active ability FX ID at $00EA; 0 = no reload
    BNE loc_02EED2
    RTS 

  loc_02EED2:
    DEC                   ; DEC $00EA: branch FX type 1 vs ≥2
    BNE loc_02EEF0
    LDX #$4400            ; FX type 1: VRAM destination $4400
    STX $VMADDL
    LDX #$&misc_fx_1CC000 ; DMA misc_fx_1CC000 ($0480 bytes) — primary ability sprite tiles
    LDA #$^misc_fx_1CC000
    LDY #$0480
    JSL $@DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 ) ; CopyPalette @fx_palette_198070 — 16 colors to CGRAM starting $A0
    RTS 

  loc_02EEF0:
    LDX #$4400            ; FX type ≥2: alternate ability visual set
    STX $VMADDL
    LDX #$&misc_fx_1CC480 ; DMA misc_fx_1CC480 ($0600 bytes) — secondary ability sprite tiles
    LDA #$^misc_fx_1CC480
    LDY #$0600
    JSL $@DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 ) ; CopyPalette @fx_palette_198090 — 7 colors to CGRAM starting $A9
    RTS 
}

---------------------------------------------
; Walk and clear the pending actor execution queue.
; 
; Starts from the queue head at DP $5A. For each queued entry: TCD sets direct page to the actor base, STZ $08 clears its frame counter (preventing execution), then follows the linked list via $06 (next pointer). Terminates when $06 = 0 (end of list).
; 
; Called during inventory close to discard any leftover actor queue entries from the inventory scene before the gameplay scene's actors are restored.

DrainActorQueue {
    PHP 
    PHD 
    REP #$20
    LDA $5A               ; DrainActorQueue — head of actor linked list at direct-page $5A
    BEQ loc_02EF1A

  loc_02EF13:
    TCD                   ; Walk queue: TCD to actor DP, zero $08 frame counter, follow $06 next link
    STZ $08
    LDA $06
    BNE loc_02EF13

  loc_02EF1A:
    PLD 
    PLP 
    RTS 
}

---------------------------------------------
; Save complete game state to backup WRAM for inventory overlay.
; 
; Preserves all live game data so the inventory scene can freely use the same WRAM areas:
;   - Joypad state (joypadCurrent, joypadHeld, joypadMaskStd) → $7E:38AC-38B1
;   - Active actor count → $0DBE
;   - 8 DP words at $004E → $7E:389C (thinker/state variables)
;   - 6 camera words (cameraTargetX..cameraDeltaY) → $7E:3890
;   - MVN block transfers (7 total):
;     $00:0E00 (256 bytes, HW shadow page) → $7E:3490
;     $7E:3000 (256 bytes, actor pool page) → $7E:3590
;     $00:1000 ($1000 bytes, actor table) → $7F:E000
;     $7F:1000 ($1000 bytes, secondary) → $7F:F000
;     $00:0F00 (256 bytes, variable page) → $7E:3690
;     $7F:0F00 (256 bytes) → $7E:3790
;     $7F:0A00 ($203 bytes, palette buffer) → $7E:38B4
; 
; After saving, joypadCurrent and joypadMaskStd are zeroed (suppress input during transition).

SaveGameState {
    PHP 
    PHB 
    REP #$20
    LDA $joypadCurrent    ; Backup joypadCurrent → $7E:38AC; zero live input during overlay
    STZ $joypadCurrent
    STA $7E38AC
    LDA $joypadHeld       ; Backup joypadHeld → $7E:38AE
    STA $7E38AE
    LDA $joypadMaskStd    ; Backup joypadMaskStd → $7E:38B0; zero mask during overlay
    STZ $joypadMaskStd
    STA $7E38B0
    LDA $activeActorCount ; Backup activeActorCount → scratch $0DBE
    STA $0DBE
    LDX #$0000            ; Loop: backup 8 words $004E–$005D → $7E:389C (DP runtime vars)

  loc_02EF45:
    LDA $004E, X          ; Save loop body: LDA $004E,X / STA $7E389C,X
    STA $7E389C, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02EF45
    LDX #$0000            ; Loop: backup 6 camera/scroll words → $7E:3890

  loc_02EF56:
    LDA $cameraTargetX, X ; Camera backup loop body: cameraTargetX,X → $7E3890,X
    STA $7E3890, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02EF56
    LDX #$0E00            ; MVN $00:0E00 → $7E:3490 — 256 bytes hardware shadow registers
    LDY #$3490
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$3000            ; MVN $7E:3000 → $7E:3590 — 256 bytes actor pool header
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$1000            ; MVN $00:1000 → $7F:E000 — $1000 bytes actor instance table
    LDY #$E000
    LDA #$0FFF
    MVN #$7F, #$00
    LDX #$1000            ; MVN $7F:1000 → $7F:F000 — $1000 bytes actor extended data page
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$0F00            ; MVN $00:0F00 → $7E:3690 — 256 bytes variable/script page
    LDY #$3690
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$0F00            ; MVN $7F:0F00 → $7E:3790 — 256 bytes WRAM scratch page
    LDA #$00FF
    MVN #$7E, #$7F
    LDX #$0A00            ; MVN $7F:0A00 → $7E:38B4 — $203 bytes CGRAM palette buffer
    LDY #$38B4
    LDA #$0202
    MVN #$7E, #$7F
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Restore complete game state from backup WRAM after inventory close.
; 
; Reverse of SaveGameState: restores all MVN-copied memory regions from their backup locations, then restores joypad state, camera words, DP variables, and actor count. MVN copies run in reverse direction (backup → live).

RestoreGameState {
    PHP 
    PHB 
    REP #$20
    LDA $7E38AC           ; Restore joypadCurrent from $7E:38AC
    STA $joypadCurrent
    LDA $7E38AE           ; Restore joypadHeld from $7E:38AE
    STA $joypadHeld
    LDA $7E38B0           ; Restore joypadMaskStd from $7E:38B0
    STA $joypadMaskStd
    LDA $0DBE             ; Restore activeActorCount from $0DBE
    STA $activeActorCount
    LDX #$0000            ; Loop: restore 8 words $7E:389C → $004E (DP runtime vars)

  loc_02EFD4:
    LDA $7E389C, X        ; Restore loop body: LDA $7E389C,X / STA $004E,X
    STA $004E, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02EFD4
    LDX #$0000            ; Loop: restore 6 camera/scroll words → cameraTargetX+

  loc_02EFE5:
    LDA $7E3890, X        ; Camera restore loop body: $7E3890,X → cameraTargetX,X
    STA $cameraTargetX, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02EFE5
    LDX #$3490            ; MVN $7E:3490 → $00:0E00 — restore hardware shadow page
    LDY #$0E00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$3000            ; MVN $7E:3590 → $7E:3000 — restore actor pool header
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$E000            ; MVN $7F:E000 → $00:1000 — restore actor instance table
    LDY #$1000
    LDA #$0FFF
    MVN #$00, #$7F
    LDY #$1000            ; MVN $7F:F000 → $7F:1000 — restore actor extended data page
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$3690            ; MVN $7E:3690 → $00:0F00 — restore variable/script page
    LDY #$0F00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$0F00            ; MVN $7E:3790 → $7F:0F00 — restore WRAM scratch page
    LDA #$00FF
    MVN #$7F, #$7E
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Restore the CGRAM palette buffer from backup.
; 
; Copies $203 bytes from $7E:38B4 back to $7F:0A00 (the palette staging buffer that gets DMA'd to CGRAM during VBlank). Called separately from RestoreGameState because palette restoration happens at a different point in the close sequence (after scene graphics are reloaded but before UploadCgramPalette).

RestorePaletteBuffer {
    PHP 
    PHB 
    REP #$20
    LDX #$38B4            ; MVN $7E:38B4 → $7F:0A00 — restore $203-byte palette buffer for CGRAM upload
    LDY #$0A00
    LDA #$0202
    MVN #$7F, #$7E
    PLB 
    PLP 
    RTS 
}