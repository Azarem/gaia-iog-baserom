; Gem / stat-item pickup spawned by the field-reveal events (Bank 00, 55928-56200): it drops to the floor, hops once, becomes a pullable pickup (collect_handler_gem child) and, if it is a gem, expires.
; 
; === SPAWN ===
; 
; SpawnAfterFlags ( field_reveal_object, #$0020 ) from EnemyDefeatDispatch (every kill but the last; the child's $26 = enemies remaining, nonzero), pyCC_mystic_ball (771837) and awB1_wall_walker (769369) (child $26 = 0). The spawn copies the spawner's position and statsPtr ($7F0020).
; 
; === WHICH PICKUP ===
; 
; - $26 nonzero, or the room's clear reward already taken (TestFlag_0300(sceneCurrent) set), or tier 0: FieldRevealFromActorStats reads the byte at +3 of the spawner's stat table. & 3 = 0 dies at once; 1 / 2 / 3 = a gem pickup with anim $04 / $05 / $06 and item $83 / $84 / $85 (1 / 2 / 5 gems, given by GiveItemToPlayer).
; - Otherwise enemy_clear_reward_table[sceneCurrent] & 3 picks the room's stat item: 1 / 2 / 3 = anim $0C / $0D / $0E (the sprites of e_hp / e_str / e_def_increase) and item $80 / $81 / $82 (Max HP / STR / DEF + 1). These paths also store $FFFF in orbitAngle (no reader found). Nothing here sets scene flag $0300 (reward_actors does for the last-kill reward).
; 
; === DROP AND LIFE ===
; 
; FieldRevealDrop stores the item id in chatPtr ($7F000A), remembers the spawn Y in $24 and sets $26 := 7 (the step budget). With Y aligned to a 16 px row it probes the tile with BranchIfSolidHere: while the tile is solid it moves one row (16 px) down, at most 8 rows, and stops early on a tile whose collision byte is $0E; after 8 failures the target is the spawn Y + 1. The target goes to moveXAlt / moveYAlt, the actor returns to its spawn Y, flies to the target (MoveToward, 4 px per frame), hops once (Y chain $45: -2, -2, -1, -1, 0, 0, +1, +1, +2, +2), waits 12 ticks (WaitByte #0B) and spawns collect_handler_gem (SpawnAfterMarked #$2300): holding L / R then pulls the pickup toward the player.
; It then animates in 100-frame blocks. A stat item (anim $0C-$0E, at least 8) repeats forever. A gem (anim $04-$06) switches to anim + 5 after the first block (the blink animations $09 / $0A / $0B, inferred), plays 10 more frames and falls into FieldRevealDieEmpty (Die): a gem lives about 110 frames.
; 
; The flag means 'this room's reward is already taken', and only the tier path stages stat items; the gem path stages gems.
---------------------------------------------

?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'flag_helpers'
?INCLUDE 'interaction_handlers'
?INCLUDE 'spriteset_pickups_effects'

!sceneCurrent                   0644
!chatPtr                        7F000A
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!collisionLayer                 7FC000

---------------------------------------------

; Entry: metasprite spriteset_pickups_effects, palette 0, clear the ForceDir bits ($6000 of $12). Choose the pickup: $26 nonzero or scene flag $0300 set -> FieldRevealFromActorStats; else the room's tier selects a stat item (0 -> FieldRevealFromActorStats). See the block note.

field_reveal_object {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetSpritePalette] ( #00 )
    LDA #$6000
    TRB $12               ; Clear the ForceDir bits ($6000 of $12)
    LDA $26               ; $26 nonzero = spawned by EnemyDefeatDispatch (enemies remaining): use the spawner's stats
    BNE FieldRevealFromActorStats
    LDA $sceneCurrent
    JSL $@flag_helpers.TestFlag_0300 ; Room's clear reward already taken (scene flag $0300 + scene)? Then use the spawner's stats
    BCS FieldRevealFromActorStats
    LDY $sceneCurrent
    LDA $&enemy_clear_reward_table, Y ; Tier of this scene (0 none, 1 / 2 / 3 = Max HP / STR / DEF)
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &field_reveal_tier_cases ) ; Case index in $0000: 0 -> FieldRevealFromActorStats, 1 / 2 / 3 -> the stat items below
}

---------------------------------------------
; SwitchCase table on the room's reward tier (enemy_clear_reward_table & 3): 0 -> FieldRevealFromActorStats, 1 / 2 / 3 -> the Hidden sprite A / B / C stat items.

field_reveal_tier_cases [
  &FieldRevealFromActorStats   ;00
  &FieldRevealStatItemHp   ;01
  &FieldRevealStatItemStr   ;02
  &FieldRevealStatItemDef   ;03
]

---------------------------------------------
; Tier 1: anim $0C (Max HP item sprite), item id $80 = Max HP + 1.

FieldRevealStatItemHp {
    COP [StageSprAndHitbox] ( #0C )
    LDA #$FFFF
    STA $orbitAngle, X    ; orbitAngle := $FFFF (no reader found)
    LDA #$0080            ; Item $80 = Max HP + 1 (GiveItemToPlayer)
    BRA FieldRevealDrop
}

---------------------------------------------
; Tier 2: anim $0D (STR item sprite), item id $81 = STR + 1.

FieldRevealStatItemStr {
    COP [StageSprAndHitbox] ( #0D )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0081            ; Item $81 = STR + 1
    BRA FieldRevealDrop
}

---------------------------------------------
; Tier 3: anim $0E (DEF item sprite), item id $82 = DEF + 1.

FieldRevealStatItemDef {
    COP [StageSprAndHitbox] ( #0E )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0082            ; Item $82 = DEF + 1
    BRA FieldRevealDrop
}

---------------------------------------------
; Read the byte at +3 of the spawner's stat table (statsPtr, copied by the spawn); & 3 selects: 0 -> FieldRevealDieEmpty, 1 / 2 / 3 -> the gem pickups below.

FieldRevealFromActorStats {
    LDA $statsPtr, X      ; statsPtr = the spawner's stat table pointer (copied by the spawn)
    TAY 
    LDA $0003, Y          ; Byte +3 & 3: 0 none, 1 / 2 / 3 = gem pickup
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &field_reveal_gem_cases )
}

---------------------------------------------
; SwitchCase table on the stat-table byte & 3: 0 -> FieldRevealDieEmpty, 1 / 2 / 3 -> the gem pickup A / B / C.

field_reveal_gem_cases [
  &FieldRevealDieEmpty   ;00
  &FieldRevealGem1   ;01
  &FieldRevealGem2   ;02
  &FieldRevealGem5   ;03
]

---------------------------------------------
; Gem pickup 1: anim $04, item id $83 = 1 gem.

FieldRevealGem1 {
    COP [StageSprAndHitbox] ( #04 )
    LDA #$0083            ; Item $83 = 1 gem
    BRA FieldRevealDrop
}

---------------------------------------------
; Gem pickup 2: anim $05, item id $84 = 2 gems.

FieldRevealGem2 {
    COP [StageSprAndHitbox] ( #05 )
    LDA #$0084            ; Item $84 = 2 gems
    BRA FieldRevealDrop
}

---------------------------------------------
; Gem pickup 3: anim $06, item id $85 = 5 gems.

FieldRevealGem5 {
    COP [StageSprAndHitbox] ( #06 )
    LDA #$0085            ; Item $85 = 5 gems

; Common tail: item id -> chatPtr, spawn Y -> $24, step budget $26 := 7, Y aligned to a 16 px row, then probe for the landing row (FieldRevealDropProbe).

  FieldRevealDrop:
    STA $chatPtr, X       ; Item id for the pickup ($7F000A, given by GiveItemToPlayer when the player touches it)
    LDA $16
    STA $24               ; Remember the spawn Y
    LDA #$0007
    STA $26               ; $26 := 7: step budget for the downward probe (8 tries)
    LDA $16
    AND #$FFF0            ; Align Y to a 16 px row
    STA $16
    BRA FieldRevealDropProbe

; The probed tile is solid: spend one step ($26); when the budget is gone the target is spawn Y + 1, otherwise check the collision byte and move down one row.

  FieldRevealDropStep:
    DEC $26
    BPL FieldRevealDropCheckType
    LDA $24
    INC 
    STA $16
    BRA FieldRevealLaunch

; Budget left: collision byte $0E at the probed tile ends the scan here; anything else moves the probe one row (16 px) down.

  FieldRevealDropCheckType:
    PHX 
    TYX 
    LDA $collisionLayer, X ; Collision byte of the probed tile (Y = map index left by the probe)
    PLX 
    AND #$00FF
    CMP #$000E            ; Collision byte $0E ends the scan at this row (its meaning is not traced)
    BEQ FieldRevealLaunch
    LDA $16
    CLC 
    ADC #$0010            ; One row down
    STA $16

; Probe the tile at the actor position: solid -> FieldRevealDropStep (next row), free -> fall through to the launch.

  FieldRevealDropProbe:
    COP [BranchIfSolidHere] ( &FieldRevealDropStep ) ; Solid tile (or out of bounds): go to the step logic; free tile: continue

; Landing row found: target = (X, Y), return to the spawn Y, fly there, hop (Y chain $45), wait 12 ticks (WaitByte #0B), spawn the collect handler.

  FieldRevealLaunch:
    LDA $16
    STA $moveYAlt, X      ; Target Y = the landing row
    LDA $14
    STA $moveXAlt, X      ; Target X = the current X
    LDA $24
    STA $16               ; Back to the spawn Y; the drop is animated by MoveToward below
    COP [MoveToward] ( #FF, #04 ) ; Move to moveXAlt / moveYAlt at 4 px per frame
    COP [StageMoveXY] ( #00, #45 ) ; X chain 0 (none), Y chain $45: one hop (-2, -2, -1, -1, 0, 0, +1, +1, +2, +2)
    COP [WaitByte] ( #0B ) ; WaitByte #0B = 12 ticks: the hop plays out
    COP [SpawnAfterMarked] ( @interaction_handlers.collect_handler_gem, #$2300 ) ; Marked child collect_handler_gem (flags $2300): L / R pulls the pickup toward the player; it dies with this actor

; Life loop: 100 frames per block. Anim index >= 8 (stat items) repeats the block forever; a gem takes anim + 5 for 10 more frames and then dies in FieldRevealDieEmpty.

  FieldRevealLifeLoop:
    COP [LoopStart] ( #64 ) ; 100 frames per block
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
    LDA $28               ; Anim index: stat items (>= 8) repeat the block forever
    CMP #$0008
    BCS FieldRevealLifeLoop
    CLC 
    ADC #$0005            ; Gems: anim + 5 (blink, inferred) for 10 more frames, then Die
    STA $28
    COP [LoopStart] ( #0A )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
}

---------------------------------------------
; Die. Also the end of the gem's life: the script above runs into it after its last LoopEnd.

FieldRevealDieEmpty {
    COP [Die]
}