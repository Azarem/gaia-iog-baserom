; Main player character actor definition and movement state machine (181132–184272).
; 
; This is the largest player actor file — the actor-def that instantiates the player and contains the complete movement FSM, traversal systems (climbing, ladders, shimmy), combat (melee, run attack, ranged), and related helpers. The actor-def's init code spawns four companion actors: attack_ability_system (charged attacks), player_move_controller (per-frame physics), slope_ramp_physics (slope tile handling), and shadow_shimmer (Shadow's palette shimmer).
; 
; === LOGICAL SECTIONS (recommended split boundaries) ===
; 
; 1. CORE IDLE + WALKING (181132–181790)
;    PlayerCharacterDef, PlayerIdleEntry, PlayerIdleDispatchTable, IdleStand* (8 directional × Shadow variants), WalkSouth/North/West/East, CheckAttackWhileWalking, WalkAbortToIdle, WalkRestoreSaved, SetAutoWalkTimer.
;    The idle dispatch uses a facing × input matrix: GetPlayerFacing (0–3) × SignedMultiply by 14 selects a row of 7 entries in PlayerIdleDispatchTable. Input priority: attack button > D-pad cardinal > L/R run > idle stand. Walk pieces initialize speed (±3), manage invincibility timer, and transition to running on L/R shoulder press.
; 
; 2. VINE CLIMBING (181790–182198)
;    ClimbVineEntry, ClimbVineLand, CheckClimbFrame, CheckClimbAttack, ClimbDropAttack, ClimbDropLand, ImpactTerrainShake, CameraShakeActor, CameraShakeFrame.
;    Freedan-only vine climbing with a 3-frame alternating sprite cycle. CheckClimbAttack gates drop attack to Freedan (form 1) with abilityBitmask bit 6 ($0040). ClimbDropLand spawns ImpactTerrainShake (sets $0010 flag for 479 frames) and CameraShakeActor (random ±1 camera offset via RNG).
; 
; 3. LADDER SYSTEM (182198–182461)
;    LadderClimbSouth/North, LadderMoveDown/Up, LadderIdleSouth/North (+ Shadow variants), LadderLandBottom, LadderReachTop.
;    Bi-directional ladder traversal. Entry masks joypad ($CFF0) to restrict input to up/down. LadderMoveDown/Up check solid tiles at 16-pixel boundaries for exit transitions. Idle poses have Shadow-specific sprites (flag byte #00 == $01).
; 
; 4. SHIMMY SYSTEM (182461–182818)
;    ShimmyRightEntry, ShimmyRightCheckWall, ShimmyRightLoop, ShimmyRightUpCheck, ShimmyRightDownCheck, ShimmyLeftEntry, ShimmyLeftCheckWall, ShimmyLeftLoop, ShimmyLeftUpCheck, ShimmyLeftDownCheck, ShimmyDetachRight/Left (+ Shadow variants), ShimmyTopCorner.
;    Horizontal wall shimmy with wall-contact detection at 8-pixel intervals. CheckWall verifies east/west solid tiles before allowing movement. Detach states listen for L/R to re-enter shimmy or up/down for corner transitions. ShimmyTopCorner restores normal movement and returns to idle.
; 
; 5. RUNNING + INERTIAL MOVEMENT (182818–183186)
;    AttackFromWalkSouth/North/West/East, RunSouth/North/West/East, RunStopToIdle, MovingEastWest, MovingNorthSouth.
;    L/R shoulder triggers run (bit 13 $2000 in playerFlags, bit 5 $0020 in actor flags). AttackFromWalk* pieces inject the appropriate D-pad direction into joypadHeld before falling into Run*. MovingEastWest/NorthSouth handle inertial deceleration animations — entered from PlayerIdleEntry when speed is nonzero but no matching D-pad is held.
; 
; 6. RUN ATTACK (183186–183514)
;    CheckRunAttack, RunAttackSpeedCheck, SpeedThresholdEW, SpeedThresholdNS, RunAttackNS, RunAttackEW, DisableStatusForAttack, RunAttackFlagSetup, RestoreStatusDisplay, RunAttackCleanup.
;    Will-only (form 0) dash attack requiring abilityBitmask bit 1 ($0002) and speed >= 3. RunAttackSpeedCheck routes to EW or NS based on which axis has sufficient speed. Both directions use LoadAbilityAnimTableA entry 1, stage a looping sprite move, then clean up flags.
; 
; 7. BASIC MELEE ATTACK (183514–184138)
;    AttackSouth/North/West/East, AttackRedirect, AttackFinish, AttackInit.
;    Directional melee for all character forms. AttackInit strips D-pad from joypadCurrent, sets joypadHeld, and plays form-specific SFX (Will=#01, Freedan/Shadow=#02). Freedan (form 1) checks for wall-adjacent push attack variants using BranchIfSolid (sprites #48/#49 S/N, #42/#43 W/E). Will (form 0) can redirect mid-attack via BranchIfButton on perpendicular D-pad, and continue-attack on same D-pad into ranged. Scene $00E8 (Dark Gaia fight) spawns projectile actors alongside melee.
; 
; 8. RANGED ATTACK + PROJECTILES (184138–184272)
;    RangedAttackSouth/North/West/East, RangedSetForceX/Y, ProjectileSouth/North/West/East.
;    Will-only ranged follow-up after melee. RangedSetForce* sets up force movement, flags $0800 playerFlags, enables orbActorFlags $0040, and stores climbStateData = 1. Projectile actors use table_17D000 metasprite with two-phase animation (initial + looping), self-destructing on wall hit (bit 14 $4000 in actor flags).
---------------------------------------------

?BANK 02

?INCLUDE 'attack_ability_system'
?INCLUDE 'game_over_sequence'
?INCLUDE 'hardware_math'
?INCLUDE 'player_move_controller'
?INCLUDE 'shadow_shimmer'
?INCLUDE 'slope_ramp_physics'
?INCLUDE 'table_17D000'

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
!free101C                       7F101C

---------------------------------------------

; Player character actor definition table and initialization code.
; 
; The actor-def header (#00, #08, #85) defines the actor type. The inline init code:
; 1. Sets visibility ($0100) and mirror ($0001) actor flags
; 2. Stores the current actor slot as playerActor ($09AA)
; 3. Sets the free101C marker to signal the player actor is active
; 4. Checks the game-over wakeup flag ($0AF8) — spawns DeathWakeupMessage if set
; 5. Spawns four companion actors: attack_ability_system (SpawnBefore), player_move_controller and slope_ramp_physics (SpawnAfter), shadow_shimmer (SpawnLastRel)
; 
; These companions handle combat, physics, slope detection, and Shadow's palette shimmer respectively. The player character actor itself handles only the movement state machine.

PlayerCharacterDef [
  actor-def < #00, #08, #85, {

  code_02C38F:
    LDA #$0100            ; Init: set visibility ($0100), mirror ($0001) flags; store actor slot as playerActor
    TSB $10
    LDA #$0001
    TSB $12
    TXA 
    STA $playerActor
    LDA #$0001
    STA $free101C, X      ; Set free101C marker — signals player actor is active
    LDA $0AF8             ; Check $0AF8 (game-over wakeup flag) — spawn DeathWakeupMessage if set
    BEQ loc_02C3B0
    COP [SpawnAfterFlags] ( @game_over_sequence.DeathWakeupMessage, #$2000 )

  loc_02C3B0:
    COP [SpawnBefore] ( @attack_ability_system.AttackSystemEntry ) ; Spawn attack_ability_system.AttackSystemEntry as SpawnBefore companion (runs before player each frame)
    COP [SpawnAfter] ( @player_move_controller.PlayerMoveController ) ; Spawn player_move_controller as SpawnAfter companion (physics/collision processing)
    COP [SpawnAfter] ( @slope_ramp_physics.SlopePhysicsEntry ) ; Spawn slope_ramp_physics as SpawnAfter companion (slope tile handling)
    COP [SpawnLastRel] ( @shadow_shimmer.ShadowShimmerInit, #00, #00, #$2800 ) ; Spawn shadow_shimmer as SpawnLastRel companion (Shadow palette shimmer, dies if not form 2)
} >
]

---------------------------------------------
; Main idle state entry and input dispatch loop.
; 
; Clears transient flags: D-pad held bits ($F0FF mask on joypadHeld), run/slider flags ($2800 on playerFlags), run-attack flag ($0020), and climb data. Checks for ability-hijacked state ($2000 in actor flags) — returns immediately if set (attack system controls player).
; 
; Saves itself as the return point via SetSavedPtr, clears force movement. Checks for residual speed — if nonzero, jumps to MovingEastWest or MovingNorthSouth for inertial deceleration.
; 
; If no residual speed, computes a dispatch index: GetPlayerFacing (0=S, 1=N, 2=W, 3=E) × 14 via SignedMultiply → row offset into PlayerIdleDispatchTable. Then scans joypad input in priority order: attack button > D-pad cardinal (S/N/W/E) > L/R run > idle stand. The resulting 2-byte address is loaded from the table and executed via the DEC+PHA+RTS trick.

PlayerIdleEntry {
    COP [SetEntryContinue] ; Main idle entry — clears transient flags and dispatches to walk/run/attack/stand based on input
    LDA $joypadHeld       ; Clear directional held bits ($0F00) from joypadHeld — prevents stale D-pad state from previous frame
    AND #$F0FF
    STA $joypadHeld
    LDA #$2800            ; Clear bits 11+13 ($2800) from playerFlags — end run state and slider state
    TRB $playerFlags
    LDA #$0100            ; Restore visibility flag ($0100) in actor flags
    TSB $10
    LDA #$0020            ; Clear run-attack flag ($0020) from actor flags
    TRB $10
    STZ $climbStateData
    LDA $10               ; Check bit 13 ($2000) of actor flags — ability-hijacked state (attack system controls player)
    BIT #$2000
    BEQ loc_02C3EE
    RTL 

  loc_02C3EE:
    COP [SetSavedPtr] ( &PlayerIdleEntry ) ; Save PlayerIdleEntry as return point and clear force movement
    COP [SetForceBoth] ( #00 )
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
    JSL $@hardware_math.SignedMultiply
    REP #$20
    TAX 
    LDA $joypadCurrent    ; Read joypad state; scan input priority: attack > D-pad (S/N/W/E) > L/R run > idle stand
    BIT #$8000
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
; Indexed by (facing × 7 + input_priority). Each row of 7 entries: [Attack, WalkEast, WalkWest, WalkSouth, WalkNorth, Run, IdleStand]. The facing direction determines which row is used, and the input scan priority determines the column.

PlayerIdleDispatchTable [
  &AttackSouth   ;00
  &WalkEast   ;01
  &WalkWest   ;02
  &WalkSouth   ;03
  &WalkNorth   ;04
  &RunSouth   ;05
  &IdleStandSouth   ;06
  &AttackNorth   ;07
  &WalkEast   ;08
  &WalkWest   ;09
  &WalkSouth   ;0A
  &WalkNorth   ;0B
  &RunNorth   ;0C
  &IdleStandNorth   ;0D
  &AttackWest   ;0E
  &WalkEast   ;0F
  &WalkWest   ;10
  &WalkSouth   ;11
  &WalkNorth   ;12
  &RunWest   ;13
  &IdleStandWest   ;14
  &AttackEast   ;15
  &WalkEast   ;16
  &WalkWest   ;17
  &WalkSouth   ;18
  &WalkNorth   ;19
  &RunEast   ;1A
  &IdleStandEast   ;1B
]

IdleStandSouth {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandSouthShadow ) ; South idle: check Shadow flag byte → select normal (#00) or Shadow (#10) sprite
    COP [StagePlayerSprite] ( #00 )
    BRA loc_02C4BD
}

IdleStandSouthShadow {
    COP [StagePlayerSprite] ( #10 ) ; Shadow south idle sprite (#10)
    BRA loc_02C4BD
}

IdleStandNorth {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandNorthShadow ) ; North idle: normal (#01) or Shadow (#11) sprite
    COP [StagePlayerSprite] ( #01 )
    BRA loc_02C4BD
}

IdleStandNorthShadow {
    COP [StagePlayerSprite] ( #11 ) ; Shadow north idle sprite (#11)
    BRA loc_02C4BD
}

IdleStandWest {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandWestShadow ) ; West idle: normal (#02) or Shadow (#12) sprite
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C4BD
}

IdleStandWestShadow {
    COP [StagePlayerSprite] ( #12 ) ; Shadow west idle sprite (#12)
    BRA loc_02C4BD
}

IdleStandEast {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandEastShadow ) ; East idle: normal (#03) or Shadow (#13) sprite
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
    COP [SetEntryContinue]
    LDA $playerSpeedEw    ; Check if player has started moving (speed nonzero) → restore saved ptr to re-dispatch
    ORA $playerSpeedNs
    BNE IdleAnimReturn
    COP [BranchIfButton] ( #$8F30, &IdleAnimReturn ) ; Any gameplay button ($8F30 = attack + D-pad + L/R) → exit idle and re-dispatch
    DEC $24
    BMI loc_02C4BD
    RTL 
}

IdleAnimReturn {
    COP [RestoreSavedPtr] ; Return from idle animation — restore saved ptr to re-enter PlayerIdleEntry
}

WalkSouth {
    LDA $24               ; South walk: if facing was already south ($24==0), initialize speed +3 and clear invincibility timer
    BNE loc_02C4F9
    LDA $invincibilityTimer
    BMI loc_02C4F9
    STZ $invincibilityTimer
    LDA #$0003
    STA $playerSpeedNs
    STZ $slopeStepCounter ; Stage south walk sprite (#08) and set auto-walk timer (13 frames)
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C4F9:
    COP [StagePlayerSprite] ( #08 )
    JSR $&SetAutoWalkTimer

  loc_02C4FF:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C4FF
    COP [BranchIfNoButton] ( #$0400, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C51F
    COP [BranchIfButton] ( #$0030, &RunSouth )

  loc_02C51F:
    DEC $24
    BMI loc_02C4FF
    RTL 
}

WalkNorth {
    LDA $24               ; North walk: if facing was north ($24==1), initialize speed -3 (FFFD) northward
    DEC 
    BNE loc_02C541
    LDA $invincibilityTimer
    BMI loc_02C541
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C541:
    COP [StagePlayerSprite] ( #09 )
    JSR $&SetAutoWalkTimer

  loc_02C547:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C547
    COP [BranchIfNoButton] ( #$0800, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C567
    COP [BranchIfButton] ( #$0030, &RunNorth )

  loc_02C567:
    DEC $24
    BMI loc_02C547
    RTL 
}

WalkWest {
    LDA $24               ; West walk: if facing was west ($24==2), initialize speed -3 (FFFD) westward
    DEC 
    DEC 
    BNE loc_02C58A
    LDA $invincibilityTimer
    BMI loc_02C58A
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C58A:
    COP [StagePlayerSprite] ( #0A )
    JSR $&SetAutoWalkTimer

  loc_02C590:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C590
    COP [BranchIfNoButton] ( #$0200, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5B0
    COP [BranchIfButton] ( #$0030, &RunWest )

  loc_02C5B0:
    DEC $24
    BMI loc_02C590
    RTL 
}

WalkEast {
    LDA $24               ; East walk: if facing was east ($24==3), initialize speed +3 eastward
    DEC 
    DEC 
    DEC 
    BNE loc_02C5D4
    LDA $invincibilityTimer
    BMI loc_02C5D4
    STZ $invincibilityTimer
    LDA #$0003
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C5D4:
    COP [StagePlayerSprite] ( #0B )
    JSR $&SetAutoWalkTimer

  loc_02C5DA:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C5DA
    COP [BranchIfNoButton] ( #$0100, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5FA
    COP [BranchIfButton] ( #$0030, &RunEast )

  loc_02C5FA:
    DEC $24
    BMI loc_02C5DA
    RTL 
}

---------------------------------------------
; Check for attack or speed-zero conditions during walking.
; 
; Called via JSR from WalkSouth/North/West/East per-frame loops. Checks:
; 1. Attack button ($8000) pressed → WalkAbortToIdle (pop return, restore saved ptr)
; 2. Both EW and NS speed zeroed (external stop) → WalkAbortToIdle
; 3. If neither: check playerFlags bit 12 ($1000 walk-attack flag), return Z flag to caller
; 
; Returns: Z flag = 0 means walk-attack is active (caller should check for run transition).

CheckAttackWhileWalking {
    COP [BranchIfButton] ( #$8000, &WalkAbortToIdle ) ; Check for attack button ($8000) or zero speed while walking → abort walk to idle
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE WalkAbortToIdle
    LDA $playerFlags
    BIT #$1000
    RTS 
}

WalkAbortToIdle {
    PLA                   ; Pop walk return address — falls through to WalkRestoreSaved
}

WalkRestoreSaved {
    COP [RestoreSavedPtr] ; Restore saved ptr after walk ends — returns to PlayerIdleEntry for re-dispatch
}

SetAutoWalkTimer {
    LDA #$000D            ; Set auto-walk timer: 13 frames ($000D) of guaranteed walk before idle re-check
    STA $invincibilityTimer
    RTS 
}

---------------------------------------------
; Vine climbing state machine — Freedan-only traversal system.
; 
; Entry: clear ground flag ($0008), set climb flag ($0200), mask joypad ($4000). Plays initial climb-on animation (sprites #18, #19).
; 
; Main loop: 3-sprite alternating cycle (#1A, #1B, #19) with force Y movement (#07 = downward). Each frame checks for solid ground landing. CheckClimbFrame reads the $2A event flag for animation timing. CheckClimbAttack gates drop attack to Freedan (characterForm == 1) with abilityBitmask bit 6 ($0040).

ClimbVineEntry {
    LDA #$0008            ; Vine climb entry: clear ground flag ($0008), set climb flag ($0200), mask joypad ($4000)
    TRB $10
    LDA #$0200
    TSB $10
    LDA #$4000
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #18, #00, #18 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]

  loc_02C63B:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand ) ; Check solid type below for landing; begin 3-sprite alternating climb cycle
    COP [StagePlayerSprite] ( #1A )
    COP [StageForceMoveY] ( #07 )

  loc_02C646:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C658

  loc_02C64D:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C64D
    BRA loc_02C646

  loc_02C658:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #1B )
    COP [StageForceMoveY] ( #07 )

  loc_02C663:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C675

  loc_02C66A:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C66A
    BRA loc_02C663

  loc_02C675:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #19 )
    COP [StageForceMoveY] ( #07 )

  loc_02C680:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C63B

  loc_02C687:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
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
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

CheckClimbFrame {
    LDA $2A               ; Check climb frame: read $2A event flag; CLC if event occurred (frame data in $24), SEC if no event
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
    COP [BranchIfButton] ( #$8000, &ClimbDropAttack )
    RTS 
}

---------------------------------------------
; Freedan drop attack from vine — triggers ground impact effects.
; 
; Pops the climb loop return address, sets body sprite #06 with hitbox #00. Falls with force Y movement until hitting solid ground (16-pixel boundary check). On landing, loads anim table B entry 2, spawns ImpactTerrainShake and CameraShakeActor (scene $DD skips terrain shake), then plays 39-frame recovery animation before returning to idle.

ClimbDropAttack {
    PLA                   ; Drop attack: pop caller, set body sprite #06, hitbox #00, fall with force move Y #07
    COP [SetPlayerBodySprite] ( #06 )
    COP [StageSprAndHitbox] ( #00 )

  loc_02C6DC:
    COP [StageForceMoveY] ( #07 )

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
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C6E6
    BRA loc_02C6DF
}

ClimbDropLand {
    LDA #$0002            ; Drop landing: load anim table B entry 2, check scene $DD skip, spawn terrain shake + camera shake
    JSR $&attack_ability_system.LoadAbilityAnimTableB
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00DD
    BEQ loc_02C714
    COP [SpawnLastRel] ( @ImpactTerrainShake, #00, #00, #$2400 )

  loc_02C714:
    COP [SpawnLastRel] ( @CameraShakeActor, #00, #00, #$2400 )
    LDA #$003C
    STA $0026, Y
    COP [StageSpriteMoveY] ( #01, #00 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

ImpactTerrainShake {
    LDA #$0010            ; Terrain shake: set playerFlags bit 4 ($0010), wait 479 frames ($01DF), clear flag, die
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
; Two paths based on layerPriorityFlag bit 9 ($0200):
; - Normal: Generate random ±1 offset for both X and Y camera targets using RNG byte (low 2 bits for X, bits 4-5 for Y, each mapped to -1/0/+1).
; - Layer priority active: Save original camera position to actor WRAM on first call ($7F100C/E), apply random offsets, then restore original when shake ends.

CameraShakeFrame {
    LDA $layerPriorityFlag ; Camera shake frame: random ±1 offset to cameraTargetX/Y via RNG byte
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
    LSR                   ; Second RNG for Y axis: (RNG >> 4 & 3) - 1 → add to camera Y target
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
    LDA #$0028            ; Ladder entry south: clear flags, set climb mode ($0100), mask joypad to up/down only ($CFF0)
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFF0
    TSB $joypadMaskStd    ; Ladder entry animation, then check up/down buttons to begin movement or idle
    COP [StagePlayerMoveXY] ( #26, #00, #1B )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    JMP $&LadderIdleNorth
}

LadderClimbNorth {
    LDA #$0028            ; Ladder entry north: same flag setup, different entry animation sprite #28
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #28, #00, #19 )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    BRA LadderIdleSouth
}

LadderMoveDown {
    COP [StagePlayerSprite] ( #2D ) ; Ladder move down: sprite #2D, force Y movement #1D, check 16px boundary for bottom landing

  loc_02C810:
    COP [StageForceMoveY] ( #1D )

  loc_02C813:
    LDA $16
    AND #$000F
    BNE loc_02C81F
    COP [BranchIfSolidTypeSouth] ( #00, &LadderLandBottom )

  loc_02C81F:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C810
    COP [BranchIfNoButton] ( #$0401, &LadderIdleSouth )
    COP [SetEntryExit]
    BRA loc_02C813
}

LadderMoveUp {
    COP [StagePlayerSprite] ( #2C ) ; Ladder move up: sprite #2C, force Y movement #1E, check 16px boundary for top exit

  loc_02C834:
    COP [StageForceMoveY] ( #1E )

  loc_02C837:
    LDA $16
    AND #$000F
    BNE loc_02C843
    COP [BranchIfSolidTypeNorth] ( #00, &LadderReachTop )

  loc_02C843:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C834
    COP [BranchIfNoButton] ( #$0801, &LadderIdleNorth )
    COP [SetEntryExit]
    BRA loc_02C837
}

LadderIdleSouth {
    COP [BranchIfFlagByte] ( #00, #01, &LadderIdleSouthShadow ) ; Ladder idle south: Shadow flag check → normal sprite #2B or Shadow sprite #2F
    COP [StagePlayerSprite] ( #2B )
    BRA loc_02C873
}

LadderIdleSouthShadow {
    COP [StagePlayerSprite] ( #2F ) ; Shadow ladder idle south: sprite #2F
    BRA loc_02C873
}

LadderIdleNorth {
    COP [BranchIfFlagByte] ( #00, #01, &LadderIdleNorthShadow ) ; Ladder idle north: normal sprite #2A or Shadow sprite #2E
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
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    DEC $24
    BPL loc_02C883
    BRA loc_02C877
}

LadderLandBottom {
    COP [StagePlayerMoveY] ( #29, #1A ) ; Ladder bottom landing: animate exit #29, unmask joypad, restore ground flag, return to saved ptr
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]
}

LadderReachTop {
    COP [StagePlayerMoveY] ( #27, #1C ) ; Ladder top exit: animate exit #27, unmask joypad, restore ground flag, return to saved ptr
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  ShimmyRightEntry:
    LDA #$0028            ; Shimmy right entry: clear flags, set climb mode, animate initial shimmy sprite #33 rightward (#51)
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
    COP [StageForceMoveX] ( #51 )

  loc_02C8F2:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE ShimmyRightAnimLoop
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfButton] ( #$0801, &ShimmyRightUpCheck )
    COP [BranchIfButton] ( #$0401, &ShimmyRightDownCheck )

  loc_02C90E:
    COP [BranchIfSolidTypeEast] ( #07, &ShimmyRightAnimLoop )
    COP [BranchIfSolidTypeEast] ( #00, &ShimmyRightAnimLoop )
    JMP $&ShimmyDetachRight
}

ShimmyRightAnimLoop {
    COP [SetEntryContinue] ; Shimmy right animation loop: animate, check button release → detach; re-check wall contact
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C8EF
    COP [BranchIfNoButton] ( #$0101, &ShimmyDetachRight )
    COP [SetEntryExit]
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
    LDA #$0028            ; Shimmy left entry: same setup as right with sprite #32, force move #52 (leftward)
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
    COP [StageForceMoveX] ( #52 )

  loc_02C96F:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE ShimmyLeftAnimLoop
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfButton] ( #$0801, &ShimmyLeftUpCheck )
    COP [BranchIfButton] ( #$0401, &ShimmyLeftDownCheck )

  loc_02C98B:
    COP [BranchIfSolidTypeWest] ( #07, &ShimmyLeftAnimLoop )
    COP [BranchIfSolidTypeWest] ( #00, &ShimmyLeftAnimLoop )
    BRA ShimmyDetachLeft
}

ShimmyLeftAnimLoop {
    COP [SetEntryContinue] ; Shimmy left animation loop
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C96C
    COP [BranchIfNoButton] ( #$0201, &ShimmyDetachLeft )
    COP [SetEntryExit]
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
    COP [StageForceMoveX] ( #00 ) ; Detach right: stop X movement, select normal (#31) or Shadow (#35) sprite, enter wall-hang idle
    COP [BranchIfFlagByte] ( #00, #01, &ShimmyDetachRightShadow )
    COP [StagePlayerSprite] ( #31 )
    BRA loc_02C9DB
}

ShimmyDetachRightShadow {
    COP [StagePlayerSprite] ( #35 ) ; Shadow detach right sprite (#35)
    BRA loc_02C9DB
}

ShimmyDetachLeft {
    COP [StageForceMoveX] ( #00 ) ; Detach left: stop X movement, normal (#30) or Shadow (#34) sprite
    COP [BranchIfFlagByte] ( #00, #01, &ShimmyDetachLeftShadow )
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
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0801, &DetachedCheckUp )
    COP [BranchIfButton] ( #$0401, &DetachedCheckDown )
    COP [BranchIfButton] ( #$0201, &ShimmyLeftCheckWall )
    COP [BranchIfButton] ( #$0101, &ShimmyRightCheckWall )

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
    STZ $2C               ; Top corner: clear movement, restore ground flag ($0008), return to idle via saved ptr
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  AttackFromWalkSouth:
    LDA #$0400            ; Attack-from-walk south: inject south D-pad ($0400) into joypadHeld, fall through to RunSouth
    TSB $joypadHeld
}

RunSouth {
    STZ $invincibilityTimer ; Run south: clear invincibility, sprite #3A, enter shared run loop
    COP [StagePlayerSprite] ( #3A )
    BRA loc_02CA58

  AttackFromWalkNorth:
    LDA #$0800            ; Attack-from-walk north: inject north D-pad ($0800)
    TSB $joypadHeld
}

RunNorth {
    STZ $invincibilityTimer ; Run north: sprite #3B
    COP [StagePlayerSprite] ( #3B )
    BRA loc_02CA58

  AttackFromWalkWest:
    LDA #$0200            ; Attack-from-walk west: inject west D-pad ($0200)
    TSB $joypadHeld
}

RunWest {
    STZ $invincibilityTimer ; Run west: sprite #3C
    COP [StagePlayerSprite] ( #3C )
    BRA loc_02CA58

  AttackFromWalkEast:
    LDA #$0100            ; Attack-from-walk east: inject east D-pad ($0100)
    TSB $joypadHeld
}

RunEast {
    STZ $invincibilityTimer ; Run east: sprite #3D
    COP [StagePlayerSprite] ( #3D )

  loc_02CA58:
    LDA #$2000
    TSB $playerFlags      ; Shared run loop: set run flag ($2000 playerFlags, $0020 actor), clear visibility, animate per frame
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
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CA68
    COP [BranchIfNoButton] ( #$0030, &RunStopToIdle )
    DEC $24
    BMI loc_02CA68
    RTL 
}

RunStopToIdle {
    COP [RestoreSavedPtr] ; Run stop: restore saved ptr → return to PlayerIdleEntry
}

---------------------------------------------
; Inertial east-west movement handler — entered when player has residual EW speed.
; 
; Entered from PlayerIdleEntry when playerSpeedEw is nonzero but no matching D-pad input. Two sub-states based on speed sign: positive → east-facing sprite (#0F), negative → west-facing (#0E). Each frame: animate, check for speed zeroing → restore saved ptr; check for direction reversal → switch sprite; check for run attack; check speed threshold for melee attack; check L/R for run transition.
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
    BRA loc_02CA9C        ; East-facing inertial movement: sprite #0F, animation loop with attack/run checks

  MovingToEast:
    COP [SetEntryExit]    ; Direction switch to east: re-enter with SetEntryExit

  loc_02CA9C:
    COP [StagePlayerSprite] ( #0F )

  loc_02CA9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CA9F
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0200, &MovingToWest )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CACD
    COP [BranchIfButton] ( #$8000, &AttackEast )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkEast )

  loc_02CACD:
    DEC $24
    BMI loc_02CA9F
    RTL 
}

MovingToWest {
    COP [SetEntryExit]    ; Direction switch to west: re-enter with SetEntryExit

  loc_02CAD4:
    COP [StagePlayerSprite] ( #0E )

  loc_02CAD7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CAD7
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0100, &MovingToEast )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CB05
    COP [BranchIfButton] ( #$8000, &AttackWest )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkWest )

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
    COP [SetEntryExit]    ; Direction switch to north: re-enter with SetEntryExit

  loc_02CB24:
    COP [StagePlayerSprite] ( #0D )

  loc_02CB27:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CB27
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0400, &MovingToSouth )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB55
    COP [BranchIfButton] ( #$8000, &AttackNorth )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkNorth )

  loc_02CB55:
    DEC $24
    BMI loc_02CB27
    RTL 
}

MovingToSouth {
    COP [SetEntryExit]    ; Direction switch to south: re-enter with SetEntryExit

  loc_02CB5C:
    COP [StagePlayerSprite] ( #0C )

  loc_02CB5F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CB5F
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0800, &MovingToNorth )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB8D
    COP [BranchIfButton] ( #$8000, &AttackSouth )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkSouth )

  loc_02CB8D:
    DEC $24
    BMI loc_02CB5F
    RTL 
}

---------------------------------------------
; Run attack eligibility gate — Will-only (form 0) ability check.
; 
; Conditions (all must be true): actor flag $0080 clear (not frozen), characterForm == 0 (Will), abilityBitmask bit 1 ($0002) set (dash ability learned), playerFlags bit 12 ($1000) clear (not in walk-attack state). If all pass and attack button ($8000) pressed, branches to RunAttackSpeedCheck.

CheckRunAttack {
    LDA $10               ; Check run attack gate: actor flag $0080 clear, Will only (form 0), abilityBitmask bit 1 ($0002), not flagged $1000
    BIT #$0080
    BNE loc_02CBB4
    LDA $characterForm
    BNE loc_02CBB4
    LDA $abilityBitmask
    BIT #$0002
    BEQ loc_02CBB4
    LDA $playerFlags
    BIT #$1000            ; Attack button pressed during run → RunAttackSpeedCheck
    BNE loc_02CBB4
    COP [BranchIfButton] ( #$8000, &RunAttackSpeedCheck )

  loc_02CBB4:
    RTS 
}

---------------------------------------------
; Route run attack to EW or NS based on which axis has sufficient speed.
; 
; Computes |playerSpeedEw| — if >= 3, pops return and jumps to RunAttackEW. Otherwise computes |playerSpeedNs| — if >= 3, pops return and jumps to RunAttackNS. If neither axis has sufficient speed, returns to caller (no run attack).

RunAttackSpeedCheck {
    LDA $playerSpeedEw    ; Speed check: absolute EW speed >= 3 → RunAttackEW; else check NS speed >= 3 → RunAttackNS
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
; North-south run attack animation — Will's dash attack along vertical axis.
; 
; Loads anim table A entry 1, sets body sprite #04. Branches by speed sign:
; - South (positive): sprites #0C → #0D loop → #0E finish, zeros NS speed
; - North (negative): SetForceNE, sprites #0F → #10 loop → #11 finish
; 
; Both paths: RunAttackFlagSetup (set $0200 actor flag, consume attack, set $0802 playerFlags), loop with AnimLoop for dash distance, RunAttackCleanup, restore saved ptr.

RunAttackNS {
    LDA #$0001            ; Run attack NS: load anim table A entry 1, set body sprite #04; south or north by speed sign
    JSR $&attack_ability_system.LoadAbilityAnimTableA
    COP [SetPlayerBodySprite] ( #04 )
    LDA $playerSpeedNs
    BMI loc_02CC2E
    JSR $&RunAttackFlagSetup
    LDA #$0100            ; South run attack: flag setup, sprite #0C→#0D loop→#0E finish, zero NS speed, cleanup
    TRB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    STZ $playerSpeedNs
    COP [StageSpriteLoopMoveY] ( #0D, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr] ; North run attack: flag setup, SetForceNE, sprite #0F→#10 loop→#11 finish

  loc_02CC2E:
    JSR $&RunAttackFlagSetup
    COP [SetForceNE] ( #01 )
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
    LDA #$0001            ; Run attack EW: same structure for horizontal axis
    JSR $&attack_ability_system.LoadAbilityAnimTableA
    COP [SetPlayerBodySprite] ( #04 )
    LDA $playerSpeedEw
    BPL loc_02CC84
    JSR $&RunAttackFlagSetup
    COP [SetForceSW] ( #01 )
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

DisableStatusForAttack {
    LDA #$0100            ; Disable status overlay: clear $0100 actor flag, set $0200 in layerPriorityFlag
    TRB $10
    LDA #$0200
    TSB $layerPriorityFlag
}

RunAttackFlagSetup {
    LDA #$0200            ; Run attack flag setup: set $0200 actor flag, consume attack button, set $0802 playerFlags
    TSB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0802
    TSB $playerFlags
    RTS 
}

RestoreStatusDisplay {
    LDA #$0200            ; Restore status display: clear $0200 from layerPriorityFlag
    TRB $layerPriorityFlag
}

RunAttackCleanup {
    LDA #$0200            ; Run attack cleanup: clear $0200 actor flag, consume attack button, clear $0002 playerFlags
    TRB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0002
    TRB $playerFlags
    RTS 
}

---------------------------------------------
; South-facing melee attack for all character forms.
; 
; AttackInit strips D-pad, sets joypadHeld, plays form-specific SFX. Injects south D-pad ($0400). Freedan (form 1) checks for wall-adjacent attack via BranchIfSolidSouth — if wall contact, uses push sprite #48 instead of normal #36. Also checks diagonal solid offset for X-axis alignment.
; 
; Scene $00E8 (Dark Gaia fight): spawns ProjectileSouth alongside melee.
; 
; Per-frame loop: Will (form 0) checks perpendicular D-pad ($0B00) for redirect and same-axis D-pad ($0400) for ranged follow-up. Freedan/Shadow check redirect only. On animation end, checks for attack button re-press (combo) or finishes.

AttackSouth {
    JSR $&AttackInit      ; Attack south: init, inject south D-pad, Freedan wall-push check via BranchIfSolidSouth
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
    COP [SpawnLastRel] ( @ProjectileSouth, #00, #00, #$0602 )

  loc_02CD18:
    COP [SetEntryContinue] ; Will (form 0): per-frame redirect check ($0B00 perpendicular D-pad) + ranged follow-up ($0400 south)
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CD1E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CD52
    LDA $characterForm
    BNE loc_02CD45        ; No input → check for attack button re-press (combo) or finish
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &AttackRedirect )
    COP [BranchIfButton] ( #$0400, &RangedAttackSouth )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD45:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &AttackRedirect )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD52:
    COP [BranchIfButton] ( #$8000, &AttackSouth )
    JMP $&AttackFinish
}

AttackNorth {
    JSR $&AttackInit      ; Attack north: init, Freedan wall-push via BranchIfSolidSouth + diagonal offset
    LDA #$0800
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0001
    BNE loc_02CD85
    COP [BranchIfSolidSouth] ( &AttackNorthWallPush )
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
    COP [SpawnLastRel] ( @ProjectileNorth, #00, #D0, #$0602 )

  loc_02CD99:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CD9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CDD3
    LDA $characterForm
    BNE loc_02CDC6
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &AttackRedirect )
    COP [BranchIfButton] ( #$0800, &RangedAttackNorth )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDC6:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &AttackRedirect )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDD3:
    COP [BranchIfButton] ( #$8000, &AttackNorth )
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
    COP [SpawnLastRel] ( @ProjectileWest, #00, #00, #$0602 )

  loc_02CE17:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CE1D:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CE51
    LDA $characterForm
    BNE loc_02CE44
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &AttackRedirect )
    COP [BranchIfButton] ( #$0200, &RangedAttackWest )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE44:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &AttackRedirect )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE51:
    COP [BranchIfButton] ( #$8000, &AttackWest )
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
    COP [SpawnLastRel] ( @ProjectileEast, #00, #00, #$0602 )

  loc_02CE95:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CE9B:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CECF
    LDA $characterForm
    BNE loc_02CEC2
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &AttackRedirect )
    COP [BranchIfButton] ( #$0100, &RangedAttackEast )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CEC2:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &AttackRedirect )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CECF:
    COP [BranchIfButton] ( #$8000, &AttackEast )
    JMP $&AttackFinish
}

---------------------------------------------
; Mid-attack direction change — allows Will to redirect attacks.
; 
; Checks joypadCurrent for any D-pad direction ($0F00). If found, clears the attack button from joypadHeld ($8000) to allow the new direction to be processed. If no D-pad held, falls through to AttackFinish.

AttackRedirect {
    LDA $joypadCurrent    ; Attack redirect: check D-pad ($0F00) for perpendicular direction change mid-attack; clear if none
    BIT #$0F00
    BEQ AttackFinish
    LDA #$8000
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
; Strips D-pad from joypadCurrent (AND #$0F00 to keep only directional bits), sets attack+direction into joypadHeld. Clears visibility flag ($0100). Plays character-form-specific SFX: Will = sound #01 (lighter attack), Freedan/Shadow = sound #02 (heavier attack).

AttackInit {
    LDA $joypadCurrent    ; Attack init: strip D-pad from joypadCurrent, set joypadHeld, clear visibility flag, play SFX
    AND #$0F00
    STA $joypadCurrent
    ORA #$8000
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
; Will-only ranged attack follow-up — south direction.
; 
; Called when Will presses the same D-pad direction during melee attack on scene $E8 or with ranged ability. Sets force movement Y via RangedSetForceY, displays ranged sprite #44, animates once, then clears ranged flags ($0200, AndActorFlags $FFBF) and restores saved ptr.
; 
; North/West/East variants mirror this with direction-specific sprites (#45/#46/#47) and mirror flags ($2000/$4000).

RangedAttackSouth {
    JSR $&RangedSetForceY ; Ranged south: set force Y, sprite #44, animate, then clear flags and restore
    COP [StagePlayerSprite] ( #44 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackNorth {
    JSR $&RangedSetForceY ; Ranged north: set force Y, mirror flag $2000, sprite #45
    LDA #$2000
    TSB $12
    COP [StagePlayerSprite] ( #45 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackWest {
    JSR $&RangedSetForceX ; Ranged west: set force X, mirror flag $4000, sprite #46
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
    COP [AndActorFlags] ( #$FFBF )
    COP [RestoreSavedPtr]
}

RangedSetForceX {
    COP [StageForceMoveX] ( #46 ) ; Ranged set force X: stage force move X #46 for horizontal projectile launch
    BRA loc_02CF52
}

RangedSetForceY {
    COP [StageForceMoveY] ( #46 ) ; Ranged set force Y: stage force move Y #46 for vertical projectile launch

  loc_02CF52:
    LDA #$0800
    TSB $playerFlags
    LDA #$0001
    STA $climbStateData
    LDA #$0200
    TSB $10
    COP [OrActorFlags] ( #$0040 )
    RTS 
}

---------------------------------------------
; Will's ranged projectile actor — south direction.
; 
; Independent spawned actor using table_17D000 metasprite table. Two-phase animation: initial launch (sprite #00, MoveY #09), then looping travel (sprite #04, MoveY #0F). Self-destructs when wall hit detected (bit 14 $4000 in actor flags → COP Die).
; 
; North/West/East variants use matching sprite pairs and MoveX/MoveY directions.

ProjectileSouth {
    COP [SetMetasprite] ( @table_17D000 ) ; Projectile south: metasprite from table_17D000, initial sprite #00 + MoveY #09, then loop #04 + #0F
    COP [StageSpriteMoveY] ( #00, #09 )
    COP [AnimOnce]

  loc_02CF73:
    COP [StageSpriteMoveY] ( #04, #0F )
    COP [AnimOnce]
    LDA $10               ; Loop south: repeat animation until wall hit (bit 14 $4000) then die
    BIT #$4000
    BEQ loc_02CF73
    COP [Die]
}

ProjectileNorth {
    COP [SetMetasprite] ( @table_17D000 ) ; Projectile north: initial #01 + MoveY #0A, loop #05 + #10
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
    COP [SetMetasprite] ( @table_17D000 ) ; Projectile west: initial #02 + MoveX #0A, loop #06 + #10
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
    COP [SetMetasprite] ( @table_17D000 ) ; Projectile east: initial #03 + MoveX #09, loop #07 + #0F
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