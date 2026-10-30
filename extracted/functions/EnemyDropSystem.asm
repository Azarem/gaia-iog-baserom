; Enemy drop spawner for gems and heals (Bank 00, 57129-57340). What drops is a pickup carrying item id $83 to $86 of GiveItemToPlayer: 1, 2 or 5 gems, or a 5 HP heal.
; 
; === CALLER ===
; 
; StandardEnemyDefeatHandler reaches EnemyGemDropRouter when the defeated enemy's stat byte +3 (enemy-stats gemDropType) is nonzero and either this scene's reward flag $0300 is set or enemies remain (the last enemy of a scene whose reward is still unclaimed gets the stat reward instead of a gem). The router spawns one of three entries with SpawnListAppend (flags $0420, so the pickup inherits the dead enemy's position through CopyActorState): value 1 = SpawnDropGem1 (fixed $83), value 2 = SpawnDropGem2 (fixed $84), any other nonzero value (3) = SpawnDropByHpTier (random, see below).
; 
; === THE PICKUP ===
; 
; The actor carries its item id in chatPtr ($7F000A,X) and has the 'friendly' flag $0020 in its $10 (from the spawn flags). When the player overlaps it, combat_collision.InteractionDamage_NPCChat calls GiveItemToPlayer(chatPtr) and turns the actor into NpcDespawnStub. Ids: $83 = 1 gem, $84 = 2 gems, $85 = 5 gems (cap 999), $86 = hpToHeal += 5 (UpdateHUD refills 1 HP every 8 frames) plus the spark effect and SFX $22.
; Each entry also spawns a marked child, interaction_handlers.collect_handler_gem (flags $2700), which pulls the pickup toward the player while L / R is held. The pickup is the marked parent ($12 bit $0040 set by SpawnAfterMarked), so its Die also removes the child. Each body clears $10 bit $0400 that the $0420 spawn flags set (while it is set the pickup is excluded from the interaction pass, so it cannot be collected (measured: with the bit forced back on, the pickup was not collected in the 88 frames observed); why the spawn flags set it first is not traced).
; 
; === LIFETIME (spriteset_pickups_effects animation lists) ===
; 
; Gems: anim 4 / 5 / 6 (gems $83 / $84 / $85) for 10 passes (about 75 ticks each: a 60-tick still frame and 5 shimmer frames of 3 ticks, about 750 ticks), then the blink anim 9 / $0A / $0B for 150 passes (2 ticks each, about 300 ticks), then Die. Heal: anim $22 for 180 passes (2 ticks, about 360 ticks), then anim $35 for 60 passes (4 ticks, about 240 ticks), then Die.
; 
; === WEIGHTED DROP (SpawnDropByHpTier) ===
; 
; HP tier by the player's HP against max HP: HP <= max/4 uses table group $20, HP <= max/2 uses group $10, otherwise group 0. A random byte is compared against the group's four ascending thresholds (the last is $0100, so it always matches) and the first row whose threshold is above the byte gives the body to run. Probabilities of 256 outcomes:
; HP above half: $86 heal 5.9%, $85 5 gems 17.6%, $84 2 gems 36.3%, $83 1 gem 40.2%. HP between a quarter and a half: $85 9.8%, $83 19.9%, $86 30.1%, $84 40.2%. HP at or below a quarter: $84 4.7%, $83 15.2%, $85 29.7%, $86 50.4%. The heal becomes the likeliest drop when the player is low on HP.
---------------------------------------------

?INCLUDE 'interaction_handlers'
?INCLUDE 'spriteset_pickups_effects'

!playerMaxHp                    0ACA
!playerHp                       0ACE
!chatPtr                        7F000A

---------------------------------------------

; Drop type 1 (stat byte +3 = 1): the 1-gem pickup. Stages the enemy sprite sheet (palette 0) and the marked child collect_handler_gem, then continues in DropBodyGem1.

SpawnDropGem1 {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnAfterMarked] ( @interaction_handlers.collect_handler_gem, #$2700 ) ; Marked child collect_handler_gem (flags $2700): pulls the pickup toward the player on L / R; this actor's Die also removes it

; Body of the 1-gem pickup (item $83): sets chatPtr, clears $10 bit $0400, runs the shimmer and blink animations, then dies. Also the target of two table rows.

  DropBodyGem1:
    LDA #$0083            ; Item id $83 = 1 gem (given by GiveItemToPlayer on touch)
    STA $chatPtr, X
    LDA #$0400
    TRB $10               ; Clear $10 bit $0400 that the $0420 spawn flags set: the pickup cannot be collected while it is set (why it is set first is not traced)
    COP [StageSpriteLoop] ( #04, #0A ) ; Anim 4 for 10 passes: 60-tick still frame plus 5 shimmer frames per pass, about 750 ticks
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #96 ) ; Anim 9 for 150 passes: 2-tick blink per pass, about 300 ticks, then Die
    COP [AnimLoop]
    COP [Die]
}

---------------------------------------------
; Drop type 2 (stat byte +3 = 2): same setup as SpawnDropGem1, then continues in DropBodyGem2 (item $84, 2 gems).

SpawnDropGem2 {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnAfterMarked] ( @interaction_handlers.collect_handler_gem, #$2700 ) ; Same marked child as SpawnDropGem1

; Body of the 2-gem pickup (item $84): anim 5 for 10 passes, anim $0A for 150 passes, Die. Also the target of two table rows.

  DropBodyGem2:
    LDA #$0084            ; Item id $84 = 2 gems
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #05, #0A ) ; Same lifetime with anim 5 (10 passes) and anim $0A (150 passes)
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #96 )
    COP [AnimLoop]
    COP [Die]
}

---------------------------------------------
; Drop type 3 (any other nonzero stat byte): same setup, then chooses the body from drop_threshold_by_hp by HP tier and a random byte, and jumps to it with the RTS trick (PLX, PHA, RTS).

SpawnDropByHpTier {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnAfterMarked] ( @interaction_handlers.collect_handler_gem, #$2700 )
    LDA $playerMaxHp      ; HP tier: HP at or below max/4 selects table group $20
    LSR 
    LSR 
    CMP $playerHp
    BCC loc_00DF99
    LDA #$0020
    BRA loc_00DFAA

; Second HP test (HP above a quarter of max): HP at or below half of max takes group $10, otherwise group 0.

  loc_00DF99:
    LDA $playerMaxHp      ; HP above max/4: HP at or below max/2 selects group $10, otherwise group 0
    LSR 
    CMP $playerHp
    BCC loc_00DFA7
    LDA #$0010
    BRA loc_00DFAA

; HP above half of max: table group 0.

  loc_00DFA7:
    LDA #$0000

; Roll: keeps the group offset in $26, takes a random byte and scans the group's rows.

  loc_00DFAA:
    STA $26               ; $26 := byte offset of the 4-row group in drop_threshold_by_hp
    COP [RngByte]         ; A := random byte 0 to 255
    PHX 
    LDX $26
    LDY #$0002            ; At most 3 compares; the fourth row has threshold $0100 and always matches

; Scan loop: the first row whose threshold is above the random byte wins (at most 3 compares, the fourth row is $0100).

  loc_00DFB4:
    CMP $@drop_threshold_by_hp, X ; Random byte below the row's threshold selects the row; rows are 4 bytes apart
    BCC loc_00DFC1
    INX 
    INX 
    INX 
    INX 
    DEY 
    BPL loc_00DFB4

; Loads the chosen row's body address and subtracts 1 so that RTS lands on it.

  loc_00DFC1:
    LDA $@drop_threshold_by_hp+2, X ; Body address of the chosen row
    DEC 
    PLX 
    PHA                   ; Return-address jump: X is the actor slot again, push body-1 so the return below lands on the chosen body
    RTS 
}

---------------------------------------------
; Body of the 5-gem pickup (item $85). Not an entry point of its own: only the table reaches it, after SpawnDropByHpTier has done the setup.

DropBodyGem5 {
    LDA #$0085            ; Item id $85 = 5 gems; reached only through the table
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #06, #0A ) ; Same lifetime with anim 6 (10 passes) and anim $0B (150 passes)
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0B, #96 )
    COP [AnimLoop]
    COP [Die]

; Body of the heal pickup (item $86: hpToHeal += 5 and the spark effect): anim $22 for 180 passes, anim $35 for 60 passes, Die. Reached only through the table.

  DropBodyHeal5:
    LDA #$0086            ; Item id $86 = heal: GiveItemToPlayer adds 5 to hpToHeal and spawns the spark effect
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #22, #B4 ) ; Anim $22 for 180 passes (2 ticks each, about 360 ticks)
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #3C ) ; Anim $35 for 60 passes (4 ticks each, about 240 ticks), then Die
    COP [AnimLoop]
    COP [Die]
}

---------------------------------------------
; Weighted drop table: 3 groups (HP above half, HP between a quarter and a half, HP at or below a quarter) of 4 rows of { random-byte threshold, body address }, 16 bytes per group. The first row with threshold above the random byte wins. Percentages are in the block note.

drop_threshold_by_hp [
  gem-drop-threshold < #$000F, &DropBodyHeal5 >   ;00
  gem-drop-threshold < #$003C, &DropBodyGem5 >   ;01
  gem-drop-threshold < #$0099, &DropBodyGem2 >   ;02
  gem-drop-threshold < #$0100, &DropBodyGem1 >   ;03
  gem-drop-threshold < #$0019, &DropBodyGem5 >   ;04
  gem-drop-threshold < #$004C, &DropBodyGem1 >   ;05
  gem-drop-threshold < #$0099, &DropBodyHeal5 >   ;06
  gem-drop-threshold < #$0100, &DropBodyGem2 >   ;07
  gem-drop-threshold < #$000C, &DropBodyGem2 >   ;08
  gem-drop-threshold < #$0033, &DropBodyGem1 >   ;09
  gem-drop-threshold < #$007F, &DropBodyGem5 >   ;0A
  gem-drop-threshold < #$0100, &DropBodyHeal5 >   ;0B
]