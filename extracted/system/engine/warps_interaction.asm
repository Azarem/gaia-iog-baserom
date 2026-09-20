; Warp system, chest interaction, and barrier tiles (173533–174986, Bank 02).
; 
; Combines three related subsystems that manage scene transitions (warps), treasure chest opening, and event-flagged barrier tile placement. All three reference per-scene data from table_01ADA8 (barrier/chest entries) and scene_warps (warp rectangles).
; 
; === WARP SYSTEM ===
; 
; InitWarpTable sets up two warp table pointers for the current scene:
; - $00D4: Standard warp entries (12 bytes each) — scene-transition warps
; - $00D6: Extended warp entries (13 bytes each) — in-scene forced-walk warps
; 
; The two tables are stored contiguously in scene_warps, separated by an $FF terminator byte. InitWarpTable walks past the standard entries to find the extended table start.
; 
; CheckWarpRectangles tests the player's tile and pixel position against both tables:
; 1. Standard warps: tile-level AABB check (playerXTile/playerYTile vs entry bytes 0-3), then sub-tile pixel refinement via ConvertWarpToPixels. Hit → ExecuteWarp.
; 2. Extended warps: same AABB structure but 13-byte entries (extra byte for scroll step configuration). Hit → code_02AAF2 for forced-walk warp.
; 
; ConvertWarpToPixels converts tile coordinates to pixel coordinates (×16) and computes the bounding box size (width/height × 16 − 15) for sub-tile precision checking.
; 
; ExecuteWarp saves complete warp state: destination scene ($0642), player spawn coordinates ($064C/$064E/$0650/$0652), source scene ($0B12), source warp rectangle bounds ($0B08-$0B0E), and camera offset packing ($0B10/$0B11 = camera X/Y packed into nibbles). Bit 7 of entry byte 9 selects between immediate transition (clear) and deferred transition with save data pointer (set).
; 
; code_02AAF2 handles extended (forced-walk) warps: checks the $0100 re-entry guard in playerFlags, configures scroll step parameters, calls InitCameraBounds, and spawns a direction-specific forced walk actor via StartForcedWalk.
; 
; StartForcedWalk decodes the direction from scrollStepTableBase: bit 5 = West, bit 4 = East, bit 7 = North, default = South. Spawns the corresponding ForcedWalk actor (ForcedWalkSouth/West/East/North) as a SpawnBefore on the player actor. Sets playerFlags $0100 (forced walk active) and $2000 (run mode) on the player actor.
; 
; === CHEST INTERACTION SYSTEM ===
; 
; HandleChestInteraction is called when the player presses the action button while facing north. It checks:
; 1. layerPriorityFlag bit $0200 (interaction disabled) → reject
; 2. Player actor flag $0004 (standing/facing valid) → reject if not set
; 3. joypadCurrent bit $0800 (up button) → reject if not pressed
; 4. GetPlayerFacingDirection == 1 (north) → reject if not facing north
; 
; The chest tile search reads the mapLayerTilemap at the player's computed facing position. Tile $F8 = chest left side, $F9 = chest right side. For $F9, it checks the left neighbor for $F8 to locate the chest origin.
; 
; Once found, the routine walks table_01ADA8 entries for the current scene ($0646) to find a matching chest by X/Y coordinate. Unmatched chests show a default "nothing found" dialogue (dialogstring_01FF48).
; 
; Matched chests branch on entry byte 2:
; - Nonzero: Item chest → GiveItemToPlayer. On success: ShowDialogueFrame with item-get dialogue, open chest tiles ($FC), SetEventFlag. On inventory full: play SFX #$2A, show "can't carry" dialogue (dialogstring_01FF2D). If entry byte 3 bit 7 is set: spawn ChestOpeningActor for animated opening with music transition.
; - Zero: Flag-only chest → show "found" dialogue (dialogstring_01FF36), SetEventFlag.
; 
; DrawChestTiles places 4 tiles (2×2) for open/closed chest graphics at the chest's map position, queuing each to QueueVisibleTileVram for immediate VRAM update. Tile IDs: $06+2, $06+3 (top), $06, $06+1 (bottom), where $06 is the base tile ($FC for open, $F8 for closed).
; 
; === CHEST OPENING ACTOR ===
; 
; ChestOpeningActor manages animated chest opening with music transitions:
; 1. Stores musicParentActor, spawns SpcTransferMusicData for music loading
; 2. Guards against actor pool exhaustion ($1FC0)
; 3. Forwards the dialogue string pointer and render state to the spawned child
; 4. Suppresses joypad ($CFF0) and locks the player in an idle animation
; 5. Waits for musicTransitionState == $FFFF (music loaded)
; 6. Spawns ChestDialogueActor to show the item-get dialogue after a timed delay
; 7. Polls APUIO1 for $FF (SPC ready), then unlocks player and unmasks joypad
; 8. Spawns a second SpcTransferMusicData for follow-up data, waits again
; 9. WaitByte(11) for final sync, then clears displayModeFlags bit 7
; 
; ChestDialogueActor: waits 72 frames ($48), clears $1000 flag, stores render context ($20 → $0DB8), shows dialogue frame with stored string pointer, then dies.
; 
; === BARRIER TILES ===
; 
; PlaceBarrierTiles walks the table_01ADA8 entries for the current scene. For each entry where the event flag (byte 3 AND $7F → TestEventFlag_0200) is set, it places a 2×2 barrier tile pattern on the map:
;   Top-left: $FE, Top-right: $FF
;   Bottom-left: $FC, Bottom-right: $FD
; 
; These tiles mark impassable terrain (closed doors, blocked passages). When the corresponding event flag is later set by gameplay, ApplyAllEventBlocks (in event_blocks) swaps the barrier tiles away.
; 
; === UTILITY ===
; 
; SetAnimStatePointer: Sets a function pointer ($0000,Y) and clears the frame counter ($0008,Y) for an actor. Used by ChestOpeningActor to override the player's animation state during the chest opening sequence.
---------------------------------------------

