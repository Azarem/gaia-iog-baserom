?BANK 03

?INCLUDE 'ambient_palette_cycler'
?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'chunk_03BAE1'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'inventory_overlay'
?INCLUDE 'music_actors'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'system_core'
?INCLUDE 'system_strings'
?INCLUDE 'table_01ADA8'
?INCLUDE 'table_0EE000'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!sceneNext                      0642
!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!musicParentActor               06F2
!musicTransitionState           06FA
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!displayModeFlags               09EC
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!characterForm                  0AD4
!damageFlashTimer               0B22
!INIDISP                        2100
!APUIO1                         2141
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!extendedFlags                  7F002A
!adhocVramDma                   7F0C03

---------------------------------------------

func_038000 {
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
    JMP $&sub_038410

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
    JSR $&sub_0380BF
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
    JSR $&sub_038259
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
---------------------------------------------

sub_0380BF {
    LDA $7F0C07
    BEQ loc_0380D7
    SEP #$20
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiOnly
    REP #$20
    BRA sub_0380BF

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
    JSR $&sub_03827C
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
    JSR $&sub_03830E
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
---------------------------------------------

sub_038259 {
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
    LDA $@word_0383D6, X
    STA $7F0A24
    SEP #$20
    RTS 
}
---------------------------------------------

sub_03827C {
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
---------------------------------------------

sub_03830E {
    LDA $56
    BEQ loc_03832E

  loc_038312:
    TAX 
    LDA $extendedFlags, X
    BIT #$0100
    BEQ loc_038321
    JSR $&sub_03832F
    BRA loc_038329

  loc_038321:
    BIT #$0200
    BEQ loc_038329
    JSR $&sub_038379

  loc_038329:
    LDA $0006, X
    BNE loc_038312

  loc_03832E:
    RTS 
}
---------------------------------------------

sub_03832F {
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
---------------------------------------------

sub_038379 {
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
---------------------------------------------

word_0383D6 [
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
---------------------------------------------

sub_038410 {
    PEA $&sub_03842F-1
    LDY $inventoryEquippedIndex
    BPL loc_03841B
    JMP $&func_0384BF

  loc_03841B:
    LDA $inventorySlots, Y
    AND #$00FF
    AND #$003F
    ASL 
    TAX 
    LDA #$4000
    TSB $joypadHeld
    JMP ($&table_03843F, X)
}
---------------------------------------------

sub_03842F {
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    LDA #$4000
    TSB $joypadHeld
    PLP 
    RTL 
}
---------------------------------------------

table_03843F [
  &func_0384BF   ;00
  &func_0384D5   ;01
  &func_0385C2   ;02
  &func_038691   ;03
  &func_0387A7   ;04
  &func_03881D   ;05
  &func_03888A   ;06
  &func_038917   ;07
  &func_03899A   ;08
  &func_038BA4   ;09
  &func_038D67   ;0A
  &func_038E15   ;0B
  &func_038E96   ;0C
  &func_038F17   ;0D
  &func_038FF3   ;0E
  &func_0390CE   ;0F
  &func_039144   ;10
  &func_03921A   ;11
  &func_039299   ;12
  &func_03932B   ;13
  &func_0393A1   ;14
  &func_039427   ;15
  &func_03950C   ;16
  &func_03966A   ;17
  &func_039691   ;18
  &func_03983D   ;19
  &func_0398B2   ;1A
  &func_03995C   ;1B
  &func_03997F   ;1C
  &func_0399CD   ;1D
  &func_039AA0   ;1E
  &func_039AA0   ;1F
  &func_039AA0   ;20
  &func_039AA0   ;21
  &func_039AA0   ;22
  &func_039AA0   ;23
  &func_039CAF   ;24
  &func_039D09   ;25
  &func_039E15   ;26
  &func_039F30   ;27
  &func_039F5D   ;28
  &func_039FB1   ;29
  &func_039FB1   ;2A
  &func_039FB1   ;2B
  &func_039FB1   ;2C
  &func_039FB1   ;2D
  &func_039FB1   ;2E
  &func_039FB1   ;2F
  &func_039FB1   ;30
  &func_039FB1   ;31
  &func_039FB1   ;32
  &func_039FB1   ;33
  &func_039FB1   ;34
  &func_039FB1   ;35
  &func_039FB1   ;36
  &func_039FB1   ;37
  &func_039FB1   ;38
  &func_039FB1   ;39
  &func_039FB1   ;3A
  &func_039FB1   ;3B
  &func_039FB1   ;3C
  &func_039FB1   ;3D
  &func_039FB1   ;3E
  &func_039FB1   ;3F
]
---------------------------------------------

func_0384BF {
    COP [PrintWideString] ( &widestring_0384C4 )
    RTS 
}

widestring_0384C4 `[DEF]You're not equipped.[END]`
---------------------------------------------

func_0384D5 {
    COP [PrintWideString] ( &widestring_038517 )
    JSR $&sub_039FB2
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    PHX 
    PHD 
    LDA $playerActor
    TCD 
    TAX 
    COP [SpawnLastRel] ( @code_038566, #00, #00, #$2000 )
    TYX 
    LDA #$0000
    STA $0012, X
    LDA #$3000
    STA $000E, X
    LDY $playerActor
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLD 
    PLX 
    RTS 
}

widestring_038517 `[DEF]He raised the Red Jewel![FIN]Red Jewels[N]fly to Jeweler Gem's in[N]a single ray of light![END]`

code_038566 {
    COP [SpawnMarkedAfter] ( @code_038576, #$1002 )
    COP [LoopInit] ( #FF )
    DEC $16
    COP [LoopNext]
    COP [Die]
}

code_038576 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$0001
    STA $orbitAngle, X
    STA $orbitDiameter, X
    COP [PlaySoundCh2] ( #25 )

  loc_03858C:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_03858C
    LDA $08
    STZ $08
    STA $26

  loc_038598:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    COP [SetEntryExit]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$00FF
    BEQ loc_0385C0
    INC 
    STA $orbitDiameter, X
    DEC $26
    BPL loc_038598
    BRA loc_03858C

  loc_0385C0:
    COP [Die]
}
---------------------------------------------

func_0385C2 {
    LDA $sceneCurrent
    CMP #$000B
    BNE loc_03861A
    COP [BranchIfPlayerInAbsTiles] ( #0E, #10, #10, #11, &code_0385DC )
    COP [BranchIfPlayerInAbsTiles] ( #0A, #17, #0C, #18, &code_0385FF )
    BRA loc_03861A
}

code_0385DC {
    COP [BranchIfFlagByte] ( #24, #01, &code_038615 )
    COP [PrintWideString] ( &widestring_03861F )
    COP [StageBgChange] ( #06 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0106 )
    COP [SetFlagByte] ( #24 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearLowAbs] ( #0E, #11 )
    COP [ClearLowAbs] ( #0F, #11 )
    RTS 
}

code_0385FF {
    COP [BranchIfFlagByte] ( #42, #01, &code_038615 )
    COP [PrintWideString] ( &widestring_03861F )
    COP [SetFlagByte] ( #42 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearHighAbs] ( #09, #17 )
    RTS 
}

code_038615 {
    COP [PrintWideString] ( &widestring_038680 )
    RTS 

  loc_03861A:
    COP [PrintWideString] ( &widestring_03865D )
    RTS 
}

widestring_03861F `[DEF]As he turns the [N]prison key, the steel [N]door opens with a [N]dull sound. [END]`

widestring_03865D `[DEF]There's no keyhole for[N]the prison key.[END]`

widestring_038680 `[DEF]The door is open. [END]`
---------------------------------------------

func_038691 {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_0386FA
    LDA $playerYTile
    CMP #$0012
    BEQ loc_0386A6
    CMP #$0013
    BNE loc_0386EA

  loc_0386A6:
    LDA $playerXTile
    CMP #$0037
    BEQ loc_0386B3
    CMP #$0038
    BNE loc_0386EA

  loc_0386B3:
    COP [PrintWideString] ( &widestring_0386BE )
    COP [RemoveItem] ( #03 )
    COP [SetFlagByte] ( #30 )
    RTS 
}

widestring_0386BE `[DEF]He set Inca Statue [N]A on the mantel. [END]`
---------------------------------------------

func_0386DD {
    LDA $playerYTile
    CMP #$0015
    BEQ loc_0386EA
    CMP #$0016
    BNE loc_0386FA

  loc_0386EA:
    LDA $playerXTile
    CMP #$0026
    BNE loc_0386F5
    JMP $&code_03876D

  loc_0386F5:
    CMP #$0027
    BNE loc_0386FA

  loc_0386FA:
    COP [BranchIfFlagByte] ( #44, #00, &code_038705 )
    COP [PrintWideString] ( &widestring_03870A )
    RTS 
}

code_038705 {
    COP [PrintWideString] ( &widestring_038746 )
    RTS 
}

widestring_03870A `[DEF]He said to dedicate the [N]statues where the [N]breath of the spirits [N]can't reach. [END]`

widestring_038746 `[DEF]Is the Inca secret[N]hidden in the statue?[END]`

code_03876D {
    COP [PrintWideString] ( &widestring_038772 )
    RTS 
}

widestring_038772 `[DEF]The shape of the mantel [N]doesn't match the [N]shape of the statue. [END]`
---------------------------------------------

func_0387A7 {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_03880D
    LDA $playerYTile
    CMP #$0015
    BEQ loc_0387BC
    CMP #$0016
    BNE loc_038800

  loc_0387BC:
    LDA $playerXTile
    CMP #$0026
    BEQ loc_0387C9
    CMP #$0027
    BNE loc_038800

  loc_0387C9:
    COP [PrintWideString] ( &widestring_0387D4 )
    COP [RemoveItem] ( #04 )
    COP [SetFlagByte] ( #31 )
    RTS 
}

widestring_0387D4 `[DEF]He set Inca Statue [N]B on the mantel. [END]`
---------------------------------------------

func_0387F3 {
    LDA $playerYTile
    CMP #$0012
    BEQ loc_038800
    CMP #$0013
    BNE loc_03880D

  loc_038800:
    LDA $playerXTile
    CMP #$0037
    BEQ loc_038818
    CMP #$0038
    BNE loc_03880D

  loc_03880D:
    COP [BranchIfFlagByte] ( #44, #00, &code_038705 )
    COP [PrintWideString] ( &widestring_03870A )
    RTS 

  loc_038818:
    COP [PrintWideString] ( &widestring_038772 )
    RTS 
}
---------------------------------------------

func_03881D {
    COP [PrintWideString] ( &widestring_038836 )
    LDA $sceneCurrent
    CMP #$0018
    BNE loc_038831
    COP [SetFlagByte] ( #2E )
    COP [PrintWideString] ( &widestring_03885A )
    RTS 

  loc_038831:
    COP [PrintWideString] ( &widestring_03887A )
    RTS 
}

widestring_038836 `[DEF]Will softly played the [N]Incan melody. [FIN]`

widestring_03885A `The Mayor's expression[N]changed![END]`

widestring_03887A `But nothing happened.[END]`
---------------------------------------------

func_03888A {
    COP [PrintWideString] ( &widestring_0388AD )
    COP [DialogueOptions] ( #02, #01, &code_list_038894 )
}

code_list_038894 [
  &code_0388A8   ;00
  &code_03889A   ;01
  &code_0388A8   ;02
]

code_03889A {
    COP [PrintWideString] ( &widestring_0388E9 )
    LDA #$0008
    STA $damageFlashTimer
    JSR $&sub_039FB2
    RTS 
}

code_0388A8 {
    COP [PrintWideString] ( &widestring_0388CA )
    RTS 
}

widestring_0388AD `[DEF]Take the medicine?[N] Yes[N] No`

widestring_0388CA `[CLR]He stopped eating [N]the herb. [END]`

widestring_0388E9 `[CLR]Eating the herb, he [N]regained his strength. [END]`
---------------------------------------------

func_038917 {
    LDA $sceneCurrent
    CMP #$0025
    BNE loc_038939
    LDA $playerYTile
    CMP #$0019
    BEQ loc_03892C
    CMP #$001A
    BNE loc_038939

  loc_03892C:
    LDA $playerXTile
    CMP #$000E
    BEQ func_038971
    CMP #$000F
    BNE loc_038939

  loc_038939:
    COP [PrintWideString] ( &widestring_03893E )
    RTS 
}

widestring_03893E `[DEF]I can't find a space [N]that the diamond-shaped [N]block fits. [END]`
---------------------------------------------

func_038971 {
    COP [PrintWideString] ( &widestring_03897C )
    COP [RemoveItem] ( #07 )
    COP [SetFlagByte] ( #2F )
    RTS 
}

widestring_03897C `[DEF]He fit the block[N]into the tile![END]`
---------------------------------------------

func_03899A {
    LDA $characterForm
    BNE loc_0389F5
    JSL $@music_actors.IsMusicPlaying
    BCC loc_0389A6
    RTS 

  loc_0389A6:
    LDA $sceneCurrent
    CMP #$0024
    BNE code_0389F0
    COP [BranchIfFlagByte] ( #01, #01, &code_0389F0 )
    LDA #$0080
    TSB $displayModeFlags
    COP [PrintWideString] ( &widestring_038A2B )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @func_039FCA, #00, #00, #$2000 )
    CPY #$1FC0
    BNE loc_0389D3
    JMP $&code_0389D9

  loc_0389D3:
    LDA #$CFF0
    TSB $joypadMaskStd
}

code_0389D9 {
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$0019
    STA $0026, Y
    LDA #$0000
    STA $0020, Y
    PLX 
    RTS 
}

code_0389F0 {
    COP [PrintWideString] ( &widestring_038A8A )
    RTS 

  loc_0389F5:
    COP [PrintWideString] ( &widestring_038B76 )
    RTS 
}

code_0389FA {
    COP [PrintWideString] ( &widestring_038B8F )
    RTS 
}
---------------------------------------------

widestring_0389FF `[DEF]Play the Flute?[N] Yes[N] No`
---------------------------------------------

func_038A16 {
    COP [SetFlagByte] ( #01 )
    COP [PrintWideString] ( &widestring_038A46 )
    COP [SpawnThinkerParam] ( #2F, @ambient_palette_cycler.code_00B522 )
    COP [RestoreSavedPtr]

  loc_038A25:
    COP [PrintWideString] ( &widestring_038AB5 )
    COP [RestoreSavedPtr]
}

widestring_038A2B `[DEF]He softly played[N]the Wind Melody.[END]`

widestring_038A46 `[DEF][CLR]When touched by the echo[N]of the Flute, the Gold[N]Block began to glow![END]`

widestring_038A8A `[DEF]He softly played[N]the Wind Melody.[FIN]But nothing happened.[END]`

widestring_038AB5 `[DEF][CLR]When the melody flowed[N]around his body, strange[N]words filled his head.[FIN]Chant in the room paved[N]with gold, and meditate[N]a while in the place[N]that shines brightly.[FIN]For that person the road[N]to the ocean of[N]freedom will open...[END]`

widestring_038B76 `[DEF][CLR]He doesn't have[N]the Flute...[END]`

widestring_038B8F `[CLR]He stopped playing.[END]`
---------------------------------------------

func_038BA4 {
    LDA $characterForm
    BEQ loc_038BAC
    JMP $&code_038C30

  loc_038BAC:
    JSL $@music_actors.IsMusicPlaying
    BCC loc_038BB3
    RTS 

  loc_038BB3:
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038BD6
    CMP #$0011
    BEQ loc_038BC7
    CMP #$00CD
    BEQ loc_038BDE
    BRA code_038C2B

  loc_038BC7:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038C2B )
    COP [BranchIfFlagByte] ( #02, #01, &code_038C2B )
    BRA loc_038BEF

  loc_038BD6:
    COP [BranchIfFlagByte] ( #40, #01, &code_038C2B )
    BRA loc_038BEF

  loc_038BDE:
    COP [BranchIfFlagByte] ( #BB, #01, &code_038C2B )
    COP [BranchIfFlagByte] ( #0E, #00, &code_038C2B )
    COP [SetFlagByte] ( #0D )
    BRA loc_038BEF

  loc_038BEF:
    LDA #$0080
    TSB $displayModeFlags
    COP [PrintWideString] ( &widestring_038C76 )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @func_039FCA, #00, #00, #$2000 )
    CPY #$1FC0
    BNE loc_038C0E
    JMP $&code_038C14

  loc_038C0E:
    LDA #$CFF0
    TSB $joypadMaskStd
}

code_038C14 {
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$0018
    STA $0026, Y
    LDA #$0001
    STA $0020, Y
    PLX 
    RTS 
}

code_038C2B {
    COP [PrintWideString] ( &widestring_038CDB )
    RTS 
}

code_038C30 {
    COP [PrintWideString] ( &widestring_038F82 )
    RTS 
}
---------------------------------------------

func_038C35 {
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038C49
    CMP #$0011
    BEQ loc_038C58
    CMP #$00CD
    BEQ code_038C68
    BRA code_038C70

  loc_038C49:
    COP [BranchIfFlagByte] ( #40, #01, &code_038C68 )
    COP [SetFlagByte] ( #40 )
    COP [PrintWideString] ( &widestring_038CA0 )
    COP [RestoreSavedPtr]

  loc_038C58:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038C70 )
    COP [SetFlagByte] ( #02 )
    COP [PrintWideString] ( &widestring_038D17 )
    COP [RestoreSavedPtr]
}

code_038C68 {
    COP [SetFlagByte] ( #01 )
    COP [ClearFlagByte] ( #0E )
    COP [RestoreSavedPtr]
}

code_038C70 {
    COP [PrintWideString] ( &widestring_038CDB+M )
    COP [RestoreSavedPtr]
}

widestring_038C76 `[DEF]He softly played the[N]melody he had learned[N]from Lola.[END]`

widestring_038CA0 `[DEF][CLR]The melody, carried on [N]the wind, spread [N]over the meadow. [END]`

widestring_038CDB `[DEF]He softly played the[N]melody he had learned[N]from Lola.[FIN][::][DEF][CLR]But nothing happened.[END]`

widestring_038D17 `[DEF][CLR]He heard a soft voice[N]from somewhere...[FIN][TPL:2]Strange Voice:[N]Go to the switch on[N]the right-hand wall.[PAL:0][END]`
---------------------------------------------

func_038D67 {
    LDA $sceneCurrent
    CMP #$002F
    BNE code_038D80
    COP [BranchIfFlagByte] ( #02, #00, &code_038D80 )
    COP [RemoveItem] ( #0A )
    COP [PrintWideString] ( &widestring_038DDA )
    COP [SetFlagByte] ( #03 )
    RTS 
}

code_038D80 {
    COP [PrintWideString] ( &widestring_038D85 )
    RTS 
}

widestring_038D85 `[DEF]He bit off some [N]of the smoked meat. [FIN]It had a flavor he'd[N]never tasted before.[N]What could it be?[END]`

widestring_038DDA `[DEF]We bit off[N]some of the meat.[FIN]It was better than any[N]food we'd ever had.[END]`
---------------------------------------------

func_038E15 {
    COP [PrintWideString] ( &widestring_038E39 )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038E29
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038E2E )

  loc_038E29:
    COP [PrintWideString] ( &widestring_038E61 )
    RTS 
}

code_038E2E {
    COP [PrintWideString] ( &widestring_038E73 )
    COP [RemoveItem] ( #0B )
    COP [SetFlagByte] ( #5B )
    RTS 
}

widestring_038E39 `[DEF]He tries using the key [N]to the mine. [FIN]`

widestring_038E61 `But there's no keyhole![END]`

widestring_038E73 `The key turns, making a [N]strange sound. [END]`
---------------------------------------------

func_038E96 {
    COP [PrintWideString] ( &widestring_038EBA )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038EAA
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038EAF )

  loc_038EAA:
    COP [PrintWideString] ( &widestring_038EE2 )
    RTS 
}

code_038EAF {
    COP [PrintWideString] ( &widestring_038EF4 )
    COP [RemoveItem] ( #0C )
    COP [SetFlagByte] ( #5C )
    RTS 
}

widestring_038EBA `[DEF]He tries using the key [N]to the mine. [FIN]`

widestring_038EE2 `But there's no keyhole![END]`

widestring_038EF4 `The key turns, making a [N]strange sound. [END]`
---------------------------------------------

func_038F17 {
    LDA $characterForm
    BEQ loc_038F21
    COP [PrintWideString] ( &widestring_038F82 )
    RTS 

  loc_038F21:
    LDA $sceneCurrent
    CMP #$0039
    BEQ loc_038F2B
    BRA code_038F7D

  loc_038F2B:
    COP [BranchIfFlagByte] ( #68, #01, &code_038F7D )
    COP [BranchIfPlayerInAbsTiles] ( #13, #18, #1A, #1D, &code_038F3B )
    BRA code_038F7D
}

code_038F3B {
    LDA #$0080
    TSB $displayModeFlags
    COP [PrintWideString] ( &widestring_038FCD )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @func_039FCA, #00, #00, #$2000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$001D
    STA $0026, Y
    LDA #$0002
    STA $0020, Y
    PLX 
    LDA #$000E
    STA $musicParentActor
    RTS 
}
---------------------------------------------

func_038F6F {
    COP [RemoveItem] ( #0D )
    COP [SpawnThinkerParam] ( #1B, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [SetFlagByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_038F7D {
    COP [PrintWideString] ( &widestring_038F98 )
    RTS 
}

widestring_038F82 `[DEF]He doesn't have[N]the Flute.[END]`

widestring_038F98 `[DEF]Will began playing the [N]melody he remembered. [FIN]But nothing happened.[END]`

widestring_038FCD `[DEF][CLR]Will began playing the [N]melody he remembered. [END]`
---------------------------------------------

func_038FF3 {
    LDA $sceneCurrent
    CMP #$004C
    BNE loc_03901B
    COP [BranchIfPlayerInAbsTiles] ( #16, #0C, #18, #0F, &code_039020 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #10, #18, #13, &code_03902B )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0A, #0B, #0D, &code_039036 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0E, #0B, #11, &code_039041 )

  loc_03901B:
    COP [PrintWideString] ( &widestring_039057 )
    RTS 
}

code_039020 {
    COP [BranchIfFlagByte] ( #60, #01, &code_039052 )
    COP [SetFlagByte] ( #60 )
    BRA loc_03904A
}

code_03902B {
    COP [BranchIfFlagByte] ( #61, #01, &code_039052 )
    COP [SetFlagByte] ( #61 )
    BRA loc_03904A
}

code_039036 {
    COP [BranchIfFlagByte] ( #62, #01, &code_039052 )
    COP [SetFlagByte] ( #62 )
    BRA loc_03904A
}

code_039041 {
    COP [BranchIfFlagByte] ( #63, #01, &code_039052 )
    COP [SetFlagByte] ( #63 )

  loc_03904A:
    COP [PrintWideString] ( &widestring_039083 )
    JSR $&sub_039FB2
    RTS 
}

code_039052 {
    COP [PrintWideString] ( &widestring_0390A5 )
    RTS 
}

widestring_039057 `[DEF]He raises the [N]Crystal Ball, but [N]nothing happened... [END]`

widestring_039083 `[DEF]The Crystal Ball is [N]set in the hole! [END]`

widestring_0390A5 `[DEF]The Crystal Ball is [N]already set in the hole![END]`
---------------------------------------------

func_0390CE {
    COP [PrintWideString] ( &widestring_0390F2 )
    LDA $sceneCurrent
    CMP #$003F
    BNE loc_0390E2
    COP [BranchIfPlayerInAbsTiles] ( #18, #34, #1A, #37, &code_0390E7 )

  loc_0390E2:
    COP [PrintWideString] ( &widestring_039110 )
    RTS 
}

code_0390E7 {
    COP [PrintWideString] ( &widestring_039122 )
    COP [RemoveItem] ( #0F )
    COP [SetFlagByte] ( #69 )
    RTS 
}

widestring_0390F2 `[DEF]He tries using [N]the elevator key. [FIN]`

widestring_039110 `But there's no keyhole![END]`

widestring_039122 `The key turns, making a[N]strange sound. [END]`
---------------------------------------------

func_039144 {
    COP [PrintWideString] ( &widestring_039179 )
    LDA $sceneCurrent
    CMP #$005A
    BNE code_039158
    COP [BranchIfPlayerInAbsTiles] ( #08, #07, #0A, #08, &code_03915D )

  code_039158:
    COP [PrintWideString] ( &widestring_0391A4 )
    RTS 
}

code_03915D {
    COP [BranchIfFlagWord] ( #$0138, #01, &code_039158 )
    COP [PrintWideString] ( &widestring_0391B6 )
    COP [RemoveItem] ( #10 )
    COP [StageBgChange] ( #38 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0138 )
    COP [PrintWideString] ( &widestring_0391D9 )
    RTS 
}

widestring_039179 `[DEF]He tries using the key [N]to the Seaside Palace.[FIN]`

widestring_0391A4 `But there's no keyhole![END]`

widestring_0391B6 `The key turns, making a[N]strange sound. [FIN]`

widestring_0391D9 `[CLR][TPL:2]Lilly spoke from[N]his pocket.[FIN]The phantom land of[N]Mu lies ahead.[PAL:0][END]`
---------------------------------------------

func_03921A {
    COP [PrintWideString] ( &widestring_039244 )
    LDA $sceneCurrent
    CMP #$005D
    BNE loc_03923F
    COP [BranchIfPlayerInAbsTiles] ( #0A, #11, #17, #1A, &code_039230 )
    BRA loc_03923F
}

code_039230 {
    COP [SolidHighAbs] ( #0D, #0F )
    COP [RemoveItem] ( #11 )
    COP [PrintWideString] ( &widestring_03926F )
    COP [SetFlagByte] ( #0E )
    RTS 

  loc_03923F:
    COP [PrintWideString] ( &widestring_03925F )
    RTS 
}

widestring_039244 `[DEF]He raises the [N]Purification Stone. [FIN]`

widestring_03925F `But nothing happened![END]`

widestring_03926F `The stone began to glow, [N]then disappeared into [N]the spring. [END]`
---------------------------------------------

func_039299 {
    COP [PrintWideString] ( &widestring_0392DE )
    LDA $sceneCurrent
    CMP #$0063
    BNE code_0392D9
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #0A, #08, &code_0392C8 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #06, #1A, #08, &code_0392B7 )
    BRA code_0392D9
}

code_0392B7 {
    COP [BranchIfFlagByte] ( #7E, #01, &code_0392D9 )
    JSR $&sub_039FB2
    COP [PrintWideString] ( &widestring_03930B )
    COP [SetFlagByte] ( #7E )
    RTS 
}

code_0392C8 {
    COP [BranchIfFlagByte] ( #7B, #01, &code_0392D9 )
    JSR $&sub_039FB2
    COP [PrintWideString] ( &widestring_03930B )
    COP [SetFlagByte] ( #7B )
    RTS 
}

code_0392D9 {
    COP [PrintWideString] ( &widestring_0392FB )
    RTS 
}

widestring_0392DE `[DEF]He raises the [N]Statue of Hope. [FIN]`

widestring_0392FB `But nothing happened![END]`

widestring_03930B `A strange whisper is[N]heard from somewhere...[END]`
---------------------------------------------

func_03932B {
    COP [PrintWideString] ( &widestring_039370 )
    LDA $sceneCurrent
    CMP #$0066
    BNE code_03936B
    COP [BranchIfPlayerInAbsTiles] ( #23, #08, #26, #0A, &code_039349 )
    COP [BranchIfPlayerInAbsTiles] ( #2A, #08, #2D, #0A, &code_03935A )
    BRA code_03936B
}

code_039349 {
    COP [BranchIfFlagByte] ( #80, #01, &code_03936B )
    JSR $&sub_039FB2
    COP [PrintWideString] ( &widestring_03939F )
    COP [SetFlagByte] ( #80 )
    RTS 
}

code_03935A {
    COP [BranchIfFlagByte] ( #81, #01, &code_03936B )
    JSR $&sub_039FB2
    COP [PrintWideString] ( &widestring_03939F )
    COP [SetFlagByte] ( #81 )
    RTS 
}

code_03936B {
    COP [PrintWideString] ( &widestring_03938F )
    RTS 
}

widestring_039370 `[DEF]He raises the [N]Rama Statue. [FIN]`

widestring_03938F `But nothing happened![END]`

widestring_03939F `[CLD]`
---------------------------------------------

func_0393A1 {
    COP [PrintWideString] ( &widestring_0393C5 )
    LDA $sceneCurrent
    CMP #$0074
    BNE loc_0393B5
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #0A, &code_0393BA )

  loc_0393B5:
    COP [PrintWideString] ( &widestring_0393EA )
    RTS 
}

code_0393BA {
    COP [PrintWideString] ( &widestring_0393FA )
    COP [RemoveItem] ( #14 )
    COP [SetFlagByte] ( #01 )
    RTS 
}

widestring_0393C5 `[DEF]He tries using the [N]Magic Powder. [FIN]`

widestring_0393EA `But nothing happened![END]`

widestring_0393FA `He spreads Magic Powder [N]on Kara's picture! [END]`
---------------------------------------------

func_039427 {
    COP [PrintWideString] ( &widestring_03944D )
    COP [DialogueOptions] ( #03, #01, &code_list_039431 )
}

code_list_039431 [
  &code_039439   ;00
  &code_03943E   ;01
  &code_039443   ;02
  &code_039448   ;03
]

code_039439 {
    COP [PrintWideString] ( &widestring_0394B5 )
    RTS 
}

code_03943E {
    COP [PrintWideString] ( &widestring_0394CE )
    RTS 
}

code_039443 {
    COP [PrintWideString] ( &widestring_0394E5 )
    RTS 
}

code_039448 {
    COP [PrintWideString] ( &widestring_0394FD )
    RTS 
}

widestring_03944D `[DEF]He opened Lance's father's[N]journal. [FIN]Read which entry? [N] Tower of Babel [N] Mystic Statues [N] Great Wall of China `

widestring_0394B5 `[DEF]He closes the journal. [END]`

widestring_0394CE `[DEF]The Tower of Babel...[END]`

widestring_0394E5 `[DEF]The Mystic Statues... [END]`

widestring_0394FD `[DEF]The Great Wall...[END]`
---------------------------------------------

func_03950C {
    COP [SetFlagByte] ( #8E )
    COP [PrintWideString] ( &widestring_039514 )
    RTS 
}

widestring_039514 `[DEF]He opened Lance's letter. [FIN][TPL:4]Lance: [N]I'm going to the [N]Great Wall of China. [FIN]I intended to keep it [N]secret, but I told Will [N]just in case... [FIN]I'm putting this letter[N]in his luggage, but he[N]probably won't notice.[FIN]The townspeople say[N]there's some kind of[N]cure for my father[N]at the Great Wall.[FIN]It's a long journey, but[N]I'd go anywhere if[N]it would help him.[N]Don't worry about me...[FIN]P.S.: [N]By the way, Lilly [N]has left me.[PAL:0][END]`
---------------------------------------------

func_03966A {
    COP [PrintWideString] ( &widestring_03966F )
    RTS 
}

widestring_03966F `[DEF]Lance made this necklace [N]for Lilly...[END]`
---------------------------------------------

func_039691 {
    COP [PrintWideString] ( &widestring_039696 )
    RTS 
}

widestring_039696 `[DEF]He opened the will.[FIN][N]    To the Opponent[FIN]Even if I perish, don't[N]mourn for me.[FIN]Even if Russian Glass[N]doesn't cost me[N]my life, it's my fate[N]to pass away soon.[FIN]Six months ago, when I[N]found out I was dying,[N]I decided to amass as[N]much money as possible.[FIN]I wanted to leave it to [N]my wife, and the child [N]I'll never see. [FIN]I made my fortune [N]in spite of the  [N]unhappiness I have [N]caused others. [FIN]If I lose, I want to[N]leave part of my[N]estate to you.[FIN]Please take care of my [N]four favorite [N]Kruk horses. [END]`
---------------------------------------------

func_03983D {
    COP [PrintWideString] ( &widestring_039861 )
    LDA $sceneCurrent
    CMP #$0095
    BNE loc_039851
    COP [BranchIfPlayerInAbsTiles] ( #28, #09, #2D, #0D, &code_039856 )

  loc_039851:
    COP [PrintWideString] ( &widestring_039880 )
    RTS 
}

code_039856 {
    COP [PrintWideString] ( &widestring_039890 )
    COP [RemoveItem] ( #19 )
    COP [SetFlagByte] ( #A8 )
    RTS 
}

widestring_039861 `[DEF]He tries using [N]the Teapot. [FIN]`

widestring_039880 `But nothing happened![END]`

widestring_039890 `The spirits' tears [N]rained down. [END]`
---------------------------------------------

func_0398B2 {
    COP [PrintWideString] ( &widestring_0398FC )
    LDA $sceneCurrent
    CMP #$00A2
    BEQ loc_0398C8
    CMP #$00A5
    BEQ func_0398DA

  loc_0398C3:
    COP [PrintWideString] ( &widestring_039925 )
    RTS 

  loc_0398C8:
    COP [BranchIfPlayerInAbsTiles] ( #14, #08, #16, #09, &code_0398D2 )
    BRA loc_0398C3
}

code_0398D2 {
    COP [PrintWideString] ( &widestring_039935 )
    COP [SetFlagByte] ( #01 )
    RTS 
}
---------------------------------------------

func_0398DA {
    COP [BranchIfPlayerInAbsTiles] ( #2E, #12, #30, #13, &code_0398EC )
    COP [BranchIfPlayerInAbsTiles] ( #28, #24, #2A, #25, &code_0398F4 )
    BRA loc_0398C3
}

code_0398EC {
    COP [PrintWideString] ( &widestring_039935 )
    COP [SetFlagByte] ( #01 )
    RTS 
}

code_0398F4 {
    COP [PrintWideString] ( &widestring_039935 )
    COP [SetFlagByte] ( #02 )
    RTS 
}

widestring_0398FC `[DEF]He tries using the water [N]from the mushroom. [FIN]`

widestring_039925 `But nothing happened![END]`

widestring_039935 `He pours the mushroom[N]water on the stems! [END]`
---------------------------------------------

func_03995C {
    COP [PrintWideString] ( &widestring_039961 )
    RTS 
}

widestring_039961 `[DEF]It's the prize money[N]from Russian Glass.[END]`
---------------------------------------------

func_03997F {
    COP [PrintWideString] ( &widestring_039984 )
    RTS 
}

widestring_039984 `[DEF]These are glasses made[N]of black crystal. They[N]can cut out a lot[N]of light...[END]`
---------------------------------------------

func_0399CD {
    LDA $sceneCurrent
    CMP #$00AE
    BNE code_0399ED
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #07, #08, &code_0399F2 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #06, #09, #08, &code_039A01 )
    COP [BranchIfPlayerInAbsTiles] ( #0A, #06, #0B, #08, &code_039A10 )

  code_0399ED:
    COP [PrintWideString] ( &widestring_039A35 )
    RTS 
}

code_0399F2 {
    COP [BranchIfFlagByte] ( #BF, #01, &code_0399ED )
    COP [SetFlagByte] ( #BF )
    COP [PrintWideString] ( &widestring_039A63 )
    BRA loc_039A1F
}

code_039A01 {
    COP [BranchIfFlagByte] ( #C0, #01, &code_0399ED )
    COP [SetFlagByte] ( #C0 )
    COP [PrintWideString] ( &widestring_039A63 )
    BRA loc_039A1F
}

code_039A10 {
    COP [BranchIfFlagByte] ( #C1, #01, &code_0399ED )
    COP [SetFlagByte] ( #C1 )
    COP [PrintWideString] ( &widestring_039A63 )
    BRA loc_039A1F

  loc_039A1F:
    COP [BranchIfFlagByte] ( #BF, #00, &code_039A34 )
    COP [BranchIfFlagByte] ( #C0, #00, &code_039A34 )
    COP [BranchIfFlagByte] ( #C1, #00, &code_039A34 )
    COP [RemoveItem] ( #1D )
}

code_039A34 {
    RTS 
}

widestring_039A35 `[DEF]He stares at the Gorgon [N]Flower, but [N]nothing happens! [END]`

widestring_039A63 `[DEF]He puts one petal of[N]the Gorgon Flower into[N]the statue's mouth. [END]`
---------------------------------------------

func_039AA0 {
    LDA $sceneCurrent
    CMP #$00CD
    BEQ loc_039AB2

  loc_039AA8:
    COP [PrintWideString] ( &widestring_039C8B )
    RTS 
}
---------------------------------------------

func_039AAD {
    COP [PrintWideString] ( &widestring_039C60 )
    RTS 

  loc_039AB2:
    COP [BranchIfFlagByte] ( #0F, #01, &func_039AAD )
    COP [BranchIfPlayerInAbsTiles] ( #04, #09, #0C, #0B, &code_039AC2 )
    BRA loc_039AA8
}

code_039AC2 {
    COP [PrintWideString] ( &widestring_039BA5 )
    COP [DialogueOptions] ( #63, #01, &code_list_039ACC )
}

code_list_039ACC [
  &code_039ADA   ;00
  &code_039ADF   ;01
  &code_039AE7   ;02
  &code_039AEF   ;03
  &code_039AF7   ;04
  &code_039AFF   ;05
  &code_039B07   ;06
]

code_039ADA {
    COP [PrintWideString] ( &widestring_039C89 )
    RTS 
}

code_039ADF {
    LDA #$0000
    STA $0AAC
    BRA loc_039B0F
}

code_039AE7 {
    LDA #$0001
    STA $0AAC
    BRA loc_039B0F
}

code_039AEF {
    LDA #$0002
    STA $0AAC
    BRA loc_039B0F
}

code_039AF7 {
    LDA #$0003
    STA $0AAC
    BRA loc_039B0F
}

code_039AFF {
    LDA #$0004
    STA $0AAC
    BRA loc_039B0F
}

code_039B07 {
    LDA #$0005
    STA $0AAC
    BRA loc_039B0F

  loc_039B0F:
    LDY $inventoryEquippedIndex
    LDA $inventorySlots, Y
    AND #$00FF
    SEC 
    SBC #$001E
    STA $0AA6
    JSR $&sub_039FB2
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_039B70, #00, #00, #$2000 )
    LDA $0AA6
    STA $0024, Y
    LDA $0AAC
    CLC 
    ADC #$0005
    STA $0014, Y
    LDA #$0006
    STA $0016, Y
    PLX 
    LDA $0AAC
    ASL 
    TAY 
    LDA $0B28, Y
    BMI loc_039B65
    CLC 
    ADC #$001E
    PHY 
    JSL $@chunk_03BAE1.func_03EF97
    PLY 
    LDA $0AA6
    STA $0B28, Y
    COP [PrintWideString] ( &widestring_039C19 )
    RTS 

  loc_039B65:
    LDA $0AA6
    STA $0B28, Y
    COP [PrintWideString] ( &widestring_039C39 )
    RTS 
}

code_039B70 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_039B7B )
}

code_list_039B7B [
  &code_039B87   ;00
  &code_039B8C   ;01
  &code_039B91   ;02
  &code_039B96   ;03
  &code_039B9B   ;04
  &code_039BA0   ;05
]

code_039B87 {
    COP [DrawMetatileHere] ( #84 )
    COP [Die]
}

code_039B8C {
    COP [DrawMetatileHere] ( #85 )
    COP [Die]
}

code_039B91 {
    COP [DrawMetatileHere] ( #86 )
    COP [Die]
}

code_039B96 {
    COP [DrawMetatileHere] ( #8C )
    COP [Die]
}

code_039B9B {
    COP [DrawMetatileHere] ( #8D )
    COP [Die]
}

code_039BA0 {
    COP [DrawMetatileHere] ( #8E )
    COP [Die]
}

widestring_039BA5 `[DEF][TPL:0]There are six hollows [N]where a tile can fit. [FIN]Put it where?[N] 1st from L. 4th from L.[N] 2nd from L. 5th from L.[N] 3rd from L. 6th from L.`

widestring_039C19 `[CLR][TPL:0]He exchanges the [N]hieroglyph plate![PAL:0][END]`

widestring_039C39 `[CLR][TPL:0]He puts the hieroglyph [N]plate in the hole![PAL:0][END]`

widestring_039C60 `[DEF][TPL:0]Now is not the time to[N]fit the tile...[PAL:0][END]`

widestring_039C89 `[CLD]`

widestring_039C8B `[DEF]There's no place to put[N]the hieroglyph plate.[PAL:0][END]`
---------------------------------------------

func_039CAF {
    LDA $playerFlags
    BIT #$1000
    BNE loc_039CE0
    BIT #$0100
    BNE loc_039CE0
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE loc_039CE0
    LDA $characterForm
    CMP #$0002
    BNE loc_039CDC
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C557
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C557
    JSR $&sub_03A0A0
    RTS 

  loc_039CDC:
    COP [PrintWideString] ( &widestring_039CE1 )

  loc_039CE0:
    RTS 
}

widestring_039CE1 `[DEF]He holds up the Aura,[N]but nothing happens...[END]`
---------------------------------------------

func_039D09 {
    COP [PrintWideString] ( &widestring_039D0E )
    RTS 
}

widestring_039D0E `[DEF][TPL:3]Have you been OK? [N]Neil told us that he was [N]in Dao, so I'm sending [N]this letter. [FIN]I heard the reason why.[N]Grandpa and I are[N]looking forward to[N]seeing you.[FIN]When we looked in your [N]father's luggage, we [N]found a journal written [N]about the Pyramid. [FIN]I thought it would help[N]you, so I sent it along.[N]Take care.[N]            Bill / Lola[PAL:0][END]`
---------------------------------------------

func_039E15 {
    COP [PrintWideString] ( &widestring_039E1A )
    RTS 
}

widestring_039E1A `[DEF]I've deciphered the[N]hieroglyphs. No one[N]has ever done[N]it before.[FIN]It says there's a key to[N]solving the riddle of[N]human history in[N]the Pyramid.[FIN][ESC:C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,CA,CB][N]The first part says, [N]"The Sun Spirit rises [N]from the horizon.ˮ [FIN]I went to the Pyramid,[N]and found the same[N]inscription. So...[FIN]Here a page is missing.[END]`
---------------------------------------------

func_039F30 {
    COP [PrintWideString] ( &widestring_039F35 )
    RTS 
}

widestring_039F35 `[DEF]This is the Crystal Ring [N]that King Edward  [N]is looking for. [END]`
---------------------------------------------

func_039F5D {
    COP [PrintWideString] ( &widestring_039F6B )
    COP [RemoveItem] ( #28 )
    LDA #$0001
    STA $damageFlashTimer
    RTS 
}

widestring_039F6B `[DEF]When I bite a bright red [N]apple, I feel better. The [N]apple was delicious. [END]`
---------------------------------------------

func_039FB1 {
    RTS 
}
---------------------------------------------

sub_039FB2 {
    LDA $inventoryEquippedIndex
    TAY 
    SEP #$20
    LDA #$00
    STA $inventorySlots, Y
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType
    DEC 
    STA $inventoryEquippedIndex
    RTS 
}
---------------------------------------------

func_039FCA {
    LDA #$0080
    TSB $displayModeFlags
    LDA $musicParentActor
    STA $24
    COP [SpawnAfterFlags] ( @chunk_03BAE1.func_03E1D6, #$2000 )
    CPY #$1FC0
    BNE loc_039FE4
    JMP $&code_03A098

  loc_039FE4:
    TXA 
    TYX 
    TAY 
    LDA $26
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDY $playerActor
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$*player_transition_handlers.loc_00C446
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C446
    JSR $&sub_03A0A0
    LDA #$0800
    TSB $playerFlags
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_03A029
    RTL 

  loc_03A029:
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_03A03B
    RTL 

  loc_03A03B:
    LDY $playerActor
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$*player_transition_handlers.loc_00C455
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C455
    JSR $&sub_03A0A0
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetSavedPtr] ( &code_03A06E )
    LDA $20
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_03A068 )
}

code_list_03A068 [
  &func_038A16   ;00
  &func_038C35   ;01
  &func_038F6F   ;02
]

code_03A06E {
    COP [SpawnAfterFlags] ( @chunk_03BAE1.func_03E1D6, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA $24
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_03A095
    RTL 

  loc_03A095:
    COP [WaitByte] ( #01 )
}

code_03A098 {
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}
---------------------------------------------

sub_03A0A0 {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}