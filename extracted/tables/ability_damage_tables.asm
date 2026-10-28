; Attack ability damage tables (Bank 01, 121255-121278): one table per player form, three abilities each. Despite the old name and header they hold no animation, sprite-frame or hitbox data: each record is { word $0000, word pointer to the ability's upgrade-level word in WRAM, one damage byte per upgrade level }.
; 
; LoadAbilityDamageA (Will, will_ability_damage_table) and LoadAbilityDamageB (Freedan, freedan_ability_damage_table) in attack_ability_system take the ability index in A, follow the table pointer to the record, read the level from the WRAM word the record points to, and store record[4 + level] in climbStateData ($09E0 for Will, $09E2 for Freedan). combat_collision adds that value to the hit strength.
; 
; | Table | Ability | Level word | Damage by level |
; |-------|---------|-----------|------------------|
; | Will | 0 Psycho Dash | $0B16 | 5 / 10 |
; | Will | 1 Psycho Slider | $0B18 | 5 / 8 |
; | Will | 2 Spin Dash | $0B1A | 4 / 7 |
; | Freedan | 0 Dark Friar | $0B1C | 5 / 8 / 12 |
; | Freedan | 1 Aura Barrier | $0B1E | 5 / 9 |
; | Freedan | 2 Earthquaker | $0B20 | 0 / 7 |
; 
; The level word is written by the jeweler_gem rewards (Psycho Dash level 1 at 20 jewels, Dark Friar level 2 at 30) and read by the ability code. The first word of every record is $0000 and no code reads it (OQ-I062-2). Dark Friar is the only 7-byte record (three levels); the other five are 6 bytes.
; 
; Checked: all six records decoded byte by byte against both loaders (attack_ability_system lines 1628-1672) and against the table note in attack_ability_system and the jeweler_gem rewards. The values as damage bonuses come from those notes; not traced at runtime (UNVERIFIED-RUNTIME).
---------------------------------------------

?BANK 01

---------------------------------------------

; Will's three abilities: 3 word pointers (index 0 Psycho Dash, 1 Psycho Slider, 2 Spin Dash) to the damage records below. Read by LoadAbilityDamageA; the loader turns each pointer into a record offset by subtracting the table base.

will_ability_damage_table [
  &ability_damage_psycho_dash   ;00
  &ability_damage_psycho_slider   ;01
  &ability_damage_spin_dash   ;02
]

---------------------------------------------
; Psycho Dash: $0000, level word $0B16, damage 5 (level 0) / 10 (level 1).

ability_damage_psycho_dash #0000160B050A

---------------------------------------------
; Psycho Slider: $0000, level word $0B18, damage 5 / 8.

ability_damage_psycho_slider #0000180B0508

---------------------------------------------
; Spin Dash: $0000, level word $0B1A, damage 4 / 7.

ability_damage_spin_dash #00001A0B0407
---------------------------------------------

; Freedan's three abilities: 3 word pointers (index 0 Dark Friar, 1 Aura Barrier, 2 Earthquaker) to the damage records below. Read by LoadAbilityDamageB.

freedan_ability_damage_table [
  &ability_damage_dark_friar   ;00
  &ability_damage_aura_barrier   ;01
  &ability_damage_earthquaker   ;02
]

---------------------------------------------
; Dark Friar: $0000, level word $0B1C, damage 5 / 8 / 12 (7 bytes, the only three-level record).

ability_damage_dark_friar #00001C0B05080C

---------------------------------------------
; Aura Barrier: $0000, level word $0B1E, damage 5 / 9.

ability_damage_aura_barrier #00001E0B0509

---------------------------------------------
; Earthquaker: $0000, level word $0B20, damage 0 / 7.

ability_damage_earthquaker #0000200B0007