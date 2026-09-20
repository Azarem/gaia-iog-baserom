; Four Way statue trap — fires projectiles in 4 diagonal directions.
; 
; Solid enemy on a tile, waits offscreen. When visible and not already
; hit ($4000), plays an idle loop (#28), then checks player axis.
; Fires 4 projectile children at diagonal offsets with SFX #1E.
; Projectiles fly diagonally until hitting a wall. After firing,
; plays cooldown animation and repeats. Also has a variant that
; fires only 2 directional projectiles based on player position.
---------------------------------------------

---------------------------------------------

ir1D_four_way [
  actor-def < #09, #00, #00, {

  code_0A8C73:
    COP [AddPosition] ( #08, #00 )
    LDA #$0011
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]

  loc_0A8C82:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8C85:
    LDA $10
    BIT #$4000
    BNE loc_0A8C82
    COP [StageSpriteLoop] ( #28, #08 )
    COP [AnimLoop]
    COP [DirToPlayer]
    AND #$0001
    BEQ loc_0A8CD2
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnLastRel] ( @code_0A8D61, #F2, #F0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D74, #0F, #F0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D87, #F2, #04, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D9A, #0F, #04, #$0200 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #27, #02 )
    COP [AnimLoop]
    BRA code_0A8C85

  loc_0A8CD2:
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnLastRel] ( @code_0A8D0C, #00, #E0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D2B, #00, #00, #$0202 )
    COP [SpawnLastRel] ( @code_0A8D3D, #E8, #F5, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D4F, #18, #F5, #$0200 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    JMP $&code_0A8C85
} >
]

code_0A8D0C {
    JSR $&code_0A8DAD
    COP [ToggleVFlip]
    COP [StageSpriteMoveY] ( #0D, #06 )
    COP [AnimOnce]
    LDA #$0002
    TSB $10

  loc_0A8D1C:
    COP [StageSpriteMoveY] ( #0D, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D1C
    COP [Die]
}

code_0A8D2B {
    JSR $&code_0A8DAD

  loc_0A8D2E:
    COP [StageSpriteMoveY] ( #0D, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D2E
    COP [Die]
}

code_0A8D3D {
    JSR $&code_0A8DAD

  loc_0A8D40:
    COP [StageSpriteMoveX] ( #0C, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D40
    COP [Die]
}

code_0A8D4F {
    JSR $&code_0A8DAD

  loc_0A8D52:
    COP [StageSpriteMoveX] ( #8C, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D52
    COP [Die]
}

code_0A8D61 {
    JSR $&code_0A8DAD
    COP [StageSpriteMoveXY] ( #2C, #04, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D61
    COP [Die]
}

code_0A8D74 {
    JSR $&code_0A8DAD
    COP [StageSpriteMoveXY] ( #AC, #03, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D74
    COP [Die]
}

code_0A8D87 {
    JSR $&code_0A8DAD
    COP [StageSpriteMoveXY] ( #2B, #04, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D87
    COP [Die]
}

code_0A8D9A {
    JSR $&code_0A8DAD
    COP [StageSpriteMoveXY] ( #AB, #03, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D9A
    COP [Die]
}

code_0A8DAD {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    RTS 
}