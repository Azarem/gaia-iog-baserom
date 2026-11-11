; Hit-toggle prop of the aqueduct back area (scene $12, tile (2B,56)); it uses the switch stats (HP $FF) and never dies.
; 
; Each hit plays frame #11; the first hit (word flag $0114 clear) also plays a sound, applies BG change #14, sets $0114, applies BG change #15 and sets $0115 (event blocks $14 and $15); later hits do nothing more. For form 0 (characterForm = 0) it first sets bit $0200 of $10.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_pickups_effects'

!characterForm                  0AD4
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec12_aqueduct_enemy [
  actor-def < #0F, #01, #01, {

  code_09BF12:
    LDA $characterForm
    BNE loc_09BF1C
    LDA #$0200
    TSB $10

  loc_09BF1C:
    COP [NudgePosition] ( #02, #00 )
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    LDA #$00FF
    STA $currentHp, X

  code_09BF38:
    COP [SetHitCallback] ( &code_09BF46 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [JumpNextFrame] ( @code_09BF38 )
} >
]

code_09BF46 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [BranchOnFlagWord] ( #$0114, #01, &code_09BF68 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #14 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0114 )
    COP [StageBgChange] ( #15 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0115 )
}

code_09BF68 {
    COP [SetEntryHere]
    RTL 
}