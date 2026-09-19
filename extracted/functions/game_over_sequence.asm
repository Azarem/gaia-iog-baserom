; Full player-death handler assigned by combat_collision when HP reaches zero.
; 
; Disables input, spawns DeathPaletteFadeThinker and GameOverCutsceneSprites, fades INIDISP to black, plays sound #$0C, then either revives at half HP if gems ≥100 or resets HP/form/flags and loads save-scene data for respawn. Handles special case for scene $E8 (character form). Includes DeathWakeupMessage dialog variants for Will, Freedan, and Shadow.
---------------------------------------------

?INCLUDE 'actor_pool'
?INCLUDE 'DeathPaletteFadeThinker'
?INCLUDE 'spriteset_enemies'

!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxB                   064A
!worldReadyFlag                 0654
!joypadMaskStd                  065A
!wramFlags                      0A80
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!gemCount                       0AD6
!sceneSaveData                  0AF0
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

GameOverSequence {
    LDA #$0040            ; GameOver: mask joypad $FFF0, spawn DeathPaletteFadeThinker and cutscene sprites
    TSB $10
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #20 )
    COP [SpawnThinker] ( @DeathPaletteFadeThinker )
    COP [SpawnAfter] ( @GameOverCutsceneSprites )
    COP [WaitByte] ( #77 )
    LDA #$8000
    TRB $10
    COP [PlaySoundBoth] ( #$0C0C )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    LDA #$000F
    STA $orbitAngle, X

  loc_00D664:
    SEP #$20              ; Fade loop: decrement orbitAngle into INIDISP ($2100) every 3 frames until negative
    LDA $orbitAngle, X
    DEC 
    BMI loc_00D67B
    STA $orbitAngle, X
    STA $INIDISP
    REP #$20
    COP [WaitByte] ( #03 )
    BRA loc_00D664

  loc_00D67B:
    REP #$20              ; Post-fade: spawn palette reset thinkers #0B and #0D, evaluate gem revival
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker )
    COP [SpawnThinkerParam] ( #0D, @actor_pool.PaletteResetAndKillThinker )
    COP [SetEntryExit]
    PHB 
    LDA $gemCount
    CMP #$0064
    BCC loc_00D6AD
    SBC #$0064
    STA $gemCount
    LDA $playerMaxHp
    LSR 
    STA $playerHp
    SEP #$20
    LDA $0AF6
    PHA 
    PLB 
    LDY $0AF4
    BRA loc_00D6E6

  loc_00D6AD:
    STZ $gemCount         ; Gems≥100: subtract 100 from gemCount, restore HP to half max, reload save scene
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00E8
    BNE loc_00D6C3
    LDA #$0002
    STA $characterForm
    BRA loc_00D6C6

  loc_00D6C3:
    STZ $characterForm

  loc_00D6C6:
    LDA $playerMaxHp
    STA $playerHp
    LDY #$0000
    LDA #$0000

  loc_00D6D2:
    STA $wramFlags, Y
    INY 
    INY 
    CPY #$0020
    BNE loc_00D6D2
    SEP #$20
    LDA $0AF2
    PHA 
    PLB 
    LDY $sceneSaveData

  loc_00D6E6:
    LDA $0000, Y          ; No gems: zero gemCount and WRAM flags; load respawn scene from sceneSaveData
    STA $sceneNext
    LDA $0005, Y
    AND #$7F
    STA $0650
    REP #$20
    LDA $0001, Y
    STA $064C
    LDA $0003, Y
    STA $064E
    LDA $0006, Y
    STA $0652
    PLB 
    LDA #$0404
    STA $gfxCacheIdxB
    INC $0AF8
    STZ $worldReadyFlag
    COP [SetEntryContinue]
    RTL 
}

GameOverCutsceneSprites {
    LDA #$2000
    TSB $10
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    COP [WaitByte] ( #0B )
    COP [SpawnMarkedAfterRel] ( @GameOverSparkleDriftA, #E7, #D8, #$0700 )
    COP [WaitByte] ( #02 )
    COP [SpawnMarkedAfterRel] ( @GameOverSparkleDriftB, #19, #E8, #$0700 )
    COP [WaitByte] ( #04 )
    COP [SpawnMarkedAfterRel] ( @GameOverSparkleDriftA, #E7, #F8, #$0700 )
    COP [WaitByte] ( #62 )
    COP [Die]
}

GameOverSparkleDriftA {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #2F )
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #30 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA GameOverSparkleDriftA
}

GameOverSparkleDriftB {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #2F )
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #30 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA GameOverSparkleDriftB

  DeathWakeupMessage:
    LDA #$CFF0            ; DeathWakeupMessage: characterForm selects Will/Freedan/Shadow dialog variant
    TSB $joypadMaskStd
    STZ $0AF8
    COP [WaitByte] ( #02 )
    LDA $characterForm
    BNE loc_00D7AD
    COP [PrintDialogString] ( &dialogstring_00D7C2 )
    BRA loc_00D7BA

  loc_00D7AD:
    DEC 
    BNE loc_00D7B6
    COP [PrintDialogString] ( &dialogstring_00D818 )
    BRA loc_00D7BA

  loc_00D7B6:
    COP [PrintDialogString] ( &dialogstring_00D848 )

  loc_00D7BA:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

dialogstring_00D7C2 `[DEF]Will: I am sometimes [N]aware of having fallen [N]in a place I know. Must [N]have been a nightmare. [END]`

dialogstring_00D818 `[DEF]Freedan: When I think[N]about it, that place[N]seemed familiar...[END]`

dialogstring_00D848 `[DEF]Shadow: When I think[N]about it, that place[N]seemed familiar...[END]`