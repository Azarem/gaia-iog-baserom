; Short death effect actor (Bank 00): plays animation #01 of spriteset_pickups_effects once, then removes itself.
; 
; Spawned at the position of a defeated enemy by SpawnListAppend ( @EnemyDeathFlash, #00, #00 (#10 in gw8A_sand_fanger), #$0302 ) from StandardEnemyDefeatHandler (the standard field-enemy defeat), EnemyDefeatDispatch, awB0_zombie, awB1_wall_walker, gw8A_sand_fanger, sg4D_dynapede, sg4E_nitropede and sg4D_knight_armor (two sites); sg4D_dynapede also ends with JumpFar into it, so that actor turns into the effect itself.
; 
; Sequence: SetMetasprite points the actor at spriteset_pickups_effects, a table of frame lists with one list per animation index; SetSpritePalette #00 sets the actor's OAM palette field (bits $0E00 of $0E) to 0, which leaves every sprite on the palette stored in its sprite group; StageSpriteFrame #01 selects animation list #01 (pickups_effects_01_death_flash), eight frames from the sprite groups 0EE514, 0EE53D, 0EE566, 0EECA9, 0EE58F, 0EECA9, 0EE5F0 and 0EE619 with hold values 2, 2, 2, 1, 0, 0, 2, 2 (a hold of n shows the frame for n + 1 ticks, 19 ticks in all); AnimOnce plays the list once and yields until it ends; then TSB $10 sets $2000 (hidden / script-only) and Die unlinks the actor in the same run, so no rendered frame ever sees the flag. Why it sets the flag is unknown.
; 
; What the animation looks like was not verified: the sprite groups and their palette were not decoded.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

---------------------------------------------

; Actor script: SetMetasprite, SetSpritePalette #00, StageSpriteFrame #01, AnimOnce, TSB $10 with $2000, Die. Runs for the 19 ticks of animation list #01.

EnemyDeathFlash {
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Frame lists: spriteset_pickups_effects (one list per animation index)
    COP [SetSpritePalette] ( #00 ) ; OAM palette field = 0: the sprite groups keep their own palette
    COP [StageSpriteFrame] ( #01 ) ; Animation index #01 = pickups_effects_01_death_flash (eight frames, 19 ticks)
    COP [AnimOnce]        ; Play the list once; the script continues after the last frame
    LDA #$2000            ; $2000 = hidden / script-only in the actor flags
    TSB $10               ; Set it on this actor; Die below runs in the same frame, so it is never drawn with it
    COP [Die]             ; Unlink this actor
}