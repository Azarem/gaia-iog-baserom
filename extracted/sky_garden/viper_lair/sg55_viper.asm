?INCLUDE 'cop_handlers_flags'
?INCLUDE 'hardware_math'
?INCLUDE 'sE6_gaia'
?INCLUDE 'SetPlayerGameOverFlag'
?INCLUDE 'sg55_viper_arena'
?INCLUDE 'sprite_composition'
?INCLUDE 'spriteset_enemies'
?INCLUDE 'StandardEnemyDefeatHandler'

!extVelocityX                   0408
!extVelocityY                   040A
!rngModuloResult                0420
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetY                  06C2
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!scratch1010                    7F1010

---------------------------------------------

btF3_neo_viper [
  actor-def < #00, #00, #00, {

  code_0AD0D8:
    LDA #$0011
    TSB $12
    LDA #$0100
    STA $cameraBoundsY
    COP [SpawnLastRel] ( @code_0AD125, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0AD0F7
    JMP $&code_0AD1D5

  loc_0AD0F7:
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_WillToShadow
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_WillToShadow
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0AD11D
    RTL 

  loc_0AD11D:
    COP [SetDeathCallback] ( @code_0AD945 )
    JMP $&code_0AD1D5
} >
]

code_0AD125 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0AD12D
    RTL 

  loc_0AD12D:
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_ShadowToWill
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_ShadowToWill
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0AD153
    RTL 

  loc_0AD153:
    COP [SetFlagWord] ( #$0176 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$03F8, #$02A0, #03, #$3820 )
    COP [Die]
}

