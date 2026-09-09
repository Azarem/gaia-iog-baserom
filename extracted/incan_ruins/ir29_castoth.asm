?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'camera_drift'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'func_0AA36E'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'sE6_gaia'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!rngModuloResult                0420
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerXPos                     09A2
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!animScratch                    7F0000
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

btF2_neo_castoth [
  actor-def < #01, #01, #03, {

  code_0A99DA:
    LDA #$8011
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfterAbs] ( @code_0A9A68, #$0058, #$00A0, #$0200 )
    TYA 
    STA $animScratch, X
    COP [SpawnMarkedAfterAbs] ( @code_0A9A76, #$0098, #$00A0, #$0200 )
    TYA 
    STA $animScratch+2, X
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$0100
    TSB $12
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDA $characterForm
    CMP #$0002
    BEQ loc_0A9A43
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F5F9
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F5F9
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0A9A43
    RTL 

  loc_0A9A43:
    COP [SpawnLastRel] ( @func_0A9EEB, #00, #00, #$2200 )
    TYA 
    STA $orbitAngle, X
    COP [SetDeathCallback] ( @func_0A9C1E )
    COP [SpawnLastRel] ( @code_0A9AB9, #00, #00, #$2000 )
    STZ $00F0
    STZ $00F2
    JMP $&code_0A9BF6
} >
]

code_0A9A68 {
    COP [AddPosition] ( #08, #00 )
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #30 )
    BRA loc_0A9A84
}

code_0A9A76 {
    COP [AddPosition] ( #08, #00 )
    COP [ToggleHFlip]
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #30 )

  loc_0A9A84:
    LDA #$&stats_01ABF0+190
    STA $statsPtr, X
    LDA $@stats_01ABF0+190
    AND #$00FF
    STA $currentHp, X
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BNE loc_0A9AB8
    JMP $&code_0AA1D3

  loc_0A9AB8:
    RTL 
}

code_0A9AB9 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0A9AC1
    RTL 

  loc_0A9AC1:
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F3B1
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F3B1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0A9AE7
    RTL 

  loc_0A9AE7:
    COP [SetFlagWord] ( #$0175 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$03F8, #$03A0, #03, #$4830 )
    COP [Die]
}
---------------------------------------------

ir29_castoth [
  actor-def < #01, #01, #03, {

  code_0A9B06:
    LDA #$0000
    JSL $@cop_handlers_script.TestWramFlag_Offset100
    BCC loc_0A9B17
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0A9B17:
    LDA #$8011
    TSB $12
    COP [AddPosition] ( #08, #F8 )
    COP [SetSpritePriority] ( #20 )
    LDA #$*binary_0A9C0F
    AND #$00FF
    STA $0AF6
    LDA #$&binary_0A9C0F
    STA $0AF4
    JSL $@func_0AA37B
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [StageBgChange] ( #1E )
    COP [ApplyBgChange]
    COP [WaitByte] ( #27 )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #3B )
    LDA #$EFF0
    TRB $joypadMaskStd
    JSL $@func_0AA391
    COP [SpawnLastRel] ( @camera_drift.CameraDriftLoopSimple, #00, #00, #$2000 )
    COP [SpawnMarkedAfterAbs] ( @code_0AA169, #$0050, #$00E0, #$0301 )
    TYA 
    STA $animScratch, X
    COP [WaitByte] ( #3B )
    COP [SpawnMarkedAfterAbs] ( @code_0AA177, #$00A0, #$00E0, #$0301 )
    TYA 
    STA $animScratch+2, X
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$0100
    TSB $12
    LDA #$0090
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [SpawnLastRel] ( @func_0A9EEB, #00, #00, #$2200 )
    TYA 
    STA $orbitAngle, X
    COP [SetDeathCallback] ( @func_0A9C1E )
    STZ $26
    STZ $00F0
    STZ $00F2
    BRA code_0A9BF6
} >
]
---------------------------------------------

func_0A9BC2 {
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @func_0A9C17, #00, #00, #$2000 )
    COP [WaitWord] ( #$0095 )
    COP [SpawnMarkedAfter] ( @code_0A9D64, #$0302 )
    COP [WaitWord] ( #$0095 )
    COP [CallScript] ( &func_0A9D25 )
    LDA #$0003
    STA $00F2
    LDA #$0200
    TSB $10
    STZ $00F0
}

code_0A9BF6 {
    COP [WaitWord] ( #$010D )
    COP [SpawnMarkedAfter] ( @code_0A9D64, #$0302 )
    COP [WaitWord] ( #$010D )
    LDA $00F0
    CMP #$0003
    BEQ func_0A9BC2
    BRA code_0A9BF6
}
---------------------------------------------

binary_0A9C0F #1E68000001000024
---------------------------------------------

func_0A9C17 {
    COP [PaletteStart] ( #11 )
    COP [PaletteStep]
    COP [Die]
}
---------------------------------------------

func_0A9C1E {
    LDA $playerFlags
    BIT #$0200
    BEQ loc_0A9C29
    COP [SetEntryContinue]
    RTL 

  loc_0A9C29:
    LDA #$0020
    TSB $playerFlags
    LDY $26
    BEQ loc_0A9C41
    STZ $26
    LDA #$&loc_0A9DB1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y

  loc_0A9C41:
    LDA $orbitAngle, X
    PHX 
    TCD 
    TAX 
    COP [MarkDeath]
    PLA 
    TCD 
    TAX 
    LDA $animScratch, X
    TAY 
    LDA #$&func_0A9CB2
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA $animScratch+2, X
    TAY 
    LDA #$&func_0A9CB2
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SpawnLastRel] ( @func_0AA36E, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0A9C8E, #00, #00, #$2000 )
    COP [WaitByte] ( #3B )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

code_0A9C8E {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #12 )
    COP [SpawnLastRel] ( @code_0A9CE7, #00, #C8, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0A9CF4, #00, #C8, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}
---------------------------------------------

func_0A9CB2 {
    COP [SpawnLastRel] ( @code_0A9CC0, #00, #00, #$2000 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

code_0A9CC0 {
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_0A9CE7, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0A9CF4, #00, #00, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_0A9CE7 {
    JSR $&sub_0A9CFE
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0A9CF4 {
    JSR $&sub_0A9CFE
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}
---------------------------------------------

sub_0A9CFE {
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #60 )
    LDA $rngModuloResult
    SEC 
    SBC #$0030
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #60 )
    LDA $rngModuloResult
    SEC 
    SBC #$0030
    CLC 
    ADC $16
    STA $16
    RTS 
}
---------------------------------------------

func_0A9D25 {
    LDA #$0200
    TSB $10
    COP [LoopInit] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @code_0A9D93, #$0000, #$FFE0, #$2202 )
    STY $26
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [WaitWord] ( #$012B )
    LDA #$0200
    TRB $10
    LDY $26
    STZ $26
    LDA #$&loc_0A9DB1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [RestoreSavedPtr]
}

code_0A9D64 {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A9FDB, #00, #A0, #$2000 )
    LDA $sceneCurrent
    CMP #$002A
    BCC loc_0A9D8B
    COP [WaitByte] ( #0E )
    COP [SpawnLastRel] ( @code_0A9FDB, #00, #A0, #$2000 )

  loc_0A9D8B:
    COP [StageSpriteLoop] ( #26, #08 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9D93 {
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfter] ( @code_0A9DBA, #$0202 )
    COP [SpawnMarkedAfter] ( @code_0A9DB3, #$0202 )
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_0A9DB1
    RTL 

  loc_0A9DB1:
    COP [Die]
}

code_0A9DB3 {
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    BRA code_0A9DB3
}

code_0A9DBA {
    PHX 
    LDX #$0000
    LDA $playerXPos
    CLC 
    ADC #$0008
    STA $0000
    SEC 
    SBC #$0080
    BMI loc_0A9DED

  loc_0A9DCE:
    CMP $@array_0A9ED3, X
    BCC loc_0A9DDD
    INX 
    INX 
    INX 
    INX 
    CPX #$0014
    BCC loc_0A9DCE

  loc_0A9DDD:
    LDA $@array_0A9ED3+2, X
    PLX 
    PHA 
    LDA $0E
    ORA #$4000
    STA $0E
    PLA 
    BRA loc_0A9E07

  loc_0A9DED:
    BPL loc_0A9DF3
    EOR #$FFFF
    INC 

  loc_0A9DF3:
    CMP $@array_0A9ED3, X
    BCC loc_0A9E02
    INX 
    INX 
    INX 
    INX 
    CPX #$0014
    BCC loc_0A9DF3

  loc_0A9E02:
    LDA $@array_0A9ED3+2, X
    PLX 

  loc_0A9E07:
    STA $28
    STZ $2A
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #0F )
    LDA #$2000
    TRB $10
    COP [SpawnLastRel] ( @code_0A9E36, #00, #00, #$2200 )
    COP [PlaySoundCh1] ( #20 )
    LDA #$0004
    STA $24

  loc_0A9E29:
    COP [SetEntryContinue]
    COP [AnimOnce]
    DEC $24
    BPL loc_0A9E29
    COP [SetEntryExitNow] ( @code_0A9DBA )
}

code_0A9E36 {
    COP [WaitByte] ( #03 )
    LDA #$2000
    TRB $10
    PHX 
    LDA $0E
    BIT #$4000
    BNE loc_0A9E5B
    LDA $28
    SEC 
    SBC #$001D
    ASL 
    ASL 
    TAX 
    LDA $@array_0A9EA3, X
    STA $14
    LDA $@array_0A9EA3+2, X
    BRA loc_0A9E6E

  loc_0A9E5B:
    LDA $28
    SEC 
    SBC #$001D
    ASL 
    ASL 
    TAX 
    LDA $@array_0A9EBB, X
    STA $14
    LDA $@array_0A9EBB+2, X

  loc_0A9E6E:
    STA $16
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    STA $14
    LDA $0411
    AND #$0007
    SEC 
    SBC $16
    STA $16
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [Die]
}
---------------------------------------------

array_0A9EA3 [
  screen-pos < #$0080, #$00D6 >   ;00
  screen-pos < #$0070, #$00D6 >   ;01
  screen-pos < #$0056, #$00D6 >   ;02
  screen-pos < #$0038, #$00C6 >   ;03
  screen-pos < #$001A, #$00B0 >   ;04
  screen-pos < #$001A, #$0098 >   ;05
]
---------------------------------------------

array_0A9EBB [
  screen-pos < #$0080, #$00D6 >   ;00
  screen-pos < #$0093, #$00D6 >   ;01
  screen-pos < #$00AA, #$00D6 >   ;02
  screen-pos < #$00CA, #$00C6 >   ;03
  screen-pos < #$00E7, #$00B8 >   ;04
  screen-pos < #$00E5, #$0098 >   ;05
]
---------------------------------------------

array_0A9ED3 [
  screen-pos < #$000A, #$001D >   ;00
  screen-pos < #$0015, #$001E >   ;01
  screen-pos < #$0032, #$001F >   ;02
  screen-pos < #$0059, #$0020 >   ;03
  screen-pos < #$005F, #$0021 >   ;04
  screen-pos < #$005D, #$0022 >   ;05
]
---------------------------------------------

func_0A9EEB {
    COP [SetSpritePriority] ( #30 )

  code_0A9EEE:
    COP [SetSavedPtr] ( &code_0A9EEE )
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #1E )
    COP [BranchIfPlayerInAbsTiles] ( #05, #02, #0C, #05, &code_0A9F2A )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0A, #0B, #0C, &code_0A9FAA )
    COP [WaitByte] ( #04 )
    COP [LoopNext]
    LDA #$2000
    TRB $10
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A9F22 )
}

code_list_0A9F22 [
  &code_0A9F37   ;00
  &code_0A9F5B   ;01
  &code_0A9F7F   ;02
  &code_0A9F86   ;03
]

code_0A9F2A {
    LDA #$2000
    TRB $10
    LDA $0036
    LSR 
    BCC code_0A9F37
    BRA code_0A9F5B
}

code_0A9F37 {
    LDA #$0008
    STA $14
    LDA #$003A
    STA $16
    COP [StageSpriteLoop] ( #27, #06 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9FD3, #$0200 )
    COP [StageSpriteMoveX] ( #27, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F5B {
    LDA #$00F0
    STA $14
    LDA #$003A
    STA $16
    COP [StageSpriteLoop] ( #27, #06 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9FD3, #$0200 )
    COP [StageSpriteMoveX] ( #27, #08 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F7F {
    LDA #$0020
    STA $14
    BRA loc_0A9F8B
}

code_0A9F86 {
    LDA #$00E0
    STA $14

  loc_0A9F8B:
    LDA #$001C
    STA $16
    COP [StageSpriteLoop] ( #27, #06 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9FD3, #$0200 )
    COP [StageSpriteMoveY] ( #27, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9FAA {
    LDA #$2000
    TRB $10
    LDA #$0008
    STA $14
    LDA #$00B6
    STA $16
    COP [StageSpriteLoop] ( #27, #06 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9FD3, #$0200 )
    COP [StageSpriteMoveX] ( #27, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9FD3 {
    COP [StageSpriteLoop] ( #27, #03 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9FDB {
    COP [SetSpritePriority] ( #30 )
    LDA #$0014
    STA $20
    LDA #$0001
    STA $22
    COP [StageSpriteLoop] ( #19, #04 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnMarkedAfter] ( @code_0AA04D, #$0302 )
    COP [StageSpriteLoop] ( #1A, #02 )
    COP [AnimLoop]
    COP [SetEntryExit]
    LDA $20
    CMP #$0010
    BCS loc_0AA011
    LDA $22
    EOR #$FFFF
    INC 
    STA $22
    BRA loc_0AA01E

  loc_0AA011:
    CMP #$0028
    BCC loc_0AA01E
    LDA $22
    EOR #$FFFF
    INC 
    STA $22

  loc_0AA01E:
    LDA $20
    CLC 
    ADC $22
    STA $20
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_0AA030
    RTL 

  loc_0AA030:
    LDA #$2000
    TRB $10
    LDY $06
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0AA04D {
    LDA $24
    STA $orbitAngle, X
    COP [SpawnMarkedAfter] ( @code_0AA12E, #$0202 )
    LDA #$0000
    STA $0026, Y
    COP [SpawnMarkedAfter] ( @code_0AA12E, #$0202 )
    LDA #$0055
    STA $0026, Y
    COP [SpawnMarkedAfter] ( @code_0AA12E, #$0202 )
    LDA #$00AA
    STA $0026, Y
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AA08E )
}

code_list_0AA08E [
  &code_0AA096   ;00
  &code_0AA09B   ;01
  &code_0AA0A1   ;02
  &code_0AA0A6   ;03
]

code_0AA096 {
    LDA #$4000
    TSB $12
}

code_0AA09B {
    COP [StageForceMoveXY] ( #05, #03 )
    BRA loc_0AA0AC
}

code_0AA0A1 {
    LDA #$4000
    TSB $12
}

code_0AA0A6 {
    COP [StageForceMoveXY] ( #03, #05 )
    BRA loc_0AA0AC

  loc_0AA0AC:
    COP [StageSprAndHitbox] ( #24 )
    LDA #$0186
    STA $26

  loc_0AA0B4:
    COP [ReloadForceMove]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AA0B4
    LDA $08
    STA $24
    STZ $08

  loc_0AA0C2:
    COP [SetEntryExit]
    LDA $14
    BMI loc_0AA0CD
    CMP #$0020
    BCS loc_0AA0D6

  loc_0AA0CD:
    LDA $12
    EOR #$4000
    STA $12
    BRA loc_0AA0E2

  loc_0AA0D6:
    CMP #$00E0
    BCC loc_0AA0E2
    LDA $12
    EOR #$4000
    STA $12

  loc_0AA0E2:
    LDA $16
    BMI loc_0AA0EB
    CMP #$0020
    BCS loc_0AA0F4

  loc_0AA0EB:
    LDA $12
    EOR #$2000
    STA $12
    BRA loc_0AA100

  loc_0AA0F4:
    CMP #$00C0
    BCC loc_0AA100
    LDA $12
    EOR #$2000
    STA $12

  loc_0AA100:
    DEC $26
    BMI loc_0AA10A
    DEC $24
    BPL loc_0AA0C2
    BRA loc_0AA0B4

  loc_0AA10A:
    LDA $24
    DEC 
    BMI loc_0AA113
    STA $08
    COP [SetEntryExit]

  loc_0AA113:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AA113
    LDA $orbitAngle, X
    TAY 
    LDA #$&loc_0AA030
    STA $0000, Y
    COP [SetEntryContinue]
    RTL 
}

code_0AA12E {
    LDA $26
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #23 )

  loc_0AA137:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AA137
    LDA $08
    STA $26
    STZ $08

  loc_0AA143:
    LDA $parentId, X
    TAY 
    LDA $0020, Y
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    COP [SetEntryExit]
    DEC $26
    BPL loc_0AA143
    BRA loc_0AA137
}

code_0AA169 {
    COP [AddPosition] ( #08, #00 )
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )
    BRA loc_0AA185
}

code_0AA177 {
    COP [AddPosition] ( #08, #00 )
    COP [ToggleHFlip]
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )

  loc_0AA185:
    LDA #$&stats_01ABF0+190
    STA $statsPtr, X
    LDA $@stats_01ABF0+190
    AND #$00FF
    STA $currentHp, X
    STA $orbitAngle, X
    COP [StageSpriteMoveY] ( #03, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnLastRel] ( @camera_drift.CameraDriftPatterned, #00, #00, #$2000 )
    COP [CollPriorityClearMin]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA #$0101
    TRB $10
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
}

code_0AA1D3 {
    COP [SetDeathCallback] ( @code_0AA241 )

  loc_0AA1D8:
    LDA #$0200
    TSB $10
    COP [BranchOnPlayerX] ( #$0030, &code_0AA1E7, &code_0AA1EE, &code_0AA1E7 )
}

code_0AA1E7 {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_0AA1D8
}

code_0AA1EE {
    COP [StageSpriteLoop] ( #06, #03 )
    COP [AnimLoop]
    COP [BranchOnPlayerX] ( #$0020, &code_0AA1E7, &code_0AA1FE, &code_0AA1E7 )
}

code_0AA1FE {
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AA230 )
    COP [BranchOnPlayerX] ( #$0020, &code_0AA2DB, &code_0AA2FE, &code_0AA31D )
}

code_0AA230 {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    BRA loc_0AA1D8
}

code_0AA241 {
    COP [AndActorFlags] ( #$FFBD )
    COP [LoopInit] ( #08 )
    COP [SetSpritePalette] ( #02 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    LDA $28
    CMP #$000A
    BCS loc_0AA260
    CMP #$0009
    BEQ loc_0AA289
    BRA loc_0AA291

  loc_0AA260:
    LDA $7F100C, X
    CMP $14
    BNE loc_0AA270
    LDA $7F100E, X
    CMP $16
    BEQ loc_0AA284

  loc_0AA270:
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 )

  loc_0AA284:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]

  loc_0AA289:
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]

  loc_0AA291:
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1C, #01 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA #$0040
    TRB $10
    LDA $orbitAngle, X
    STA $currentHp, X
    SEC 
    ROL $00F0
    COP [SetEntryExit]
    LDA $00F2
    BNE loc_0AA2C2
    RTL 

  loc_0AA2C2:
    LSR $00F2
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #1C, #02 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    JMP $&code_0AA1D3
}

code_0AA2DB {
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #0D, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0E, #02, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0F, #02, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #10, #02, #05 )
    COP [AnimOnce]
    BRA loc_0AA33E
}

code_0AA2FE {
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #10, #05 )
    COP [AnimOnce]
    BRA loc_0AA33E
}

code_0AA31D {
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #0D, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0E, #01, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0F, #01, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #10, #01, #05 )
    COP [AnimOnce]

  loc_0AA33E:
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @camera_drift.CameraDriftPatterned, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #11, #01 )
    COP [SpawnLastRel] ( @camera_drift.CameraDriftPatterned, #00, #00, #$2000 )
    COP [RestoreSavedPtr]
}
---------------------------------------------

func_0AA37B {
    LDY $playerActor
    LDA #$*player_transition_handlers.loc_00C432
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C432
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTL 
}
---------------------------------------------

func_0AA391 {
    LDY $playerActor
    LDA #$*player_transition_handlers.loc_00C45A
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C45A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTL 
}