; Inventory screen overlay: full scene save / restore around the pause-menu inventory (191746-192584, Bank 02).
; 
; The inventory is a normal scene ($FF) with its own actors and thinkers that reuses the live WRAM. OpenInventoryScreen therefore saves the pools and state it will overwrite, builds scene $FF, runs UpdateFrameDialogue until the inventory_menu actor sets flag byte #00, restores everything and reloads the previous scene's graphics. Called through JSL from GlobalInputHandler (Select). Not saved: tile / map data (the scene script reloads it), VRAM (reloaded), sprite VRAM tiles for the player and ability effects (reloaded explicitly).
; 
; === SAVE MAP (SaveGameState / RestoreGameState) ===
; 
;   joypadCurrent, joypadHeld, joypadMaskStd ($0656-$065B) -> $7E:38AC-38B1 (joypadCurrent and joypadMaskStd are zeroed live)
;   activeActorCount ($0DBC) -> $0DBE (a word just outside every copied page)
;   DP $4E-$5D (8 words: actor free-list pointer $4E/$50, thinker free-list pointer $52/$54, actor list head / tail $56 / $58, thinker list head / tail $5A / $5C) -> $7E:389C
;   6 camera words $06BE-$06C9 (cameraTargetX, cameraDeltaX, cameraTargetY, cameraDeltaY, scrollOverrideH, forcedScrollOverride) -> $7E:3890; scrollOverrideV ($06CA) is NOT saved
;   MVN copies: $00:0E00 actor free-slot list -> $7E:3490; $7E:3000 thinker free-slot list -> $7E:3590; $00:1000-$1FFF actor slots -> $7F:E000; $7F:1000-$1FFF actor extended data -> $7F:F000; $00:0F00 thinker table (16 slots x $10) -> $7E:3690; $7F:0F00 thinker extended data -> $7E:3790; $7F:0A00 palette staging ($203 bytes) -> $7E:38B4 (restored separately by RestorePaletteBuffer)
; 
; === OPEN FLOW (OpenInventoryScreen) ===
; 
; 1. DisableNmiKeepJoypad (NMITIMEN = $01: NMI OFF, joypad auto-read on), EnterForcedBlank (INIDISP $80), HDMAEN = 0.
; 2. SaveGameState (above).
; 3. joypadMaskInv = $0F00 (the Up / Down / Left / Right bits). Push effectDeltaX (zeroed), displayModeFlags (set to $4000: every request bit clears; bit 14 is bit 6 of hudDisableFlag at $09ED, the HUD-off bit), eventFlags (zeroed; flag byte #00 is the loop's exit flag, so this also re-arms it), sceneCurrent (set to $FF, sceneTableIndex = $01FE). Event flag $FF (bit 7 of $0A1F, the scene-setup-complete latch) is cleared.
; 4. PPU: all window select / logic registers zero (windows off; WH0 = 0 and WH1 = $FF are inert without a W*SEL bit), BG3SC = $78 (tilemap at VRAM word $7800 = byte $F000), BG3 scroll zero, SceneScriptNoMusic builds scene $FF graphics, BG2SC = $0C, BG1SC = bg1ConfigMode = $04 (inventory_menu swaps BG1SC per tab), LoadScenePalettes, palette staging colour 2 = $5B1B (R27 G24 B22), UploadCgramPalette.
; 5. Source-pointer cache slots C ($0672) and D ($0675) are invalidated (zeroing addr-hi + bank forces the next lookup to miss, so the scene reload at close re-decompresses those BG tile sources). Camera targets / deltas, the four scroll accumulators, scrollOverrideH / V, forcedScrollOverride, $06CC and $00B2 are zeroed.
; 6. ClearVramBufferFull, InitActorPool, SpawnSceneActors, SpawnSceneThinkers, ClearActorRenderList.
; 7. RunActors_Normal x 2, SortActorsByDepth, $FFFF sentinel at the compose buffer, ComposeAllSprites, one UpdateFrameDialogue.
; 8. EnableNmiAndJoypad (NMITIMEN $81), VBlankWaitAndJoypad, INIDISP = $0F, DisableNmiKeepJoypad (NMI off again).
; 9. Main loop (code_02EE17): UpdateFrameDialogue (RunActors_CutsceneOnly, camera scroll, light HDMA-phase thinkers, sprite compose, one VBlank wait with the NMI pulsed on, light general thinkers), copy bg1ConfigMode to BG1SC, repeat while flag byte #00 equals #00 (BranchOnFlagByte).
; 
; === CLOSE FLOW ===
; 
; 10. BG3 vertical scroll zero, DisableNmiKeepJoypad, EnterForcedBlank, HDMAEN = 0.
; 11. RestoreGameState; then bg1ScrollH / mapScrollV / effectScrollH / effectScrollV are loaded from the restored cameraTargetX / cameraTargetY / cameraDeltaX / cameraDeltaY.
; 12. Pop sceneCurrent (sceneTableIndex recomputed), eventFlags, displayModeFlags, effectDeltaX.
; 13. SceneScriptNoMusic (previous scene's graphics), ApplyAllEventBlocks, PlaceOpenedChestTiles (rewrites the opened 2x2 pattern for chests whose flag is set).
; 14. RestorePaletteBuffer, LoadScenePalettes, LoadPlayerGraphics, ReloadAbilityFX (tiles and palette selected by activeAbilityGfx $00EA).
; 15. ClearActorRenderList, ClearVramBufferFull, displayModeFlags |= $41 (bit 0 = full BG3 tilemap upload, bit 6 = sine-table rebuild trigger read by BuildSineLookupTable), LoadHudTilemap, then the player sprite cache ($09CC / $09CE) and cachedPrevHp / cachedPrevMaxHp are zeroed so the next frames treat them as changed, joypadMaskInv and the unnamed words $00F4 / $00F8 are zeroed.
; 16. RunBg3Script (BG3 console string), ResetThinkerWaitCounters (resets the wait counter of every THINKER in the list at $5A, not an actor queue), ResetHdmaState, UpdateFrameRender, SetFlagByte #FF (the scene-setup-complete latch cleared in step 3), UpdateFrameRender, INIDISP = $0F, PLP, RTL.
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
!sceneTableIndex                0646
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!srcCacheBgC                    0672
!srcCacheBgD                    0675
!bg1ScrollH                     068A
!effectScrollH                  068C
!mapScrollV                     068E
!effectScrollV                  0690
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!effectDeltaX                   06E4
!playerSpriteCachePtr           09CC
!playerSpriteCacheBank          09CE
!displayModeFlags               09EC
!eventFlags                     0A00
!eventFlagsF8toFF               0A1F
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

; Open / run / close in one JSL (steps in the block note). PHP / PLP bracket the whole routine; A, X and Y are clobbered. The four words pushed in step 3 stay on the stack until step 12, so nothing between them may leave an unbalanced push.

OpenInventoryScreen {
    PHP                   ; OpenInventoryScreen — inventory overlay entry; saves P and enters 8-bit mode
    SEP #$20
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMITIMEN = $01: NMI off, joypad auto-read on (DisableNmiKeepJoypad)
    JSL $@vblank_joypad.EnterForcedBlank ; EnterForcedBlank — halt PPU so inventory setup can DMA tiles/CGRAM
    STZ $HDMAEN           ; Disable HDMA during inventory scene (no scroll/window effects)
    JSR $&SaveGameState   ; SaveGameState — snapshot live WRAM before overlay mutates game state
    REP #$20              ; Push overlay stack: effectDeltaX, displayModeFlags, eventFlags, sceneCurrent
    LDA #$0F00            ; joypadMaskInv = $0F00: the Up / Down / Left / Right bits only, not B / Y / A / X
    STA $joypadMaskInv
    LDA $effectDeltaX     ; Save effectDeltaX; zero until overlay closes
    PHA 
    STZ $effectDeltaX
    LDA $displayModeFlags ; Save displayModeFlags, then force $4000: every request bit clears; bit 14 is bit 6 of hudDisableFlag ($09ED, HUD off)
    PHA 
    LDA #$4000
    STA $displayModeFlags
    LDA $eventFlags       ; Save eventFlags (flags $00-$0F); zeroing also clears flag byte #00, the exit flag the main loop waits for
    PHA 
    STZ $eventFlags
    LDA $sceneCurrent     ; Push sceneCurrent low byte; sceneCurrent = $FF (inventory scene ID)
    AND #$00FF
    PHA 
    LDA #$00FF
    STA $sceneCurrent
    ASL                   ; Scene table index = sceneCurrent × 2 → $0646
    STA $sceneTableIndex
    SEP #$20
    LDA $eventFlagsF8toFF ; Clear event flag $FF (bit 7 of $0A1F), the scene-setup-complete latch; SetFlagByte #FF sets it again at the end of the close path
    AND #$7F
    STA $eventFlagsF8toFF
    STZ $W12SEL           ; Zero all PPU window select and logic registers (disable windows)
    STZ $W34SEL
    STZ $WOBJSEL
    STZ $WBGLOG
    STZ $WOBJLOG
    STZ $WH0
    STZ $WH2
    STZ $WH3
    LDA #$FF              ; WH0 = 0 / WH1 = $FF describe a full-width window, but every W*SEL is zero so no layer uses it
    STA $WH1
    LDA #$78              ; BG3SC = $78: tilemap at VRAM word $7800 (byte $F000), 32x32
    STA $BG3SC
    STZ $BG3HOFS          ; Zero BG3 horizontal scroll (HOFS write-twice)
    STZ $BG3HOFS
    STZ $BG3VOFS          ; Zero BG3 vertical scroll (VOFS write-twice)
    STZ $BG3VOFS
    JSL $@scene_script.SceneScriptNoMusic ; SceneScriptNoMusic — load scene $FF tilesets/palette without BGM change
    LDA #$0C              ; BG2SC = $0C: tilemap at VRAM word $0C00, 32x32
    STA $BG2SC
    LDA #$04              ; BG1SC = $04: tilemap at VRAM word $0400, 32x32 (inventory_menu changes it later through bg1ConfigMode)
    STA $BG1SC
    STA $bg1ConfigMode    ; bg1ConfigMode = $04 — inventory_menu actor can swap BG1 tilemap per tab
    JSL $@scene_lifecycle.LoadScenePalettes
    LDA #$1B              ; Low byte of the palette staging word at $7F0A04 (colour index 2): $5B1B = R27 G24 B22
    STA $7F0A04
    LDA #$5B              ; High byte of colour index 2 (stored at $7F0A05)
    STA $7F0A05
    JSL $@system_init.UploadCgramPalette ; UploadCgramPalette — push inventory CGRAM from $7F:0A00 buffer
    LDX #$0000            ; Invalidate source-pointer cache slots C ($0672) and D ($0675): zeroing addr-hi + bank makes the next lookup a miss
    STX $srcCacheBgC+1    ; 16-bit store: zeroes $0673-$0674 (addr high byte and bank of slot C)
    STX $srcCacheBgD+1    ; 16-bit store: zeroes $0676-$0677 (addr high byte and bank of slot D)
    LDX #$0000            ; Zero camera targets / deltas and the scroll state; the camera words come back from the save area, the rest does not
    STX $cameraTargetX
    STX $cameraTargetY
    STX $cameraDeltaX
    STX $cameraDeltaY
    STX $bg1ScrollH       ; Zero the four scroll accumulators: bg1ScrollH, mapScrollV, effectScrollH, effectScrollV
    STX $mapScrollV
    STX $effectScrollH
    STX $effectScrollV
    STX $scrollOverrideH
    STX $forcedScrollOverride
    STX $scrollOverrideV  ; scrollOverrideV ($06CA) is zeroed here but was not saved, so its old value is lost
    STX $06CC             ; Unnamed word $06CC, zeroed with the scroll state and never saved
    STX $00B2             ; Unnamed DP word $00B2, outside the saved DP range, zeroed and never restored
    JSL $@vram_buffer_clear.ClearVramBufferFull ; ClearVramBufferFull — empty tile upload queue before actor spawn
    JSL $@actor_execution.InitActorPool ; InitActorPool — reset actor free list for inventory scene
    JSL $@actor_execution.SpawnSceneActors ; SpawnSceneActors — create inventory menu/cursor actors
    JSL $@thinker_execution.SpawnSceneThinkers ; SpawnSceneThinkers — create inventory logic controllers
    JSL $@sprite_composition.ClearActorRenderList ; ClearActorRenderList before first sprite compose
    JSL $@actor_execution.RunActors_Normal ; RunActors ×2 — two ticks so UI layout actors settle positions
    JSL $@actor_execution.RunActors_Normal
    JSL $@sprite_composition.SortActorsByDepth ; SortActorsByDepth — Z-order overlapping menu sprites
    LDA #$FF              ; Sentinel byte $FF (A is 8-bit)
    STA $oamComposeBuffer ; $7F3100 = $FF
    STA $oamComposeBuffer+1 ; $7F3101 = $FF: with the byte above the compose list starts out empty
    JSL $@sprite_composition.ComposeAllSprites
    JSL $@system_core.UpdateFrameDialogue ; First inventory frame: UpdateFrameDialogue (cutscene-flagged actors, camera scroll, thinkers, sprite compose, one VBlank wait)
    JSL $@vblank_joypad.EnableNmiAndJoypad ; NMITIMEN = $81: NMI + joypad on for the fade-in VBlank wait only; DisableNmiKeepJoypad turns the NMI off again below
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; VBlankWaitAndJoypad — wait one frame before fade-in
    LDA #$0F              ; INIDISP = $0F — full brightness (fade inventory on screen)
    STA $INIDISP
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMITIMEN = $01: NMI off again, joypad auto-read stays on; UpdateFrameDialogue pulses the NMI on only for its own VBlank wait

; Main loop of the inventory scene: one UpdateFrameDialogue per pass, then bg1ConfigMode is copied to BG1SC (the inventory_menu actor changes it to flip between the item grid and the status view). Exits when flag byte #00 becomes nonzero; eventFlags was zeroed at open, so the loop starts armed.

  code_02EE17:
    JSL $@system_core.UpdateFrameDialogue ; Main loop tick: RunActors_CutsceneOnly, camera scroll, type-D / light general thinkers, sprite compose, one VBlank wait
    LDA $bg1ConfigMode    ; bg1ConfigMode → BG1SC — tabs dynamically swap BG1 tilemap base
    STA $BG1SC
    COP [BranchOnFlagByte] ( #00, #00, &code_02EE17 ) ; Branch back to code_02EE17 while flag byte #00 (events $00-$07) is zero; inventory_menu sets it to close
    STZ $BG3VOFS          ; Close path — zero BG3 vertical scroll before teardown
    STZ $BG3VOFS
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMI off again (joypad auto-read stays on) before the state copies
    JSL $@vblank_joypad.EnterForcedBlank ; EnterForcedBlank for scene-reload and HUD restore phase
    STZ $HDMAEN           ; Disable HDMA again before copying backup WRAM
    JSR $&RestoreGameState ; RestoreGameState — copy all backup WRAM regions back to live
    LDX $cameraTargetX    ; cameraTargetX → bg1ScrollH
    STX $bg1ScrollH
    LDX $cameraTargetY    ; cameraTargetY → mapScrollV
    STX $mapScrollV
    LDX $cameraDeltaX     ; cameraDeltaX -> effectScrollH
    STX $effectScrollH
    LDX $cameraDeltaY     ; cameraDeltaY -> effectScrollV
    STX $effectScrollV
    REP #$20              ; Pop overlay stack: sceneCurrent, eventFlags, displayModeFlags, effectDeltaX
    PLA 
    STA $sceneCurrent
    ASL                   ; Recompute scene table index from restored sceneCurrent
    STA $sceneTableIndex
    PLA 
    STA $eventFlags       ; Restores flags $00-$0F as they were before the inventory (including flag byte #00)
    PLA 
    STA $displayModeFlags
    PLA 
    STA $effectDeltaX
    SEP #$20
    JSL $@scene_script.SceneScriptNoMusic ; SceneScriptNoMusic — reload original scene graphics (no BGM)
    JSL $@event_blocks.ApplyAllEventBlocks ; ApplyAllEventBlocks — re-apply persistent scene event tile swaps
    JSL $@warps_interaction.PlaceOpenedChestTiles ; PlaceOpenedChestTiles: rewrites the opened-chest 2x2 tile pattern for every chest whose event flag is set (map tiles only)
    JSR $&RestorePaletteBuffer ; RestorePaletteBuffer — copy saved palette $7E:38B4 → $7F:0A00
    JSL $@scene_lifecycle.LoadScenePalettes ; LoadScenePalettes — upload scene CGRAM from restored buffer
    JSL $@scene_lifecycle.LoadPlayerGraphics ; LoadPlayerGraphics — restore player sprite tiles to VRAM
    JSR $&ReloadAbilityFX ; ReloadAbilityFX — restore active ability VFX tiles if any
    JSL $@sprite_composition.ClearActorRenderList ; ClearActorRenderList for world-scene sprite compose
    JSL $@vram_buffer_clear.ClearVramBufferFull ; ClearVramBufferFull — flush stale tile upload queue
    LDA #$41              ; A is 8-bit: TSB below sets displayModeFlags bit 0 (full BG3 tilemap upload) and bit 6 (sine-table rebuild trigger)
    TSB $displayModeFlags ; Bit 0: BG3 staging buffer goes to VRAM next NMI. Bit 6: BuildSineLookupTable regenerates the sine tables on the next GenHdmaSine (not dialogue)
    JSL $@scene_lifecycle.LoadHudTilemap ; LoadHudTilemap — restore overworld status bar BG tilemap
    LDX #$0000            ; Zero the player sprite cache pointer / bank ($09CC / $09CE) and the cached HP values: change-detection copies, so the next frames treat them as changed
    STX $playerSpriteCachePtr
    STX $playerSpriteCacheBank
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $joypadMaskInv    ; Clear joypadMaskInv (set to $0F00 at open) and the unnamed words $00F4 / $00F8 (no other reference in system/)
    STX $00F4
    STX $00F8
    COP [RunBg3Script] ( @system_strings.consolestring_01E818 ) ; RunBg3Script @consolestring_01E818 — draw initial HUD status text on BG3
    JSR $&ResetThinkerWaitCounters ; Walks the THINKER list from $5A and zeroes each wait counter (no actors are touched)
    JSL $@hdma_dma_spc.ResetHdmaState ; ResetHdmaState — re-init HDMA tables after overlay disable
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender — first post-inventory compose/upload frame
    COP [SetFlagByte] ( #FF ) ; Set event flag $FF (bit 7 of $0A1F): the scene-setup-complete latch cleared at open; scene_lifecycle sets it at the same point of scene setup
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender — second frame after flag set (clean OAM upload)
    LDA #$0F              ; INIDISP = $0F — ensure full brightness returning to gameplay
    STA $INIDISP
    PLP 
    RTL                   ; Return to caller — inventory overlay closed
}

---------------------------------------------
; Re-uploads the ability effect tiles and palette after the inventory scene overwrote sprite VRAM. $00EA (activeAbilityGfx): 0 = nothing to do; 1 = misc_fx_1CC000 ($0480 bytes) to VRAM word $4400 and fx_palette_198070 (16 colours, staging colour index $A0 = OBJ palette row 10); 2 or more = misc_fx_1CC480 ($0600 bytes) to $4400 and fx_palette_198090 (7 colours from colour index $A9). The palette goes into the $7F0A00 staging buffer; the NMI upload sends it to CGRAM. The screen is still in forced blank, so the DMA is safe.

ReloadAbilityFX {
    LDA $00EA             ; ReloadAbilityFX — check active ability FX ID at $00EA; 0 = no reload
    BNE loc_02EED2
    RTS 

  loc_02EED2:
    DEC                   ; DEC (accumulator, the FX id from $00EA): zero = FX type 1 path, nonzero = type 2 or higher
    BNE loc_02EEF0
    LDX #$4400            ; FX type 1: VRAM destination $4400
    STX $VMADDL
    LDX #$&misc_fx_1CC000 ; DMA misc_fx_1CC000 ($0480 bytes) — primary ability sprite tiles
    LDA #$^misc_fx_1CC000
    LDY #$0480
    JSL $@DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 ) ; Stage 16 colours from fx_palette_198070 at $7F0A00 + 2 x $A0 (OBJ palette row 10); the NMI uploads them to CGRAM
    RTS 

  loc_02EEF0:
    LDX #$4400            ; FX type ≥2: alternate ability visual set
    STX $VMADDL
    LDX #$&misc_fx_1CC480 ; DMA misc_fx_1CC480 ($0600 bytes) — secondary ability sprite tiles
    LDA #$^misc_fx_1CC480
    LDY #$0600
    JSL $@DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 ) ; Stage 7 colours from fx_palette_198090 at colour index $A9 (OBJ palette row 10, colours 9-15)
    RTS 
}

---------------------------------------------
; Walks the THINKER list: DP $5A is the thinker list head ($5C the tail; the actor list uses $56 / $58). For each thinker D is set to its slot, the wait counter at $08 is zeroed (0 = run on the next pass; a stored n skips n passes) and the next-link at $06 is followed until it is zero. It runs after RestoreGameState, so it hits the restored gameplay thinkers, not leftovers of the inventory scene. D and P are saved around it.

ResetThinkerWaitCounters {
    PHP 
    PHD 
    REP #$20
    LDA $5A               ; DP $5A = head of the THINKER list (tail $5C); the actor list uses $56 / $58
    BEQ loc_02EF1A

  loc_02EF13:
    TCD                   ; D = this thinker's slot
    STZ $08               ; Zero the wait counter: the thinker runs on its next pass
    LDA $06               ; Next-link of this thinker; zero ends the list
    BNE loc_02EF13

  loc_02EF1A:
    PLD 
    PLP 
    RTS 
}

---------------------------------------------
; Copies the state listed in the block note's SAVE MAP into the backup areas and zeroes joypadCurrent / joypadMaskStd so no gameplay input leaks into the inventory scene. DBR is saved with PHB because every MVN leaves the destination bank in DBR. Each MVN leaves X / Y just past its block, which is why some copies reload only one of the two registers (save: X only on the second, fourth and sixth copy; restore: Y only on the second and fourth).

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
    LDA $cameraTargetX, X ; Camera words $06BE-$06C9: cameraTargetX, cameraDeltaX, cameraTargetY, cameraDeltaY, scrollOverrideH, forcedScrollOverride
    STA $7E3890, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02EF56
    LDX #$0E00            ; MVN $00:0E00 -> $7E:3490: the actor free-slot list (long pointer $4E / $50), 256 bytes
    LDY #$3490
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$3000            ; MVN $7E:3000 -> $7E:3590: the thinker free-slot list (long pointer $52 / $54), 256 bytes; Y continues from the previous copy
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$1000            ; MVN $00:1000 -> $7F:E000: the 84 actor slots of $30 bytes ($1000 total)
    LDY #$E000
    LDA #$0FFF
    MVN #$7F, #$00
    LDX #$1000            ; MVN $7F:1000 → $7F:F000 — $1000 bytes actor extended data page
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$0F00            ; MVN $00:0F00 -> $7E:3690: the thinker table (16 slots of $10 bytes)
    LDY #$3690
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$0F00            ; MVN $7F:0F00 -> $7E:3790: thinker extended data (animScratch at $7F0000 + slot); Y continues from the previous copy
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
; Reverse of SaveGameState for everything except the palette staging buffer. DP $4E-$5D comes back before the pages it points into; both are restored before anything runs. scrollOverrideV, $06CC and $00B2 are not restored because they were never saved.

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
    LDX #$3490            ; MVN $7E:3490 -> $00:0E00: restore the actor free-slot list
    LDY #$0E00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$3000            ; MVN $7E:3590 -> $7E:3000: restore the thinker free-slot list
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$E000            ; MVN $7F:E000 → $00:1000 — restore actor instance table
    LDY #$1000
    LDA #$0FFF
    MVN #$00, #$7F
    LDY #$1000            ; MVN $7F:F000 → $7F:1000 — restore actor extended data page
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$3690            ; MVN $7E:3690 -> $00:0F00: restore the thinker table
    LDY #$0F00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$0F00            ; MVN $7E:3790 -> $7F:0F00: restore the thinker extended data
    LDA #$00FF
    MVN #$7F, #$7E
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Copies $203 bytes from $7E:38B4 back to the $7F:0A00 palette staging buffer. Called after the scene graphics are reloaded so LoadScenePalettes and the ability palette see the saved colours.

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