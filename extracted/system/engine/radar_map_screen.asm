; Radar map screen overlay — world map minimap display (229567–230416, Bank 03).
; 
; Renders the in-game radar/map overlay accessible from within combat areas. Displays a tile-based minimap of the current area centered on the player position, with scene transition markers, friendly actors (blue dots), and enemy actors (red dots) plotted as icons.
; 
; === RENDERING PIPELINE (RadarScreenSetup) ===
; 
; 1. DMA radar icon graphics (512 bytes from radar_icons_001C00) to VRAM $7700
; 2. Block-copy radar tilemap layout (radar_layout_001E00, $0580 bytes) to VRAM staging buffer at $7F0380
; 3. Compute 68×68-tile viewport centered on player position (aligned to 4-tile boundary)
; 4. Plot scene transition markers from table_01ADA8 within viewport (tile $2EE6)
; 5. Convert viewport from tile to pixel coordinates (×16) for actor plotting
; 6. Iterate actor linked list — friendly actors (extendedFlags bit 8) as blue dots ($2AE7), enemies (bit 9) as red dots ($280D)
; 7. Display BCD marker count and actor count as digit tiles (base $34F0)
; 8. Check enemy clear reward eligibility (flag $0300 + enemy_clear_reward_table) and draw chest icon if applicable
; 9. Run BG3 script for radar text overlay
; 
; === RADAR RESOLUTION ===
; 
; Each radar cell represents a 4×4 map tile (64×64 pixel) area. The 68-tile viewport covers ~17 radar cells in each axis. Scene markers use tile coordinates directly from table_01ADA8; actor positions are in pixels and undergo >>5 (X) / AND $FFC0 (Y) conversion to VRAM offsets. Both methods produce consistent 4-tile-per-cell resolution.
; 
; === VRAM BUFFER LAYOUT ===
; 
; The radar occupies a region of the BG tilemap staging buffer at $7F0200. Offset $0216 marks the start of the radar interior. Each tilemap row is 64 bytes (32 words). Marker icons, actor dots, digit tiles, and the chest icon are written directly to calculated positions within this buffer.
; 
; === BORDER ANIMATION ===
; 
; RadarBorderAnimate provides a cycling visual effect around the radar frame, driven by a 29-entry tile table (RadarBorderTileTable) updated every other frame at VRAM position $7F0A24.
---------------------------------------------

?BANK 03

?INCLUDE 'cop_handlers_script'
?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'system_strings'
?INCLUDE 'table_01ADA8'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!sceneCurrent                   0644
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!playerXTile                    09A6
!playerYTile                    09A8
!displayModeFlags               09EC
!extendedFlags                  7F002A
!adhocVramDma                   7F0C03

---------------------------------------------

; Main entry point for radar screen rendering.
; 
; Waits for any pending ad-hoc VRAM DMA to complete, then queues radar icon graphics (radar_icons_001C00, 512 bytes) for DMA to VRAM $7700. After the transfer completes, clears the VRAM staging buffer and block-copies the base radar tilemap layout (radar_layout_001E00, $0580 bytes) into WRAM at $7F0380.
; 
; Computes a 68×68-tile viewport centered on the player's tile position (aligned to 4-tile boundary via AND $00FC): left = playerX − 32, right = left + 68, top = playerY − 32, bottom = top + 68. Calls RadarPlotSceneMarkers to place transition point icons, then displays the BCD scene marker count as digit tiles at $7F07C8–$7F07CE (base tile $34F0).
; 
; Converts viewport bounds from tile to pixel coordinates (×16) for actor plotting, then calls RadarPlotActors. Displays the actor count from $0AEE at $7F0608–$7F060E.
; 
; Checks enemy clear reward eligibility: tests flag $0300 for the current scene via TestFlag_0300, then looks up enemy_clear_reward_table. If a reward exists, draws a 4×4 chest icon (flipped variants of tiles $2E1–$2E3) and reward counter tiles ($32E8–$32EB) into the VRAM buffer, then runs a BG3 script (system_strings.consolestring_01EAD1) for the radar text overlay.
; 
; Sets displayModeFlags bit 0 to enable the radar display.

