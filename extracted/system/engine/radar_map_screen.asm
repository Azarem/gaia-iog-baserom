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

RadarScreenSetup {
    LDA $7F0C07
    BEQ loc_0380D7
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    REP #$20
    BRA RadarScreenSetup

  loc_0380D7:
    LDA #$&radar_icons_001C00
    STA $adhocVramDma
    LDA #$*radar_icons_001C00
    STA $7F0C05
    LDA #$7700
    STA $7F0C07
    LDA #$0200
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
    JSL $@vram_buffer_clear.ClearVramBufferPartial
    PHB 
    LDX #$&radar_layout_001E00
    LDY #$0380
    LDA #$057F
    MVN #$7F, #$^radar_layout_001E00
    PLB 
    LDA $playerXTile
    AND #$00FC
    SEC 
    SBC #$0020
    STA $0018
    CLC 
    ADC #$0044
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
    AND #$00F0
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03815B
    ORA #$34F0
    STA $7F07CC

  loc_03815B:
    LDA $0002
    AND #$000F
    ORA #$34F0
    STA $7F07CE
    LDA #$2EE6
    STA $7F07C8
    LDA $0018
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
    LDA #$2AE7
    STA $7F0608
    LDA $sceneCurrent
    JSL $@cop_handlers_script.TestFlag_0300
    BCS loc_038248
    LDX $sceneCurrent
    LDA $@enemy_clear_reward_table, X
    AND #$00FF
    BEQ loc_038248
    LDA #$2EE1
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
    LDA #$32E8
    STA $7F0448
    INC 
    STA $7F044A
    INC 
    STA $7F0488
    INC 
    STA $7F048A
    LDX #$0000
    COP [RunBg3Script] ( @system_strings.asciistring_01EAD1 )

  loc_038248:
    LDA #$32E5
    STA $7F0626
    LDA #$0001
    TSB $displayModeFlags
    LDX #$0000
    RTS 
}

RadarBorderAnimate {
    LDA $0036
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

RadarPlotSceneMarkers {
    PHX 
    STZ $0002
    LDX $0646
    LDA $@table_01ADA8, X
    SEC 
    SBC #$&table_01ADA8
    TAX 
    SEP #$20

  loc_03828E:
    LDA $@table_01ADA8, X
    BMI loc_03830A
    LDA $@table_01ADA8+3, X
    REP #$20
    AND #$007F
    JSL $@cop_handlers_script.TestEventFlag_0200
    SEP #$20
    BCS loc_038304
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
    AND #$FE
    STA $0000
    STZ $0001
    LDA $@table_01ADA8+1, X
    SEC 
    SBC $001C
    REP #$20
    LSR 
    AND #$00FE
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0000
    CLC 
    ADC #$0216
    PHX 
    TAX 
    LDA #$2EE6
    STA $7F0200, X
    PLX 
    SEP #$20

  loc_0382F9:
    SED 
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

RadarPlotActors {
    LDA $56
    BEQ loc_03832E

  loc_038312:
    TAX 
    LDA $extendedFlags, X
    BIT #$0100
    BEQ loc_038321
    JSR $&RadarPlotFriendlyActor
    BRA loc_038329

  loc_038321:
    BIT #$0200
    BEQ loc_038329
    JSR $&RadarPlotEnemyActor

  loc_038329:
    LDA $0006, X
    BNE loc_038312

  loc_03832E:
    RTS 
}

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
    LDA #$2AE7
    STA $7F0200, X
    PLX 

  loc_038377:
    SEC 
    RTS 
}

RadarPlotEnemyActor {
    LDA $0014, X
    CMP $cameraOffsetX
    BCC loc_0383D5
    CMP $cameraBoundsX
    BCS loc_0383D5
    CMP $0018
    BMI loc_0383D5
    CMP $001A
    BCS loc_0383D5
    LDA $0016, X
    CMP $cameraOffsetY
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
    LDA #$280D
    STA $7F0200, X
    PLX 

  loc_0383D5:
    RTS 
}

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