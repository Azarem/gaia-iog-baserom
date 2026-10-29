; Main UI input dispatcher — menu, map, and item use button handling (229376–229567, Bank 03).
; 
; Called once per frame from the main game loop (system_core) between warp/chest checks and actor execution. Handles the three primary UI buttons: Start (map/radar), Select (inventory), and the item-use button (Y $4000 in the vanilla game; this baserom's button-remap patch tests logical bit $0008 instead, applied through transforms.json).
; 
; === GUARD CONDITIONS ===
; 
; Five checks suppress all input before button dispatch:
; 1. sceneNext nonzero — a scene transition is pending; ignore all UI input
; 2. playerFlags bit 9 ($0200) — game over sequence active
; 3. IsMusicPlaying returns carry set — a melody item is playing (SPC transfer in progress)
; 4. playerFlags bits 13|11 ($2800) — guard/channel stance ($2000) or script/ability lock ($0800); blocks Select and Y but NOT Start
; 5. No recognized button pressed — returns immediately
; 
; Note: the Start button ($1000) check comes before the $2800 guard, so the map is accessible even while blocking or during an ability.
; 
; === BUTTON DISPATCH ===
; 
; - Start ($1000) → Map/Radar screen (toggle: stays up until Start is pressed again)
; - Select ($2000) → Inventory screen (OpenInventoryScreen)
; - Item use (vanilla Y $4000, logical $0008 here) → Use equipped item (ItemUseDispatch)
; 
; === MAP/RADAR SCREEN ===
; 
; Two display modes based on playerFlags bit 3 ($0008, combat lock — set in non-combat scenes):
; 
; 1. Normal mode (bit 3 clear): Calls RadarScreenSetup for the full radar minimap with actor dots, scene markers, and enemy clear reward display.
; 
; 2. Combat-lock mode (bit 3 set): Displays a 'PAUSE' text overlay via BG3 script (consolestring_01EAC6) with dimmed brightness (INIDISP = $09). Used in non-combat scenes (towns, cutscene rooms) where the full radar overlay is not appropriate.
; 
; Both modes enter a shared display loop: each frame enables NMI, waits for VBlank, animates the radar border tiles, and polls joypadCurrent for a fresh Start press. Start was marked consumed in joypadHeld on entry, so joypadCurrent hides it until the button is released and pressed again; the overlay therefore stays up until that second press (a toggle, not hold-to-view). Then the overlay is torn down: VRAM buffer is partially cleared, brightness restored to $0F, displayModeFlags bit 0 set to flush pending VRAM, and one UpdateFrameDialogue call restores the normal display.
; 
; === INVENTORY SCREEN ===
; 
; Marks Select as consumed in joypadHeld ($2000 via TSB), syncs to VBlank, calls OpenInventoryScreen, then marks both Select ($2000) and vanilla Y ($4000) as consumed on return ($6000) to prevent an immediate re-trigger of the inventory or item use. This constant is not covered by the baserom's button-remap transforms, so the logical item-use bit $0008 is not consumed here.
---------------------------------------------

?BANK 03

?INCLUDE 'inventory_overlay'
?INCLUDE 'item_use_system'
?INCLUDE 'music_actors'
?INCLUDE 'radar_map_screen'
?INCLUDE 'system_core'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!sceneNext                      0642
!joypadCurrent                  0656
!joypadHeld                     0658
!playerFlags                    09AE
!displayModeFlags               09EC
!INIDISP                        2100

---------------------------------------------

; Per-frame overworld UI input dispatcher — routes Start, Select, and Y buttons to map, inventory, and item use.
; 
; Called from the main game loop each frame. Five guard conditions suppress input: pending scene transition (sceneNext nonzero), game over active ($0200), melody playing (IsMusicPlaying carry set), and guard/channel stance or script/ability lock ($2800) — though Start bypasses the $2800 guard.
; 
; Button priority: Start ($1000) is checked first → map/radar. Then $2800 guard. Then Select ($2000) → inventory. Then the item-use button (vanilla Y $4000, logical $0008 here) → item use.
; 
; === MAP/RADAR PATH ===
; 
; Marks Start consumed in joypadHeld. Two sub-paths based on playerFlags bit 3 ($0008, combat lock):
; 
; - Normal (clear): RadarScreenSetup renders the full minimap with actors, markers, and enemy clear status. Enters the display loop at full brightness.
; - Combat-locked (set): COP RunBg3Script displays 'PAUSE' text (consolestring_01EAC6). Clears displayModeFlags bit 15, enables NMI for one VBlank cycle, then sets INIDISP to $09 (dimmed). Enters the display loop.
; 
; Display loop: EnableNmiAndJoypad → VBlankWait → DisableNmiKeepJoypad → RadarBorderAnimate (the animation index lives in a word pushed on the stack, read by RadarBorderAnimate as $03,S) → poll joypadCurrent's high byte ($0657) for bit $10 (Start), which only reappears after Start is released and pressed again. On that press: re-consume Start in joypadHeld ($0659) so the closing press cannot reopen the map, clear overlay VRAM, restore brightness to $0F, set displayModeFlags bit 0 for VRAM flush, call UpdateFrameDialogue to restore display.
; 
; === INVENTORY PATH ===
; 
; Marks Select consumed ($2000). VBlankWait → OpenInventoryScreen → DisableNmiKeepJoypad. On return, marks Select+Y ($6000, vanilla button values) consumed to prevent re-trigger.
; 
; === ITEM USE PATH ===
; 
; Jumps directly to ItemUseDispatch. The JMP transfers control without pushing a return address — ItemUseDispatch handles its own cleanup and returns via the stacked PLP/RTL from this routine's PHP.

GlobalInputHandler {
    PHP 
    REP #$20
    LDA $sceneNext        ; Guard: pending scene transition → suppress all UI input
    AND #$00FF
    BNE loc_038039
    LDA $playerFlags      ; Guard: playerFlags bit 9 ($0200) = game over sequence active
    BIT #$0200
    BNE loc_038039
    JSL $@music_actors.IsMusicPlaying ; Guard: melody item playing (SPC transfer) → skip input
    BCS loc_038039
    LDA $joypadCurrent    ; Check Start button ($1000) first — map/radar has highest priority
    BIT #$1000
    BNE loc_038055        ; Start pressed → map/radar path (bypasses run/ability guard)
    LDA $playerFlags      ; Guard: bits 13|11 ($2800) = guard/channel stance or script/ability lock → block Select/Y
    BIT #$2800
    BNE loc_038039
    LDA $joypadCurrent    ; Check Select ($2000) → inventory screen
    BIT #$2000
    BNE loc_03803B
    BIT #$0008            ; Item-use button: logical $0008 here (vanilla Y $4000) → use equipped item
    BEQ loc_038039
    JMP $&item_use_system.ItemUseDispatch ; JMP to ItemUseDispatch — control transfers without return address push

  loc_038039:
    PLP 
    RTL 

  loc_03803B:
    LDA #$2000            ; Mark Select as consumed in joypadHeld to prevent re-trigger
    TSB $joypadHeld
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; Sync to VBlank before opening inventory overlay
    JSL $@inventory_overlay.OpenInventoryScreen ; Open the full inventory screen UI
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; Restore NMI-only mode (disable joypad auto-read during inventory teardown)
    LDA #$6000            ; $6000 = Select + vanilla Y: consume both on return so neither re-triggers at once (logical $0008 is not included)
    TSB $joypadHeld
    PLP 
    RTL 

  loc_038055:
    LDA #$1000            ; Mark Start as consumed in joypadHeld
    TSB $joypadHeld
    LDX #$0000
    LDA $playerFlags      ; Check playerFlags bit 3 ($0008) = combat lock (non-combat scene) → simplified pause display
    BIT #$0008
    BNE loc_03806D
    JSR $&radar_map_screen.RadarScreenSetup ; Normal mode: full radar minimap with actors, markers, and enemy status
    SEP #$20
    BRA loc_03808B        ; Skip to the shared display loop

  loc_03806D:
    COP [RunBg3Script] ( @system_strings.consolestring_01EAC6 ) ; Combat-lock mode: display 'PAUSE' text overlay via BG3 script
    LDA #$8000            ; Clear displayModeFlags bit 15 ($8000) before pause display setup
    TRB $displayModeFlags
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Enable NMI+joypad for one VBlank frame to sync display
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    LDA #$09              ; INIDISP $09: dim screen to 9/15 brightness for pause overlay
    STA $INIDISP

  loc_03808B:
    LDX #$0000            ; Initialize radar border animation index to 0
    PHX 

  loc_03808F:
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Display loop: enable NMI+joypad, wait for VBlank (joypad is read), back to NMI-only
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    JSR $&radar_map_screen.RadarBorderAnimate ; Animate the radar border color (BGR555 palette cycle on odd frames)
    LDA $joypadCurrent+1  ; joypadCurrent high byte: consumed Start is hidden, so bit $10 appears only on a fresh press
    BIT #$10              ; Bit $10 in high byte = Start ($1000); zero = still held → loop
    BEQ loc_03808F
    PLX 
    LDA #$10              ; Consume Start again (joypadHeld high byte, $0659) so this closing press cannot reopen the map
    TSB $joypadHeld+1
    JSL $@vram_buffer_clear.ClearBg3TilemapBuffer_PreserveHud ; Clear the BG3 staging buffer below the HUD rows to remove the radar/pause graphics
    LDA #$0F              ; Restore full brightness INIDISP = $0F
    STA $INIDISP
    LDA #$01              ; Set displayModeFlags bit 0 ($01) = BG3 staging buffer has pending data for next VBlank
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue ; One UpdateFrameDialogue call to flush VRAM and restore normal display
    PLP 
    RTL 
}