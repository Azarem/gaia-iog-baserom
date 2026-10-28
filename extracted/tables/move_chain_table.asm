; Movement delta chains (Bank 01, 110726-115587): 85 word pointers ($00-$54) to chains of delta-nodes, followed by the 1,173 nodes (4,692 bytes, 01B130-01C383). Every movement index in the game is an index into this table: COP movement operands (StageMoveX/Y/XY, StageSpriteMove*, the player Move ops), walk_step_table (forced walks), the world map route steps and the hit stagger all name a chain, not a distance or a speed.
; 
; === NODE AND CHAIN ===
; 
; A delta-node is { signed word value, &next }. The value is a per-frame position delta in pixels; the link is the next node. An actor holds the current node pointer in $2C (X chain) or $2E (Y chain): actor_pool.AnimFrameLookup turns an index into the head pointer (table + index x 2), and ApplyMovement / ApplyMovementWithCollision (tile_collision_physics) add the node's value to $14 / $16 once per frame (negated when $12 bit 14 / bit 13 flips the axis) and move the pointer to the link. A zero pointer means no chain: the actor then uses its per-actor scratch delta (moveScratch1/2). The raw index stays in moveXAlt / moveYAlt ($7F0018 / $7F001A).
; 
; Each chain ends in exactly one of three ways (counted over the whole file; 85 chains = 1 + 58 + 26):
; - null link ($0000): 1 chain, entry $00. The value 0 is applied once and the pointer is cleared.
; - link to itself: 58 chains. The last node repeats forever (constant speed, or 0 = stand still after a one-shot curve).
; - link back to an earlier node: 26 chains. The chain loops (fractional speeds, oscillations, periodic pulses).
; 
; === FAMILIES (indices) ===
; 
; - $00: null chain (value 0, link 0).
; - $01-$10: constant +/-1 .. +/-8 pixels per frame, one self-linked node each; odd index = positive, even = negative ($01 = +1, $02 = -1, $03 = +2 ... $0F = +8, $10 = -8).
; - $11-$14: fractional constant speeds as 2- and 4-node cycles: $11 +1,0 (+1/2 average), $12 -1,0 (-1/2), $13 +1,0,0,0 (+1/4), $14 -1,0,0,0 (-1/4).
; - $15-$54: programmed curves of 1 to 57 nodes: delayed starts (runs of 0), acceleration and deceleration ramps, out-and-back arcs that sum to 0, periodic pulses and pauses (e.g. $3C = +8,0,0,0 repeating, $53 = 16 frames still then 16 frames at -1, repeating). Chain lengths: 1 node ($00-$10, $1F, $20, $37), 2 ($11, $12), 3 ($3F), 4 ($13, $14, $16, $17, $3C), 5 ($51, $52), 6 ($1D, $1E), longest $21 (57), $4C (43), $3D (37), $4D and $4E (33). $16 and $17 are 4-node cycles of +1 / -1 and behave exactly like $01 / $02; $1F, $20 and $37 are a single 0 node that links to itself.
; - Node values range from -8 to +12; 0 is the commonest (302 of 1,173 nodes), then +1 (183), -1 (156), +2 (126).
; 
; === USERS ===
; 
; - COP movement operands via AnimFrameLookup (cop_handlers_force_move, cop_handlers_sprite, cop_handlers_player_sprite), for example $36 in attack_ability_system and $0F / $10 in ramps.
; - forced_walk: walk_step_table byte 1 ($00, $11-$14).
; - WorldMapController route steps: three indices per step (X $00CA, Y $00CC, rotation $00BC), see world_map_options.
; - hit_stagger_controller: $22 (tier 0, 48 px) and $23 (tier 1 and above, 32 px).
; - unused_particle_rain_spawner: indices 3-10.
; 
; The old header said 'simple entries ($00-$11) are single constants' ($11 is a 2-node cycle, $00 a null chain) and that camera scrolling uses the table; no camera code reads it (AnimFrameLookup is called only from the three COP handler files, and the world map sets the camera from the route position).
; 
; Checked: table, chain-end counts, node counts and all 85 chain lengths over the whole file; consumers ApplyMovement, AnimFrameLookup, both ReadDirSprite helpers, WorldMapController, hit_stagger_controller, ramps, unused_particle_rain_spawner and the COP handler headers read; SAMPLED 50 of the 85 chains node by node ($00-$17 read or dumped, $18-$27, $36, $37, $3C, $3D, $3F, $4C, $51-$54 dumped; the other 35 are only counted). Not traced at runtime (UNVERIFIED-RUNTIME): that one node is consumed per frame, and what the long curves look like in motion.
---------------------------------------------

?BANK 01

---------------------------------------------

; 85 word pointers, indexed by the movement index ($00-$54), each the head of a delta-node chain. AnimFrameLookup returns table[index x 2]; callers store it in actor field $2C (X) or $2E (Y). See the block note for the node format, the chain endings and the index families.

move_chain_table [
  &move_chain_00   ;00
  &move_chain_01   ;01
  &move_chain_02   ;02
  &move_chain_03   ;03
  &move_chain_04   ;04
  &move_chain_05   ;05
  &move_chain_06   ;06
  &move_chain_07   ;07
  &move_chain_08   ;08
  &move_chain_09   ;09
  &move_chain_0A   ;0A
  &move_chain_0B   ;0B
  &move_chain_0C   ;0C
  &move_chain_0D   ;0D
  &move_chain_0E   ;0E
  &move_chain_0F   ;0F
  &move_chain_10   ;10
  &move_chain_11   ;11
  &move_chain_12   ;12
  &move_chain_13   ;13
  &move_chain_14   ;14
  &move_chain_15   ;15
  &move_chain_16   ;16
  &move_chain_17   ;17
  &move_chain_18   ;18
  &move_chain_19   ;19
  &move_chain_1A   ;1A
  &move_chain_1B   ;1B
  &move_chain_1C   ;1C
  &move_chain_1D   ;1D
  &move_chain_1E   ;1E
  &move_chain_1F   ;1F
  &move_chain_20   ;20
  &move_chain_21   ;21
  &move_chain_22   ;22
  &move_chain_23   ;23
  &move_chain_24   ;24
  &move_chain_25   ;25
  &move_chain_26   ;26
  &move_chain_27   ;27
  &move_chain_28   ;28
  &move_chain_29   ;29
  &move_chain_2A   ;2A
  &move_chain_2B   ;2B
  &move_chain_2C   ;2C
  &move_chain_2D   ;2D
  &move_chain_2E   ;2E
  &move_chain_2F   ;2F
  &move_chain_30   ;30
  &move_chain_31   ;31
  &move_chain_32   ;32
  &move_chain_33   ;33
  &move_chain_34   ;34
  &move_chain_35   ;35
  &move_chain_36   ;36
  &move_chain_37   ;37
  &move_chain_38   ;38
  &move_chain_39   ;39
  &move_chain_3A   ;3A
  &move_chain_3B   ;3B
  &move_chain_3C   ;3C
  &move_chain_3D   ;3D
  &move_chain_3E   ;3E
  &move_chain_3F   ;3F
  &move_chain_40   ;40
  &move_chain_41   ;41
  &move_chain_42   ;42
  &move_chain_43   ;43
  &move_chain_44   ;44
  &move_chain_45   ;45
  &move_chain_46   ;46
  &move_chain_47   ;47
  &move_chain_48   ;48
  &move_chain_49   ;49
  &move_chain_4A   ;4A
  &move_chain_4B   ;4B
  &move_chain_4C   ;4C
  &move_chain_4D   ;4D
  &move_chain_4E   ;4E
  &move_chain_4F   ;4F
  &move_chain_50   ;50
  &move_chain_51   ;51
  &move_chain_52   ;52
  &move_chain_53   ;53
  &move_chain_54   ;54
]

---------------------------------------------
; Entry $00: value 0, link $0000 (null). ApplyMovement adds 0, stores $0000 in $2C / $2E and the actor falls back to its per-actor scratch delta. The only chain with a null link.

move_chain_00 [
  delta-node < #$0000, #$0000 >
]

---------------------------------------------
; Entries $01-$10 (01B134-01B170): one node each, linked to itself. $01 = +1, $02 = -1, $03 = +2, $04 = -2 ... $0F = +8, $10 = -8 pixels per frame.

move_chain_01 [
  delta-node < #$0001, &move_chain_01 >
]

move_chain_02 [
  delta-node < #$FFFF, &move_chain_02 >
]

move_chain_03 [
  delta-node < #$0002, &move_chain_03 >
]

move_chain_04 [
  delta-node < #$FFFE, &move_chain_04 >
]

move_chain_05 [
  delta-node < #$0003, &move_chain_05 >
]

move_chain_06 [
  delta-node < #$FFFD, &move_chain_06 >
]

move_chain_07 [
  delta-node < #$0004, &move_chain_07 >
]

move_chain_08 [
  delta-node < #$FFFC, &move_chain_08 >
]

move_chain_09 [
  delta-node < #$0005, &move_chain_09 >
]

move_chain_0A [
  delta-node < #$FFFB, &move_chain_0A >
]

move_chain_0B [
  delta-node < #$0006, &move_chain_0B >
]

move_chain_0C [
  delta-node < #$FFFA, &move_chain_0C >
]

move_chain_0D [
  delta-node < #$0007, &move_chain_0D >
]

move_chain_0E [
  delta-node < #$FFF9, &move_chain_0E >
]

move_chain_0F [
  delta-node < #$0008, &move_chain_0F >
]

move_chain_10 [
  delta-node < #$FFF8, &move_chain_10 >
]

---------------------------------------------
; Entry $11: +1, 0 repeating (average +1/2 per frame). The next three entries are the same idea: $12 (01B17C) -1, 0; $13 (01B184) +1, 0, 0, 0 (+1/4); $14 (01B194) -1, 0, 0, 0 (-1/4). walk_step_table uses all four for the slow forced walks.

move_chain_11 [
  delta-node < #$0001, &delta_node_01B178 >
]

delta_node_01B178 [
  delta-node < #$0000, &move_chain_11 >
]

move_chain_12 [
  delta-node < #$FFFF, &delta_node_01B180 >
]

delta_node_01B180 [
  delta-node < #$0000, &move_chain_12 >
]

move_chain_13 [
  delta-node < #$0001, &delta_node_01B188 >
]

delta_node_01B188 [
  delta-node < #$0000, &delta_node_01B18C >
]

delta_node_01B18C [
  delta-node < #$0000, &delta_node_01B190 >
]

delta_node_01B190 [
  delta-node < #$0000, &move_chain_13 >
]

move_chain_14 [
  delta-node < #$FFFF, &delta_node_01B198 >
]

delta_node_01B198 [
  delta-node < #$0000, &delta_node_01B19C >
]

delta_node_01B19C [
  delta-node < #$0000, &delta_node_01B1A0 >
]

delta_node_01B1A0 [
  delta-node < #$0000, &move_chain_14 >
]

---------------------------------------------
; Entry $15: -4 -4 -2 -2 -1 -1, four 0, +1 +1 +2 +2 +4 +4, then 0 held (17 nodes). A decelerating then accelerating swing: 14 pixels one way and back again, net 0.

move_chain_15 [
  delta-node < #$FFFC, &delta_node_01B1A8 >
]

delta_node_01B1A8 [
  delta-node < #$FFFC, &delta_node_01B1AC >
]

delta_node_01B1AC [
  delta-node < #$FFFE, &delta_node_01B1B0 >
]

delta_node_01B1B0 [
  delta-node < #$FFFE, &delta_node_01B1B4 >
]

delta_node_01B1B4 [
  delta-node < #$FFFF, &delta_node_01B1B8 >
]

delta_node_01B1B8 [
  delta-node < #$FFFF, &delta_node_01B1BC >
]

delta_node_01B1BC [
  delta-node < #$0000, &delta_node_01B1C0 >
]

delta_node_01B1C0 [
  delta-node < #$0000, &delta_node_01B1C4 >
]

delta_node_01B1C4 [
  delta-node < #$0000, &delta_node_01B1C8 >
]

delta_node_01B1C8 [
  delta-node < #$0000, &delta_node_01B1CC >
]

delta_node_01B1CC [
  delta-node < #$0001, &delta_node_01B1D0 >
]

delta_node_01B1D0 [
  delta-node < #$0001, &delta_node_01B1D4 >
]

delta_node_01B1D4 [
  delta-node < #$0002, &delta_node_01B1D8 >
]

delta_node_01B1D8 [
  delta-node < #$0002, &delta_node_01B1DC >
]

delta_node_01B1DC [
  delta-node < #$0004, &delta_node_01B1E0 >
]

delta_node_01B1E0 [
  delta-node < #$0004, &delta_node_01B1E4 >
]

delta_node_01B1E4 [
  delta-node < #$0000, &delta_node_01B1E4 >
]

---------------------------------------------
; Entry $16: four +1 nodes in a cycle (the same motion as $01). Entry $17 (01B1F8) is the same with -1 (the same as $02).

move_chain_16 [
  delta-node < #$0001, &delta_node_01B1EC >
]

delta_node_01B1EC [
  delta-node < #$0001, &delta_node_01B1F0 >
]

delta_node_01B1F0 [
  delta-node < #$0001, &delta_node_01B1F4 >
]

delta_node_01B1F4 [
  delta-node < #$0001, &move_chain_16 >
]

move_chain_17 [
  delta-node < #$FFFF, &delta_node_01B1FC >
]

delta_node_01B1FC [
  delta-node < #$FFFF, &delta_node_01B200 >
]

delta_node_01B200 [
  delta-node < #$FFFF, &delta_node_01B204 >
]

delta_node_01B204 [
  delta-node < #$FFFF, &move_chain_17 >
]

---------------------------------------------
; Entry $18: a 32-node closed loop: ten 0, -2 x3, -1 x4, eight 0, +1 x4, +2 x3 (net 0), the last node links back to the head, so the actor bobs out and back forever.

move_chain_18 [
  delta-node < #$0000, &delta_node_01B20C >
]

delta_node_01B20C [
  delta-node < #$0000, &delta_node_01B210 >
]

delta_node_01B210 [
  delta-node < #$0000, &delta_node_01B214 >
]

delta_node_01B214 [
  delta-node < #$0000, &delta_node_01B218 >
]

delta_node_01B218 [
  delta-node < #$0000, &delta_node_01B21C >
]

delta_node_01B21C [
  delta-node < #$0000, &delta_node_01B220 >
]

delta_node_01B220 [
  delta-node < #$0000, &delta_node_01B224 >
]

delta_node_01B224 [
  delta-node < #$0000, &delta_node_01B228 >
]

delta_node_01B228 [
  delta-node < #$0000, &delta_node_01B22C >
]

delta_node_01B22C [
  delta-node < #$0000, &delta_node_01B230 >
]

delta_node_01B230 [
  delta-node < #$FFFE, &delta_node_01B234 >
]

delta_node_01B234 [
  delta-node < #$FFFE, &delta_node_01B238 >
]

delta_node_01B238 [
  delta-node < #$FFFE, &delta_node_01B23C >
]