sg55_viper [
  actor-def < #00, #00, #00, {

  code_0AD172:
    LDA #$0001
    JSL $@cop_handlers_flags.TestWramFlag_Offset100
    BCC loc_0AD183
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0AD183:
    LDA #$0011
    TSB $12
    COP [SetDeathCallback] ( @code_0AD945 )
    LDA #$*binary_0AD93D
    AND #$00FF
    STA $0AF6
    LDA #$&binary_0AD93D
    STA $0AF4
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #01 )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #27 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $playerYPos
    CMP #$00A0
    BCC loc_0AD1BC
    RTL 

  loc_0AD1BC:
    LDA #$0130
    STA $cameraBoundsY
    COP [LoopInit] ( #30 )
    LDA $cameraBoundsY
    DEC 
    STA $cameraBoundsY
    COP [LoopNext]
    COP [SpawnBeforeFlags] ( @sg55_viper_arena, #$2800 )
} >
]

code_0AD1D5 {
    COP [SpawnAfter] ( @code_0AD27E )
    LDA #$FFD0
    STA $0018, Y
    LDA #$0030
    STA $001C, Y
    LDA #$0000
    STA $001A, Y
    LDA #$0080
    STA $001E, Y
    LDA #$0001
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    LDA #$0006
    STA $002E, Y

  code_0AD204:
    LDA #$0010
    STA $24
    COP [CallScript] ( &code_0AD306 )
    STZ $24
    COP [CallScript] ( &code_0AD2DA )
    COP [CallScript] ( &code_0AD380 )
    STZ $24
    COP [CallScript] ( &code_0AD2DA )
    STZ $24
    COP [CallScript] ( &code_0AD306 )
    LDA #$FFA0
    STA $24
    COP [CallScript] ( &code_0AD306 )
    LDA #$FFD0
    STA $24
    COP [CallScript] ( &code_0AD2DA )
    COP [InitGravity] ( #00, #09, #00 )
    COP [StageSprAndHitbox] ( #00 )

  loc_0AD23D:
    COP [TickGravity]
    COP [SetEntryExit]
    LDA $16
    BMI loc_0AD23D
    CMP #$0030
    BCC loc_0AD23D
    COP [StageSpriteMoveY] ( #00, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #01, #02, #13 )
    COP [AnimLoop]
    COP [SetSavedPtr] ( &code_0AD265 )
    COP [BranchOnPlayerX] ( #$0020, &code_0AD65F, &code_0AD63D, &code_0AD686 )
}

code_0AD265 {
    STZ $24
    COP [CallScript] ( &code_0AD306 )
    STZ $24
    COP [CallScript] ( &code_0AD2DA )
    COP [CallScript] ( &code_0AD4B3 )
    COP [StageSpriteLoop] ( #00, #02 )
    COP [AnimLoop]
    JMP $&code_0AD204
}

code_0AD27E {
    LDY $24
    LDA $0028, Y
    CMP $28
    BNE loc_0AD2D9
    LDA $0014, Y
    SEC 
    SBC #$0008
    CLC 
    ADC $18
    CMP $playerXPos
    BCS loc_0AD2D9
    SEC 
    SBC $18
    CLC 
    ADC $1C
    CMP $playerXPos
    BCC loc_0AD2D9
    LDA $0016, Y
    SEC 
    SBC #$0010
    CLC 
    ADC $1A
    CMP $playerYPos
    BCS loc_0AD2D9
    SEC 
    SBC $1A
    CLC 
    ADC $1E
    CMP $playerYPos
    BCC loc_0AD2D9
    LDY #$1000
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0AD2C7
    RTL 

  loc_0AD2C7:
    LDA $2C
    CLC 
    ADC $extVelocityX
    STA $extVelocityX
    LDA $2E
    CLC 
    ADC $extVelocityY
    STA $extVelocityY

  loc_0AD2D9:
    RTL 
}

code_0AD2DA {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $playerXPos
    STA $moveXAlt, X
    LDA $0410
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC #$0050
    CLC 
    ADC $24
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #04 )
    COP [RestoreSavedPtr]
}

code_0AD306 {
    LDA $16
    CLC 
    ADC $24
    STA $7F100E, X
    LDA #$0000
    STA $orbitAngle, X
    COP [BranchOnPlayerX] ( #$0000, &code_0AD320, &code_0AD320, &code_0AD325 )
}

code_0AD320 {
    LDA #$4000
    TSB $12
}

code_0AD325 {
    LDA #$2000
    TSB $12
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_0AD339
    EOR #$FFFF
    INC 

  loc_0AD339:
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    INC 
    STA $26
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [InitGravity] ( #03, #09, #00 )
    COP [StageSprAndHitbox] ( #00 )

  loc_0AD352:
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch1, X
    COP [TickGravity]
    LDA $orbitAngle, X
    DEC 
    BPL loc_0AD36B
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08

  loc_0AD36B:
    STA $orbitAngle, X
    LDA $16
    BMI loc_0AD379
    CMP $7F100E, X
    BCS loc_0AD352

  loc_0AD379:
    LDA #$6000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AD380 {
    COP [StageSpriteLoop] ( #01, #03 )
    COP [AnimLoop]
    COP [StageForceMoveY] ( #13 )
    COP [WaitByte] ( #27 )
    COP [StageForceMoveY] ( #00 )
    COP [SpawnAfterFlags] ( @code_0AD398, #$0200 )
    COP [RestoreSavedPtr]
}

code_0AD398 {
    COP [PlaySoundCh1] ( #1E )
    LDA $playerXPos
    STA $moveXAlt, X
    LDA $playerYPos
    STA $moveYAlt, X
    COP [MoveToward] ( #05, #02 )
    COP [LoopInit] ( #0A )
    COP [SetSpritePalette] ( #08 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #1D )
    COP [SpawnAfterFlags] ( @code_0AD3E6, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD451, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD3DD, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD448, #$0200 )
    COP [SetEntryExit]
    COP [Die]
}

code_0AD3DD {
    COP [SetHFlip]
    COP [ToggleVFlip]
    LDA #$6002
    TSB $12
}

code_0AD3E6 {
    COP [OrActorFlags] ( #$0010 )
    LDY $24
    LDA $002A, Y
    DEC 
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD3FC )
}

code_list_0AD3FC [
  &code_0AD404   ;00
  &code_0AD415   ;01
  &code_0AD426   ;02
  &code_0AD437   ;03
]

code_0AD404 {
    COP [StageSpriteLoopMoveXY] ( #1D, #20, #02, #00 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD404
    COP [Die]
}

code_0AD415 {
    COP [StageSpriteLoopMoveXY] ( #1E, #20, #17, #14 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD415
    COP [Die]
}

code_0AD426 {
    COP [StageSpriteLoopMoveXY] ( #1F, #20, #12, #12 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD426
    COP [Die]
}

code_0AD437 {
    COP [StageSpriteLoopMoveXY] ( #20, #20, #14, #17 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD437
    COP [Die]
}

code_0AD448 {
    COP [SetHFlip]
    COP [ToggleVFlip]
    LDA #$6002
    TSB $12
}

code_0AD451 {
    COP [OrActorFlags] ( #$0010 )
    LDY $24
    LDA $002A, Y
    DEC 
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD467 )
}

code_list_0AD467 [
  &code_0AD46F   ;00
  &code_0AD480   ;01
  &code_0AD491   ;02
  &code_0AD4A2   ;03
]

code_0AD46F {
    COP [StageSpriteLoopMoveXY] ( #19, #20, #00, #01 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD46F
    COP [Die]
}

code_0AD480 {
    COP [StageSpriteLoopMoveXY] ( #1A, #20, #14, #16 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD480
    COP [Die]
}

code_0AD491 {
    COP [StageSpriteLoopMoveXY] ( #1B, #20, #12, #11 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD491
    COP [Die]
}

code_0AD4A2 {
    COP [StageSpriteLoopMoveXY] ( #1C, #20, #17, #13 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD4A2
    COP [Die]
}

code_0AD4B3 {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    STA $orbitAngle, X
    COP [StageSpriteLoop] ( #01, #03 )
    COP [AnimLoop]
    LDA #$0000

  loc_0AD4C9:
    STA $24
    COP [SpawnAfterFlags] ( @code_0AD4EE, #$2200 )
    TXA 
    TYX 
    TAY 
    LDA $24
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA $24
    INC 
    CMP #$0006
    BCC loc_0AD4C9
    LDA $orbitAngle, X
    STA $24
    COP [RestoreSavedPtr]
}

code_0AD4EE {
    COP [PlaySoundCh1] ( #1E )
    COP [OrActorFlags] ( #$0010 )
    LDA $orbitAngle, X
    CMP #$0006
    BCC loc_0AD501
    LDA #$0005

  loc_0AD501:
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD50A )
}

code_list_0AD50A [
  &code_0AD516   ;00
  &code_0AD51F   ;01
  &code_0AD528   ;02
  &code_0AD531   ;03
  &code_0AD53A   ;04
  &code_0AD543   ;05
]

code_0AD516 {
    COP [AddPosition] ( #10, #E0 )
    LDA #$0020
    BRA loc_0AD54A
}

code_0AD51F {
    COP [AddPosition] ( #F0, #E0 )
    LDA #$0040
    BRA loc_0AD54A
}

code_0AD528 {
    COP [AddPosition] ( #20, #E0 )
    LDA #$0030
    BRA loc_0AD54A
}

code_0AD531 {
    COP [AddPosition] ( #E0, #E0 )
    LDA #$0030
    BRA loc_0AD54A
}

code_0AD53A {
    COP [AddPosition] ( #30, #E0 )
    LDA #$0040
    BRA loc_0AD54A
}

code_0AD543 {
    COP [AddPosition] ( #D0, #E0 )
    LDA #$0020

  loc_0AD54A:
    STA $7F100E, X
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    LDY $24
    LDA $0024, Y
    BPL loc_0AD565
    COP [ClearHFlip]
    LDA #$4000
    TSB $12
    BRA loc_0AD56C

  loc_0AD565:
    COP [SetHFlip]
    LDA #$0002
    TSB $12

  loc_0AD56C:
    LDA $7F100E, X
    TAY 
    LDA #$0005
    SEP #$20
    JSL $@hardware_math.UnsignedDivide
    REP #$20
    AND #$00FF
    STA $orbitAngle, X
    STA $orbitDiameter, X
    COP [StageSprAndHitbox] ( #19 )
    LDA #$0000
    STA $7F100C, X
    STA $scratch1010, X
    STA $scratch1010+2, X
    COP [SetEntryContinue]
    LDA $7F100E, X
    BEQ loc_0AD5D2
    DEC 
    STA $7F100E, X
    LDA $7F100C, X
    INC 
    STA $7F100C, X
    LDA $orbitDiameter, X
    DEC 
    STA $orbitDiameter, X
    BNE loc_0AD5D2
    LDA $orbitAngle, X
    STA $orbitDiameter, X
    LDA $28
    INC 
    CMP #$001E
    BCS loc_0AD5D2
    STA $28
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation

  loc_0AD5D2:
    LDA $7F100C, X
    CLC 
    ADC $scratch1010, X
    STA $scratch1010, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $moveScratch1, X
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC $scratch1010, X
    EOR #$FFFF
    INC 
    STA $scratch1010, X
    LDA $7F100E, X
    CLC 
    ADC $scratch1010+2, X
    STA $scratch1010+2, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $moveScratch2, X
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC $scratch1010+2, X
    EOR #$FFFF
    INC 
    STA $scratch1010+2, X
    LDA $0036
    LSR 
    BCC loc_0AD629
    COP [SetSpritePalette] ( #08 )
    BRA loc_0AD62C

  loc_0AD629:
    COP [SetSpritePalette] ( #00 )

  loc_0AD62C:
    LDA $14
    BMI loc_0AD63B
    SEC 
    SBC $cameraBoundsX
    CLC 
    ADC #$0010
    BPL loc_0AD63B
    RTL 

  loc_0AD63B:
    COP [Die]
}

code_0AD63D {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD779, #00, #E1, #$0202 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD848, #00, #00, #$0202 )
    COP [SetHitCallback] ( &code_0AD6F6 )
    BRA loc_0AD6AB
}

code_0AD65F {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD7DA, #FD, #DD, #$0202 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD880, #F4, #FE, #$0202 )
    COP [SetHitCallback] ( &code_0AD6BC )
    BRA loc_0AD6AB
}

code_0AD686 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #83 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD7C9, #03, #DD, #$0202 )
    COP [StageSpriteFrame] ( #83 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD8B8, #0C, #FE, #$0202 )
    COP [SetHitCallback] ( &code_0AD6D9 )

  loc_0AD6AB:
    LDA #$0003
    STA $sprTimer, X
    COP [SetEntryContinue]
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
    COP [RestoreSavedPtr]
}

code_0AD6BC {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD751, &code_0AD6C6, &code_0AD6CD )
}

code_0AD6C6 {
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    BRA loc_0AD70E
}

code_0AD6CD {
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    BRA loc_0AD725
}

code_0AD6D9 {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD6EA, &code_0AD6E3, &code_0AD751 )
}

code_0AD6E3 {
    COP [StageSpriteFrame] ( #89 )
    COP [AnimOnce]
    BRA loc_0AD70E
}

code_0AD6EA {
    COP [StageSpriteFrame] ( #89 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    BRA loc_0AD73C
}

code_0AD6F6 {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD700, &code_0AD751, &code_0AD707 )
}

code_0AD700 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    BRA loc_0AD73C
}

code_0AD707 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    BRA loc_0AD725

  loc_0AD70E:
    COP [StageSprAndHitbox] ( #02 )
    COP [SpawnMarkedAfterRel] ( @code_0AD771, #00, #E1, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD848, #00, #00, #$0202 )
    BRA code_0AD751

  loc_0AD725:
    COP [StageSprAndHitbox] ( #83 )
    COP [SpawnMarkedAfterRel] ( @code_0AD7BA, #03, #DD, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD8B8, #0C, #FE, #$0202 )
    BRA code_0AD751

  loc_0AD73C:
    COP [StageSprAndHitbox] ( #03 )
    COP [SpawnMarkedAfterRel] ( @code_0AD7D2, #03, #DD, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD880, #F4, #FE, #$0202 )
}

code_0AD751 {
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA #$6000
    TRB $12
    LDA $14
    STA $moveXAlt, X
    LDA $cameraTargetY
    SEC 
    SBC #$0040
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #04 )
    COP [RestoreSavedPtr]
}

code_0AD771 {
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD79C
}

code_0AD779 {
    LDA $24
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #24 )
    COP [LoopInit] ( #30 )
    JSR $&code_0AD832
    BCC loc_0AD78D
    JMP $&code_0AD818

  loc_0AD78D:
    COP [LoopNext]
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #17 )
    LDA #$2000
    TRB $10

  loc_0AD79C:
    COP [StageSprAndHitbox] ( #25 )
    STZ $24

  loc_0AD7A1:
    COP [SetEntryContinue]
    JSR $&code_0AD832
    BCS code_0AD818
    DEC $24
    BMI loc_0AD7AD
    RTL 

  loc_0AD7AD:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    INC 
    STA $24
    STZ $08
    BRA loc_0AD7A1
}

code_0AD7BA {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD7FA
}

code_0AD7C9 {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    BRA code_0AD7DA
}

code_0AD7D2 {
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD7FA
}

code_0AD7DA {
    LDA $24
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #26 )
    COP [LoopInit] ( #30 )
    JSR $&code_0AD832
    BCS code_0AD818
    COP [LoopNext]
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #17 )
    LDA #$2000
    TRB $10

  loc_0AD7FA:
    COP [StageSprAndHitbox] ( #27 )
    STZ $24

  loc_0AD7FF:
    COP [SetEntryContinue]
    JSR $&code_0AD832
    BCS code_0AD818
    DEC $24
    BMI loc_0AD80B
    RTL 

  loc_0AD80B:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    INC 
    STA $24
    STZ $08
    BRA loc_0AD7FF
}

code_0AD818 {
    COP [Die]

  code_0AD81A:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryExit]
    JSR $&code_0AD832
    BCS code_0AD818
    DEC $24
    BMI loc_0AD830
    RTL 

  loc_0AD830:
    COP [RestoreSavedPtr]
}

code_0AD832 {
    LDA $orbitAngle, X
    TAY 
    LDA $0028, Y
    CMP #$0002
    BEQ loc_0AD844
    CMP #$0003
    BNE loc_0AD846

  loc_0AD844:
    CLC 
    RTS 

  loc_0AD846:
    SEC 
    RTS 
}

code_0AD848 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $24
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0D )

  loc_0AD860:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD81A )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD860
    COP [SpawnLastRel] ( @code_0AD8F7, #00, #30, #$0200 )
    BRA loc_0AD860
}

code_0AD880 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0000
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0F )

  loc_0AD898:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD81A )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD898
    COP [SpawnLastRel] ( @code_0AD8F7, #C0, #20, #$0200 )
    BRA loc_0AD898
}

code_0AD8B8 {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0000
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0F )

  loc_0AD8D7:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD81A )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD8D7
    COP [SpawnLastRel] ( @code_0AD8F7, #40, #20, #$0200 )
    BRA loc_0AD8D7
}

code_0AD8F7 {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0000
    STA $moveYAlt, X
    COP [RngByte]
    AND #$0007
    CMP #$0007
    BNE loc_0AD90F
    LDA #$0003

  loc_0AD90F:
    STA $moveXAlt, X
    LSR 
    LDA #$0000
    ADC #$0021
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [ReloadForceMove]
    COP [SetEntryExit]
    COP [InitGravity] ( #03, #04, #01 )
    COP [SetEntryContinue]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0AD935
    RTL 

  loc_0AD935:
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [Die]
}

binary_0AD93D #4CF8003000000022

code_0AD945 {
    LDA $playerFlags
    BIT #$0200
    BEQ loc_0AD950
    COP [SetEntryContinue]
    RTL 

  loc_0AD950:
    LDA #$0020
    TSB $playerFlags
    COP [SpawnLastRel] ( @SetPlayerGameOverFlag, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0AD970, #00, #00, #$2300 )
    COP [WaitByte] ( #27 )
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

code_0AD970 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_0AD994, #00, #E0, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0AD9A1, #00, #E0, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_0AD994 {
    JSR $&code_0AD9AB
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0AD9A1 {
    JSR $&code_0AD9AB
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0AD9AB {
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #50 )
    LDA $rngModuloResult
    SEC 
    SBC #$0028
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