RadarScreenSetup {
    LDA $7F0C07           ; Check if previous ad-hoc VRAM DMA is still pending
    BEQ loc_0380D7
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    REP #$20
    BRA RadarScreenSetup

  loc_0380D7:
    LDA #$&radar_icons_001C00 ; Queue radar icon source address for DMA transfer
    STA $adhocVramDma
    LDA #$*radar_icons_001C00
    STA $7F0C05
    LDA #$7700            ; VRAM destination $7700 for radar icon tile data
    STA $7F0C07
    LDA #$0200            ; Transfer 512 bytes of radar icon graphics
    STA $7F0C09

  loc_0380F3:
    LDA $7F0C07
    BEQ loc_03810B
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    REP #$20
    BRA loc_0380F3

  loc_03810B:
    JSL $@vram_buffer_clear.ClearVramBufferPartial ; Clear VRAM staging buffer before drawing radar content
    PHB 
    LDX #$&radar_layout_001E00
    LDY #$0380
    LDA #$057F            ; Block-copy $0580 bytes of radar tilemap layout to $7F0380
    MVN #$7F, #$^radar_layout_001E00
    PLB 
    LDA $playerXTile
    AND #$00FC            ; Align player X to 4-tile boundary for viewport calculation
    SEC 
    SBC #$0020            ; Viewport left edge = playerX − 32 tiles
    STA $0018
    CLC 
    ADC #$0044            ; Viewport right edge = left + 68 tiles
    STA $001A
    LDA $playerYTile
    AND #$00FC
    SEC 
    SBC #$0020
    STA $001C
    CLC 
    ADC #$0044
    STA $001E
    JSR $&RadarPlotSceneMarkers
    LDA $0002
    AND #$00F0            ; Extract BCD tens digit from scene marker count
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03815B
    ORA #$34F0            ; Combine digit with tile base $34F0 for numeric display
    STA $7F07CC

  loc_03815B:
    LDA $0002
    AND #$000F
    ORA #$34F0
    STA $7F07CE
    LDA #$2EE6            ; Scene marker legend icon tile $2EE6
    STA $7F07C8
    LDA $0018             ; Convert viewport from tile to pixel coordinates (×16 via ASL ×4)
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0018
    LDA $001C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001C
    LDA $001A
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001A
    LDA $001E
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001E
    JSR $&RadarPlotActors
    LDA $0AEE
    AND #$00F0
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_0381AD
    ORA #$34F0
    STA $7F060C

  loc_0381AD:
    LDA $0AEE
    AND #$000F
    ORA #$34F0
    STA $7F060E
    LDA #$2AE7            ; Friendly actor legend icon tile $2AE7
    STA $7F0608
    LDA $sceneCurrent
    JSL $@cop_handlers_script.TestFlag_0300 ; Test flag $0300 — have this scene's enemies been cleared?
    BCS loc_038248
    LDX $sceneCurrent
    LDA $@enemy_clear_reward_table, X ; Look up enemy_clear_reward_table — 0 = no reward available
    AND #$00FF
    BEQ loc_038248
    LDA #$2EE1            ; Draw 4×4 chest icon (flipped tile variants $2E1–$2E3)
    STA $7F0406
    LDA #$6EE1
    STA $7F040C
    LDA #$AEE1
    STA $7F04C6
    LDA #$EEE1
    STA $7F04CC
    LDA #$2EE2
    STA $7F0408
    LDA #$6EE2
    STA $7F040A
    LDA #$AEE2
    STA $7F04C8
    LDA #$EEE2
    STA $7F04CA
    LDA #$2EE3
    STA $7F0446
    LDA #$AEE3
    STA $7F0486
    LDA #$6EE3
    STA $7F044C
    LDA #$EEE3
    STA $7F048C
    LDA #$32E8            ; Reward counter digit tiles ($32E8 sequential via INC)
    STA $7F0448
    INC 
    STA $7F044A
    INC 
    STA $7F0488
    INC 
    STA $7F048A
    LDX #$0000
    COP [RunBg3Script] ( @system_strings.consolestring_01EAD1 ) ; Display radar label text via BG3 script

  loc_038248:
    LDA #$32E5            ; Radar display legend tile at $7F0626
    STA $7F0626
    LDA #$0001
    TSB $displayModeFlags ; Enable radar overlay (set bit 0 of displayModeFlags)
    LDX #$0000
    RTS 
}

---------------------------------------------
; Animate the radar screen border on alternate frames.
; 
; Checks bit 0 of the frame counter at $0036; returns immediately on even frames. On odd frames, switches to 16-bit mode and increments a cycling animation index stored on the caller's stack ($03,S), wrapping at 29 ($001D). The index is doubled (ASL) and used to look up a tile word from RadarBorderTileTable, which is written to VRAM buffer position $7F0A24.
; 
; Produces a shimmering/pulsing animation effect on the radar border that cycles through 29 distinct tile patterns at half the frame rate.