delta_node_01B23C [
  delta-node < #$FFFF, &delta_node_01B240 >
]

delta_node_01B240 [
  delta-node < #$FFFF, &delta_node_01B244 >
]

delta_node_01B244 [
  delta-node < #$FFFF, &delta_node_01B248 >
]

delta_node_01B248 [
  delta-node < #$FFFF, &delta_node_01B24C >
]

delta_node_01B24C [
  delta-node < #$0000, &delta_node_01B250 >
]

delta_node_01B250 [
  delta-node < #$0000, &delta_node_01B254 >
]

delta_node_01B254 [
  delta-node < #$0000, &delta_node_01B258 >
]

delta_node_01B258 [
  delta-node < #$0000, &delta_node_01B25C >
]

delta_node_01B25C [
  delta-node < #$0000, &delta_node_01B260 >
]

delta_node_01B260 [
  delta-node < #$0000, &delta_node_01B264 >
]

delta_node_01B264 [
  delta-node < #$0000, &delta_node_01B268 >
]

delta_node_01B268 [
  delta-node < #$0000, &delta_node_01B26C >
]

delta_node_01B26C [
  delta-node < #$0001, &delta_node_01B270 >
]

delta_node_01B270 [
  delta-node < #$0001, &delta_node_01B274 >
]

delta_node_01B274 [
  delta-node < #$0001, &delta_node_01B278 >
]

delta_node_01B278 [
  delta-node < #$0001, &delta_node_01B27C >
]

delta_node_01B27C [
  delta-node < #$0002, &delta_node_01B280 >
]

delta_node_01B280 [
  delta-node < #$0002, &delta_node_01B284 >
]

delta_node_01B284 [
  delta-node < #$0002, &move_chain_18 >
]

move_chain_19 [
  delta-node < #$0000, &delta_node_01B28C >
]

delta_node_01B28C [
  delta-node < #$0000, &delta_node_01B290 >
]

delta_node_01B290 [
  delta-node < #$0000, &delta_node_01B294 >
]

delta_node_01B294 [
  delta-node < #$0000, &delta_node_01B298 >
]

delta_node_01B298 [
  delta-node < #$0001, &delta_node_01B29C >
]

delta_node_01B29C [
  delta-node < #$0000, &delta_node_01B2A0 >
]

delta_node_01B2A0 [
  delta-node < #$0000, &delta_node_01B2A4 >
]

delta_node_01B2A4 [
  delta-node < #$0001, &delta_node_01B2A8 >
]

delta_node_01B2A8 [
  delta-node < #$0000, &delta_node_01B2AC >
]

delta_node_01B2AC [
  delta-node < #$0000, &delta_node_01B2B0 >
]

delta_node_01B2B0 [
  delta-node < #$0002, &delta_node_01B2B4 >
]

delta_node_01B2B4 [
  delta-node < #$0000, &delta_node_01B2B8 >
]

delta_node_01B2B8 [
  delta-node < #$0000, &delta_node_01B2BC >
]

delta_node_01B2BC [
  delta-node < #$0001, &delta_node_01B2C0 >
]

delta_node_01B2C0 [
  delta-node < #$0001, &delta_node_01B2C4 >
]

delta_node_01B2C4 [
  delta-node < #$0001, &delta_node_01B2C8 >
]

delta_node_01B2C8 [
  delta-node < #$0001, &delta_node_01B2B4 >
]

move_chain_1A [
  delta-node < #$0001, &delta_node_01B2D0 >
]

delta_node_01B2D0 [
  delta-node < #$0001, &delta_node_01B2D4 >
]

delta_node_01B2D4 [
  delta-node < #$0001, &delta_node_01B2D8 >
]

delta_node_01B2D8 [
  delta-node < #$0001, &delta_node_01B2DC >
]

delta_node_01B2DC [
  delta-node < #$0000, &delta_node_01B2E0 >
]

delta_node_01B2E0 [
  delta-node < #$0000, &delta_node_01B2E4 >
]

delta_node_01B2E4 [
  delta-node < #$0001, &delta_node_01B2E8 >
]

delta_node_01B2E8 [
  delta-node < #$0001, &delta_node_01B2EC >
]

delta_node_01B2EC [
  delta-node < #$0001, &delta_node_01B2F0 >
]

delta_node_01B2F0 [
  delta-node < #$0001, &delta_node_01B2F4 >
]

delta_node_01B2F4 [
  delta-node < #$0000, &delta_node_01B2F8 >
]

delta_node_01B2F8 [
  delta-node < #$0000, &delta_node_01B2FC >
]

delta_node_01B2FC [
  delta-node < #$0001, &delta_node_01B300 >
]

delta_node_01B300 [
  delta-node < #$0001, &delta_node_01B304 >
]

delta_node_01B304 [
  delta-node < #$0001, &delta_node_01B308 >
]

delta_node_01B308 [
  delta-node < #$0001, &delta_node_01B30C >
]

delta_node_01B30C [
  delta-node < #$0000, &delta_node_01B310 >
]

delta_node_01B310 [
  delta-node < #$0000, &delta_node_01B314 >
]

delta_node_01B314 [
  delta-node < #$0001, &delta_node_01B318 >
]

delta_node_01B318 [
  delta-node < #$0001, &delta_node_01B31C >
]

delta_node_01B31C [
  delta-node < #$0001, &delta_node_01B320 >
]

delta_node_01B320 [
  delta-node < #$0001, &delta_node_01B324 >
]

delta_node_01B324 [
  delta-node < #$0000, &delta_node_01B324 >
]

move_chain_1B [
  delta-node < #$0000, &delta_node_01B32C >
]

delta_node_01B32C [
  delta-node < #$0000, &delta_node_01B330 >
]

delta_node_01B330 [
  delta-node < #$0000, &delta_node_01B334 >
]

delta_node_01B334 [
  delta-node < #$0000, &delta_node_01B338 >
]

delta_node_01B338 [
  delta-node < #$0000, &delta_node_01B33C >
]

delta_node_01B33C [
  delta-node < #$0000, &delta_node_01B340 >
]

delta_node_01B340 [
  delta-node < #$0000, &delta_node_01B344 >
]

delta_node_01B344 [
  delta-node < #$0000, &delta_node_01B348 >
]

delta_node_01B348 [
  delta-node < #$FFFF, &delta_node_01B34C >
]

delta_node_01B34C [
  delta-node < #$FFFF, &delta_node_01B350 >
]

delta_node_01B350 [
  delta-node < #$FFFF, &delta_node_01B354 >
]

delta_node_01B354 [
  delta-node < #$FFFF, &delta_node_01B340 >
]

move_chain_1C [
  delta-node < #$FFFF, &delta_node_01B35C >
]

delta_node_01B35C [
  delta-node < #$FFFF, &delta_node_01B360 >
]

delta_node_01B360 [
  delta-node < #$FFFF, &delta_node_01B364 >
]

delta_node_01B364 [
  delta-node < #$FFFF, &delta_node_01B368 >
]

delta_node_01B368 [
  delta-node < #$0000, &delta_node_01B36C >
]

delta_node_01B36C [
  delta-node < #$0000, &delta_node_01B370 >
]

delta_node_01B370 [
  delta-node < #$FFFF, &delta_node_01B374 >
]

delta_node_01B374 [
  delta-node < #$FFFF, &delta_node_01B378 >
]

delta_node_01B378 [
  delta-node < #$FFFF, &delta_node_01B37C >
]

delta_node_01B37C [
  delta-node < #$FFFF, &delta_node_01B380 >
]

delta_node_01B380 [
  delta-node < #$0000, &delta_node_01B384 >
]

delta_node_01B384 [
  delta-node < #$0000, &delta_node_01B388 >
]

delta_node_01B388 [
  delta-node < #$FFFF, &delta_node_01B38C >
]

delta_node_01B38C [
  delta-node < #$FFFF, &delta_node_01B390 >
]

delta_node_01B390 [
  delta-node < #$FFFF, &delta_node_01B394 >
]

delta_node_01B394 [
  delta-node < #$FFFF, &delta_node_01B398 >
]

delta_node_01B398 [
  delta-node < #$0000, &delta_node_01B39C >
]

delta_node_01B39C [
  delta-node < #$0000, &delta_node_01B3A0 >
]

delta_node_01B3A0 [
  delta-node < #$FFFF, &delta_node_01B3A4 >
]

delta_node_01B3A4 [
  delta-node < #$FFFF, &delta_node_01B3A8 >
]

delta_node_01B3A8 [
  delta-node < #$FFFF, &delta_node_01B3AC >
]

delta_node_01B3AC [
  delta-node < #$FFFF, &delta_node_01B3B0 >
]

delta_node_01B3B0 [
  delta-node < #$0000, &delta_node_01B3B0 >
]

move_chain_1D [
  delta-node < #$0002, &delta_node_01B3B8 >
]

delta_node_01B3B8 [
  delta-node < #$0002, &delta_node_01B3BC >
]

delta_node_01B3BC [
  delta-node < #$0002, &delta_node_01B3C0 >
]

delta_node_01B3C0 [
  delta-node < #$0002, &delta_node_01B3C4 >
]

delta_node_01B3C4 [
  delta-node < #$0000, &delta_node_01B3C8 >
]

delta_node_01B3C8 [
  delta-node < #$0000, &move_chain_1D >
]

move_chain_1E [
  delta-node < #$FFFE, &delta_node_01B3D0 >
]

delta_node_01B3D0 [
  delta-node < #$FFFE, &delta_node_01B3D4 >
]

delta_node_01B3D4 [
  delta-node < #$FFFE, &delta_node_01B3D8 >
]

delta_node_01B3D8 [
  delta-node < #$FFFE, &delta_node_01B3DC >
]

delta_node_01B3DC [
  delta-node < #$0000, &delta_node_01B3E0 >
]

delta_node_01B3E0 [
  delta-node < #$0000, &move_chain_1E >
]

move_chain_1F [
  delta-node < #$0000, &move_chain_1F >
]

move_chain_20 [
  delta-node < #$0000, &move_chain_20 >
]

move_chain_21 [
  delta-node < #$FFFE, &delta_node_01B3F0 >
]

delta_node_01B3F0 [
  delta-node < #$FFFE, &delta_node_01B3F4 >
]

delta_node_01B3F4 [
  delta-node < #$FFFF, &delta_node_01B3F8 >
]

delta_node_01B3F8 [
  delta-node < #$FFFF, &delta_node_01B3FC >
]

delta_node_01B3FC [
  delta-node < #$0000, &delta_node_01B400 >
]

delta_node_01B400 [
  delta-node < #$0000, &delta_node_01B404 >
]

delta_node_01B404 [
  delta-node < #$0000, &delta_node_01B408 >
]

delta_node_01B408 [
  delta-node < #$0000, &delta_node_01B40C >
]

delta_node_01B40C [
  delta-node < #$0001, &delta_node_01B410 >
]

delta_node_01B410 [
  delta-node < #$0001, &delta_node_01B414 >
]

delta_node_01B414 [
  delta-node < #$0001, &delta_node_01B418 >
]

delta_node_01B418 [
  delta-node < #$0001, &delta_node_01B41C >
]

delta_node_01B41C [
  delta-node < #$0001, &delta_node_01B420 >
]

delta_node_01B420 [
  delta-node < #$0001, &delta_node_01B424 >
]

delta_node_01B424 [
  delta-node < #$0001, &delta_node_01B428 >
]

delta_node_01B428 [
  delta-node < #$0001, &delta_node_01B42C >
]

delta_node_01B42C [
  delta-node < #$0002, &delta_node_01B430 >
]

delta_node_01B430 [
  delta-node < #$0002, &delta_node_01B434 >
]

delta_node_01B434 [
  delta-node < #$0002, &delta_node_01B438 >
]

delta_node_01B438 [
  delta-node < #$0002, &delta_node_01B43C >
]

delta_node_01B43C [
  delta-node < #$0003, &delta_node_01B440 >
]

delta_node_01B440 [
  delta-node < #$0003, &delta_node_01B444 >
]

delta_node_01B444 [
  delta-node < #$0003, &delta_node_01B448 >
]

delta_node_01B448 [
  delta-node < #$0003, &delta_node_01B44C >
]

delta_node_01B44C [
  delta-node < #$0004, &delta_node_01B450 >
]

delta_node_01B450 [
  delta-node < #$0004, &delta_node_01B454 >
]

delta_node_01B454 [
  delta-node < #$0004, &delta_node_01B458 >
]

delta_node_01B458 [
  delta-node < #$0004, &delta_node_01B45C >
]

delta_node_01B45C [
  delta-node < #$FFFE, &delta_node_01B460 >
]

delta_node_01B460 [
  delta-node < #$FFFE, &delta_node_01B464 >
]

delta_node_01B464 [
  delta-node < #$FFFF, &delta_node_01B468 >
]

delta_node_01B468 [
  delta-node < #$FFFF, &delta_node_01B46C >
]

delta_node_01B46C [
  delta-node < #$0000, &delta_node_01B470 >
]

delta_node_01B470 [
  delta-node < #$0000, &delta_node_01B474 >
]

delta_node_01B474 [
  delta-node < #$0000, &delta_node_01B478 >
]

delta_node_01B478 [
  delta-node < #$0000, &delta_node_01B47C >
]

delta_node_01B47C [
  delta-node < #$0001, &delta_node_01B480 >
]

delta_node_01B480 [
  delta-node < #$0001, &delta_node_01B484 >
]

delta_node_01B484 [
  delta-node < #$0001, &delta_node_01B488 >
]

delta_node_01B488 [
  delta-node < #$0001, &delta_node_01B48C >
]

delta_node_01B48C [
  delta-node < #$0002, &delta_node_01B490 >
]

delta_node_01B490 [
  delta-node < #$0002, &delta_node_01B494 >
]

delta_node_01B494 [
  delta-node < #$0002, &delta_node_01B498 >
]

delta_node_01B498 [
  delta-node < #$0002, &delta_node_01B49C >
]

delta_node_01B49C [
  delta-node < #$0004, &delta_node_01B4A0 >
]

delta_node_01B4A0 [
  delta-node < #$0004, &delta_node_01B4A4 >
]

delta_node_01B4A4 [
  delta-node < #$0004, &delta_node_01B4A8 >
]

delta_node_01B4A8 [
  delta-node < #$0004, &delta_node_01B4AC >
]

delta_node_01B4AC [
  delta-node < #$FFFF, &delta_node_01B4B0 >
]

delta_node_01B4B0 [
  delta-node < #$FFFF, &delta_node_01B4B4 >
]

delta_node_01B4B4 [
  delta-node < #$0000, &delta_node_01B4B8 >
]

delta_node_01B4B8 [
  delta-node < #$0000, &delta_node_01B4BC >
]

delta_node_01B4BC [
  delta-node < #$0001, &delta_node_01B4C0 >
]

delta_node_01B4C0 [
  delta-node < #$0001, &delta_node_01B4C4 >
]

delta_node_01B4C4 [
  delta-node < #$0002, &delta_node_01B4C8 >
]

