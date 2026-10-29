; Radar map screen overlay — the Start-button map of the current area (229567–230416, Bank 03).
; 
; Draws a 17×17-cell view centered on the player. One cell = 4×4 map tiles (64×64 px) = one BG3 tilemap word. Contents: an icon for every unopened treasure chest, a dot for every actor flagged extendedFlags bit 8 (the stat-bearing enemies counted in enemiesRemainingBcd), a second dot type for actors flagged bit 9 (only dark_space.asm sets that bit, so these are probably Dark Space entrances), and a legend with the unopened-chest count and the remaining-enemy count. When the scene still offers an unclaimed clear reward (enemy_clear_reward_table, flag $0300 + scene), a framed 2×2 reward icon and a BG3 label are added. GlobalInputHandler calls RadarScreenSetup once when Start opens the map and RadarBorderAnimate every frame of its display loop.
; 
; === RENDERING PIPELINE (RadarScreenSetup) ===
; 
; 1. Wait until no adhoc VRAM DMA is pending, then queue 512 bytes of radar icon graphics (radar_icons_001C00) for VRAM $7700 and wait for that transfer to finish.
; 2. Clear the BG3 staging buffer and block-copy the radar layout (radar_layout_001E00, $0580 bytes) to $7F0380.
; 3. Compute the 68×68-tile viewport (player tile aligned down to a multiple of 4, minus 32 on each axis). Left/right/top/bottom are kept in WRAM scratch $0018/$001A/$001C/$001E.
; 4. RadarPlotSceneMarkers draws the unopened chests inside the viewport and returns the count of all unopened chests of the scene (BCD, in scratch $0002); the count is shown as digits at $7F07CC/$7F07CE next to the chest icon $2EE6.
; 5. The viewport bounds are converted from tiles to pixels (×16) and RadarPlotActors plots the dots.
; 6. The remaining-enemy count (enemiesRemainingBcd, BCD) is shown as digits at $7F060C/$7F060E next to the dot icon $2AE7.
; 7. If flag $0300 + sceneCurrent is clear and enemy_clear_reward_table[scene] is non-zero, the reward frame is drawn and the BG3 script system_strings.consolestring_01EAD1 runs for the text.
; 8. Sets displayModeFlags bit 0, which requests a full BG3 staging upload.
; 
; === RADAR RESOLUTION ===
; 
; Map tiles are 16 px, so a 4-tile cell is 64 px. Chest records hold tile coordinates: cell column byte offset = ((tileX − left) >> 1) AND $FE, row = (((tileY − top) >> 1) AND $FE) << 5 (64 bytes per tilemap row). Actors hold pixel coordinates: column = ((x − left) >> 5) AND $FFFE, row = (y − top) AND $FFC0. Both give the same cell grid; $0216 is added as the byte offset of the radar interior inside the $7F0200 buffer.
; 
; === BORDER ANIMATION ===
; 
; RadarBorderAnimate runs on odd frames only. It steps an index (kept in a word on the caller's stack, $03,S) through the 29-entry RadarBorderColorTable and writes the entry to $7F0A24, which is cgramPalette color 18. The table values are BGR555 colors (a blue → yellow → blue cycle), so the border shimmers by palette cycling, not by changing tiles.
---------------------------------------------

?BANK 03

?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'flag_helpers'
?INCLUDE 'scene_chest_table'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!frameCounter                   0036
!sceneCurrent                   0644
!sceneTableIndex                0646
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!playerXTile                    09A6
!playerYTile                    09A8
!displayModeFlags               09EC
!enemiesRemainingBcd            0AEE
!extendedFlags                  7F002A
!bg3TilemapBuffer               7F0200
!adhocVramDma                   7F0C03
!adhocVramDmaBank               7F0C05
!adhocVramDmaDest               7F0C07
!adhocVramDmaSize               7F0C09

---------------------------------------------

; Build the radar screen (JSR from GlobalInputHandler when Start opens the map).
; 
; Waits for any pending adhoc VRAM DMA, queues the icon graphics DMA (512 bytes to VRAM $7700) and waits for it, clears the staging buffer, block-copies the radar layout, computes the viewport and then plots chests, actors, legend counts and the optional clear-reward frame. See the file header for the full pipeline and cell geometry.
; 
; Reward block: when flag $0300 + sceneCurrent is clear and enemy_clear_reward_table[scene] is non-zero it draws a 4×4-cell frame (corner tile $2EE1 with H/V flips, edges $2EE2/$2EE3 with flips) around a 2×2 icon of sequential tiles $32E8–$32EB and runs the BG3 label script. The table value (1=HP, 2=STR, 3=DEF per boss_clear_reward_handler) is only tested for non-zero here; what the icon shows is unverified.

RadarScreenSetup {
    LDA $adhocVramDmaDest ; Check if previous ad-hoc VRAM DMA is still pending
    BEQ loc_0380D7
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    REP #$20
    BRA RadarScreenSetup

  loc_0380D7:
    LDA #$&radar_icons_001C00 ; Queue radar icon source address for DMA transfer
    STA $adhocVramDma
    LDA #$*radar_icons_001C00
    STA $adhocVramDmaBank
    LDA #$7700            ; VRAM destination $7700 for radar icon tile data
    STA $adhocVramDmaDest ; Writing the destination arms the adhoc DMA; the size is stored after it (writers should store the size first)
    LDA #$0200            ; Transfer 512 bytes of radar icon graphics
    STA $adhocVramDmaSize

  loc_0380F3:
    LDA $adhocVramDmaDest
    BEQ loc_03810B
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    REP #$20
    BRA loc_0380F3

  loc_03810B:
    JSL $@vram_buffer_clear.ClearBg3TilemapBuffer_PreserveHud ; Clear the BG3 staging buffer below the HUD rows before drawing radar content
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
    AND #$00F0            ; Tens digit of the unopened-chest count (BCD from RadarPlotSceneMarkers); a zero tens digit is not drawn
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
    LDA #$2EE6            ; Chest legend icon $2EE6 (same tile as the chest markers) beside the unopened-chest count
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
    LDA $enemiesRemainingBcd ; Remaining-enemy count (BCD): tens digit first
    AND #$00F0
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_0381AD
    ORA #$34F0
    STA $7F060C

  loc_0381AD:
    LDA $enemiesRemainingBcd
    AND #$000F
    ORA #$34F0
    STA $7F060E
    LDA #$2AE7            ; Legend icon $2AE7 (same tile as the bit-8 actor dots) beside the remaining-enemy count
    STA $7F0608
    LDA $sceneCurrent
    JSL $@flag_helpers.TestFlag_0300 ; Flag $0300 + scene set = this scene's clear reward already claimed → skip the reward frame
    BCS loc_038248
    LDX $sceneCurrent
    LDA $@enemy_clear_reward_table, X ; enemy_clear_reward_table[scene]: 0 = no reward (1=HP, 2=STR, 3=DEF per boss_clear_reward_handler)
    AND #$00FF
    BEQ loc_038248
    LDA #$2EE1            ; Reward frame corner $2EE1; the four corners are its H/V-flip variants ($2EE1/$6EE1/$AEE1/$EEE1)
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
    LDA #$32E8            ; 2×2 reward icon in the frame interior: tiles $32E8-$32EB (INC between stores); meaning unverified
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
    LDA #$32E5            ; Tile $32E5 at $7F0626 (purpose unverified)
    STA $7F0626
    LDA #$0001
    TSB $displayModeFlags ; Request a full BG3 staging upload (displayModeFlags bit 0)
    LDX #$0000
    RTS 
}

---------------------------------------------
; Animate the radar border color on odd frames (JSR from GlobalInputHandler's display loop).
; 
; Returns at once when bit 0 of frameCounter ($0036) is clear. Otherwise it increments the animation index stored in the caller's stack word ($03,S), wraps it at 29, and writes RadarBorderColorTable[index] to $7F0A24 (cgramPalette color 18). The values are BGR555 colors, not tilemap words, so the border pulses through a blue → yellow → blue palette cycle.

RadarBorderAnimate {
    LDA $frameCounter     ; Animate on odd frames only (frame parity check on $0036)
    LSR 
    BCS loc_038260
    RTS 

  loc_038260:
    REP #$20
    LDA $03, S
    INC 
    CMP #$001D            ; Wrap animation index at 29 (table length)
    BCC loc_03826D
    LDA #$0000

  loc_03826D:
    STA $03, S
    ASL 
    TAX 
    LDA $@RadarBorderColorTable, X ; BGR555 border color for this animation step
    STA $7F0A24           ; Write the color to cgramPalette+$24 = palette color 18 (the radar border color)
    SEP #$20
    RTS 
}

---------------------------------------------
; Plot the unopened treasure chests of the current scene and count them in BCD (scratch $0002).
; 
; sceneTableIndex ($0646) is a byte index into the pointer list at the head of scene_chest_table; the word found there is the address of this scene's record list. Each 4-byte record: byte 0 = X tile (bit 7 set = end of list), byte 1 = Y tile of the chest's bottom row, byte 2 = contents (0 = flag only), byte 3 = event flag (AND $7F; bit 7 = fanfare). A set event flag (TestEventFlag_0200) means the chest is already opened, so it is skipped and not counted.
; 
; Every unopened chest is counted, whether or not it lies inside the viewport. Those inside get the tile $2EE6 written at the cell offset (+$0216 radar interior base into $7F0200).

RadarPlotSceneMarkers {
    PHX 
    STZ $0002             ; Initialize BCD marker counter to zero
    LDX $sceneTableIndex  ; sceneTableIndex = byte index into the per-scene pointer list at the head of scene_chest_table
    LDA $@scene_chest_table, X
    SEC 
    SBC #$&scene_chest_table ; Pointer − table base = byte offset of this scene's first 4-byte chest record
    TAX 
    SEP #$20              ; 8-bit mode for byte-level table entry access

  loc_03828E:
    LDA $@scene_chest_table, X
    BMI loc_03830A        ; Byte 0 bit 7 = end of this scene's chest list
    LDA $@scene_chest_table+3, X ; Byte 3 = event flag (bit 7 = fanfare, masked off below); flag set = chest opened
    REP #$20
    AND #$007F            ; Mask to 7-bit event flag ID
    JSL $@flag_helpers.TestEventFlag_0200
    SEP #$20
    BCS loc_038304        ; Flag set = chest already opened: skip it (not drawn, not counted)
    LDA $@scene_chest_table, X
    CMP $0018
    BMI loc_0382F9        ; X tile left of the viewport → not drawn, but still counted at loc_0382F9
    CMP $001A
    BCS loc_0382F9
    LDA $@scene_chest_table+1, X
    CMP $001C
    BMI loc_0382F9
    CMP $001E
    BCS loc_0382F9
    LDA $@scene_chest_table, X
    SEC 
    SBC $0018
    LSR 
    AND #$FE              ; Word-align X offset for 2-byte VRAM tilemap entries
    STA $0000
    STZ $0001
    LDA $@scene_chest_table+1, X
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
    LDA #$2EE6            ; Tile word $2EE6 = unopened-chest marker
    STA $bg3TilemapBuffer, X
    PLX 
    SEP #$20

  loc_0382F9:
    SED                   ; SED: count this chest in BCD (every unopened chest, drawn or not)
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
; Walk the actor list (head $56, next at $0006,X) and plot dots by extendedFlags.
; 
; Bit 8 ($0100) routes to RadarPlotFriendlyActor, which plots the stat-bearing enemies, and bit 9 ($0200) to RadarPlotEnemyActor, which plots the Dark Space portals. Bit 8 is set by InitActorFromSceneData (actor_execution) for actors spawned with combat stats and an enemy number (they are counted in enemiesRemaining), so that dot marks the stat-bearing enemies still in the actor list. Bit 9 is set only by dark_space.asm (COP OrExtraFlags #$0200 in DarkSpacePortalInit), so that dot marks a Dark Space portal. Bit 8 is tested first, so an actor with both bits gets the enemy dot. Actors with neither bit are not plotted.

RadarPlotActors {
    LDA $56
    BEQ loc_03832E

  loc_038312:
    TAX 
    LDA $extendedFlags, X ; Load actor extendedFlags for type classification
    BIT #$0100            ; Bit 8 = stat-bearing enemy (set by actor_execution, counted in enemiesRemaining) → dot $2AE7
    BEQ loc_038321
    JSR $&RadarPlotFriendlyActor
    BRA loc_038329

  loc_038321:
    BIT #$0200            ; Bit 9 = set only by dark_space.asm (OrExtraFlags #$0200) → dot $280D, a Dark Space portal
    BEQ loc_038329
    JSR $&RadarPlotEnemyActor

  loc_038329:
    LDA $0006, X          ; Follow linked list next-pointer ($0006,X)
    BNE loc_038312

  loc_03832E:
    RTS 
}

---------------------------------------------
; Plot one bit-8 actor (a stat-bearing enemy) as the enemy dot, tile word $2AE7.
; 
; Skips actors whose pixel position ($0014,X/$0016,X) is outside the viewport ($0018/$001A × $001C/$001E). Cell offset: column = ((x − left) >> 5) AND $FFFE, row = (y − top) AND $FFC0, plus $0216, written into $7F0200. $2AE7 is tile $2E7 with palette 2 and is also the legend icon beside the remaining-enemy count. Always returns with carry set.

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
    LDA #$2AE7            ; Tile word $2AE7 = enemy dot (tile $2E7, palette 2; same icon as the legend)
    STA $bg3TilemapBuffer, X
    PLX 

  loc_038377:
    SEC 
    RTS 
}

---------------------------------------------
; Plot one bit-9 actor (a Dark Space portal) as dot tile word $280D.
; 
; Same cell math as RadarPlotFriendlyActor, after one extra test against cameraOffsetX/Y..cameraBoundsX/Y. Those four words are the scene's scroll limits, not the current view, so the extra test only rejects positions outside the scene. $280D is tile $00D with palette 2 (not palette 0).

RadarPlotEnemyActor {
    LDA $0014, X
    CMP $cameraOffsetX    ; cameraOffsetX..cameraBoundsX are the scene scroll limits, not the current view
    BCC loc_0383D5
    CMP $cameraBoundsX
    BCS loc_0383D5
    CMP $0018
    BMI loc_0383D5
    CMP $001A
    BCS loc_0383D5
    LDA $0016, X
    CMP $cameraOffsetY    ; cameraOffsetY..cameraBoundsY: scene scroll limits (Y)
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
    LDA #$280D            ; Tile word $280D = second dot type (tile $00D, palette 2)
    STA $bg3TilemapBuffer, X
    PLX 

  loc_0383D5:
    RTS 
}

---------------------------------------------
; 29 BGR555 colors for the radar border animation.
; 
; RadarBorderAnimate writes one entry per odd frame to cgramPalette color 18 ($7F0A24). Decoded values run from blue ($5C82: R2 G4 B23) through yellow ($4BBF: R31 G29 B18) and back to blue ($58E5).

RadarBorderColorTable [
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