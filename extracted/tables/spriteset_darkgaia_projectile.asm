; Sprite set of the Dark Gaia fight projectiles (Bank 17, 1560576-1561584, 1008 bytes). The old note ('Will's Psycho Dash and Psycho Slide projectile sprites', 'ranged abilities') was wrong: the only user is the four Projectile* actors of player_character (ProjectileSouth/North/West/East), which the Attack* pieces spawn only in scene $E8 (flags $0602); Psycho Dash and Psycho Slide do not use it.
; 
; Structure (the sprite-set format is documented once in the spriteset_freedan block note): 8 animations, 12 sprite groups of 9 sub-sprites each (76 bytes per group).
; 
; | Index | Set | Frames (hold) | Used by |
; |-------|-----|---------------|---------|
; | $00 | projectile_launch_south | 3 (5, 2, 2) | ProjectileSouth launch, MoveY #09 |
; | $01 | projectile_launch_north | 3 (5, 2, 2) | ProjectileNorth launch, MoveY #0A |
; | $02 | projectile_launch_west | 3 (5, 2, 2) | ProjectileWest launch, MoveX #0A |
; | $03 | projectile_launch_east | 3 (5, 2, 2) | ProjectileEast launch, MoveX #09 |
; | $04-$07 | projectile_travel_south, 17D04E, 17D054, 17D05A | 1 (9) each | looping travel pose of South/North/West/East, MoveY/MoveX #0F or #10 |
; 
; Each travel animation holds a single frame that is the LAST group of its launch animation (e.g. $04 = sprite_group_17D3A4, the last frame of $00), so the projectile keeps its final launch pose while it flies; the 16 frame records therefore use only 12 groups. The ProjectileSouth/North/West/East actors die when they leave the screen, so the travel animation never ends on its own.
; 
; Totals: pointer table 16 bytes, frame lists 80 bytes (4 x 14 + 4 x 6), groups 912 bytes. The tile graphics these sub-sprites draw were not traced (OQ-I067-3).
---------------------------------------------

?BANK 17

---------------------------------------------

; 8 pointers to the animation frame lists: $00-$03 = launch South/North/West/East, $04-$07 = travel loop in the same order.

spriteset_darkgaia_projectile [
  &projectile_launch_south   ;00
  &projectile_launch_north   ;01
  &projectile_launch_west   ;02
  &projectile_launch_east   ;03
  &projectile_travel_south   ;04
  &projectile_travel_north   ;05
  &projectile_travel_west   ;06
  &projectile_travel_east   ;07
]

---------------------------------------------
; Animation $00, South launch: 3 frames (hold 5, 2, 2 ticks + 1 each). Used by ProjectileSouth (#00).

projectile_launch_south [
  sprite-set < #$0005, &sprite_group_17D30C >   ;00
  sprite-set < #$0002, &sprite_group_17D358 >   ;01
  sprite-set < #$0002, &sprite_group_17D3A4 >   ;02
]

---------------------------------------------
; Animation $01, North launch: 3 frames (hold 5, 2, 2). Used by ProjectileNorth (#01).

projectile_launch_north [
  sprite-set < #$0005, &sprite_group_17D228 >   ;00
  sprite-set < #$0002, &sprite_group_17D274 >   ;01
  sprite-set < #$0002, &sprite_group_17D2C0 >   ;02
]

---------------------------------------------
; Animation $02, West launch: 3 frames (hold 5, 2, 2). Used by ProjectileWest (#02).

projectile_launch_west [
  sprite-set < #$0005, &sprite_group_17D144 >   ;00
  sprite-set < #$0002, &sprite_group_17D190 >   ;01
  sprite-set < #$0002, &sprite_group_17D1DC >   ;02
]

---------------------------------------------
; Animation $03, East launch: 3 frames (hold 5, 2, 2). Used by ProjectileEast (#03).

projectile_launch_east [
  sprite-set < #$0005, &sprite_group_17D060 >   ;00
  sprite-set < #$0002, &sprite_group_17D0AC >   ;01
  sprite-set < #$0002, &sprite_group_17D0F8 >   ;02
]

---------------------------------------------
; Animation $04, South travel loop: one frame (hold 9) = last group of animation $00.

projectile_travel_south [
  sprite-set < #$0009, &sprite_group_17D3A4 >
]

---------------------------------------------
; Animation $05, North travel loop: one frame (hold 9) = last group of animation $01.

projectile_travel_north [
  sprite-set < #$0009, &sprite_group_17D2C0 >
]

---------------------------------------------
; Animation $06, West travel loop: one frame (hold 9) = last group of animation $02.

projectile_travel_west [
  sprite-set < #$0009, &sprite_group_17D1DC >
]

---------------------------------------------
; Animation $07, East travel loop: one frame (hold 9) = last group of animation $03.

projectile_travel_east [
  sprite-set < #$0009, &sprite_group_17D0F8 >
]

sprite_group_17D060 [
  sprite-group < #17, #0F, #17, #0C, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #16, #00, #13, #00, #$4444 >   ;00
    sprite-part < #01, #06, #10, #13, #00, #$4446 >   ;01
    sprite-part < #00, #00, #1E, #06, #15, #$4463 >   ;02
    sprite-part < #00, #00, #1E, #0E, #0D, #$4464 >   ;03
    sprite-part < #01, #06, #10, #06, #0D, #$4442 >   ;04
    sprite-part < #01, #13, #03, #06, #0D, #$4440 >   ;05
    sprite-part < #00, #0E, #10, #00, #1B, #$4461 >   ;06
    sprite-part < #00, #06, #18, #00, #1B, #$4462 >   ;07
    sprite-part < #00, #16, #08, #00, #1B, #$4460 >   ;08
  ] >
]

sprite_group_17D0AC [
  sprite-group < #16, #11, #18, #0D, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #17, #00, #15, #00, #$4444 >   ;00
    sprite-part < #01, #07, #10, #15, #00, #$4446 >   ;01
    sprite-part < #00, #00, #1F, #07, #16, #$4463 >   ;02
    sprite-part < #00, #00, #1F, #0F, #0E, #$4464 >   ;03
    sprite-part < #01, #07, #10, #07, #0E, #$4442 >   ;04
    sprite-part < #01, #15, #02, #07, #0E, #$4440 >   ;05
    sprite-part < #00, #0F, #10, #00, #1D, #$4461 >   ;06
    sprite-part < #00, #07, #18, #00, #1D, #$4462 >   ;07
    sprite-part < #00, #17, #08, #00, #1D, #$4460 >   ;08
  ] >
]

sprite_group_17D0F8 [
  sprite-group < #15, #13, #1A, #0F, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #18, #00, #19, #00, #$4444 >   ;00
    sprite-part < #01, #08, #10, #19, #00, #$4446 >   ;01
    sprite-part < #00, #00, #20, #09, #18, #$4463 >   ;02
    sprite-part < #00, #00, #20, #11, #10, #$4464 >   ;03
    sprite-part < #01, #08, #10, #09, #10, #$4442 >   ;04
    sprite-part < #01, #18, #00, #09, #10, #$4440 >   ;05
    sprite-part < #00, #10, #10, #01, #20, #$4461 >   ;06
    sprite-part < #00, #08, #18, #01, #20, #$4462 >   ;07
    sprite-part < #00, #18, #08, #00, #21, #$4460 >   ;08
  ] >
]

sprite_group_17D144 [
  sprite-group < #0F, #17, #17, #0C, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #00, #16, #13, #00, #$0444 >   ;00
    sprite-part < #01, #10, #06, #13, #00, #$0446 >   ;01
    sprite-part < #00, #1E, #00, #06, #15, #$0463 >   ;02
    sprite-part < #00, #1E, #00, #0E, #0D, #$0464 >   ;03
    sprite-part < #01, #10, #06, #06, #0D, #$0442 >   ;04
    sprite-part < #01, #03, #13, #06, #0D, #$0440 >   ;05
    sprite-part < #00, #10, #0E, #00, #1B, #$0461 >   ;06
    sprite-part < #00, #18, #06, #00, #1B, #$0462 >   ;07
    sprite-part < #00, #08, #16, #00, #1B, #$0460 >   ;08
  ] >
]

sprite_group_17D190 [
  sprite-group < #11, #16, #18, #0D, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #00, #17, #15, #00, #$0444 >   ;00
    sprite-part < #01, #10, #07, #15, #00, #$0446 >   ;01
    sprite-part < #00, #1F, #00, #07, #16, #$0463 >   ;02
    sprite-part < #00, #1F, #00, #0F, #0E, #$0464 >   ;03
    sprite-part < #01, #10, #07, #07, #0E, #$0442 >   ;04
    sprite-part < #01, #02, #15, #07, #0E, #$0440 >   ;05
    sprite-part < #00, #10, #0F, #00, #1D, #$0461 >   ;06
    sprite-part < #00, #18, #07, #00, #1D, #$0462 >   ;07
    sprite-part < #00, #08, #17, #00, #1D, #$0460 >   ;08
  ] >
]