delta_node_01B4C8 [
  delta-node < #$0002, &delta_node_01B4CC >
]

delta_node_01B4CC [
  delta-node < #$0000, &delta_node_01B4CC >
]

---------------------------------------------
; Entry $22: 4 4 5 5 5 5 4 4 3 3 2 2 1 1 0 (15 nodes, 48 pixels, then 0 held). The tier 0 hit stagger knockback (hit_stagger_controller). Verified against the nodes.

move_chain_22 [
  delta-node < #$0004, &delta_node_01B4D4 >
]

delta_node_01B4D4 [
  delta-node < #$0004, &delta_node_01B4D8 >
]

delta_node_01B4D8 [
  delta-node < #$0005, &delta_node_01B4DC >
]

delta_node_01B4DC [
  delta-node < #$0005, &delta_node_01B4E0 >
]

delta_node_01B4E0 [
  delta-node < #$0005, &delta_node_01B4E4 >
]

delta_node_01B4E4 [
  delta-node < #$0005, &delta_node_01B4E8 >
]

delta_node_01B4E8 [
  delta-node < #$0004, &delta_node_01B4EC >
]

delta_node_01B4EC [
  delta-node < #$0004, &delta_node_01B4F0 >
]

delta_node_01B4F0 [
  delta-node < #$0003, &delta_node_01B4F4 >
]

delta_node_01B4F4 [
  delta-node < #$0003, &delta_node_01B4F8 >
]

delta_node_01B4F8 [
  delta-node < #$0002, &delta_node_01B4FC >
]

delta_node_01B4FC [
  delta-node < #$0002, &delta_node_01B500 >
]

delta_node_01B500 [
  delta-node < #$0001, &delta_node_01B504 >
]

delta_node_01B504 [
  delta-node < #$0001, &delta_node_01B508 >
]

delta_node_01B508 [
  delta-node < #$0000, &delta_node_01B508 >
]

---------------------------------------------
; Entry $23: 3 3 4 4 3 3 2 2 2 2 1 1 1 1 0 (15 nodes, 32 pixels, then 0 held). The hit stagger knockback for tier 1 and above, which includes the player.

move_chain_23 [
  delta-node < #$0003, &delta_node_01B510 >
]

delta_node_01B510 [
  delta-node < #$0003, &delta_node_01B514 >
]

delta_node_01B514 [
  delta-node < #$0004, &delta_node_01B518 >
]

delta_node_01B518 [
  delta-node < #$0004, &delta_node_01B51C >
]

delta_node_01B51C [
  delta-node < #$0003, &delta_node_01B520 >
]

delta_node_01B520 [
  delta-node < #$0003, &delta_node_01B524 >
]

delta_node_01B524 [
  delta-node < #$0002, &delta_node_01B528 >
]

delta_node_01B528 [
  delta-node < #$0002, &delta_node_01B52C >
]

delta_node_01B52C [
  delta-node < #$0002, &delta_node_01B530 >
]

delta_node_01B530 [
  delta-node < #$0002, &delta_node_01B534 >
]

delta_node_01B534 [
  delta-node < #$0001, &delta_node_01B538 >
]

delta_node_01B538 [
  delta-node < #$0001, &delta_node_01B53C >
]

delta_node_01B53C [
  delta-node < #$0001, &delta_node_01B540 >
]

delta_node_01B540 [
  delta-node < #$0001, &delta_node_01B544 >
]

delta_node_01B544 [
  delta-node < #$0000, &delta_node_01B544 >
]

move_chain_24 [
  delta-node < #$0000, &delta_node_01B54C >
]

delta_node_01B54C [
  delta-node < #$0000, &delta_node_01B550 >
]

delta_node_01B550 [
  delta-node < #$0000, &delta_node_01B554 >
]

delta_node_01B554 [
  delta-node < #$0001, &delta_node_01B558 >
]

delta_node_01B558 [
  delta-node < #$0001, &delta_node_01B55C >
]

delta_node_01B55C [
  delta-node < #$0001, &delta_node_01B560 >
]

delta_node_01B560 [
  delta-node < #$0001, &delta_node_01B564 >
]

delta_node_01B564 [
  delta-node < #$0001, &move_chain_24 >
]

move_chain_25 [
  delta-node < #$0000, &delta_node_01B56C >
]

delta_node_01B56C [
  delta-node < #$0000, &delta_node_01B570 >
]

delta_node_01B570 [
  delta-node < #$0000, &delta_node_01B574 >
]

delta_node_01B574 [
  delta-node < #$FFFF, &delta_node_01B578 >
]

delta_node_01B578 [
  delta-node < #$FFFF, &delta_node_01B57C >
]

delta_node_01B57C [
  delta-node < #$FFFF, &delta_node_01B580 >
]

delta_node_01B580 [
  delta-node < #$FFFF, &delta_node_01B584 >
]

delta_node_01B584 [
  delta-node < #$FFFF, &move_chain_25 >
]

move_chain_26 [
  delta-node < #$FFFF, &delta_node_01B58C >
]

delta_node_01B58C [
  delta-node < #$FFFF, &delta_node_01B590 >
]

delta_node_01B590 [
  delta-node < #$FFFF, &delta_node_01B594 >
]

delta_node_01B594 [
  delta-node < #$FFFF, &delta_node_01B598 >
]

delta_node_01B598 [
  delta-node < #$FFFF, &delta_node_01B59C >
]

delta_node_01B59C [
  delta-node < #$FFFE, &delta_node_01B5A0 >
]

delta_node_01B5A0 [
  delta-node < #$FFFE, &delta_node_01B5A4 >
]

delta_node_01B5A4 [
  delta-node < #$FFFE, &delta_node_01B5A8 >
]

delta_node_01B5A8 [
  delta-node < #$0001, &delta_node_01B5AC >
]

delta_node_01B5AC [
  delta-node < #$0001, &delta_node_01B5B0 >
]

delta_node_01B5B0 [
  delta-node < #$0001, &delta_node_01B5B4 >
]

delta_node_01B5B4 [
  delta-node < #$0001, &delta_node_01B5B8 >
]

delta_node_01B5B8 [
  delta-node < #$0001, &delta_node_01B5BC >
]

delta_node_01B5BC [
  delta-node < #$0002, &delta_node_01B5C0 >
]

delta_node_01B5C0 [
  delta-node < #$0002, &delta_node_01B5C4 >
]

delta_node_01B5C4 [
  delta-node < #$0002, &delta_node_01B5C8 >
]

delta_node_01B5C8 [
  delta-node < #$0001, &delta_node_01B5CC >
]

delta_node_01B5CC [
  delta-node < #$0001, &delta_node_01B5D0 >
]

delta_node_01B5D0 [
  delta-node < #$0001, &delta_node_01B5D4 >
]

delta_node_01B5D4 [
  delta-node < #$0001, &delta_node_01B5D8 >
]

delta_node_01B5D8 [
  delta-node < #$0001, &delta_node_01B5DC >
]

delta_node_01B5DC [
  delta-node < #$0002, &delta_node_01B5E0 >
]

delta_node_01B5E0 [
  delta-node < #$0002, &delta_node_01B5E4 >
]

delta_node_01B5E4 [
  delta-node < #$0002, &delta_node_01B5E8 >
]

delta_node_01B5E8 [
  delta-node < #$FFFF, &delta_node_01B5EC >
]

delta_node_01B5EC [
  delta-node < #$FFFF, &delta_node_01B5F0 >
]

delta_node_01B5F0 [
  delta-node < #$FFFF, &delta_node_01B5F4 >
]

delta_node_01B5F4 [
  delta-node < #$FFFF, &delta_node_01B5F8 >
]

delta_node_01B5F8 [
  delta-node < #$FFFF, &delta_node_01B5FC >
]

delta_node_01B5FC [
  delta-node < #$FFFE, &delta_node_01B600 >
]

delta_node_01B600 [
  delta-node < #$FFFE, &delta_node_01B604 >
]

delta_node_01B604 [
  delta-node < #$FFFE, &move_chain_26 >
]

move_chain_27 [
  delta-node < #$FFFF, &delta_node_01B60C >
]

delta_node_01B60C [
  delta-node < #$FFFF, &delta_node_01B610 >
]

delta_node_01B610 [
  delta-node < #$FFFF, &delta_node_01B614 >
]

delta_node_01B614 [
  delta-node < #$FFFF, &delta_node_01B618 >
]

delta_node_01B618 [
  delta-node < #$FFFF, &delta_node_01B61C >
]

delta_node_01B61C [
  delta-node < #$FFFF, &delta_node_01B620 >
]

delta_node_01B620 [
  delta-node < #$FFFF, &delta_node_01B624 >
]

delta_node_01B624 [
  delta-node < #$FFFF, &delta_node_01B628 >
]

delta_node_01B628 [
  delta-node < #$FFFF, &delta_node_01B62C >
]

delta_node_01B62C [
  delta-node < #$FFFF, &delta_node_01B630 >
]

delta_node_01B630 [
  delta-node < #$FFFF, &delta_node_01B634 >
]

delta_node_01B634 [
  delta-node < #$0000, &delta_node_01B638 >
]

delta_node_01B638 [
  delta-node < #$0000, &delta_node_01B63C >
]

delta_node_01B63C [
  delta-node < #$0000, &delta_node_01B640 >
]

delta_node_01B640 [
  delta-node < #$0000, &delta_node_01B644 >
]

delta_node_01B644 [
  delta-node < #$0000, &delta_node_01B648 >
]

delta_node_01B648 [
  delta-node < #$0000, &delta_node_01B64C >
]

delta_node_01B64C [
  delta-node < #$0000, &delta_node_01B650 >
]

delta_node_01B650 [
  delta-node < #$0000, &delta_node_01B654 >
]

delta_node_01B654 [
  delta-node < #$FFFF, &delta_node_01B658 >
]

delta_node_01B658 [
  delta-node < #$FFFF, &delta_node_01B65C >
]

delta_node_01B65C [
  delta-node < #$FFFF, &delta_node_01B660 >
]

delta_node_01B660 [
  delta-node < #$FFFF, &delta_node_01B664 >
]

delta_node_01B664 [
  delta-node < #$FFFF, &delta_node_01B664 >
]

move_chain_28 [
  delta-node < #$0001, &delta_node_01B66C >
]

delta_node_01B66C [
  delta-node < #$0001, &delta_node_01B670 >
]

delta_node_01B670 [
  delta-node < #$0001, &delta_node_01B674 >
]

delta_node_01B674 [
  delta-node < #$0001, &delta_node_01B678 >
]

delta_node_01B678 [
  delta-node < #$0001, &delta_node_01B67C >
]

delta_node_01B67C [
  delta-node < #$0001, &delta_node_01B680 >
]

delta_node_01B680 [
  delta-node < #$0001, &delta_node_01B684 >
]

delta_node_01B684 [
  delta-node < #$0001, &delta_node_01B688 >
]

delta_node_01B688 [
  delta-node < #$0001, &delta_node_01B68C >
]

delta_node_01B68C [
  delta-node < #$0001, &delta_node_01B690 >
]

delta_node_01B690 [
  delta-node < #$0001, &delta_node_01B694 >
]

delta_node_01B694 [
  delta-node < #$0000, &delta_node_01B698 >
]

delta_node_01B698 [
  delta-node < #$0000, &delta_node_01B69C >
]

delta_node_01B69C [
  delta-node < #$0000, &delta_node_01B6A0 >
]

delta_node_01B6A0 [
  delta-node < #$0000, &delta_node_01B6A4 >
]

delta_node_01B6A4 [
  delta-node < #$0000, &delta_node_01B6A8 >
]

delta_node_01B6A8 [
  delta-node < #$0000, &delta_node_01B6AC >
]

delta_node_01B6AC [
  delta-node < #$0000, &delta_node_01B6B0 >
]

delta_node_01B6B0 [
  delta-node < #$0000, &delta_node_01B6B4 >
]

delta_node_01B6B4 [
  delta-node < #$0001, &delta_node_01B6B8 >
]

delta_node_01B6B8 [
  delta-node < #$0001, &delta_node_01B6BC >
]

delta_node_01B6BC [
  delta-node < #$0001, &delta_node_01B6C0 >
]

delta_node_01B6C0 [
  delta-node < #$0001, &delta_node_01B6C4 >
]

delta_node_01B6C4 [
  delta-node < #$0001, &delta_node_01B6C4 >
]

move_chain_29 [
  delta-node < #$FFFF, &delta_node_01B6CC >
]

delta_node_01B6CC [
  delta-node < #$FFFF, &delta_node_01B6D0 >
]

delta_node_01B6D0 [
  delta-node < #$FFFF, &delta_node_01B6D4 >
]

delta_node_01B6D4 [
  delta-node < #$FFFE, &delta_node_01B6D8 >
]

delta_node_01B6D8 [
  delta-node < #$FFFE, &delta_node_01B6DC >
]

delta_node_01B6DC [
  delta-node < #$FFFE, &delta_node_01B6E0 >
]

delta_node_01B6E0 [
  delta-node < #$FFFD, &delta_node_01B6E4 >
]

delta_node_01B6E4 [
  delta-node < #$FFFD, &delta_node_01B6E8 >
]

delta_node_01B6E8 [
  delta-node < #$FFFD, &delta_node_01B6EC >
]

delta_node_01B6EC [
  delta-node < #$FFFC, &delta_node_01B6EC >
]

move_chain_2A [
  delta-node < #$FFFD, &delta_node_01B6F4 >
]

delta_node_01B6F4 [
  delta-node < #$FFFD, &delta_node_01B6F8 >
]

delta_node_01B6F8 [
  delta-node < #$FFFD, &delta_node_01B6FC >
]

delta_node_01B6FC [
  delta-node < #$FFFE, &delta_node_01B700 >
]

delta_node_01B700 [
  delta-node < #$FFFE, &delta_node_01B704 >
]

delta_node_01B704 [
  delta-node < #$FFFE, &delta_node_01B708 >
]

delta_node_01B708 [
  delta-node < #$FFFF, &delta_node_01B70C >
]

delta_node_01B70C [
  delta-node < #$FFFF, &delta_node_01B710 >
]

delta_node_01B710 [
  delta-node < #$FFFF, &delta_node_01B714 >
]

delta_node_01B714 [
  delta-node < #$0000, &delta_node_01B714 >
]

move_chain_2B [
  delta-node < #$0001, &delta_node_01B71C >
]

delta_node_01B71C [
  delta-node < #$0001, &delta_node_01B720 >
]

delta_node_01B720 [
  delta-node < #$0001, &delta_node_01B724 >
]

delta_node_01B724 [
  delta-node < #$0002, &delta_node_01B728 >
]

delta_node_01B728 [
  delta-node < #$0002, &delta_node_01B72C >
]

delta_node_01B72C [
  delta-node < #$0002, &delta_node_01B730 >
]

delta_node_01B730 [
  delta-node < #$0003, &delta_node_01B734 >
]

delta_node_01B734 [
  delta-node < #$0003, &delta_node_01B738 >
]

