; Credits miscellaneous timeline events (~300 lines).
; 
; Coordinates timed events during the credits: camera
; transitions, palette changes, special effect triggers,
; and scene switches between revisited locations.
; The timeline backbone for the credits sequence.
---------------------------------------------

?INCLUDE 'CreditPositionLookup'

!decompressedTilesets           7E4000

---------------------------------------------

sF7_credits_misc_timeline {
    COP [HaltIfCounterGte] ( #$3844 )
    COP [SetLinkedActorScript] ( &code_09E675 )
    COP [HaltIfCounterGte] ( #$3A4C )
    COP [SetLinkedActorScript] ( &code_09E65B )
}

code_09E65B {
    COP [Die]
}

code_09E65D {
    COP [SpawnBefore] ( @sF7_credits_misc_timeline )
    LDA #$0041
    JSL $@CreditPositionLookup
    COP [SetMetasprite] ( $7E6000 )

  loc_09E66D:
    COP [StageSpriteMoveX] ( #0E, #01 )
    COP [AnimOnce]
    BRA loc_09E66D
}

code_09E675 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    BRA code_09E675
}

code_09E67C {
    COP [PaletteStart] ( #7C )
    COP [PaletteStep]
    COP [Die]

  code_09E683:
    COP [HaltIfCounterGte] ( #$515C )
    COP [SetLinkedActorScript] ( &code_09E68B )
}

code_09E68B {
    COP [Die]
}

code_09E68D {
    COP [SpawnBefore] ( @code_09E683 )
    COP [SetMetasprite] ( $7E6000 )
    LDA #$0003
    JSL $@CreditPositionLookup

  loc_09E69D:
    COP [StageSpriteMoveX] ( #0A, #02 )
    COP [AnimOnce]
    BRA loc_09E69D
}

code_09E6A5 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0D, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0D, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E6C0 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #09, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E6DB {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0A, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0A, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E6F6 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0B, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0B, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E711 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0C, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0C, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E72C {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #11, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E747 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #15, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #15, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E762 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #16, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #16, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E77D {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #1B, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1B, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E798 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #1C, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1C, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E7B3 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #17, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #17, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E7CE {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0E, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0E, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E7E9 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #0F, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #0F, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E804 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #12, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #12, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E81F {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #13, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #13, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E83A {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #18, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E855 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #14, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #14, #68, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E870 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0020
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #1A, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1A, #88, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E88B {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #19, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #80, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E8A6 {
    COP [SetMetasprite] ( $7E4000 )
    LDA #$0021
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #10, #C8, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #80, #01 )
    COP [AnimLoop]
    COP [Die]
}

code_09E8C1 {
    COP [SetMetasprite] ( $7E6000 )
    LDA #$0032
    JSL $@CreditPositionLookup
    COP [StageSpriteLoopMoveX] ( #13, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #13, #55 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitWord] ( #$0FEF )
    COP [Die]
}