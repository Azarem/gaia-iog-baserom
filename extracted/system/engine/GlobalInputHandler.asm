; Main UI input dispatcher — menu, map, and item use button handling (229376–229567, Bank 03).
; 
; Called once per frame from the main game loop (system_core) between warp/chest checks and actor execution. Handles the three primary UI buttons: Start (map/radar), Select (inventory), and Y (use equipped item).
; 
; === GUARD CONDITIONS ===
; 
; Five checks suppress all input before button dispatch:
; 1. sceneNext nonzero — a scene transition is pending; ignore all UI input
; 2. playerFlags bit 9 ($0200) — game over sequence active
; 3. IsMusicPlaying returns carry set — a melody item is playing (SPC transfer in progress)
; 4. playerFlags bits 13|11 ($2800) — running ($2000) or ability active ($0800); blocks Select and Y but NOT Start (map can still be opened during run)
; 5. No recognized button pressed — returns immediately
; 
; Note: the Start button ($1000) check comes before the $2800 guard, so the map is accessible even while running or during an ability.
; 
; === BUTTON DISPATCH ===
; 
; - Start ($1000) → Map/Radar screen (hold-to-view with border animation)
; - Select ($2000) → Inventory screen (OpenInventoryScreen)
; - Y ($4000) → Use equipped item (ItemUseDispatch)
; 
; === MAP/RADAR SCREEN ===
; 
; Two display modes based on playerFlags bit 3 ($0008, input lock):
; 
; 1. Normal mode (bit 3 clear): Calls RadarScreenSetup for the full radar minimap with actor dots, scene markers, and enemy clear reward display.
; 
; 2. Input-locked mode (bit 3 set): Displays a 'PAUSE' text overlay via BG3 script (consolestring_01EAC6) with dimmed brightness (INIDISP = $09). Used when the player is in a restricted state (cutscene guidance, NPC walk, etc.) where the full radar overlay is not appropriate.
; 
; Both modes enter a shared hold-to-view loop: each frame enables NMI, waits for VBlank, animates the radar border tiles, and polls the Start button. When Start is released, the overlay is torn down: VRAM buffer is partially cleared, brightness restored to $0F, displayModeFlags bit 0 set to flush pending VRAM, and one UpdateFrameDialogue call restores the normal display.
; 
; === INVENTORY SCREEN ===
; 
; Marks Select as consumed in joypadHeld ($2000 via TSB), syncs to VBlank, calls OpenInventoryScreen, then marks both Select and L ($6000) as consumed on return to prevent immediate re-trigger.
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
; Called from the main game loop each frame. Five guard conditions suppress input: pending scene transition (sceneNext nonzero), game over active ($0200), melody playing (IsMusicPlaying carry set), and running/ability state ($2800) — though Start bypasses the $2800 guard.
; 
; Button priority: Start ($1000) is checked first → map/radar. Then $2800 guard. Then Select ($2000) → inventory. Then Y ($4000) → item use.
; 
; === MAP/RADAR PATH ===
; 
; Marks Start consumed in joypadHeld. Two sub-paths based on playerFlags bit 3 ($0008, input lock):
; 
; - Normal (clear): RadarScreenSetup renders the full minimap with actors, markers, and enemy clear status. Enters the hold loop at full brightness.
; - Input-locked (set): COP RunBg3Script displays 'PAUSE' text (consolestring_01EAC6). Clears displayModeFlags bit 15, enables NMI for one VBlank cycle, then sets INIDISP to $09 (dimmed). Enters the hold loop.
; 
; Hold loop: EnableNmiAndJoypad → VBlankWait → EnableNmiOnly → RadarBorderAnimate → poll Start ($0657 bit $10). On release: clear overlay VRAM, restore brightness to $0F, set displayModeFlags bit 0 for VRAM flush, call UpdateFrameDialogue to restore display.
; 
; === INVENTORY PATH ===
; 
; Marks Select consumed ($2000). VBlankWait → OpenInventoryScreen → EnableNmiOnly. On return, marks Select+L ($6000) consumed to prevent re-trigger.
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
    LDA $playerFlags      ; Guard: bits 13|11 ($2800) = running or ability active → block Select/Y
    BIT #$2800
    BNE loc_038039
    LDA $joypadCurrent    ; Check Select ($2000) → inventory screen
    BIT #$2000
    BNE loc_03803B
    BIT #$4000            ; Check Y ($4000) → use equipped item
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
    JSL $@vblank_joypad.EnableNmiOnly ; Restore NMI-only mode (disable joypad auto-read during inventory teardown)
    LDA #$6000            ; Mark Select+L ($6000) consumed on return — prevents immediate re-open
    TSB $joypadHeld
    PLP 
    RTL 

  loc_038055:
    LDA #$1000            ; Mark Start as consumed in joypadHeld
    TSB $joypadHeld
    LDX #$0000
    LDA $playerFlags      ; Check playerFlags bit 3 ($0008) = input lock → simplified pause display
    BIT #$0008
    BNE loc_03806D
    JSR $&radar_map_screen.RadarScreenSetup ; Normal mode: full radar minimap with actors, markers, and enemy status
    SEP #$20
    BRA loc_03808B        ; Skip to shared hold-to-view loop

  loc_03806D:
    COP [RunBg3Script] ( @system_strings.consolestring_01EAC6 ) ; Input-locked mode: display 'PAUSE' text overlay via BG3 script
    LDA #$8000            ; Clear displayModeFlags bit 15 ($8000) before pause display setup
    TRB $displayModeFlags
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Enable NMI+joypad for one VBlank frame to sync display
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    LDA #$09              ; INIDISP $09: dim screen to 9/15 brightness for pause overlay
    STA $INIDISP

  loc_03808B:
    LDX #$0000            ; Initialize radar border animation index to 0
    PHX 

  loc_03808F:
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Hold loop: enable NMI+joypad, wait for VBlank, disable joypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    JSR $&radar_map_screen.RadarBorderAnimate ; Animate radar border tiles (cycling pattern on odd frames)
    LDA $0657             ; Read joypad high byte — poll for Start button release
    BIT #$10              ; Bit $10 in high byte = Start ($1000); zero = still held → loop
    BEQ loc_03808F
    PLX 
    LDA #$10              ; Mark Start in joypad release tracker ($0659) to suppress re-trigger
    TSB $0659
    JSL $@vram_buffer_clear.ClearVramBufferPartial ; Clear overlay VRAM to remove radar/pause graphics
    LDA #$0F              ; Restore full brightness INIDISP = $0F
    STA $INIDISP
    LDA #$01              ; Set displayModeFlags bit 0 ($01) = VRAM buffer has pending data for next VBlank
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue ; One UpdateFrameDialogue call to flush VRAM and restore normal display
    PLP 
    RTL 
}