delta_node_01B738 [
  delta-node < #$0003, &delta_node_01B73C >
]

delta_node_01B73C [
  delta-node < #$0004, &delta_node_01B73C >
]

move_chain_2C [
  delta-node < #$0003, &delta_node_01B744 >
]

delta_node_01B744 [
  delta-node < #$0003, &delta_node_01B748 >
]

delta_node_01B748 [
  delta-node < #$0003, &delta_node_01B74C >
]

delta_node_01B74C [
  delta-node < #$0002, &delta_node_01B750 >
]

delta_node_01B750 [
  delta-node < #$0002, &delta_node_01B754 >
]

delta_node_01B754 [
  delta-node < #$0002, &delta_node_01B758 >
]

delta_node_01B758 [
  delta-node < #$0001, &delta_node_01B75C >
]

delta_node_01B75C [
  delta-node < #$0001, &delta_node_01B760 >
]

delta_node_01B760 [
  delta-node < #$0001, &delta_node_01B764 >
]

delta_node_01B764 [
  delta-node < #$0000, &delta_node_01B764 >
]

move_chain_2D [
  delta-node < #$0001, &delta_node_01B76C >
]

delta_node_01B76C [
  delta-node < #$0001, &delta_node_01B770 >
]

delta_node_01B770 [
  delta-node < #$0001, &delta_node_01B774 >
]

delta_node_01B774 [
  delta-node < #$0002, &delta_node_01B778 >
]

delta_node_01B778 [
  delta-node < #$0002, &delta_node_01B77C >
]

delta_node_01B77C [
  delta-node < #$0002, &delta_node_01B780 >
]

delta_node_01B780 [
  delta-node < #$0003, &delta_node_01B784 >
]

delta_node_01B784 [
  delta-node < #$0003, &delta_node_01B788 >
]

delta_node_01B788 [
  delta-node < #$0003, &delta_node_01B78C >
]

delta_node_01B78C [
  delta-node < #$0005, &delta_node_01B790 >
]

delta_node_01B790 [
  delta-node < #$0005, &delta_node_01B794 >
]

delta_node_01B794 [
  delta-node < #$0005, &delta_node_01B798 >
]

delta_node_01B798 [
  delta-node < #$0003, &delta_node_01B79C >
]

delta_node_01B79C [
  delta-node < #$0003, &delta_node_01B7A0 >
]

delta_node_01B7A0 [
  delta-node < #$0003, &delta_node_01B7A4 >
]

delta_node_01B7A4 [
  delta-node < #$0002, &delta_node_01B7A8 >
]

delta_node_01B7A8 [
  delta-node < #$0002, &delta_node_01B7AC >
]

delta_node_01B7AC [
  delta-node < #$0002, &delta_node_01B7B0 >
]

delta_node_01B7B0 [
  delta-node < #$0001, &delta_node_01B7B4 >
]

delta_node_01B7B4 [
  delta-node < #$0001, &delta_node_01B7B8 >
]

delta_node_01B7B8 [
  delta-node < #$0001, &move_chain_2D >
]

move_chain_2E [
  delta-node < #$FFFF, &delta_node_01B7C0 >
]

delta_node_01B7C0 [
  delta-node < #$FFFF, &delta_node_01B7C4 >
]

delta_node_01B7C4 [
  delta-node < #$FFFF, &delta_node_01B7C8 >
]

delta_node_01B7C8 [
  delta-node < #$FFFE, &delta_node_01B7CC >
]

delta_node_01B7CC [
  delta-node < #$FFFE, &delta_node_01B7D0 >
]

delta_node_01B7D0 [
  delta-node < #$FFFE, &delta_node_01B7D4 >
]

delta_node_01B7D4 [
  delta-node < #$FFFD, &delta_node_01B7D8 >
]

delta_node_01B7D8 [
  delta-node < #$FFFD, &delta_node_01B7DC >
]

delta_node_01B7DC [
  delta-node < #$FFFD, &delta_node_01B7E0 >
]

delta_node_01B7E0 [
  delta-node < #$FFFB, &delta_node_01B7E4 >
]

delta_node_01B7E4 [
  delta-node < #$FFFB, &delta_node_01B7E8 >
]

delta_node_01B7E8 [
  delta-node < #$FFFB, &delta_node_01B7EC >
]

delta_node_01B7EC [
  delta-node < #$FFFD, &delta_node_01B7F0 >
]

delta_node_01B7F0 [
  delta-node < #$FFFD, &delta_node_01B7F4 >
]

delta_node_01B7F4 [
  delta-node < #$FFFD, &delta_node_01B7F8 >
]

delta_node_01B7F8 [
  delta-node < #$FFFE, &delta_node_01B7FC >
]

delta_node_01B7FC [
  delta-node < #$FFFE, &delta_node_01B800 >
]

delta_node_01B800 [
  delta-node < #$FFFE, &delta_node_01B804 >
]

delta_node_01B804 [
  delta-node < #$FFFF, &delta_node_01B808 >
]

delta_node_01B808 [
  delta-node < #$FFFF, &delta_node_01B80C >
]

delta_node_01B80C [
  delta-node < #$FFFF, &move_chain_2E >
]

move_chain_2F [
  delta-node < #$FFFD, &delta_node_01B814 >
]

delta_node_01B814 [
  delta-node < #$FFFD, &delta_node_01B818 >
]

delta_node_01B818 [
  delta-node < #$FFFD, &delta_node_01B81C >
]

delta_node_01B81C [
  delta-node < #$FFFE, &delta_node_01B820 >
]

delta_node_01B820 [
  delta-node < #$FFFE, &delta_node_01B824 >
]

delta_node_01B824 [
  delta-node < #$FFFE, &delta_node_01B828 >
]

delta_node_01B828 [
  delta-node < #$FFFF, &delta_node_01B82C >
]

delta_node_01B82C [
  delta-node < #$FFFF, &delta_node_01B830 >
]

delta_node_01B830 [
  delta-node < #$FFFF, &delta_node_01B834 >
]

delta_node_01B834 [
  delta-node < #$0000, &delta_node_01B838 >
]

delta_node_01B838 [
  delta-node < #$0000, &delta_node_01B83C >
]

delta_node_01B83C [
  delta-node < #$0000, &delta_node_01B840 >
]

delta_node_01B840 [
  delta-node < #$0001, &delta_node_01B844 >
]

delta_node_01B844 [
  delta-node < #$0001, &delta_node_01B848 >
]

delta_node_01B848 [
  delta-node < #$0001, &delta_node_01B84C >
]

delta_node_01B84C [
  delta-node < #$0002, &delta_node_01B850 >
]

delta_node_01B850 [
  delta-node < #$0002, &delta_node_01B854 >
]

delta_node_01B854 [
  delta-node < #$0002, &delta_node_01B858 >
]

delta_node_01B858 [
  delta-node < #$0003, &delta_node_01B85C >
]

delta_node_01B85C [
  delta-node < #$0003, &delta_node_01B860 >
]

delta_node_01B860 [
  delta-node < #$0003, &move_chain_2F >
]

move_chain_30 [
  delta-node < #$0003, &delta_node_01B868 >
]

delta_node_01B868 [
  delta-node < #$0003, &delta_node_01B86C >
]

delta_node_01B86C [
  delta-node < #$0003, &delta_node_01B870 >
]

delta_node_01B870 [
  delta-node < #$0002, &delta_node_01B874 >
]

delta_node_01B874 [
  delta-node < #$0002, &delta_node_01B878 >
]

delta_node_01B878 [
  delta-node < #$0002, &delta_node_01B87C >
]

delta_node_01B87C [
  delta-node < #$0001, &delta_node_01B880 >
]

delta_node_01B880 [
  delta-node < #$0001, &delta_node_01B884 >
]

delta_node_01B884 [
  delta-node < #$0001, &delta_node_01B888 >
]

delta_node_01B888 [
  delta-node < #$0000, &delta_node_01B88C >
]

delta_node_01B88C [
  delta-node < #$0000, &delta_node_01B890 >
]

delta_node_01B890 [
  delta-node < #$0000, &delta_node_01B894 >
]

delta_node_01B894 [
  delta-node < #$FFFF, &delta_node_01B898 >
]

delta_node_01B898 [
  delta-node < #$FFFF, &delta_node_01B89C >
]

delta_node_01B89C [
  delta-node < #$FFFF, &delta_node_01B8A0 >
]

delta_node_01B8A0 [
  delta-node < #$FFFE, &delta_node_01B8A4 >
]

delta_node_01B8A4 [
  delta-node < #$FFFE, &delta_node_01B8A8 >
]

delta_node_01B8A8 [
  delta-node < #$FFFE, &delta_node_01B8AC >
]

delta_node_01B8AC [
  delta-node < #$FFFD, &delta_node_01B8B0 >
]

delta_node_01B8B0 [
  delta-node < #$FFFD, &delta_node_01B8B4 >
]

delta_node_01B8B4 [
  delta-node < #$FFFD, &move_chain_30 >
]

move_chain_31 [
  delta-node < #$FFFA, &delta_node_01B8BC >
]

delta_node_01B8BC [
  delta-node < #$FFFA, &delta_node_01B8C0 >
]

delta_node_01B8C0 [
  delta-node < #$FFFC, &delta_node_01B8C4 >
]

delta_node_01B8C4 [
  delta-node < #$FFFC, &delta_node_01B8C8 >
]

delta_node_01B8C8 [
  delta-node < #$FFFE, &delta_node_01B8CC >
]

delta_node_01B8CC [
  delta-node < #$FFFE, &delta_node_01B8D0 >
]

delta_node_01B8D0 [
  delta-node < #$0000, &delta_node_01B8D4 >
]

delta_node_01B8D4 [
  delta-node < #$0000, &delta_node_01B8D8 >
]

delta_node_01B8D8 [
  delta-node < #$0000, &delta_node_01B8DC >
]

delta_node_01B8DC [
  delta-node < #$0000, &delta_node_01B8E0 >
]

delta_node_01B8E0 [
  delta-node < #$0002, &delta_node_01B8E4 >
]

delta_node_01B8E4 [
  delta-node < #$0002, &delta_node_01B8E8 >
]

delta_node_01B8E8 [
  delta-node < #$0004, &delta_node_01B8EC >
]

delta_node_01B8EC [
  delta-node < #$0004, &delta_node_01B8F0 >
]

delta_node_01B8F0 [
  delta-node < #$0006, &delta_node_01B8F4 >
]

delta_node_01B8F4 [
  delta-node < #$0006, &move_chain_31 >
]

move_chain_32 [
  delta-node < #$0007, &delta_node_01B8FC >
]

delta_node_01B8FC [
  delta-node < #$0007, &delta_node_01B900 >
]

delta_node_01B900 [
  delta-node < #$0006, &delta_node_01B904 >
]

delta_node_01B904 [
  delta-node < #$0006, &delta_node_01B908 >
]

delta_node_01B908 [
  delta-node < #$0005, &delta_node_01B90C >
]

delta_node_01B90C [
  delta-node < #$0005, &delta_node_01B910 >
]

delta_node_01B910 [
  delta-node < #$0005, &delta_node_01B914 >
]

delta_node_01B914 [
  delta-node < #$0005, &delta_node_01B918 >
]

delta_node_01B918 [
  delta-node < #$0004, &delta_node_01B91C >
]

delta_node_01B91C [
  delta-node < #$0004, &delta_node_01B920 >
]

delta_node_01B920 [
  delta-node < #$0003, &delta_node_01B924 >
]

delta_node_01B924 [
  delta-node < #$0003, &delta_node_01B928 >
]

delta_node_01B928 [
  delta-node < #$0002, &delta_node_01B92C >
]

delta_node_01B92C [
  delta-node < #$0002, &delta_node_01B930 >
]

delta_node_01B930 [
  delta-node < #$0000, &delta_node_01B934 >
]

delta_node_01B934 [
  delta-node < #$0000, &move_chain_32 >
]

move_chain_33 [
  delta-node < #$0000, &delta_node_01B93C >
]

delta_node_01B93C [
  delta-node < #$0000, &delta_node_01B940 >
]

delta_node_01B940 [
  delta-node < #$FFFE, &delta_node_01B944 >
]

delta_node_01B944 [
  delta-node < #$FFFE, &delta_node_01B948 >
]

delta_node_01B948 [
  delta-node < #$FFFD, &delta_node_01B94C >
]

delta_node_01B94C [
  delta-node < #$FFFD, &delta_node_01B950 >
]

delta_node_01B950 [
  delta-node < #$FFFC, &delta_node_01B954 >
]

delta_node_01B954 [
  delta-node < #$FFFC, &delta_node_01B958 >
]

delta_node_01B958 [
  delta-node < #$FFFB, &delta_node_01B95C >
]

delta_node_01B95C [
  delta-node < #$FFFB, &delta_node_01B960 >
]

delta_node_01B960 [
  delta-node < #$FFFB, &delta_node_01B964 >
]

delta_node_01B964 [
  delta-node < #$FFFB, &delta_node_01B968 >
]

delta_node_01B968 [
  delta-node < #$FFFA, &delta_node_01B96C >
]

delta_node_01B96C [
  delta-node < #$FFFA, &delta_node_01B970 >
]

delta_node_01B970 [
  delta-node < #$FFF9, &delta_node_01B974 >
]

delta_node_01B974 [
  delta-node < #$FFF9, &move_chain_33 >
]

move_chain_34 [
  delta-node < #$FFFA, &delta_node_01B97C >
]

delta_node_01B97C [
  delta-node < #$FFFA, &delta_node_01B980 >
]

delta_node_01B980 [
  delta-node < #$FFFC, &delta_node_01B984 >
]

delta_node_01B984 [
  delta-node < #$FFFC, &delta_node_01B988 >
]

delta_node_01B988 [
  delta-node < #$FFFE, &delta_node_01B98C >
]

delta_node_01B98C [
  delta-node < #$FFFE, &delta_node_01B990 >
]

delta_node_01B990 [
  delta-node < #$0000, &delta_node_01B994 >
]

delta_node_01B994 [
  delta-node < #$0000, &delta_node_01B998 >
]

delta_node_01B998 [
  delta-node < #$0000, &delta_node_01B99C >
]

delta_node_01B99C [
  delta-node < #$0000, &delta_node_01B9A0 >
]

delta_node_01B9A0 [
  delta-node < #$0002, &delta_node_01B9A4 >
]

delta_node_01B9A4 [
  delta-node < #$0002, &delta_node_01B9A8 >
]

delta_node_01B9A8 [
  delta-node < #$0004, &delta_node_01B9AC >
]

delta_node_01B9AC [
  delta-node < #$0004, &delta_node_01B9B0 >
]

delta_node_01B9B0 [
  delta-node < #$0006, &delta_node_01B9B4 >
]

delta_node_01B9B4 [
  delta-node < #$0006, &move_chain_34 >
]

move_chain_35 [
  delta-node < #$FFFC, &delta_node_01B9BC >
]

delta_node_01B9BC [
  delta-node < #$FFFD, &delta_node_01B9C0 >
]

