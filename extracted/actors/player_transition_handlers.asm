; Shared library of player cutscene and transition COP scripts (Bank 00) consumed by 15+ scene and boss actors via direct entry-pointer writes or SpawnLastRel.
; 
; Entry points cover distinct gameplay moments: item reveal with metasprite staging, flag-gated sprite loops and Freedan body-sprite staging, scripted fall/jump sequences with joypad masking, layer priority, and landing animations, and a floor-fall handler that scans downward for solid type $04 tiles.
; 
; Most routines finish by restoring PlayerIdleEntry from player_character. Callers include Castoth, Sand Fanger, Sky Garden jump handler, Angkor Wat sequences, Gold Ship/Oakton rescue scenes, combat_collision knockdown paths, item_use_system, and warps_interaction.
---------------------------------------------

?INCLUDE 'player_character'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerFlags                    09AE

---------------------------------------------

player_transition_handlers {
    COP [SpawnLastRel] ( @PlayerItemRevealSpawn, #00, #00, #$0302 )
    COP [Die]
}

PlayerItemRevealSpawn {
    COP [PlaySoundCh2] ( #09 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [Die]

  PlayerIdleAnimLoop:
    COP [BranchIfFlagByte] ( #00, #01, &PlayerIdleUseShadowSprite )
    COP [StagePlayerSprite] ( #01 )
    BRA PlayerIdleAnimContinue
}

PlayerIdleUseShadowSprite {
    COP [StagePlayerSprite] ( #11 )

  PlayerIdleAnimContinue:
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA PlayerIdleAnimContinue

  PlayerStaticBodyPose:
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #04 )

  PlayerStaticBodyAnimLoop:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    BRA PlayerStaticBodyAnimLoop

  PlayerWalkingIdlePose:
    LDA #$0200
    TRB $10

  RestorePlayerControlDirect:
    JML $@player_character.PlayerIdleEntry ; RestorePlayerControlDirect
}

PlayerFreedanRevealIdle {
    COP [SetPlayerBodySprite] ( #04 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    RTL 
}

PlayerIdleEntryJump {
    JML $@player_character.PlayerIdleEntry
}

PlayerFreedanRevealExit {
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    JML $@player_character.PlayerIdleEntry
}

PlayerFallFromHeight {
    LDA #$CFF0            ; Player fall: mask joypad $CFF0, set playerFlags $0800, force layer priority $0200
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #80 )
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #08 )
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    LDA #$CFF0
    TRB $joypadMaskStd
    STZ $08
    JML $@player_character.PlayerIdleEntry
}

PlayerSkyGardenJumpLanding {
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    COP [AddPosition] ( #00, #C0 )
    COP [SetEntryExit]
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #40 )
    LDA #$2000
    TRB $10
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #E0 )
    COP [StagePlayerMoveY] ( #1A, #08 )
    COP [AnimOnce]
    COP [LoopInit] ( #03 )
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #20 )
    COP [StagePlayerSprite] ( #1E )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #03 )
    COP [AnimOnce]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerSprite] ( #1F )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    STZ $08
    JML $@player_character.PlayerIdleEntry
}

PlayerAuraTransformEntry {
    LDA #$0800            ; Aura transform: scan downward for solid type $04, align Y to $FFF0 grid
    TSB $playerFlags
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #08 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $14
    STA $24
    LDA $16
    STA $26
    LDA $16
    AND #$FFF0
    STA $16

  PlayerAuraAlignToSolidSouth:
    COP [BranchIfSolid] ( &PlayerAuraBlockedBySolid )
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    BRA PlayerAuraAlignToSolidSouth
}

PlayerAuraBlockedBySolid {
    COP [BranchIfSolidTypeSouth] ( #04, &PlayerAuraDescendToFloor )
    LDA $24
    STA $14
    LDA $26
    STA $16
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    JMP $&PlayerAuraTransformExit
}

PlayerAuraDescendToFloor {
    LDA $24
    STA $14
    LDA $26
    STA $16
    LDA #$2000
    TSB $10

  PlayerAuraScanSolidRow:
    LDA $16               ; Per-row solid scan: BranchIfSolidType $04 only when Y mod 16 equals zero
    AND #$000F
    BNE PlayerAuraScanSolidNext
    COP [BranchIfSolidType] ( #04, &PlayerAuraLandOnSolid )

  PlayerAuraScanSolidNext:
    INC $16
    COP [SetEntryExitNow] ( @PlayerAuraScanSolidRow )
}

PlayerAuraLandOnSolid {
    LDA #$2000
    TRB $10
    LDA #$0002
    TSB $10

  PlayerAuraLandAnimLoop:
    COP [StageSpriteMoveY] ( #02, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &PlayerAuraLandComplete )
    BRA PlayerAuraLandAnimLoop
}

PlayerAuraLandComplete {
    LDA #$0002
    TRB $10
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
}

PlayerAuraTransformExit {
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    STZ $08
    JML $@player_character.PlayerIdleEntry
}