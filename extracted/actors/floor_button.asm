; Floor pressure-plate actor with solid collision, 255 HP, and a hit callback.
; 
; When struck, sets a scene flag from the actor's $24 parameter, animates press frames #0F→#10→#0F, and waits 15 frames before resetting. Used in pyramid puzzle rooms and dungeon switch layouts. Triggers puzzle state when the player or objects land on the plate.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

floor_button [
  actor-def < #00, #00, #01, {

  code_00C9FE:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0031
    TSB $12

  loc_00CA1F:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &FloorButtonHitCallback )
    COP [SetEntryContinue]
    RTL 
} >
]

FloorButtonHitCallback {
    LDA $24
    JSL $@cop_handlers_flags.SetFlagRaw
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [WaitByte] ( #0F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_00CA1F
}