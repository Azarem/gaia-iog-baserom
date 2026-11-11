; Toggle block B on the garden southwest underside (scene $52) — a hit switch, not an enemy to kill.
; 
; One placement. Solid enemy sprite with stat entry 118; HP resets to $FF every frame, so it never dies. Each hit swaps between frame #0F (BG change #28, sets $0127/$0128, clears $0129/$012A) and frame #10 (BG change #2A, sets $0129/$012A, clears $0127/$0128). At spawn it starts in frame #0F when $0127 is set and in frame #10 otherwise, without applying a BG change.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_pickups_effects'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg52_blocker_enemy_b [
  actor-def < #0F, #01, #01, {

  code_05F658:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [BranchOnFlagWord] ( #$0127, #01, &code_05F68C )
    BRA loc_05F6BB

  code_05F672:
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #28 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0127 )
    COP [SetFlagWord] ( #$0128 )
    COP [ClearFlagWord] ( #$0129 )
    COP [ClearFlagWord] ( #$012A )
} >
]

code_05F68C {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05F6A1 )
    COP [SetEntryHere]
    RTL 
}

code_05F6A1 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #2A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0129 )
    COP [SetFlagWord] ( #$012A )
    COP [ClearFlagWord] ( #$0127 )
    COP [ClearFlagWord] ( #$0128 )

  loc_05F6BB:
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05F672 )
    COP [SetEntryHere]
    RTL 
}