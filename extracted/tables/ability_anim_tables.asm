; Attack ability animation configuration for both player forms. Contains will_ability_anim_table (Psycho Dash/Slider/Spin Dash) and freedan_ability_anim_table (Dark Friar/Aura Barrier/Earthquaker). Each entry is a sprite frame/hitbox/timing config loaded by the attack ability system.
---------------------------------------------

?BANK 01

---------------------------------------------

; Animation configuration for Will's 3 attack abilities. Each entry is a 6-byte record with sprite frame indices, hitbox dimensions, and timing data stored to climbStateData registers ($09E0/$09E2). Index 0 = Psycho Dash, 1 = Psycho Slider, 2 = Spin Dash. Referenced by LoadAbilityAnimTableA in attack_ability_system.asm.

will_ability_anim_table [
  &binary_01D9AD   ;00
  &binary_01D9B3   ;01
  &binary_01D9B9   ;02
]

binary_01D9AD #0000160B050A

binary_01D9B3 #0000180B0508

binary_01D9B9 #00001A0B0407
---------------------------------------------

; Animation configuration for Freedan's 3 attack abilities. Same structure as will_ability_anim_table. Index 0 = Dark Friar, 1 = Aura Barrier, 2 = Earthquaker. Referenced by LoadAbilityAnimTableB in attack_ability_system.asm.

freedan_ability_anim_table [
  &binary_01D9C5   ;00
  &binary_01D9CC   ;01
  &binary_01D9D2   ;02
]

binary_01D9C5 #00001C0B05080C

binary_01D9CC #00001E0B0509

binary_01D9D2 #0000200B0007