; Hit switch (Bank 00, 51710-51778; formerly named floor_button): a solid, hit-triggered switch that raises one numbered event flag each time it is struck. It is not a pressure plate: the actor is solid (MarkSolidHere), so the player cannot stand on it, and the trigger is the engine's hit callback. The old text ('triggers puzzle state when the player or objects land on the plate', 'used in pyramid puzzle rooms') is wrong.
; 
; === INIT ===
; 
; actor-def <#00,#00,#01>. $24 := $0E (spawn type byte >> 1, the flag number), then $0E := $2000 (OAM attribute word, priority 2). statsPtr points at enemy_stats_table + $118 (the assembler's offset is hex), which is entry $46: HP $14, ATK $16, DEF $FF, type 0; the actor's currentHp is overwritten with $FF anyway. Metasprite spriteset_pickups_effects, frame $0F shown with AnimOnce, MarkSolidHere. $12 |= $0031: bit $0001 selects between the two post-hit invulnerability modes ($FFEF recovery vs $0011 invincibility in combat_collision; which one it picks was not traced), bit $0010 makes the victim stagger-immune, bit $0020 marks it as a boss so no damage digits are spawned (combat_collision).
; HitSwitchRearm (re-arm): currentHp := $FF, COP SetHitCallback ( &HitSwitchTriggered ), SetEntryHere, RTL. The actor then idles.
; 
; === WHEN HIT ===
; 
; combat_collision dispatches onHitCallback ($7F1000) after the hit damage: the callback pointer becomes the victim's entry address and onHitCallback is cleared, so the script below runs on the actor's next turn. HitSwitchTriggered: SetFlagRaw with A = $24 (the event-flag number, no base offset), frame $10 (assumed to be the pressed look; not viewed), AnimOnce, WaitByte #0F (16 ticks), frame $0F, AnimOnce, then BRA HitSwitchRearm which restores HP $FF and registers the callback again. The button can therefore be struck again after about 16 ticks plus two animation cycles.
; 
; === PLACEMENT AND FLAG READERS ===
; 
; Seven spawns, all in Great Wall scenes (the old docs say pyramid):
; 
; | Scene | Area | Position (tile) | Type byte | Flag | Reader of that flag |
; |-------|------|-----------------|-----------|------|---------------------|
; | 83 | great_wall/wall_dive | 35,1B | 03 | $01 | gw83_switch (WaitOnFlagByte $01, placed on the same tile) |
; | 85 | great_wall/wall_rampway | 18,1A | 03 | $01 | gw85_retractable_gate |
; | 85 | great_wall/wall_rampway | 3B,29 and 29,2B | 05 | $02 | gw85_short_switch_spear |
; | 85 | great_wall/wall_rampway | 37,2C | 07 | $03 | gw85_long_switch_spear |
; | 85 | great_wall/wall_rampway | 64,1D | 09 | $04 | gw85_multi_switch_spear |
; | 87 | scene 87 (no area folder in extracted/) | 2F,28 | 1F | $0F | none in the scene's spawn list |
; 
; The gw85 actors run WaitOnFlagByte ( #n, #01 ) followed by ClearFlagByte ( #n ), so in the rampway the flag is a one-shot trigger consumed by the gate or spear. gw83_switch waits on flag $01 and does not clear it. In scene 87 the flag $0F has no waiter among the scene's actors (the gw82_wall_spear actors it spawns use timers only); $0F is also used as an unrelated flag in Babel Tower and Freejia scripts (OQ-I042-3).
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'flag_helpers'
?INCLUDE 'spriteset_pickups_effects'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

hit_switch [
  actor-def < #00, #00, #01, {

; Init: flag number $24 := $0E, OAM attribute $2000, stats pointer at enemy_stats_table + $118, frame $0F, solid, $12 |= $0031, then fall into the re-arm step.

  HitSwitchInit:
    LDA $0E               ; Spawn type byte >> 1 = the event-flag number (1, 2, 3, 4 or $0F), kept in $24 for the hit callback
    STA $24
    LDA #$2000            ; OAM attribute word $2000 (priority 2, palette 0) replaces $0E
    STA $0E
    LDA #$&enemy_stats_table+118 ; Offset $118 = entry $46 of enemy_stats_table (HP $14, ATK $16, DEF $FF, type 0)
    STA $statsPtr, X
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #0F ) ; Frame $0F (resting), shown once
    COP [AnimOnce]
    COP [MarkSolidHere]   ; Solid: the player cannot walk onto the button
    LDA #$0031            ; $0001 iframe-mode select, $0010 stagger-immune, $0020 boss (no damage digits)
    TSB $12

; Re-arm: HP := $FF, register HitSwitchTriggered, SetEntryHere and idle with RTL. Reached from init and from the end of the callback.

  HitSwitchRearm:
    LDA #$00FF            ; Re-arm: currentHp := $FF (the button cannot be killed in practice)
    STA $currentHp, X
    COP [SetHitCallback] ( &HitSwitchTriggered ) ; Run HitSwitchTriggered when hit (onHitCallback is cleared on every dispatch)
    COP [SetEntryHere]    ; Re-enter here every frame; idle until hit
    RTL 
} >
]

---------------------------------------------
; Runs after a hit: set event flag $24, show frame $10 (assumed pressed look), wait 16 ticks (WaitByte #0F), show frame $0F again, then re-arm.

HitSwitchTriggered {
    LDA $24               ; Flag number from init; SetFlagRaw sets event flag A (no base offset)
    JSL $@flag_helpers.SetFlagRaw
    COP [StageSpriteFrame] ( #10 ) ; Frame $10 (assumed pressed look; not viewed)
    COP [AnimOnce]
    COP [WaitByte] ( #0F ) ; Hold for 16 ticks (WaitByte #0F)
    COP [StageSpriteFrame] ( #0F ) ; Back to the resting frame $0F
    COP [AnimOnce]
    BRA HitSwitchRearm    ; Re-arm
}