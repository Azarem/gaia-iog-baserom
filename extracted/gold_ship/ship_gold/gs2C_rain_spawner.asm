?INCLUDE 'spriteset_enemies'

!playerXPos                     09A2

---------------------------------------------

gs2C_rain_spawner [
  actor-def < #02, #00, #2B, {

  loc_05813D:
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_058149, #$0B00 )
    BRA loc_05813D
} >
]

code_058149 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePriority] ( #30 )
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $playerXPos
    STA $14
    COP [RngByte]
    AND #$007F
    CLC 
    ADC #$0218
    STA $16
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}