RadarBorderAnimate {
    LDA $0036             ; Animate on odd frames only (frame parity check on $0036)
    LSR 
    BCS loc_038260
    RTS 

  loc_038260:
    REP #$20
    LDA $03, S
    INC 
    CMP #$001D
    BCC loc_03826D
    LDA #$0000

  loc_03826D:
    STA $03, S
    ASL 
    TAX 
    LDA $@RadarBorderTileTable, X
    STA $7F0A24
    SEP #$20
    RTS 
}

---------------------------------------------
; Plot scene transition markers on the radar and count them in BCD.
; 
; Iterates the scene marker table (table_01ADA8) starting from the current scene's offset stored at $0646. Each 4-byte table entry contains: byte 0 = X tile coordinate, byte 1 = Y tile coordinate, byte 3 = event flag ID (bit 7 = end-of-table sentinel).
; 
; For each entry: tests the event flag via TestEventFlag_0200 — set means already visited, skip. Checks if the marker's tile coordinates fall within the radar viewport ($0018–$001A for X, $001C–$001E for Y).
; 
; Visible markers are converted to VRAM buffer offsets: column = (markerX − left) >> 1 & $FE, row = ((markerY − top) >> 1 & $FE) << 5. The offset + $0216 (radar interior base) indexes into $7F0200 where tile $2EE6 (marker icon) is written.
; 
; Maintains a BCD counter in $0002 using decimal mode (SED/CLD), incrementing by 1 for each unvisited marker. The count is used by RadarScreenSetup for the digit display.