delta_node_01B9C0 [
  delta-node < #$FFFE, &delta_node_01B9C4 >
]

delta_node_01B9C4 [
  delta-node < #$FFFF, &delta_node_01B9C8 >
]

delta_node_01B9C8 [
  delta-node < #$0000, &delta_node_01B9CC >
]

delta_node_01B9CC [
  delta-node < #$0000, &delta_node_01B9D0 >
]

delta_node_01B9D0 [
  delta-node < #$0001, &delta_node_01B9D4 >
]

delta_node_01B9D4 [
  delta-node < #$0002, &delta_node_01B9D8 >
]

delta_node_01B9D8 [
  delta-node < #$0003, &delta_node_01B9DC >
]

delta_node_01B9DC [
  delta-node < #$0004, &delta_node_01B9E0 >
]

delta_node_01B9E0 [
  delta-node < #$FFFE, &delta_node_01B9E4 >
]

delta_node_01B9E4 [
  delta-node < #$FFFF, &delta_node_01B9E8 >
]

delta_node_01B9E8 [
  delta-node < #$0000, &delta_node_01B9EC >
]

delta_node_01B9EC [
  delta-node < #$0001, &delta_node_01B9F0 >
]

delta_node_01B9F0 [
  delta-node < #$0002, &delta_node_01B9F4 >
]

delta_node_01B9F4 [
  delta-node < #$0000, &delta_node_01B9F4 >
]

---------------------------------------------
; Entry $36: eight 0, then 4 4 7 7 9 9 12 12 (64 pixels out), 0 0, eight -8 (64 pixels back), then 0 held (27 nodes). An out-and-back curve; attack_ability_system names index $36 in its movement notes. Verified against the nodes.

move_chain_36 [
  delta-node < #$0000, &delta_node_01B9FC >
]

delta_node_01B9FC [
  delta-node < #$0000, &delta_node_01BA00 >
]

delta_node_01BA00 [
  delta-node < #$0000, &delta_node_01BA04 >
]

delta_node_01BA04 [
  delta-node < #$0000, &delta_node_01BA08 >
]

delta_node_01BA08 [
  delta-node < #$0000, &delta_node_01BA0C >
]

delta_node_01BA0C [
  delta-node < #$0000, &delta_node_01BA10 >
]

delta_node_01BA10 [
  delta-node < #$0000, &delta_node_01BA14 >
]

delta_node_01BA14 [
  delta-node < #$0000, &delta_node_01BA18 >
]

delta_node_01BA18 [
  delta-node < #$0004, &delta_node_01BA1C >
]

delta_node_01BA1C [
  delta-node < #$0004, &delta_node_01BA20 >
]

delta_node_01BA20 [
  delta-node < #$0007, &delta_node_01BA24 >
]

delta_node_01BA24 [
  delta-node < #$0007, &delta_node_01BA28 >
]

delta_node_01BA28 [
  delta-node < #$0009, &delta_node_01BA2C >
]

delta_node_01BA2C [
  delta-node < #$0009, &delta_node_01BA30 >
]

delta_node_01BA30 [
  delta-node < #$000C, &delta_node_01BA34 >
]

delta_node_01BA34 [
  delta-node < #$000C, &delta_node_01BA38 >
]

delta_node_01BA38 [
  delta-node < #$0000, &delta_node_01BA3C >
]

delta_node_01BA3C [
  delta-node < #$0000, &delta_node_01BA40 >
]

delta_node_01BA40 [
  delta-node < #$FFF8, &delta_node_01BA44 >
]

delta_node_01BA44 [
  delta-node < #$FFF8, &delta_node_01BA48 >
]

delta_node_01BA48 [
  delta-node < #$FFF8, &delta_node_01BA4C >
]

delta_node_01BA4C [
  delta-node < #$FFF8, &delta_node_01BA50 >
]

delta_node_01BA50 [
  delta-node < #$FFF8, &delta_node_01BA54 >
]

delta_node_01BA54 [
  delta-node < #$FFF8, &delta_node_01BA58 >
]

delta_node_01BA58 [
  delta-node < #$FFF8, &delta_node_01BA5C >
]

delta_node_01BA5C [
  delta-node < #$FFF8, &delta_node_01BA60 >
]

delta_node_01BA60 [
  delta-node < #$0000, &delta_node_01BA60 >
]

move_chain_37 [
  delta-node < #$0000, &move_chain_37 >
]

move_chain_38 [
  delta-node < #$FFFC, &delta_node_01BA6C >
]

delta_node_01BA6C [
  delta-node < #$FFFC, &delta_node_01BA70 >
]

delta_node_01BA70 [
  delta-node < #$FFFD, &delta_node_01BA74 >
]

delta_node_01BA74 [
  delta-node < #$FFFD, &delta_node_01BA78 >
]

delta_node_01BA78 [
  delta-node < #$FFFE, &delta_node_01BA7C >
]

delta_node_01BA7C [
  delta-node < #$FFFE, &delta_node_01BA80 >
]

delta_node_01BA80 [
  delta-node < #$FFFF, &delta_node_01BA84 >
]

delta_node_01BA84 [
  delta-node < #$0000, &delta_node_01BA88 >
]

delta_node_01BA88 [
  delta-node < #$0000, &delta_node_01BA8C >
]

delta_node_01BA8C [
  delta-node < #$0001, &delta_node_01BA90 >
]

delta_node_01BA90 [
  delta-node < #$0002, &delta_node_01BA94 >
]

delta_node_01BA94 [
  delta-node < #$0002, &delta_node_01BA98 >
]

delta_node_01BA98 [
  delta-node < #$0003, &delta_node_01BA9C >
]

delta_node_01BA9C [
  delta-node < #$0003, &delta_node_01BAA0 >
]

delta_node_01BAA0 [
  delta-node < #$0004, &delta_node_01BAA4 >
]

delta_node_01BAA4 [
  delta-node < #$0004, &delta_node_01BAA4 >
]

move_chain_39 [
  delta-node < #$FFFA, &delta_node_01BAAC >
]

delta_node_01BAAC [
  delta-node < #$FFFA, &delta_node_01BAB0 >
]

delta_node_01BAB0 [
  delta-node < #$FFFA, &delta_node_01BAB4 >
]

delta_node_01BAB4 [
  delta-node < #$FFFB, &delta_node_01BAB8 >
]

delta_node_01BAB8 [
  delta-node < #$FFFB, &delta_node_01BABC >
]

delta_node_01BABC [
  delta-node < #$FFFC, &delta_node_01BAC0 >
]

delta_node_01BAC0 [
  delta-node < #$FFFD, &delta_node_01BAC4 >
]

delta_node_01BAC4 [
  delta-node < #$FFFE, &delta_node_01BAC8 >
]

delta_node_01BAC8 [
  delta-node < #$FFFF, &delta_node_01BACC >
]

delta_node_01BACC [
  delta-node < #$0000, &delta_node_01BAD0 >
]

delta_node_01BAD0 [
  delta-node < #$0000, &delta_node_01BAD4 >
]

delta_node_01BAD4 [
  delta-node < #$0000, &delta_node_01BAD8 >
]

delta_node_01BAD8 [
  delta-node < #$0000, &delta_node_01BADC >
]

delta_node_01BADC [
  delta-node < #$0001, &delta_node_01BAE0 >
]

delta_node_01BAE0 [
  delta-node < #$0002, &delta_node_01BAE4 >
]

delta_node_01BAE4 [
  delta-node < #$0003, &delta_node_01BAE4 >
]

move_chain_3A [
  delta-node < #$FFFD, &delta_node_01BAEC >
]

delta_node_01BAEC [
  delta-node < #$FFFE, &delta_node_01BAF0 >
]

delta_node_01BAF0 [
  delta-node < #$FFFF, &delta_node_01BAF4 >
]

delta_node_01BAF4 [
  delta-node < #$0000, &delta_node_01BAF8 >
]

delta_node_01BAF8 [
  delta-node < #$0000, &delta_node_01BAFC >
]

delta_node_01BAFC [
  delta-node < #$0000, &delta_node_01BB00 >
]

delta_node_01BB00 [
  delta-node < #$0000, &delta_node_01BB04 >
]

delta_node_01BB04 [
  delta-node < #$0001, &delta_node_01BB08 >
]

delta_node_01BB08 [
  delta-node < #$0002, &delta_node_01BB0C >
]

delta_node_01BB0C [
  delta-node < #$0003, &delta_node_01BB10 >
]

delta_node_01BB10 [
  delta-node < #$0004, &delta_node_01BB14 >
]

delta_node_01BB14 [
  delta-node < #$0005, &delta_node_01BB18 >
]

delta_node_01BB18 [
  delta-node < #$0005, &delta_node_01BB1C >
]

delta_node_01BB1C [
  delta-node < #$0006, &delta_node_01BB20 >
]

delta_node_01BB20 [
  delta-node < #$0006, &delta_node_01BB24 >
]

delta_node_01BB24 [
  delta-node < #$0006, &delta_node_01BB24 >
]

move_chain_3B [
  delta-node < #$FFFF, &delta_node_01BB2C >
]

delta_node_01BB2C [
  delta-node < #$0000, &delta_node_01BB30 >
]

delta_node_01BB30 [
  delta-node < #$FFFF, &delta_node_01BB34 >
]

delta_node_01BB34 [
  delta-node < #$0000, &delta_node_01BB38 >
]

delta_node_01BB38 [
  delta-node < #$0000, &delta_node_01BB3C >
]

delta_node_01BB3C [
  delta-node < #$0000, &delta_node_01BB40 >
]

delta_node_01BB40 [
  delta-node < #$0001, &delta_node_01BB44 >
]

delta_node_01BB44 [
  delta-node < #$0000, &delta_node_01BB48 >
]

delta_node_01BB48 [
  delta-node < #$0001, &delta_node_01BB4C >
]

delta_node_01BB4C [
  delta-node < #$0000, &delta_node_01BB50 >
]

delta_node_01BB50 [
  delta-node < #$0001, &delta_node_01BB54 >
]

delta_node_01BB54 [
  delta-node < #$0000, &delta_node_01BB58 >
]

delta_node_01BB58 [
  delta-node < #$0001, &delta_node_01BB5C >
]

delta_node_01BB5C [
  delta-node < #$0000, &delta_node_01BB60 >
]

delta_node_01BB60 [
  delta-node < #$0000, &delta_node_01BB64 >
]

delta_node_01BB64 [
  delta-node < #$0000, &delta_node_01BB68 >
]

delta_node_01BB68 [
  delta-node < #$FFFF, &delta_node_01BB6C >
]

delta_node_01BB6C [
  delta-node < #$0000, &delta_node_01BB70 >
]

delta_node_01BB70 [
  delta-node < #$FFFF, &delta_node_01BB74 >
]

delta_node_01BB74 [
  delta-node < #$0000, &delta_node_01BB74 >
]

---------------------------------------------
; Entry $3C: +8, 0, 0, 0 repeating (4 nodes; average +2 per frame in jumps of 8 pixels). Entry $3F (01BC78) is +8, 0, 0 repeating (3 nodes).

move_chain_3C [
  delta-node < #$0008, &delta_node_01BB7C >
]

delta_node_01BB7C [
  delta-node < #$0000, &delta_node_01BB80 >
]

delta_node_01BB80 [
  delta-node < #$0000, &delta_node_01BB84 >
]

delta_node_01BB84 [
  delta-node < #$0000, &move_chain_3C >
]

move_chain_3D [
  delta-node < #$0004, &delta_node_01BB8C >
]

delta_node_01BB8C [
  delta-node < #$0000, &delta_node_01BB90 >
]

delta_node_01BB90 [
  delta-node < #$0000, &delta_node_01BB94 >
]

delta_node_01BB94 [
  delta-node < #$0000, &delta_node_01BB98 >
]

delta_node_01BB98 [
  delta-node < #$0000, &delta_node_01BB9C >
]

delta_node_01BB9C [
  delta-node < #$0000, &delta_node_01BBA0 >
]

delta_node_01BBA0 [
  delta-node < #$0004, &delta_node_01BBA4 >
]

delta_node_01BBA4 [
  delta-node < #$0000, &delta_node_01BBA8 >
]

delta_node_01BBA8 [
  delta-node < #$0000, &delta_node_01BBAC >
]

delta_node_01BBAC [
  delta-node < #$0000, &delta_node_01BBB0 >
]

delta_node_01BBB0 [
  delta-node < #$0000, &delta_node_01BBB4 >
]

delta_node_01BBB4 [
  delta-node < #$0005, &delta_node_01BBB8 >
]

delta_node_01BBB8 [
  delta-node < #$0000, &delta_node_01BBBC >
]

delta_node_01BBBC [
  delta-node < #$0000, &delta_node_01BBC0 >
]

delta_node_01BBC0 [
  delta-node < #$0000, &delta_node_01BBC4 >
]

delta_node_01BBC4 [
  delta-node < #$0004, &delta_node_01BBC8 >
]

delta_node_01BBC8 [
  delta-node < #$0000, &delta_node_01BBCC >
]

delta_node_01BBCC [
  delta-node < #$0000, &delta_node_01BBD0 >
]

delta_node_01BBD0 [
  delta-node < #$0000, &delta_node_01BBD4 >
]

delta_node_01BBD4 [
  delta-node < #$0000, &delta_node_01BBD8 >
]

delta_node_01BBD8 [
  delta-node < #$0002, &delta_node_01BBDC >
]

delta_node_01BBDC [
  delta-node < #$0000, &delta_node_01BBE0 >
]

delta_node_01BBE0 [
  delta-node < #$0000, &delta_node_01BBE4 >
]

delta_node_01BBE4 [
  delta-node < #$0000, &delta_node_01BBE8 >
]

delta_node_01BBE8 [
  delta-node < #$0000, &delta_node_01BBEC >
]

delta_node_01BBEC [
  delta-node < #$0004, &delta_node_01BBF0 >
]

delta_node_01BBF0 [
  delta-node < #$0000, &delta_node_01BBF4 >
]

delta_node_01BBF4 [
  delta-node < #$0000, &delta_node_01BBF8 >
]

delta_node_01BBF8 [
  delta-node < #$0000, &delta_node_01BBFC >
]

delta_node_01BBFC [
  delta-node < #$0000, &delta_node_01BC00 >
]

delta_node_01BC00 [
  delta-node < #$0005, &delta_node_01BC04 >
]

delta_node_01BC04 [
  delta-node < #$0000, &delta_node_01BC08 >
]

delta_node_01BC08 [
  delta-node < #$0000, &delta_node_01BC0C >
]

delta_node_01BC0C [
  delta-node < #$0000, &delta_node_01BC10 >
]

delta_node_01BC10 [
  delta-node < #$0000, &delta_node_01BC14 >
]

delta_node_01BC14 [
  delta-node < #$0004, &delta_node_01BC18 >
]

delta_node_01BC18 [
  delta-node < #$0000, &delta_node_01BC18 >
]

move_chain_3E [
  delta-node < #$0004, &delta_node_01BC20 >
]

