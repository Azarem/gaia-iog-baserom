; Walking laborer NPC in Freejia — animated background character.
; 
; Non-interactable NPC that walks a patrol route through town.
; No dialog. Represents the laborers visible in Freejia's streets.
---------------------------------------------

?INCLUDE 'spriteset_town_objects'

!cameraBoundsY                  06DC

---------------------------------------------

fr32_laborer_npc [
  actor-def < #00, #00, #28, {

  code_05B021:
    LDA #$0420
    STA $cameraBoundsY
    COP [SpawnAfter] ( @code_05B03E )
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @spriteset_town_objects )
    COP [ResetSpriteInit] ( #00, #$3FE0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]

code_05B03E {
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @spriteset_town_objects )
    COP [ResetSpriteInit] ( #01, #$3FF0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
}