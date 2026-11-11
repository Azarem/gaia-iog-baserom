; Aura Barrier orbital spriteset (Bank 17, 1544192-1544617 = $17:9000): 3 animations ($00-$02), 12 frame records, 12 sprite groups, 30 sub-sprites. Only user: AuraProjectileChild in attack_ability_system (COP SetMetasprite ( @spriteset_aura )); AuraOrbitalSpawner makes 2 or 4 of those actors (4 when the upgrade flag $0B1E is set) and moves them around the player. The struct format is described in the spriteset_freedan block note.
; 
; === ANIMATIONS ===
; 
; | Index | Shape | Played by |
; |-------|-------|-----------|
; | $00 | 4 frames, hold 7 (8 ticks each), 2 sub-sprites of 8x8 per frame (small sparks) | AnimOnce first, and last when the orbital shrinks |
; | $01 | 4 frames, hold 7, 3 sub-sprites per frame (a 16x16 and two 8x8 in the first, three 8x8 in the others) | AnimOnce second, and first when the orbital shrinks |
; | $02 | 4 frames, hold 7, 2 sub-sprites of 16x16 (frames 0, 1 and 3) or 4 of 8x8 (frame 2) | the loop that runs until the spawner overwrites the actor's function pointer with AuraProjectileShrink |
; 
; AuraProjectileChild stages $00 and $01 once (the orbital grows) and then loops $02; AuraProjectileShrink plays $01 and $00 once and hides the actor ($10 bit $2000). All 12 groups keep the default attack box $F8 $F0 $01 $01 (group bytes 4-7); nothing reads it for the orbitals (measured over a full cast that shows all 12 groups: no read of bytes 4-7, and PlayerAttackHitTest never runs for an orbital).
; 
; Hit rectangle: AuraOrbitalSpawner spawns each orbital with $10 = $0600 (the COP SpawnAfterMarked operand). $0400 makes the orbital a source of the second pass of CombatCollision: it builds the hit rectangle from the body box, group bytes 8-11 (X offset, width, Y offset, height in pixels, signed offsets; $FC $08 $F8 $16 for the first group = X -4 to +4, Y -8 to +14 around the actor position, mirrored for an H-flipped actor), and calls ApplyHitDamageToVictim for every actor of the render list whose own hitbox ($20-$23) overlaps it and whose $10 has none of the $76E0 bits; $0200 keeps the orbital itself out of that victim set. Measured: the rectangle in DP $00-$06 equals the header formula in all 538 orbital passes of a cast, an actor is hit when its left edge (X minus its west extent) is below the rectangle's right edge and its right edge is at least the rectangle's left edge (same rule on Y), and a bat took 2 HP per orbital hit (3 to 1, then 1 to 0). The body box is 1 to 6 pixels taller than the frame extents (bytes 0-3) in all 12 groups (first group: height 22 against 16); nothing in the code derives it from the sub-sprites.
; 
; === ART AND PALETTE ===
; 
; Every tile word is in $0440-$046F: tile numbers $40-$6F with the palette bits (9-11) = 2, i.e. sprite palette 2 (CGRAM $A0-$AF). AuraVramDmaLoader uploads $0600 bytes (48 tiles) of misc_fx_1CC480 to VRAM $4400 with COP AdhocVramDma, and AuraBarrierMain copies 7 colours of fx_palette_198090 to CGRAM $A9-$AF; AuraBarrierPaletteFX cycles bundle #5B over colours $A1-$A8 of the same palette (the bundle writes only $A1-$A8). The Freedan Aura Barrier uploads misc_fx_1CC480 (48 tiles) to VRAM $4400 with the sprite name base at $4000 (measured: no $2101 write occurs during the cast, so $4400 is tile $40 of the first sprite name table); the Shadow Aura item neither writes OBSEL nor uploads to $4400.
; 
; Byte budget: 426 bytes = 6 (table) + 3 x 18 (lists of 4 records + the hidden $FFFF) + 12 x 13 (group headers) + 30 x 7 (sub-sprites).
---------------------------------------------

?BANK 17

---------------------------------------------

; 3 pointers to the frame lists, indexed by the animation number staged by AuraProjectileChild / AuraProjectileShrink: $00 and $01 grow-in, $02 the looping orbit. See the block note.

spriteset_aura [
  &aura_anim_00_spark_in   ;00
  &aura_anim_01_grow   ;01
  &aura_anim_02_orbit   ;02
]

---------------------------------------------
; Animation $00: 4 frames, hold 7, groups sprite_group_17903C ... 17908D (two 8x8 sub-sprites each, tile words $0460-$0466). The first stage of the grow-in and the last of the shrink.

aura_anim_00_spark_in [
  sprite-set < #$0007, &sprite_group_17903C >   ;00
  sprite-set < #$0007, &sprite_group_179057 >   ;01
  sprite-set < #$0007, &sprite_group_179072 >   ;02
  sprite-set < #$0007, &sprite_group_17908D >   ;03
]

---------------------------------------------
; Animation $01: 4 frames, hold 7, groups sprite_group_1790A8 ... 17910E (three sub-sprites each, tile words $044C-$044F, $045E-$045F, $0467-$046F). The second stage of the grow-in and the first of the shrink.

aura_anim_01_grow [
  sprite-set < #$0007, &sprite_group_1790A8 >   ;00
  sprite-set < #$0007, &sprite_group_1790CA >   ;01
  sprite-set < #$0007, &sprite_group_1790EC >   ;02
  sprite-set < #$0007, &sprite_group_17910E >   ;03
]