delta_node_01BC20 [
  delta-node < #$0000, &delta_node_01BC24 >
]

delta_node_01BC24 [
  delta-node < #$0000, &delta_node_01BC28 >
]

delta_node_01BC28 [
  delta-node < #$0004, &delta_node_01BC2C >
]

delta_node_01BC2C [
  delta-node < #$0000, &delta_node_01BC30 >
]

delta_node_01BC30 [
  delta-node < #$0000, &delta_node_01BC34 >
]

delta_node_01BC34 [
  delta-node < #$0005, &delta_node_01BC38 >
]

delta_node_01BC38 [
  delta-node < #$0000, &delta_node_01BC3C >
]

delta_node_01BC3C [
  delta-node < #$0000, &delta_node_01BC40 >
]

delta_node_01BC40 [
  delta-node < #$0004, &delta_node_01BC44 >
]

delta_node_01BC44 [
  delta-node < #$0000, &delta_node_01BC48 >
]

delta_node_01BC48 [
  delta-node < #$0000, &delta_node_01BC4C >
]

delta_node_01BC4C [
  delta-node < #$0002, &delta_node_01BC50 >
]

delta_node_01BC50 [
  delta-node < #$0000, &delta_node_01BC54 >
]

delta_node_01BC54 [
  delta-node < #$0000, &delta_node_01BC58 >
]

delta_node_01BC58 [
  delta-node < #$0004, &delta_node_01BC5C >
]

delta_node_01BC5C [
  delta-node < #$0000, &delta_node_01BC60 >
]

delta_node_01BC60 [
  delta-node < #$0000, &delta_node_01BC64 >
]

delta_node_01BC64 [
  delta-node < #$0005, &delta_node_01BC68 >
]

delta_node_01BC68 [
  delta-node < #$0000, &delta_node_01BC6C >
]

delta_node_01BC6C [
  delta-node < #$0000, &delta_node_01BC70 >
]

delta_node_01BC70 [
  delta-node < #$0004, &delta_node_01BC74 >
]

delta_node_01BC74 [
  delta-node < #$0000, &delta_node_01BC74 >
]

move_chain_3F [
  delta-node < #$0008, &delta_node_01BC7C >
]

delta_node_01BC7C [
  delta-node < #$0000, &delta_node_01BC80 >
]

delta_node_01BC80 [
  delta-node < #$0000, &move_chain_3F >
]

move_chain_40 [
  delta-node < #$FFFD, &delta_node_01BC88 >
]

delta_node_01BC88 [
  delta-node < #$FFFD, &delta_node_01BC8C >
]

delta_node_01BC8C [
  delta-node < #$FFFD, &delta_node_01BC90 >
]

delta_node_01BC90 [
  delta-node < #$FFFD, &delta_node_01BC94 >
]

delta_node_01BC94 [
  delta-node < #$FFFD, &delta_node_01BC98 >
]

delta_node_01BC98 [
  delta-node < #$FFFD, &delta_node_01BC9C >
]

delta_node_01BC9C [
  delta-node < #$FFFD, &delta_node_01BCA0 >
]

delta_node_01BCA0 [
  delta-node < #$FFFD, &delta_node_01BCA4 >
]

delta_node_01BCA4 [
  delta-node < #$0001, &delta_node_01BCA8 >
]

delta_node_01BCA8 [
  delta-node < #$0001, &delta_node_01BCAC >
]

delta_node_01BCAC [
  delta-node < #$0001, &delta_node_01BCB0 >
]

delta_node_01BCB0 [
  delta-node < #$0001, &delta_node_01BCB4 >
]

delta_node_01BCB4 [
  delta-node < #$0001, &delta_node_01BCB8 >
]

delta_node_01BCB8 [
  delta-node < #$0001, &delta_node_01BCBC >
]

delta_node_01BCBC [
  delta-node < #$0001, &delta_node_01BCC0 >
]

delta_node_01BCC0 [
  delta-node < #$0001, &delta_node_01BCC4 >
]

delta_node_01BCC4 [
  delta-node < #$0000, &delta_node_01BCC4 >
]

move_chain_41 [
  delta-node < #$FFFF, &delta_node_01BCCC >
]

delta_node_01BCCC [
  delta-node < #$FFFF, &delta_node_01BCD0 >
]

delta_node_01BCD0 [
  delta-node < #$FFFF, &delta_node_01BCD4 >
]

delta_node_01BCD4 [
  delta-node < #$FFFF, &delta_node_01BCD8 >
]

delta_node_01BCD8 [
  delta-node < #$FFFF, &delta_node_01BCDC >
]

delta_node_01BCDC [
  delta-node < #$FFFF, &delta_node_01BCE0 >
]

delta_node_01BCE0 [
  delta-node < #$FFFF, &delta_node_01BCE4 >
]

delta_node_01BCE4 [
  delta-node < #$FFFF, &delta_node_01BCE8 >
]

delta_node_01BCE8 [
  delta-node < #$0003, &delta_node_01BCEC >
]

delta_node_01BCEC [
  delta-node < #$0003, &delta_node_01BCF0 >
]

delta_node_01BCF0 [
  delta-node < #$0003, &delta_node_01BCF4 >
]

delta_node_01BCF4 [
  delta-node < #$0003, &delta_node_01BCF8 >
]

delta_node_01BCF8 [
  delta-node < #$0003, &delta_node_01BCFC >
]

delta_node_01BCFC [
  delta-node < #$0003, &delta_node_01BD00 >
]

delta_node_01BD00 [
  delta-node < #$0003, &delta_node_01BD04 >
]

delta_node_01BD04 [
  delta-node < #$0003, &delta_node_01BD08 >
]

delta_node_01BD08 [
  delta-node < #$0000, &delta_node_01BD08 >
]

move_chain_42 [
  delta-node < #$0001, &delta_node_01BD10 >
]

delta_node_01BD10 [
  delta-node < #$0001, &delta_node_01BD14 >
]

delta_node_01BD14 [
  delta-node < #$0001, &delta_node_01BD18 >
]

delta_node_01BD18 [
  delta-node < #$0001, &delta_node_01BD1C >
]

delta_node_01BD1C [
  delta-node < #$0001, &delta_node_01BD20 >
]

delta_node_01BD20 [
  delta-node < #$0001, &delta_node_01BD24 >
]

delta_node_01BD24 [
  delta-node < #$0001, &delta_node_01BD28 >
]

delta_node_01BD28 [
  delta-node < #$0001, &delta_node_01BD2C >
]

delta_node_01BD2C [
  delta-node < #$0001, &delta_node_01BD30 >
]

delta_node_01BD30 [
  delta-node < #$0001, &delta_node_01BD34 >
]

delta_node_01BD34 [
  delta-node < #$0001, &delta_node_01BD38 >
]

delta_node_01BD38 [
  delta-node < #$0001, &delta_node_01BD3C >
]

delta_node_01BD3C [
  delta-node < #$0001, &delta_node_01BD40 >
]

delta_node_01BD40 [
  delta-node < #$0001, &delta_node_01BD44 >
]

delta_node_01BD44 [
  delta-node < #$0001, &delta_node_01BD48 >
]

delta_node_01BD48 [
  delta-node < #$0001, &delta_node_01BD4C >
]

delta_node_01BD4C [
  delta-node < #$0000, &delta_node_01BD4C >
]

move_chain_43 [
  delta-node < #$FFFF, &delta_node_01BD54 >
]

delta_node_01BD54 [
  delta-node < #$FFFF, &delta_node_01BD58 >
]

delta_node_01BD58 [
  delta-node < #$FFFF, &delta_node_01BD5C >
]

delta_node_01BD5C [
  delta-node < #$FFFF, &delta_node_01BD60 >
]

delta_node_01BD60 [
  delta-node < #$FFFF, &delta_node_01BD64 >
]

delta_node_01BD64 [
  delta-node < #$FFFF, &delta_node_01BD68 >
]

delta_node_01BD68 [
  delta-node < #$FFFF, &delta_node_01BD6C >
]

delta_node_01BD6C [
  delta-node < #$FFFF, &delta_node_01BD70 >
]

delta_node_01BD70 [
  delta-node < #$0001, &delta_node_01BD74 >
]

delta_node_01BD74 [
  delta-node < #$0001, &delta_node_01BD78 >
]

delta_node_01BD78 [
  delta-node < #$0001, &delta_node_01BD7C >
]

delta_node_01BD7C [
  delta-node < #$0001, &delta_node_01BD80 >
]

delta_node_01BD80 [
  delta-node < #$0001, &delta_node_01BD84 >
]

delta_node_01BD84 [
  delta-node < #$0001, &delta_node_01BD88 >
]

delta_node_01BD88 [
  delta-node < #$0001, &delta_node_01BD8C >
]

delta_node_01BD8C [
  delta-node < #$0001, &delta_node_01BD90 >
]

delta_node_01BD90 [
  delta-node < #$0000, &delta_node_01BD90 >
]

move_chain_44 [
  delta-node < #$0006, &delta_node_01BD98 >
]

delta_node_01BD98 [
  delta-node < #$0006, &delta_node_01BD9C >
]

delta_node_01BD9C [
  delta-node < #$0006, &delta_node_01BDA0 >
]

delta_node_01BDA0 [
  delta-node < #$0006, &delta_node_01BDA4 >
]

delta_node_01BDA4 [
  delta-node < #$0006, &delta_node_01BDA8 >
]

delta_node_01BDA8 [
  delta-node < #$0005, &delta_node_01BDAC >
]

delta_node_01BDAC [
  delta-node < #$0005, &delta_node_01BDB0 >
]

delta_node_01BDB0 [
  delta-node < #$0005, &delta_node_01BDB4 >
]

delta_node_01BDB4 [
  delta-node < #$0005, &delta_node_01BDB8 >
]

delta_node_01BDB8 [
  delta-node < #$0004, &delta_node_01BDBC >
]

delta_node_01BDBC [
  delta-node < #$0004, &delta_node_01BDC0 >
]

delta_node_01BDC0 [
  delta-node < #$0004, &delta_node_01BDC4 >
]

delta_node_01BDC4 [
  delta-node < #$0003, &delta_node_01BDC8 >
]

delta_node_01BDC8 [
  delta-node < #$0003, &delta_node_01BDCC >
]

delta_node_01BDCC [
  delta-node < #$0002, &delta_node_01BDD0 >
]

delta_node_01BDD0 [
  delta-node < #$0001, &delta_node_01BDD0 >
]

move_chain_45 [
  delta-node < #$FFFE, &delta_node_01BDD8 >
]

delta_node_01BDD8 [
  delta-node < #$FFFE, &delta_node_01BDDC >
]

delta_node_01BDDC [
  delta-node < #$FFFF, &delta_node_01BDE0 >
]

delta_node_01BDE0 [
  delta-node < #$FFFF, &delta_node_01BDE4 >
]

delta_node_01BDE4 [
  delta-node < #$0000, &delta_node_01BDE8 >
]

delta_node_01BDE8 [
  delta-node < #$0000, &delta_node_01BDEC >
]

delta_node_01BDEC [
  delta-node < #$0001, &delta_node_01BDF0 >
]

delta_node_01BDF0 [
  delta-node < #$0001, &delta_node_01BDF4 >
]

delta_node_01BDF4 [
  delta-node < #$0002, &delta_node_01BDF8 >
]

delta_node_01BDF8 [
  delta-node < #$0002, &delta_node_01BDFC >
]

delta_node_01BDFC [
  delta-node < #$0000, &delta_node_01BDFC >
]

move_chain_46 [
  delta-node < #$0000, &delta_node_01BE04 >
]

delta_node_01BE04 [
  delta-node < #$0000, &delta_node_01BE08 >
]

delta_node_01BE08 [
  delta-node < #$0000, &delta_node_01BE0C >
]

delta_node_01BE0C [
  delta-node < #$0000, &delta_node_01BE10 >
]

delta_node_01BE10 [
  delta-node < #$0000, &delta_node_01BE14 >
]

delta_node_01BE14 [
  delta-node < #$0000, &delta_node_01BE18 >
]

delta_node_01BE18 [
  delta-node < #$0003, &delta_node_01BE1C >
]

delta_node_01BE1C [
  delta-node < #$0003, &delta_node_01BE20 >
]

delta_node_01BE20 [
  delta-node < #$0003, &delta_node_01BE24 >
]

delta_node_01BE24 [
  delta-node < #$0003, &delta_node_01BE28 >
]

delta_node_01BE28 [
  delta-node < #$0003, &delta_node_01BE2C >
]

delta_node_01BE2C [
  delta-node < #$0003, &delta_node_01BE30 >
]

delta_node_01BE30 [
  delta-node < #$0003, &delta_node_01BE34 >
]

delta_node_01BE34 [
  delta-node < #$0003, &delta_node_01BE38 >
]

delta_node_01BE38 [
  delta-node < #$0003, &delta_node_01BE3C >
]

delta_node_01BE3C [
  delta-node < #$0003, &delta_node_01BE40 >
]

delta_node_01BE40 [
  delta-node < #$0003, &delta_node_01BE44 >
]

delta_node_01BE44 [
  delta-node < #$0003, &delta_node_01BE48 >
]

delta_node_01BE48 [
  delta-node < #$0003, &delta_node_01BE4C >
]

delta_node_01BE4C [
  delta-node < #$0003, &delta_node_01BE50 >
]

delta_node_01BE50 [
  delta-node < #$0003, &delta_node_01BE54 >
]

delta_node_01BE54 [
  delta-node < #$0003, &delta_node_01BE58 >
]

delta_node_01BE58 [
  delta-node < #$0003, &delta_node_01BE5C >
]

delta_node_01BE5C [
  delta-node < #$0003, &delta_node_01BE60 >
]

delta_node_01BE60 [
  delta-node < #$0003, &delta_node_01BE64 >
]

delta_node_01BE64 [
  delta-node < #$0001, &delta_node_01BE68 >
]

delta_node_01BE68 [
  delta-node < #$0001, &delta_node_01BE6C >
]

delta_node_01BE6C [
  delta-node < #$0001, &delta_node_01BE70 >
]

delta_node_01BE70 [
  delta-node < #$0001, &delta_node_01BE74 >
]

delta_node_01BE74 [
  delta-node < #$0000, &delta_node_01BE74 >
]

move_chain_47 [
  delta-node < #$0001, &delta_node_01BE7C >
]

delta_node_01BE7C [
  delta-node < #$0000, &delta_node_01BE80 >
]

delta_node_01BE80 [
  delta-node < #$0001, &delta_node_01BE84 >
]

delta_node_01BE84 [
  delta-node < #$0000, &delta_node_01BE88 >
]

delta_node_01BE88 [
  delta-node < #$0001, &delta_node_01BE8C >
]

delta_node_01BE8C [
  delta-node < #$0000, &delta_node_01BE90 >
]

delta_node_01BE90 [
  delta-node < #$0001, &delta_node_01BE94 >
]

delta_node_01BE94 [
  delta-node < #$0000, &delta_node_01BE98 >
]

