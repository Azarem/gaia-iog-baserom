; Ocean wave visual effects during the adrift sequence.
; 
; Loads spriteset_adrift_wave misc data and plays a looping wave
; animation overlay using ResetSpriteInit and LoadSpriteAnimGlobal.
; Provides the atmospheric ocean surface effect during the drift.
---------------------------------------------

?INCLUDE 'spriteset_adrift_wave'

---------------------------------------------

dc2F_adrift_fx [
  actor-def < #00, #00, #28, {

  code_0596FD:
    COP [SetScratchPointer] ( @misc_fx_1CD180 )
    COP [SetMetasprite] ( @spriteset_adrift_wave )
    COP [SetTileStreamAnim] ( #00, #$2010 )
    COP [AdvanceSpriteAnim]
    RTL 
} >
]