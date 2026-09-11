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

OverworldInputHandler {
    PHP 
    REP #$20
    LDA $sceneNext
    AND #$00FF
    BNE loc_038039
    LDA $playerFlags
    BIT #$0200
    BNE loc_038039
    JSL $@music_actors.IsMusicPlaying
    BCS loc_038039
    LDA $joypadCurrent
    BIT #$1000
    BNE loc_038055
    LDA $playerFlags
    BIT #$2800
    BNE loc_038039
    LDA $joypadCurrent
    BIT #$2000
    BNE loc_03803B
    BIT #$4000
    BEQ loc_038039
    JMP $&item_use_system.ItemUseDispatch

  loc_038039:
    PLP 
    RTL 

  loc_03803B:
    LDA #$2000
    TSB $joypadHeld
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@inventory_overlay.OpenInventoryScreen
    JSL $@vblank_joypad.EnableNmiOnly
    LDA #$6000
    TSB $joypadHeld
    PLP 
    RTL 

  loc_038055:
    LDA #$1000
    TSB $joypadHeld
    LDX #$0000
    LDA $playerFlags
    BIT #$0008
    BNE loc_03806D
    JSR $&radar_map_screen.RadarScreenSetup
    SEP #$20
    BRA loc_03808B

  loc_03806D:
    COP [RunBg3Script] ( @system_strings.asciistring_01EAC6 )
    LDA #$8000
    TRB $displayModeFlags
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    LDA #$09
    STA $INIDISP

  loc_03808B:
    LDX #$0000
    PHX 

  loc_03808F:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    JSR $&radar_map_screen.RadarBorderAnimate
    LDA $0657
    BIT #$10
    BEQ loc_03808F
    PLX 
    LDA #$10
    TSB $0659
    JSL $@vram_buffer_clear.ClearVramBufferPartial
    LDA #$0F
    STA $INIDISP
    LDA #$01
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue
    PLP 
    RTL 
}