delta_node_01BE98 [
  delta-node < #$0000, &delta_node_01BE98 >
]

move_chain_48 [
  delta-node < #$0001, &delta_node_01BEA0 >
]

delta_node_01BEA0 [
  delta-node < #$0001, &delta_node_01BEA4 >
]

delta_node_01BEA4 [
  delta-node < #$0001, &delta_node_01BEA8 >
]

delta_node_01BEA8 [
  delta-node < #$0001, &delta_node_01BEAC >
]

delta_node_01BEAC [
  delta-node < #$0002, &delta_node_01BEB0 >
]

delta_node_01BEB0 [
  delta-node < #$0002, &delta_node_01BEB4 >
]

delta_node_01BEB4 [
  delta-node < #$0002, &delta_node_01BEB8 >
]

delta_node_01BEB8 [
  delta-node < #$0002, &delta_node_01BEBC >
]

delta_node_01BEBC [
  delta-node < #$0003, &delta_node_01BEC0 >
]

delta_node_01BEC0 [
  delta-node < #$0003, &delta_node_01BEC4 >
]

delta_node_01BEC4 [
  delta-node < #$0003, &delta_node_01BEC8 >
]

delta_node_01BEC8 [
  delta-node < #$0003, &delta_node_01BECC >
]

delta_node_01BECC [
  delta-node < #$0002, &delta_node_01BED0 >
]

delta_node_01BED0 [
  delta-node < #$0002, &delta_node_01BED4 >
]

delta_node_01BED4 [
  delta-node < #$0002, &delta_node_01BED8 >
]

delta_node_01BED8 [
  delta-node < #$0002, &delta_node_01BEDC >
]

delta_node_01BEDC [
  delta-node < #$0002, &delta_node_01BEE0 >
]

delta_node_01BEE0 [
  delta-node < #$0002, &delta_node_01BEE4 >
]

delta_node_01BEE4 [
  delta-node < #$0002, &delta_node_01BEE8 >
]

delta_node_01BEE8 [
  delta-node < #$0002, &delta_node_01BEEC >
]

delta_node_01BEEC [
  delta-node < #$0000, &delta_node_01BEEC >
]

move_chain_49 [
  delta-node < #$FFFD, &delta_node_01BEF4 >
]

delta_node_01BEF4 [
  delta-node < #$FFFD, &delta_node_01BEF8 >
]

delta_node_01BEF8 [
  delta-node < #$FFFD, &delta_node_01BEFC >
]

delta_node_01BEFC [
  delta-node < #$FFFD, &delta_node_01BF00 >
]

delta_node_01BF00 [
  delta-node < #$FFFF, &delta_node_01BF04 >
]

delta_node_01BF04 [
  delta-node < #$FFFF, &delta_node_01BF08 >
]

delta_node_01BF08 [
  delta-node < #$FFFF, &delta_node_01BF0C >
]

delta_node_01BF0C [
  delta-node < #$FFFF, &delta_node_01BF10 >
]

delta_node_01BF10 [
  delta-node < #$FFFF, &delta_node_01BF14 >
]

delta_node_01BF14 [
  delta-node < #$FFFF, &delta_node_01BF18 >
]

delta_node_01BF18 [
  delta-node < #$FFFF, &delta_node_01BF1C >
]

delta_node_01BF1C [
  delta-node < #$FFFF, &delta_node_01BF20 >
]

delta_node_01BF20 [
  delta-node < #$0003, &delta_node_01BF24 >
]

delta_node_01BF24 [
  delta-node < #$0003, &delta_node_01BF28 >
]

delta_node_01BF28 [
  delta-node < #$0003, &delta_node_01BF2C >
]

delta_node_01BF2C [
  delta-node < #$0003, &delta_node_01BF30 >
]

delta_node_01BF30 [
  delta-node < #$0002, &delta_node_01BF34 >
]

delta_node_01BF34 [
  delta-node < #$0002, &delta_node_01BF38 >
]

delta_node_01BF38 [
  delta-node < #$0002, &delta_node_01BF3C >
]

delta_node_01BF3C [
  delta-node < #$0002, &delta_node_01BF40 >
]

delta_node_01BF40 [
  delta-node < #$0000, &delta_node_01BF40 >
]

move_chain_4A [
  delta-node < #$FFFE, &delta_node_01BF48 >
]

delta_node_01BF48 [
  delta-node < #$FFFF, &delta_node_01BF4C >
]

delta_node_01BF4C [
  delta-node < #$0000, &delta_node_01BF50 >
]

delta_node_01BF50 [
  delta-node < #$0001, &delta_node_01BF54 >
]

delta_node_01BF54 [
  delta-node < #$0002, &delta_node_01BF58 >
]

delta_node_01BF58 [
  delta-node < #$0000, &delta_node_01BF5C >
]

delta_node_01BF5C [
  delta-node < #$FFFF, &delta_node_01BF60 >
]

delta_node_01BF60 [
  delta-node < #$0001, &delta_node_01BF64 >
]

delta_node_01BF64 [
  delta-node < #$0000, &delta_node_01BF68 >
]

delta_node_01BF68 [
  delta-node < #$0000, &delta_node_01BF6C >
]

delta_node_01BF6C [
  delta-node < #$FFFF, &delta_node_01BF70 >
]

delta_node_01BF70 [
  delta-node < #$0001, &delta_node_01BF74 >
]

delta_node_01BF74 [
  delta-node < #$0000, &delta_node_01BF78 >
]

delta_node_01BF78 [
  delta-node < #$FFFF, &delta_node_01BF7C >
]

delta_node_01BF7C [
  delta-node < #$0001, &delta_node_01BF80 >
]

delta_node_01BF80 [
  delta-node < #$0000, &delta_node_01BF84 >
]

delta_node_01BF84 [
  delta-node < #$0000, &delta_node_01BF84 >
]

move_chain_4B [
  delta-node < #$0000, &delta_node_01BF8C >
]

delta_node_01BF8C [
  delta-node < #$0000, &delta_node_01BF90 >
]

delta_node_01BF90 [
  delta-node < #$0002, &delta_node_01BF94 >
]

delta_node_01BF94 [
  delta-node < #$0002, &delta_node_01BF98 >
]

delta_node_01BF98 [
  delta-node < #$0002, &delta_node_01BF9C >
]

delta_node_01BF9C [
  delta-node < #$0002, &delta_node_01BFA0 >
]

delta_node_01BFA0 [
  delta-node < #$0002, &delta_node_01BFA4 >
]

delta_node_01BFA4 [
  delta-node < #$0002, &delta_node_01BFA8 >
]

delta_node_01BFA8 [
  delta-node < #$0002, &delta_node_01BFAC >
]

delta_node_01BFAC [
  delta-node < #$0001, &delta_node_01BFB0 >
]

delta_node_01BFB0 [
  delta-node < #$0001, &delta_node_01BFB4 >
]

delta_node_01BFB4 [
  delta-node < #$0001, &delta_node_01BFB8 >
]

delta_node_01BFB8 [
  delta-node < #$0001, &delta_node_01BFBC >
]

delta_node_01BFBC [
  delta-node < #$0002, &delta_node_01BFC0 >
]

delta_node_01BFC0 [
  delta-node < #$0002, &delta_node_01BFC4 >
]

delta_node_01BFC4 [
  delta-node < #$0002, &delta_node_01BFC8 >
]

delta_node_01BFC8 [
  delta-node < #$0002, &delta_node_01BFCC >
]

delta_node_01BFCC [
  delta-node < #$0002, &delta_node_01BFD0 >
]

delta_node_01BFD0 [
  delta-node < #$0002, &delta_node_01BFD4 >
]

delta_node_01BFD4 [
  delta-node < #$0001, &delta_node_01BFD8 >
]

delta_node_01BFD8 [
  delta-node < #$0001, &delta_node_01BFDC >
]

delta_node_01BFDC [
  delta-node < #$0000, &delta_node_01BFDC >
]

move_chain_4C [
  delta-node < #$0000, &delta_node_01BFE4 >
]

delta_node_01BFE4 [
  delta-node < #$0000, &delta_node_01BFE8 >
]

delta_node_01BFE8 [
  delta-node < #$FFFD, &delta_node_01BFEC >
]

delta_node_01BFEC [
  delta-node < #$FFFD, &delta_node_01BFF0 >
]

delta_node_01BFF0 [
  delta-node < #$FFFD, &delta_node_01BFF4 >
]

delta_node_01BFF4 [
  delta-node < #$FFFD, &delta_node_01BFF8 >
]

delta_node_01BFF8 [
  delta-node < #$FFFD, &delta_node_01BFFC >
]

delta_node_01BFFC [
  delta-node < #$FFFD, &delta_node_01C000 >
]

delta_node_01C000 [
  delta-node < #$FFFD, &delta_node_01C004 >
]

delta_node_01C004 [
  delta-node < #$FFFD, &delta_node_01C008 >
]

delta_node_01C008 [
  delta-node < #$FFFD, &delta_node_01C00C >
]

delta_node_01C00C [
  delta-node < #$FFFD, &delta_node_01C010 >
]

delta_node_01C010 [
  delta-node < #$FFFD, &delta_node_01C014 >
]

delta_node_01C014 [
  delta-node < #$FFFD, &delta_node_01C018 >
]

delta_node_01C018 [
  delta-node < #$FFFD, &delta_node_01C01C >
]

delta_node_01C01C [
  delta-node < #$FFFD, &delta_node_01C020 >
]

delta_node_01C020 [
  delta-node < #$FFFD, &delta_node_01C024 >
]

delta_node_01C024 [
  delta-node < #$FFFD, &delta_node_01C028 >
]

delta_node_01C028 [
  delta-node < #$FFFD, &delta_node_01C02C >
]

delta_node_01C02C [
  delta-node < #$FFFD, &delta_node_01C030 >
]

delta_node_01C030 [
  delta-node < #$FFFD, &delta_node_01C034 >
]

delta_node_01C034 [
  delta-node < #$FFFD, &delta_node_01C038 >
]

delta_node_01C038 [
  delta-node < #$FFFD, &delta_node_01C03C >
]

delta_node_01C03C [
  delta-node < #$FFFD, &delta_node_01C040 >
]

delta_node_01C040 [
  delta-node < #$FFFD, &delta_node_01C044 >
]

delta_node_01C044 [
  delta-node < #$FFFD, &delta_node_01C048 >
]

delta_node_01C048 [
  delta-node < #$FFFD, &delta_node_01C04C >
]

delta_node_01C04C [
  delta-node < #$FFFD, &delta_node_01C050 >
]

delta_node_01C050 [
  delta-node < #$FFFE, &delta_node_01C054 >
]

delta_node_01C054 [
  delta-node < #$FFFE, &delta_node_01C058 >
]

delta_node_01C058 [
  delta-node < #$FFFE, &delta_node_01C05C >
]

delta_node_01C05C [
  delta-node < #$FFFE, &delta_node_01C060 >
]

delta_node_01C060 [
  delta-node < #$FFFE, &delta_node_01C064 >
]

delta_node_01C064 [
  delta-node < #$FFFE, &delta_node_01C068 >
]

delta_node_01C068 [
  delta-node < #$FFFF, &delta_node_01C06C >
]

delta_node_01C06C [
  delta-node < #$FFFF, &delta_node_01C070 >
]

delta_node_01C070 [
  delta-node < #$FFFF, &delta_node_01C074 >
]

delta_node_01C074 [
  delta-node < #$FFFF, &delta_node_01C078 >
]

delta_node_01C078 [
  delta-node < #$FFFF, &delta_node_01C07C >
]

delta_node_01C07C [
  delta-node < #$FFFF, &delta_node_01C080 >
]

delta_node_01C080 [
  delta-node < #$FFFF, &delta_node_01C084 >
]

delta_node_01C084 [
  delta-node < #$FFFF, &delta_node_01C088 >
]

delta_node_01C088 [
  delta-node < #$0000, &delta_node_01C088 >
]

move_chain_4D [
  delta-node < #$0000, &delta_node_01C090 >
]

delta_node_01C090 [
  delta-node < #$0000, &delta_node_01C094 >
]

delta_node_01C094 [
  delta-node < #$0002, &delta_node_01C098 >
]

delta_node_01C098 [
  delta-node < #$0002, &delta_node_01C09C >
]

delta_node_01C09C [
  delta-node < #$0002, &delta_node_01C0A0 >
]

delta_node_01C0A0 [
  delta-node < #$0002, &delta_node_01C0A4 >
]

delta_node_01C0A4 [
  delta-node < #$0002, &delta_node_01C0A8 >
]

delta_node_01C0A8 [
  delta-node < #$0002, &delta_node_01C0AC >
]

delta_node_01C0AC [
  delta-node < #$0002, &delta_node_01C0B0 >
]

delta_node_01C0B0 [
  delta-node < #$0002, &delta_node_01C0B4 >
]

delta_node_01C0B4 [
  delta-node < #$0002, &delta_node_01C0B8 >
]

delta_node_01C0B8 [
  delta-node < #$0002, &delta_node_01C0BC >
]

delta_node_01C0BC [
  delta-node < #$0002, &delta_node_01C0C0 >
]

delta_node_01C0C0 [
  delta-node < #$0002, &delta_node_01C0C4 >
]

delta_node_01C0C4 [
  delta-node < #$0002, &delta_node_01C0C8 >
]

delta_node_01C0C8 [
  delta-node < #$0002, &delta_node_01C0CC >
]

delta_node_01C0CC [
  delta-node < #$0002, &delta_node_01C0D0 >
]

delta_node_01C0D0 [
  delta-node < #$0002, &delta_node_01C0D4 >
]

delta_node_01C0D4 [
  delta-node < #$0002, &delta_node_01C0D8 >
]

delta_node_01C0D8 [
  delta-node < #$0002, &delta_node_01C0DC >
]

delta_node_01C0DC [
  delta-node < #$0002, &delta_node_01C0E0 >
]

delta_node_01C0E0 [
  delta-node < #$0002, &delta_node_01C0E4 >
]

delta_node_01C0E4 [
  delta-node < #$0002, &delta_node_01C0E8 >
]

delta_node_01C0E8 [
  delta-node < #$0002, &delta_node_01C0EC >
]

delta_node_01C0EC [
  delta-node < #$0001, &delta_node_01C0F0 >
]

delta_node_01C0F0 [
  delta-node < #$0001, &delta_node_01C0F4 >
]

delta_node_01C0F4 [
  delta-node < #$0001, &delta_node_01C0F8 >
]

delta_node_01C0F8 [
  delta-node < #$0001, &delta_node_01C0FC >
]

delta_node_01C0FC [
  delta-node < #$0001, &delta_node_01C100 >
]

delta_node_01C100 [
  delta-node < #$0001, &delta_node_01C104 >
]

delta_node_01C104 [
  delta-node < #$0002, &delta_node_01C108 >
]

delta_node_01C108 [
  delta-node < #$0002, &delta_node_01C10C >
]

delta_node_01C10C [
  delta-node < #$0000, &delta_node_01C10C >
]