?BANK 02

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'event_blocks'
?INCLUDE 'forced_walk'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'item_get_dialog_table'
?INCLUDE 'map_coords'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'scene_barrier_chest_table'
?INCLUDE 'scene_lifecycle'
?INCLUDE 'scene_warps'
?INCLUDE 'ShowDialogueFrame'
?INCLUDE 'system_core'

!sceneNext                      0642
!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadMaskStd                  065A
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!layerPriorityFlag              06EE
!musicParentActor               06F2
!sfxQueueCh2                    06F9
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!displayModeFlags               09EC
!sceneSaveData                  0AF0
!APUIO1                         2141
!mapLayerTilemap                7EA000
!chatPtr                        7F000A
!orbitAngle                     7F0010

---------------------------------------------

; Top-level entry point for warp detection and chest interaction.
; 
; Called during the main game loop to check if the player has entered a warp zone or is interacting with a chest. Saves processor state, switches to 16-bit mode, then calls CheckWarpRectangles first. If no warp hit (carry clear), calls HandleChestInteraction. Both routines return carry set on a hit. Four NOPs follow the carry check — likely patched-out debug or timing code. Restores processor state and returns.

CheckWarpAndChest {
    PHP 
    REP #$20
    JSR $&CheckWarpRectangles ; Per-frame dispatch: test warp rectangles before chest interaction
    BCS loc_02A5EA
    JSR $&HandleChestInteraction ; No warp hit — try A-button chest open on facing tile
    BCS loc_02A5EA

  loc_02A5EA:
    NOP                   ; NOP sled (×4) — patch/debug padding after warp/chest carry check
    NOP 
    NOP 
    NOP 
    PLP 
    RTL 
}

---------------------------------------------
; Place 2×2 barrier tile patterns on the map for event-flagged entries.
; 
; Walks the table_01ADA8 entries for the current scene ($0646 indexes scene_warps → table pointer). Each 4-byte entry contains: byte 0 = X tile, byte 1 = Y tile, byte 2 = item/content, byte 3 = event flag (bit 7 = terminator).
; 
; Termination: bit 7 set on byte 0 ($0080 test) ends the walk.
; 
; For each entry: tests the event flag (byte 3 AND $7F → TestEventFlag_0200). If the flag is set (carry set): computes the map index from tile coordinates (X, Y−1 for the top row), then writes four barrier tiles:
;   $FE at (X, Y−1), $FF at (X+1, Y−1) — top row
;   $FC at (X, Y), $FD at (X+1, Y) — bottom row
; 
; These tiles represent closed doors/barriers. Uses MapIndexMoveRight and MapIndexMoveDown for adjacent tile addressing.

PlaceBarrierTiles {
    PHP 
    REP #$20
    LDY $0646             ; Scene index $0646 → table_01ADA8 pointer for barrier/chest entries
    LDX $&scene_barrier_chest_table, Y ; Load 4-byte entry base for current scene barrier list

  loc_02A5F9:
    LDA $0000, X          ; Entry byte 0 bit 7 ($0080) = end-of-table sentinel
    BIT #$0080
    BNE loc_02A65B
    LDA $0003, X          ; Entry byte 3 AND $7F → event flag index (TestEventFlag_0200)
    AND #$007F
    JSL $@cop_handlers_flags.TestEventFlag_0200 ; Flag clear (BCC) — barrier removed; skip 2×2 tile placement
    BCC loc_02A655
    PHX 
    SEP #$20              ; Entry +0/+1 = tile X/Y; DEC Y anchors top row at Y−1
    LDA $0000, X
    STA $18
    LDA $0001, X
    DEC 
    STA $1C
    STZ $19
    STZ $1D
    LDX #$0000            ; TileCoordsToMapIndex — map index for top-left barrier cell
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    STX $00
    LDA #$FE              ; Load $FE — barrier top-left closed tile
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight → adjacent column
    LDA #$FF              ; Load $FF — barrier top-right closed tile
    STA $mapLayerTilemap, X
    LDX $00
    STX $02
    JSL $@map_coords.MapIndexMoveDown ; MapIndexMoveDown — advance to bottom row of 2×2
    LDA #$FC              ; Load $FC — barrier bottom-left closed tile
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight
    LDA #$FD              ; Load $FD — barrier bottom-right closed tile
    STA $mapLayerTilemap, X
    REP #$20
    PLX 

  loc_02A655:
    INX                   ; Next entry: INX×4 (4 bytes per barrier record)
    INX 
    INX 
    INX 
    BRA loc_02A5F9

  loc_02A65B:
    PLP 
    RTL 
}

