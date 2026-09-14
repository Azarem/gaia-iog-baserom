?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'func_0AA36E'
?INCLUDE 'func_0AA41C'
?INCLUDE 'hardware_math'
?INCLUDE 'math_lookup_tables'
?INCLUDE 'table_0EE000'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerActor                    09AA
!characterForm                  0AD4
!mode7Tilemap                   7EE000
!thinkerExtendedData            7EF000
!animScratch                    7F0000
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!retPtr2                        7F001E
!statsPtr                       7F0020
!currentHp                      7F0026
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

actor_09AA6E [
  actor-def < #00, #10, #01, {

  code_09AA71:
    LDA #$8011
    TSB $12
    LDA $14
    SEC 
    SBC #$0008
    STA $14
    LDA $16
    CLC 
    ADC #$0100
    STA $16
    LDA #$0000
    STA $cameraTargetX
    STA $cameraTargetY
    STA $cameraDeltaX
    STA $cameraDeltaY
    COP [SpawnAfterFlags] ( @code_09B719, #$2300 )
    COP [SpawnAfterFlags] ( @code_09B6FC, #$2300 )
    COP [SpawnAfterFlags] ( @code_09B747, #$2300 )
    COP [SpawnMarkedBefore] ( @code_09B5C7, #$2000 )
    COP [SpawnMarkedAfterRel] ( @code_09B30E, #C8, #33, #$0111 )
    COP [SpawnMarkedAfterRel] ( @code_09B36A, #38, #33, #$0111 )
    COP [SpawnMarkedAfterRel] ( @code_09B586, #BF, #0B, #$0301 )
    COP [SpawnMarkedAfterRel] ( @code_09B57F, #41, #0B, #$0301 )
    STZ $24
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    LDA $24
    BNE loc_09AAE3
    RTL 

  loc_09AAE3:
    LDA #$0100
    TRB $10
    LDA #$0003
    STA $0000
    LDY $06

  loc_09AAF0:
    LDA $0010, Y
    AND #$FEFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_09AAF0

  loc_09AB02:
    LDY $06
    LDA #$&code_09B58E
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$&code_09B58E
    STA $0000, Y
    LDA #$021C
    STA $animScratch, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_09AB6C
    LDA $animScratch, X
    DEC 
    STA $animScratch, X
    BMI loc_09AB2D
    RTL 

  loc_09AB2D:
    LDY $06
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    LDA $0026, Y
    BNE loc_09AB42
    LDA #$&code_09B37A
    STA $0000, Y

  loc_09AB42:
    LDA $0006, Y
    TAY 
    LDA $0026, Y
    BNE loc_09AB51
    LDA #$&code_09B31E
    STA $0000, Y

  loc_09AB51:
    LDA #$00B4
    STA $animScratch, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_09AB6C
    LDA $animScratch, X
    DEC 
    STA $animScratch, X
    BMI loc_09AB6A
    RTL 

  loc_09AB6A:
    BRA loc_09AB02

  loc_09AB6C:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetDeathCallback] ( @code_09ABF5 )

  loc_09AB76:
    COP [SpawnLastRel] ( @code_09B9BE, #00, #00, #$2000 )
    LDA #$0010
    TRB $10
    COP [WaitByte] ( #1D )
    COP [SetHitCallback] ( &code_09ABEE )

  loc_09AB8B:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #29 )
    COP [SpawnLastRel] ( @code_09B8B6, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_09B9C5, #00, #00, #$2000 )
    COP [SetHitCallback] ( #$0000 )
    COP [WaitWord] ( #$00B3 )
    LDA #$0010
    TSB $10
    LDY $06
    LDA #$&loc_09B5AD
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$&loc_09B5AD
    STA $0000, Y
    LDY $06
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    LDA #$&code_09B3EA
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$&code_09B3EA
    STA $0000, Y
    COP [WaitWord] ( #$01DF )
    BRA loc_09AB76
} >
]

code_09ABEE {
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA loc_09AB8B
}

code_09ABF5 {
    COP [SpawnLastRel] ( @code_09B9C5, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    LDY $04
    LDA #$&code_09B6A6
    STA $0000, Y
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    LDA $26
    BEQ loc_09AC17
    RTL 

  loc_09AC17:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #F5 )
    COP [AdhocVramDma] ( $7EE000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7EE800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7EF000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7EF800, #$5C00, #$0800 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SpawnLastRel] ( @code_09AC55, #00, #00, #$0012 )
    COP [Die]
}

code_09AC55 {
    COP [SetDeathCallback] ( @code_09B1D5 )
    LDA #$&enemy_stats_table+15C
    STA $statsPtr, X
    LDA $&enemy_stats_table+15C
    AND #$00FF
    STA $currentHp, X
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfterRel] ( @code_09ADB3, #EA, #E0, #$2200 )
    COP [SpawnMarkedAfterRel] ( @code_09ADEB, #16, #E0, #$2200 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0080
    STA $moveXAlt, X
    STA $moveYAlt, X
    COP [StageMove] ( #1E, #FF, #FF )
    COP [TickMove]
    COP [StageSpriteLoop] ( #1E, #04 )
    COP [AnimLoop]
    LDA #$0010
    TRB $10

  code_09ACA2:
    COP [SetHitCallback] ( &code_09AD11 )
    COP [SetEntryContinue]
    LDA $0036
    LSR 
    BCS loc_09ACBF
    LDA $playerActor
    LDA $0014, Y
    STA $0018
    LDA $0016, Y
    STA $001C
    BRA loc_09ACCD

  loc_09ACBF:
    COP [RngByte]
    STA $0018
    LDA $0411
    AND #$00FF
    STA $001C

  loc_09ACCD:
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $0018
    CMP #$0020
    BCS loc_09ACE0
    RTL 

  loc_09ACE0:
    CMP #$00E0
    BCC loc_09ACE6
    RTL 

  loc_09ACE6:
    STA $moveXAlt, X
    LDA $0411
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $001C
    CMP #$0040
    BCS loc_09ACFE
    RTL 

  loc_09ACFE:
    CMP #$00E0
    BCC loc_09AD04
    RTL 

  loc_09AD04:
    STA $moveYAlt, X
    COP [StageMove] ( #1E, #FF, #FF )
    COP [TickMove]
    BRA code_09ACA2
}

code_09AD11 {
    LDA #$0001
    STA $26
    COP [StageSpriteFrame] ( #42 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_09AD3F, #00, #EC, #$0211 )
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    STZ $26
    JMP $&code_09ACA2
}

code_09AD38 {
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    BRA code_09AD38
}

code_09AD3F {
    COP [SetDeathCallback] ( @code_09ADA7 )
    COP [OrActorFlags] ( #$0080 )
    COP [StageSpriteLoopMoveY] ( #22, #10, #07 )
    COP [AnimLoop]
    COP [WaitByte] ( #13 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    LDA #$0210
    TRB $10
    LDA #$&enemy_stats_table+158
    STA $statsPtr, X
    LDA $&enemy_stats_table+158
    AND #$00FF
    STA $currentHp, X

  loc_09AD6D:
    COP [SetHitCallback] ( &code_09ADA0 )
    COP [SetEntryContinue]
    COP [RngByte]
    CMP #$0014
    BCS loc_09AD7B
    RTL 

  loc_09AD7B:
    CMP #$00E0
    BCC loc_09AD81
    RTL 

  loc_09AD81:
    STA $moveXAlt, X
    COP [RngByte]
    CMP #$0014
    BCS loc_09AD8D
    RTL 

  loc_09AD8D:
    CMP #$00E0
    BCC loc_09AD93
    RTL 

  loc_09AD93:
    STA $moveYAlt, X
    COP [StageMove] ( #24, #02, #FF )
    COP [TickMove]
    BRA loc_09AD6D
}

code_09ADA0 {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_09AD6D
}

code_09ADA7 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [Die]
}

code_09ADB3 {
    COP [SpawnMarkedAfterRel] ( @code_09AE52, #B0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B2AE, #C0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #D0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #E0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #F0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B29B, #00, #00, #$0202 )
    BRA loc_09AE21
}

code_09ADEB {
    COP [SpawnMarkedAfterRel] ( @code_09B147, #50, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B2AE, #40, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #30, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #20, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B28D, #10, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_09B29B, #00, #E0, #$0202 )

  loc_09AE21:
    LDA $14
    LDY $24
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    LDY $24
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [SetEntryContinue]
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTL 
}

code_09AE52 {
    COP [StageSprAndHitbox] ( #29 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0070
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $parentId, X
    TAY 
    LDA $0010, Y
    BIT #$0010
    BEQ code_09AE76
    JSR $&code_09B255
    RTL 

  code_09AE76:
    COP [SetSavedPtr] ( &code_09AE76 )
    COP [DirToPlayer]
    PHX 
    AND #$0007
    STA $0000
    TAX 
    LDA $@byte_09B25C, X
    PLX 
    AND #$00FF
    STA $7F100C, X
    SEP #$20
    SEC 
    SBC $orbitAngle, X
    REP #$20
    BPL loc_09AECA

  loc_09AE9B:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    JSR $&code_09B274
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    AND #$00FF
    STA $orbitAngle, X
    SEC 
    SBC $7F100C, X
    BPL loc_09AEC3
    EOR #$FFFF
    INC 

  loc_09AEC3:
    CMP #$0003
    BCS loc_09AE9B
    BRA code_09AE76

  loc_09AECA:
    AND #$00FF
    CMP #$0010
    BCC code_09AF02
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    JSR $&code_09B274
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    SEC 
    SBC $7F100C, X
    BPL loc_09AEFA
    EOR #$FFFF
    INC 

  loc_09AEFA:
    CMP #$0003
    BCS loc_09AECA
    JMP $&code_09AE76

  code_09AF02:
    LDA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    PHX 
    TAX 
    LDA $@byte_09B26C, X
    PLX 
    AND #$00FF
    STA $0000
    LDA $0410
    AND #$0001
    SEC 
    SBC #$0001
    CLC 
    ADC $0000
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_09AF32 )
}

code_list_09AF32 [
  &code_09AF42   ;00
  &code_09AF66   ;01
  &code_09AF8A   ;02
  &code_09AFAE   ;03
  &code_09AFD2   ;04
  &code_09AFF6   ;05
  &code_09B01A   ;06
  &code_09B03E   ;07
]

code_09AF42 {
    COP [StageSprAndHitbox] ( #2A )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0A6, #00, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09AF66 {
    COP [StageSprAndHitbox] ( #2F )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0B8, #08, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09AF8A {
    COP [StageSprAndHitbox] ( #2C )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0CA, #08, #00, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09AFAE {
    COP [StageSprAndHitbox] ( #30 )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0DC, #08, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09AFD2 {
    COP [StageSprAndHitbox] ( #29 )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0EE, #00, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09AFF6 {
    COP [StageSprAndHitbox] ( #2D )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B0FF, #F8, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09B01A {
    COP [StageSprAndHitbox] ( #2B )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B110, #F8, #00, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09B03E {
    COP [StageSprAndHitbox] ( #2E )
    JSR $&code_09B084
    COP [LoopInit] ( #10 )
    JSR $&code_09B255
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_09B121, #F8, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_09B255
    COP [LoopNext]
    JSR $&code_09B062
    COP [RestoreSavedPtr]
}

code_09B062 {
    LDA $parentId, X
    TAY 
    LDA $0026, Y
    BNE loc_09B082
    LDA $0010, Y
    BIT #$0040
    BNE loc_09B082
    LDA #$&code_09ACA2
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    CLC 
    RTS 

  loc_09B082:
    SEC 
    RTS 
}

code_09B084 {
    LDA $parentId, X
    TAY 
    LDA $0026, Y
    BNE loc_09B0A4
    LDA $0010, Y
    BIT #$0040
    BNE loc_09B0A4
    LDA #$&code_09AD38
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    CLC 
    RTS 

  loc_09B0A4:
    SEC 
    RTS 
}

code_09B0A6 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3B )
    COP [StageForceMoveXY] ( #00, #08 )
    JMP $&code_09B134
}

code_09B0B8 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #40 )
    COP [StageForceMoveXY] ( #05, #06 )
    JMP $&code_09B134
}

code_09B0CA {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #35 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3D )
    COP [StageForceMoveXY] ( #07, #00 )
    JMP $&code_09B134
}

code_09B0DC {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #41 )
    COP [StageForceMoveXY] ( #05, #05 )
    JMP $&code_09B134
}

code_09B0EE {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3A )
    COP [StageForceMoveXY] ( #00, #07 )
    BRA code_09B134
}

code_09B0FF {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3E )
    COP [StageForceMoveXY] ( #06, #05 )
    BRA code_09B134
}

code_09B110 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3C )
    COP [StageForceMoveXY] ( #08, #00 )
    BRA code_09B134
}

code_09B121 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #37 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3F )
    COP [StageForceMoveXY] ( #06, #06 )
    BRA code_09B134

  loc_09B132:
    COP [ReloadForceMove]
}

code_09B134 {
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_09B132
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [Die]
}

code_09B147 {
    COP [StageSprAndHitbox] ( #29 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0070
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $parentId, X
    TAY 
    LDA $0010, Y
    BIT #$0010
    BEQ code_09B16B
    JSR $&code_09B255
    RTL 

  code_09B16B:
    COP [SetSavedPtr] ( &code_09B16B )
    LDA $0410
    LSR 
    BCS loc_09B17B
    JMP $&code_09AF02
}

code_09B178 {
    COP [StageSprAndHitbox] ( #29 )

  loc_09B17B:
    COP [RngByte]
    STA $7F100C, X
    LDA $0036
    LSR 
    BCC loc_09B1AE

  loc_09B187:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    JSR $&code_09B274
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    INC 
    AND #$00FF
    STA $orbitAngle, X
    LDA $7F100C, X
    DEC 
    STA $7F100C, X
    BPL loc_09B187
    COP [RestoreSavedPtr]

  loc_09B1AE:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    JSR $&code_09B274
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    DEC 
    AND #$00FF
    STA $orbitAngle, X
    LDA $7F100C, X
    DEC 
    STA $7F100C, X
    BPL loc_09B1AE
    COP [RestoreSavedPtr]
}

code_09B1D5 {
    LDA #$0001
    STA $26
    COP [SpawnLastRel] ( @func_0AA36E, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_09B1FA, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_09BA38, #00, #00, #$2000 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

code_09B1FA {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_09B21E, #00, #C8, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_09B22B, #00, #C8, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_09B21E {
    JSR $&code_09B238
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_09B22B {
    JSR $&code_09B238
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_09B238 {
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_09B255 {
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    RTS 
}
---------------------------------------------

byte_09B25C [
  #80   ;00
  #60   ;01
  #28   ;02
  #20   ;03
  #00   ;04
  #E0   ;05
  #C0   ;06
  #A0   ;07
]
---------------------------------------------

byte_09B264 [
  #29   ;00
  #30   ;01
  #2C   ;02
  #2F   ;03
  #2A   ;04
  #2E   ;05
  #2B   ;06
  #2D   ;07
]
---------------------------------------------

byte_09B26C [
  #04   ;00
  #03   ;01
  #02   ;02
  #01   ;03
  #00   ;04
  #07   ;05
  #06   ;06
  #05   ;07
]

code_09B274 {
    LDA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    PHX 
    TAX 
    LDA $@byte_09B264, X
    PLX 
    AND #$00FF
    STA $28
    RTS 
}

code_09B28D {
    COP [StageSprAndHitbox] ( #28 )
    STZ $08
    JSR $&code_09B2B8
    COP [SetEntryContinue]
    JSR $&code_09B2CD
    RTL 
}

code_09B29B {
    COP [StageSprAndHitbox] ( #28 )
    STZ $08
    JSR $&code_09B2B8
    COP [SetEntryContinue]
    JSR $&code_09B2CD
    LDA $0014, Y
    STA $14
    RTL 
}

code_09B2AE {
    COP [StageSprAndHitbox] ( #28 )
    COP [SetEntryContinue]
    JSL $@func_0AA41C
    RTL 
}

code_09B2B8 {
    LDA $14
    STA $7F100C, X
    STA $orbitAngle, X
    LDA $16
    STA $7F100E, X
    STA $orbitDiameter, X
    RTS 
}

code_09B2CD {
    LDY $06
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    CLC 
    BPL loc_09B2DB
    SEC 

  loc_09B2DB:
    ROR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    CLC 
    BPL loc_09B2EA
    SEC 

  loc_09B2EA:
    ROR 
    STA $16
    LDA $orbitAngle, X
    STA $7F100C, X
    LDA $orbitDiameter, X
    STA $7F100E, X
    LDY $04
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    RTS 
}

code_09B30E {
    JSR $&code_09BA14
    COP [SetDeathCallback] ( @code_09B3C6 )

  loc_09B316:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_09B31E {
    LDY $24
    LDA $0024, Y
    CMP #$0001
    BEQ loc_09B32E
    LDA $0036
    LSR 
    BCC loc_09B316

  loc_09B32E:
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @code_09B528, #10, #00, #$0202 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    LDA #$0010
    TSB $10
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    BRA loc_09B316
}

code_09B36A {
    JSR $&code_09BA14
    COP [SetDeathCallback] ( @code_09B3C6 )

  loc_09B372:
    COP [StageSpriteFrame] ( #85 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_09B37A {
    LDY $24
    LDA $0024, Y
    CMP #$0001
    BEQ loc_09B38A
    LDA $0036
    LSR 
    BCS loc_09B372

  loc_09B38A:
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #96 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @code_09B4E7, #F0, #00, #$0202 )
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #9B )
    COP [AnimOnce]
    LDA #$0010
    TSB $10
    COP [StageSpriteFrame] ( #85 )
    COP [AnimOnce]
    BRA loc_09B372
}

code_09B3C6 {
    LDA #$0001
    STA $26
    LDY $24
    LDA $0024, Y
    LSR 
    STA $0024, Y
    COP [SpawnLastRel] ( @code_09B479, #00, #00, #$0300 )
    LDA #$0002
    TSB $12

  loc_09B3E2:
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_09B3EA {
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #20 )
    COP [SpawnLastRel] ( @code_09B3FD, #00, #00, #$0302 )
    BRA loc_09B3E2
}

code_09B3FD {
    LDA #$0080
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #30 )
    COP [MoveToward] ( #0C, #02 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $0E
    BIT #$C000
    BEQ loc_09B447
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteLoopMoveY] ( #0E, #06, #0C )
    COP [AnimLoop]
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #0E )
    COP [SpawnAfterFlags] ( @code_09B449, #$0202 )
    COP [WaitByte] ( #0E )
    COP [LoopNext]

  loc_09B447:
    COP [Die]
}

code_09B449 {
    COP [PlaySoundCh1] ( #23 )
    COP [RngByte]
    STA $14
    COP [RngByte]
    LSR 
    BCS loc_09B467

  loc_09B455:
    COP [StageSpriteLoopMoveY] ( #0F, #14, #03 )
    COP [AnimLoop]
    LDA $16
    BMI loc_09B455
    CMP #$0120
    BCC loc_09B455
    COP [Die]

  loc_09B467:
    COP [StageSpriteLoopMoveY] ( #0F, #14, #05 )
    COP [AnimLoop]
    LDA $16
    BMI loc_09B467
    CMP #$0120
    BCC loc_09B467
    COP [Die]
}

code_09B479 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0002
    TSB $12

  loc_09B481:
    COP [RngByte]
    LDA $0036
    LSR 
    BCS loc_09B492
    COP [SpawnAfterFlags] ( @code_09B4C9, #$0302 )
    BRA loc_09B499

  loc_09B492:
    COP [SpawnAfterFlags] ( @code_09B4D8, #$0302 )

  loc_09B499:
    LDA $0410
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0411
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $16
    STA $0016, Y
    COP [StageSpriteLoopMoveY] ( #05, #07, #01 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_09B481
    COP [Die]
}

code_09B4C9 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_09B4D8 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_09B4E7 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0005
    STA $26

  loc_09B4EF:
    COP [SpawnAfterFlags] ( @code_09B500, #$0202 )
    LDA $26
    STA $0026, Y
    DEC 
    STA $26
    BNE loc_09B4EF
}

code_09B500 {
    COP [OrActorFlags] ( #$0010 )
    LDA $26
    PHX 
    TAX 
    LDA $@byte_09B57A, X
    AND #$00FF
    PLX 
    STA $moveYAlt, X
    LDA #$0008
    STA $moveXAlt, X
    COP [ReloadForceMove]
    COP [StageSpriteLoop] ( #11, #20 )
    COP [AnimLoop]
    COP [StageForceMoveX] ( #08 )
    BRA loc_09B567
}

code_09B528 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0005
    STA $26

  loc_09B530:
    COP [SpawnAfterFlags] ( @code_09B541, #$0202 )
    LDA $26
    STA $0026, Y
    DEC 
    STA $26
    BNE loc_09B530
}

code_09B541 {
    COP [OrActorFlags] ( #$0010 )
    LDA $26
    PHX 
    TAX 
    LDA $@byte_09B57A, X
    AND #$00FF
    PLX 
    STA $moveYAlt, X
    LDA #$0007
    STA $moveXAlt, X
    COP [ReloadForceMove]
    COP [StageSpriteLoop] ( #91, #20 )
    COP [AnimLoop]
    COP [StageForceMoveX] ( #07 )

  loc_09B567:
    COP [SetEntryContinue]
    LDA $10
    BIT #$4000
    BNE loc_09B571
    RTL 

  loc_09B571:
    LDA #$0014
    STA $08
    COP [SetEntryExit]
    COP [Die]
}
---------------------------------------------

byte_09B57A [
  #03   ;00
  #01   ;01
  #00   ;02
  #02   ;03
  #04   ;04
]

code_09B57F {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
}

code_09B586 {
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_09B58E {
    COP [LoopInit] ( #05 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_09B7A8, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_09B586

  loc_09B5AD:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_09B7A8, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    BRA code_09B586
}

code_09B5C7 {
    LDY $06
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0010
    STA $orbitDiameter, X
    LDA $16
    STA $7F100C, X
    LDA $16
    SEC 
    SBC #$0100
    STA $26
    COP [SetEntryContinue]
    LDA $16
    BEQ loc_09B62E
    SEC 
    SBC #$0002
    STA $16
    LDA #$FFFE
    STA $001C
    STZ $0018
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    JSR $&code_09B9CC
    LDA $16
    SEC 
    SBC $26
    BMI loc_09B618
    RTL 

  loc_09B618:
    EOR #$FFFF
    INC 
    STA $001C
    STZ $16
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    JSR $&code_09B9CC
    RTL 

  loc_09B62E:
    LDY $24
    LDA #$0003
    STA $0024, Y
    BRA loc_09B64D

  loc_09B638:
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0028
    STA $08
    COP [SetEntryExit]

  loc_09B64D:
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    CMP #$0040
    BEQ loc_09B638
    CMP #$00C0
    BEQ loc_09B638
    CLC 
    ADC #$0002
    AND #$00FF
    STA $orbitAngle, X
    JSR $&code_09BA59
    CLC 
    ADC $7F100C, X
    STA $16
    LDY $06
    LDA $20
    SEC 
    SBC $14
    EOR #$FFFF
    INC 
    STA $0018
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA $22
    SEC 
    SBC $16
    EOR #$FFFF
    INC 
    STA $001C
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $14
    STA $20
    LDA $16
    STA $22
    JSR $&code_09B9CC
    RTL 
}

code_09B6A6 {
    LDA $14
    STA $orbitAngle, X
    COP [LoopInit] ( #80 )
    COP [RngByte]
    LDA $16
    CLC 
    ADC #$0002
    STA $16
    LDA #$0002
    STA $001C
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $14
    PHA 
    LDA $0410
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $orbitAngle, X
    STA $14
    SEC 
    SBC $01, S
    STA $0018
    PLA 
    LDA $0018
    CLC 
    ADC $0014, Y
    STA $0014, Y
    JSR $&code_09B9CC
    COP [LoopNext]
    LDY $06
    LDA #$0000
    STA $0026, Y
    COP [Die]
}

code_09B6FC {
    LDY $24
    LDA $0026, Y
    BNE loc_09B70A
    COP [PaletteStart] ( #63 )
    COP [PaletteStep]
    BRA code_09B6FC

  loc_09B70A:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    CMP #$0002
    BEQ loc_09B717
    RTL 

  loc_09B717:
    COP [Die]
}

code_09B719 {
    COP [PaletteStart] ( #62 )
    COP [PaletteStep]
    COP [RngByte]
    CMP #$00C0
    BCC loc_09B73E
    COP [PaletteStart] ( #66 )
    COP [PaletteStep]
    COP [RngByte]
    AND #$0007
    CLC 
    ADC #$0004
    STA $08
    COP [SetEntryExit]
    COP [PaletteStart] ( #66 )
    COP [PaletteStep]
    COP [RngByte]

  loc_09B73E:
    STA $08
    STA $072A
    COP [SetEntryExit]
    BRA code_09B719
}

code_09B747 {
    COP [SetSpritePriority] ( #30 )
    LDA #$00A0
    STA $14
    LDA #$00C0
    STA $16
    COP [SetEntryContinue]
    LDY $24
    LDA $0016, Y
    SEC 
    SBC #$0030
    SEC 
    SBC $16
    BMI loc_09B765
    RTL 

  loc_09B765:
    COP [SetEntryContinue]
    COP [SpawnAfterFlags] ( @code_09B787, #$0300 )
    LDA $0410
    AND #$0003
    CLC 
    ADC #$0005
    STA $08
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_09B785
    RTL 

  loc_09B785:
    COP [Die]
}

code_09B787 {
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $16
    STA $16
    LDA $0411
    AND #$0003
    CLC 
    ADC $14
    STA $14
    COP [StageSpriteMoveX] ( #15, #08 )
    COP [AnimOnce]
    COP [Die]
}

code_09B7A8 {
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    LDA $0E
    BIT #$4000
    BEQ loc_09B7C1
    COP [AddPosition] ( #04, #FA )
    COP [StageForceMoveXY] ( #01, #02 )
    BRA loc_09B7C9

  loc_09B7C1:
    COP [AddPosition] ( #FC, #FA )
    COP [StageForceMoveXY] ( #02, #02 )

  loc_09B7C9:
    LDA #$0020
    TSB $12
    LDA #$0000
    STA $currentHp, X
    COP [SetDeathCallback] ( @code_09B84F )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    LDA #$&loc_09B802
    STA $retPtr2, X
    STA $00
    LDA $0B02
    CLC 
    ADC #$0005
    STA $loopCounter, X

  loc_09B802:
    COP [SetEntryContinue]
    COP [RngByte]
    LDY $playerActor
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0014, Y
    STA $moveXAlt, X
    BPL loc_09B81B
    RTL 

  loc_09B81B:
    CMP #$0108
    BCC loc_09B821
    RTL 

  loc_09B821:
    LDA $0411
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0016, Y
    STA $moveYAlt, X
    BPL loc_09B836
    RTL 

  loc_09B836:
    CMP #$00E8
    BCC loc_09B83C
    RTL 

  loc_09B83C:
    COP [MoveToward] ( #18, #02 )
    LDA $10
    BIT #$4000
    BNE loc_09B87E
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [LoopNext]
}

code_09B84F {
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $16
    SEC 
    SBC #$0008
    STA $16
    LDA #$0003
    STA $24

  loc_09B861:
    COP [SpawnAfterFlags] ( @code_09B880, #$0202 )
    DEC $24
    BPL loc_09B861
    STZ $24
    LDA $16
    CLC 
    ADC #$0004
    STA $16
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_09B87E:
    COP [Die]
}

code_09B880 {
    PEA $&code_09B8AF-1
    LDY $24
    LDA $0024, Y
    INC 
    STA $0024, Y
    CMP #$0001
    BEQ loc_09B8AA
    CMP #$0002
    BEQ loc_09B8A5
    CMP #$0003
    BEQ loc_09B8A0
    COP [StageForceMoveXY] ( #01, #01 )
    RTS 

  loc_09B8A0:
    COP [StageForceMoveXY] ( #01, #02 )
    RTS 

  loc_09B8A5:
    COP [StageForceMoveXY] ( #02, #01 )
    RTS 

  loc_09B8AA:
    COP [StageForceMoveXY] ( #02, #02 )
    RTS 
}

code_09B8AF {
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_09B8B6 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveY] ( #12, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #02 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1E )
    COP [RngByte]
    STA $26
    COP [SpawnAfterFlags] ( @code_09B8F3, #$0202 )
    LDA $26
    CLC 
    ADC #$0055
    AND #$00FF
    STA $0026, Y
    COP [SpawnAfterFlags] ( @code_09B8F3, #$0202 )
    LDA $26
    CLC 
    ADC #$00AA
    AND #$00FF
    STA $0026, Y
}

code_09B8F3 {
    LDA $26
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0001
    STA $7F100E, X
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #13 )

  loc_09B91A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_09B91A
    LDA $08
    STZ $08
    STA $26

  loc_09B926:
    COP [SetEntryExit]
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CLC 
    ADC #$04
    STA $orbitDiameter, X
    BCS loc_09B970
    REP #$20
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3
    PLA 
    SEC 
    SBC $16
    STA $7F100E, X
    PLA 
    SEC 
    SBC $14
    STA $7F100C, X
    DEC $26
    BPL loc_09B926
    BRA loc_09B91A

  loc_09B970:
    REP #$20
    LDA #$6000
    TRB $12
    LDA $7F100C, X
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA $7F100E, X
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BRA loc_09B99F

  loc_09B991:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_09B991
    LDA $08
    STZ $08
    STA $26

  loc_09B99D:
    COP [SetEntryExit]

  loc_09B99F:
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_09B9BC
    DEC $26
    BPL loc_09B99D
    BRA loc_09B991

  loc_09B9BC:
    COP [Die]
}

code_09B9BE {
    COP [PaletteStart] ( #6A )
    COP [PaletteStep]
    COP [Die]
}

code_09B9C5 {
    COP [PaletteStart] ( #69 )
    COP [PaletteStep]
    COP [Die]
}

code_09B9CC {
    PHX 
    LDX $0006, Y
    STY $0000

  loc_09B9D3:
    LDA $0000
    CMP $parentId, X
    BNE loc_09B9F6
    LDA $0014, X
    CLC 
    ADC $0018
    STA $0014, X
    LDA $0016, X
    CLC 
    ADC $001C
    STA $0016, X
    LDA $0006, X
    TAX 
    BRA loc_09B9D3

  loc_09B9F6:
    PLX 
    LDA $0018
    EOR #$FFFF
    INC 
    CLC 
    ADC $cameraDeltaX
    STA $cameraDeltaX
    LDA $001C
    EOR #$FFFF
    INC 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    RTS 
}

code_09BA14 {
    LDA #$8011
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080
    STA $extendedFlags, X
    LDA #$&enemy_stats_table+154
    STA $statsPtr, X
    LDA $&enemy_stats_table+154
    AND #$00FF
    STA $currentHp, X
    STZ $26
    RTS 
}

code_09BA38 {
    LDA #$8000
    TSB $joypadMaskStd
    COP [WaitByte] ( #EF )
    LDA #$0000
    STA $characterForm
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_09BA59 {
    LDA $orbitAngle, X
    TAY 
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.sine_table_8bit, Y
    BPL loc_09BA6A
    EOR #$FF
    INC 
    SEC 

  loc_09BA6A:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_09BA7F
    EOR #$FFFF
    INC 

  loc_09BA7F:
    RTS 
}