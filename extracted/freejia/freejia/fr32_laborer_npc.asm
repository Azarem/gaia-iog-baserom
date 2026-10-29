; Walking laborer NPC in Freejia — animated background character.
; 
; Non-interactable NPC that walks a patrol route through town.
; No dialog. Represents the laborers visible in Freejia's streets.
---------------------------------------------

?INCLUDE 'spriteset_freejia_tilefx'

!cameraBoundsY                  06DC

---------------------------------------------

fr32_laborer_npc [
  actor-def < #00, #00, #28, {

  code_05B021:
    LDA #$0420
    STA $cameraBoundsY
    COP [SpawnAfter] ( @code_05B03E )
    COP [SetScratchPointer] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @spriteset_freejia_tilefx )
    COP [SetTileStreamAnim] ( #00, #$3FE0 )
    COP [AdvanceSpriteAnim]
    RTL 
} >
]

code_05B03E {
    COP [SetScratchPointer] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @spriteset_freejia_tilefx )
    COP [SetTileStreamAnim] ( #01, #$3FF0 )
    COP [AdvanceSpriteAnim]
    RTL 
}