?INCLUDE 'cop_handlers_actors'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'func_0AA36E'
?INCLUDE 'sE6_gaia'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!bg2ScrollH                     068E
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!WOBJSEL                        2125
!CGWSEL                         2130
!CGADSUB                        2131
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020

---------------------------------------------

btF4_neo_male_vampire [
  actor-def < #00, #00, #00, {

  code_0AF153:
    LDA #$8011
    TSB $12
    COP [SpawnLastRel] ( @code_0AF1AD, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @func_0AF6E6, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0AF173
    JMP $&code_0AF23E

  loc_0AF173:
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
    BEQ loc_0AF199
    RTL 

  loc_0AF199:
    JMP $&code_0AF23E
} >
]
---------------------------------------------

btF4_neo_female_vampire [
  actor-def < #16, #00, #00, {

  code_0AF19F:
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0AF1AA
    RTL 

  loc_0AF1AA:
    JMP $&code_0AF3E6
} >
]

code_0AF1AD {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0AF1B5
    RTL 

  loc_0AF1B5:
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
    BEQ loc_0AF1DB
    RTL 

  loc_0AF1DB:
    COP [SetFlagWord] ( #$0177 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$02F8, #$01A0, #03, #$2810 )
    COP [Die]
}
---------------------------------------------

mu67_male_vampire [
  actor-def < #00, #00, #01, {

  code_0AF1FA:
    COP [SpawnAfterFlags] ( @code_0AF53D, #$2800 )
    COP [SpawnAfterFlags] ( @func_0AF6E6, #$2000 )
    LDA #$FFFF
    STA $00FE
    COP [BranchIfPlayerAt] ( #$0180, #$0060, &func_0AFA48 )
    COP [BranchIfPlayerAt] ( #$0180, #$01E0, &func_0AFA48 )
    LDA #$0002
    JSL $@cop_handlers_script.TestWramFlag_Offset100
    BCC loc_0AF22F
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0AF22F:
    LDA #$*binary_0AFA51
    AND #$00FF
    STA $0AF6
    LDA #$&binary_0AFA51
    STA $0AF4
} >
]

code_0AF23E {
    COP [SetDeathCallback] ( @func_0AFA59 )
    LDA #$8011
    TSB $12
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF27E )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_0AF259 )
    RTL 
}

code_0AF259 {
    COP [ExitIfFlagByte] ( #86, #01 )
    LDA $14
    STA $moveXAlt, X
    LDA #$0100
    STA $moveYAlt, X
    COP [StageMove] ( #01, #02, #FF )
    COP [TickMove]
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF27E )
    COP [SetFlagByte] ( #87 )
    COP [PrintWideString] ( &widestring_0AFB45 )
}

code_0AF27E {
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AF2A2
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundCh1] ( #0E )
    COP [WaitByte] ( #0E )
    COP [StageBgChange] ( #92 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #91 )
    COP [ApplyBgChange]
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #27 )

  loc_0AF2A2:
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #02 )
    COP [SpawnMarkedAfter] ( @code_0AF876, #$2200 )
    STZ $09F0
    STZ $09F2
    BRA loc_0AF2CA

  code_0AF2BD:
    JSR $&sub_0AFA17
    COP [StageMove] ( #01, #02, #FF )
    COP [TickMove]
    COP [WaitByte] ( #1D )

  loc_0AF2CA:
    LDA $00F2
    BEQ loc_0AF313

  code_0AF2CF:
    JSR $&sub_0AF961
    COP [SetHitCallback] ( &code_0AF39D )
    COP [StageMove] ( #01, #02, #FF )
    COP [TickMove]
    COP [WaitByte] ( #13 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @code_0AF8AC, #00, #00, #$2200 )
    COP [SpawnLastRel] ( @code_0AF8C7, #00, #00, #$2200 )
    COP [SpawnLastRel] ( @code_0AF8E2, #00, #00, #$2200 )
    COP [SpawnLastRel] ( @code_0AF8FD, #00, #00, #$2200 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    BRA loc_0AF2CA

  loc_0AF313:
    LDA $09F2
    BEQ loc_0AF31B
    JMP $&code_0AF394

  loc_0AF31B:
    COP [SetHitCallback] ( #$0000 )
    LDA #$0001
    STA $09F0
    COP [SetEntryExit]
    LDA $09F2
    BEQ loc_0AF32F
    JMP $&code_0AF394

  loc_0AF32F:
    LDA $09F0
    BEQ loc_0AF341
    COP [SetEntryContinue]
    LDA $09F2
    BNE code_0AF394
    LDA $09F0
    BEQ loc_0AF341
    RTL 

  loc_0AF341:
    LDA $playerYPos
    STA $moveYAlt, X
    LDA #$00B8
    STA $moveXAlt, X
    COP [StageMove] ( #01, #04, #FF )
    COP [TickMove]
    LDA $09F2
    BNE code_0AF394
    LDA #$0001
    STA $09F0
    COP [SetEntryExit]
    LDA $09F2
    BNE code_0AF394
    LDA $09F0
    BEQ loc_0AF36E
    RTL 

  loc_0AF36E:
    LDA #$0200
    TSB $10
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #43, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [WaitByte] ( #17 )
    COP [SpawnLastRel] ( @code_0AF619, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
}

code_0AF394 {
    LDA #$0001
    STA $00F2
    JMP $&code_0AF2CF
}

code_0AF39D {
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [SpawnMarkedAfter] ( @code_0AF712, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF718, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF71E, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF724, #$0200 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    JMP $&code_0AF2BD
}
---------------------------------------------

mu67_female_vampire [
  actor-def < #17, #00, #01, {

  code_0AF3CB:
    COP [BranchIfPlayerAt] ( #$0180, #$0060, &func_0AFA48 )
    COP [BranchIfPlayerAt] ( #$0180, #$01E0, &func_0AFA48 )
    LDA #$0002
    JSL $@cop_handlers_script.TestWramFlag_Offset100
    BCC code_0AF3E6
    COP [Die]
} >
]

code_0AF3E6 {
    COP [SetDeathCallback] ( @code_0AFAA0 )
    LDA #$8011
    TSB $12
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF41D )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_0AF401 )
    RTL 
}

code_0AF401 {
    COP [ExitIfFlagByte] ( #86, #01 )
    LDA $14
    STA $moveXAlt, X
    LDA #$0100
    STA $moveYAlt, X
    COP [StageMove] ( #17, #02, #FF )
    COP [TickMove]
    COP [ExitIfFlagByte] ( #02, #01 )
}

code_0AF41D {
    COP [SpawnMarkedAfter] ( @code_0AF7B6, #$2200 )
    BRA loc_0AF433
}
---------------------------------------------

func_0AF426 {
    JSR $&sub_0AFA17
    COP [StageMove] ( #17, #02, #FF )
    COP [TickMove]
    COP [WaitByte] ( #3B )

  loc_0AF433:
    LDA $00F2
    BEQ loc_0AF455
    COP [SetHitCallback] ( &func_0AF50F )
    STZ $00F0
    JSR $&sub_0AF9A8
    COP [StageMove] ( #17, #02, #FF )
    COP [TickMove]
    COP [SetHitCallback] ( #$0000 )
    INC $00F0
    COP [WaitByte] ( #07 )
    BRA loc_0AF433

  loc_0AF455:
    LDA $09F2
    BNE loc_0AF4BE
    COP [SetHitCallback] ( #$0000 )
    INC $00F0
    COP [SetEntryContinue]
    LDA $09F2
    BNE loc_0AF4BE
    LDA $09F0
    BNE loc_0AF46E
    RTL 

  loc_0AF46E:
    STZ $09F0
    COP [SetEntryExit]
    LDA $playerYPos
    STA $moveYAlt, X
    LDA #$0048
    STA $moveXAlt, X
    COP [StageMove] ( #17, #04, #FF )
    COP [TickMove]
    COP [SetEntryContinue]
    LDA $09F2
    BNE loc_0AF4BE
    LDA $09F0
    BNE loc_0AF495
    RTL 

  loc_0AF495:
    STZ $09F0
    LDA #$0200
    TSB $10
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [WaitByte] ( #17 )
    COP [SpawnLastRel] ( @code_0AF551, #00, #00, #$0202 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    JMP $&func_0AF426

  loc_0AF4BE:
    LDA #$0001
    STA $00F2
    JMP $&func_0AF426
}
---------------------------------------------

func_0AF4C7 {
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF8A5, #00, #00, #$2200 )
    JMP $&func_0AF426
}
---------------------------------------------

func_0AF4D9 {
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF8C0, #00, #00, #$2200 )
    JMP $&func_0AF426
}
---------------------------------------------

func_0AF4EB {
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF8DB, #00, #00, #$2200 )
    JMP $&func_0AF426
}
---------------------------------------------

func_0AF4FD {
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF8F6, #00, #00, #$2200 )
    JMP $&func_0AF426
}
---------------------------------------------

func_0AF50F {
    INC $00F0
    COP [StageSpriteLoop] ( #17, #02 )
    COP [AnimLoop]
    COP [SpawnMarkedAfter] ( @code_0AF72D, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF733, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF739, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF73F, #$0200 )
    COP [StageSpriteLoop] ( #17, #02 )
    COP [AnimLoop]
    JMP $&func_0AF426
}

code_0AF53D {
    SEP #$20
    LDA #$30
    STA $WOBJSEL
    LDA #$22
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    RTL 
}

code_0AF551 {
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AF562
    LDA #$&stats_01ABF0+C4
    STA $statsPtr, X
    BRA loc_0AF569

  loc_0AF562:
    LDA #$&stats_01ABF0+1A4
    STA $statsPtr, X

  loc_0AF569:
    COP [PlaySoundCh1] ( #1E )
    LDA #$0080
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [StageMove] ( #0A, #04, #FF )
    COP [TickMove]
    COP [PlaySoundBoth] ( #$2323 )
    COP [SpawnAfterFlags] ( @code_0AF633, #$2000 )
    COP [SpawnThinkerParam] ( #67, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteLoop] ( #0B, #04 )
    COP [AnimLoop]
    JSR $&sub_0AF6D7
    COP [PlaySoundCh1] ( #20 )
    COP [StageSprAndHitbox] ( #2E )
    LDA #$0000
    STA $7F100C, X
    COP [BranchOnPlayerY] ( #$0000, &code_0AF5B5, &code_0AF5B5, &code_0AF5BA )
}

code_0AF5B5 {
    LDA #$FFFD
    BRA loc_0AF5BD
}

code_0AF5BA {
    LDA #$0003

  loc_0AF5BD:
    STA $7F100E, X
    COP [BranchOnPlayerX] ( #$0028, &code_0AF5CB, &code_0AF5D7, &code_0AF5D0 )
}

code_0AF5CB {
    LDA #$FFFE
    BRA loc_0AF5D3
}

code_0AF5D0 {
    LDA #$0002

  loc_0AF5D3:
    STA $7F100C, X
}

code_0AF5D7 {
    JSR $&sub_0AF6D7
    COP [SpawnMarkedAfter] ( @code_0AF640, #$0300 )
    JSR $&sub_0AF6AA
    LDA $10
    BIT #$4000
    BNE loc_0AF5F0
    COP [SetEntryExitNow] ( @code_0AF5D7 )

  loc_0AF5F0:
    LDA $16
    BMI loc_0AF5FE
    CMP #$0240
    BCS loc_0AF608
    COP [SetEntryExitNow] ( @code_0AF5D7 )

  loc_0AF5FE:
    CMP #$FFC0
    BCC loc_0AF608
    COP [SetEntryExitNow] ( @code_0AF5D7 )

  loc_0AF608:
    LDA #$FFFF
    STA $00FE
    STA $00F6
    STA $00FA
    COP [WaitByte] ( #01 )
    COP [Die]
}

code_0AF619 {
    LDA #$0080
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [StageMove] ( #0A, #04, #FF )
    COP [TickMove]
    COP [Die]
}

code_0AF633 {
    COP [LoopInit] ( #20 )
    INC $00FE
    JSR $&sub_0AF6D7
    COP [LoopNext]
    COP [Die]
}

code_0AF640 {
    LDY $24
    LDA $0026, Y
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AF651 )
}

code_list_0AF651 [
  &code_0AF661   ;00
  &code_0AF666   ;01
  &code_0AF66B   ;02
  &code_0AF670   ;03
  &code_0AF675   ;04
  &code_0AF67A   ;05
  &code_0AF67F   ;06
  &code_0AF684   ;07
]

code_0AF661 {
    COP [StageSprAndHitbox] ( #11 )
    BRA loc_0AF687
}

code_0AF666 {
    COP [StageSprAndHitbox] ( #95 )
    BRA loc_0AF687
}

code_0AF66B {
    COP [StageSprAndHitbox] ( #12 )
    BRA loc_0AF687
}

code_0AF670 {
    COP [StageSprAndHitbox] ( #13 )
    BRA loc_0AF687
}

code_0AF675 {
    COP [StageSprAndHitbox] ( #94 )
    BRA loc_0AF687
}

code_0AF67A {
    COP [StageSprAndHitbox] ( #93 )
    BRA loc_0AF687
}

code_0AF67F {
    COP [StageSprAndHitbox] ( #15 )
    BRA loc_0AF687
}

code_0AF684 {
    COP [StageSprAndHitbox] ( #14 )

  loc_0AF687:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF6A8
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryExit]
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    DEC $26
    BMI loc_0AF687
    RTL 

  loc_0AF6A8:
    COP [Die]
}
---------------------------------------------

sub_0AF6AA {
    INC $26
    LDA $16
    CLC 
    ADC $7F100E, X
    STA $16
    LDA $14
    CLC 
    ADC $7F100C, X
    STA $14
    BIT #$FF00
    BEQ loc_0AF6D6
    SEC 
    SBC $7F100C, X
    STA $14
    LDA $7F100C, X
    EOR #$FFFF
    INC 
    STA $7F100C, X

  loc_0AF6D6:
    RTS 
}
---------------------------------------------

sub_0AF6D7 {
    LDA $14
    STA $00F6
    LDA $16
    SEC 
    SBC $bg2ScrollH
    STA $00FA
    RTS 
}
---------------------------------------------

func_0AF6E6 {
    COP [RngByte]
    AND #$00FF
    CLC 
    ADC #$02D0
    STA $00F2
    COP [SetEntryExit]
    DEC $00F2
    BEQ loc_0AF6FA
    RTL 

  loc_0AF6FA:
    COP [SetEntryContinue]
    LDA $00F2
    BNE loc_0AF702
    RTL 

  loc_0AF702:
    LDA $09F2
    BNE loc_0AF709
    BRA func_0AF6E6

  loc_0AF709:
    COP [SetEntryContinue]
    LDA #$0001
    STA $00F2
    RTL 
}

code_0AF712 {
    COP [InitSpiral] ( #00, #00 )
    BRA loc_0AF728
}

code_0AF718 {
    COP [InitSpiral] ( #00, #40 )
    BRA loc_0AF728
}

code_0AF71E {
    COP [InitSpiral] ( #00, #80 )
    BRA loc_0AF728
}

code_0AF724 {
    COP [InitSpiral] ( #00, #C0 )

  loc_0AF728:
    COP [StageSprAndHitbox] ( #2B )
    BRA loc_0AF746
}

code_0AF72D {
    COP [InitSpiral] ( #00, #00 )
    BRA loc_0AF743
}

code_0AF733 {
    COP [InitSpiral] ( #00, #40 )
    BRA loc_0AF743
}

code_0AF739 {
    COP [InitSpiral] ( #00, #80 )
    BRA loc_0AF743
}

code_0AF73F {
    COP [InitSpiral] ( #00, #C0 )

  loc_0AF743:
    COP [StageSprAndHitbox] ( #2C )

  loc_0AF746:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF746
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryExit]
    LDA $24
    STA $0000
    COP [SpiralStep] ( #03, #02 )
    LDA $orbitDiameter, X
    CMP #$0080
    BCS loc_0AF76D
    DEC $26
    BMI loc_0AF746
    RTL 

  loc_0AF76D:
    COP [LoopInit] ( #1E )

  loc_0AF770:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF770
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryExit]
    LDA $24
    STA $0000
    COP [SpiralStep] ( #00, #04 )
    DEC $26
    BMI loc_0AF78E
    RTL 

  loc_0AF78E:
    COP [LoopNext]

  loc_0AF790:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF790
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryExit]
    LDA $24
    STA $0000
    COP [SpiralStep] ( #FC, #04 )
    LDA $orbitDiameter, X
    BMI loc_0AF7B4
    DEC $26
    BMI loc_0AF790
    RTL 

  loc_0AF7B4:
    COP [Die]
}

code_0AF7B6 {
    LDA $00F0
    BEQ loc_0AF7BC
    RTL 

  loc_0AF7BC:
    LDA $10
    BIT #$00C0
    BEQ loc_0AF7C4
    RTL 

  loc_0AF7C4:
    LDY $24
    SEP #$20
    LDA $02
    CMP $0002, Y
    BEQ loc_0AF7D2
    JMP $&code_0AF873

  loc_0AF7D2:
    REP #$20
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [BranchNearerAxis] ( &code_0AF7E6, &code_0AF81D )
}

code_0AF7E6 {
    LDA $16
    CMP $@word_0AFA40
    BEQ loc_0AF801
    CMP $@word_0AFA40+2
    BEQ loc_0AF801
    CMP $@word_0AFA40+4
    BEQ loc_0AF801
    CMP $@word_0AFA40+6
    BEQ loc_0AF801
    RTL 

  loc_0AF801:
    COP [BranchOnPlayerX] ( #$000F, &code_0AF80B, &code_0AF875, &code_0AF814 )
}

code_0AF80B {
    COP [BranchIfPlayerInRelTiles] ( #FB, #FF, #FF, #01, &code_0AF854 )
    RTL 
}

code_0AF814 {
    COP [BranchIfPlayerInRelTiles] ( #01, #FF, #05, #01, &code_0AF859 )
    RTL 
}

code_0AF81D {
    LDA $14
    CMP $@word_0AFA38
    BEQ loc_0AF838
    CMP $@word_0AFA38+2
    BEQ loc_0AF838
    CMP $@word_0AFA38+4
    BEQ loc_0AF838
    CMP $@word_0AFA38+6
    BEQ loc_0AF838
    RTL 

  loc_0AF838:
    COP [BranchOnPlayerY] ( #$000F, &code_0AF842, &code_0AF875, &code_0AF84B )
}

code_0AF842 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #FF, &code_0AF85E )
    RTL 
}

code_0AF84B {
    COP [BranchIfPlayerInRelTiles] ( #FF, #01, #01, #06, &code_0AF863 )
    RTL 
}

code_0AF854 {
    LDA #$&func_0AF4C7
    BRA loc_0AF866
}

code_0AF859 {
    LDA #$&func_0AF4D9
    BRA loc_0AF866
}

code_0AF85E {
    LDA #$&func_0AF4EB
    BRA loc_0AF866
}

code_0AF863 {
    LDA #$&func_0AF4FD

  loc_0AF866:
    LDY $24
    STA $0000, Y
    COP [PlaySoundCh1] ( #06 )
    INC $00F0
    RTL 
}
---------------------------------------------

func_0AF872_noref {
    PLX 
}

code_0AF873 {
    REP #$20
}

code_0AF875 {
    RTL 
}

code_0AF876 {
    COP [WaitByte] ( #04 )
    LDY $24
    LDA $0014, Y
    CMP $14
    BNE loc_0AF889
    LDA $0016, Y
    CMP $16
    BEQ code_0AF876

  loc_0AF889:
    COP [SpawnAfterFlags] ( @code_0AF89E, #$0300 )
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    BRA code_0AF876
}

code_0AF89E {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [Die]
}

code_0AF8A5 {
    LDA #$0001
    STA $26
    BRA loc_0AF8B6
}

code_0AF8AC {
    STZ $26
    COP [AddPosition] ( #F0, #00 )
    COP [CallScript] ( &code_0AF937 )

  loc_0AF8B6:
    COP [AddPosition] ( #F0, #00 )
    COP [CallScript] ( &code_0AF911 )
    BRA loc_0AF8B6
}

code_0AF8C0 {
    LDA #$0001
    STA $26
    BRA loc_0AF8D1
}

code_0AF8C7 {
    STZ $26
    COP [AddPosition] ( #10, #00 )
    COP [CallScript] ( &code_0AF937 )

  loc_0AF8D1:
    COP [AddPosition] ( #10, #00 )
    COP [CallScript] ( &code_0AF911 )
    BRA loc_0AF8D1
}

code_0AF8DB {
    LDA #$0001
    STA $26
    BRA loc_0AF8EC
}

code_0AF8E2 {
    STZ $26
    COP [AddPosition] ( #00, #F0 )
    COP [CallScript] ( &code_0AF937 )

  loc_0AF8EC:
    COP [AddPosition] ( #00, #F0 )
    COP [CallScript] ( &code_0AF911 )
    BRA loc_0AF8EC
}

code_0AF8F6 {
    LDA #$0001
    STA $26
    BRA loc_0AF907
}

code_0AF8FD {
    STZ $26
    COP [AddPosition] ( #00, #10 )
    COP [CallScript] ( &code_0AF937 )

  loc_0AF907:
    COP [AddPosition] ( #00, #10 )
    COP [CallScript] ( &code_0AF911 )
    BRA loc_0AF907
}

code_0AF911 {
    COP [BranchIfSolid] ( &code_0AF95F )
    LDA $26
    BEQ loc_0AF928
    COP [SpawnAfterFlags] ( @code_0AF95A, #$0200 )
    COP [PlaySoundCh1] ( #14 )
    COP [WaitByte] ( #03 )
    COP [RestoreSavedPtr]

  loc_0AF928:
    COP [SpawnAfterFlags] ( @code_0AF94F, #$0200 )
    COP [PlaySoundCh1] ( #14 )
    COP [WaitByte] ( #01 )
    COP [RestoreSavedPtr]
}

code_0AF937 {
    COP [BranchIfSolid] ( &code_0AF95F )
    COP [SpawnAfterFlags] ( @code_0AF947, #$0200 )
    COP [WaitByte] ( #1D )
    COP [RestoreSavedPtr]
}

code_0AF947 {
    COP [StageSpriteLoop] ( #07, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0AF94F {
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [Die]
}

code_0AF95A {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
}

code_0AF95F {
    COP [Die]
}
---------------------------------------------

sub_0AF961 {
    LDA $moveXAlt, X
    STA $0018
    LDA $moveYAlt, X
    STA $001C
    COP [RngByte]
    AND #$0003
    STA $7F100C, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA38, X
    PLX 
    STA $moveXAlt, X
    COP [RngByte]
    AND #$0003
    STA $7F100E, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA40, X
    PLX 
    STA $moveYAlt, X
    CMP $001C
    BNE loc_0AF9A7
    LDA $0018
    CMP $moveXAlt, X
    BEQ sub_0AF961

  loc_0AF9A7:
    RTS 
}
---------------------------------------------

sub_0AF9A8 {
    COP [RngByte]
    LSR 
    BCC loc_0AF9E8
    COP [RngByte]
    LSR 
    LDA $7F100C, X
    AND #$0003
    BCC loc_0AF9C1
    CMP #$0003
    BEQ loc_0AF9C4
    INC 
    BRA loc_0AF9C4

  loc_0AF9C1:
    BEQ loc_0AF9E8
    DEC 

  loc_0AF9C4:
    STA $7F100C, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA38, X
    PLX 
    STA $moveXAlt, X

  loc_0AF9D4:
    LDA $7F100E, X
    AND #$0003
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA40, X
    PLX 
    STA $moveYAlt, X
    RTS 

  loc_0AF9E8:
    LDA $0410
    LSR 
    LSR 
    LDA $7F100E, X
    AND #$0003
    BCC loc_0AF9FE
    CMP #$0003
    BEQ loc_0AFA01
    INC 
    BRA loc_0AFA01

  loc_0AF9FE:
    BEQ loc_0AFA01
    DEC 

  loc_0AFA01:
    STA $7F100E, X
    LDA $7F100C, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA38, X
    PLX 
    STA $moveXAlt, X
    BRA loc_0AF9D4
}
---------------------------------------------

sub_0AFA17 {
    LDA $7F100C, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA38, X
    PLX 
    STA $moveXAlt, X
    LDA $7F100E, X
    ASL 
    PHX 
    TAX 
    LDA $@word_0AFA40, X
    PLX 
    STA $moveYAlt, X
    RTS 
}
---------------------------------------------

word_0AFA38 [
  #$0018   ;00
  #$0058   ;01
  #$00A8   ;02
  #$00E8   ;03
]
---------------------------------------------

word_0AFA40 [
  #$0058   ;00
  #$00D8   ;01
  #$0158   ;02
  #$01D8   ;03
]
---------------------------------------------

func_0AFA48 {
    LDA #$0008
    TSB $playerFlags
    COP [SetEntryContinue]
    RTL 
}
---------------------------------------------

binary_0AFA51 #66F8003000000022
---------------------------------------------

func_0AFA59 {
    COP [SetEntryContinue]
    LDA $09F2
    BNE loc_0AFA72
    INC 
    STA $09F2
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AFA81
    COP [PrintWideString] ( &widestring_0AFCA0 )
    BRA loc_0AFA81

  loc_0AFA72:
    LDA #$0020
    TSB $playerFlags
    COP [SpawnLastRel] ( @func_0AA36E, #00, #00, #$2000 )

  loc_0AFA81:
    LDA $playerFlags
    BIT #$0200
    BNE loc_0AFA97
    COP [SpawnLastRel] ( @code_0AFAE7, #00, #F0, #$2300 )
    COP [WaitByte] ( #1D )
    COP [Die]

  loc_0AFA97:
    LDA #$0020
    TRB $playerFlags
    COP [SetEntryContinue]
    RTL 
}

code_0AFAA0 {
    COP [SetEntryContinue]
    LDA $09F2
    BNE loc_0AFAB9
    INC 
    STA $09F2
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AFAC8
    COP [PrintWideString] ( &widestring_0AFCE4 )
    BRA loc_0AFAC8

  loc_0AFAB9:
    LDA #$0020
    TSB $playerFlags
    COP [SpawnLastRel] ( @func_0AA36E, #00, #00, #$2000 )

  loc_0AFAC8:
    LDA $playerFlags
    BIT #$0200
    BNE loc_0AFADE
    COP [SpawnLastRel] ( @code_0AFAE7, #00, #F0, #$2300 )
    COP [WaitByte] ( #1D )
    COP [Die]

  loc_0AFADE:
    LDA #$0020
    TRB $playerFlags
    COP [SetEntryContinue]
    RTL 
}

code_0AFAE7 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #03 )
    COP [SpawnLastRel] ( @code_0AFB0E, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0AFB1B, #00, #00, #$0302 )
    COP [WaitByte] ( #05 )
    COP [LoopNext]
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

code_0AFB0E {
    JSR $&sub_0AFB28
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0AFB1B {
    JSR $&sub_0AFB28
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}
---------------------------------------------

sub_0AFB28 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $16
    STA $16
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $14
    STA $14
    RTS 
}
---------------------------------------------

widestring_0AFB45 `[DEF][TPL:2]Vampire: [N]You've found the  [N]Mystic Statue! [FIN]I thought that guy who [N]came to the palace was [N]strange....We were [N]right to let him go. [FIN][TPL:1]Vampiress: [N]What are you saying? [N]You were drooling [N]when he was here! [FIN]You're always like that [N]when young ones come! [N]All you ever think about [N]is food! [FIN][TPL:2]Vampire: [N]So do you!! [FIN]Wait. This is not the[N]time or place for[N]an argument.[FIN]First, let's get that [N]Mystic Statue!  [N]Get ready!!![PAL:0][END]`

widestring_0AFCA0 `[DLG:3,11][SIZ:D,4][TPL:1]Vampiress: [N]I'm glad he's gone. [N]It's your turn next!! [N]Get ready![PAL:0][END]`

widestring_0AFCE4 `[DLG:3,11][SIZ:D,4][TPL:2]Vampire: You! [N]You did that to my wife! [N]I'll never forgive you!![PAL:0][END]`