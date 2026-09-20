; Bird flight pattern data and behavior for Sky Garden crystal birds.
; 
; Defines the flight paths and animation cycles for the
; crystal bird actors that circle the Sky Garden. Used by
; the garden_crash_cutscene and visual atmosphere actors.
; Contains path tables and movement speed parameters.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

sg_bird_flight_patterns {
    COP [CallNear] ( &code_0ADB19 )
    COP [ToggleVMirror]
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]

  loc_0ADA5D:
    COP [StageSpriteMoveY] ( #2B, #0B )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADA5D
}

code_0ADA69 {
    COP [CallNear] ( &code_0ADB19 )
    COP [ToggleVMirror]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0ADA74:
    COP [StageSpriteMoveXY] ( #2D, #0A, #09 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADA74
}

code_0ADA81 {
    COP [CallNear] ( &code_0ADB19 )
    LDA #$0002
    TSB $12
    COP [SetHMirror]
    COP [ToggleVMirror]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0ADA93:
    COP [StageSpriteMoveXY] ( #2D, #09, #09 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADA93
}

code_0ADAA0 {
    COP [CallNear] ( &code_0ADB19 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]

  loc_0ADAA9:
    COP [StageSpriteMoveX] ( #2C, #0C )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADAA9
}

code_0ADAB5 {
    COP [CallNear] ( &code_0ADB19 )
    LDA #$0002
    TSB $12
    COP [SetHMirror]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]

  loc_0ADAC5:
    COP [StageSpriteMoveX] ( #2C, #0B )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADAC5
}

code_0ADAD1 {
    COP [CallNear] ( &code_0ADB19 )
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0ADADA:
    COP [StageSpriteMoveXY] ( #2D, #0A, #0A )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADADA
}

code_0ADAE7 {
    COP [CallNear] ( &code_0ADB19 )
    LDA #$0002
    TSB $12
    COP [SetHMirror]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0ADAF7:
    COP [StageSpriteMoveXY] ( #2D, #09, #0A )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADAF7
}

code_0ADB04 {
    COP [CallNear] ( &code_0ADB19 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]

  loc_0ADB0D:
    COP [StageSpriteMoveY] ( #2B, #0C )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ADB2D )
    BRA loc_0ADB0D
}

code_0ADB19 {
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [RestoreSavedPtr]
}

code_0ADB2D {
    LDA $10
    BIT #$4000
    BNE loc_0ADB36
    COP [RestoreSavedPtr]

  loc_0ADB36:
    COP [Die]
}