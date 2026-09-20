; Dark Gaia — the final boss of the game (~1,005 lines).
; 
; Multi-form final boss with the game's largest boss script.
; Phase 1: Dark Gaia's face attacks with energy beams and
; summoned projectiles. Phase 2: transformation into the
; comet form with new attack patterns. Phase 3: final
; desperate assault. Uses extensive camera control, palette
; manipulation, and spawned child actors for attacks.
; Defeat triggers the ending sequence.
---------------------------------------------

?BANK 0C

?INCLUDE 'enemy_stats_table'
?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'
?INCLUDE 'player_character'
?INCLUDE 'sE8_comet_display_config'
?INCLUDE 'SetPlayerGameOverFlag'
?INCLUDE 'smooth_follow'
?INCLUDE 'spriteset_enemies'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!characterForm                  0AD4
!WH0                            2126
!TM                             212C
!animScratch                    7F0000
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!retPtr2                        7F001E
!statsPtr                       7F0020
!currentHp                      7F0026
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

sE8_dark_gaia [
  actor-def < #00, #00, #21, {

  code_0CEEAD:
    LDA #$0010
    TSB $12
    LDA #$0000
    STA $cameraTargetY
    STA $cameraTargetX
    STA $cameraDeltaY
    STA $cameraDeltaX
    LDA #$0081
    STA $14
    LDA #$00EA
    STA $16
    LDY $playerActor
    LDA #$&loc_0CF5EF
    STA $0000, Y
    LDA #$*loc_0CF5EF
    STA $0002, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryHere]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0CEEF1
    RTL 

  loc_0CEEF1:
    COP [SpawnAfter] ( @code_0CED37 )
    COP [SetEntryHereAndYield]
    LDY #$0F00
    LDA #$&sE8_comet_display_config.code_0CEBA1
    STA $0000, Y
    COP [StartMusic] ( #10 )
    COP [SetDeathCallback] ( @code_0CEF88 )
    COP [WaitByte] ( #FE )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]

  loc_0CEF11:
    COP [SetHitCallback] ( &code_0CEF3C )
    LDA #$2000
    TRB $10
    COP [SpawnListAppend] ( @code_0CF550, #00, #00, #$0301 )
    STY $24
    LDA #$0064
    STA $26
    COP [SetEntryHere]
    DEC $26
    BMI loc_0CEF31
    RTL 

  loc_0CEF31:
    LDA #$2000
    TSB $10

  loc_0CEF36:
    COP [WaitWord] ( #$01DF )
    BRA loc_0CEF11
} >
]

code_0CEF3C {
    LDA #$2000
    TSB $10
    COP [SpawnListAppend] ( @code_0CEF6D, #00, #00, #$2000 )
    COP [LoopStart] ( #10 )
    LDY $24
    BEQ loc_0CEF5A
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y

  loc_0CEF5A:
    COP [SetEntryHereAndYield]
    LDY $24
    BEQ loc_0CEF69
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0CEF69:
    COP [LoopEnd]
    BRA loc_0CEF36
}

code_0CEF6D {
    COP [LoopStart] ( #10 )
    SEP #$20
    LDA #$16
    STA $TM
    REP #$20
    COP [SetEntryHereAndYield]
    SEP #$20
    LDA #$17
    STA $TM
    REP #$20
    COP [LoopEnd]
    COP [Die]
}

code_0CEF88 {
    COP [SetFlagByte] ( #03 )
    COP [SetHitCallback] ( #$0000 )
    COP [SetDeathCallback] ( $000000 )
    LDA #$2300
    TSB $10
    LDY $24
    BEQ loc_0CEFA6
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y

  loc_0CEFA6:
    COP [SpawnAfter] ( @code_0CED3E )
    COP [WaitByte] ( #3B )
    LDY #$0F00
    LDA #$&sE8_comet_display_config.code_0CEB76
    STA $0000, Y
    COP [SpawnThinker] ( @oneshot_palette_flash_18.FlashPalette18 )
    COP [WaitByte] ( #77 )
    LDA #$&enemy_stats_table+154
    STA $statsPtr, X
    LDA $&enemy_stats_table+154
    AND #$00FF
    STA $currentHp, X
    LDA #$0301
    STA $10
    LDA #$1000
    TSB $12
    LDA #$0080
    TSB $displayModeFlags
    COP [SetEntryHereAndYield]
    LDA #$0800
    TSB $playerFlags
    LDY $playerActor
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y
    COP [LoopStart] ( #80 )
    LDA $bg2ScrollH
    CLC 
    ADC #$0002
    STA $cameraTargetY
    LDY $0056

  loc_0CF004:
    LDA $0010, Y
    BIT #$0400
    BEQ loc_0CF016
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y

  loc_0CF016:
    LDA $0006, Y
    TAY 
    BNE loc_0CF004
    COP [LoopEnd]
    COP [SetEntryHereAndYield]
    COP [SpawnThinker] ( @oneshot_palette_flash_19.FlashPalette19 )
    LDY #$0F00
    LDA #$&sE8_comet_display_config.code_0CEBA1
    STA $0000, Y
    COP [SetFlagByte] ( #01 )
    LDY $playerActor
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y
    COP [WaitByte] ( #63 )
    LDY #$0F00
    LDA #$&sE8_comet_display_config.code_0CEBF7
    STA $0000, Y
    COP [WaitByte] ( #63 )
    LDA #$0080
    TRB $displayModeFlags
    COP [StageBgChange] ( #9D )
    COP [ApplyBgChange]
    COP [SpawnAfterMarked] ( @code_0CF4E3, #$0301 )
    TYA 
    STA $orbitAngle, X
    COP [SpawnAfterMarked] ( @code_0CF3FC, #$2200 )
    COP [SpawnAfterMarked] ( @code_0CF403, #$2200 )
    LDA #$0080
    STA $14
    LDA #$0150
    STA $16
    LDA #$2000
    TRB $10
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]

  code_0CF08A:
    COP [SetDeathCallback] ( @code_0CF154 )

  code_0CF08F:
    COP [SetEntryHere]
    LDA $orbitDiameter, X
    BMI loc_0CF0A2
    DEC 
    STA $orbitDiameter, X
    LDA #$0000
    JMP $&code_0CF13B

  loc_0CF0A2:
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0CF0B0 )
}

code_list_0CF0B0 [
  &code_0CF13B   ;00
  &code_0CF13B   ;01
  &code_0CF0C0   ;02
  &code_0CF0C0   ;03
  &code_0CF0C0   ;04
  &code_0CF0C0   ;05
  &code_0CF0C0   ;06
  &code_0CF0C0   ;07
]

code_0CF0C0 {
    LDA #$0003
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    TAY 
    LDA #$&loc_0CF51E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    LDA #$0200
    TSB $10
    LDA #$0057
    STA $7F0C02
    COP [SpawnThinker] ( @code_0CEC65 )
    COP [SetFlagByte] ( #02 )
    COP [SpawnListAppend] ( @code_0CED45, #00, #00, #$2000 )
    COP [PlaySoundCh1] ( #20 )
    COP [SpawnListAppend] ( @code_0CF266, #00, #00, #$2200 )

  code_0CF10B:
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [BranchOnFlagByte] ( #02, #01, &code_0CF10B )
    LDA #$00FF
    STA $WH0
    COP [StageSpriteLoop] ( #06, #3C )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    LDA $orbitAngle, X
    TAY 
    LDA #$&loc_0CF4FF
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    JMP $&code_0CF08F
}

code_0CF13B {
    COP [SpawnListAppend] ( @code_0CF2F2, #00, #00, #$0301 )
    COP [SpawnListAppend] ( @code_0CF31F, #00, #00, #$0301 )
    COP [WaitWord] ( #$012B )
    JMP $&code_0CF08A
}

code_0CF154 {
    COP [SetFlagByte] ( #04 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SpawnListAppend] ( @SetPlayerGameOverFlag, #00, #00, #$2000 )
    COP [SpawnListAppend] ( @code_0CF201, #00, #E0, #$2300 )
    COP [SpawnListAppend] ( @code_0CF1CE, #00, #00, #$0300 )
    COP [SpawnListAppend] ( @code_0CF1DF, #00, #00, #$0300 )
    COP [SpawnListAppend] ( @code_0CF1F0, #00, #00, #$0300 )
    COP [SpawnListAppend] ( @code_0CF291, #00, #00, #$2800 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDY #$0F00
    LDA #$&sE8_comet_display_config.code_0CEC35
    STA $0000, Y
    COP [SpawnThinker] ( @oneshot_palette_flash_18.FlashPalette18 )
    COP [WaitWord] ( #$012B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    LDA #$0800
    TSB $10
    COP [WaitByte] ( #01 )
    LDA #$0000
    STA $characterForm
    RTL 
}

code_0CF1CE {
    LDA #$0060
    STA $14
    LDA #$01B8
    STA $16

  loc_0CF1D8:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    BRA loc_0CF1D8
}

code_0CF1DF {
    LDA #$00B1
    STA $14
    LDA #$01B8
    STA $16

  loc_0CF1E9:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    BRA loc_0CF1E9
}

code_0CF1F0 {
    LDA #$00B4
    STA $14
    LDA #$01A0
    STA $16

  loc_0CF1FA:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    BRA loc_0CF1FA
}

code_0CF201 {
    LDA #$0080
    STA $14
    LDA #$0170
    STA $16
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [LoopStart] ( #0C )
    COP [SpawnListAppend] ( @code_0CF22F, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnListAppend] ( @code_0CF23C, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [LoopEnd]
    COP [Die]
}

code_0CF22F {
    COP [PlaySoundCh1] ( #06 )
    JSR $&code_0CF249
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0CF23C {
    COP [PlaySoundCh1] ( #06 )
    JSR $&code_0CF249
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0CF249 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
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

code_0CF266 {
    LDA #$&enemy_stats_table+160
    STA $statsPtr, X
    LDA $&enemy_stats_table+160
    AND #$00FF
    STA $currentHp, X
    LDA #$0080
    STA $14
    LDA #$01E0
    STA $16
    COP [WaitByte] ( #09 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoop] ( #1F, #0A )
    COP [AnimLoop]
    COP [Die]
}

code_0CF291 {
    LDA #$0220
    STA $16
    COP [LoopStart] ( #1E )
    COP [SpawnAfterFlags] ( @code_0CF2BB, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterFlags] ( @code_0CF2C8, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterFlags] ( @code_0CF2D5, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [LoopEnd]
    COP [Die]
}

code_0CF2BB {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1B, #00, #06 )
    COP [AnimOnce]
    BRA loc_0CF2E2
}

code_0CF2C8 {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1C, #00, #06 )
    COP [AnimOnce]
    BRA loc_0CF2E2
}

code_0CF2D5 {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1D, #00, #08 )
    COP [AnimOnce]
    BRA loc_0CF2E2

  loc_0CF2E2:
    COP [ReloadMoveDurations]
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $16
    CMP #$00E0
    BCS loc_0CF2E2
    COP [Die]
}

code_0CF2F2 {
    LDA #$0031
    STA $14
    LDA #$0197
    STA $16
    COP [SpawnAfterFlags] ( @code_0CF3EF, #$0301 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    LDA #$0010
    STA $14
    LDA #$0150
    STA $16
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$0004
    STA $26
    JMP $&code_0CF353
}

code_0CF31F {
    COP [SetHMirror]
    LDA #$0002
    TSB $12
    LDA #$00CF
    STA $14
    LDA #$0197
    STA $16
    COP [SpawnAfterFlags] ( @code_0CF3EF, #$0301 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    LDA #$00F0
    STA $14
    LDA #$0150
    STA $16
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$000C
    STA $26
    JMP $&code_0CF353
}

code_0CF353 {
    COP [PlaySoundCh1] ( #20 )
    COP [OrExtraFlags] ( #$0010 )
    LDA #$00A0
    TSB $12
    LDA #$0100
    TRB $10
    LDA #$&enemy_stats_table+158
    STA $statsPtr, X
    LDA $&enemy_stats_table+158
    AND #$00FF
    STA $currentHp, X
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterMarked] ( @smooth_follow.CopySiblingFollowState, #$2000 )
    LDA #$800B
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $playerActor
    STA $0024, Y
    PHX 
    TYX 
    LDA $26
    STA $animScratch2, X
    PLX 
    LDA #$0002
    TSB $10
    COP [StageSpriteLoop] ( #0B, #05 )
    COP [AnimLoop]
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $7F100E, X
    LDA $0000
    STA $7F100C, X
    COP [KillNext]

  loc_0CF3C5:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryHere]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_0CF3E6
    RTL 

  loc_0CF3E6:
    LDA $10
    BIT #$4000
    BEQ loc_0CF3C5
    COP [Die]
}

code_0CF3EF {
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [Die]

  loc_0CF3F6:
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
}

code_0CF3FC {
    LDA #$0018
    STA $14
    BRA loc_0CF408
}

code_0CF403 {
    LDA #$00E8
    STA $14

  loc_0CF408:
    LDA #$01D8
    STA $16

  loc_0CF40D:
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0078
    STA $08
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #04, #01, &code_0CF4E1 )
    COP [SpawnAfterMarked] ( @code_0CF429, #$0200 )
    BRA loc_0CF40D
}

code_0CF429 {
    COP [OrExtraFlags] ( #$0080 )
    LDA #$00A0
    TSB $12
    COP [StageSpriteLoop] ( #11, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$&enemy_stats_table+15C
    STA $statsPtr, X
    LDA $&enemy_stats_table+15C
    AND #$00FF
    STA $currentHp, X
    COP [PlaySoundCh1] ( #1D )
    COP [SetDeathCallback] ( @code_0CF4D9 )
    LDA #$0200
    TRB $10
    COP [StageSpriteMoveY] ( #13, #0A )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #13, #2A )
    COP [AnimOnce]
    LDA #$0000
    STA $currentHp, X
    LDA #$&loc_0CF47E
    STA $retPtr2, X
    STA $00
    LDA #$0005
    STA $loopCounter, X

  loc_0CF47E:
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #04, #01, &code_0CF4DC )
    COP [RngByte]
    LDY $playerActor
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0014, Y
    STA $moveXAlt, X
    BPL loc_0CF49D
    RTL 

  loc_0CF49D:
    CMP #$0108
    BCC loc_0CF4A3
    RTL 

  loc_0CF4A3:
    LDA $0411
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0016, Y
    CMP #$0100
    BCS loc_0CF4B7
    RTL 

  loc_0CF4B7:
    CMP #$01E8
    BCC loc_0CF4BD
    RTL 

  loc_0CF4BD:
    STA $moveYAlt, X
    COP [MoveToward] ( #13, #02 )
    LDA $10
    BIT #$4000
    BNE code_0CF4E1
    COP [StageSpriteLoop] ( #13, #01 )
    COP [AnimLoop]
    COP [LoopEnd]
    COP [SetDeathCallback] ( $000000 )
}

code_0CF4D9 {
    COP [PlaySoundCh1] ( #1B )
}

code_0CF4DC {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
}

code_0CF4E1 {
    COP [Die]
}

code_0CF4E3 {
    LDA #$0080
    STA $14
    LDA #$01AA
    STA $16
    COP [SpawnAfterOffsetMarked] ( @code_0CF549, #FC, #FC, #$0301 )
    COP [SpawnAfterOffsetMarked] ( @code_0CF543, #04, #00, #$0301 )

  loc_0CF4FF:
    LDY $06
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0CF517:
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    BRA loc_0CF517

  loc_0CF51E:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_0CF543 {
    COP [StageSprAndHitbox] ( #0C )
    COP [WaitByte] ( #09 )
}

code_0CF549 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA code_0CF549
}

code_0CF550 {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0CF570, #$0202 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDY $24
    LDA #$0000
    STA $0024, Y
    COP [Die]
}

code_0CF570 {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )

  loc_0CF578:
    COP [StageSpriteMoveY] ( #15, #0C )
    COP [AnimOnce]
    COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
    LDA $16
    BPL loc_0CF578
    BPL loc_0CF58E
    EOR #$FFFF
    INC 

  loc_0CF58E:
    CMP #$0030
    BCC loc_0CF578
    LDA #$2000
    TSB $10
    COP [LoopStart] ( #0E )
    COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
    COP [SpawnAfterFlags] ( @code_0CF5AF, #$0202 )
    COP [WaitByte] ( #0E )
    COP [LoopEnd]
}

code_0CF5AD {
    COP [Die]
}

code_0CF5AF {
    COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
    COP [PlaySoundCh1] ( #23 )
    COP [RngByte]
    STA $14
    COP [RngByte]
    LSR 
    BCS loc_0CF5D8

  loc_0CF5C1:
    COP [StageSpriteMoveY] ( #16, #09 )
    COP [AnimOnce]
    COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
    LDA $16
    BMI loc_0CF5C1
    CMP #$0120
    BCC loc_0CF5C1
    COP [Die]

  loc_0CF5D8:
    COP [StageSpriteMoveY] ( #16, #0D )
    COP [AnimOnce]
    COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
    LDA $16
    BMI loc_0CF5D8
    CMP #$0120
    BCC loc_0CF5D8
    COP [Die]

  loc_0CF5EF:
    LDA #$0008
    TRB $10
    LDA #$0088
    STA $14
    LDA #$FFC0
    STA $16

  loc_0CF5FE:
    COP [StagePlayerMoveY] ( #1B, #07 )
    COP [AnimOnce]
    LDA $16
    BMI loc_0CF5FE
    CMP #$00E0
    BCC loc_0CF5FE
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    JML $@player_character.PlayerIdleEntry
}
---------------------------------------------

code_0CEC65 {
    LDA #$0004
    STA $animScratch2, X
    LDA #$0000
    STA $animScratch, X
    STA $animScratch+2, X
    STA $spritesetPtr, X
    COP [SetEntryHere]
    LDA $animScratch, X
    LSR 
    BCS loc_0CEC89
    LDY #$0000
    BRA loc_0CEC8C

  loc_0CEC89:
    LDY #$0200

  loc_0CEC8C:
    SEP #$20
    PHB 
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    PHD 
    LDA #$0000
    TCD 
    LDA $animScratch+2, X
    INC 
    INC 
    STA $animScratch+2, X
    STA $0E
    LDA #$857A
    STA $18
    LDA #$00FF
    STA $7C01, Y
    SEP #$20
    LDA #$45
    STA $7C00, Y
    INY 
    INY 
    INY 

  loc_0CECBB:
    LDA #$04
    STA $7C00, Y
    LDA $18
    DEC 
    STA $18
    STA $7C01, Y
    LDA $19
    INC 
    STA $19
    STA $7C02, Y
    INY 
    INY 
    INY 
    DEC $0E
    BPL loc_0CECBB
    LDA #$01
    STA $7C00, Y
    REP #$20
    LDA #$00FF
    STA $7C01, Y
    SEP #$20
    LDA #$00
    STA $7C03, Y
    REP #$20
    PLD 
    PLB 
    LDA $animScratch, X
    LSR 
    BCS loc_0CECFE
    COP [QueueDma] ( $7E7C00, #26 )
    BRA loc_0CED04

  loc_0CECFE:
    COP [QueueDma] ( $7E7E00, #26 )

  loc_0CED04:
    LDA $animScratch, X
    INC 
    STA $animScratch, X
    LDA $animScratch+2, X
    CMP #$0024
    BCS loc_0CED17
    RTL 

  loc_0CED17:
    LDA #$0023
    STA $animScratch+2, X
    LDA $spritesetPtr, X
    INC 
    STA $spritesetPtr, X
    COP [ClearFlagByte] ( #02 )
    COP [SetEntryHereAndYield]
    COP [SetEntryHereAndYield]
    LDA #$00FF
    STA $WH0
    COP [KillThinker]
    RTL 
}

code_0CED37 {
    COP [PaletteStart] ( #7D )
    COP [PaletteStep]
    COP [Die]
}

code_0CED3E {
    COP [PaletteStart] ( #7F )
    COP [PaletteStep]
    COP [Die]
}

code_0CED45 {
    COP [PaletteStart] ( #69 )
    COP [PaletteStep]
    COP [Die]
}