; Prop sprite of the Hamlet scene in the Native Village (scene $AC), spawned by nvAC_kara at (0088,00FE). It shows frame $30, waits for scratch $05 (set by the narration child of nvAC_hamlet) and then falls into code_0881AE: SetMetasprite spriteset_pickups_effects, a nudge of -10 pixels in Y, frame $07 once and Die. nvAC_kara and nvAC_erik also spawn code_0881AE directly after the same wait.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

---------------------------------------------

nv_village_event_sprite {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #05, #01 )
}

code_0881AE {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [NudgePosition] ( #00, #F6 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}