sprite_group_17D1DC [
  sprite-group < #13, #15, #1A, #0F, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #00, #18, #19, #00, #$0444 >   ;00
    sprite-part < #01, #10, #08, #19, #00, #$0446 >   ;01
    sprite-part < #00, #20, #00, #09, #18, #$0463 >   ;02
    sprite-part < #00, #20, #00, #11, #10, #$0464 >   ;03
    sprite-part < #01, #10, #08, #09, #10, #$0442 >   ;04
    sprite-part < #01, #00, #18, #09, #10, #$0440 >   ;05
    sprite-part < #00, #10, #10, #01, #20, #$0461 >   ;06
    sprite-part < #00, #18, #08, #01, #20, #$0462 >   ;07
    sprite-part < #00, #08, #18, #00, #21, #$0460 >   ;08
  ] >
]

sprite_group_17D228 [
  sprite-group < #15, #15, #18, #12, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #0D, #0D, #00, #1A, #$0448 >   ;00
    sprite-part < #01, #0D, #0D, #0D, #0D, #$044A >   ;01
    sprite-part < #01, #0D, #0D, #1A, #00, #$044C >   ;02
    sprite-part < #01, #1A, #00, #0D, #0D, #$044E >   ;03
    sprite-part < #01, #00, #1A, #0D, #0D, #$444E >   ;04
    sprite-part < #00, #1A, #08, #05, #1D, #$0468 >   ;05
    sprite-part < #00, #21, #01, #05, #1D, #$0469 >   ;06
    sprite-part < #00, #01, #21, #05, #1D, #$4469 >   ;07
    sprite-part < #00, #08, #1A, #05, #1D, #$4468 >   ;08
  ] >
]

