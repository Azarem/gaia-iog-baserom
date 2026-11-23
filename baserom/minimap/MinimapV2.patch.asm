; Retranslation Minimap V2. Hook only Start in combat-enabled scenes.
; The stock dispatcher still owns pause, inventory, and remapped item use.

?INCLUDE 'GlobalInputHandler'
?INCLUDE 'minimap_v2_core'
?INCLUDE 'sprite_composition'
?INCLUDE 'system_core'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!joypadCurrent                  0656
!joypadHeld                     0658
!playerFlags                    09AE
!displayModeFlags               09EC
!INIDISP                        2100
!sortedRenderList               0C00

GlobalInputHandler.loc_038055! {
    LDA #$1000
    TSB $joypadHeld
    LDX #$0000
    LDA $playerFlags
    BIT #$0008
    BEQ open_minimap
    JMP $&loc_03806D

  open_minimap:
    JSL $@ShowMinimap
    PLP
    RTL
}

ShowMinimap {
    JSL $@minimap_v2_core.MinimapScreenSetup
    LDX #$0000
    PHX
    PHX

  gih_loop_top:
    REP #$20
    STZ $sortedRenderList
    JSL $@sprite_composition.ComposeAllSprites
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.DisableNmiKeepJoypad

    REP #$20
    LDA $joypadCurrent
    BIT #$1000
    BEQ gih_scroll
    JMP $&gih_loop_exit

  gih_scroll:
    ; --- D-pad scroll (minimap mode only) ---
    LDA $joypadCurrent

    BIT #$0800
    BEQ gih_no_up
    LDA $B6
    SEC
    SBC #$0002
    BPL gih_up_ok
    LDA #$0000
  gih_up_ok:
    AND #$FFFE
    STA $B6
    BRA gih_do_scroll

  gih_no_up:
    LDA $joypadCurrent
    BIT #$0400
    BEQ gih_no_down
    LDA $B6
    CLC
    ADC #$0002
    CMP $BE
    BCC gih_down_ok
    LDA $BE
  gih_down_ok:
    AND #$FFFE
    STA $B6
    BRA gih_do_scroll

  gih_no_down:
    LDA $joypadCurrent
    BIT #$0200
    BEQ gih_no_left
    LDA $B4
    SEC
    SBC #$0002
    BPL gih_left_ok
    LDA #$0000
  gih_left_ok:
    AND #$FFFE
    STA $B4
    BRA gih_do_scroll

  gih_no_left:
    LDA $joypadCurrent
    BIT #$0100
    BEQ gih_blink
    LDA $B4
    CLC
    ADC #$0002
    CMP $BC
    BCC gih_right_ok
    LDA $BC
  gih_right_ok:
    AND #$FFFE
    STA $B4

  gih_do_scroll:
    JSL $@minimap_v2_core.MinimapScrollUpdate
    BRA gih_blink

  gih_blink:
    SEP #$20
    ; Toggle OBJ palette 7 color 1 (player sprite marker) every 16 frames
    ; CGRAM shadow address: $7F0A00 + $1E0 + 2 = $7F0BE2
    LDA $01, S
    INC
    STA $01, S
    AND #$10
    BNE gih_blink_on

    ; OFF phase: transparent (color 0)
    REP #$20
    LDA #$0000
    STA $7F0BE2
    SEP #$20
    BRA gih_shimmer

  gih_blink_on:
    ; ON phase: restore original white ($7FFF = BGR555 white)
    REP #$20
    LDA #$7FFF
    STA $7F0BE2
    SEP #$20

    ; --- Border shimmer animation ---
    ; Cycles palette 7 color 1 through a 29-entry gradient at half frame rate.
    ; CGRAM shadow address: $7F0A00 + $38 + 2 = $7F0A3A (pal 7, color 1)
  gih_shimmer:
    LDA $0036
    LSR
    BCC gih_loop_top_jmp

    REP #$20
    LDA $03, S
    INC
    CMP #$001D
    BCC gih_shim_ok
    LDA #$0000
  gih_shim_ok:
    STA $03, S
    ASL
    TAX
    LDA $@minimap_v2_shimmer, X
    STA $7F0A3A
    SEP #$20

  gih_loop_top_jmp:
    JMP $&gih_loop_top

  gih_loop_exit:
    PLX
    PLX
    JSL $@minimap_v2_core.MinimapTeardown

    SEP #$20
    LDA #$10
    TSB $joypadHeld+1
    JSL $@vram_buffer_clear.ClearBg3TilemapBuffer_PreserveHud
    LDA #$0F
    STA $INIDISP
    LDA #$01
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue
    RTL
}