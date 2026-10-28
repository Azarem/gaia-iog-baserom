; Enemy combat stat rows (Bank 01, 109552-109992 = $01:ABF0): 110 rows of 4 bytes < HP, ATK, DEF, gemDropType >. The row number is the stats index: byte 6 of an enemy-spawn record in scene_actors (index $01-$63 in 62 distinct values; 0 = an actor without combat stats). InitActorFromSceneData stores index x 4 + the table address in statsPtr ($7F0020,X) and loads byte 0 into currentHp ($7F0026,X). Boss and special actors set statsPtr themselves with an operand such as enemy_stats_table+154 (the offset is in hex: +154 / 4 = row $55). The old note was wrong about the fourth byte ('Type 0-3, affects damage calculations'), about DEF $7F ('immune to normal damage') and about HP $7F / $FF ('boss-tier').
; 
; === FIELDS (read by combat_collision and StandardEnemyDefeatHandler) ===
; 
; | Byte | Field | Reader |
; |------|-------|--------|
; | +0 | HP: the start value of currentHp and the maximum (hitVictimMaxHp) | InitActorFromSceneData, ApplyHitDamageToVictim |
; | +1 | ATK: the damage the enemy deals to the player on contact: max(1, ATK - playerDef), then 60 frames of invulnerability | the enemy-hits-player path of combat_collision |
; | +2 | DEF: subtracted from the player's total strength: rawDamage = max(1, totalStr - DEF), netDamage = rawDamage + characterForm | ApplyHitDamageToVictim (_DamagePath) |
; | +3 | gemDropType: 0 = no gem, 1 = SpawnDropGem1, 2 = SpawnDropGem2, 3 or more = SpawnDropByHpTier (EnemyDropSystem) | EnemyGemDropRouter in StandardEnemyDefeatHandler |
; 
; PlayerAttackHitTest (the player's attack box) does not read DEF: its damage is chainDamage / 2 + 1, with chainDamage accumulating over consecutive hits of one attack (formulas in the combat_collision header). Which attack of the game goes through which of the two routines was not traced at runtime (OQ-I066-2). DEF $7F (21 rows) and $FF (row $46) therefore do not make an enemy immune: in ApplyHitDamageToVictim they only pin every hit to its minimum, 1 + characterForm. Damage and stagger immunity are bits $0010 / $0020 of the actor's $12 flags (EnemyInitBasic sets both), not table data.
; 
; The gem is only dropped when the scene's clear reward (flag $0300) was already taken or other enemies remain; the last enemy of a scene gives the stat reward of enemy_clear_reward_table instead.
; 
; === WHOLE-TABLE FACTS ===
; 
; - 18 rows are all zero ($00 $12 $13 $15-$17 $23-$26 $65-$68 $6A-$6D). Row $00 is also the pointer EnemyInitBasic stores: an actor whose statsPtr equals the table address is counted as 'no stats' (no kill counter, no gem, no reward).
; - 92 rows have stats: gemDropType 0 in 37, 1 in 21, 2 in 21, 3 in 13. 21 rows have DEF $7F, row $46 has DEF $FF, rows $21 and $22 have HP $FF.
; - Rows named by code (statsPtr operands): $01 dc2F_adrift; $08 ec0E_spiney; $11 ec12_skull_chaser and sp5A_phantom_ribber; $31 and $69 mu67_vampires; $33 gw82_archer; $37 gw8A_sand_fanger; $46 twelve switch, blocker and trapped-slave actors (hit_switch, dm3F_switch, dm40_trapped_slave, ec0E_switch, ec11_aqueduct_blocker, ec11_button_voice, ec12_aqueduct_enemy, ir21_switch, pyD6_vader_barrier_lower / upper, sg52_blocker_enemy_a / b); $47 and $48 awB0_zombie; $4D pyD2_haunt; $55-$58 sE8_dark_gaia (and unused_mode7_boss for $55-$57); $5F and $60 sEA_solid_arm; $64 ec0E_lily and ir29_castoth.
; - 16 rows with stats are neither used by a scene spawn record nor named by code: $06 $07 $09 $1F $20 $21 $22 $38 $39 $3B $40 $41 $4B $52 $53 $59 (OQ-I066-1).
; 
; The enemy a row belongs to is the actor named in the spawn record, so the table does not say which enemy it describes.
---------------------------------------------

?BANK 01

---------------------------------------------

; 110 enemy-stats rows < HP, ATK, DEF, gemDropType >, row index = the stats index of a scene_actors enemy-spawn record (byte 6; 0 = none). Field uses, the all-zero rows, the rows named by code and the 16 rows with no reader are in the block note.

enemy_stats_table [
  enemy-stats < #00, #00, #00, #00 >   ;00
  enemy-stats < #06, #02, #00, #02 >   ;01
  enemy-stats < #05, #01, #00, #01 >   ;02
  enemy-stats < #0A, #03, #01, #03 >   ;03
  enemy-stats < #03, #02, #01, #01 >   ;04
  enemy-stats < #03, #01, #00, #01 >   ;05
  enemy-stats < #7F, #00, #00, #00 >   ;06
  enemy-stats < #08, #02, #46, #00 >   ;07
  enemy-stats < #03, #02, #33, #00 >   ;08
  enemy-stats < #06, #02, #30, #00 >   ;09
  enemy-stats < #08, #02, #00, #02 >   ;0A
  enemy-stats < #06, #03, #00, #01 >   ;0B
  enemy-stats < #09, #02, #00, #01 >   ;0C
  enemy-stats < #0B, #04, #02, #02 >   ;0D
  enemy-stats < #08, #03, #01, #03 >   ;0E
  enemy-stats < #06, #03, #01, #01 >   ;0F
  enemy-stats < #0E, #03, #01, #00 >   ;10
  enemy-stats < #0A, #05, #01, #03 >   ;11
  enemy-stats < #00, #00, #00, #00 >   ;12
  enemy-stats < #00, #00, #00, #00 >   ;13
  enemy-stats < #28, #07, #7F, #00 >   ;14
  enemy-stats < #00, #00, #00, #00 >   ;15
  enemy-stats < #00, #00, #00, #00 >   ;16
  enemy-stats < #00, #00, #00, #00 >   ;17
  enemy-stats < #0A, #09, #03, #02 >   ;18
  enemy-stats < #05, #07, #04, #01 >   ;19
  enemy-stats < #05, #08, #04, #03 >   ;1A
  enemy-stats < #0C, #09, #04, #01 >   ;1B
  enemy-stats < #0C, #0A, #04, #02 >   ;1C
  enemy-stats < #10, #09, #04, #01 >   ;1D
  enemy-stats < #14, #0A, #05, #03 >   ;1E
  enemy-stats < #05, #01, #00, #00 >   ;1F
  enemy-stats < #05, #01, #00, #00 >   ;20
  enemy-stats < #FF, #09, #00, #00 >   ;21
  enemy-stats < #FF, #0A, #00, #00 >   ;22
  enemy-stats < #00, #00, #00, #00 >   ;23
  enemy-stats < #00, #00, #00, #00 >   ;24
  enemy-stats < #00, #00, #00, #00 >   ;25
  enemy-stats < #00, #00, #00, #00 >   ;26
  enemy-stats < #28, #0F, #7F, #00 >   ;27
  enemy-stats < #1A, #0E, #06, #02 >   ;28
  enemy-stats < #16, #0D, #05, #03 >   ;29
  enemy-stats < #0C, #0E, #04, #01 >   ;2A
  enemy-stats < #08, #0E, #02, #01 >   ;2B
  enemy-stats < #14, #12, #07, #02 >   ;2C
  enemy-stats < #05, #0F, #09, #01 >   ;2D
  enemy-stats < #0A, #12, #0B, #03 >   ;2E
  enemy-stats < #28, #0E, #7F, #00 >   ;2F
  enemy-stats < #28, #0F, #7F, #00 >   ;30
  enemy-stats < #32, #16, #7F, #00 >   ;31
  enemy-stats < #0F, #0F, #0A, #01 >   ;32
  enemy-stats < #19, #12, #09, #02 >   ;33
  enemy-stats < #16, #13, #08, #03 >   ;34
  enemy-stats < #16, #10, #08, #02 >   ;35
  enemy-stats < #28, #15, #7F, #00 >   ;36
  enemy-stats < #03, #11, #7F, #00 >   ;37
  enemy-stats < #14, #09, #06, #03 >   ;38
  enemy-stats < #14, #09, #08, #00 >   ;39
  enemy-stats < #14, #09, #08, #01 >   ;3A
  enemy-stats < #10, #0E, #08, #00 >   ;3B
  enemy-stats < #10, #12, #0B, #02 >   ;3C
  enemy-stats < #12, #13, #0D, #01 >   ;3D
  enemy-stats < #12, #12, #0D, #01 >   ;3E
  enemy-stats < #0F, #14, #0F, #03 >   ;3F
  enemy-stats < #0C, #09, #07, #02 >   ;40
  enemy-stats < #06, #09, #05, #01 >   ;41
  enemy-stats < #19, #16, #10, #02 >   ;42
  enemy-stats < #14, #1A, #10, #01 >   ;43
  enemy-stats < #1E, #16, #0C, #03 >   ;44
  enemy-stats < #1C, #19, #0B, #02 >   ;45
  enemy-stats < #14, #16, #FF, #00 >   ;46
  enemy-stats < #14, #17, #0E, #03 >   ;47
  enemy-stats < #0A, #16, #0F, #00 >   ;48
  enemy-stats < #0F, #17, #0F, #02 >   ;49
  enemy-stats < #08, #16, #0F, #01 >   ;4A
  enemy-stats < #06, #09, #05, #01 >   ;4B
  enemy-stats < #0C, #17, #0C, #02 >   ;4C
  enemy-stats < #1C, #1A, #0F, #00 >   ;4D
  enemy-stats < #1E, #18, #0F, #03 >   ;4E
  enemy-stats < #14, #17, #0F, #02 >   ;4F
  enemy-stats < #28, #22, #7F, #00 >   ;50
  enemy-stats < #19, #15, #11, #02 >   ;51
  enemy-stats < #08, #09, #06, #00 >   ;52
  enemy-stats < #05, #09, #05, #01 >   ;53
  enemy-stats < #14, #24, #7F, #00 >   ;54
  enemy-stats < #28, #23, #7F, #00 >   ;55
  enemy-stats < #0A, #26, #7F, #00 >   ;56
  enemy-stats < #01, #23, #7F, #00 >   ;57
  enemy-stats < #14, #2B, #7F, #00 >   ;58
  enemy-stats < #10, #0E, #08, #02 >   ;59
  enemy-stats < #28, #24, #7F, #00 >   ;5A
  enemy-stats < #28, #24, #7F, #00 >   ;5B
  enemy-stats < #28, #24, #7F, #00 >   ;5C
  enemy-stats < #28, #24, #7F, #00 >   ;5D
  enemy-stats < #28, #24, #7F, #00 >   ;5E
  enemy-stats < #28, #24, #7F, #00 >   ;5F
  enemy-stats < #28, #24, #7F, #00 >   ;60
  enemy-stats < #14, #24, #1A, #02 >   ;61
  enemy-stats < #10, #24, #19, #02 >   ;62
  enemy-stats < #1E, #24, #19, #02 >   ;63
  enemy-stats < #0A, #07, #08, #00 >   ;64
  enemy-stats < #00, #00, #00, #00 >   ;65
  enemy-stats < #00, #00, #00, #00 >   ;66
  enemy-stats < #00, #00, #00, #00 >   ;67
  enemy-stats < #00, #00, #00, #00 >   ;68
  enemy-stats < #28, #28, #7F, #00 >   ;69
  enemy-stats < #00, #00, #00, #00 >   ;6A
  enemy-stats < #00, #00, #00, #00 >   ;6B
  enemy-stats < #00, #00, #00, #00 >   ;6C
  enemy-stats < #00, #00, #00, #00 >   ;6D
]