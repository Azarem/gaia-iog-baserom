; Plug mechanism at the Great Wall dive entrance, released by a hit switch.
; 
; Dies at spawn when flag word $0152 is set. Otherwise it waits on WaitOnFlagByte ( #01, #01 ), the scratch flag raised by the hit_switch placed on the same tile (35,1B). It then shows frame #29 of spriteset_pickups_effects, clears $10 bit $2000, moves toward pixel ($0278,$0190) (StageMove ( #29, #04, #FF ), TickMove), spawns a debris burst, applies BG change #52 and sets $0152. The scratch flag is not cleared.
---------------------------------------------

?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'spriteset_pickups_effects'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw83_switch [
  actor-def < #00, #00, #30, {

  code_07BDA7:
    COP [BranchOnFlagWord] ( #$0152, #01, &code_07BDE6 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [SetMetasprite] ( @spriteset_pickups_effects )
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