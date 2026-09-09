?BANK 03

?INCLUDE 'binary_01C36C'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'overworld_names'
?INCLUDE 'overworld_options'
?INCLUDE 'overworld_routes'
?INCLUDE 'reward_table'
?INCLUDE 'table_01AD90'
?INCLUDE 'table_01B06E'
?INCLUDE 'table_0EE000'

!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadRaw                      0660
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!scrollOverrideH                06C6
!scrollOverrideV                06CA
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!musicParentActor               06F2
!musicTransitionState           06FA
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!damageFlashTimer               0B22
!INIDISP                        2100
!M7SEL                          211A
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!APUIO1                         2141
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!RDMPYL                         4216
!tileStagingBuffer              7E7000
!sineTableA                     7E8900
!sineTableB                     7E8B00
!mapLayerTilemap                7EA000
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!extendedFlags                  7F002A
!moveScratch2                   7F002E
!adhocVramDma                   7F0C03
!S_sineTableB                   8B00

---------------------------------------------

code_038000 {
    PHP 
    REP #$20
    LDA $slopeCurvePtrB
    BIT #$0200
    BNE loc_038031
    JSL $@chunk_028000.code_02A178
    BCS loc_038031
    LDA $joypadCurrent
    BIT #$1000
    BNE loc_03804D
    LDA $slopeCurvePtrB
    BIT #$2800
    BNE loc_038031
    LDA $joypadCurrent
    BIT #$2000
    BNE loc_038033
    BIT #$4000
    BEQ loc_038031
    JMP $&code_038408

  loc_038031:
    PLP 
    RTL 

  loc_038033:
    LDA #$2000
    TSB $joypadHeld
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_02F944
    JSL $@chunk_028000.code_0282C7
    LDA #$6000
    TSB $joypadHeld
    PLP 
    RTL 

  loc_03804D:
    LDA #$1000
    TSB $joypadHeld
    LDX #$0000
    LDA $slopeCurvePtrB
    BIT #$0008
    BNE loc_038065
    JSR $&code_0380B7
    SEP #$20
    BRA loc_038083

  loc_038065:
    COP [RunBg3Script] ( @01E76A )
    LDA #$8000
    TRB $09FA
    SEP #$20
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    LDA #$09
    STA $INIDISP

  loc_038083:
    LDX #$0000
    PHX 

  loc_038087:
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    JSR $&code_038251
    LDA $0657
    BIT #$10
    BEQ loc_038087
    PLX 
    LDA #$10
    TSB $0659
    JSL $@chunk_028000.code_02FC9A
    LDA #$0F
    STA $INIDISP
    LDA #$01
    TSB $09FA
    JSL $@chunk_008000.code_008122
    PLP 
    RTL 
}

code_0380B7 {
    LDA $7F0C07
    BEQ loc_0380CF
    SEP #$20
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    REP #$20
    BRA code_0380B7

  loc_0380CF:
    LDA #$2800
    STA $adhocVramDma
    LDA #$00C3
    STA $7F0C05
    LDA #$7700
    STA $7F0C07
    LDA #$0200
    STA $7F0C09

  loc_0380EB:
    LDA $7F0C07
    BEQ loc_038103
    SEP #$20
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    REP #$20
    BRA loc_0380EB

  loc_038103:
    JSL $@chunk_028000.code_02FC9A
    PHB 
    LDX #$2A00
    LDY #$0380
    LDA #$057F
    MVN #$7F, #$C3
    PLB 
    LDA $playerSpeedNs
    AND #$00FC
    SEC 
    SBC #$0020
    STA $0018
    CLC 
    ADC #$0044
    STA $001A
    LDA $slopeStepCounter
    AND #$00FC
    SEC 
    SBC #$0020
    STA $001C
    CLC 
    ADC #$0044
    STA $001E
    JSR $&code_038274
    LDA $0002
    AND #$00F0
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_038153
    ORA #$34F0
    STA $7F07CC

  loc_038153:
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
    JSR $&code_038306
    LDA $0AEE
    AND #$00F0
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_0381A5
    ORA #$34F0
    STA $7F060C

  loc_0381A5:
    LDA $0AEE
    AND #$000F
    ORA #$34F0
    STA $7F060E
    LDA #$2AE7
    STA $7F0608
    LDA $sceneCurrent
    JSL $@chunk_008000.code_00B544
    BCS loc_038240
    LDX $sceneCurrent
    LDA $@reward_table, X
    AND #$00FF
    BEQ loc_038240
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
    COP [RunBg3Script] ( @01E775 )

  loc_038240:
    LDA #$32E5
    STA $7F0626
    LDA #$0001
    TSB $09FA
    LDX #$0000
    RTS 
}

code_038251 {
    LDA $0036
    LSR 
    BCS loc_038258
    RTS 

  loc_038258:
    REP #$20
    LDA $03, S
    INC 
    CMP #$001D
    BCC loc_038265
    LDA #$0000

  loc_038265:
    STA $03, S
    ASL 
    TAX 
    LDA $@word_0383CE, X
    STA $7F0A24
    SEP #$20
    RTS 
}

code_038274 {
    PHX 
    STZ $0002
    LDX $0646
    LDA $@table_01AD90, X
    SEC 
    SBC #$AD90
    TAX 
    SEP #$20

  loc_038286:
    LDA $@table_01AD90, X
    BMI loc_038302
    LDA $@table_01AD90+3, X
    REP #$20
    AND #$007F
    JSL $@chunk_008000.code_00B537
    SEP #$20
    BCS loc_0382FC
    LDA $@table_01AD90, X
    CMP $0018
    BMI loc_0382F1
    CMP $001A
    BCS loc_0382F1
    LDA $@table_01AD90+1, X
    CMP $001C
    BMI loc_0382F1
    CMP $001E
    BCS loc_0382F1
    LDA $@table_01AD90, X
    SEC 
    SBC $0018
    LSR 
    AND #$FE
    STA $0000
    STZ $0001
    LDA $@table_01AD90+1, X
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

  loc_0382F1:
    SED 
    LDA $0002
    CLC 
    ADC #$01
    STA $0002
    CLD 

  loc_0382FC:
    INX 
    INX 
    INX 
    INX 
    BRA loc_038286

  loc_038302:
    REP #$20
    PLX 
    RTS 
}

code_038306 {
    LDA $56
    BEQ loc_038326

  loc_03830A:
    TAX 
    LDA $extendedFlags, X
    BIT #$0100
    BEQ loc_038319
    JSR $&code_038327
    BRA loc_038321

  loc_038319:
    BIT #$0200
    BEQ loc_038321
    JSR $&code_038371

  loc_038321:
    LDA $0006, X
    BNE loc_03830A

  loc_038326:
    RTS 
}

code_038327 {
    LDA $0014, X
    CMP $0018
    BMI loc_03836F
    CMP $001A
    BCS loc_03836F
    LDA $0016, X
    CMP $001C
    BMI loc_03836F
    CMP $001E
    BCS loc_03836F
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

  loc_03836F:
    SEC 
    RTS 
}

code_038371 {
    LDA $0014, X
    CMP $cameraOffsetX
    BCC loc_0383CD
    CMP $cameraBoundsX
    BCS loc_0383CD
    CMP $0018
    BMI loc_0383CD
    CMP $001A
    BCS loc_0383CD
    LDA $0016, X
    CMP $cameraOffsetY
    BCC loc_0383CD
    CMP $cameraBoundsY
    BCS loc_0383CD
    CMP $001C
    BMI loc_0383CD
    CMP $001E
    BCS loc_0383CD
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

  loc_0383CD:
    RTS 
}
---------------------------------------------