move_chain_4E [
  delta-node < #$0000, &delta_node_01C114 >
]

delta_node_01C114 [
  delta-node < #$0000, &delta_node_01C118 >
]

delta_node_01C118 [
  delta-node < #$0000, &delta_node_01C11C >
]

delta_node_01C11C [
  delta-node < #$0000, &delta_node_01C120 >
]

delta_node_01C120 [
  delta-node < #$FFFF, &delta_node_01C124 >
]

delta_node_01C124 [
  delta-node < #$FFFF, &delta_node_01C128 >
]

delta_node_01C128 [
  delta-node < #$FFFE, &delta_node_01C12C >
]

delta_node_01C12C [
  delta-node < #$FFFE, &delta_node_01C130 >
]

delta_node_01C130 [
  delta-node < #$FFFD, &delta_node_01C134 >
]

delta_node_01C134 [
  delta-node < #$FFFD, &delta_node_01C138 >
]

delta_node_01C138 [
  delta-node < #$FFFC, &delta_node_01C13C >
]

delta_node_01C13C [
  delta-node < #$FFFC, &delta_node_01C140 >
]

delta_node_01C140 [
  delta-node < #$0000, &delta_node_01C144 >
]

delta_node_01C144 [
  delta-node < #$0000, &delta_node_01C148 >
]

delta_node_01C148 [
  delta-node < #$0001, &delta_node_01C14C >
]

delta_node_01C14C [
  delta-node < #$0001, &delta_node_01C150 >
]

delta_node_01C150 [
  delta-node < #$0002, &delta_node_01C154 >
]

delta_node_01C154 [
  delta-node < #$0002, &delta_node_01C158 >
]

delta_node_01C158 [
  delta-node < #$0003, &delta_node_01C15C >
]

delta_node_01C15C [
  delta-node < #$0003, &delta_node_01C160 >
]

delta_node_01C160 [
  delta-node < #$0004, &delta_node_01C164 >
]

delta_node_01C164 [
  delta-node < #$0004, &delta_node_01C168 >
]

delta_node_01C168 [
  delta-node < #$0006, &delta_node_01C16C >
]

delta_node_01C16C [
  delta-node < #$0006, &delta_node_01C170 >
]

delta_node_01C170 [
  delta-node < #$FFFE, &delta_node_01C174 >
]

delta_node_01C174 [
  delta-node < #$FFFE, &delta_node_01C178 >
]

delta_node_01C178 [
  delta-node < #$0006, &delta_node_01C17C >
]

delta_node_01C17C [
  delta-node < #$0006, &delta_node_01C180 >
]

delta_node_01C180 [
  delta-node < #$FFFE, &delta_node_01C184 >
]

delta_node_01C184 [
  delta-node < #$FFFE, &delta_node_01C188 >
]

delta_node_01C188 [
  delta-node < #$0006, &delta_node_01C18C >
]

delta_node_01C18C [
  delta-node < #$0006, &delta_node_01C190 >
]

delta_node_01C190 [
  delta-node < #$0000, &delta_node_01C190 >
]

move_chain_4F [
  delta-node < #$FFFC, &delta_node_01C198 >
]

delta_node_01C198 [
  delta-node < #$FFFC, &delta_node_01C19C >
]

delta_node_01C19C [
  delta-node < #$FFFC, &delta_node_01C1A0 >
]

delta_node_01C1A0 [
  delta-node < #$FFFC, &delta_node_01C1A4 >
]

delta_node_01C1A4 [
  delta-node < #$FFFC, &delta_node_01C1A8 >
]

delta_node_01C1A8 [
  delta-node < #$FFFC, &delta_node_01C1AC >
]

delta_node_01C1AC [
  delta-node < #$FFFC, &delta_node_01C1B0 >
]

delta_node_01C1B0 [
  delta-node < #$FFFC, &delta_node_01C1B4 >
]

delta_node_01C1B4 [
  delta-node < #$0006, &delta_node_01C1B8 >
]

delta_node_01C1B8 [
  delta-node < #$0006, &delta_node_01C1BC >
]

delta_node_01C1BC [
  delta-node < #$0006, &delta_node_01C1C0 >
]

delta_node_01C1C0 [
  delta-node < #$0006, &delta_node_01C1C4 >
]

delta_node_01C1C4 [
  delta-node < #$0006, &delta_node_01C1C8 >
]

delta_node_01C1C8 [
  delta-node < #$0006, &delta_node_01C1CC >
]

delta_node_01C1CC [
  delta-node < #$0006, &delta_node_01C1D0 >
]

delta_node_01C1D0 [
  delta-node < #$0006, &delta_node_01C1D4 >
]

delta_node_01C1D4 [
  delta-node < #$0006, &delta_node_01C1D8 >
]

delta_node_01C1D8 [
  delta-node < #$0006, &delta_node_01C1DC >
]

delta_node_01C1DC [
  delta-node < #$0006, &delta_node_01C1E0 >
]

delta_node_01C1E0 [
  delta-node < #$0006, &delta_node_01C1E4 >
]

delta_node_01C1E4 [
  delta-node < #$0006, &delta_node_01C1E8 >
]

delta_node_01C1E8 [
  delta-node < #$0006, &delta_node_01C1EC >
]

delta_node_01C1EC [
  delta-node < #$0006, &delta_node_01C1F0 >
]

delta_node_01C1F0 [
  delta-node < #$0006, &delta_node_01C1F4 >
]

delta_node_01C1F4 [
  delta-node < #$0000, &delta_node_01C1F4 >
]

move_chain_50 [
  delta-node < #$FFFE, &delta_node_01C1FC >
]

delta_node_01C1FC [
  delta-node < #$FFFE, &delta_node_01C200 >
]

delta_node_01C200 [
  delta-node < #$FFFE, &delta_node_01C204 >
]

delta_node_01C204 [
  delta-node < #$FFFD, &delta_node_01C208 >
]

delta_node_01C208 [
  delta-node < #$FFFD, &delta_node_01C20C >
]

delta_node_01C20C [
  delta-node < #$FFFD, &delta_node_01C210 >
]

delta_node_01C210 [
  delta-node < #$FFFD, &delta_node_01C214 >
]

delta_node_01C214 [
  delta-node < #$FFFC, &delta_node_01C218 >
]

delta_node_01C218 [
  delta-node < #$FFFC, &delta_node_01C21C >
]

delta_node_01C21C [
  delta-node < #$FFFB, &delta_node_01C220 >
]

delta_node_01C220 [
  delta-node < #$FFFB, &delta_node_01C224 >
]

delta_node_01C224 [
  delta-node < #$FFFB, &delta_node_01C228 >
]

delta_node_01C228 [
  delta-node < #$FFFB, &delta_node_01C22C >
]

delta_node_01C22C [
  delta-node < #$FFFB, &delta_node_01C230 >
]

delta_node_01C230 [
  delta-node < #$FFFA, &delta_node_01C234 >
]

delta_node_01C234 [
  delta-node < #$FFFA, &delta_node_01C238 >
]

delta_node_01C238 [
  delta-node < #$FFFA, &delta_node_01C23C >
]

delta_node_01C23C [
  delta-node < #$FFF9, &delta_node_01C240 >
]

delta_node_01C240 [
  delta-node < #$FFF9, &delta_node_01C244 >
]

delta_node_01C244 [
  delta-node < #$0006, &delta_node_01C248 >
]

delta_node_01C248 [
  delta-node < #$0006, &delta_node_01C24C >
]

delta_node_01C24C [
  delta-node < #$0005, &delta_node_01C250 >
]

delta_node_01C250 [
  delta-node < #$0001, &delta_node_01C254 >
]

delta_node_01C254 [
  delta-node < #$0001, &delta_node_01C258 >
]

delta_node_01C258 [
  delta-node < #$0000, &delta_node_01C258 >
]

move_chain_51 [
  delta-node < #$0000, &delta_node_01C260 >
]

delta_node_01C260 [
  delta-node < #$0000, &delta_node_01C264 >
]

delta_node_01C264 [
  delta-node < #$0000, &delta_node_01C268 >
]

delta_node_01C268 [
  delta-node < #$0000, &delta_node_01C26C >
]

delta_node_01C26C [
  delta-node < #$0001, &delta_node_01C26C >
]

move_chain_52 [
  delta-node < #$0000, &delta_node_01C274 >
]

delta_node_01C274 [
  delta-node < #$0000, &delta_node_01C278 >
]

delta_node_01C278 [
  delta-node < #$0000, &delta_node_01C27C >
]

delta_node_01C27C [
  delta-node < #$0000, &delta_node_01C280 >
]

delta_node_01C280 [
  delta-node < #$FFFF, &delta_node_01C280 >
]

---------------------------------------------
; Entry $53: sixteen 0, then sixteen -1, and the last node links back to the head: -1 pixel per frame for 16 frames, still for 16, repeating.

move_chain_53 [
  delta-node < #$0000, &delta_node_01C288 >
]

delta_node_01C288 [
  delta-node < #$0000, &delta_node_01C28C >
]

delta_node_01C28C [
  delta-node < #$0000, &delta_node_01C290 >
]

delta_node_01C290 [
  delta-node < #$0000, &delta_node_01C294 >
]

delta_node_01C294 [
  delta-node < #$0000, &delta_node_01C298 >
]

delta_node_01C298 [
  delta-node < #$0000, &delta_node_01C29C >
]

delta_node_01C29C [
  delta-node < #$0000, &delta_node_01C2A0 >
]

delta_node_01C2A0 [
  delta-node < #$0000, &delta_node_01C2A4 >
]

delta_node_01C2A4 [
  delta-node < #$0000, &delta_node_01C2A8 >
]

delta_node_01C2A8 [
  delta-node < #$0000, &delta_node_01C2AC >
]

delta_node_01C2AC [
  delta-node < #$0000, &delta_node_01C2B0 >
]

delta_node_01C2B0 [
  delta-node < #$0000, &delta_node_01C2B4 >
]

delta_node_01C2B4 [
  delta-node < #$0000, &delta_node_01C2B8 >
]

delta_node_01C2B8 [
  delta-node < #$0000, &delta_node_01C2BC >
]

delta_node_01C2BC [
  delta-node < #$0000, &delta_node_01C2C0 >
]

delta_node_01C2C0 [
  delta-node < #$0000, &delta_node_01C2C4 >
]

delta_node_01C2C4 [
  delta-node < #$FFFF, &delta_node_01C2C8 >
]

delta_node_01C2C8 [
  delta-node < #$FFFF, &delta_node_01C2CC >
]

delta_node_01C2CC [
  delta-node < #$FFFF, &delta_node_01C2D0 >
]

delta_node_01C2D0 [
  delta-node < #$FFFF, &delta_node_01C2D4 >
]

delta_node_01C2D4 [
  delta-node < #$FFFF, &delta_node_01C2D8 >
]

delta_node_01C2D8 [
  delta-node < #$FFFF, &delta_node_01C2DC >
]

delta_node_01C2DC [
  delta-node < #$FFFF, &delta_node_01C2E0 >
]

delta_node_01C2E0 [
  delta-node < #$FFFF, &delta_node_01C2E4 >
]

delta_node_01C2E4 [
  delta-node < #$FFFF, &delta_node_01C2E8 >
]

delta_node_01C2E8 [
  delta-node < #$FFFF, &delta_node_01C2EC >
]

delta_node_01C2EC [
  delta-node < #$FFFF, &delta_node_01C2F0 >
]

delta_node_01C2F0 [
  delta-node < #$FFFF, &delta_node_01C2F4 >
]

delta_node_01C2F4 [
  delta-node < #$FFFF, &delta_node_01C2F8 >
]

delta_node_01C2F8 [
  delta-node < #$FFFF, &delta_node_01C2FC >
]

delta_node_01C2FC [
  delta-node < #$FFFF, &delta_node_01C300 >
]

delta_node_01C300 [
  delta-node < #$FFFF, &move_chain_53 >
]

---------------------------------------------
; Entry $54, the last chain: sixteen 0, then the $15 swing (-4 -4 -2 -2 -1 -1, four 0, +1 +1 +2 +2 +4 +4), 32 nodes, the last node links back to the head: a periodic back-and-forth, net 0.

move_chain_54 [
  delta-node < #$0000, &delta_node_01C308 >
]

delta_node_01C308 [
  delta-node < #$0000, &delta_node_01C30C >
]

delta_node_01C30C [
  delta-node < #$0000, &delta_node_01C310 >
]

delta_node_01C310 [
  delta-node < #$0000, &delta_node_01C314 >
]

delta_node_01C314 [
  delta-node < #$0000, &delta_node_01C318 >
]

delta_node_01C318 [
  delta-node < #$0000, &delta_node_01C31C >
]

delta_node_01C31C [
  delta-node < #$0000, &delta_node_01C320 >
]

delta_node_01C320 [
  delta-node < #$0000, &delta_node_01C324 >
]

delta_node_01C324 [
  delta-node < #$0000, &delta_node_01C328 >
]

delta_node_01C328 [
  delta-node < #$0000, &delta_node_01C32C >
]

delta_node_01C32C [
  delta-node < #$0000, &delta_node_01C330 >
]

delta_node_01C330 [
  delta-node < #$0000, &delta_node_01C334 >
]

delta_node_01C334 [
  delta-node < #$0000, &delta_node_01C338 >
]

delta_node_01C338 [
  delta-node < #$0000, &delta_node_01C33C >
]

delta_node_01C33C [
  delta-node < #$0000, &delta_node_01C340 >
]

delta_node_01C340 [
  delta-node < #$0000, &delta_node_01C344 >
]

delta_node_01C344 [
  delta-node < #$FFFC, &delta_node_01C348 >
]

delta_node_01C348 [
  delta-node < #$FFFC, &delta_node_01C34C >
]

delta_node_01C34C [
  delta-node < #$FFFE, &delta_node_01C350 >
]

delta_node_01C350 [
  delta-node < #$FFFE, &delta_node_01C354 >
]

delta_node_01C354 [
  delta-node < #$FFFF, &delta_node_01C358 >
]

delta_node_01C358 [
  delta-node < #$FFFF, &delta_node_01C35C >
]

delta_node_01C35C [
  delta-node < #$0000, &delta_node_01C360 >
]

delta_node_01C360 [
  delta-node < #$0000, &delta_node_01C364 >
]

delta_node_01C364 [
  delta-node < #$0000, &delta_node_01C368 >
]

delta_node_01C368 [
  delta-node < #$0000, &delta_node_01C36C >
]

delta_node_01C36C [
  delta-node < #$0001, &delta_node_01C370 >
]

delta_node_01C370 [
  delta-node < #$0001, &delta_node_01C374 >
]

delta_node_01C374 [
  delta-node < #$0002, &delta_node_01C378 >
]

delta_node_01C378 [
  delta-node < #$0002, &delta_node_01C37C >
]

delta_node_01C37C [
  delta-node < #$0004, &delta_node_01C380 >
]

delta_node_01C380 [
  delta-node < #$0004, &move_chain_54 >
]