sprite_group_17D274 [
  sprite-group < #16, #16, #1B, #11, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #0E, #0E, #00, #1C, #$0448 >   ;00
    sprite-part < #01, #0E, #0E, #0E, #0E, #$044A >   ;01
    sprite-part < #01, #0E, #0E, #1C, #00, #$044C >   ;02
    sprite-part < #01, #1C, #00, #0E, #0E, #$044E >   ;03
    sprite-part < #01, #00, #1C, #0E, #0E, #$444E >   ;04
    sprite-part < #00, #1C, #08, #06, #1E, #$0468 >   ;05
    sprite-part < #00, #24, #00, #06, #1E, #$0469 >   ;06
    sprite-part < #00, #00, #24, #06, #1E, #$4469 >   ;07
    sprite-part < #00, #08, #1C, #06, #1E, #$4468 >   ;08
  ] >
]

sprite_group_17D2C0 [
  sprite-group < #18, #18, #20, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #10, #10, #00, #20, #$0448 >   ;00
    sprite-part < #01, #10, #10, #10, #10, #$044A >   ;01
    sprite-part < #01, #10, #10, #20, #00, #$044C >   ;02
    sprite-part < #01, #20, #00, #10, #10, #$044E >   ;03
    sprite-part < #01, #00, #20, #10, #10, #$444E >   ;04
    sprite-part < #00, #20, #08, #08, #20, #$0468 >   ;05
    sprite-part < #00, #28, #00, #08, #20, #$0469 >   ;06
    sprite-part < #00, #00, #28, #08, #20, #$4469 >   ;07
    sprite-part < #00, #08, #20, #08, #20, #$4468 >   ;08
  ] >
]

sprite_group_17D30C [
  sprite-group < #15, #15, #12, #18, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #0D, #0D, #1A, #00, #$8448 >   ;00
    sprite-part < #01, #0D, #0D, #0D, #0D, #$844A >   ;01
    sprite-part < #01, #0D, #0D, #00, #1A, #$844C >   ;02
    sprite-part < #01, #1A, #00, #0D, #0D, #$844E >   ;03
    sprite-part < #01, #00, #1A, #0D, #0D, #$C44E >   ;04
    sprite-part < #00, #1A, #08, #1D, #05, #$8468 >   ;05
    sprite-part < #00, #21, #01, #1D, #05, #$8469 >   ;06
    sprite-part < #00, #01, #21, #1D, #05, #$C469 >   ;07
    sprite-part < #00, #08, #1A, #1D, #05, #$C468 >   ;08
  ] >
]

sprite_group_17D358 [
  sprite-group < #16, #16, #11, #1B, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #0E, #0E, #1C, #00, #$8448 >   ;00
    sprite-part < #01, #0E, #0E, #0E, #0E, #$844A >   ;01
    sprite-part < #01, #0E, #0E, #00, #1C, #$844C >   ;02
    sprite-part < #01, #1C, #00, #0E, #0E, #$844E >   ;03
    sprite-part < #01, #00, #1C, #0E, #0E, #$C44E >   ;04
    sprite-part < #00, #1C, #08, #1E, #06, #$8468 >   ;05
    sprite-part < #00, #24, #00, #1E, #06, #$8469 >   ;06
    sprite-part < #00, #00, #24, #1E, #06, #$C469 >   ;07
    sprite-part < #00, #08, #1C, #1E, #06, #$C468 >   ;08
  ] >
]

sprite_group_17D3A4 [
  sprite-group < #18, #18, #10, #20, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #10, #10, #20, #00, #$8448 >   ;00
    sprite-part < #01, #10, #10, #10, #10, #$844A >   ;01
    sprite-part < #01, #10, #10, #00, #20, #$844C >   ;02
    sprite-part < #01, #20, #00, #10, #10, #$844E >   ;03
    sprite-part < #01, #00, #20, #10, #10, #$C44E >   ;04
    sprite-part < #00, #20, #08, #20, #08, #$8468 >   ;05
    sprite-part < #00, #28, #00, #20, #08, #$8469 >   ;06
    sprite-part < #00, #00, #28, #20, #08, #$C469 >   ;07
    sprite-part < #00, #08, #20, #20, #08, #$C468 >   ;08
  ] >
]