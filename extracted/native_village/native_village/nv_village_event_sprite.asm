; Event sprite controller for Native Village cutscenes.
; 
; Technical actor that manages sprite changes during village
; event sequences. Handles costume/appearance transitions
; for cutscene characters.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

nv_village_event_sprite {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #05, #01 )
}

code_0881AE {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [NudgePosition] ( #00, #F6 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}