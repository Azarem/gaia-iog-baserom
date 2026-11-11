; Toggle block A on the garden southwest underside (scene $52) — a hit switch, not an enemy to kill.
; 
; Two placements. Solid enemy sprite with stat entry 118; HP resets to $FF every frame, so it never dies. Each hit swaps between two states: frame #0F with BG change #90 and $0125/$0126 cleared, and frame #10 with BG change #26 and $0125/$0126 set. Both placements test $0126 every frame, so the one that was not hit follows the other and the two always show the same state. The state at spawn follows $0126.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_pickups_effects'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg52_blocker_enemy_a [
  actor-def < #0F, #01, #01, {

  code_05F5E1:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [BranchOnFlagWord] ( #$0126, #01, &code_05F62E )

  code_05F607:
    COP [SetHitCallback] ( &code_05F62E )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #90 )
    COP [ApplyBgChange]
    COP [ClearFlagWord] ( #$0125 )
    COP [ClearFlagWord] ( #$0126 )
    COP [SetEntryHere]
    COP [BranchOnFlagWord] ( #$0126, #01, &code_05F62E )
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05F62E {
    COP [SetHitCallback] ( &code_05F607 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #26 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0125 )
    COP [SetFlagWord] ( #$0126 )
    COP [SetEntryHere]
    COP [BranchOnFlagWord] ( #$0126, #00, &code_05F607 )
    LDA #$00FF
    STA $currentHp, X
    RTL 
}