RadarPlotSceneMarkers {
    PHX 
    STZ $0002             ; Initialize BCD marker counter to zero
    LDX $0646             ; Load current scene's marker table pointer from $0646
    LDA $@table_01ADA8, X
    SEC 
    SBC #$&table_01ADA8   ; Convert scene table pointer to byte index into table_01ADA8
    TAX 
    SEP #$20              ; 8-bit mode for byte-level table entry access

  loc_03828E:
    LDA $@table_01ADA8, X
    BMI loc_03830A        ; Bit 7 set = end-of-table sentinel
    LDA $@table_01ADA8+3, X
    REP #$20
    AND #$007F            ; Mask to 7-bit event flag ID
    JSL $@cop_handlers_script.TestEventFlag_0200
    SEP #$20
    BCS loc_038304        ; Event flag set = visited marker, skip plotting
    LDA $@table_01ADA8, X
    CMP $0018
    BMI loc_0382F9
    CMP $001A
    BCS loc_0382F9
    LDA $@table_01ADA8+1, X
    CMP $001C
    BMI loc_0382F9
    CMP $001E
    BCS loc_0382F9
    LDA $@table_01ADA8, X
    SEC 
    SBC $0018
    LSR 
    AND #$FE              ; Word-align X offset for 2-byte VRAM tilemap entries
    STA $0000
    STZ $0001
    LDA $@table_01ADA8+1, X
    SEC 
    SBC $001C
    REP #$20
    LSR 
    AND #$00FE
    ASL                   ; <<5: multiply Y offset by VRAM row stride (32 words/row)
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0000
    CLC 
    ADC #$0216            ; Add $0216 = byte offset to radar interior in VRAM buffer
    PHX 
    TAX 
    LDA #$2EE6            ; Tile $2EE6 = scene transition marker icon
    STA $7F0200, X
    PLX 
    SEP #$20

  loc_0382F9:
    SED                   ; Enter decimal mode for BCD counter increment
    LDA $0002
    CLC 
    ADC #$01
    STA $0002
    CLD 

  loc_038304:
    INX 
    INX 
    INX 
    INX 
    BRA loc_03828E

  loc_03830A:
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Iterate the active actor linked list and dispatch to type-specific plotters.
; 
; Walks the actor list starting from head pointer $56, following next-pointers at $0006,X. For each actor, checks extendedFlags ($7F002A,X): bit 8 ($0100) routes to RadarPlotFriendlyActor, bit 9 ($0200) routes to RadarPlotEnemyActor. Actors with neither bit set are skipped (not plotted on the radar).

RadarPlotActors {
    LDA $56
    BEQ loc_03832E

  loc_038312:
    TAX 
    LDA $extendedFlags, X ; Load actor extendedFlags for type classification
    BIT #$0100            ; Bit 8 ($0100) = friendly/NPC actor → plot blue dot
    BEQ loc_038321
    JSR $&RadarPlotFriendlyActor
    BRA loc_038329

  loc_038321:
    BIT #$0200            ; Bit 9 ($0200) = enemy actor → plot red dot
    BEQ loc_038329
    JSR $&RadarPlotEnemyActor

  loc_038329:
    LDA $0006, X          ; Follow linked list next-pointer ($0006,X)
    BNE loc_038312

  loc_03832E:
    RTS 
}

---------------------------------------------
; Plot a single friendly actor as a blue dot on the radar.
; 
; Checks if the actor's pixel position ($0014,X / $0016,X) falls within the radar viewport bounds ($0018/$001A for X, $001C/$001E for Y). Out-of-bounds actors are skipped.
; 
; For in-bounds actors, converts the pixel position to a VRAM buffer offset: column = (actorX − left) >> 5 & $FFFE, row = (actorY − top) & $FFC0, then adds $0216 (radar interior base). Writes tile $2AE7 (palette 2 blue dot) to the VRAM buffer at $7F0200 + offset.
; 
; Always returns with carry set (SEC before RTS).

RadarPlotFriendlyActor {
    LDA $0014, X
    CMP $0018
    BMI loc_038377
    CMP $001A
    BCS loc_038377
    LDA $0016, X
    CMP $001C
    BMI loc_038377
    CMP $001E
    BCS loc_038377
    PHX 
    LDA $0014, X
    SEC 
    SBC $0018
    LSR                   ; >>5 and word-align: convert pixel X offset to VRAM column
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$FFFE
    STA $0000
    LDA $0016, X
    SEC 
    SBC $001C
    AND #$FFC0            ; AND $FFC0: extract VRAM row offset (64 bytes per tilemap row)
    CLC 
    ADC $0000
    CLC 
    ADC #$0216            ; Add $0216 = radar interior base offset in VRAM buffer
    TAX 
    LDA #$2AE7            ; Tile $2AE7 = friendly actor dot (palette 2, blue)
    STA $7F0200, X
    PLX 

  loc_038377:
    SEC 
    RTS 
}

---------------------------------------------
; Plot a single enemy actor as a red dot on the radar.
; 
; Performs a two-stage bounds check: first verifies the actor is within camera view bounds (cameraOffsetX/Y to cameraBoundsX/Y), then checks the radar viewport bounds ($0018–$001E). Only enemies visible on both the game camera and the radar map are plotted — off-screen enemies are hidden.
; 
; Uses the same pixel-to-VRAM-offset conversion as RadarPlotFriendlyActor. Writes tile $280D (palette 0 red dot) to the VRAM buffer.

RadarPlotEnemyActor {
    LDA $0014, X
    CMP $cameraOffsetX    ; Camera X bounds check — only show on-screen enemies on radar
    BCC loc_0383D5
    CMP $cameraBoundsX
    BCS loc_0383D5
    CMP $0018
    BMI loc_0383D5
    CMP $001A
    BCS loc_0383D5
    LDA $0016, X
    CMP $cameraOffsetY    ; Camera Y bounds check
    BCC loc_0383D5
    CMP $cameraBoundsY
    BCS loc_0383D5
    CMP $001C
    BMI loc_0383D5
    CMP $001E
    BCS loc_0383D5
    PHX 
    LDA $0014, X
    SEC 
    SBC $0018
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$FFFE
    STA $0000
    LDA $0016, X
    SEC 
    SBC $001C
    AND #$FFC0
    CLC 
    ADC $0000
    CLC 
    ADC #$0216
    TAX 
    LDA #$280D            ; Tile $280D = enemy actor dot (palette 0, red)
    STA $7F0200, X
    PLX 

  loc_0383D5:
    RTS 
}

---------------------------------------------
; 29-entry word table of VRAM tile values for the radar border animation cycle.
; 
; Each entry is a complete SNES tilemap word (flip + priority + palette + tile index). RadarBorderAnimate steps through one entry per odd frame, writing it to the border tile position. The sequence produces a cycling shimmer/pulse visual effect around the radar display frame.

RadarBorderTileTable [
  #$5C82   ;00
  #$5CC4   ;01
  #$5906   ;02
  #$5928   ;03
  #$596A   ;04
  #$55AC   ;05
  #$55EE   ;06
  #$5610   ;07
  #$5252   ;08
  #$5294   ;09
  #$52D6   ;0A
  #$4EF8   ;0B
  #$4F3A   ;0C
  #$4F7C   ;0D
  #$4BBF   ;0E
  #$4BBF   ;0F
  #$4B9D   ;10
  #$4B5B   ;11
  #$4F19   ;12
  #$4EF7   ;13
  #$4EB5   ;14
  #$5273   ;15
  #$5231   ;16
  #$520F   ;17
  #$55CD   ;18
  #$558B   ;19
  #$5549   ;1A
  #$5927   ;1B
  #$58E5   ;1C
]