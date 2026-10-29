; Main player character actor definition and movement state machine (181132–184272).
; 
; This is the largest player actor file — the actor-def that instantiates the player and contains the complete movement FSM, traversal systems (climbing, ladders, shimmy), combat (melee, run attack, lunge), and related helpers. The actor-def's init code spawns four companion actors: attack_ability_system (charged attacks), player_move_controller (per-frame physics), slope_ramp_physics (slope tile handling), and shadow_shimmer (Shadow's palette shimmer).
; 
; === BUTTON AND FLAG CONVENTIONS USED IN THIS FILE ===
; Logical button masks (after the remap): attack $0080, use-item $0008, L $0020, R $0010 (L/R together $0030), D-pad $0F00 (R $0100, L $0200, Dn $0400, Up $0800). BranchIfPressed/BranchIfNotPressed take a mask word: bit 0 clear tests joypadCurrent (held buttons minus the ones consumed in joypadHeld or hidden by joypadMaskStd), bit 0 set tests joypadRaw (no consumption, no masking). TSB joypadHeld therefore CONSUMES a button (joypadCurrent stops reporting it); it does not inject one. TSB joypadMaskStd with $CFFC hides everything except Start/Select ($3000) and bits 0-1 from joypadCurrent, D-pad included; the ladder and shimmy code reads Up/Down through joypadRaw masks such as $0801 / $0401.
; Actor flag word $10 (this file): $0008 normal collision-aware movement (cleared while climbing, restored on exit), $0020 block marker (set by the block loop, cleared by PlayerIdleEntry), $0080 hit-reaction counter active (actor_execution), $0200 set while the Psycho Slider and the lunge run, $4000 off-screen (set by sprite_composition). The meaning of $0100 and $2000 for the player is not traced.
; 
; 1. CORE IDLE + WALKING (181132–181790)
;    PlayerCharacterDef, PlayerIdleEntry, PlayerIdleDispatchTable, IdleStand* (8 directional × Shadow variants), WalkSouth/North/West/East, CheckAttackWhileWalking, WalkAbortToIdle, WalkRestoreSaved, SetAutoWalkTimer.
;    The idle dispatch uses a facing × input matrix: GetPlayerFacing (0–3) × Multiply8x8Unsigned by 14 selects a row of 7 entries in PlayerIdleDispatchTable. Input priority: attack button > D-pad cardinal > L/R block > idle stand.
;    Walk pieces stage the walk sprite (#08–#0B) and call SetAutoWalkTimer, which writes 13 to $040C (mnemonic invincibilityTimer; UpdateFrameCounters decrements it every frame, $FFFF = closed). A walk entered while the player already faces that way (PlayerIdleEntry leaves the facing index in $24) with the window still open ($040C >= 0) closes the window, sets the axis speed to ±3 and yields once before re-dispatching: a run start. docs/ram_map.txt describes $040C the same way ("running-allowed timer"); the invincibilityTimer mnemonic name is stale. Holding L/R during a walk enters the block stance unless playerFlags $1000 (on slope) is set.
; 
; 2. VINE CLIMBING (181790–182198)
;    ClimbVineEntry, ClimbVineLand, CheckClimbFrame, CheckClimbAttack, ClimbDropAttack, ClimbDropLand, ImpactTerrainShake, CameraShakeActor, CameraShakeFrame.
;    Freedan-only vine climbing with a 3-frame alternating sprite cycle. CheckClimbAttack gates drop attack to Freedan (form 1) with abilityBitmask bit 6 ($0040). ClimbDropLand spawns ImpactTerrainShake (sets playerFlags $0010 for 480 ticks, WaitWord #$01DF) and CameraShakeActor (about 60 frames of random camera-target offsets: (RNG & 3) - 1 on X and ((RNG >> 2) & 3) - 1 on Y, each -1..+2).
; 
; 3. LADDER SYSTEM (182198–182461)
;    LadderClimbSouth/North, LadderMoveDown/Up, LadderIdleSouth/North (+ Shadow variants), LadderLandBottom, LadderReachTop.
;    Bi-directional ladder traversal. Entry sets joypadMaskStd |= $CFFC (all of joypadCurrent hidden except Start/Select) and reads Up/Down through raw masks ($0801 / $0401); exit clears the same bits. LadderMoveDown/Up check solid tiles at 16-pixel boundaries for exit transitions. Idle poses have Shadow-specific sprites (flag byte #00 == $01).
; 
; 4. SHIMMY SYSTEM (182461–182818)
;    ShimmyRightEntry, ShimmyRightCheckWall, ShimmyRightLoop, ShimmyRightUpCheck, ShimmyRightDownCheck, ShimmyLeftEntry, ShimmyLeftCheckWall, ShimmyLeftLoop, ShimmyLeftUpCheck, ShimmyLeftDownCheck, ShimmyDetachRight/Left (+ Shadow variants), ShimmyTopCorner.
;    Horizontal wall shimmy with wall-contact detection at 8-pixel intervals. CheckWall verifies east/west solid tiles before allowing movement. Detach states listen for L/R to re-enter shimmy or up/down for corner transitions. ShimmyTopCorner restores normal movement and returns to idle.
; 
; 5. BLOCKING + INERTIAL MOVEMENT (182818–183186)
;    BlockFromWalkSouth/North/West/East, BlockSouth/North/West/East, BlockStopToIdle, MovingEastWest, MovingNorthSouth.
;    L/R shoulder triggers block stance (playerFlags $2000, actor flag $0020, actor flag $0100 cleared, $040C zeroed). BlockFromWalk* pieces consume the matching D-pad bit in joypadHeld (so the held direction no longer reads as a new walk) before falling into Block*. MovingEastWest/NorthSouth handle inertial deceleration animations — entered from PlayerIdleEntry when speed is nonzero but no matching D-pad is held.
; 
; 6. PSYCHO SLIDER / RUN ATTACK (183186–183514)
;    CheckRunAttack, RunAttackSpeedCheck, SpeedThresholdEW, SpeedThresholdNS, RunAttackNS, RunAttackEW, FreezeCameraForAttack, RunAttackFlagSetup, UnfreezeCameraAfterAttack, RunAttackCleanup.
;    The Psycho Slider — Will's running slide attack (abilityBitmask bit 1, $0002). Acquired in Mu West (scene $62). While moving at |speed| >= 3, pressing attack ($0080) initiates a damaging slide that can pass through narrow passages. RunAttackSpeedCheck routes to EW or NS based on which axis has sufficient speed. Both directions use LoadAbilityDamageA entry 1, stage a looping sprite move, then clean up flags. FreezeCameraForAttack / UnfreezeCameraAfterAttack are entered from attack_ability_system only; they set and clear layerPriorityFlag $0200, the bit that freezes camera_scroll_controller.
; 
; 7. BASIC MELEE ATTACK (183514–184138)
;    AttackSouth/North/West/East, AttackRedirect, AttackFinish, AttackInit.
;    Directional melee for all character forms. AttackInit keeps only the D-pad bits of joypadCurrent, sets joypadHeld = D-pad | attack (both consumed) and plays form-specific SFX (Will=#01, Freedan/Shadow=#02); each Attack* then consumes its own direction bit. Freedan (form 1) checks for wall-adjacent push attack variants on the south/north sides (BranchIfSolid*, sprites #48/#49); the west/east push sprites (#42/#43) are used by Will and Freedan, not Shadow. Will (form 0) can redirect mid-attack with BranchIfPressed on every D-pad direction except the facing one (south $0B00, north $0700), and continue into the lunge by pressing the facing direction. Scene $00E8 (Dark Gaia fight) spawns a Projectile* actor alongside each melee swing.
; 
; 8. LUNGE + PROJECTILES (184138–184272)
;    RangedAttackSouth/North/West/East, RangedSetForceX/Y, ProjectileSouth/North/West/East.
;    The Ranged* pieces are a Will-only follow-up lunge, not a projectile launch: RangedSetForce* stages force move #46 (six frames of 0, 19 of 3, 4 of 1, then 0), sets playerFlags $0800, climbStateData = 1 (the Will ability damage bonus combat_collision adds), actor flag $0200 and extendedFlags $0040 (the bounce flag tile_collision_physics reads); the exits clear $0200 and $0040 again. North and west add the direction-negate bits $2000 / $4000 to $12 so the same curve runs in the opposite direction. The Projectile* actors are spawned only by the Attack* pieces in scene $E8 (flags $0602); they use the spriteset_darkgaia_projectile metasprite with a two-phase animation (initial + looping) and die when bit $4000 of $10 (off-screen) is set.
---------------------------------------------

?BANK 02

?INCLUDE 'attack_ability_system'
?INCLUDE 'game_over_sequence'
?INCLUDE 'hardware_math'
?INCLUDE 'player_move_controller'
?INCLUDE 'shadow_shimmer'
?INCLUDE 'slope_ramp_physics'
?INCLUDE 'spriteset_darkgaia_projectile'

!invincibilityTimer             040C
!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!climbStateData                 09E0
!abilityBitmask                 0AA2
!characterForm                  0AD4
!gameOverWakeupFlag             0AF8
!free101C                       7F101C

---------------------------------------------

; Player character actor definition table and initialization code.
; 
; The actor-def header (#00, #08, #85) defines the actor type. The inline init code:
; 1. Sets $0100 in actor flags $10 and $0001 in $12 (meaning of both bits not traced)
; 2. Stores the current actor slot as playerActor ($09AA)
; 3. Sets the free101C marker to signal the player actor is active
; 4. Checks the game-over wakeup flag ($0AF8) — spawns DeathWakeupMessage if set
; 5. Spawns four companion actors: attack_ability_system (SpawnBefore), player_move_controller and slope_ramp_physics (SpawnAfter), shadow_shimmer (SpawnListAppend, flags $2800)
; 
; These companions handle combat, physics, slope detection, and Shadow's palette shimmer respectively. The player character actor itself handles only the movement state machine.

PlayerCharacterDef [
  actor-def < #00, #08, #85, {

  code_02C38F:
    LDA #$0100            ; Init: set $0100 in actor flags $10 and $0001 in $12 (meaning of both bits not traced), then store the actor slot as playerActor
    TSB $10
    LDA #$0001
    TSB $12
    TXA 
    STA $playerActor
    LDA #$0001
    STA $free101C, X      ; Set free101C marker — signals player actor is active
    LDA $gameOverWakeupFlag ; Check $0AF8 (game-over wakeup flag) — spawn DeathWakeupMessage if set
    BEQ loc_02C3B0
    COP [SpawnAfterFlags] ( @game_over_sequence.DeathWakeupMessage, #$2000 )

  loc_02C3B0:
    COP [SpawnBefore] ( @attack_ability_system.AttackSystemEntry ) ; Spawn attack_ability_system.AttackSystemEntry as SpawnBefore companion (runs before player each frame)
    COP [SpawnAfter] ( @player_move_controller.PlayerMoveController ) ; Spawn player_move_controller as SpawnAfter companion (physics/collision processing)
    COP [SpawnAfter] ( @slope_ramp_physics.SlopePhysicsEntry ) ; Spawn slope_ramp_physics as SpawnAfter companion (slope tile handling)
    COP [SpawnListAppend] ( @shadow_shimmer.ShadowShimmerInit, #00, #00, #$2800 ) ; Spawn shadow_shimmer with SpawnListAppend (appended at the actor list end) (Shadow palette shimmer, dies if not form 2)
} >
]

---------------------------------------------
; Main idle state entry and input dispatch loop.
; 
; Clears transient state: the D-pad bits of joypadHeld ($F0FF mask, so held directions are re-detected), playerFlags $2800 (block and script/ability lock), actor flag $0020 (the block marker) and climbStateData; sets actor flag $0100 again. Returns at once when bit $2000 of actor flags $10 is set (SortActorsByDepth treats that bit as hidden; who sets it on the player is not traced).
; 
; Saves itself as the return point via SetSavedPtr, clears force movement. Checks for residual speed — if nonzero, jumps to MovingEastWest or MovingNorthSouth for inertial deceleration.
; 
; If no residual speed, computes a dispatch index: GetPlayerFacing (0=S, 1=N, 2=W, 3=E, also left in $24) × 14 via Multiply8x8Unsigned → row offset into PlayerIdleDispatchTable. Then scans joypadCurrent in priority order: attack button > D-pad cardinal (S/N/W/E) > L/R block > idle stand. The resulting 2-byte address is loaded from the table and executed via the DEC+PHA+RTS trick.

PlayerIdleEntry {
    COP [SetEntryHere]    ; Main idle entry — clears transient flags and dispatches to walk/block/attack/stand based on input
    LDA $joypadHeld       ; Clear directional held bits ($0F00) from joypadHeld — prevents stale D-pad state from previous frame
    AND #$F0FF
    STA $joypadHeld
    LDA #$2800            ; Clear playerFlags $2800: the script/ability lock $0800 and the guard / Spin Dash stance $2000
    TRB $playerFlags
    LDA #$0100            ; Set $0100 in actor flags $10 again: block, attack and run-attack code clear it (meaning not traced)
    TSB $10
    LDA #$0020            ; Clear $0020 in actor flags $10: the marker the block loop sets (the Psycho Slider marker is $0200, cleared by RunAttackCleanup)
    TRB $10
    STZ $climbStateData   ; Zero climbStateData ($09E0), the Will ability damage bonus that the lunge sets to 1
    LDA $10               ; Bit $2000 of $10: SortActorsByDepth skips actors with it set; idle then yields without acting (who sets it on the player is not traced)
    BIT #$2000
    BEQ loc_02C3EE
    RTL 

  loc_02C3EE:
    COP [SetSavedPtr] ( &PlayerIdleEntry ) ; Save PlayerIdleEntry as return point and clear force movement
    COP [SetMoveNegateXY] ( #00 )
    LDA $playerSpeedEw    ; Check for residual EW speed — if nonzero, enter MovingEastWest for deceleration
    BEQ loc_02C3FD
    JMP $&MovingEastWest

  loc_02C3FD:
    LDA $playerSpeedNs    ; Check for residual NS speed — if nonzero, enter MovingNorthSouth for deceleration
    BEQ loc_02C405
    JMP $&MovingNorthSouth

  loc_02C405:
    PHX                   ; No residual speed — compute dispatch index from facing × input matrix
    COP [GetPlayerFacing] ; Get player facing (0=S, 1=N, 2=W, 3=E) for dispatch table row selection
    AND #$0003
    STA $24
    SEP #$20              ; Switch to 8-bit; multiply facing by 14 (7 entries × 2 bytes) via hardware math to get row offset
    XBA 
    LDA #$0E
    JSL $@hardware_math.Multiply8x8Unsigned
    REP #$20
    TAX 
    LDA $joypadCurrent    ; Read joypad state; scan input priority: attack > D-pad (S/N/W/E) > L/R block > idle stand
    BIT #$0080
    BNE loc_02C43F
    INX 
    INX 
    XBA 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    BIT #$0300
    BNE loc_02C43F
    INX 
    INX 

  loc_02C43F:
    LDA $@PlayerIdleDispatchTable, X ; Load dispatch handler address from PlayerIdleDispatchTable and execute via RTS trick
    PLX 
    DEC 
    PHA 
    RTS 
}

---------------------------------------------
; 7-entry × 4-direction idle dispatch table (28 entries, 56 bytes).
; 
; Indexed by (facing × 7 + input_priority). Each row of 7 entries: [Attack, WalkEast, WalkWest, WalkSouth, WalkNorth, Block, IdleStand]. The facing direction determines which row is used, and the input scan priority determines the column.

PlayerIdleDispatchTable [
  &AttackSouth   ;00
  &WalkEast   ;01
  &WalkWest   ;02
  &WalkSouth   ;03
  &WalkNorth   ;04
  &BlockSouth   ;05
  &IdleStandSouth   ;06
  &AttackNorth   ;07
  &WalkEast   ;08
  &WalkWest   ;09
  &WalkSouth   ;0A
  &WalkNorth   ;0B
  &BlockNorth   ;0C
  &IdleStandNorth   ;0D
  &AttackWest   ;0E
  &WalkEast   ;0F
  &WalkWest   ;10
  &WalkSouth   ;11
  &WalkNorth   ;12
  &BlockWest   ;13
  &IdleStandWest   ;14
  &AttackEast   ;15
  &WalkEast   ;16
  &WalkWest   ;17
  &WalkSouth   ;18
  &WalkNorth   ;19
  &BlockEast   ;1A
  &IdleStandEast   ;1B
]

IdleStandSouth {
    COP [BranchOnFlagByte] ( #00, #01, &IdleStandSouthShadow ) ; South idle: check Shadow flag byte → select normal (#00) or Shadow (#10) sprite
    COP [StagePlayerSprite] ( #00 )
    BRA loc_02C4BD
}

IdleStandSouthShadow {
    COP [StagePlayerSprite] ( #10 ) ; Shadow south idle sprite (#10)
    BRA loc_02C4BD
}

IdleStandNorth {
    COP [BranchOnFlagByte] ( #00, #01, &IdleStandNorthShadow ) ; North idle: normal (#01) or Shadow (#11) sprite
    COP [StagePlayerSprite] ( #01 )
    BRA loc_02C4BD
}

IdleStandNorthShadow {
    COP [StagePlayerSprite] ( #11 ) ; Shadow north idle sprite (#11)
    BRA loc_02C4BD
}

IdleStandWest {
    COP [BranchOnFlagByte] ( #00, #01, &IdleStandWestShadow ) ; West idle: normal (#02) or Shadow (#12) sprite
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C4BD
}

IdleStandWestShadow {
    COP [StagePlayerSprite] ( #12 ) ; Shadow west idle sprite (#12)
    BRA loc_02C4BD
}

IdleStandEast {
    COP [BranchOnFlagByte] ( #00, #01, &IdleStandEastShadow ) ; East idle: normal (#03) or Shadow (#13) sprite
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02C4BD
}

IdleStandEastShadow {
    COP [StagePlayerSprite] ( #13 ) ; Shadow east idle sprite (#13)

  loc_02C4BD:
    COP [AnimOneFrame]    ; Shared idle animation loop — animate, check for speed or any button press to exit idle
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $playerSpeedEw    ; Check if player has started moving (speed nonzero) → restore saved ptr to re-dispatch
    ORA $playerSpeedNs
    BNE IdleAnimReturn
    COP [BranchIfPressed] ( #$0FB0, &IdleAnimReturn ) ; Attack ($0080), D-pad ($0F00) or L/R ($0030) down and not consumed (mask $0FB0, bit 0 clear = joypadCurrent) -> back to idle re-dispatch
    DEC $24
    BMI loc_02C4BD
    RTL 
}

IdleAnimReturn {
    COP [RestoreSavedPtr] ; Return from idle animation — restore saved ptr to re-enter PlayerIdleEntry
}

WalkSouth {
    LDA $24               ; South walk: $24 = facing from PlayerIdleEntry (0 = south); a run start needs facing south already and the $040C window open (>= 0)
    BNE loc_02C4F9
    LDA $invincibilityTimer
    BMI loc_02C4F9
    STZ $invincibilityTimer ; Close the $040C window (a run window, not invincibility)
    LDA #$0003
    STA $playerSpeedNs    ; Run start: NS speed +3 (RunAttackSpeedCheck accepts |speed| >= 3)
    STZ $slopeStepCounter ; Reset the slope-step and decel-step counters, yield one tick, then RestoreSavedPtr re-dispatches idle with the speed set
    STZ $decelStepCounter
    COP [SetEntryHereAndYield]
    COP [RestoreSavedPtr]

  loc_02C4F9:
    COP [StagePlayerSprite] ( #08 ) ; Plain south walk sprite #08 (the path taken when the run start is skipped)
    JSR $&SetAutoWalkTimer ; Open the 13-frame $040C window (repeat the faced direction inside it to start a run)

  loc_02C4FF:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C4FF
    COP [BranchIfNotPressed] ( #$0400, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C51F
    COP [BranchIfPressed] ( #$0030, &BlockSouth )

  loc_02C51F:
    DEC $24
    BMI loc_02C4FF
    RTL 
}

WalkNorth {
    LDA $24               ; North walk: run start needs facing north already ($24 = 1) and the $040C window open; speed -3
    DEC 
    BNE loc_02C541
    LDA $invincibilityTimer
    BMI loc_02C541
    STZ $invincibilityTimer ; Close the $040C window
    LDA #$FFFD
    STA $playerSpeedNs    ; Run start: NS speed -3
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryHereAndYield]
    COP [RestoreSavedPtr]

  loc_02C541:
    COP [StagePlayerSprite] ( #09 ) ; Plain north walk sprite #09
    JSR $&SetAutoWalkTimer

  loc_02C547:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C547
    COP [BranchIfNotPressed] ( #$0800, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C567
    COP [BranchIfPressed] ( #$0030, &BlockNorth )

  loc_02C567:
    DEC $24
    BMI loc_02C547
    RTL 
}

WalkWest {
    LDA $24               ; West walk: run start needs facing west already ($24 = 2) and the $040C window open; EW speed -3
    DEC 
    DEC 
    BNE loc_02C58A
    LDA $invincibilityTimer
    BMI loc_02C58A
    STZ $invincibilityTimer ; Close the $040C window
    LDA #$FFFD
    STA $playerSpeedEw    ; Run start: EW speed -3
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryHereAndYield]
    COP [RestoreSavedPtr]

  loc_02C58A:
    COP [StagePlayerSprite] ( #0A ) ; Plain west walk sprite #0A
    JSR $&SetAutoWalkTimer

  loc_02C590:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C590
    COP [BranchIfNotPressed] ( #$0200, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5B0
    COP [BranchIfPressed] ( #$0030, &BlockWest )

  loc_02C5B0:
    DEC $24
    BMI loc_02C590
    RTL 
}

WalkEast {
    LDA $24               ; East walk: run start needs facing east already ($24 = 3) and the $040C window open; EW speed +3
    DEC 
    DEC 
    DEC 
    BNE loc_02C5D4
    LDA $invincibilityTimer
    BMI loc_02C5D4
    STZ $invincibilityTimer ; Close the $040C window
    LDA #$0003
    STA $playerSpeedEw    ; Run start: EW speed +3
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryHereAndYield]
    COP [RestoreSavedPtr]

  loc_02C5D4:
    COP [StagePlayerSprite] ( #0B ) ; Plain east walk sprite #0B
    JSR $&SetAutoWalkTimer

  loc_02C5DA:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C5DA
    COP [BranchIfNotPressed] ( #$0100, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5FA
    COP [BranchIfPressed] ( #$0030, &BlockEast )

  loc_02C5FA:
    DEC $24
    BMI loc_02C5DA
    RTL 
}

---------------------------------------------
; Check for attack or speed-zero conditions during walking.
; 
; Called via JSR from WalkSouth/North/West/East per-frame loops. Checks:
; 1. Attack button (mask $0080) down → WalkAbortToIdle (pop return, restore saved ptr)
; 2. Both EW and NS speed zeroed (external stop) → WalkAbortToIdle
; 3. If neither: test playerFlags bit 12 ($1000, on-slope flag) and return the result in Z
; 
; Returns: Z = 0 means the on-slope flag is set, and every caller then branches over its L/R block check (BNE); Z = 1 (not on a slope) lets the caller test L/R for the block stance.

CheckAttackWhileWalking {
    COP [BranchIfPressed] ( #$0080, &WalkAbortToIdle ) ; Attack button down (mask $0080) -> abort the walk; zero speed on both axes below aborts it too
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE WalkAbortToIdle
    LDA $playerFlags
    BIT #$1000            ; Z = 0 when playerFlags $1000 (on slope) is set; every caller then skips its L/R block check
    RTS 
}

WalkAbortToIdle {
    PLA                   ; Pop walk return address — falls through to WalkRestoreSaved
}

WalkRestoreSaved {
    COP [RestoreSavedPtr] ; Restore saved ptr after walk ends — returns to PlayerIdleEntry for re-dispatch
}

SetAutoWalkTimer {
    LDA #$000D            ; Open the $040C window for 13 frames: repeating the faced direction before it expires starts a run
    STA $invincibilityTimer
    RTS 
}

---------------------------------------------
; Vine climbing state machine — Freedan-only traversal system.
; 
; Entry: clear actor flag $0008 (restored by ClimbVineLand), set actor flag $0200, hide the use-item button ($0008) via joypadMaskStd. Plays initial climb-on animation (sprites #18, #19).
; 
; Main loop: 3-sprite alternating cycle (#1A, #1B, #19) with force Y movement (#07 = downward). Each frame checks for solid ground landing. CheckClimbFrame reads the $2A event flag for animation timing. CheckClimbAttack gates drop attack to Freedan (characterForm == 1) with abilityBitmask bit 6 ($0040).

ClimbVineEntry {
    LDA #$0008            ; Vine entry: clear $0008 in actor flags (ClimbVineLand restores it), set $0200, then hide the use-item button via joypadMaskStd
    TRB $10
    LDA #$0200
    TSB $10
    LDA #$0008
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #18, #00, #18 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]

  loc_02C63B:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand ) ; Check solid type below for landing; begin 3-sprite alternating climb cycle
    COP [StagePlayerSprite] ( #1A )
    COP [StageMoveY] ( #07 )

  loc_02C646:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C658

  loc_02C64D:
    JSR $&CheckClimbAttack
    COP [SetEntryHereAndYield]
    DEC $24
    BPL loc_02C64D
    BRA loc_02C646

  loc_02C658:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #1B )
    COP [StageMoveY] ( #07 )

  loc_02C663:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C675

  loc_02C66A:
    JSR $&CheckClimbAttack
    COP [SetEntryHereAndYield]
    DEC $24
    BPL loc_02C66A
    BRA loc_02C663

  loc_02C675:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #19 )
    COP [StageMoveY] ( #07 )

  loc_02C680:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C63B

  loc_02C687:
    JSR $&CheckClimbAttack
    COP [SetEntryHereAndYield]
    DEC $24
    BPL loc_02C687
    BRA loc_02C680
}

ClimbVineLand {
    COP [PlaySoundCh2] ( #2C ) ; Vine landing: play sound #2C, animate landing sprite #1C, restore flags, return to idle
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$0008
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

CheckClimbFrame {
    LDA $2A               ; Frame test: $2A nonzero = a frame was staged; move its hold time $08 to $24, clear $08, CLC. $2A zero: SEC
    BEQ loc_02C6BA
    LDA $08
    STZ $08
    STA $24
    CLC 
    RTS 

  loc_02C6BA:
    SEC 
    RTS 
}

CheckClimbAttack {
    LDA $characterForm    ; Check climb attack: Freedan-only (form 1) with abilityBitmask bit 6 ($0040) → ClimbDropAttack
    CMP #$0001
    BEQ loc_02C6C5
    RTS 

  loc_02C6C5:
    LDA $abilityBitmask
    BIT #$0040
    BNE loc_02C6CE
    RTS 

  loc_02C6CE:
    COP [BranchIfPressed] ( #$0080, &ClimbDropAttack )
    RTS 
}

---------------------------------------------
; Freedan drop attack from vine — triggers ground impact effects.
; 
; Pops the climb loop return address, sets body sprite #06 with hitbox #00. Falls with force Y movement until hitting solid ground (16-pixel boundary check). On landing, loads anim table B entry 2, spawns ImpactTerrainShake and CameraShakeActor (scene $DD skips terrain shake), then plays 39-frame recovery animation before returning to idle.

ClimbDropAttack {
    PLA                   ; Drop attack: pop caller, set body sprite #06, hitbox #00, fall with force move Y #07
    COP [SetPlayerSpriteDirect] ( #06 )
    COP [StageSprAndHitbox] ( #00 )

  loc_02C6DC:
    COP [StageMoveY] ( #07 )

  loc_02C6DF:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C6DC

  loc_02C6E6:
    LDA $16
    BIT #$000F
    BNE loc_02C6F2
    COP [BranchIfSolidType] ( #00, &ClimbDropLand )

  loc_02C6F2:
    COP [SetEntryHereAndYield]
    DEC $24
    BPL loc_02C6E6
    BRA loc_02C6DF
}

ClimbDropLand {
    LDA #$0002            ; Drop landing: load anim table B entry 2, check scene $DD skip, spawn terrain shake + camera shake
    JSR $&attack_ability_system.LoadAbilityDamageB
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00DD
    BEQ loc_02C714
    COP [SpawnListAppend] ( @ImpactTerrainShake, #00, #00, #$2400 )

  loc_02C714:
    COP [SpawnListAppend] ( @CameraShakeActor, #00, #00, #$2400 )
    LDA #$003C
    STA $0026, Y
    COP [StageSpriteMoveY] ( #01, #00 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$0008
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

ImpactTerrainShake {
    LDA #$0010            ; Terrain shake: set playerFlags bit 4 ($0010), WaitWord #$01DF = 480 ticks, clear flag, die
    TSB $playerFlags
    COP [WaitWord] ( #$01DF )
    LDA #$0010
    TRB $playerFlags
    COP [Die]
}

CameraShakeActor {
    COP [PlaySoundCh2] ( #15 ) ; Camera shake actor: play sound #15, shake for $26 frames, then die
    JSR $&CameraShakeFrame
    DEC $26
    BMI loc_02C75C
    RTL 

  loc_02C75C:
    COP [Die]
}

---------------------------------------------
; Per-frame camera shake offset calculation.
; 
; Two paths based on layerPriorityFlag bit 9 ($0200), the bit camera_scroll_controller treats as camera-frozen:
; - Clear: zero the saved camera copies ($7F100C/E), then add random offsets to the camera targets using one RNG byte: (RNG & 3) - 1 to X, ((RNG >> 2) & 3) - 1 to Y. Each offset is -1, 0, +1 or +2.
; - Set: save the original camera target in actor WRAM on the first call ($7F100C/E), restore it before applying the offsets each later call, so the shake stays centred on the frozen position.

CameraShakeFrame {
    LDA $layerPriorityFlag ; Camera shake tick: layerPriorityFlag $0200 set (camera frozen) saves/restores the original target; clear zeroes the saved copies
    BIT #$0200
    BNE loc_02C794
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X

  loc_02C771:
    COP [RngByte]
    PHA 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    PLA 
    LSR 
    LSR                   ; Y axis: ((RNG >> 2) & 3) - 1 = -1..+2, added to cameraTargetY (the X axis above uses (RNG & 3) - 1)
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTS 

  loc_02C794:
    LDA $7F100C, X
    BNE loc_02C7AA
    LDA $cameraTargetX
    STA $7F100C, X
    LDA $cameraTargetY
    STA $7F100E, X
    BRA loc_02C771

  loc_02C7AA:
    STA $cameraTargetX
    LDA $7F100E, X
    STA $cameraTargetY
    BRA loc_02C771

  LadderClimbSouth:
    LDA #$0028            ; Ladder entry south: clear $0028 in actor flags, set $0100 and playerFlags $0800, then hide all buttons but Start/Select ($CFFC)
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFFC
    TSB $joypadMaskStd    ; Mask $CFFC hides the D-pad too: Up/Down are read from joypadRaw with the bit-0 masks $0801 / $0401 below
    COP [StagePlayerMoveXY] ( #26, #00, #1B )
    COP [AnimOnce]
    COP [BranchIfPressed] ( #$0801, &LadderMoveUp )
    COP [BranchIfPressed] ( #$0401, &LadderMoveDown )
    JMP $&LadderIdleNorth
}

LadderClimbNorth {
    LDA #$0028            ; Ladder entry north: same flag and joypad setup, entry animation sprite #28
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #28, #00, #19 )
    COP [AnimOnce]
    COP [BranchIfPressed] ( #$0401, &LadderMoveDown )
    COP [BranchIfPressed] ( #$0801, &LadderMoveUp )
    BRA LadderIdleSouth
}

LadderMoveDown {
    COP [StagePlayerSprite] ( #2D ) ; Ladder move down: sprite #2D, force Y movement #1D, check 16px boundary for bottom landing

  loc_02C810:
    COP [StageMoveY] ( #1D )

  loc_02C813:
    LDA $16
    AND #$000F
    BNE loc_02C81F
    COP [BranchIfSolidTypeSouth] ( #00, &LadderLandBottom )

  loc_02C81F:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C810
    COP [BranchIfNotPressed] ( #$0401, &LadderIdleSouth )
    COP [SetEntryHereAndYield]
    BRA loc_02C813
}

LadderMoveUp {
    COP [StagePlayerSprite] ( #2C ) ; Ladder move up: sprite #2C, force Y movement #1E, check 16px boundary for top exit

  loc_02C834:
    COP [StageMoveY] ( #1E )

  loc_02C837:
    LDA $16
    AND #$000F
    BNE loc_02C843
    COP [BranchIfSolidTypeNorth] ( #00, &LadderReachTop )

  loc_02C843:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C834
    COP [BranchIfNotPressed] ( #$0801, &LadderIdleNorth )
    COP [SetEntryHereAndYield]
    BRA loc_02C837
}

LadderIdleSouth {
    COP [BranchOnFlagByte] ( #00, #01, &LadderIdleSouthShadow ) ; Ladder idle south: Shadow flag check → normal sprite #2B or Shadow sprite #2F
    COP [StagePlayerSprite] ( #2B )
    BRA loc_02C873
}

LadderIdleSouthShadow {
    COP [StagePlayerSprite] ( #2F ) ; Shadow ladder idle south: sprite #2F
    BRA loc_02C873
}

LadderIdleNorth {
    COP [BranchOnFlagByte] ( #00, #01, &LadderIdleNorthShadow ) ; Ladder idle north: normal sprite #2A or Shadow sprite #2E
    COP [StagePlayerSprite] ( #2A )
    BRA loc_02C873
}

LadderIdleNorthShadow {
    COP [StagePlayerSprite] ( #2E )

  loc_02C873:
    STZ $2E
    STZ $08               ; Shared ladder idle loop: wait for animation event, then check up/down buttons

  loc_02C877:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C877
    LDA $08
    STZ $08
    STA $24

  loc_02C883:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0401, &LadderMoveDown )
    COP [BranchIfPressed] ( #$0801, &LadderMoveUp )
    DEC $24
    BPL loc_02C883
    BRA loc_02C877
}

LadderLandBottom {
    COP [StagePlayerMoveY] ( #29, #1A ) ; Ladder bottom landing: animate exit #29, unhide the buttons ($CFFC), restore $0008 in actor flags, return to the saved ptr
    COP [AnimOnce]
    LDA #$CFFC
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]
}

LadderReachTop {
    COP [StagePlayerMoveY] ( #27, #1C ) ; Ladder top exit: animate exit #27, unhide the buttons ($CFFC), restore $0008 in actor flags, return to the saved ptr
    COP [AnimOnce]
    LDA #$CFFC
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  ShimmyRightEntry:
    LDA #$0028            ; Shimmy right entry: clear $0028 in actor flags, set $0100 and playerFlags $0800, sprite #33 with force move #51 (rightward)
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    COP [StagePlayerMoveXY] ( #33, #51, #00 )
    COP [AnimOnce]

  ShimmyRightCheckWall:
    LDA $14               ; Wall check right: verify wall contact at X+8 aligned to 16px; detach if no wall
    CLC 
    ADC #$0008
    AND #$000F
    BNE ShimmyRightLoop
    COP [BranchIfSolidTypeEast] ( #07, &ShimmyRightLoop )
    COP [BranchIfSolidTypeEast] ( #00, &ShimmyRightLoop )
    JMP $&ShimmyDetachRight
}

ShimmyRightLoop {
    COP [StagePlayerSprite] ( #33 ) ; Shimmy right main loop: sprite #33, force move X #51, check tile boundaries for transitions

  loc_02C8EF:
    COP [StageMoveX] ( #51 )

  loc_02C8F2:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE ShimmyRightAnimLoop
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfPressed] ( #$0801, &ShimmyRightUpCheck )
    COP [BranchIfPressed] ( #$0401, &ShimmyRightDownCheck )

  loc_02C90E:
    COP [BranchIfSolidTypeEast] ( #07, &ShimmyRightAnimLoop )
    COP [BranchIfSolidTypeEast] ( #00, &ShimmyRightAnimLoop )
    JMP $&ShimmyDetachRight
}

ShimmyRightAnimLoop {
    COP [SetEntryHere]    ; Shimmy right animation loop: animate, check button release → detach; re-check wall contact
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C8EF
    COP [BranchIfNotPressed] ( #$0101, &ShimmyDetachRight )
    COP [SetEntryHereAndYield]
    BRA loc_02C8F2
}

ShimmyRightUpCheck {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner ) ; Shimmy right up check: solid north → corner transition
    BRA loc_02C90E
}

ShimmyRightDownCheck {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner ) ; Shimmy right down check: solid south → corner transition
    BRA loc_02C90E

  ShimmyLeftEntry:
    LDA #$0028            ; Shimmy left entry: same setup as right with sprite #32 and force move #52 (leftward)
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    COP [StagePlayerMoveXY] ( #32, #52, #00 )
    COP [AnimOnce]

  ShimmyLeftCheckWall:
    LDA $14               ; Wall check left: verify wall contact on west side; detach if no wall
    CLC 
    ADC #$0008
    AND #$000F
    BNE ShimmyLeftLoop
    COP [BranchIfSolidTypeWest] ( #07, &ShimmyLeftLoop )
    COP [BranchIfSolidTypeWest] ( #00, &ShimmyLeftLoop )
    BRA ShimmyDetachLeft
}

ShimmyLeftLoop {
    COP [StagePlayerSprite] ( #32 ) ; Shimmy left main loop: sprite #32, force move X #52

  loc_02C96C:
    COP [StageMoveX] ( #52 )

  loc_02C96F:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE ShimmyLeftAnimLoop
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfPressed] ( #$0801, &ShimmyLeftUpCheck )
    COP [BranchIfPressed] ( #$0401, &ShimmyLeftDownCheck )

  loc_02C98B:
    COP [BranchIfSolidTypeWest] ( #07, &ShimmyLeftAnimLoop )
    COP [BranchIfSolidTypeWest] ( #00, &ShimmyLeftAnimLoop )
    BRA ShimmyDetachLeft
}

ShimmyLeftAnimLoop {
    COP [SetEntryHere]    ; Shimmy left animation loop
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C96C
    COP [BranchIfNotPressed] ( #$0201, &ShimmyDetachLeft )
    COP [SetEntryHereAndYield]
    BRA loc_02C96F
}

ShimmyLeftUpCheck {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner ) ; Shimmy left up check: solid north → corner transition
    BRA loc_02C98B
}

ShimmyLeftDownCheck {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner ) ; Shimmy left down check: solid south → corner transition
    BRA loc_02C98B
}

ShimmyDetachRight {
    COP [StageMoveX] ( #00 ) ; Detach right: stop X movement, select normal (#31) or Shadow (#35) sprite, enter wall-hang idle
    COP [BranchOnFlagByte] ( #00, #01, &ShimmyDetachRightShadow )
    COP [StagePlayerSprite] ( #31 )
    BRA loc_02C9DB
}

ShimmyDetachRightShadow {
    COP [StagePlayerSprite] ( #35 ) ; Shadow detach right sprite (#35)
    BRA loc_02C9DB
}

ShimmyDetachLeft {
    COP [StageMoveX] ( #00 ) ; Detach left: stop X movement, normal (#30) or Shadow (#34) sprite
    COP [BranchOnFlagByte] ( #00, #01, &ShimmyDetachLeftShadow )
    COP [StagePlayerSprite] ( #30 )
    BRA loc_02C9DB
}

ShimmyDetachLeftShadow {
    COP [StagePlayerSprite] ( #34 ) ; Shadow detach left sprite (#34)

  loc_02C9DB:
    STZ $2C
    STZ $08               ; Shared detach idle: wait for event, then listen for D-pad (up/down → solid check, L/R → shimmy re-enter)

  loc_02C9DF:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C9DF
    LDA $08
    STZ $08
    STA $24

  loc_02C9EB:
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0801, &DetachedCheckUp )
    COP [BranchIfPressed] ( #$0401, &DetachedCheckDown )
    COP [BranchIfPressed] ( #$0201, &ShimmyLeftCheckWall )
    COP [BranchIfPressed] ( #$0101, &ShimmyRightCheckWall )

  loc_02CA05:
    DEC $24
    BPL loc_02C9EB
    BRA loc_02C9DF
}

DetachedCheckUp {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner ) ; Detached up check: solid north → corner transition (reach top)
    BRA loc_02CA05
}

DetachedCheckDown {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner ) ; Detached down check: solid south → corner transition
    BRA loc_02CA05
}

ShimmyTopCorner {
    STZ $2C               ; Top corner: clear the X movement chain ($2C), restore $0008 in actor flags, return to the saved ptr
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  BlockFromWalkSouth:
    LDA #$0400            ; Block-from-walk south: consume the south D-pad bit ($0400) in joypadHeld so joypadCurrent stops reporting it, then fall into BlockSouth
    TSB $joypadHeld
}

BlockSouth {
    STZ $invincibilityTimer ; Block south: close the $040C window, sprite #3A, enter the shared block loop
    COP [StagePlayerSprite] ( #3A )
    BRA loc_02CA58

  BlockFromWalkNorth:
    LDA #$0800            ; Block-from-walk north: consume the north D-pad bit ($0800) in joypadHeld
    TSB $joypadHeld
}

BlockNorth {
    STZ $invincibilityTimer ; Block north: sprite #3B
    COP [StagePlayerSprite] ( #3B )
    BRA loc_02CA58

  BlockFromWalkWest:
    LDA #$0200            ; Block-from-walk west: consume the west D-pad bit ($0200) in joypadHeld
    TSB $joypadHeld
}

BlockWest {
    STZ $invincibilityTimer ; Block west: sprite #3C
    COP [StagePlayerSprite] ( #3C )
    BRA loc_02CA58

  BlockFromWalkEast:
    LDA #$0100            ; Block-from-walk east: consume the east D-pad bit ($0100) in joypadHeld
    TSB $joypadHeld
}

BlockEast {
    STZ $invincibilityTimer ; Block east: sprite #3D
    COP [StagePlayerSprite] ( #3D )

  loc_02CA58:
    LDA #$2000
    TSB $playerFlags      ; Shared block loop: set playerFlags $2000 and actor $0020, clear actor $0100 (idle restores it), animate until L/R is released
    LDA #$0020
    TSB $10
    LDA #$0100
    TRB $10

  loc_02CA68:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CA68
    COP [BranchIfNotPressed] ( #$0030, &BlockStopToIdle )
    DEC $24
    BMI loc_02CA68
    RTL 
}

BlockStopToIdle {
    COP [RestoreSavedPtr] ; Block stop: restore saved ptr → return to PlayerIdleEntry
}

---------------------------------------------
; Inertial east-west movement handler — entered when player has residual EW speed.
; 
; Entered from PlayerIdleEntry when playerSpeedEw is nonzero but no matching D-pad input. Two sub-states based on speed sign: positive → east-facing sprite (#0F), negative → west-facing (#0E). Each frame: animate, check for speed zeroing → restore saved ptr; check for direction reversal → switch sprite; check for Psycho Slider (running slide attack); check speed threshold for melee attack; check L/R for block transition.
; 
; Mirrors MovingNorthSouth for the vertical axis.

MovingEastWest {
    LDA $joypadCurrent    ; Moving east-west: handle inertial deceleration when player has EW speed but released D-pad
    BIT #$0300
    BEQ loc_02CA93
    BIT #$0200
    BNE loc_02CAD4
    BRA loc_02CA9C

  loc_02CA93:
    LDA $playerSpeedEw
    BMI loc_02CAD4
    BRA loc_02CA9C        ; East-facing inertial movement: sprite #0F, animation loop with attack/block checks

  MovingToEast:
    COP [SetEntryHereAndYield] ; Direction switch to east: re-enter with SetEntryExit

  loc_02CA9C:
    COP [StagePlayerSprite] ( #0F )

  loc_02CA9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CA9F
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfPressed] ( #$0200, &MovingToWest )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CACD
    COP [BranchIfPressed] ( #$0080, &AttackEast )
    COP [BranchIfPressed] ( #$0030, &BlockFromWalkEast )

  loc_02CACD:
    DEC $24
    BMI loc_02CA9F
    RTL 
}

MovingToWest {
    COP [SetEntryHereAndYield] ; Direction switch to west: re-enter with SetEntryExit

  loc_02CAD4:
    COP [StagePlayerSprite] ( #0E )

  loc_02CAD7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CAD7
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfPressed] ( #$0100, &MovingToEast )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CB05
    COP [BranchIfPressed] ( #$0080, &AttackWest )
    COP [BranchIfPressed] ( #$0030, &BlockFromWalkWest )

  loc_02CB05:
    DEC $24
    BMI loc_02CAD7
    RTL 

  loc_02CB0A:
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Inertial north-south movement handler — entered when player has residual NS speed.
; 
; Same structure as MovingEastWest but for vertical axis. Positive → south-facing sprite (#0C), negative → north-facing (#0D). Checks up/down D-pad for direction reversal and attack transitions.

MovingNorthSouth {
    LDA $joypadCurrent    ; Moving north-south: handle inertial NS deceleration with N/S sprite and attack checks
    BIT #$0C00
    BEQ loc_02CB1B
    BIT #$0800
    BNE loc_02CB24
    BRA loc_02CB5C

  loc_02CB1B:
    LDA $playerSpeedNs
    BMI loc_02CB24
    BRA loc_02CB5C

  MovingToNorth:
    COP [SetEntryHereAndYield] ; Direction switch to north: re-enter with SetEntryExit

  loc_02CB24:
    COP [StagePlayerSprite] ( #0D )

  loc_02CB27:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CB27
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfPressed] ( #$0400, &MovingToSouth )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB55
    COP [BranchIfPressed] ( #$0080, &AttackNorth )
    COP [BranchIfPressed] ( #$0030, &BlockFromWalkNorth )

  loc_02CB55:
    DEC $24
    BMI loc_02CB27
    RTL 
}

MovingToSouth {
    COP [SetEntryHereAndYield] ; Direction switch to south: re-enter with SetEntryExit

  loc_02CB5C:
    COP [StagePlayerSprite] ( #0C )

  loc_02CB5F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CB5F
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfPressed] ( #$0800, &MovingToNorth )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB8D
    COP [BranchIfPressed] ( #$0080, &AttackSouth )
    COP [BranchIfPressed] ( #$0030, &BlockFromWalkSouth )

  loc_02CB8D:
    DEC $24
    BMI loc_02CB5F
    RTL 
}

---------------------------------------------
; Psycho Slider eligibility gate — Will-only (form 0) running slide attack.
; 
; The Psycho Slider is Will's sliding attack ability (abilityBitmask bit 1, $0002), acquired in Mu West. When moving fast enough, pressing the attack button initiates a damaging slide that can pass through narrow passages.
; 
; Conditions (all must be true): actor flag $0080 clear (no hit-reaction counter active), characterForm == 0 (Will), abilityBitmask bit 1 ($0002) set (Psycho Slider learned), playerFlags bit 12 ($1000) clear (not on a slope). If all pass and the attack button (mask $0080) is down, branches to RunAttackSpeedCheck.

CheckRunAttack {
    LDA $10               ; Psycho Slider gate: actor $0080 clear (no hit reaction), Will only, abilityBitmask $0002, playerFlags $1000 clear (not on a slope)
    BIT #$0080
    BNE loc_02CBB4
    LDA $characterForm
    BNE loc_02CBB4
    LDA $abilityBitmask
    BIT #$0002
    BEQ loc_02CBB4
    LDA $playerFlags
    BIT #$1000            ; Skip on a slope (playerFlags $1000 set)
    BNE loc_02CBB4
    COP [BranchIfPressed] ( #$0080, &RunAttackSpeedCheck ) ; Attack button down (mask $0080) -> RunAttackSpeedCheck, which needs |speed| >= 3 on either axis

  loc_02CBB4:
    RTS 
}

---------------------------------------------
; Route Psycho Slider to EW or NS based on which axis has sufficient speed.
; 
; Computes |playerSpeedEw| — if >= 3, pops return and jumps to RunAttackEW. Otherwise computes |playerSpeedNs| — if >= 3, pops return and jumps to RunAttackNS. If neither axis has sufficient speed, returns to caller (no slide attack).

RunAttackSpeedCheck {
    LDA $playerSpeedEw    ; Psycho Slider speed check: absolute EW speed >= 3 → RunAttackEW; else NS speed >= 3 → RunAttackNS
    BPL loc_02CBBE
    EOR #$FFFF
    INC 

  loc_02CBBE:
    CMP #$0003
    BCC loc_02CBC7
    PLA 
    JMP $&RunAttackEW

  loc_02CBC7:
    LDA $playerSpeedNs
    BPL loc_02CBD0
    EOR #$FFFF
    INC 

  loc_02CBD0:
    CMP #$0003
    BCC loc_02CBB4
    PLA 
    JMP $&RunAttackNS
}

SpeedThresholdEW {
    LDA $playerSpeedEw    ; EW speed threshold: |speedEw| >= 4 → carry set (too fast for normal attack); else check $1000 flag
    BPL loc_02CBE2
    EOR #$FFFF
    INC 

  loc_02CBE2:
    BRA loc_02CBED
}

SpeedThresholdNS {
    LDA $playerSpeedNs    ; NS speed threshold: same check for |speedNs|
    BPL loc_02CBED
    EOR #$FFFF
    INC 

  loc_02CBED:
    CMP #$0004
    BCC loc_02CBF3
    RTS 

  loc_02CBF3:
    LDA $playerFlags
    BIT #$1000
    BNE loc_02CBFD
    CLC 
    RTS 

  loc_02CBFD:
    SEC 
    RTS 
}

---------------------------------------------
; North-south Psycho Slider animation — Will's running slide attack along vertical axis.
; 
; Loads anim table A entry 1, sets body sprite #04. Branches by speed sign:
; - South (positive): sprites #0C → #0D loop → #0E finish, zeros NS speed
; - North (negative): SetForceNE, sprites #0F → #10 loop → #11 finish
; 
; Both paths: RunAttackFlagSetup (set $0200 actor flag, consume attack, set $0802 playerFlags), loop with AnimLoop for slide distance, RunAttackCleanup, restore saved ptr.

RunAttackNS {
    LDA #$0001            ; Psycho Slider NS: load anim table A entry 1, set body sprite #04; south or north by speed sign
    JSR $&attack_ability_system.LoadAbilityDamageA
    COP [SetPlayerSpriteDirect] ( #04 )
    LDA $playerSpeedNs
    BMI loc_02CC2E
    JSR $&RunAttackFlagSetup
    LDA #$0100            ; South Psycho Slider: flag setup, sprite #0C→#0D loop→#0E finish, zero NS speed, cleanup
    TRB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    STZ $playerSpeedNs
    COP [StageSpriteLoopMoveY] ( #0D, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr] ; End of the south Psycho Slider: restore the saved pointer (the north slider starts at loc_02CC2E below)

  loc_02CC2E:
    JSR $&RunAttackFlagSetup
    COP [SetMoveNegateY] ( #01 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    STZ $playerSpeedNs
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveY] ( #10, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

RunAttackEW {
    LDA #$0001            ; Psycho Slider EW: same structure for horizontal axis
    JSR $&attack_ability_system.LoadAbilityDamageA
    COP [SetPlayerSpriteDirect] ( #04 )
    LDA $playerSpeedEw
    BPL loc_02CC84
    JSR $&RunAttackFlagSetup
    COP [SetMoveNegateX] ( #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #13, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]

  loc_02CC84:
    JSR $&RunAttackFlagSetup
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #16, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Called from attack_ability_system before Psycho Dash and run attack paths: clears bit $0100 in the player actor flags and sets layerPriorityFlag bit $0200 so camera_scroll_controller stops scrolling, then falls through into RunAttackFlagSetup.

FreezeCameraForAttack {
    LDA #$0100            ; Clear $0100 in actor flags and set layerPriorityFlag $0200 (freezes camera_scroll_controller); falls into RunAttackFlagSetup
    TRB $10
    LDA #$0200
    TSB $layerPriorityFlag
}

RunAttackFlagSetup {
    LDA #$0200            ; Psycho Slider flag setup: set $0200 actor flag, consume attack button, set $0802 playerFlags
    TSB $10
    LDA #$0080
    TSB $joypadHeld
    LDA #$0802
    TSB $playerFlags
    RTS 
}

---------------------------------------------
; Called when Psycho Dash animation completes: clears layerPriorityFlag $0200 so the camera scrolls again, then falls through into RunAttackCleanup.

UnfreezeCameraAfterAttack {
    LDA #$0200            ; Clear layerPriorityFlag $0200 (the camera scrolls again); falls into RunAttackCleanup
    TRB $layerPriorityFlag
}

RunAttackCleanup {
    LDA #$0200            ; Psycho Slider cleanup: clear $0200 actor flag, consume attack button, clear $0002 playerFlags
    TRB $10
    LDA #$0080
    TSB $joypadHeld
    LDA #$0002
    TRB $playerFlags
    RTS 
}

---------------------------------------------
; South-facing melee attack for all character forms.
; 
; AttackInit keeps only the D-pad bits of joypadCurrent, sets joypadHeld = D-pad | attack and plays the form-specific SFX; AttackSouth then consumes the south D-pad bit ($0400) in joypadHeld. Freedan (form 1) checks for wall-adjacent attack via BranchIfSolidSouth — if wall contact, uses push sprite #48 instead of normal #36. Also checks diagonal solid offset for X-axis alignment.
; 
; Scene $00E8 (Dark Gaia fight): spawns ProjectileSouth alongside melee.
; 
; Per-frame loop: Will (form 0) checks every D-pad direction except south ($0B00 = Up|Left|Right) for a redirect and the facing direction ($0400) for the lunge. Freedan/Shadow check redirect only. On animation end, checks for attack button re-press (combo) or finishes.

AttackSouth {
    JSR $&AttackInit      ; Attack south: AttackInit, consume the south D-pad bit in joypadHeld, Freedan wall-push test via BranchIfSolidSouth
    LDA #$0400
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0001
    BNE loc_02CD04
    COP [BranchIfSolidSouth] ( &AttackSouthWallPush )
    LDA $playerXPos
    AND #$000F
    BEQ loc_02CD04
    COP [BranchIfSolidOffset] ( #01, #01, &AttackSouthWallPush ) ; Freedan wall-adjacent south: also check X alignment for diagonal solid offset
    BRA loc_02CD04
}

AttackSouthWallPush {
    COP [StagePlayerSprite] ( #48 ) ; Freedan wall-push south: sprite #48 (thrusting attack against wall)
    BRA loc_02CD07

  loc_02CD04:
    COP [StagePlayerSprite] ( #36 )

  loc_02CD07:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CD18
    COP [SpawnListAppend] ( @ProjectileSouth, #00, #00, #$0602 )

  loc_02CD18:
    COP [SetEntryHere]    ; Per-frame loop: Will redirects on any D-pad direction but south ($0B00) or lunges on south ($0400); other forms only redirect
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]

  loc_02CD1E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CD52
    LDA $characterForm
    BNE loc_02CD45        ; No input → check for attack button re-press (combo) or finish
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0B00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0400, &RangedAttackSouth )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD45:
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0B00, &AttackRedirect )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD52:
    COP [BranchIfPressed] ( #$0080, &AttackSouth )
    JMP $&AttackFinish
}

AttackNorth {
    JSR $&AttackInit      ; Attack north: AttackInit, consume the north D-pad bit, Freedan wall-push test (BranchIfSolidSouth)
    LDA #$0800
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0001
    BNE loc_02CD85
    COP [BranchIfSolidSouth] ( &AttackNorthWallPush ) ; Tests solid SOUTH although this is the north attack; AttackSouth uses the same op
    LDA $playerXPos
    AND #$000F
    BEQ loc_02CD85
    COP [BranchIfSolidOffset] ( #01, #FF, &AttackNorthWallPush )
    BRA loc_02CD85
}

AttackNorthWallPush {
    COP [StagePlayerSprite] ( #49 ) ; Freedan wall-push north: sprite #49
    BRA loc_02CD88

  loc_02CD85:
    COP [StagePlayerSprite] ( #37 )

  loc_02CD88:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CD99
    COP [SpawnListAppend] ( @ProjectileNorth, #00, #D0, #$0602 )

  loc_02CD99:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]

  loc_02CD9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CDD3
    LDA $characterForm
    BNE loc_02CDC6
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0700, &AttackRedirect )
    COP [BranchIfPressed] ( #$0800, &RangedAttackNorth )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDC6:
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0700, &AttackRedirect )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDD3:
    COP [BranchIfPressed] ( #$0080, &AttackNorth )
    JMP $&AttackFinish
}

AttackWest {
    JSR $&AttackInit      ; Attack west: init, non-Shadow (forms 0-1) wall-push via BranchIfSolidWest + Y-offset check
    LDA #$0200
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0002
    BEQ loc_02CDFE
    COP [BranchIfSolidWest] ( &AttackWestWallPush )
    LDA $16
    AND #$000F
    BEQ loc_02CDFE
    COP [BranchIfSolidOffset] ( #FF, #01, &AttackWestWallPush )

  loc_02CDFE:
    COP [StagePlayerSprite] ( #38 )
    BRA loc_02CE06
}

AttackWestWallPush {
    COP [StagePlayerSprite] ( #42 ) ; Wall-push west: sprite #42 (available to Will and Freedan, not Shadow)

  loc_02CE06:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CE17
    COP [SpawnListAppend] ( @ProjectileWest, #00, #00, #$0602 )

  loc_02CE17:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]

  loc_02CE1D:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CE51
    LDA $characterForm
    BNE loc_02CE44
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0D00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0200, &RangedAttackWest )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE44:
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0D00, &AttackRedirect )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE51:
    COP [BranchIfPressed] ( #$0080, &AttackWest )
    JMP $&AttackFinish
}

AttackEast {
    JSR $&AttackInit      ; Attack east: init, non-Shadow wall-push via BranchIfSolidEast + Y-offset check
    LDA #$0100
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0002
    BEQ loc_02CE7C
    COP [BranchIfSolidEast] ( &AttackEastWallPush )
    LDA $16
    AND #$000F
    BEQ loc_02CE7C
    COP [BranchIfSolidOffset] ( #01, #01, &AttackEastWallPush )

  loc_02CE7C:
    COP [StagePlayerSprite] ( #39 )
    BRA loc_02CE84
}

AttackEastWallPush {
    COP [StagePlayerSprite] ( #43 ) ; Wall-push east: sprite #43

  loc_02CE84:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CE95
    COP [SpawnListAppend] ( @ProjectileEast, #00, #00, #$0602 )

  loc_02CE95:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]

  loc_02CE9B:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CECF
    LDA $characterForm
    BNE loc_02CEC2
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0E00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0100, &RangedAttackEast )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CEC2:
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0E00, &AttackRedirect )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CECF:
    COP [BranchIfPressed] ( #$0080, &AttackEast )
    JMP $&AttackFinish
}

---------------------------------------------
; Mid-attack direction change — allows Will to redirect attacks.
; 
; Checks joypadCurrent for any D-pad direction ($0F00). If none is held it branches to AttackFinish. Otherwise it clears the attack bit ($0080) from joypadHeld (un-consuming the button) and falls into AttackFinish, which clears the D-pad bits of joypadHeld and returns to idle for a new dispatch.

AttackRedirect {
    LDA $joypadCurrent    ; Any D-pad direction held ($0F00)? If none go to AttackFinish; else un-consume the attack bit ($0080) in joypadHeld, then fall into AttackFinish
    BIT #$0F00
    BEQ AttackFinish
    LDA #$0080
    TRB $joypadHeld
}

AttackFinish {
    LDA #$0F00            ; Attack finish: clear D-pad held bits ($0F00), restore saved ptr → return to idle
    TRB $joypadHeld
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Shared melee attack initialization for all four directions.
; 
; Keeps only the D-pad bits of joypadCurrent (AND #$0F00), then sets joypadHeld = D-pad | attack ($0080) so the attack button and the held directions read as consumed. Clears actor flag $0100. Plays character-form-specific SFX: Will = sound #01, Freedan/Shadow = sound #02.

AttackInit {
    LDA $joypadCurrent    ; Keep only the D-pad bits of joypadCurrent, set joypadHeld = D-pad | attack (both consumed), clear actor $0100, play the form SFX
    AND #$0F00
    STA $joypadCurrent
    ORA #$0080
    STA $joypadHeld
    LDA #$0100
    TRB $10
    LDA $characterForm
    BEQ loc_02CF0B
    COP [PlaySoundCh2] ( #02 )
    RTS 

  loc_02CF0B:
    COP [PlaySoundCh2] ( #01 ) ; Will SFX: sound #01 (lighter attack sound)
    RTS 
}

---------------------------------------------
; Will-only lunge follow-up — south direction.
; 
; Reached from AttackSouth when Will (form 0) holds the facing direction during the swing. Calls RangedSetForceY (force move #46, playerFlags $0800, climbStateData = 1, actor flag $0200, extendedFlags $0040), shows sprite #44, animates once, then clears actor flag $0200 and extendedFlags $0040 (AndExtraFlags #$FFBF) and restores the saved ptr.
; 
; North/West/East variants mirror this with sprites #45/#46/#47. North sets $2000 and west sets $4000 in $12, the direction-negate bits tile_collision_physics uses to flip the Y / X delta; the east and south variants need no flip. No projectile is spawned here.

RangedAttackSouth {
    JSR $&RangedSetForceY ; Lunge south: RangedSetForceY (force move #46), sprite #44, play once, then clear $0200 and extendedFlags $0040 and restore the saved ptr
    COP [StagePlayerSprite] ( #44 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackNorth {
    JSR $&RangedSetForceY ; Lunge north: RangedSetForceY, $2000 in $12 (the flip-Y direction bit tile_collision_physics reads), sprite #45
    LDA #$2000
    TSB $12
    COP [StagePlayerSprite] ( #45 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackWest {
    JSR $&RangedSetForceX ; Lunge west: RangedSetForceX, $4000 in $12 (the flip-X direction bit), sprite #46
    LDA #$4000
    TSB $12
    COP [StagePlayerSprite] ( #46 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackEast {
    JSR $&RangedSetForceX ; Ranged east: set force X, sprite #47
    COP [StagePlayerSprite] ( #47 )
    COP [AnimOnce]

  loc_02CF3F:
    LDA #$0200
    TRB $10
    COP [AndExtraFlags] ( #$FFBF )
    COP [RestoreSavedPtr]
}

RangedSetForceX {
    COP [StageMoveX] ( #46 ) ; Force move curve #46: 6 frames of 0, 19 of 3, 4 of 1, then 0 (a delayed forward lunge; nothing is spawned here)
    BRA loc_02CF52
}

RangedSetForceY {
    COP [StageMoveY] ( #46 ) ; The same curve #46 on the Y axis

  loc_02CF52:
    LDA #$0800
    TSB $playerFlags      ; Set playerFlags $0800 (script/ability lock); PlayerIdleEntry clears it again
    LDA #$0001
    STA $climbStateData   ; climbStateData = 1: the Will ability damage bonus ($09E0) that combat_collision adds; PlayerIdleEntry zeroes it
    LDA #$0200
    TSB $10               ; Set $0200 in actor flags (the bit the Psycho Slider also sets); the lunge exit clears it
    COP [OrExtraFlags] ( #$0040 ) ; Set extendedFlags $0040, the bounce flag tile_collision_physics reads; the lunge exit clears it with AndExtraFlags #$FFBF
    RTS 
}

---------------------------------------------
; Dark Gaia fight projectile actor — south direction.
; 
; Spawned by AttackSouth only in scene $E8 (SpawnListAppend, flags $0602). Uses the spriteset_darkgaia_projectile metasprite. Two-phase animation: initial launch (sprite #00, MoveY #09), then looping travel (sprite #04, MoveY #0F). Dies when bit 14 ($4000) of its actor flags $10 is set — sprite_composition sets that bit for actors outside the screen bounds — so it flies until it leaves the screen.
; 
; North/West/East variants use matching sprite pairs and MoveX/MoveY directions.

ProjectileSouth {
    COP [SetMetasprite] ( @spriteset_darkgaia_projectile ) ; Projectile south: metasprite set spriteset_darkgaia_projectile, initial sprite #00 + MoveY #09, then loop #04 + #0F
    COP [StageSpriteMoveY] ( #00, #09 )
    COP [AnimOnce]

  loc_02CF73:
    COP [StageSpriteMoveY] ( #04, #0F )
    COP [AnimOnce]
    LDA $10               ; Loop until bit $4000 of $10 is set (sprite_composition sets it when the actor is off-screen), then die
    BIT #$4000
    BEQ loc_02CF73
    COP [Die]
}

ProjectileNorth {
    COP [SetMetasprite] ( @spriteset_darkgaia_projectile ) ; Projectile north: initial #01 + MoveY #0A, loop #05 + #10
    COP [StageSpriteMoveY] ( #01, #0A )
    COP [AnimOnce]

  loc_02CF8D:
    COP [StageSpriteMoveY] ( #05, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CF8D
    COP [Die]
}

ProjectileWest {
    COP [SetMetasprite] ( @spriteset_darkgaia_projectile ) ; Projectile west: initial #02 + MoveX #0A, loop #06 + #10
    COP [StageSpriteMoveX] ( #02, #0A )
    COP [AnimOnce]

  loc_02CFA7:
    COP [StageSpriteMoveX] ( #06, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CFA7
    COP [Die]
}

ProjectileEast {
    COP [SetMetasprite] ( @spriteset_darkgaia_projectile ) ; Projectile east: initial #03 + MoveX #09, loop #07 + #0F
    COP [StageSpriteMoveX] ( #03, #09 )
    COP [AnimOnce]

  loc_02CFC1:
    COP [StageSpriteMoveX] ( #07, #0F )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CFC1
    COP [Die]
}