word_0383CE [
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

code_038408 {
    PEA $&code_038421-1
    LDY $inventoryEquippedIndex
    BPL loc_038413
    JMP $&code_0384B1

  loc_038413:
    LDA $inventorySlots, Y
    AND #$00FF
    AND #$003F
    ASL 
    TAX 
    JMP ($&code_list_038431, X)
}

code_038421 {
    SEP #$20
    JSL $@chunk_008000.code_008122
    REP #$20
    LDA #$4000
    TSB $joypadHeld
    PLP 
    RTL 
}

code_list_038431 [
  &code_0384B1   ;00
  &code_0384CB   ;01
  &code_0385A8   ;02
  &code_038663   ;03
  &code_03873A   ;04
  &code_0387A9   ;05
  &code_03880A   ;06
  &code_03887C   ;07
  &code_0388F4   ;08
  &code_038A90   ;09
  &code_038C1A   ;0A
  &code_038CC1   ;0B
  &code_038D2E   ;0C
  &code_038D9B   ;0D
  &code_038E6C   ;0E
  &code_038F29   ;0F
  &code_038F9B   ;10
  &code_03905B   ;11
  &code_0390C6   ;12
  &code_03914D   ;13
  &code_0391BC   ;14
  &code_039223   ;15
  &code_0392E5   ;16
  &code_03941D   ;17
  &code_039446   ;18
  &code_0395D9   ;19
  &code_03963D   ;1A
  &code_0396DE   ;1B
  &code_0396FE   ;1C
  &code_039738   ;1D
  &code_0397E7   ;1E
  &code_0397E7   ;1F
  &code_0397E7   ;20
  &code_0397E7   ;21
  &code_0397E7   ;22
  &code_0397E7   ;23
  &code_0399C8   ;24
  &code_039A12   ;25
  &code_039B2D   ;26
  &code_039C55   ;27
  &code_039C81   ;28
  &code_039CC6   ;29
  &code_039CC6   ;2A
  &code_039CC6   ;2B
  &code_039CC6   ;2C
  &code_039CC6   ;2D
  &code_039CC6   ;2E
  &code_039CC6   ;2F
  &code_039CC6   ;30
  &code_039CC6   ;31
  &code_039CC6   ;32
  &code_039CC6   ;33
  &code_039CC6   ;34
  &code_039CC6   ;35
  &code_039CC6   ;36
  &code_039CC6   ;37
  &code_039CC6   ;38
  &code_039CC6   ;39
  &code_039CC6   ;3A
  &code_039CC6   ;3B
  &code_039CC6   ;3C
  &code_039CC6   ;3D
  &code_039CC6   ;3E
  &code_039CC6   ;3F
]

code_0384B1 {
    COP [PrintWideString] ( &widestring_0384B6 )
    RTS 
}

widestring_0384B6 `[DEF][DLY:0]持ち物を そうびしていない··[END]`

code_0384CB {
    COP [PrintWideString] ( &widestring_03850D )
    JSR $&code_039CC7
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    PHX 
    PHD 
    LDA $decelStepCounter
    TCD 
    TAX 
    COP [SpawnLastRel] ( @code_03854C, #00, #00, #$2000 )
    TYX 
    LDA #$0000
    STA $0012, X
    LDA #$3000
    STA $000E, X
    LDY $decelStepCounter
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLD 
    PLX 
    RTS 
}

widestring_03850D `[DEF]赤い宝石を かかげた![FIN]赤い宝石は 宝石商ジェムのところへ[N]ーすじの光となって 飛んでいった![END]`

code_03854C {
    COP [SpawnMarkedAfter] ( @code_03855C, #$1002 )
    COP [LoopInit] ( #FF )
    DEC $16
    COP [LoopNext]
    COP [Die]
}

code_03855C {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$0001
    STA $orbitAngle, X
    STA $orbitDiameter, X
    COP [PlaySoundCh2] ( #25 )

  loc_038572:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_038572
    LDA $08
    STZ $08
    STA $26

  loc_03857E:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    COP [SetEntryExit]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$00FF
    BEQ loc_0385A6
    INC 
    STA $orbitDiameter, X
    DEC $26
    BPL loc_03857E
    BRA loc_038572

  loc_0385A6:
    COP [Die]
}

code_0385A8 {
    LDA $sceneCurrent
    CMP #$000B
    BNE loc_038600
    COP [BranchIfPlayerInAbsTiles] ( #0E, #10, #10, #11, &code_0385C2 )
    COP [BranchIfPlayerInAbsTiles] ( #0A, #17, #0C, #18, &code_0385E5 )
    BRA loc_038600
}

code_0385C2 {
    COP [BranchIfFlagByte] ( #24, #01, &code_0385FB )
    COP [PrintWideString] ( &widestring_038605 )
    COP [StageBgChange] ( #06 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0106 )
    COP [SetFlagByte] ( #24 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearLowAbs] ( #0E, #11 )
    COP [ClearLowAbs] ( #0F, #11 )
    RTS 
}

code_0385E5 {
    COP [BranchIfFlagByte] ( #42, #01, &code_0385FB )
    COP [PrintWideString] ( &widestring_038605 )
    COP [SetFlagByte] ( #42 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearHighAbs] ( #09, #17 )
    RTS 
}

code_0385FB {
    COP [PrintWideString] ( &widestring_038651 )
    RTS 

  loc_038600:
    COP [PrintWideString] ( &widestring_038632 )
    RTS 
}

widestring_038605 `[DEF]ろうごくのカギを さしこむと[N]にぶい音とともに 鉄のとびらが[N]開いていった.[END]`

widestring_038632 `[DEF]そこには ろうごくのカギを使う[N]カギ穴がない.[END]`

widestring_038651 `[DEF]とびらは すでに 開いていた.[END]`

code_038663 {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_0386C2
    LDA $slopeStepCounter
    CMP #$0012
    BEQ loc_038678
    CMP #$0013
    BNE loc_0386B5

  loc_038678:
    LDA $playerSpeedNs
    CMP #$0037
    BEQ loc_038685
    CMP #$0038
    BNE loc_0386B5

  loc_038685:
    COP [PrintWideString] ( &widestring_038690 )
    COP [RemoveItem] ( #03 )
    COP [SetFlagByte] ( #30 )
    RTS 
}

widestring_038690 `[DEF]さいだんに インカの像Aを[N]ささげた.[END]`
---------------------------------------------

code_0386A8 {
    LDA $slopeStepCounter
    CMP #$0015
    BEQ loc_0386B5
    CMP #$0016
    BNE loc_0386C2

  loc_0386B5:
    LDA $playerSpeedNs
    CMP #$0026
    BEQ loc_03871A
    CMP #$0027
    BNE loc_0386C2

  loc_0386C2:
    COP [BranchIfFlagByte] ( #44, #00, &code_0386CD )
    COP [PrintWideString] ( &widestring_0386D2 )
    RTS 
}

code_0386CD {
    COP [PrintWideString] ( &widestring_0386F6 )
    RTS 
}

widestring_0386D2 `[DEF]神の息が 届かないところに[N]ささげるとか 言っていたな···[END]`

widestring_0386F6 `[DEF]この像に インカの秘密が[N]かくされて いるのだろうか··?[END]`

loc_03871A {
    COP [PrintWideString] ( &widestring_03871F )
    RTS 
}

widestring_03871F `[DEF]さいだんの形と 像の形が[N]合わないようだ.[END]`

code_03873A {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_038799
    LDA $slopeStepCounter
    CMP #$0015
    BEQ loc_03874F
    CMP #$0016
    BNE loc_03878C

  loc_03874F:
    LDA $playerSpeedNs
    CMP #$0026
    BEQ loc_03875C
    CMP #$0027
    BNE loc_03878C

  loc_03875C:
    COP [PrintWideString] ( &widestring_038767 )
    COP [RemoveItem] ( #04 )
    COP [SetFlagByte] ( #31 )
    RTS 
}

widestring_038767 `[DEF]さいだんに インカの像Bを[N]ささげた.[END]`

widestring_03877F `[AD][B6]ぞ[PAU:12]が[F0]ざ[PAU:13]が[CLR]で`

loc_03878C {
    LDA $playerSpeedNs
    CMP #$0037
    BEQ loc_0387A4
    CMP #$0038
    BNE loc_038799

  loc_038799:
    COP [BranchIfFlagByte] ( #44, #00, &code_0386CD )
    COP [PrintWideString] ( &widestring_0386D2 )
    RTS 

  loc_0387A4:
    COP [PrintWideString] ( &widestring_03871F )
    RTS 
}

code_0387A9 {
    COP [PrintWideString] ( &widestring_0387C2 )
    LDA $sceneCurrent
    CMP #$0018
    BNE loc_0387BD
    COP [SetFlagByte] ( #2E )
    COP [PrintWideString] ( &widestring_0387E6 )
    RTS 

  loc_0387BD:
    COP [PrintWideString] ( &widestring_0387F9 )
    RTS 
}

widestring_0387C2 `[DEF]テムは インカのメロディーを[N]静かに ふきはじめた.[FIN]`

widestring_0387E6 `村長の 表情が 変わった![END]`

widestring_0387F9 `しかし 何も おこらなかった.[END]`

code_03880A {
    COP [PrintWideString] ( &widestring_038831 )
    COP [DialogueOptions] ( #02, #01, &code_list_038814 )
}

code_list_038814 [
  &code_03882C   ;00
  &code_03881A   ;01
  &code_03882C   ;02
]

code_03881A {
    COP [PrintWideString] ( &widestring_03885B )
    LDA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    JSR $&code_039CC7
    RTS 
}

code_03882C {
    COP [PrintWideString] ( &widestring_038849 )
    RTS 
}

widestring_038831 `[DEF]藥草を 食べますか?[N] はい[N] いいえ`

widestring_038849 `[CLR]藥草を 食べるのをやめた.[END]`

widestring_03885B `[CLR]藥草を 口にいれると[N]失われた力がよみがえってきた.[END]`

code_03887C {
    LDA $sceneCurrent
    CMP #$0025
    BNE loc_03889E
    LDA $slopeStepCounter
    CMP #$0019
    BEQ loc_038891
    CMP #$001A
    BNE loc_03889E

  loc_038891:
    LDA $playerSpeedNs
    CMP #$000E
    BEQ loc_0388CD
    CMP #$000F
    BNE loc_03889E

  loc_03889E:
    COP [PrintWideString] ( &widestring_0388A3 )
    RTS 
}

widestring_0388A3 `[DEF]このあたりには ひし型のブロックを[N]はめこむ穴が 見あたらないようだ.[END]`

loc_0388CD {
    COP [PrintWideString] ( &widestring_0388D8 )
    COP [RemoveItem] ( #07 )
    COP [SetFlagByte] ( #2F )
    RTS 
}

widestring_0388D8 `[DEF]タイルに ひし型のブロックを[N]はめこんだ![END]`

code_0388F4 {
    LDA $characterForm
    BNE loc_038941
    JSL $@chunk_028000.code_02A178
    BCC loc_038900
    RTS 

  loc_038900:
    LDA $sceneCurrent
    CMP #$0024
    BNE code_03893C
    COP [BranchIfFlagByte] ( #01, #01, &code_03893C )
    LDA #$0080
    TSB $09FA
    COP [PrintWideString] ( &widestring_038976 )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_039CDF, #00, #00, #$2000 )
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

code_03893C {
    COP [PrintWideString] ( &widestring_0389B9 )
    RTS 

  loc_038941:
    COP [PrintWideString] ( &widestring_038A71 )
    RTS 
}

code_038946 {
    COP [PrintWideString] ( &widestring_038A81 )
    RTS 
}
---------------------------------------------

widestring_03894B `[DEF]笛を 吹きますか?[N] はい[N] いいえ`
---------------------------------------------

code_038961 {
    COP [SetFlagByte] ( #01 )
    COP [PrintWideString] ( &widestring_038990 )
    COP [SpawnThinkerParam] ( #2F, @chunk_008000.code_00B5CD )
    COP [RestoreSavedPtr]

  loc_038970:
    COP [PrintWideString] ( &widestring_0389E4 )
    COP [RestoreSavedPtr]
}

widestring_038976 `[DEF]風のメロディーを[N]静かに ふきはじめた.[END]`

widestring_038990 `[DEF][CLR]笛の音が あたりに こだまし[N]黄金のブロックが 光りはじめた![END]`

widestring_0389B9 `[DEF]風のメロディーを[N]静かに ふきはじめた.[FIN]しかし 何も おこらなかった.[END]`

widestring_0389E4 `[DEF][CLR]メロディが 体に しみわたり[N]不思議な言葉が 頭にうかんでくる.[FIN]ユカー面に 黄金のしきつめられた[N]部屋にて われを となえ[N]かがやける場所にて しばしの間[N]めいそうせよ.[FIN]その者にこそ 自由の海原への道が[N]開かれる···[END]`

widestring_038A71 `[DEF][CLR]笛を もっていない···[END]`

widestring_038A81 `[CLR]笛を 吹くのをやめた.[END]`

code_038A90 {
    LDA $characterForm
    BNE loc_038B0B
    JSL $@chunk_028000.code_02A178
    BCC loc_038A9C
    RTS 

  loc_038A9C:
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038ABF
    CMP #$0011
    BEQ loc_038AB0
    CMP #$00CD
    BEQ loc_038AC7
    BRA code_038B06

  loc_038AB0:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038B06 )
    COP [BranchIfFlagByte] ( #02, #01, &code_038B06 )
    BRA loc_038AD8

  loc_038ABF:
    COP [BranchIfFlagByte] ( #40, #01, &code_038B06 )
    BRA loc_038AD8

  loc_038AC7:
    COP [BranchIfFlagByte] ( #BB, #01, &code_038B06 )
    COP [BranchIfFlagByte] ( #0E, #00, &code_038B06 )
    COP [SetFlagByte] ( #0D )
    BRA loc_038AD8

  loc_038AD8:
    LDA #$0080
    TSB $09FA
    COP [PrintWideString] ( &widestring_038B51 )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_039CDF, #00, #00, #$2000 )
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

code_038B06 {
    COP [PrintWideString] ( &widestring_038B99 )
    RTS 

  loc_038B0B:
    COP [PrintWideString] ( &widestring_038E06 )
    RTS 
}

code_038B10 {
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038B24
    CMP #$0011
    BEQ loc_038B33
    CMP #$00CD
    BEQ code_038B43
    BRA code_038B4B

  loc_038B24:
    COP [BranchIfFlagByte] ( #40, #01, &code_038B43 )
    COP [SetFlagByte] ( #40 )
    COP [PrintWideString] ( &widestring_038B75 )
    COP [RestoreSavedPtr]

  loc_038B33:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038B4B )
    COP [SetFlagByte] ( #02 )
    COP [PrintWideString] ( &widestring_038BD0 )
    COP [RestoreSavedPtr]
}

code_038B43 {
    COP [SetFlagByte] ( #01 )
    COP [ClearFlagByte] ( #0E )
    COP [RestoreSavedPtr]
}

code_038B4B {
    COP [PrintWideString] ( &widestring_038BBD )
    COP [RestoreSavedPtr]
}

widestring_038B51 `[DEF]ローラから 教わった[N]メロディーを 静かにふきはじめた.[END]`

widestring_038B75 `[DEF][CLR]メロディーは 風にのって[N]草原中に ひろがっていった.[END]`

widestring_038B99 `[DEF]ローラから 教わった[N]メロディーを 静かにふきはじめた.[FIN]`

widestring_038BBD `[DEF][CLR]しかし 何も おこらなかった.[END]`

widestring_038BD0 `[DEF][CLR]すると どこからともなく[N]声が 聞こえてきた···[FIN][TPL:2]不思議な声:[N]右側にある スイッチの前へ[N]いってちょうだい.[PAL:0][END]`

code_038C1A {
    LDA $sceneCurrent
    CMP #$002F
    BNE code_038C33
    COP [BranchIfFlagByte] ( #02, #00, &code_038C33 )
    COP [RemoveItem] ( #0A )
    COP [PrintWideString] ( &widestring_038C8B )
    COP [SetFlagByte] ( #03 )
    RTS 
}

code_038C33 {
    COP [PrintWideString] ( &widestring_038C38 )
    RTS 
}

widestring_038C38 `[DEF]骨つきの くんせい肉を[N]ちょっぴり かじってみた.[FIN]それは 今まで 食べたことの[N]ないような 不思議な味がした.[N]いったい 何の肉だろう···[END]`

widestring_038C8B `[DEF]ぼくらは 骨つきの肉に[N]かぶりついた.[FIN]今まで 食べたどんな 食べ物より[N]おいしく感じた.[END]`

code_038CC1 {
    COP [PrintWideString] ( &widestring_038CE5 )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038CD5
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038CDA )

  loc_038CD5:
    COP [PrintWideString] ( &widestring_038D00 )
    RTS 
}

code_038CDA {
    COP [PrintWideString] ( &widestring_038D14 )
    COP [RemoveItem] ( #0B )
    COP [SetFlagByte] ( #5B )
    RTS 
}

widestring_038CE5 `[DEF]こうざんのカギを 使ってみる[N]ことにした.[FIN]`

widestring_038D00 `しかし そこには カギ穴がない![END]`

widestring_038D14 `カギが 不気味な音をたてて[N]まわった.[END]`

code_038D2E {
    COP [PrintWideString] ( &widestring_038D52 )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038D42
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038D47 )

  loc_038D42:
    COP [PrintWideString] ( &widestring_038D6D )
    RTS 
}

code_038D47 {
    COP [PrintWideString] ( &widestring_038D81 )
    COP [RemoveItem] ( #0C )
    COP [SetFlagByte] ( #5C )
    RTS 
}

widestring_038D52 `[DEF]こうざんのカギを 使ってみる[N]ことにした.[FIN]`

widestring_038D6D `しかし そこには カギ穴がない![END]`

widestring_038D81 `カギが 不気味な音をたてて[N]まわった.[END]`

code_038D9B {
    LDA $characterForm
    BEQ loc_038DA5
    COP [PrintWideString] ( &widestring_038E06 )
    RTS 

  loc_038DA5:
    LDA $sceneCurrent
    CMP #$0039
    BEQ loc_038DAF
    BRA code_038E01

  loc_038DAF:
    COP [BranchIfFlagByte] ( #68, #01, &code_038E01 )
    COP [BranchIfPlayerInAbsTiles] ( #13, #18, #1A, #1D, &code_038DBF )
    BRA code_038E01
}

code_038DBF {
    LDA #$0080
    TSB $09FA
    COP [PrintWideString] ( &widestring_038E49 )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_039CDF, #00, #00, #$2000 )
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

code_038DF3 {
    COP [RemoveItem] ( #0D )
    COP [SpawnThinkerParam] ( #1B, @chunk_008000.code_00B5C4 )
    COP [SetFlagByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_038E01 {
    COP [PrintWideString] ( &widestring_038E15 )
    RTS 
}

widestring_038E06 `[DEF]笛を もっていない···[END]`

widestring_038E15 `[DEF]テムは 思い出のメロディを[N]静かに ふきはじめた.[FIN]しかし 何もおこらなかった···[END]`

widestring_038E49 `[DEF][CLR]テムは 思い出のメロディを[N]静かに ふきはじめた.[END]`

code_038E6C {
    LDA $sceneCurrent
    CMP #$004C
    BNE loc_038E94
    COP [BranchIfPlayerInAbsTiles] ( #16, #0C, #18, #0F, &code_038E99 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #10, #18, #13, &code_038EA4 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0A, #0B, #0D, &code_038EAF )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0E, #0B, #11, &code_038EBA )

  loc_038E94:
    COP [PrintWideString] ( &widestring_038ED0 )
    RTS 
}

code_038E99 {
    COP [BranchIfFlagByte] ( #60, #01, &code_038ECB )
    COP [SetFlagByte] ( #60 )
    BRA loc_038EC3
}

code_038EA4 {
    COP [BranchIfFlagByte] ( #61, #01, &code_038ECB )
    COP [SetFlagByte] ( #61 )
    BRA loc_038EC3
}

code_038EAF {
    COP [BranchIfFlagByte] ( #62, #01, &code_038ECB )
    COP [SetFlagByte] ( #62 )
    BRA loc_038EC3
}

code_038EBA {
    COP [BranchIfFlagByte] ( #63, #01, &code_038ECB )
    COP [SetFlagByte] ( #63 )

  loc_038EC3:
    COP [PrintWideString] ( &widestring_038EF2 )
    JSR $&code_039CC7
    RTS 
}

code_038ECB {
    COP [PrintWideString] ( &widestring_038F0A )
    RTS 
}

widestring_038ED0 `[DEF]クリスタルボールを かかげたが[N]何も おこらなかった···[END]`

widestring_038EF2 `[DEF]クリスタルボールを 穴に[N]はめこんだ![END]`

widestring_038F0A `[DEF]クリスタルボールは すでに 穴に[N]はめこまれている![END]`

code_038F29 {
    COP [PrintWideString] ( &widestring_038F4D )
    LDA $sceneCurrent
    CMP #$003F
    BNE loc_038F3D
    COP [BranchIfPlayerInAbsTiles] ( #18, #34, #1A, #37, &code_038F42 )

  loc_038F3D:
    COP [PrintWideString] ( &widestring_038F6D )
    RTS 
}

code_038F42 {
    COP [PrintWideString] ( &widestring_038F81 )
    COP [RemoveItem] ( #0F )
    COP [SetFlagByte] ( #69 )
    RTS 
}

widestring_038F4D `[DEF]リフトのり場のカギを 使ってみる[N]ことにした.[FIN]`

widestring_038F6D `しかし そこには カギ穴がない![END]`

widestring_038F81 `カギが 不気味な音をたてて[N]まわった.[END]`

code_038F9B {
    COP [PrintWideString] ( &widestring_038FD0 )
    LDA $sceneCurrent
    CMP #$005A
    BNE code_038FAF
    COP [BranchIfPlayerInAbsTiles] ( #08, #07, #0A, #08, &code_038FB4 )

  code_038FAF:
    COP [PrintWideString] ( &widestring_038FEC )
    RTS 
}

code_038FB4 {
    COP [BranchIfFlagWord] ( #$0138, #01, &code_038FAF )
    COP [PrintWideString] ( &widestring_039000 )
    COP [RemoveItem] ( #10 )
    COP [StageBgChange] ( #38 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0138 )
    COP [PrintWideString] ( &widestring_03901A )
    RTS 
}

widestring_038FD0 `[DEF]きゅうでんのカギを 使ってみる[N]ことにした.[FIN]`

widestring_038FEC `しかし そこには カギ穴がない![END]`

widestring_039000 `カギが 不気味な音をたてて[N]まわった.`

widestring_03901A `[CLR][TPL:0]ポケットのリリィが[N]話しかけてきた.[FIN][TPL:2]この先に まぼろしの大陸 ムーが[N]広がっているんだね.[PAL:0][END]`

code_03905B {
    COP [PrintWideString] ( &widestring_039081 )
    LDA $sceneCurrent
    CMP #$005D
    BNE loc_03907C
    COP [BranchIfPlayerInAbsTiles] ( #0A, #11, #17, #1A, &code_039071 )
    BRA loc_03907C
}

code_039071 {
    COP [RemoveItem] ( #11 )
    COP [PrintWideString] ( &widestring_0390A2 )
    COP [SetFlagByte] ( #0E )
    RTS 

  loc_03907C:
    COP [PrintWideString] ( &widestring_039091 )
    RTS 
}

widestring_039081 `[DEF]じょうか石を かかげた![FIN]`

widestring_039091 `しかし 何も おこらなかった![END]`

widestring_0390A2 `石は しだいに かがやきをまし[N]泉の中へと 消えていった···[END]`

code_0390C6 {
    COP [PrintWideString] ( &widestring_03910B )
    LDA $sceneCurrent
    CMP #$0063
    BNE code_039106
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #0A, #08, &code_0390F5 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #06, #1A, #08, &code_0390E4 )
    BRA code_039106
}

code_0390E4 {
    COP [BranchIfFlagByte] ( #7E, #01, &code_039106 )
    JSR $&code_039CC7
    COP [PrintWideString] ( &widestring_03912E )
    COP [SetFlagByte] ( #7E )
    RTS 
}

code_0390F5 {
    COP [BranchIfFlagByte] ( #7B, #01, &code_039106 )
    JSR $&code_039CC7
    COP [PrintWideString] ( &widestring_03912E )
    COP [SetFlagByte] ( #7B )
    RTS 
}

code_039106 {
    COP [PrintWideString] ( &widestring_03911D )
    RTS 
}

widestring_03910B `[DEF]いのりの石像を ささげた![FIN]`

widestring_03911D `しかし 何も おこらなかった![END]`

widestring_03912E `どこからか 低く 不気味な声が[N]きこえてきた···[END]`

code_03914D {
    COP [PrintWideString] ( &widestring_039192 )
    LDA $sceneCurrent
    CMP #$0066
    BNE code_03918D
    COP [BranchIfPlayerInAbsTiles] ( #23, #08, #26, #0A, &code_03916B )
    COP [BranchIfPlayerInAbsTiles] ( #2A, #08, #2D, #0A, &code_03917C )
    BRA code_03918D
}

code_03916B {
    COP [BranchIfFlagByte] ( #80, #01, &code_03918D )
    JSR $&code_039CC7
    COP [PrintWideString] ( &widestring_0391BA )
    COP [SetFlagByte] ( #80 )
    RTS 
}

code_03917C {
    COP [BranchIfFlagByte] ( #81, #01, &code_03918D )
    JSR $&code_039CC7
    COP [PrintWideString] ( &widestring_0391BA )
    COP [SetFlagByte] ( #81 )
    RTS 
}

code_03918D {
    COP [PrintWideString] ( &widestring_0391A9 )
    RTS 
}

widestring_039192 `[DEF]ラ·ムーの石像を ささげた![FIN]`

widestring_0391A9 `しかし 何も おこらなかった![END]`

widestring_0391BA `[CLD]`

code_0391BC {
    COP [PrintWideString] ( &widestring_0391E0 )
    LDA $sceneCurrent
    CMP #$0074
    BNE loc_0391D0
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #0A, &code_0391D5 )

  loc_0391D0:
    COP [PrintWideString] ( &widestring_0391F8 )
    RTS 
}

code_0391D5 {
    COP [PrintWideString] ( &widestring_039209 )
    COP [RemoveItem] ( #14 )
    COP [SetFlagByte] ( #01 )
    RTS 
}

widestring_0391E0 `[DEF]まほうのこなを 使ってみる[N]ことにした.[FIN]`

widestring_0391F8 `しかし 何も おこらなかった![END]`

widestring_039209 `カレンの 絵に まほうのこなを[N]ふりかけた![END]`

code_039223 {
    COP [PrintWideString] ( &widestring_039249 )
    COP [DialogueOptions] ( #03, #01, &code_list_03922D )
}

code_list_03922D [
  &code_039235   ;00
  &code_03923A   ;01
  &code_03923F   ;02
  &code_039244   ;03
]

code_039235 {
    COP [PrintWideString] ( &widestring_0392A7 )
    RTS 
}

code_03923A {
    COP [PrintWideString] ( &widestring_0392B8 )
    RTS 
}

code_03923F {
    COP [PrintWideString] ( &widestring_0392C6 )
    RTS 
}

code_039244 {
    COP [PrintWideString] ( &widestring_0392D6 )
    RTS 
}

widestring_039249 `[DEF]ロブの父親の 手帳を そっと[N]開いてみた.[FIN][DLY:0]どのページを 読みますか?[N] バベルの塔について[N] ミステリードールについて[N] 万里の長城について`

widestring_0392A7 `[DEF]手帳を そっと 閉じた.[END]`

widestring_0392B8 `[DEF]バベルの塔は···[END]`

widestring_0392C6 `[DEF]ミステリードールは···[END]`

widestring_0392D6 `[DEF]万里の長城は···[END]`

code_0392E5 {
    COP [SetFlagByte] ( #8E )
    COP [PrintWideString] ( &widestring_0392ED )
    RTS 
}

widestring_0392ED `[DEF]ロブの手紙を 開いた.[FIN][TPL:4]ロブ:[N]おれは ちょっと 万里の長城まで[N]行ってくる.[FIN]みんなには ないしょのつもりだった[N]けど テムにだけは 伝えておこうと[N]思う···[FIN]テムの荷物の中に この手紙を[N]入れとくけど 気づいてくれたかな.[N]テムは にぶいからな.[FIN]町の人の話から おやじの病気を[N]直す方法が わかったんだ···[N]万里の長城に その藥があるらしい.[FIN]道のりは 長いけど マラソンでも[N]するつもりで 行ってくるよ.[N]心配しないでくれ.[FIN]追しん:[N]あ そうそう···[N]リリィに ふられちまったよ.[PAL:0][END]`

code_03941D {
    COP [PrintWideString] ( &widestring_039422 )
    RTS 
}

widestring_039422 `[DEF]ロブが リリィのために 作っていた[N]ネックレスだ···[END]`

code_039446 {
    COP [PrintWideString] ( &widestring_03944B )
    RTS 
}

widestring_03944B `[DEF]遺書を そっと開いてみた.[FIN][N]      対戦者の人へ     [FIN]私が死んでも 悲しまないでほしい.[N]そして 落ちこまないでほしい.[FIN]私は ロシアングラスで 死なずとも[N]近いうちに 天にめされる 運命で[N]あったのだ.[FIN]半年前に 不治の病と診断された時[N]死ぬまでに 人がー生働いて得る金を[N]手に入れようと思った.[FIN]私の死後 妻と まだ見ぬ子に[N]苦労はさせまいと 思ったからだ.[FIN]しかし 私が得た金は[N]他人を不幸にして 手に入れたもの.[N]こんなことは 今回で 終わりに[N]しようと思う···[FIN]もし この勝負で 私が負けたなら[N]財産のー部を 勇気ある あなたに[N]分けあたえたい.[FIN]私の愛馬 クルック 4頭を どうか[N]かわいがって やって下さい.[END]`

code_0395D9 {
    COP [PrintWideString] ( &widestring_0395FD )
    LDA $sceneCurrent
    CMP #$0095
    BNE loc_0395ED
    COP [BranchIfPlayerInAbsTiles] ( #28, #09, #2D, #0D, &code_0395F2 )

  loc_0395ED:
    COP [PrintWideString] ( &widestring_039617 )
    RTS 
}

code_0395F2 {
    COP [PrintWideString] ( &widestring_039628 )
    COP [RemoveItem] ( #19 )
    COP [SetFlagByte] ( #A8 )
    RTS 
}

widestring_0395FD `[DEF]ティアポットを 使ってみる[N]ことにした.[FIN]`

widestring_039617 `しかし 何も おこらなかった![END]`

widestring_039628 `神のなみだが あたりに[N]ふりそそいだ![END]`

code_03963D {
    COP [PrintWideString] ( &widestring_039690 )
    LDA $sceneCurrent
    CMP #$00A2
    BEQ loc_039653
    CMP #$00A5
    BEQ loc_039668

  loc_03964E:
    COP [PrintWideString] ( &widestring_0396AB )
    RTS 

  loc_039653:
    COP [BranchIfPlayerInAbsTiles] ( #14, #08, #16, #09, &code_03965D )
    BRA loc_03964E
}

code_03965D {
    COP [PrintWideString] ( &widestring_0396BC )
    JSR $&code_039CC7
    COP [SetFlagByte] ( #01 )
    RTS 

  loc_039668:
    COP [BranchIfPlayerInAbsTiles] ( #2E, #12, #30, #13, &code_03967A )
    COP [BranchIfPlayerInAbsTiles] ( #28, #24, #2A, #25, &code_039685 )
    BRA loc_03964E
}

code_03967A {
    COP [PrintWideString] ( &widestring_0396BC )
    JSR $&code_039CC7
    COP [SetFlagByte] ( #01 )
    RTS 
}

code_039685 {
    COP [PrintWideString] ( &widestring_0396BC )
    JSR $&code_039CC7
    COP [SetFlagByte] ( #02 )
    RTS 
}

widestring_039690 `[DEF]キノコのしずくを 使ってみる[N]ことにした.[FIN]`

widestring_0396AB `しかし 何も おこらなかった![END]`

widestring_0396BC `クキの とぎれた場所に[N]キノコの しずくを そそいだ![END]`

code_0396DE {
    COP [PrintWideString] ( &widestring_0396E3 )
    RTS 
}

widestring_0396E3 `[DEF]ロシアングラスの賞金でもらった[N]きんかだ.[END]`

code_0396FE {
    COP [PrintWideString] ( &widestring_039703 )
    RTS 
}

widestring_039703 `[DEF]黒い すいしょうで 作られた[N]めがねだ.[N]これなら かなりの光も しゃだん[N]できそうだな···.[END]`

code_039738 {
    LDA $sceneCurrent
    CMP #$00AE
    BNE code_039758
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #07, #08, &code_03975D )
    COP [BranchIfPlayerInAbsTiles] ( #08, #06, #09, #08, &code_03976C )
    COP [BranchIfPlayerInAbsTiles] ( #0A, #06, #0B, #08, &code_03977B )

  code_039758:
    COP [PrintWideString] ( &widestring_0397A0 )
    RTS 
}

code_03975D {
    COP [BranchIfFlagByte] ( #BF, #01, &code_039758 )
    COP [SetFlagByte] ( #BF )
    COP [PrintWideString] ( &widestring_0397C5 )
    BRA loc_03978A
}

code_03976C {
    COP [BranchIfFlagByte] ( #C0, #01, &code_039758 )
    COP [SetFlagByte] ( #C0 )
    COP [PrintWideString] ( &widestring_0397C5 )
    BRA loc_03978A
}

code_03977B {
    COP [BranchIfFlagByte] ( #C1, #01, &code_039758 )
    COP [SetFlagByte] ( #C1 )
    COP [PrintWideString] ( &widestring_0397C5 )
    BRA loc_03978A

  loc_03978A:
    COP [BranchIfFlagByte] ( #BF, #00, &code_03979F )
    COP [BranchIfFlagByte] ( #C0, #00, &code_03979F )
    COP [BranchIfFlagByte] ( #C1, #00, &code_03979F )
    COP [RemoveItem] ( #1D )
}

code_03979F {
    RTS 
}

widestring_0397A0 `[DEF]ゴーゴンの花を ながめた···[N]しかし 何も おこらなかった![END]`

widestring_0397C5 `[DEF]ゴーゴンの花びらを ー枚[N]石像の口に 入れた![END]`

code_0397E7 {
    LDA $sceneCurrent
    CMP #$00CD
    BEQ loc_0397F9
    COP [PrintWideString] ( &widestring_0399A9 )
    RTS 
}

code_0397F4 {
    COP [PrintWideString] ( &widestring_039985 )
    RTS 

  loc_0397F9:
    COP [BranchIfFlagByte] ( #0F, #01, &code_0397F4 )
    COP [PrintWideString] ( &widestring_0398E2 )
    COP [DialogueOptions] ( #63, #01, &code_list_039809 )
}

code_list_039809 [
  &code_039817   ;00
  &code_03981C   ;01
  &code_039824   ;02
  &code_03982C   ;03
  &code_039834   ;04
  &code_03983C   ;05
  &code_039844   ;06
]

code_039817 {
    COP [PrintWideString] ( &widestring_0399A7 )
    RTS 
}

code_03981C {
    LDA #$0000
    STA $0AAC
    BRA loc_03984C
}

code_039824 {
    LDA #$0001
    STA $0AAC
    BRA loc_03984C
}

code_03982C {
    LDA #$0002
    STA $0AAC
    BRA loc_03984C
}

code_039834 {
    LDA #$0003
    STA $0AAC
    BRA loc_03984C
}

code_03983C {
    LDA #$0004
    STA $0AAC
    BRA loc_03984C
}

code_039844 {
    LDA #$0005
    STA $0AAC
    BRA loc_03984C

  loc_03984C:
    LDY $inventoryEquippedIndex
    LDA $inventorySlots, Y
    AND #$00FF
    SEC 
    SBC #$001E
    STA $0AA6
    JSR $&code_039CC7
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_0398AD, #00, #00, #$2000 )
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
    BMI loc_0398A2
    CLC 
    ADC #$001E
    PHY 
    JSL $@chunk_3B7DD.code_03E458
    PLY 
    LDA $0AA6
    STA $0B28, Y
    COP [PrintWideString] ( &widestring_039952 )
    RTS 

  loc_0398A2:
    LDA $0AA6
    STA $0B28, Y
    COP [PrintWideString] ( &widestring_03996B )
    RTS 
}

code_0398AD {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0398B8 )
}

code_list_0398B8 [
  &code_0398C4   ;00
  &code_0398C9   ;01
  &code_0398CE   ;02
  &code_0398D3   ;03
  &code_0398D8   ;04
  &code_0398DD   ;05
]

code_0398C4 {
    COP [DrawMetatileHere] ( #84 )
    COP [Die]
}

code_0398C9 {
    COP [DrawMetatileHere] ( #85 )
    COP [Die]
}

code_0398CE {
    COP [DrawMetatileHere] ( #86 )
    COP [Die]
}

code_0398D3 {
    COP [DrawMetatileHere] ( #8C )
    COP [Die]
}

code_0398D8 {
    COP [DrawMetatileHere] ( #8D )
    COP [Die]
}

code_0398DD {
    COP [DrawMetatileHere] ( #8E )
    COP [Die]
}

widestring_0398E2 `[DEF][TPL:0][DLY:0]タイルが はまりそうな くぼみが[N]6つ ならんでいる.[FIN]どこに はめますか?[N] 左から1番目  左から4番目[N] 左から2番目  左から5番目[N] 左から3番目  左から6番目`

widestring_039952 `[CLR][TPL:0]ヒエログリフ板を こうかんした![PAL:0][END]`

widestring_03996B `[CLR][TPL:0]ヒエログリフ板を くぼみにはめた![PAL:0][END]`

widestring_039985 `[DEF][TPL:0]今は タイルを はめている[N]場合じゃない···[PAL:0][END]`

widestring_0399A7 `[CLD]`

widestring_0399A9 `[DEF]ヒエログリフ板を はめこむ場所が[N]ない···[PAL:0][END]`

code_0399C8 {
    LDA $slopeCurvePtrB
    BIT #$1000
    BNE loc_0399F1
    BIT #$0100
    BNE loc_0399F1
    LDA $characterForm
    CMP #$0002
    BNE loc_0399ED
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C699
    JSR $&code_039DB5
    RTS 

  loc_0399ED:
    COP [PrintWideString] ( &widestring_0399F2 )

  loc_0399F1:
    RTS 
}

widestring_0399F2 `[DEF]オーラの玉を かかげたが[N]何も おこらなかった···[END]`

code_039A12 {
    COP [PrintWideString] ( &widestring_039A17 )
    RTS 
}

widestring_039A17 `[DEF][TPL:3]元気で やっていますか?[N]ニールから 連らくを受け ダオに[N]いるらしい とのことなので[N]手紙を 出してみました.[FIN]わけは だいたい 聞きましたよ.[N]お前が ひとまわり 成長して[N]帰ってくるのを おじいさんと[N]楽しみにしています.[FIN]そうそう.[N]お前の父 オールマンの荷物を[N]調べていたら ピラミッドのことが[N]書かれた手帳が でてきたの.[FIN]何かの 役にたつかも しれないので[N]いっしょに 送ることにします.[N]では くれぐれも 体に気をつけて.[N]          ビル/ローラ[PAL:0][END]`

code_039B2D {
    COP [PrintWideString] ( &widestring_039B32 )
    RTS 
}

widestring_039B32 `[DEF]私は 古代文字 ヒエログリフの[N]解読に ついに 成功した.[N]これは おそらく 世界で 初めての[N]ことであろう.[FIN]この もくしろくによれば[N]ピラミッドには 人類の歷史の[N]とてつもない なぞをとくカギが[N]かくされていることになるのだ.[FIN]     ΓΔΘΛΨΩ     [N]この ヒエログリフは 冒頭のー文で[N]┌太陽神が 地平線よりのぼる┘[N]という 意味をもつ.[FIN]私は ピラミッドへ 足を運び[N]これと 同じ文字板を 発見した.[N]そして···[FIN]ページは ここで やぶられている.[END]`

code_039C55 {
    COP [PrintWideString] ( &widestring_039C5A )
    RTS 
}

widestring_039C5A `[DEF]これこそ エドワード国王が[N]さがしていた すいしょうの指輪だ.[END]`

code_039C81 {
    COP [PrintWideString] ( &widestring_039C8F )
    COP [RemoveItem] ( #28 )
    LDA #$0001
    STA $damageFlashTimer
    RTS 
}

widestring_039C8F `[DEF]真っ赤なリンゴを ほおばると[N]気持ちが ちょっぴり 安らいだ.[N]おいしい リンゴだった.[END]`

code_039CC6 {
    RTS 
}

code_039CC7 {
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

code_039CDF {
    LDA #$0080
    TSB $09FA
    LDA $musicParentActor
    STA $24
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
    CPY #$1FC0
    BNE loc_039CF9
    JMP $&code_039DAD

  loc_039CF9:
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
    LDY $decelStepCounter
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$0080
    STA $0002, Y
    LDA #$C58E
    JSR $&code_039DB5
    LDA #$0800
    TSB $slopeCurvePtrB
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_039D3E
    RTL 

  loc_039D3E:
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_039D50
    RTL 

  loc_039D50:
    LDY $decelStepCounter
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$0080
    STA $0002, Y
    LDA #$C59D
    JSR $&code_039DB5
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetSavedPtr] ( &code_039D83 )
    LDA $20
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_039D7D )
}

code_list_039D7D [
  &code_038961   ;00
  &code_038B10   ;01
  &code_038DF3   ;02
]

code_039D83 {
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
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
    BEQ loc_039DAA
    RTL 

  loc_039DAA:
    COP [WaitByte] ( #01 )
}

code_039DAD {
    LDA #$0080
    TRB $09FA
    COP [Die]
}

code_039DB5 {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

actor_def_039DBF [
  actor-def < #00, #00, #18, {

  code_039DC2:
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    STZ $M7SEL
    LDA #$01
    STA $TS
    STA $CGADSUB
    LDA #$82
    STA $CGWSEL
    REP #$20
    COP [SpawnThinker] ( @code_03A6CD )
    PHX 
    TYX 
    LDA #$0804
    STA $animScratch2, X
    PLX 
    COP [SpawnBefore] ( @code_039E35 )
    LDA $cameraTargetX
    CLC 
    ADC #$0080
    STA $14
    COP [StageSprAndHitbox] ( #04 )

  loc_039DFC:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CLC 
    ADC #$00B4
    STA $16
    COP [BranchIfFlagByte] ( #01, #01, &code_039E1E )
    DEC $24
    BMI loc_039E1C
    RTL 

  loc_039E1C:
    BRA loc_039DFC
} >
]

code_039E1E {
    COP [SetEntryExit]
    COP [LoopInit] ( #1E )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $cameraTargetY
    CLC 
    ADC #$00B4
    STA $16
    COP [LoopNext]
    COP [SetEntryContinue]
    RTL 
}

code_039E35 {
    LDA #$0800
    TSB $10
    LDA #$0258
    STA $24
    LDA $cameraTargetX
    CLC 
    ADC #$0080
    STA $00CA
    LDA #$0200
    STA $00B6
    LDA #$0032
    STA $00B8
    STZ $00BC
    COP [SetEntryContinue]
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    DEC $24
    BMI loc_039E73
    RTL 

  loc_039E73:
    COP [SetFlagByte] ( #01 )
    COP [LoopInit] ( #3C )
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    COP [LoopNext]
    COP [SpawnAfterFlags] ( @code_039EFE, #$2000 )
    COP [InitGravity] ( #00, #05, #00 )
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    CMP #$0500
    BCS loc_039EC4
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 

  loc_039EC4:
    LDA #$0001
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #80, #$1100 )
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 
}

code_039EFE {
    COP [LoopInit] ( #06 )
    COP [RngByte]
    AND #$001C
    STA $08
    COP [PlaySoundCh1] ( #15 )
    COP [LoopNext]
    COP [Die]
}

actor_def_039F0F [
  actor-def < #00, #00, #18, {

  code_039F12:
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    STZ $M7SEL
    LDA #$01
    STA $TM
    STA $CGADSUB
    LDA #$82
    STA $CGWSEL
    REP #$20
    COP [SpawnThinker] ( @code_03A6CD )
    PHX 
    TYX 
    LDA #$0804
    STA $animScratch2, X
    PLX 
    COP [SpawnBefore] ( @code_039F43 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_039F43 {
    LDA #$0800
    TSB $10
    LDA #$0170
    STA $cameraTargetX
    LDA #$01D0
    STA $cameraTargetY
    LDA #$01F0
    STA $00CA
    LDA #$0250
    STA $00CC
    LDA #$001C
    STA $00B8
    LDA #$0130
    STA $00BC
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    COP [SetEntryContinue]
    INC $00BC
    LDA $0036
    AND #$0001
    BEQ loc_039F7F
    RTL 

  loc_039F7F:
    LDA $00B8
    CMP #$0080
    BEQ loc_039F8C
    INC 
    STA $00B8
    RTL 

  loc_039F8C:
    COP [SetEntryContinue]
    LDA $00BC
    AND #$01FF
    BEQ loc_039F9A
    INC $00BC
    RTL 

  loc_039F9A:
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    LDA $00B8
    CMP #$0060
    BEQ loc_039FBB
    DEC 
    STA $00B8
    INC $00B6
    INC $cameraTargetY
    INC $cameraTargetY
    INC $00CC
    INC $00CC
    RTL 

  loc_039FBB:
    COP [LoopInit] ( #FF )
    DEC $cameraTargetY
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    DEC $cameraTargetY
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #7F )
    DEC $cameraTargetY
    DEC $00CC
    LDA $loopCounter, X
    AND #$0078
    LSR 
    LSR 
    LSR 
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [LoopNext]
    COP [QueueMapChange] ( #BF, #$00F8, #$00C0, #00, #$2200 )
    LDA #$0001
    STA $gfxCacheIdxA
    LDA #$0400
    STA $gfxCacheIdxB
    COP [SetEntryContinue]
    RTL 
}

actor_def_03A006 [
  actor-def < #00, #00, #20, {

  code_03A009:
    LDA #$0000
    STA $characterForm
    COP [SpawnThinkerParam] ( #0B, @chunk_008000.code_00B5C4 )
    JSL $@chunk_008000.code_00B57A
    COP [SpawnThinkerParam] ( #0B, @chunk_008000.code_00B5C4 )
    COP [SpawnAfterFlags] ( @code_03A073, #$3800 )
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA $0D58
    BEQ loc_03A071
    COP [SetEntryExit]
    PHX 
    TYX 
    LDA $animScratch2, X
    ORA #$0804
    STA $animScratch2, X
    PLX 
    LDA $0D58
    STA $24
    AND #$001F
    STA $0000
    COP [SetSavedPtr] ( &code_03A056 )
    COP [SwitchCase] ( #$0000, &overworld_options )
} >
]

code_03A056 {
    LDA $0D5A
    BEQ loc_03A071
    SEP #$20
    LDA $sceneNext
    STA $0D6E
    REP #$20
    LDA $0652
    STA $0D6C
    STZ $0652
    STZ $sceneNext

  loc_03A071:
    COP [Die]
}

code_03A073 {
    LDA $0D54
    STA $14
    SEC 
    SBC #$0080
    STA $cameraTargetX
    LDA $0D56
    STA $16
    SEC 
    SBC #$0070
    STA $cameraTargetY
    COP [InitGravity] ( #20, #05, #00 )
    COP [LoopInit] ( #2C )
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    COP [SetEntryExit]
    COP [LoopNext]
    LDA $0D58
    BEQ loc_03A0B9
    COP [WaitByte] ( #0F )
    COP [SpawnThinker] ( @code_03A586 )
    COP [SetEntryContinue]
    LDA $0D5A
    BNE loc_03A0B9
    RTL 

  loc_03A0B9:
    LDA $0D6F
    AND #$00FF
    STA $0000
    JSR $&code_03A3D6
    COP [AdhocVramDma] ( $7EA000, #$4400, #$0800 )
    COP [SpawnBeforeFlags] ( @code_03A246, #$3001 )
    COP [InitGravity] ( #00, #07, #00 )
    COP [LoopInit] ( #5D )
    COP [TickGravity]
    LDA $00B6
    CLC 
    ADC $moveScratch2, X
    STA $00B6
    INC $00B8
    COP [LoopNext]
    LDA #$0000
    STA $moveScratch2, X
    LDA #$2000
    TRB $10
    LDY #$0000

  loc_03A0FE:
    INY 
    INY 
    CPY #$000C
    BCS loc_03A10A
    LDA $0D60, Y
    BNE loc_03A0FE

  loc_03A10A:
    PHX 
    TYX 
    DEX 
    DEX 
    LDA $@loc_03A21A, X
    STA $18
    LDA #$0083
    STA $1A
    PLX 
    LDA $0D60
    STA $28
    LDA [$18]
    STA $24
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $25
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $16
    INC $18
    INC $18
    LDY #$0000

  loc_03A13E:
    INY 
    INY 
    STY $26
    LDA $0D60, Y
    BEQ loc_03A168
    PHA 
    COP [SpawnAfterFlags] ( @code_03A180, #$1800 )
    PLA 
    STA $0028, Y
    LDA [$18]
    STA $0024, Y
    LDA $24
    STA $0026, Y
    INC $18
    INC $18
    LDY $26
    CPY #$000A
    BCC loc_03A13E

  loc_03A168:
    LDA $24
    STA $orbitDiameter, X
    COP [LoopInit] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    COP [KillPrev]
    COP [SpawnBefore] ( @code_03A271 )
    BRA loc_03A1AE
}

code_03A180 {
    LDA $26
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    LDA $25
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 )
    LDA $orbitAngle, X
    STA $24

  loc_03A1AE:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryContinue]
    LDA $24

  loc_03A1BC:
    AND #$00FF
    CLC 
    ADC $cameraTargetX

  loc_03A1C3:
    STA $14
    LDA $24
    XBA 
    AND #$00FF
    CLC 

  loc_03A1CC:
    ADC $cameraTargetY
    STA $16

  loc_03A1D1:
    LDA $0D5A
    BEQ loc_03A1DD
    DEC $26
    BMI loc_03A1DB
    RTL 

  loc_03A1DB:
    BRA loc_03A1AE

  loc_03A1DD:
    LDA $orbitDiameter, X
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    CMP $14
    BNE loc_03A205
    LDA $7F0013, X
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    CMP $16
    BNE loc_03A205
    COP [Die]

  loc_03A205:
    LDA $7F0013, X
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 )
    COP [Die]

  loc_03A21A:
    PLP 
    LDX #$A238
    PLP 
    LDX #$A228
    BIT $28A2, X
    LDX #$A228
    BRA loc_03A1AA

  loc_03A22A:
    BVS loc_03A1BC
    BCC loc_03A1BE
    PLA 
    LDY #$A098
    BRA loc_03A1CC

  loc_03A234:
    RTS 
}

code_03A235 {
    BCS loc_03A1D7
    BCS loc_03A2B1
    BRA loc_03A1C3

  loc_03A23B:
    BRA loc_03A1BD

  loc_03A23D:
    BRA loc_03A2AF

  loc_03A23F:
    BCC loc_03A1D1
    BCC loc_03A2AB
    LDY #$A098
}

code_03A246 {
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$0010
    SEC 
    SBC $0D70
    LSR 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $cameraTargetY
    CLC 
    ADC #$0048
    STA $16
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    RTL 
}

code_03A271 {
    PHX 
    LDA $0D5A
    ASL 
    TAX 
    LDA $@overworld_routes, X
    STA $2C
    LDA #$0083
    STA $2E
    PLX 

  code_03A283:
    LDA [$2C]
    AND #$00FF
    CMP #$00FF
    BNE loc_03A290
    JMP $&code_03A340

  loc_03A290:
    INC $2C
    CMP #$00FE
    BNE loc_03A29A
    JMP $&code_03A332

  loc_03A29A:
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    STA $18
    LDA [$2C]
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    STA $1A

  loc_03A2AF:
    LDA [$2C]

  loc_03A2B1:
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    STA $1C
    LDA [$2C]
    AND #$00FF
    INC $2C
    STA $24
    COP [SetEntryContinue]
    LDA $18
    BEQ loc_03A2E4
    LDA ($18)
    INC $18
    INC $18
    CLC 
    ADC $00CA
    STA $00CA
    SEC 
    SBC #$0080
    STA $cameraTargetX
    LDA ($18)
    STA $18

  loc_03A2E4:
    LDA $1A
    BEQ loc_03A300
    LDA ($1A)
    INC $1A
    INC $1A
    CLC 
    ADC $00CC
    STA $00CC
    SEC 
    SBC #$0070
    STA $cameraTargetY
    LDA ($1A)
    STA $1A

  loc_03A300:
    LDA $1C
    BEQ loc_03A315
    LDA ($1C)
    INC $1C
    INC $1C
    CLC 
    ADC $00BC
    STA $00BC
    LDA ($1C)
    STA $1C

  loc_03A315:
    DEC $24
    BMI loc_03A31A
    RTL 

  loc_03A31A:
    JMP $&code_03A283
}

code_03A31D {
    LDA $0D6E
    AND #$00FF
    STA $sceneNext
    LDA $0D6C
    STA $0652
    JSR $&code_03A3C5
    COP [SetEntryContinue]
    RTL 
}

code_03A332 {
    LDA $2C
    INC 
    INC 
    STA $0D5C
    LDA [$2C]
    STA $2C
    JMP $&code_03A283
}

code_03A340 {
    LDA $0D5C
    BEQ loc_03A34D
    STZ $0D5C
    STA $2C
    JMP $&code_03A283

  loc_03A34D:
    STZ $0D5A
    STZ $0D58
    LDA $0D6E
    AND #$00FF
    STA $0000
    JSR $&code_03A3D6
    COP [AdhocVramDma] ( $7EA000, #$4400, #$0800 )
    COP [SpawnAfterFlags] ( @code_03A246, #$1001 )
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDA $00B6
    SEC 
    SBC #$0010
    BMI loc_03A389
    STA $00B6
    LDA $joypadRaw
    BIT #$1000
    BNE code_03A31D
    RTL 

  loc_03A389:
    LDA #$0000
    STA $00B6
    COP [SetEntryExit]
    COP [KillNext]
    LDA #$0800
    TSB $10
    COP [InitGravity] ( #00, #06, #00 )
    LDA #$0406
    STA $gfxCacheIdxB
    LDA $0D6E
    AND #$00FF
    STA $sceneNext
    LDA $0D6C
    STA $0652
    JSR $&code_03A3C5
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    RTL 
}

code_03A3C5 {
    LDA #$0000
    LDY #$0000

  loc_03A3CB:
    STA $0D52, Y
    INY 
    INY 
    CPY #$001C
    BCC loc_03A3CB
    RTS 
}

code_03A3D6 {
    PHP 
    PHX 
    LDX #$0000
    SEP #$20
    PHB 
    LDA #$83
    PHA 
    PLB 

  loc_03A3E2:
    LDA $&overworld_names, X
    BEQ loc_03A3FE
    CMP $0000
    BEQ loc_03A3F1
    INX 
    INX 
    INX 
    BRA loc_03A3E2

  loc_03A3F1:
    REP #$20
    LDY $&overworld_names+1, X
    JSL $@chunk_028000.code_028000
    PLB 
    PLX 
    PLP 
    RTS 

  loc_03A3FE:
    PLB 
    PLX 
    PLP 
    RTS 
}

thinker_def_03A402 [
  thinker-def < #04, #08, {

  code_03A404:
    PHD 
    LDA #$0000
    TCD 
    LDA $0036
    LSR 
    BCS loc_03A412
    JMP $&code_03A4CC

  loc_03A412:
    LDA #$0060
    STA $WRMPYA
    LDA #$00E0
    STA $06
    LDA #$001F
    STA $08
    LDA $B6
    LSR 
    STA $0E
    LDA #$0400
    SEC 
    SBC $0E
    ASL 
    STA $0E
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    LDX #$001E
    LDA #$E07F
    STA $7E8D02, X
    LDA #$0000
    STA $7E8D04, X

  loc_03A447:
    STZ $04
    STZ $02
    SEP #$20
    LDA $00
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    STA $02
    SEP #$20
    LDA $01
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    CLC 
    ADC $03
    STA $03
    SEP #$20
    LDA $04
    BNE loc_03A47A
    LDA #$01

  loc_03A47A:
    STA $7E8D00, X
    CLC 
    ADC $08
    STA $08
    BCS loc_03A4B7
    LDA $06
    STA $7E8D01, X
    INC 
    STA $06
    REP #$20
    LDA $00
    SEC 
    SBC $0E
    STA $00
    DEX 
    DEX 
    BPL loc_03A447
    INX 
    INX 

  loc_03A49D:
    TXY 
    PLA 
    TCD 
    TAX 
    SEP #$20
    LDA #$32
    XBA 
    LDA #$7E
    REP #$20
    PHA 
    TYA 
    CLC 
    ADC #$8D00
    TAY 
    PLA 
    JSL $@chunk_3B7DD.code_03DE5C
    RTL 

  loc_03A4B7:
    LDA $7E8D00, X
    SEC 
    SBC $08
    STA $7E8D00, X
    LDA $06
    STA $7E8D01, X
    REP #$20
    BRA loc_03A49D
} >
]

code_03A4CC {
    LDA #$0060
    STA $WRMPYA
    LDA #$00E0
    STA $06
    LDA #$001F
    STA $08
    LDA $B6
    LSR 
    STA $0E
    LDA #$0400
    SEC 
    SBC $0E
    ASL 
    STA $0E
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    LDX #$001E
    LDA #$E07F
    STA $7E8E02, X
    LDA #$0000
    STA $7E8E04, X

  loc_03A501:
    STZ $04
    STZ $02
    SEP #$20
    LDA $00
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    STA $02
    SEP #$20
    LDA $01
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    CLC 
    ADC $03
    STA $03
    SEP #$20
    LDA $04
    BNE loc_03A534
    LDA #$01

  loc_03A534:
    STA $7E8E00, X
    CLC 
    ADC $08
    STA $08
    BCS loc_03A571
    LDA $06
    STA $7E8E01, X
    INC 
    STA $06
    REP #$20
    LDA $00
    SEC 
    SBC $0E
    STA $00
    DEX 
    DEX 
    BPL loc_03A501
    INX 
    INX 

  loc_03A557:
    TXY 
    PLA 
    TCD 
    TAX 
    SEP #$20
    LDA #$32
    XBA 
    LDA #$7E
    REP #$20
    PHA 
    TYA 
    CLC 
    ADC #$8E00
    TAY 
    PLA 
    JSL $@chunk_3B7DD.code_03DE5C
    RTL 

  loc_03A571:
    LDA $7E8E00, X
    SEC 
    SBC $08
    STA $7E8E00, X
    LDA $06
    STA $7E8E01, X
    REP #$20
    BRA loc_03A557
}

code_03A586 {
    LDA #$0000
    STA $7F2104, X
    JSR $&code_03A653
    COP [SetEntryContinue]
    LDA $0D58
    BEQ loc_03A5A3
    LDA $0D5A
    BNE loc_03A5A3
    JSR $&code_03A5EE
    JSR $&code_03A5CE
    RTL 

  loc_03A5A3:
    COP [LoopInit] ( #02 )
    JSR $&code_03A5EE
    JSR $&code_03A5CE
    COP [LoopNext]
    COP [LoopInit] ( #28 )
    LDA $7F2104, X
    CLC 
    ADC #$0002
    STA $7F2104, X
    JSR $&code_03A5EE
    JSR $&code_03A5CE
    COP [LoopNext]
    COP [SetEntryContinue]
    JSR $&code_03A5EE
    JSR $&code_03A5CE
    RTL 
}

code_03A5CE {
    LDA $0036
    LSR 
    BCS loc_03A5E1
    COP [QueueDma] ( $7E8800, #05 )
    COP [QueueDma] ( $7E8A00, #32 )
    RTS 

  loc_03A5E1:
    COP [QueueDma] ( $7E8900, #05 )
    COP [QueueDma] ( $7E8B00, #32 )
    RTS 
}

code_03A5EE {
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $0036
    LSR 
    BCS loc_03A602
    LDY #$0000
    BRA loc_03A605

  loc_03A602:
    LDY #$0100

  loc_03A605:
    LDA $@code_03A67A
    STA $8800, Y
    LDA $@code_03A67A+7
    STA $8A00, Y
    SEP #$20
    LDA $@code_03A67A+2
    CLC 
    ADC $7F2104, X
    STA $8802, Y
    LDA $@code_03A67A+3
    STA $8803, Y
    LDA $@code_03A67A+9
    CLC 
    ADC $7F2104, X
    STA $8A02, Y
    LDA $@code_03A67A+A
    STA $8A03, Y
    REP #$20
    LDA $@code_03A67A+4
    STA $8804, Y
    LDA $@code_03A67A+B
    STA $8A04, Y
    LDA #$0000
    STA $8806, Y
    PLB 
    RTS 
}

code_03A653 {
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDY #$0000
    LDA #$01FF

  loc_03A662:
    STA $8A00, Y
    STA $S_sineTableB, Y
    INY 
    INY 
    CPY #$0098
    BCC loc_03A662
    LDA #$0000
    STA $8A00, Y
    STA $S_sineTableB, Y
    PLB 
    RTS 
}

code_03A67A {
    ADC $071807, X
    ORA ($09, X)
    BRK #$7F
    BRK #$18
    BRK #$01
    SBC $080400, X
    SEP #$20
    LDA #$80
    STA $M7SEL
    REP #$20
    LDA #$4FBC
    STA $7F0B22
    LDA #$0446
    STA $7F0B24
    LDA $0D54
    STA $00CA
    SEC 
    SBC #$0080
    ORA #$8000
    STA $scrollOverrideH
    LDA $0D56
    STA $00CC
    SEC 
    SBC #$0070
    ORA #$8000
    STA $scrollOverrideV
    STZ $00B6
    STZ $00BC
    LDA #$0400
    STA $00B8
}

code_03A6CD {
    PHX 
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    LDX #$0000
    LDA #$E0
    STA $0E

  loc_03A6DC:
    LDA #$01
    STA $tileStagingBuffer, X
    STA $7E7800, X
    STA $7E8000, X
    INX 
    INX 
    INX 
    DEC $0E
    BNE loc_03A6DC
    LDA #$00
    STA $tileStagingBuffer, X
    STA $7E7800, X
    STA $7E8000, X
    REP #$20
    PLD 
    PLX 
    COP [SetEntryContinue]
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8
    STZ $00
    STA $02
    LDA $B6
    STA $04
    LDA #$00E0
    STA $0E
    LDA $BC
    AND #$01FF
    ASL 
    TAY 
    LDX #$0000
    PEA $&code_03A75A-1
    LDA $&binary_01C36C.binary_01C67D, Y
    BMI loc_03A741
    STA $18
    LDA $&binary_01C36C.binary_01C57D, Y
    BMI loc_03A738
    STA $1C
    JMP $&code_03A775

  loc_03A738:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03A7C6

  loc_03A741:
    EOR #$FFFF
    INC 
    STA $18
    LDA $&binary_01C36C.binary_01C57D, Y
    BMI loc_03A751
    STA $1C
    JMP $&code_03A817

  loc_03A751:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03A86A
}

code_03A75A {
    PLD 
    PLX 
    COP [QueueDma] ( $7E7000, #1B )
    COP [QueueDma] ( $7E7800, #1C )
    COP [QueueDma] ( $7E8000, #1D )
    COP [QueueDma] ( $7E7000, #1E )
    RTL 
}

code_03A775 {
    JSR $&code_03A8BD

  loc_03A778:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA $RDDIVL
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E77FE, X
    EOR #$FFFF
    INC 
    STA $7E7FFE, X
    BCS loc_03A7B7
    DEC $0E
    BNE loc_03A778
    RTS 

  loc_03A7B7:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03A778
    RTS 
}

code_03A7C6 {
    JSR $&code_03A8BD

  loc_03A7C9:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA $RDDIVL
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E7FFE, X
    EOR #$FFFF
    INC 
    STA $7E77FE, X
    BCS loc_03A808
    DEC $0E
    BNE loc_03A7C9
    RTS 

  loc_03A808:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03A7C9
    RTS 
}

code_03A817 {
    JSR $&code_03A8BD

  loc_03A81A:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E77FE, X
    EOR #$FFFF
    INC 
    STA $7E7FFE, X
    BCS loc_03A85B
    DEC $0E
    BNE loc_03A81A
    RTS 

  loc_03A85B:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03A81A
    RTS 
}

code_03A86A {
    JSR $&code_03A8BD

  loc_03A86D:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E7FFE, X
    EOR #$FFFF
    INC 
    STA $7E77FE, X
    BCS loc_03A8AE
    DEC $0E
    BNE loc_03A86D
    RTS 

  loc_03A8AE:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03A86D
    RTS 
}

code_03A8BD {
    LDA $02
    BIT #$FF00
    BNE loc_03A8C5
    RTS 

  loc_03A8C5:
    LSR 
    STA $02
    LSR $18
    LSR $1C
    LSR $04
    BRA code_03A8BD

  loc_03A8D0:
    PHX 
    SEP #$20
    LDX #$0000
    LDA #$F0
    STA $tileStagingBuffer, X
    STA $7E7003, X
    STA $7E7006, X
    STA $7E7800, X
    STA $7E7803, X
    STA $7E7806, X
    STA $7E8000, X
    STA $7E8003, X
    STA $7E8006, X
    REP #$20
    LDA #$7100
    STA $7E7001, X
    LDA #$71E0
    STA $7E7004, X
    LDA #$7900
    STA $7E7801, X
    LDA #$79E0
    STA $7E7804, X
    LDA #$8100
    STA $7E8001, X
    LDA #$81E0
    STA $7E8004, X
    PLX 
    COP [SetEntryContinue]
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8
    STZ $00
    STA $02
    LDA $B6
    STA $04
    LDA #$00E0
    STA $0E
    LDA $BC
    AND #$01FF
    ASL 
    TAY 
    LDX #$01C0
    PEA $&code_03A980-1
    LDA $&binary_01C36C.binary_01C67D, Y
    BMI loc_03A967
    STA $18
    LDA $&binary_01C36C.binary_01C57D, Y
    BMI loc_03A95E
    STA $1C
    JMP $&code_03A99B

  loc_03A95E:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03A9E3

  loc_03A967:
    EOR #$FFFF
    INC 
    STA $18
    LDA $&binary_01C36C.binary_01C57D, Y
    BMI loc_03A977
    STA $1C
    JMP $&code_03AA2B

  loc_03A977:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03AA75
}

code_03A980 {
    PLD 
    PLX 
    COP [QueueHdma] ( $7E7000, #1B )
    COP [QueueHdma] ( $7E7800, #1C )
    COP [QueueHdma] ( $7E8000, #1D )
    COP [QueueHdma] ( $7E7000, #1E )
    RTL 
}

code_03A99B {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E7900, X
    EOR #$FFFF
    INC 
    STA $7E8100, X
    BCC loc_03A9DB
    CPX #$0000
    BPL code_03A99B
    RTS 

  loc_03A9DB:
    DEC $03
    CPX #$0000
    BPL code_03A99B
    RTS 
}

code_03A9E3 {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X
    EOR #$FFFF
    INC 
    STA $7E7900, X
    BCC loc_03AA23
    CPX #$0000
    BPL code_03A9E3
    RTS 

  loc_03AA23:
    DEC $03
    CPX #$0000
    BPL code_03A9E3
    RTS 
}

code_03AA2B {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E7900, X
    EOR #$FFFF
    INC 
    STA $7E8100, X
    BCC loc_03AA6D
    CPX #$0000
    BPL code_03AA2B
    RTS 

  loc_03AA6D:
    DEC $03
    CPX #$0000
    BPL code_03AA2B
    RTS 
}

code_03AA75 {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X
    EOR #$FFFF
    INC 
    STA $7E7900, X
    BCC loc_03AAB7
    CPX #$0000
    BPL code_03AA75
    RTS 

  loc_03AAB7:
    DEC $03
    CPX #$0000
    BPL code_03AA75
    RTS 
}