---------------------------------------------
; Animation $02: 4 frames, hold 7, groups sprite_group_179130 ... 17918F (16x16 pairs in frames 0, 1 and 3, four 8x8 tiles in frame 2). The loop that runs while the orbit is active.

aura_anim_02_orbit [
  sprite-set < #$0007, &sprite_group_179130 >   ;00
  sprite-set < #$0007, &sprite_group_17914B >   ;01
  sprite-set < #$0007, &sprite_group_179166 >   ;02
  sprite-set < #$0007, &sprite_group_17918F >   ;03
]

---------------------------------------------
; Example group: animation $00, frame 0. Header: extents X 4 / 4, Y 8 / 8, default attack box, body box $FC $08 $F8 $16 (the orbital's hit rectangle: X -4 to +4, Y -8 to +14 around the actor position), 2 sub-sprites (8x8, tile words $0460 and $0464, offsets (0,8) and (8,0)).

sprite_group_17903C [
  sprite-group < #04, #04, #08, #08, #F8, #F0, #01, #01, #FC, #08, #F8, #16, #02, [
    sprite-part < #00, #00, #00, #00, #08, #$0460 >   ;00
    sprite-part < #00, #00, #00, #08, #00, #$0464 >   ;01
  ] >
]

sprite_group_179057 [
  sprite-group < #04, #04, #07, #09, #F8, #F0, #01, #01, #FC, #07, #FA, #13, #02, [
    sprite-part < #00, #00, #00, #00, #08, #$0461 >   ;00
    sprite-part < #00, #00, #00, #08, #00, #$0465 >   ;01
  ] >
]

sprite_group_179072 [
  sprite-group < #03, #05, #07, #08, #F8, #F0, #01, #01, #FC, #07, #F7, #10, #02, [
    sprite-part < #00, #00, #00, #00, #07, #$0463 >   ;00
    sprite-part < #00, #00, #00, #07, #00, #$0463 >   ;01
  ] >
]

sprite_group_17908D [
  sprite-group < #04, #04, #08, #08, #F8, #F0, #01, #01, #FC, #07, #F9, #12, #02, [
    sprite-part < #00, #00, #00, #00, #08, #$0462 >   ;00
    sprite-part < #00, #00, #00, #08, #00, #$0466 >   ;01
  ] >
]

sprite_group_1790A8 [
  sprite-group < #05, #0B, #0D, #0B, #F8, #F0, #01, #01, #F9, #0F, #F5, #1B, #03, [
    sprite-part < #01, #00, #00, #00, #08, #$044C >   ;00
    sprite-part < #00, #00, #08, #10, #00, #$046C >   ;01
    sprite-part < #00, #08, #00, #10, #00, #$046D >   ;02
  ] >
]

sprite_group_1790CA [
  sprite-group < #04, #04, #0C, #0C, #F8, #F0, #01, #01, #FA, #0D, #F5, #19, #03, [
    sprite-part < #00, #00, #00, #00, #10, #$044E >   ;00
    sprite-part < #00, #00, #00, #08, #08, #$045E >   ;01
    sprite-part < #00, #00, #00, #10, #00, #$046E >   ;02
  ] >
]

sprite_group_1790EC [
  sprite-group < #04, #04, #0B, #0B, #F8, #F0, #01, #01, #FA, #0C, #F1, #1B, #03, [
    sprite-part < #00, #00, #00, #0E, #00, #$0468 >   ;00
    sprite-part < #00, #00, #00, #00, #0E, #$0467 >   ;01
    sprite-part < #00, #00, #00, #08, #06, #$0468 >   ;02
  ] >
]

sprite_group_17910E [
  sprite-group < #04, #04, #0C, #0C, #F8, #F0, #01, #01, #F9, #0C, #F4, #19, #03, [
    sprite-part < #00, #00, #00, #00, #10, #$044F >   ;00
    sprite-part < #00, #00, #00, #08, #08, #$045F >   ;01
    sprite-part < #00, #00, #00, #10, #00, #$046F >   ;02
  ] >
]

sprite_group_179130 [
  sprite-group < #08, #08, #0F, #11, #F8, #F0, #01, #01, #F8, #10, #F2, #22, #02, [
    sprite-part < #01, #00, #00, #00, #10, #$0440 >   ;00
    sprite-part < #01, #00, #00, #10, #00, #$0446 >   ;01
  ] >
]

sprite_group_17914B [
  sprite-group < #08, #08, #0E, #12, #F8, #F0, #01, #01, #F8, #10, #F1, #23, #02, [
    sprite-part < #01, #00, #00, #00, #10, #$0442 >   ;00
    sprite-part < #01, #00, #00, #10, #00, #$0448 >   ;01
  ] >
]

sprite_group_179166 [
  sprite-group < #04, #04, #0E, #12, #F8, #F0, #01, #01, #F8, #10, #F0, #25, #04, [
    sprite-part < #00, #00, #00, #00, #18, #$0469 >   ;00
    sprite-part < #00, #00, #00, #08, #10, #$046A >   ;01
    sprite-part < #00, #00, #00, #10, #08, #$046A >   ;02
    sprite-part < #00, #00, #00, #18, #00, #$046B >   ;03
  ] >
]

sprite_group_17918F [
  sprite-group < #08, #08, #0E, #12, #F8, #F0, #01, #01, #F8, #10, #F2, #21, #02, [
    sprite-part < #01, #00, #00, #00, #10, #$0444 >   ;00
    sprite-part < #01, #00, #00, #10, #00, #$044A >   ;01
  ] >
]