---------------------------------------------
; Detect and process treasure chest interactions.
; 
; Guards (all must pass):
; 1. layerPriorityFlag bit $0200 clear (interaction not disabled)
; 2. Player actor ($09AA) flag $0004 set (valid standing state)
; 3. joypadCurrent bit $0800 set (up button pressed)
; 4. GetPlayerFacingDirection == 1 (facing north)
; 
; Chest detection: Computes the tile position one cell north of the player. Reads mapLayerTilemap at that position:
; - $F8 = chest left tile → origin found directly
; - $F9 = chest right tile → checks left neighbor for $F8
; - Other = no chest → returns
; 
; Table search: Walks table_01ADA8 for the current scene, comparing each entry's X/Y against the chest origin tile. Unmatched → dialogstring_01FF48 ("nothing found" default).
; 
; Matched chest processing (entry byte 2):
; - Nonzero (item): Sets displayModeFlags $0080, draws open tiles ($FC base), calls GiveItemToPlayer. Success → ShowDialogueFrame, SetEventFlag. Inventory full → SFX #$2A, "can't carry" dialogue. If entry byte 3 bit 7 set → spawns ChestOpeningActor for animated music-transition opening.
; - Zero (flag-only): dialogstring_01FF36 ("found" message), SetEventFlag.
; 
; The chest tile computation uses player position with offsets: X = ((pos−8) aligned to 16 + half-tile) >> 4, Y = (pos−32) >> 4.

