; Switch mechanism at the Great Wall dive entrance.
; 
; Hittable switch that toggles a gate or passage. When struck,
; changes sprite state and sets the corresponding flag.
; Used to open the path deeper into the wall.
---------------------------------------------

?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'spriteset_enemies'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw83_switch [
  actor-def < #00, #00, #30, {

  code_07BDA7:
    COP [BranchIfFlagWord] ( #$0152, #01, &code_07BDE6 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    LDA #$2000
    TRB $10
    LDA #$0278
    STA $moveXAlt, X
    LDA #$0190
    STA $moveYAlt, X
    COP [StageMove] ( #29, #04, #FF )
    COP [TickMove]
    COP [SpawnAfterFlags] ( @SpawnDebrisBurst, #$2000 )
    COP [StageBgChange] ( #52 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0152 )
} >
]

code_07BDE6 {
    COP [Die]
}