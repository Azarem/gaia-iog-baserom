; Warp system, treasure chest interaction, and opened-chest redraw (173533–174986, Bank 02).
; 
; Combines three related subsystems: scene-transition warps, treasure chest opening, and redrawing already-opened chests when a scene is built (PlaceOpenedChestTiles). The chest code reads per-scene records from scene_chest_table, the warp code reads warp rectangles from scene_warps. CheckWarpAndChest is called every frame from the main loop (system_core); InitWarpTable and PlaceOpenedChestTiles run while a scene is set up (scene_lifecycle; PlaceOpenedChestTiles again when inventory_overlay rebuilds the scene).
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
; 2. Extended warps: same AABB structure but 13-byte entries (bytes 4–5 camera window, byte 6 direction/sequence, bytes 7–12 walk steps). Hit → ExecuteForcedWalkWarp for forced-walk warp.
; 
; ConvertWarpToPixels converts tile coordinates to pixel coordinates (×16) and computes the bounding box size (width/height × 16 − 15) for sub-tile precision checking.
; 
; ExecuteWarp copies the standard entry into the transition parameters: destination scene ($0642, byte 4), player spawn X/Y ($064C/$064E, bytes 5–8), facing ($0650, byte 9 with bit 7 masked off) and the packed camera window read by InitCameraBounds ($0652, bytes 10–11). It also records the source scene ($0B12), the source rectangle bytes 0–3 ($0B08/$0B0C/$0B0A/$0B0E) and two camera bytes ($0B10/$0B11) holding bits 8–11 of the camera offset X/Y and of the camera bounds X/Y. Every warp stores a pointer to entry+4 and the scene_warps bank in $0AF4/$0AF6: GameOverSequence reloads from it when the player dies with 100 or more gems (revive). If bit 7 of entry byte 9 is set the same pointer is also stored in sceneSaveData ($0AF0/$0AF2), which GameOverSequence uses for a real game over (fewer than 100 gems). Both variants return carry set.
; 
; ExecuteForcedWalkWarp handles extended (forced-walk) warps: checks the $0100 re-entry guard in playerFlags, stores the camera window, direction/sequence byte and walk-step pointer, calls InitCameraBounds, and spawns a direction-specific forced walk actor via StartForcedWalk.
; 
; StartForcedWalk decodes the direction from scrollStepTableBase: bit 5 = West, bit 4 = East, bit 7 = North, default = South. Spawns the corresponding ForcedWalk actor (ForcedWalkSouth/West/East/North) as a SpawnBefore on the player actor. Sets playerFlags $0100 (forced walk active) and bit 13 ($2000, script-driven tick) in the player actor's flags word $10.
; 
; === CHEST INTERACTION SYSTEM ===
; 
; HandleChestInteraction runs every frame (via CheckWarpAndChest) and opens a chest when the player pushes against it from below. All of these must hold, otherwise it returns at once:
; 1. layerPriorityFlag bit $0200 clear (field interaction not disabled)
; 2. Player actor flag $10 bit 2 ($0004) set: the solid-contact flag of the collision code, i.e. the player is touching a solid tile
; 3. joypadCurrent bit $0800 (D-pad up) set
; 4. GetPlayerFacingDirection == 1 (north; the same code order as the facing COP operands)
; 
; The chest tile search reads mapLayerTilemap at the tile in front of the player. Tile $F8 = chest bottom-left, $F9 = chest bottom-right (the 2×2 closed chest uses base $F8: bottom $F8/$F9, top $FA/$FB). If the tile is $F9 the left neighbour must be $F8, and the origin X is decremented, so the origin is always the bottom-left cell.
; 
; The routine then walks the scene's records in scene_chest_table (scene index $0646) comparing byte 0/1 (X, Y of the bottom-left cell) with the origin. No match: the chest is shown the message dialogstring_01FF48 ("The jewel box is tightly closed.").
; 
; A matching record is processed according to its byte 2 (contents):
; - Nonzero: item chest. displayModeFlags bit 7 is set (display-filter mode: only actors flagged $1000 keep running), the open chest tiles (base $FC) are drawn, then GiveItemToPlayer runs. Success without record byte 3 bit 7: clear the display filter, SFX #$2A, ShowDialogueFrame with dialogstring_01FF2D (prints the item name held in $0DB8), SetEventFlag. Success with byte 3 bit 7: spawn ChestOpeningActor (fanfare with music transition) and SetEventFlag. Inventory full: show the dialogue string GiveItemToPlayer returned in Y (dialogstring_01FF02, "Your inventory's full!"), redraw the closed tiles (base $F8) and do not set the flag.
; - Zero: flag-only chest: dialogstring_01FF36 ("It is empty!"), then SetEventFlag.
; In both cases the event flag is record byte 3 AND $7F.
; 
; DrawChestTiles places a 2×2 chest at the record's position, queuing each tile to QueueVisibleTileVram for an immediate VRAM update. Tile IDs: base+2, base+3 (top row, Y−1), base, base+1 (bottom row), where base is $FC for an open chest and $F8 for a closed one.
; 
; === CHEST OPENING ACTOR ===
; 
; ChestOpeningActor runs the fanfare for chests whose record has byte 3 bit 7 set. The music value it handles is the one in musicParentActor ($06F2); other code calls that word the original music ID, so the name is a misnomer (see the audit rename proposals). The sequence:
; 1. Saves $06F2 in orbitAngle (per-actor scratch) and spawns SpcTransferMusicData (async SPC upload) as a child; the pool-full result ($1FC0) jumps to the cleanup.
; 2. Gives the child its track number (the $26 field set by HandleChestInteraction, #$17, plus 1) in chatPtr and flags it $1000 so it still runs while the world is frozen.
; 3. Masks the joypad ($CFFC into joypadMaskStd: every button except Select/Start), flags the player $1000, points the player's state at PlayerIdleAnimLoop and sets playerFlags $0800 (script lock).
; 4. Yields until musicTransitionState == $FFFF (upload finished), then spawns ChestDialogueActor with the dialogue pointer ($24) and the item ID ($20).
; 5. Yields until APUIO1 reads $FF, then releases the player (RestorePlayerControlDirect, clears the $1000 flag) and unmasks the joypad.
; 6. Spawns a second SpcTransferMusicData whose track value is the saved $06F2 (restoring the scene music), waits for $FFFF again, WaitByte 11 frames, clears displayModeFlags bit 7 and dies.
; 
; ChestDialogueActor: waits 72 frames, clears its own $1000 flag, restores the item ID from $20 to $0DB8 (the dialogue string prints the item name from there), shows the dialogue pointer stored in $24 with ShowDialogueFrame, and dies.
; 
; === OPENED-CHEST REDRAW (PlaceOpenedChestTiles) ===
; 
; PlaceOpenedChestTiles walks the scene's records in scene_chest_table. For each record whose event flag (byte 3 AND $7F, TestEventFlag_0200) is set, it writes the OPEN-chest 2×2 pattern at the record position:
;   Top-left: $FE, Top-right: $FF (row Y−1)
;   Bottom-left: $FC, Bottom-right: $FD (row Y)
; These are exactly the tiles DrawChestTiles draws with base $FC, and the records are the chest records, so the routine restores chests the player has already opened whenever the scene map is rebuilt (scene load, and inventory_overlay's scene reload). The earlier "closed door/barrier" reading is not supported by the code. Only the map is written; no VRAM update is queued.
; 
; === UTILITY ===
; 
; SetAnimStatePointer: Sets a function pointer ($0000,Y) and clears the frame counter ($0008,Y) for an actor. Used by ChestOpeningActor to override the player's animation state during the chest opening sequence.
---------------------------------------------

?BANK 02

?INCLUDE 'event_blocks'
?INCLUDE 'flag_helpers'
?INCLUDE 'forced_walk'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'item_get_dialog_table'
?INCLUDE 'map_coords'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'scene_chest_table'
?INCLUDE 'scene_lifecycle'
?INCLUDE 'scene_warps'
?INCLUDE 'ShowDialogueFrame'
?INCLUDE 'system_core'

!sceneNext                      0642
!sceneCurrent                   0644
!sceneTableIndex                0646
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
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
!sceneSaveDataBank              0AF2
!reviveWarpPtr                  0AF4
!reviveWarpBank                 0AF6
!sourceSceneId                  0B12
!APUIO1                         2141
!mapLayerTilemap                7EA000
!chatPtr                        7F000A
!orbitAngle                     7F0010

---------------------------------------------

; Top-level entry point for warp detection and chest interaction.
; 
; Called once per frame from the main loop (system_core). Saves processor state, switches to 16-bit A, then calls CheckWarpRectangles first. Only if that reports no warp (carry clear) does it call HandleChestInteraction, so a warp takes priority over a chest. Both helpers return carry set on a hit, but the BCS after the chest call targets the very next instruction and PLP restores the caller's flags, so the routine returns no result; its effects are the staged warp parameters or the chest actions themselves. Four NOPs sit before the PLP (leftover padding, purpose unknown).

CheckWarpAndChest {
    PHP 
    REP #$20
    JSR $&CheckWarpRectangles ; Per-frame dispatch: test warp rectangles before chest interaction
    BCS loc_02A5EA
    JSR $&HandleChestInteraction ; No warp hit — try A-button chest open on facing tile
    BCS loc_02A5EA

  loc_02A5EA:
    NOP                   ; Four NOPs: both branches above land here, so the carry tests have no effect
    NOP 
    NOP 
    NOP 
    PLP 
    RTL 
}

---------------------------------------------
; Redraw already-opened chests into the tile map when a scene is built.
; 
; Walks the scene's records in scene_chest_table (the scene index at $0646 selects the list). Each 4-byte record is: byte 0 = X tile (bit 7 set = end of list), byte 1 = Y tile of the chest's bottom row, byte 2 = contents (item ID, 0 = flag-only), byte 3 = event flag in bits 0–6 (bit 7 = open with the music fanfare).
; 
; For each record the event flag (byte 3 AND $7F, TestEventFlag_0200) is tested. If it is set the chest was opened, so the open 2×2 pattern is written to mapLayerTilemap:
;   $FE at (X, Y−1), $FF at (X+1, Y−1): top row
;   $FC at (X, Y), $FD at (X+1, Y): bottom row
; MapIndexMoveRight/MapIndexMoveDown step between the four cells. Only the tile map is written (no VRAM update).

PlaceOpenedChestTiles {
    PHP 
    REP #$20
    LDY $sceneTableIndex  ; Scene index ($0646) → this scene's chest record list
    LDX $&scene_chest_table, Y ; X = first 4-byte chest record

  loc_02A5F9:
    LDA $0000, X          ; Entry byte 0 bit 7 ($0080) = end-of-table sentinel
    BIT #$0080
    BNE loc_02A65B
    LDA $0003, X          ; Record byte 3 AND $7F → chest event flag
    AND #$007F
    JSL $@flag_helpers.TestEventFlag_0200 ; Carry set = flag set = chest already opened
    BCC loc_02A655        ; Flag clear: leave the closed chest as it is
    PHX 
    SEP #$20              ; Record bytes 0/1 = tile X/Y (Y = bottom row); DEC Y gives the top row
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
    LDA #$FE              ; $FE = open chest, top-left
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight ; One cell right
    LDA #$FF              ; $FF = open chest, top-right
    STA $mapLayerTilemap, X
    LDX $00
    STX $02
    JSL $@map_coords.MapIndexMoveDown ; MapIndexMoveDown — advance to bottom row of 2×2
    LDA #$FC              ; $FC = open chest, bottom-left
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight ; One cell right
    LDA #$FD              ; $FD = open chest, bottom-right
    STA $mapLayerTilemap, X
    REP #$20
    PLX 

  loc_02A655:
    INX                   ; Next record: +4 bytes
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
; Open the chest in front of the player (called by CheckWarpAndChest each frame; see the block note for the full flow).
; 
; Guards (all must pass, else RTS):
; 1. layerPriorityFlag bit $0200 clear (field interaction not disabled)
; 2. Player actor ($09AA) flags $10 bit 2 ($0004) set: solid contact this frame, i.e. the player is pushing against a solid tile
; 3. joypadCurrent bit $0800 set (D-pad up)
; 4. GetPlayerFacingDirection == 1 (north)
; 
; Chest detection: the tile in front of the player is X = round((pos X − 8) / 16), Y = (pos Y − $20) >> 4. $F8 = chest bottom-left, $F9 = chest bottom-right (then the left neighbour must be $F8 and the origin X is decremented), anything else returns.
; 
; Record search: walks the scene's scene_chest_table records comparing bytes 0/1 with the origin; no match shows dialogstring_01FF48 ("The jewel box is tightly closed.").
; 
; Matched record, by byte 2: nonzero = item chest (displayModeFlags bit 7 set, open tiles drawn, GiveItemToPlayer; success shows dialogstring_01FF2D with SFX #$2A, or spawns ChestOpeningActor when byte 3 bit 7 is set; inventory full shows GiveItemToPlayer's Y string and redraws the closed tiles with no flag); zero = flag-only chest ("It is empty!", dialogstring_01FF36). The event flag set is byte 3 AND $7F.

HandleChestInteraction {
    LDA $layerPriorityFlag ; Guard: layerPriorityFlag bit 9 ($0200) disables field interaction
    BIT #$0200
    BEQ loc_02A666
    RTS 

  loc_02A666:
    LDY $playerActor      ; Guard: player actor $10 bit 2 ($0004) = solid contact this frame (pushing into the chest)
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
    LDY $playerActor      ; Tile in front (north) of the player, from its pixel position
    LDA $0014, Y
    SEC 
    SBC #$0008
    STA $18
    AND #$0008            ; Round to nearest tile: add 16 when bit 3 of (X−8) is set, then >>4
    ASL 
    CLC 
    ADC $18
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, Y          ; Tile row = (Y − $20) >> 4, one row north of the player's collision row
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
    CMP #$F8              ; $F8 = closed chest, bottom-left: right neighbour must be $F9
    BEQ loc_02A6D8
    CMP #$F9              ; $F9 = closed chest, bottom-right: left neighbour must be $F8
    BEQ loc_02A6C8

  loc_02A6C5:
    REP #$20
    RTS 

  loc_02A6C8:
    JSL $@map_coords.MapIndexMoveLeft ; One cell left: must be $F8 for a valid chest
    LDA $mapLayerTilemap, X
    CMP #$F8
    BNE loc_02A6C5
    DEC $18               ; Adjust origin X−1 when chest detected via right-half tile
    BRA loc_02A6E4

  loc_02A6D8:
    JSL $@map_coords.MapIndexMoveRight ; One cell right: must be $F9 for a valid chest
    LDA $mapLayerTilemap, X
    CMP #$F9
    BNE loc_02A6C5

  loc_02A6E4:
    LDY $sceneTableIndex  ; Walk this scene's chest records, comparing bytes 0/1 with the bottom-left cell
    LDX $&scene_chest_table, Y

  loc_02A6EA:
    LDA $0000, X          ; Byte 0 bit 7 set = end of list → no record for this chest
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
    LDY #$&item_get_dialog_table.dialogstring_01FF48 ; No record: "The jewel box is tightly closed."
    JSL $@ShowDialogueFrame
    RTS 

  loc_02A70A:
    REP #$20
    PHX 
    LDA #$0080            ; Set displayModeFlags bit 7: display-filter mode, only actors flagged $1000 run
    TSB $displayModeFlags
    LDA #$00FC            ; $06 = $FC: open-chest base tile (bottom-left cell)
    STA $06
    JSR $&DrawChestTiles  ; DrawChestTiles — swap map tiles to open-chest graphics
    LDA $01, S
    TAX 
    LDA $0002, X          ; Entry byte 2 nonzero → item chest; zero → flag-only chest
    AND #$00FF
    BEQ loc_02A73D
    JSL $@inventory_mgmt.GiveItemToPlayer ; GiveItemToPlayer — carry set means inventory full
    BCC loc_02A753
    JSL $@ShowDialogueFrame ; Y = GiveItemToPlayer's string (dialogstring_01FF02, inventory full); then redraw the closed chest
    LDA $01, S
    TAX 
    LDA #$00F8            ; $06 = $F8: closed-chest base tile, to undo the open draw
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
    JSL $@flag_helpers.SetEventFlag_0200
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
    LDY #$&item_get_dialog_table.dialogstring_01FF2D ; Overrides GiveItemToPlayer's Y: plain text of the item name from $0DB8, no pause
    JSL $@ShowDialogueFrame
    BRA loc_02A7A1

  loc_02A778:
    PLX 
    PHY 
    PHX 
    LDX #$0000
    COP [SpawnListAppend] ( @ChestOpeningActor, #00, #00, #$2000 ) ; Spawn ChestOpeningActor (fanfare with music transition)
    LDA $0012, Y          ; Flag it $1000 so it keeps running in display-filter mode
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
    JSL $@flag_helpers.SetEventFlag_0200
    PLX 
    RTS 

  loc_02A7B0:
    LDA #$0080            ; Exit path: clear displayModeFlags bit 7 (leave display-filter mode)
    TRB $displayModeFlags
    PLX 
    RTS 
}

---------------------------------------------
; Chest fanfare actor: item chests whose record has byte 3 bit 7 set are opened by this actor while the world is frozen (displayModeFlags bit 7), see the block note for the 6-step sequence.
; 
; Spawned by HandleChestInteraction with $26 = #$17 (track number), $24 = the dialogue string pointer from GiveItemToPlayer, $20 = the item ID, and flagged $1000. It spawns two SpcTransferMusicData children with SpawnAfterFlags: the first plays the track in $26 (+1) and the second restores the scene music saved from musicParentActor ($06F2) in orbitAngle. Registers are rotated with TXA/TYX/TAY so that X addresses the child while it is configured. Both spawns check for pool exhaustion (Y = $1FC0) and jump to code_02A88B. Yields use COP SetEntryHere with polling of musicTransitionState and APUIO1; the player is locked ($1000 flag, idle animation state, playerFlags $0800, joypad masked with $CFFC) until the SPC replies $FF.
; 
; code_02A88B: cleanup, clears displayModeFlags bit 7 and dies.

ChestOpeningActor {
    LDA $musicParentActor ; Save the current music value ($06F2) in orbitAngle for the second upload
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Child 1: SpcTransferMusicData uploads the fanfare track
    CPY #$1FC0            ; Actor pool full ($1FC0) → code_02A88B cleanup (clear flag, Die)
    BNE loc_02A7CE
    JMP $&code_02A88B

  loc_02A7CE:
    TXA                   ; Swap X and Y (TXA/TYX/TAY): X = new child while it is configured
    TYX 
    TAY 
    LDA $26               ; Track number from $26 (+1) → child's chatPtr (read by SpcTransferMusicData)
    INC 
    STA $chatPtr, X
    LDA $0012, X          ; Flag the child $1000 so it keeps running in display-filter mode
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$CFFC            ; Mask $CFFC in joypadMaskStd: every button except Select/Start
    TSB $joypadMaskStd
    LDY $playerActor      ; Player: flag $1000 (keeps running) and switch to the idle animation state
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$*player_transition_handlers.PlayerIdleAnimLoop ; State pointer bank → PlayerIdleAnimLoop
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerIdleAnimLoop
    JSR $&SetAnimStatePointer
    LDA #$0800            ; playerFlags $0800: script/ability lock
    TSB $playerFlags
    COP [SetEntryHere]    ; Re-entry point: yield until musicTransitionState == $FFFF (upload finished)
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A813
    RTL 

  loc_02A813:
    COP [SpawnAfterFlags] ( @ChestDialogueActor, #$2000 ) ; Spawn ChestDialogueActor (shows the item text after its 72-frame delay)
    LDA $24               ; Pass the dialogue pointer ($24) to it
    STA $0024, Y
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $20               ; Pass the item ID ($20) to it
    STA $0020, Y
    COP [SetEntryHere]
    SEP #$20              ; Poll APUIO1 until the SPC700 replies $FF
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_02A83F
    RTL 

  loc_02A83F:
    LDY $playerActor      ; SPC replied: release the player ($1000 flag cleared)
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$*player_transition_handlers.RestorePlayerControlDirect ; State pointer bank → RestorePlayerControlDirect
    STA $0002, Y
    LDA #$&player_transition_handlers.RestorePlayerControlDirect
    JSR $&SetAnimStatePointer
    LDA #$CFFC            ; Unmask the joypad ($CFFC)
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Child 2: SpcTransferMusicData for the saved scene music
    CPY #$1FC0
    BEQ code_02A88B
    PHX                   ; Saved music value (orbitAngle) → second child's chatPtr
    LDA $orbitAngle, X
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryHere]    ; Re-entry point: wait for the second upload ($FFFF)
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A888
    RTL 

  loc_02A888:
    COP [WaitByte] ( #0B ) ; Wait 11 frames, then fall into the cleanup
}

code_02A88B {
    LDA #$0080            ; Leave display-filter mode (clear displayModeFlags bit 7) and die
    TRB $displayModeFlags
    COP [Die]
}

---------------------------------------------
; Timed chest dialogue display actor.
; 
; One-shot actor spawned by ChestOpeningActor to show the item-get dialogue after a delay:
; 1. COP [WaitByte] ($48): waits 72 frames while the fanfare plays
; 2. Clears bit $1000 from its own actor flags ($12)
; 3. Copies the item ID it was given ($20) to $0DB8, where the string reads the item name
; 4. Calls ShowDialogueFrame with the dialogue string pointer stored in $24
; 5. COP [Die]

ChestDialogueActor {
    COP [WaitByte] ( #48 ) ; COP WaitByte #$48 — 72-frame delay before showing item dialogue
    LDA #$1000            ; Clear this actor's own $1000 flag
    TRB $12
    LDA $20               ; Item ID ($20) → $0DB8, where the dialogue string reads the item name
    STA $0DB8
    LDY $24               ; Show the dialogue string pointer stored in $24
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
; Entry: X = chest record pointer (scene_chest_table), $06 = base tile ID ($FC open, $F8 closed).
; 
; Reads the record's X/Y tile (bytes 0-1; Y is the bottom row, so the top row is Y−1) and keeps the pixel position of the top-left cell (×16) in $1A/$1E for QueueVisibleTileVram, which only queues the tile if that position is on screen. The map index comes from TileCoordsToMapIndex.
; 
; Writes four tiles in order, calling QueueVisibleTileVram after each:
;   Top-left: base+2, Top-right: base+3
;   Bottom-left: base, Bottom-right: base+1
; 
; The pixel coordinates in $1A/$1E follow the cell being drawn (+16 for each step right or down); MapIndexMoveRight/MapIndexMoveDown step the map index. At the end it terminates the VRAM queue with a zero word (written at dmaSkipFlag,Y) and calls UpdateFrameRender to flush the display immediately.

DrawChestTiles {
    PHP 
    LDA $0000, X          ; Record byte 0 = tile X; ×16 = pixel X of the top-left cell ($1A)
    AND #$00FF
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0001, X
    AND #$00FF            ; Record byte 1 = bottom-row tile Y; DEC = top row, ×16 = pixel Y ($1E)
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
    LDA #$0000            ; Zero word terminates the queued VRAM writes (stored at dmaSkipFlag + Y)
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
    LDA $sceneTableIndex  ; Scene index $0646 → scene_warps table pointer for this map
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
; 3. On hit: standard warps → ExecuteWarp; extended warps → ExecuteForcedWalkWarp.
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
    JMP $&ExecuteForcedWalkWarp ; Extended warp hit — JMP ExecuteForcedWalkWarp (forced-walk pan)

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
; The caller tests (player pixel − origin) < extent with an unsigned compare, so the player's pixel position must lie in [origin, origin + 16×size − 16]: the last 15 pixels of the rectangle (and anything left of or above it) do not trigger. This adds a pixel check on top of the tile check.

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
; Entry: X = pointer to the 12-byte standard warp entry. Copies it into the transition parameters:
;   $0AF4/$0AF6: pointer to entry+4 and the scene_warps bank (GameOverSequence revive point, 100+ gems)
;   sceneNext ($0642): Destination scene ID (entry byte 4)
;   warpDestX/warpDestY ($064C/$064E): Destination X/Y words (entry bytes 5-6, 7-8)
;   warpFacing ($0650): Facing/flags (entry byte 9)
;   warpScrollParams ($0652): Scroll parameters (entry bytes 10-11)
;   sourceSceneId ($0B12): sceneCurrent
;   $0B08/$0B0C/$0B0A/$0B0E: Source warp rectangle (entry bytes 0-3)
; 
; Camera bytes: $0B10 = bits 8–11 of cameraOffsetX | (bits 8–11 of cameraOffsetY << 4); $0B11 = the same for cameraBoundsX/Y. Their consumer is not in this file.
; 
; Entry byte 9 bit 7 marks a save warp: when set it is cleared in warpFacing and the entry+4 pointer and bank are also stored in sceneSaveData ($0AF0/$0AF2), the reload point for a real game over. Both paths return carry set.

ExecuteWarp {
    PHP 
    TXA                   ; Entry pointer + 4 → $0AF4 (with the bank at $0AF6: revive point for GameOverSequence)
    CLC 
    ADC #$0004
    STA $reviveWarpPtr
    SEP #$20
    LDA #$^scene_warps    ; Load scene_warps bank byte → $0AF6
    STA $reviveWarpBank
    LDA $0004, X          ; Load destination scene, coords, direction from warp entry bytes 4–11
    STA $sceneNext
    LDY $0005, X
    STY $warpDestX
    LDY $0007, X
    STY $warpDestY
    LDA $0009, X
    STA $warpFacing
    LDY $000A, X
    STY $warpScrollParams
    LDY $sceneCurrent     ; Snapshot source scene ID and warp rectangle bounds → $0B08–$0B12
    STY $sourceSceneId
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
    LDA $warpFacing       ; Byte 9 bit 7 ($80) = save warp (also record in sceneSaveData)
    BIT #$80
    BNE loc_02AADA
    PLP 
    SEC 
    RTS 

  loc_02AADA:
    AND #$7F              ; Save warp: drop bit 7 from the facing byte, store entry+4 and the bank in sceneSaveData/$0AF2
    STA $warpFacing
    REP #$20
    TXA 
    CLC 
    ADC #$0004
    STA $sceneSaveData
    LDA #$*scene_warps
    STA $sceneSaveDataBank
    PLP 
    SEC 
    RTS 
}

---------------------------------------------
; Handle extended (forced-walk) warp — in-scene camera pan with player automation.
; 
; Entry: X = pointer to the 13-byte extended warp entry. Guard: if playerFlags bit $0100 (forced walk already active) is set it returns immediately (RTS) to prevent re-triggering.
; 
; Setup (the fields are shared with ExecuteWarp but hold different data here):
;   warpFacing ($0650): a 16-bit POINTER to entry+7, the stream of 6 walk-step bytes that the ForcedWalk actors advance one byte per step (ReadDirSprite_*Velocity); not a facing byte
;   playerSpeedEw/playerSpeedNs: zeroed (player movement stops)
;   warpScrollParams ($0652): entry bytes 4-5, packed camera window read by InitCameraBounds (0 = normal bounds)
;   scrollStepTableBase: entry byte 6 (low nibble = walk sequence index into forced_walk_sequence_table, bits 4/5/7 = direction)
; 
; Calls InitCameraBounds to configure camera limits for the destination area, then StartForcedWalk to spawn the appropriate directional walk actor. Returns carry set.

ExecuteForcedWalkWarp {
    LDA $playerFlags      ; Re-entry guard: skip if playerFlags bit 8 ($0100) already set
    BIT #$0100
    BEQ loc_02AAFB
    RTS 

  loc_02AAFB:
    TXA                   ; Pointer to entry+7 → $0650: walk-step byte stream read by the ForcedWalk actors
    CLC 
    ADC #$0007
    STA $warpFacing
    LDA #$0000            ; Zero playerSpeedEw/playerSpeedNs — halt player during forced walk
    STA $playerSpeedEw
    STA $playerSpeedNs
    SEP #$20
    LDY $0004, X          ; Entry bytes 4–5 → $0652 (packed camera window for InitCameraBounds)
    STY $warpScrollParams
    LDA $0006, X          ; Entry byte 6 → scrollStepTableBase (direction bits + walk sequence index)
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
; Sets playerFlags $0100 (forced walk active) and player actor flag $2000 (COP-script mode). Clears scrollStepIndex. Decodes the walk direction from scrollStepTableBase:
;   Bit 5 ($0020): West → ForcedWalkWest
;   Bit 4 ($0010): East → ForcedWalkEast
;   Bit 7 ($0080): North → ForcedWalkNorth
;   Default: South → ForcedWalkSouth
; 
; Keeps only the low nibble of scrollStepTableBase ($000F), the walk sequence index the ForcedWalk actors use. Each direction variant uses PHD to set the player actor as DP, spawns via COP [SpawnBefore], then restores DP.

StartForcedWalk {
    REP #$20
    LDA #$0100            ; TSB playerFlags $0100 — mark forced-walk warp in progress
    TSB $playerFlags
    LDY $playerActor      ; Set player actor $0010 bit 13 ($2000) — COP-script mode during auto-walk
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    STZ $scrollStepIndex  ; Restart the walk sequence at its first step
    LDA $scrollStepTableBase ; Keep only the low nibble (walk sequence index); direction bits are decoded below
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