HandleChestInteraction {
    LDA $layerPriorityFlag ; Guard: layerPriorityFlag bit 9 ($0200) disables field interaction
    BIT #$0200
    BEQ loc_02A666
    RTS 

  loc_02A666:
    LDY $playerActor      ; Guard: player actor $0010 bit 2 ($0004) = interactable standing state
    LDA $0010, Y
    BIT #$0004
    BNE loc_02A672
    RTS 

  loc_02A672:
    LDA $joypadCurrent    ; Guard: Up button ($0800) pressed this frame
    BIT #$0800
    BNE loc_02A67B
    RTS 

  loc_02A67B:
    JSL $@GetPlayerFacingDirection ; Guard: GetPlayerFacingDirection must return north ($0001)
    AND #$00FF
    CMP #$0001
    BEQ loc_02A688
    RTS 

  loc_02A688:
    LDY $playerActor      ; Compute tile coords one cell north of player pixel position
    LDA $0014, Y
    SEC 
    SBC #$0008
    STA $18
    AND #$0008            ; X snap: ((X−8) & $08)<<1 + (X−8) then >>4 — 16px column alignment
    ASL 
    CLC 
    ADC $18
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, Y          ; Y snap: (Y − $20) >> 4 — tile row in front of player
    SEC 
    SBC #$0020
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDX #$0000
    SEP #$20
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex → read mapLayerTilemap at facing cell
    LDA $mapLayerTilemap, X
    STX $02
    CMP #$F8              ; $F8 = chest left half — verify right neighbor is $F9
    BEQ loc_02A6D8
    CMP #$F9              ; $F9 = chest right half — verify left neighbor is $F8
    BEQ loc_02A6C8

  loc_02A6C5:
    REP #$20
    RTS 

  loc_02A6C8:
    JSL $@map_coords.MapIndexMoveLeft ; MapIndexMoveLeft; left tile must be $F8 for valid 2-wide chest
    LDA $mapLayerTilemap, X
    CMP #$F8
    BNE loc_02A6C5
    DEC $18               ; Adjust origin X−1 when chest detected via right-half tile
    BRA loc_02A6E4

  loc_02A6D8:
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight; right tile must be $F9 for valid 2-wide chest
    LDA $mapLayerTilemap, X
    CMP #$F9
    BNE loc_02A6C5

  loc_02A6E4:
    LDY $0646             ; Walk scene chest table — compare entry X/Y to computed origin
    LDX $&scene_barrier_chest_table, Y

  loc_02A6EA:
    LDA $0000, X          ; Negative entry byte 0 = table end → default empty-chest dialogue
    BMI loc_02A700
    CMP $18
    BNE loc_02A6FA
    LDA $0001, X
    CMP $1C
    BEQ loc_02A70A

  loc_02A6FA:
    INX 
    INX 
    INX 
    INX 
    BRA loc_02A6EA

  loc_02A700:
    REP #$20
    LDY #$&item_get_dialog_table.dialogstring_01FF48 ; No table match — ShowDialogueFrame dialogstring_01FF48
    JSL $@ShowDialogueFrame
    RTS 

  loc_02A70A:
    REP #$20
    PHX 
    LDA #$0080            ; TSB displayModeFlags $0080 — hold sprite VRAM DMA during chest open
    TSB $displayModeFlags
    LDA #$00FC            ; $06 = $FC — open-chest tile base (top-left of 2×2)
    STA $06
    JSR $&DrawChestTiles  ; DrawChestTiles — swap map tiles to open-chest graphics
    LDA $01, S
    TAX 
    LDA $0002, X          ; Entry byte 2 nonzero → item chest; zero → flag-only chest
    AND #$00FF
    BEQ loc_02A73D
    JSL $@inventory_mgmt.GiveItemToPlayer ; GiveItemToPlayer — carry set means inventory full
    BCC loc_02A753
    JSL $@ShowDialogueFrame ; Inventory full dialogue; redraw closed tiles before exit
    LDA $01, S
    TAX 
    LDA #$00F8            ; $06 = $F8 — closed-chest tile base for restore draw
    STA $06
    JSR $&DrawChestTiles
    BRA loc_02A7B0

  loc_02A73D:
    LDY #$&item_get_dialog_table.dialogstring_01FF36 ; Flag-only chest — ShowDialogueFrame dialogstring_01FF36
    JSL $@ShowDialogueFrame
    LDA $01, S
    TAX 
    LDA $0003, X          ; Entry byte 3 AND $7F → SetEventFlag_0200 (no item grant)
    AND #$007F
    JSL $@cop_handlers_flags.SetEventFlag_0200
    BRA loc_02A7B0

  loc_02A753:
    LDA $01, S
    PHX 
    TAX 
    LDA $0003, X          ; Entry byte 3 bit 7 ($0080) → animated open with music transition
    BIT #$0080
    BNE loc_02A778
    LDA #$0080            ; Simple item get — clear displayModeFlags $0080, play SFX #$2A
    TRB $displayModeFlags
    SEP #$20
    LDA #$2A
    STA $sfxQueueCh2
    REP #$20
    PLX 
    LDY #$&item_get_dialog_table.dialogstring_01FF2D ; ShowDialogueFrame dialogstring_01FF2D — item acquired message
    JSL $@ShowDialogueFrame
    BRA loc_02A7A1

  loc_02A778:
    PLX 
    PHY 
    PHX 
    LDX #$0000
    COP [SpawnListAppend] ( @ChestOpeningActor, #00, #00, #$2000 ) ; Spawn ChestOpeningActor via SpawnLastRel — animated music open
    LDA $0012, Y          ; Set actor $0012 bit 12 ($1000) — lock actor during sequence
    ORA #$1000
    STA $0012, Y
    LDA #$0017            ; Load dialogue string ID in actor $0026 for child handoff
    STA $0026, Y
    PLX 
    PLA 
    STA $0024, Y          ; Forward dialogue pointer ($24) and render bank ($20) to opening actor
    LDA $0DB8
    STA $0020, Y

  loc_02A7A1:
    LDA $01, S
    TAX 
    LDA $0003, X          ; SetEventFlag_0200 on success — chest permanently opened
    AND #$007F
    JSL $@cop_handlers_flags.SetEventFlag_0200
    PLX 
    RTS 

  loc_02A7B0:
    LDA #$0080            ; Exit path: TRB displayModeFlags $0080 — re-enable sprite DMA
    TRB $displayModeFlags
    PLX 
    RTS 
}

---------------------------------------------
; Animated chest opening actor with music transition.
; 
; Manages a multi-frame chest opening sequence that includes music loading and dialogue display. Lifecycle:
; 
; 1. Stores musicParentActor to orbitAngle scratch field for parent tracking
; 2. Spawns SpcTransferMusicData via SpawnAfterFlags — guards $1FC0 (pool full → code_02A88B cleanup)
; 3. Forwards the dialogue string ID ($26+1) and $1000 flag to the music child
; 4. Saves actor references: X = self, Y = music child
; 5. Suppresses joypad ($CFF0 → joypadMaskStd) and locks player in idle animation via SetAnimStatePointer (pointing to player_transition_handlers.PlayerIdleAnimLoop)
; 6. Sets playerFlags $0800 (special mode)
; 7. COP [SetEntryContinue] — yields until musicTransitionState == $FFFF
; 8. Spawns ChestDialogueActor (forwards $24 dialogue string and $1000 flag, stores render bank $20)
; 9. COP [SetEntryContinue] — polls APUIO1 for $FF (SPC ready)
; 10. Unlocks player (clear $1000 from actor flags, restore idle animation to RestorePlayerControlDirect), unmasks joypad ($CFF0 TRB)
; 11. Spawns second SpcTransferMusicData for follow-up data, guards $1FC0
; 12. Forwards musicParentActor (via orbitAngle) and $1000 flag to the second child
; 13. COP [SetEntryContinue] — waits for second transfer ($FFFF)
; 14. COP [WaitByte] ($0B) — 11-frame final sync
; 
; code_02A88B: Cleanup — clears displayModeFlags bit 7 ($0080) and COP [Die].

ChestOpeningActor {
    LDA $musicParentActor ; Load musicParentActor to orbitAngle — parent tracking for child actors
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn SpcTransferMusicData — async music load for chest fanfare
    CPY #$1FC0            ; Actor pool full ($1FC0) → code_02A88B cleanup (clear flag, Die)
    BNE loc_02A7CE
    JMP $&code_02A88B

  loc_02A7CE:
    TXA                   ; Rotate registers TXA/TYX/TAY — self→X, music child→Y for setup
    TYX 
    TAY 
    LDA $26               ; Forward dialogue index ($26+1) to music child chatPtr
    INC 
    STA $chatPtr, X
    LDA $0012, X          ; Set music child $0012 bit $1000 — suspend during transfer
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$CFF0            ; TSB joypadMaskStd $CFF0 — mask D-pad and action buttons during open
    TSB $joypadMaskStd
    LDY $playerActor      ; Lock player actor: set $1000, idle anim via SetAnimStatePointer
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$*player_transition_handlers.PlayerIdleAnimLoop ; Player idle handler → player_transition_handlers.PlayerIdleAnimLoop
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerIdleAnimLoop
    JSR $&SetAnimStatePointer
    LDA #$0800            ; TSB playerFlags $0800 — special chest-open player mode
    TSB $playerFlags
    COP [SetEntryHere]    ; COP SetEntryContinue — yield until musicTransitionState == $FFFF
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A813
    RTL 

  loc_02A813:
    COP [SpawnAfterFlags] ( @ChestDialogueActor, #$2000 ) ; Spawn ChestDialogueActor — delayed item-get dialogue after music
    LDA $24               ; Forward stored dialogue string ($24) to dialogue actor
    STA $0024, Y
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $20               ; Forward render context bank ($20) to dialogue actor
    STA $0020, Y
    COP [SetEntryHere]
    SEP #$20              ; Poll APUIO1 — wait for SPC700 ready signal ($FF)
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_02A83F
    RTL 

  loc_02A83F:
    LDY $playerActor      ; Music ready — unlock player: clear actor $1000 lock bit
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$*player_transition_handlers.RestorePlayerControlDirect ; Restore player idle handler RestorePlayerControlDirect via SetAnimStatePointer
    STA $0002, Y
    LDA #$&player_transition_handlers.RestorePlayerControlDirect
    JSR $&SetAnimStatePointer
    LDA #$CFF0            ; TRB joypadMaskStd $CFF0 — restore normal input
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Second SpcTransferMusicData spawn — follow-up SPC data transfer
    CPY #$1FC0
    BEQ code_02A88B
    PHX                   ; Restore musicParentActor from orbitAngle to second child chatPtr
    LDA $orbitAngle, X
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryHere]    ; COP SetEntryContinue — wait for second music transfer complete
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A888
    RTL 

  loc_02A888:
    COP [WaitByte] ( #0B ) ; COP WaitByte #$0B — 11-frame final sync before actor exit
}

code_02A88B {
    LDA #$0080            ; code_02A88B: TRB displayModeFlags $0080 then COP Die — pool-full cleanup
    TRB $displayModeFlags
    COP [Die]
}

---------------------------------------------
; Timed chest dialogue display actor.
; 
; One-shot actor spawned by ChestOpeningActor to show the item-get dialogue after a delay:
; 1. COP [WaitByte] ($48) — waits 72 frames for the music transition to settle
; 2. Clears bit $1000 from its own actor flags ($12)
; 3. Stores render context ($20 → $0DB8)
; 4. Calls ShowDialogueFrame with the dialogue string pointer stored in $24
; 5. COP [Die]

ChestDialogueActor {
    COP [WaitByte] ( #48 ) ; COP WaitByte #$48 — 72-frame delay before showing item dialogue
    LDA #$1000            ; TRB actor $12 $1000 — release render lock on this actor
    TRB $12
    LDA $20               ; Load render bank $20 → $0DB8 for dialogue frame context
    STA $0DB8
    LDY $24               ; ShowDialogueFrame with dialogue pointer from actor $24
    JSL $@ShowDialogueFrame
    COP [Die]
}

---------------------------------------------
; Set an actor's function pointer and clear its frame counter.
; 
; Stores A to $0000,Y (the actor's execution pointer / animation state), then zeros $0008,Y (frame counter / animation timer). Used by ChestOpeningActor to override the player actor's animation during the chest opening sequence.

SetAnimStatePointer {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

---------------------------------------------
; Draw 2×2 chest tiles on the map and queue VRAM updates.
; 
; Entry: X = chest table entry pointer, $06 = base tile ID ($FC for open, $F8 for closed).
; 
; Reads the chest's X/Y tile position from the table entry (bytes 0-1), converts to pixel coordinates (×16) for visibility checking. Computes the map index via TileCoordsToMapIndex.
; 
; Writes four tiles in order, calling QueueVisibleTileVram after each for visible VRAM update:
;   Top-left: $06+2, Top-right: $06+3
;   Bottom-left: $06, Bottom-right: $06+1
; 
; Between tiles, advances the pixel X/Y coordinates by 16 and uses MapIndexMoveRight/MapIndexMoveDown for map traversal. After all four tiles, writes a zero sentinel to the VRAM queue and calls UpdateFrameRender to flush the display.

DrawChestTiles {
    PHP 
    LDA $0000, X          ; Chest entry byte 0 → tile X; ×16 for pixel visibility coords ($1A)
    AND #$00FF
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0001, X
    AND #$00FF            ; Entry byte 1 → tile Y; DEC then ×16 for pixel Y ($1E)
    DEC 
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    SEP #$20
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex — starting map index for 2×2 chest draw
    STX $02
    STX $00
    LDY #$0000
    LDA $06               ; $06+2 → top-left map tile; QueueVisibleTileVram if on-screen
    CLC 
    ADC #$02
    STA $mapLayerTilemap, X
    JSR $&event_blocks.QueueVisibleTileVram
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight
    LDA $06               ; $06+3 → top-right tile; advance pixel X by $10
    CLC 
    ADC #$03
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    SEP #$20
    JSR $&event_blocks.QueueVisibleTileVram
    LDX $00
    STX $02
    JSL $@map_coords.MapIndexMoveDown ; MapIndexMoveDown — bottom row of 2×2
    LDA $06               ; $06 → bottom-left tile; adjust pixel Y by ±$10
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    SEC 
    SBC #$0010
    STA $1A
    LDA $1E
    CLC 
    ADC #$0010
    STA $1E
    SEP #$20
    JSR $&event_blocks.QueueVisibleTileVram
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight
    LDA $06               ; $06+1 → bottom-right tile
    INC 
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    SEP #$20
    JSR $&event_blocks.QueueVisibleTileVram
    REP #$20
    LDA #$0000            ; Zero dmaSkipFlag sentinel — end VRAM queue batch
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender — flush queued chest tile VRAM updates
    PLP 
    RTS 
}

---------------------------------------------
; Initialize warp table pointers for the current scene.
; 
; Reads the scene index ($0646) to look up the warp data pointer from scene_warps. Stores the pointer to $00D4 (standard warp table start).
; 
; Then walks the standard warp entries to find the extended table: each entry starts with a non-$FF byte, and the routine advances by 12 bytes ($000C) per entry until finding the $FF terminator. The byte after the terminator is stored to $00D6 (extended warp table start).

InitWarpTable {
    REP #$20
    LDA $0646             ; Scene index $0646 → scene_warps table pointer for this map
    TAX 
    LDA $&scene_warps, X
    STA $00D4             ; Store standard warp list start → $00D4

  loc_02A963:
    SEP #$20
    TAX 
    LDA $0000, X          ; Walk standard entries until byte 0 = $FF terminator
    BMI loc_02A974
    REP #$20
    TXA 
    CLC 
    ADC #$000C            ; Standard warp stride: +$000C (12 bytes per entry)
    BRA loc_02A963

  loc_02A974:
    INX                   ; Extended warp table begins at byte after $FF sentinel → $00D6
    STX $00D6
    SEP #$20
    RTL 
}

---------------------------------------------
; Test player position against all warp rectangles for the current scene.
; 
; Two passes — standard warps ($00D4, 12-byte entries) and extended warps ($00D6, 13-byte entries).
; 
; Each pass performs:
; 1. Tile-level AABB test: playerXTile minus entry X, compared against entry width; playerYTile minus entry Y, compared against entry height. Uses unsigned comparison (BCS = outside range).
; 2. Sub-tile pixel refinement: ConvertWarpToPixels converts tile coords to pixel bounding box. playerXPos/playerYPos minus origin, compared against extent.
; 3. On hit: standard warps → ExecuteWarp; extended warps → code_02AAF2.
; 
; Entry stride: standard = $000C (12 bytes), extended = $000D (13 bytes). Both terminate on $FF sentinel byte.
; 
; If no warp hit: clears playerFlags bit $0100 (forced walk flag) and returns carry clear.

CheckWarpRectangles {
    SEP #$20
    LDX $00D4             ; Pass 1: standard warp table at $00D4 (12-byte entries)
    BEQ loc_02A9C9

  loc_02A982:
    LDA $0000, X          ; Entry byte 0 == $FF → end of standard warp list
    CMP #$FF
    BEQ loc_02A9C9
    LDA $playerXTile      ; Tile AABB: playerXTile − entry X vs entry width (byte 2)
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02A9A1
    LDA $playerYTile      ; Tile AABB: playerYTile − entry Y vs entry height (byte 3)
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02A9AD

  loc_02A9A1:
    REP #$20
    TXA 
    CLC 
    ADC #$000C            ; Outside tile rect — advance X by $000C to next standard entry
    TAX 
    SEP #$20
    BRA loc_02A982

  loc_02A9AD:
    REP #$20
    JSR $&ConvertWarpToPixels ; Inside tile rect — ConvertWarpToPixels for sub-tile refinement
    LDA $playerXPos       ; Pixel test: playerXPos − origin X vs pixel width extent ($04)
    SEC 
    SBC $00
    CMP $04
    BCS loc_02A9C9
    LDA $playerYPos       ; Pixel test: playerYPos − origin Y vs pixel height extent ($06)
    SEC 
    SBC $02
    CMP $06
    BCS loc_02A9C9
    JMP $&ExecuteWarp     ; Standard warp hit — JMP ExecuteWarp (scene transition)

  loc_02A9C9:
    SEP #$20
    LDX $00D6             ; Pass 2: extended warp table at $00D6 (13-byte entries)
    BEQ loc_02AA17

  loc_02A9D0:
    LDA $0000, X          ; Extended entry byte 0 == $FF → end of extended list
    CMP #$FF
    BEQ loc_02AA17
    LDA $playerXTile      ; Same tile-level AABB test on extended warp entries
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02A9EF
    LDA $playerYTile
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02A9FB

  loc_02A9EF:
    REP #$20
    TXA 
    CLC 
    ADC #$000D            ; Outside rect — advance X by $000D (13-byte extended stride)
    TAX 
    SEP #$20
    BRA loc_02A9D0

  loc_02A9FB:
    REP #$20
    JSR $&ConvertWarpToPixels ; Inside extended rect — sub-tile pixel bounding box check
    LDA $playerXPos
    SEC 
    SBC $00
    CMP $04
    BCS loc_02AA17
    LDA $playerYPos
    SEC 
    SBC $02
    CMP $06
    BCS loc_02AA17
    JMP $&code_02AAF2     ; Extended warp hit — JMP code_02AAF2 (forced-walk pan)

  loc_02AA17:
    REP #$20
    LDA #$0100            ; No warp hit — TRB playerFlags $0100 (clear forced-walk active)
    TRB $playerFlags
    CLC 
    RTS 
}

---------------------------------------------
; Convert warp rectangle tile coordinates to pixel bounding box.
; 
; Reads 4 bytes from the warp entry at X:
;   Byte 0 → $00: origin X (tile × 16 = pixel)
;   Byte 1 → $02: origin Y (tile × 16)
;   Byte 2 → $04: width (tile × 16 − 15 = pixel extent)
;   Byte 3 → $06: height (tile × 16 − 15)
; 
; The −15 ($000F) on width/height converts from tile count to the maximum pixel offset within the rectangle. This provides sub-tile precision: the player's exact pixel position must be within the rectangle, not just the tile position.

ConvertWarpToPixels {
    LDA $0000, X          ; Origin X: entry byte 0 × 16 → pixel left edge ($00)
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    LDA $0001, X          ; Origin Y: entry byte 1 × 16 → pixel top edge ($02)
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $02
    LDA $0002, X          ; Width extent: entry byte 2 × 16 − $0F → max X offset ($04)
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$000F
    STA $04
    LDA $0003, X          ; Height extent: entry byte 3 × 16 − $0F → max Y offset ($06)
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$000F
    STA $06
    RTS 
}

---------------------------------------------
; Execute a standard scene-transition warp.
; 
; Stores comprehensive warp state from the warp table entry:
;   $0AF4/$0AF6: Warp data pointer (entry+4, with scene_warps bank byte)
;   sceneNext ($0642): Destination scene ID (entry byte 4)
;   $064C/$064E: Destination X/Y position (entry bytes 5-6, 7-8)
;   $0650: Direction/flags (entry byte 9)
;   $0652: Scroll parameters (entry bytes 10-11)
;   $0B12: Source scene ID (sceneCurrent)
;   $0B08/$0B0C/$0B0A/$0B0E: Source warp rectangle bounds (entry bytes 0-3)
; 
; Camera state packing: $0B10 = (cameraOffsetX high nibble) | (cameraOffsetY high nibble << 4). $0B11 = (cameraBoundsX high nibble) | (cameraBoundsY high nibble << 4). Packs 4 camera values into 2 bytes.
; 
; Direction byte 9 bit 7 selects transition mode:
;   Bit 7 clear: immediate transition — returns carry set
;   Bit 7 set: deferred transition — masks off bit 7, stores save data pointer ($0AF0 = entry+4 offset, $0AF2 = scene_warps bank pointer), returns carry set

ExecuteWarp {
    PHP 
    TXA                   ; Save warp entry pointer+4 → $0AF4 (data offset for transition)
    CLC 
    ADC #$0004
    STA $0AF4
    SEP #$20
    LDA #$^scene_warps    ; Load scene_warps bank byte → $0AF6
    STA $0AF6
    LDA $0004, X          ; Load destination scene, coords, direction from warp entry bytes 4–11
    STA $sceneNext
    LDY $0005, X
    STY $064C
    LDY $0007, X
    STY $064E
    LDA $0009, X
    STA $0650
    LDY $000A, X
    STY $0652
    LDY $sceneCurrent     ; Snapshot source scene ID and warp rectangle bounds → $0B08–$0B12
    STY $0B12
    LDA $0000, X
    STA $0B08
    LDA $0001, X
    STA $0B0C
    LDA $0002, X
    STA $0B0A
    LDA $0003, X
    STA $0B0E
    LDA $cameraOffsetX+1  ; Pack camera offset X/Y high nibbles into $0B10
    AND #$0F
    STA $0B10
    LDA $cameraOffsetY+1
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $0B10
    STA $0B10
    LDA $cameraBoundsX+1  ; Pack camera bounds X/Y high nibbles into $0B11
    AND #$0F
    STA $0B11
    LDA $cameraBoundsY+1
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $0B11
    STA $0B11
    LDA $0650             ; Direction byte 9 bit 7 ($80): deferred vs immediate transition mode
    BIT #$80
    BNE loc_02AADA
    PLP 
    SEC 
    RTS 

  loc_02AADA:
    AND #$7F              ; Deferred mode: mask bit 7, save entry+4 pointer to sceneSaveData/$0AF2
    STA $0650
    REP #$20
    TXA 
    CLC 
    ADC #$0004
    STA $sceneSaveData
    LDA #$*scene_warps
    STA $0AF2
    PLP 
    SEC 
    RTS 
}

---------------------------------------------
; Handle extended (forced-walk) warp — in-scene camera pan with player automation.
; 
; Guard: checks playerFlags bit $0100 (forced walk already active). If set, returns immediately (RTS) to prevent re-triggering.
; 
; Setup:
;   $0650: Data pointer (entry + 7, for scroll/direction parameters)
;   playerSpeedEw/playerSpeedNs: zeroed (player movement stops)
;   $0652: Destination position (entry bytes 4-5)
;   scrollStepTableBase: Scroll step configuration (entry byte 6)
; 
; Calls InitCameraBounds to configure camera limits for the destination area, then StartForcedWalk to spawn the appropriate directional walk actor. Returns carry set.

code_02AAF2 {
    LDA $playerFlags      ; Re-entry guard: skip if playerFlags bit 8 ($0100) already set
    BIT #$0100
    BEQ loc_02AAFB
    RTS 

  loc_02AAFB:
    TXA                   ; Extended warp: store entry+7 pointer → $0650 (scroll/direction data)
    CLC 
    ADC #$0007
    STA $0650
    LDA #$0000            ; Zero playerSpeedEw/playerSpeedNs — halt player during forced walk
    STA $playerSpeedEw
    STA $playerSpeedNs
    SEP #$20
    LDY $0004, X          ; Entry bytes 4–5 → destination position $0652
    STY $0652
    LDA $0006, X          ; Entry byte 6 → scrollStepTableBase (direction + step config)
    STA $scrollStepTableBase
    JSL $@scene_lifecycle.InitCameraBounds ; InitCameraBounds — configure camera for destination area
    JSR $&StartForcedWalk ; StartForcedWalk — spawn directional walk actor on player
    REP #$20
    SEC 
    RTS 
}

---------------------------------------------
; Spawn a direction-specific forced walk actor on the player.
; 
; Sets playerFlags $0100 (forced walk active) and player actor flag $2000 (run mode). Clears scrollStepIndex. Decodes the walk direction from scrollStepTableBase:
;   Bit 5 ($0020): West → ForcedWalkWest
;   Bit 4 ($0010): East → ForcedWalkEast
;   Bit 7 ($0080): North → ForcedWalkNorth
;   Default: South → ForcedWalkSouth
; 
; Extracts the low nibble of scrollStepTableBase ($000F) as the actual scroll step value. Each direction variant uses PHD to set the player actor as DP, spawns via COP [SpawnBefore], then restores DP.

StartForcedWalk {
    REP #$20
    LDA #$0100            ; TSB playerFlags $0100 — mark forced-walk warp in progress
    TSB $playerFlags
    LDY $playerActor      ; Set player actor $0010 bit 13 ($2000) — run-mode during auto-walk
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    STZ $scrollStepIndex  ; Clear scrollStepIndex — restart scroll step table from head
    LDA $scrollStepTableBase ; Extract scroll step count: low nibble of scrollStepTableBase → $000F
    PHA 
    AND #$000F
    STA $scrollStepTableBase
    PLA 
    BIT #$0020            ; Direction decode from scrollStepTableBase high bits:
    BNE loc_02AB63        ; Bit 5 ($0020) → SpawnBefore ForcedWalkWest
    BIT #$0010            ; Bit 4 ($0010) → SpawnBefore ForcedWalkEast
    BNE loc_02AB70
    BIT #$0080            ; Bit 7 ($0080) → SpawnBefore ForcedWalkNorth
    BNE loc_02AB7D
    PHD                   ; Default → SpawnBefore ForcedWalkSouth; PHD/TCD sets player as DP
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkSouth )
    PLD 
    RTS 

  loc_02AB63:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkWest )
    PLD 
    RTS 

  loc_02AB70:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkEast )
    PLD 
    RTS 

  loc_02AB7D:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkNorth )
    PLD 
    RTS 
}