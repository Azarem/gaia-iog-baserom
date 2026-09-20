; World map controller — scene $FE actor, route animation, and travel system (238321–239290, Bank 03).
; 
; Main actor for the world map scene. Implements the complete world map experience: player arrival animation, companion dot formation, location name display, table-driven route travel, and scene entry on arrival. Spawned as the sole actor for scene $FE (world map). During travel, spawns the separate HdmaWindowEffect thinker for the iris/spotlight transition.
; 
; === WORLD MAP STATE BLOCK ($0D52–$0D6F) ===
; 
; | Address | Purpose |
; |---------|---------|
; | $0D54/$0D56 | Initial player X/Y position on map |
; | $0D58 | Destination/route selection ID (0 = none) |
; | $0D5A | Route active flag / route ID for playback |
; | $0D5C | Route subroutine return pointer |
; | $0D60–$0D6A | Companion array (6 words, one per party member) |
; | $0D6C | Deferred scene auxiliary data |
; | $0D6E/$0D6F | Deferred scene ID (low = ID, high = area flags) |
; 
; ClearWorldMapState zeroes the entire $0D52–$0D6D range (14 words) on cleanup.
; 
; === PLAYER LIFECYCLE ON WORLD MAP ===
; 
; 1. WorldMapController initializes: reset character form to Will, spawn palette thinkers, clear WRAM flags, mask D-pad ($FFF0 → joypadMaskStd), spawn ArrivalAndTravelSetup as linked child.
; 2. ArrivalAndTravelSetup: positions player sprite at ($0D54,$0D56), centers camera (X−$80, Y−$70), plays 44-frame gravity drop animation (player falls onto map).
; 3. If destination set ($0D58 ≠ 0): spawn HdmaWindowEffect thinker (separate block), dispatch through world_map_options table. DeferSceneTransition captures any pending sceneNext and defers it so the route animation can play.
; 4. If no destination: land directly, spawn location name actor (pr_actor_0BCF52), look up name via LookupMapName, play 93-frame ascent animation.
; 5. Companion dots: scan $0D60 array to count active companions, select formation layout from companion_position_tables, spawn CompanionDotMovement actors for each companion.
; 6. Route playback: RouteAnimationEngine reads route bytecode from world_map_routes — each step specifies X/Y/Z movement delta table indices + frame count. Supports subroutine calls ($FE) with one level of nesting and end markers ($FF).
; 7. On route completion: RouteEndHandler clears route flags, spawns destination name display, plays 59-frame descent animation with Start-button skip. Triggers deferred scene transition.
; 
; === KEY ROUTINES ===
; 
; - DeferSceneTransition: Post-route callback that captures and defers sceneNext/$0652
; - ArrivalAndTravelSetup: Camera, gravity animation, companion formation, route launch
; - CompanionDotMovement: Per-companion dot positioning and animation
; - RouteAnimationEngine: Bytecode interpreter for world_map_routes movement data
; - RouteEndHandler: Descent animation, name display, scene transition trigger
; - LookupMapName: Linear search of world_map_names table for area name string
---------------------------------------------

?BANK 03

?INCLUDE 'actor_pool'
?INCLUDE 'flag_helpers'
?INCLUDE 'HdmaWindowEffect'
?INCLUDE 'movement_delta_table'
?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'world_map_names'
?INCLUDE 'world_map_options'
?INCLUDE 'world_map_routes'

!sceneNext                      0642
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!joypadRaw                      0660
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!characterForm                  0AD4
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch2                   7F002E

---------------------------------------------

; Main actor for scene $FE (world map). Orchestrates the complete world map lifecycle.
; 
; Initialization sequence:
; 1. Reset characterForm to 0 (Will's base form)
; 2. SpawnThinkerParam $0B twice (palette reset thinkers, double-buffered)
; 3. ClearAllWramFlags — reset all WRAM event flags for a clean state
; 4. SpawnAfterFlags ArrivalAndTravelSetup with flags $3800 (linked child)
; 5. Mask D-pad: TSB $FFF0 into joypadMaskStd to prevent player movement
; 6. If $0D58 (destination) is zero → Die immediately (idle arrival, no travel)
; 
; Travel dispatch (when $0D58 ≠ 0):
; 7. SetEntryExit on the spawned child for reentrant cleanup
; 8. Configure child's animScratch2 with ORA $0804 (rendering flags)
; 9. Extract 5-bit option index from $0D58, store in $0000
; 10. SetSavedPtr → DeferSceneTransition (post-route callback)
; 11. SwitchCase through world_map_options table for the selected destination
; 
; The world_map_options handler runs the game-specific route selection logic (presenting choices, setting $0D5A route ID, triggering sceneNext). When it returns, DeferSceneTransition captures and defers the sceneNext so the travel animation can play before the actual scene change.

WorldMapController [
  actor-def < #00, #00, #20, {

  code_03A2F4:
    LDA #$0000            ; Reset to Will's base form (characterForm = 0)
    STA $characterForm
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; First palette reset thinker (type $0B) — double-buffered with second spawn
    JSL $@flag_helpers.ClearAllWramFlags ; Clear all WRAM event flags for clean world map state
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Second palette reset thinker for double-buffer coverage
    COP [SpawnAfterFlags] ( @ArrivalAndTravelSetup, #$3800 ) ; Spawn ArrivalAndTravelSetup as linked child with flags $3800
    LDA #$FFF0            ; Mask D-pad bits ($FFF0) from standard joypad — disable player movement on map
    TSB $joypadMaskStd
    LDA $0D58             ; Check destination ID — zero means no travel selected
    BEQ loc_03A35C        ; No destination → skip to Die (idle arrival only)
    COP [SetEntryHereAndYield]
    PHX                   ; Save actor index, switch to child actor index (Y from SpawnAfterFlags)
    TYX 
    LDA $animScratch2, X
    ORA #$0804            ; ORA $0804 into child's animScratch2: set rendering flags on arrival actor
    STA $animScratch2, X
    PLX 
    LDA $0D58             ; Reload destination → $24 for option dispatch
    STA $24
    AND #$001F            ; Mask to 5-bit index ($001F) for world_map_options table
    STA $0000
    COP [SetSavedPtr] ( &DeferSceneTransition ) ; Set DeferSceneTransition as post-dispatch callback
    COP [SwitchCase] ( #$0000, &world_map_options ) ; Dispatch through world_map_options table for selected destination
} >
]

---------------------------------------------
; Post-route callback — captures and defers any pending scene transition.
; 
; Called via SetSavedPtr after the world_map_options handler completes. If $0D5A (route active) is zero, the player chose no destination → Die.
; 
; Otherwise: saves sceneNext → $0D6E and $0652 → $0D6C (auxiliary scene data), then clears both to prevent an immediate transition. The deferred values are restored later by RouteEndHandler or SkipToSceneTransition after the travel animation finishes.

DeferSceneTransition {
    LDA $0D5A             ; Check route active flag — zero means player chose no destination
    BEQ loc_03A35C        ; No active route → Die
    SEP #$20
    LDA $sceneNext        ; Save pending sceneNext to $0D6E — defer scene transition
    STA $0D6E
    REP #$20
    LDA $0652             ; Save auxiliary scene data ($0652) to $0D6C
    STA $0D6C
    STZ $0652             ; Clear $0652 to prevent immediate transition
    STZ $sceneNext        ; Clear sceneNext — transition is now deferred until route completes

  loc_03A35C:
    COP [Die]
}

---------------------------------------------
; Camera positioning, gravity animations, companion formation, and route launch controller.
; 
; Spawned as a linked child from WorldMapController. Runs through several sequential phases:
; 
; === PHASE 1: CAMERA AND GRAVITY DROP ===
; 
; Position player sprite at ($0D54, $0D56). Center camera at (X−$80, Y−$70). InitGravity(#20, #05, #00) with 44-frame loop: accumulates moveScratch2 into $00B8 each frame for a gravity-based drop animation (player icon falls onto the map from above).
; 
; === PHASE 2: ROUTE LAUNCH (if $0D58 ≠ 0) ===
; 
; Wait 15 frames, spawn HdmaWindowEffect thinker for the iris transition. SetEntryContinue → poll $0D5A: when nonzero the route is active and this actor yields each frame. When $0D5A clears (route done), falls through to Phase 3.
; 
; === PHASE 3: LANDING AND LOCATION NAME ===
; 
; Read area ID from $0D6F, spawn pr_actor_0BCF52 (text renderer) with flags $2000. LookupMapName to find the name string. Store name pointer into spawned actor's $0026 field. InitGravity(#00, #07, #00) with 93-frame loop: accumulates horizontal movement into $00B6 + increments $00B8 (expansion/settle animation). Clear movement and $2000 flag from actor flags.
; 
; === PHASE 4: COMPANION FORMATION ===
; 
; Scan $0D60 array (6 words) to count active companions. Index into companion_position_tables to select a layout: 7 pointer entries map companion counts to binary position data (X,Y offset pairs). Load the player's last position as formation center.
; 
; For each active companion ($0D60,Y ≠ 0): SpawnAfterFlags CompanionDotMovement with flags $1800. Pass the companion ID ($0028,Y), position data ([$18] → $0024,Y), and center reference ($24 → $0026,Y). Advance the position pointer by 2 bytes per companion.
; 
; After spawning: store final position into orbitDiameter, play 2 animation frames, clear $00DA, spawn RouteAnimationEngine as predecessor, then fall through to the CompanionDotMovement shared animation loop at loc_03A497.

ArrivalAndTravelSetup {
    LDA $0D54             ; Load initial player X from $0D54 → sprite X ($14)
    STA $14
    SEC 
    SBC #$0080            ; Camera target X = player X − $80 (center 256px screen)
    STA $cameraTargetX
    LDA $0D56             ; Load initial player Y from $0D56 → sprite Y ($16)
    STA $16
    SEC 
    SBC #$0070            ; Camera target Y = player Y − $70 (center 224px screen)
    STA $cameraTargetY
    COP [InitGravity] ( #20, #05, #00 ) ; InitGravity: velocity $20, gravity $05, floor $00 — fast initial drop
    COP [LoopStart] ( #2C ) ; 44-frame gravity loop for arrival drop animation
    COP [TickGravity]
    LDA $moveScratch2, X  ; Accumulate gravity delta (moveScratch2) into $00B8 — player falls each frame
    CLC 
    ADC $00B8
    STA $00B8
    COP [SetEntryHereAndYield]
    COP [LoopEnd]
    LDA $0D58             ; Check destination — zero means no route to play
    BEQ loc_03A3A4
    COP [WaitByte] ( #0F ) ; Wait 15 frames before HDMA effect starts
    COP [SpawnThinker] ( @HdmaWindowEffect ) ; Spawn HdmaWindowEffect thinker for iris transition during travel
    COP [SetEntryHere]
    LDA $0D5A             ; Poll $0D5A (route active): nonzero = route still playing, skip ahead
    BNE loc_03A3A4
    RTL                   ; RTL to yield — route animation engine handles movement each frame

  loc_03A3A4:
    LDA $0D6F             ; Load area ID from $0D6F (high byte of deferred scene)
    AND #$00FF
    STA $0000
    COP [SpawnBeforeFlags] ( @pr_text_placement_calc, #$2000 ) ; Spawn name display actor (pr_actor_0BCF52) with flags $2000
    JSR $&LookupMapName   ; Look up area name string from world_map_names table
    TYA                   ; Transfer name string pointer (Y) → save into spawned actor's $0026
    LDY $04
    STA $0026, Y
    COP [InitGravity] ( #00, #07, #00 ) ; InitGravity: velocity $00, gravity $07, floor $00 — slow expansion
    COP [LoopStart] ( #5D ) ; 93-frame ascent/expansion loop for landing animation
    COP [TickGravity]
    LDA $00B6             ; Accumulate gravity into $00B6 (horizontal spread movement)
    CLC 
    ADC $moveScratch2, X
    STA $00B6
    INC $00B8             ; Increment $00B8 each frame (vertical settle)
    COP [LoopEnd]
    LDA #$0000            ; Clear moveScratch2 — reset per-frame movement delta
    STA $moveScratch2, X
    LDA #$2000            ; Clear $2000 from actor flags $10 (re-enable Select-related processing)
    TRB $10
    LDY #$0000

  loc_03A3E6:
    INY                   ; Scan companion array: advance Y by 2 per entry (16-bit words)
    INY 
    CPY #$000C            ; CPY $000C = 6 entries max (indices 0,2,4,6,8,10)
    BCS loc_03A3F2
    LDA $0D60, Y          ; Check $0D60,Y — nonzero = active companion, continue scanning
    BNE loc_03A3E6

  loc_03A3F2:
    PHX                   ; Use companion count (Y) as index into companion_position_tables
    TYX 
    DEX 
    DEX 
    LDA $@companion_position_tables, X ; Load layout data pointer for this companion count
    STA $18
    LDA #$*companion_position_tables ; Bank byte of companion_position_tables → $1A for long addressing
    STA $1A
    PLX 
    LDA $0D60             ; First companion ID ($0D60) → $28 as formation leader
    STA $28
    LDA [$18]             ; Read first position pair from layout data (packed X,Y byte pair)
    STA $24
    AND #$00FF            ; Extract low byte (X offset) + cameraTargetX = screen X
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $25
    AND #$00FF            ; Extract high byte (Y offset) + cameraTargetY = screen Y
    CLC 
    ADC $cameraTargetY
    STA $16
    INC $18               ; Advance layout pointer past 2-byte position pair
    INC $18
    LDY #$0000

  loc_03A426:
    INY                   ; Inner companion spawn loop: advance past first entry (already processed)
    INY 
    STY $26
    LDA $0D60, Y          ; Check if companion slot is active ($0D60,Y ≠ 0)
    BEQ loc_03A450        ; Zero = no more companions in this slot → done spawning
    PHA 
    COP [SpawnAfterFlags] ( @CompanionDotMovement, #$1800 ) ; Spawn CompanionDotMovement actor with flags $1800 for this companion
    PLA 
    STA $0028, Y          ; Store companion ID from stack into spawned actor's $0028 field
    LDA [$18]             ; Read next position pair from layout data
    STA $0024, Y
    LDA $24               ; Pass center reference position into spawned actor's $0026
    STA $0026, Y
    INC $18
    INC $18
    LDY $26
    CPY #$000A
    BCC loc_03A426

  loc_03A450:
    LDA $24               ; Store final formation center position into this actor's orbitDiameter
    STA $orbitDiameter, X
    COP [LoopStart] ( #02 ) ; 2-frame entry animation before route begins
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
    STZ $00DA             ; Clear $00DA (shared animation state)
    COP [SpawnBefore] ( @RouteAnimationEngine ) ; Spawn RouteAnimationEngine as predecessor (runs before this actor)
    BRA loc_03A497        ; Fall through to shared CompanionDotMovement animation loop
}

---------------------------------------------
; Per-companion dot actor — move to formation position and animate.
; 
; Entry: stores the companion's assigned diameter ($26) into orbitDiameter and position pair ($24) into orbitAngle. Extracts low byte as X offset + cameraTargetX → moveXAlt, high byte as Y offset + cameraTargetY → moveYAlt. MoveToward(#FF, #01) to glide toward target at max speed, 1px/frame.
; 
; === SHARED ANIMATION LOOP (loc_03A497) ===
; 
; SetEntryContinue → AnimOneFrame → capture frame counter from $08 into $26 (animation timer). Each tick: recompute position from $24 (low byte = X offset + cameraTargetX → $14, high byte via XBA = Y offset + cameraTargetY → $16).
; 
; If route active ($0D5A ≠ 0): decrement $26 timer; when negative, loop back to loc_03A497 for another animation cycle. When timer still positive, yield (RTL).
; 
; If route done ($0D5A = 0): compute home position from orbitDiameter (X component + cameraTargetX → moveXAlt, Y from $7F0013 + cameraTargetY → moveYAlt). If already at home position (both X and Y match) → Die. Otherwise MoveToward(#FF, #01) one more step toward home, then Die.

CompanionDotMovement {
    LDA $26               ; Store assigned diameter ($26) into per-actor orbitDiameter
    STA $orbitDiameter, X
    LDA $24               ; Store position pair into orbitAngle (packed X,Y offsets)
    STA $orbitAngle, X
    AND #$00FF            ; Extract X offset (low byte) + cameraTargetX → moveXAlt target
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    LDA $25               ; Extract Y offset (high byte) + cameraTargetY → moveYAlt target
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 ) ; Glide toward target: speed $FF, step 1px per frame
    LDA $orbitAngle, X    ; Reload position pair from orbitAngle for animation calculations
    STA $24

  loc_03A497:
    COP [SetEntryHere]    ; Shared animation loop entry: yield for next frame
    COP [AnimOneFrame]
    LDA $08               ; Capture animation frame counter from $08, clear it
    STZ $08
    STA $26
    COP [SetEntryHere]
    LDA $24               ; Recompute screen X from low byte of $24 + cameraTargetX
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $24
    XBA                   ; XBA to swap bytes: extract high byte as Y offset
    AND #$00FF
    CLC 
    ADC $cameraTargetY    ; Compute screen Y from extracted offset + cameraTargetY
    STA $16
    LDA $0D5A             ; Route active? ($0D5A ≠ 0 → stay in animation loop)
    BEQ loc_03A4C6
    DEC $26               ; Decrement animation timer; negative = restart cycle
    BMI loc_03A4C4
    RTL                   ; Timer still positive → yield for next frame (RTL)

  loc_03A4C4:
    BRA loc_03A497

  loc_03A4C6:
    LDA $orbitDiameter, X ; Route done: compute home position X from orbitDiameter + cameraTargetX
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    CMP $14               ; Check if already at home X position
    BNE loc_03A4EE
    LDA $7F0013, X        ; Compute home Y from $7F0013 (orbitDiameter high byte) + cameraTargetY
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    CMP $16               ; Check if already at home Y position
    BNE loc_03A4EE
    COP [Die]             ; At home position (both X and Y match) → Die

  loc_03A4EE:
    LDA $7F0013, X        ; Not at home yet: recompute Y target for final MoveToward
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 ) ; One final step toward home position, then die
    COP [Die]
}

companion_position_tables [
  &binary_03A511   ;00
  &binary_03A521   ;01
  &binary_03A511   ;02
  &binary_03A511   ;03
  &binary_03A525   ;04
  &binary_03A511   ;05
  &binary_03A511   ;06
]

binary_03A511 #80807090909068A098A0809860B0A0B0

binary_03A521 #78808880

binary_03A525 #80807090909068A098A0

---------------------------------------------
; Table-driven route step interpreter — reads bytecode from world_map_routes.
; 
; Entry: load route pointer from world_map_routes[$0D5A × 2] into $2C/$2E (long pointer). Fall into RouteStepLoop.
; 
; === ROUTE BYTECODE FORMAT ===
; 
; Each step is a variable-length sequence read byte-by-byte from [$2C]:
; - $FF = end of route → RouteEndHandler
; - $FE = subroutine call → RouteSubroutineCall (saves return, reads 2-byte target)
; - Otherwise: 4-byte movement step
; 
; === MOVEMENT STEP (4 bytes) ===
; 
; Byte 1 (step type): × 2 → index into movement_delta_table for X movement delta source pointer → $18
; Byte 2: × 2 → index into movement_delta_table for Y movement delta source pointer → $1A
; Byte 3: × 2 → index into movement_delta_table for Z movement delta source pointer → $1C
; Byte 4: frame count → $24
; 
; Each frame, for each non-null axis pointer ($18/$1A/$1C):
; 1. Read 16-bit delta from indirect pointer: LDA ($ptr)
; 2. Advance pointer past delta: INC $ptr × 2
; 3. Add delta to world position ($00CA for X, $00CC for Y, $00BC for Z)
; 4. Update camera target (world − screen center offset: X−$80, Y−$70)
; 5. Read next pointer word (velocity/acceleration chain): LDA ($ptr) → $ptr
; 
; Decrement frame count ($24). When negative, jump back to RouteStepLoop for next step.
; 
; The movement_delta_table contains pointers to pre-computed movement delta sequences (velocity curves, arcs, straight-line deltas) shared with forced_walk and hit_stagger systems.

RouteAnimationEngine {
    PHX                   ; Load route pointer: world_map_routes[$0D5A × 2] → $2C/$2E
    LDA $0D5A
    ASL 
    TAX 
    LDA $@world_map_routes, X
    STA $2C
    LDA #$*world_map_routes
    STA $2E
    PLX 

  RouteStepLoop:
    LDA [$2C]             ; Read route step type byte from [$2C]
    AND #$00FF
    CMP #$00FF            ; $FF = end-of-route marker → RouteEndHandler
    BNE loc_03A54E
    JMP $&RouteEndHandler

  loc_03A54E:
    INC $2C               ; Advance past type byte
    CMP #$00FE            ; $FE = subroutine call marker → RouteSubroutineCall
    BNE loc_03A558
    JMP $&RouteSubroutineCall

  loc_03A558:
    ASL                   ; Step type × 2 → index into movement_delta_table for X delta source
    TAY 
    LDA $&movement_delta_table, Y
    STA $18
    LDA [$2C]             ; Read Y movement table index (byte 2)
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&movement_delta_table, Y ; Look up Y delta source pointer from movement_delta_table
    STA $1A
    LDA [$2C]             ; Read Z movement table index (byte 3)
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&movement_delta_table, Y ; Look up Z delta source pointer from movement_delta_table
    STA $1C
    LDA [$2C]             ; Read frame count (byte 4) → $24
    AND #$00FF
    INC $2C
    STA $24
    COP [SetEntryHere]    ; Yield one frame per route step iteration
    LDA $18               ; X axis: check for null pointer (0 = no X movement this step)
    BEQ loc_03A5A2
    LDA ($18)             ; Read X delta from indirect pointer, advance pointer by 2
    INC $18
    INC $18
    CLC 
    ADC $00CA             ; Add X delta to world X position ($00CA)
    STA $00CA
    SEC 
    SBC #$0080            ; Camera target X = world X − $80 (re-center)
    STA $cameraTargetX
    LDA ($18)             ; Read next X pointer word (chain to next delta source)
    STA $18

  loc_03A5A2:
    LDA $1A               ; Y axis: check for null pointer
    BEQ loc_03A5BE
    LDA ($1A)             ; Read Y delta from indirect pointer
    INC $1A
    INC $1A
    CLC 
    ADC $00CC             ; Add Y delta to world Y position ($00CC)
    STA $00CC
    SEC 
    SBC #$0070            ; Camera target Y = world Y − $70 (re-center)
    STA $cameraTargetY
    LDA ($1A)             ; Read next Y pointer word
    STA $1A

  loc_03A5BE:
    LDA $1C               ; Z axis: check for null pointer
    BEQ loc_03A5D3
    LDA ($1C)             ; Read Z delta from indirect pointer
    INC $1C
    INC $1C
    CLC 
    ADC $00BC             ; Add Z delta to elevation ($00BC)
    STA $00BC
    LDA ($1C)             ; Read next Z pointer word
    STA $1C

  loc_03A5D3:
    DEC $24               ; Decrement frame count; negative = step complete → next step
    BMI loc_03A5D8
    RTL                   ; Frame count still positive → yield (RTL) for next tick

  loc_03A5D8:
    JMP $&RouteStepLoop
}

---------------------------------------------
; Start-button fast travel — immediately trigger the deferred scene transition.
; 
; Restores $0D6E → sceneNext and $0D6C → $0652 (the values saved by DeferSceneTransition), calls ClearWorldMapState to zero the state block, then yields via SetEntryContinue + RTL. The scene transition takes effect on the next main loop iteration.

SkipToSceneTransition {
    LDA $0D6E             ; Start skip: restore deferred scene ID ($0D6E) → sceneNext
    AND #$00FF
    STA $sceneNext
    LDA $0D6C             ; Restore auxiliary data ($0D6C) → $0652
    STA $0652
    JSR $&ClearWorldMapState ; Clear entire world map state block
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Route $FE handler — one-level subroutine call within route bytecode.
; 
; Saves return address ($2C + 2 → $0D5C), loads 2-byte target from [$2C] → $2C, and jumps to RouteStepLoop. Only one level of nesting is supported; a second $FE overwrites $0D5C.

RouteSubroutineCall {
    LDA $2C               ; Save return address ($2C + 2) → $0D5C for subroutine return
    INC 
    INC 
    STA $0D5C
    LDA [$2C]             ; Load 2-byte subroutine target from route data → $2C
    STA $2C
    JMP $&RouteStepLoop   ; Jump to RouteStepLoop to execute subroutine
}

---------------------------------------------
; Route $FF handler — processes end-of-route or subroutine return.
; 
; If $0D5C (subroutine return) is nonzero: clear $0D5C, restore $2C from saved pointer, continue RouteStepLoop (subroutine return).
; 
; Otherwise (true route end):
; 1. Clear $0D5A (route active) and $0D58 (destination)
; 2. Spawn pr_actor_0BCF52 name display for destination area ($0D6E)
; 3. LookupMapName → store name into spawned actor
; 4. WaitByte #$3B (59 frames) for name display
; 5. SetEntryContinue descent loop: decrement $00B6 by $10 per frame (player descends toward surface). Check Start button ($1000 in joypadRaw) → SkipToSceneTransition for fast travel.
; 6. When $00B6 goes negative (landing complete): zero $00B6, SetEntryExit, clear $00DA, set $0800 flag in actor flags, InitGravity(#00, #06, #00), load gfxCacheIdxB = $0406, restore deferred scene ($0D6E → sceneNext, $0D6C → $0652), ClearWorldMapState, play gravity landing via TickGravity loop.

RouteEndHandler {
    LDA $0D5C             ; Check subroutine return pointer ($0D5C)
    BEQ loc_03A60B        ; Zero = no return pending → true end of route
    STZ $0D5C             ; Clear return pointer, restore $2C, continue processing
    STA $2C
    JMP $&RouteStepLoop

  loc_03A60B:
    STZ $0D5A             ; True route end: clear route active flag ($0D5A)
    STZ $0D58             ; Clear destination ($0D58)
    LDA $0D6E             ; Load destination area ID from $0D6E for name display
    AND #$00FF
    STA $0000
    COP [SpawnAfterFlags] ( @pr_text_placement_calc, #$2000 ) ; Spawn name display actor for destination area
    JSR $&LookupMapName   ; Look up destination area name
    TYA 
    LDY $06
    STA $0026, Y          ; Store name pointer into spawned actor's $0026
    COP [WaitByte] ( #3B ) ; Display destination name for 59 frames ($3B)
    COP [SetEntryHere]
    LDA $00B6             ; Descent loop: decrement $00B6 (altitude) by $10 per frame
    SEC 
    SBC #$0010
    BMI loc_03A644        ; Altitude negative → landing complete
    STA $00B6
    LDA $joypadRaw        ; Check Start button ($1000 in raw joypad) for fast travel skip
    BIT #$1000
    BNE SkipToSceneTransition ; Start pressed → SkipToSceneTransition (bypass descent animation)
    RTL 

  loc_03A644:
    LDA #$0000            ; Landing: zero altitude ($00B6)
    STA $00B6
    COP [SetEntryHereAndYield] ; SetEntryExit for reentrant landing sequence
    STZ $00DA
    LDA #$0800            ; Set $0800 flag in actor flags (special state during landing)
    TSB $10
    COP [InitGravity] ( #00, #06, #00 ) ; InitGravity: velocity 0, gravity 6 — gentle landing bounce
    LDA #$0406            ; Set gfxCacheIdxB = $0406 for landing graphics
    STA $gfxCacheIdxB
    LDA $0D6E             ; Restore deferred scene ID ($0D6E) → sceneNext
    AND #$00FF
    STA $sceneNext
    LDA $0D6C             ; Restore auxiliary data ($0D6C) → $0652
    STA $0652
    JSR $&ClearWorldMapState ; Clear world map state block
    COP [SetEntryHere]
    COP [TickGravity]
    LDA $moveScratch2, X  ; Landing gravity: accumulate moveScratch2 into $00B8
    CLC 
    ADC $00B8
    STA $00B8
    RTL 
}

---------------------------------------------
; Zero the world map state block $0D52–$0D6D (14 words / 28 bytes).
; 
; Simple memset loop: stores $0000 to $0D52,Y with Y incrementing by 2, until CPY #$001C. Clears all travel state including position, destination, route, companions, and deferred scene data.

ClearWorldMapState {
    LDA #$0000            ; Zero-fill loop: $0000 → $0D52 through $0D6C (14 words)
    LDY #$0000

  loc_03A687:
    STA $0D52, Y
    INY 
    INY 
    CPY #$001C
    BCC loc_03A687
    RTS 
}

---------------------------------------------
; Linear search through the world_map_names table for an area name string pointer.
; 
; Sets DBR to world_map_names bank, then iterates 3-byte entries (1 byte area ID, 2 bytes name pointer). Compares each ID byte against $0000 (target area). On match: loads the 2-byte name pointer into Y and returns. On table end (zero byte): returns with Y unchanged (no match). Each entry is 3 bytes, so X advances by 3 per iteration.

LookupMapName {
    PHP                   ; Save registers, set up 8-bit mode for byte comparison
    PHX 
    LDX #$0000
    SEP #$20
    PHB 
    LDA #$^world_map_names ; Set DBR to world_map_names bank for direct addressing
    PHA 
    PLB 

  loc_03A69E:
    LDA $&world_map_names, X ; Read area ID byte from world_map_names[X]
    BEQ loc_03A6B6        ; Zero byte = end of table → not found
    CMP $0000             ; Compare against target area ID ($0000)
    BEQ loc_03A6AD        ; Match → load name pointer
    INX                   ; No match: advance X by 3 (each entry = 1 byte ID + 2 byte pointer)
    INX 
    INX 
    BRA loc_03A69E

  loc_03A6AD:
    REP #$20              ; Match found: switch to 16-bit, load name pointer from world_map_names+1
    LDY $&world_map_names+1, X
    PLB 
    PLX 
    PLP 
    RTS 

  loc_03A6B6:
    PLB 
    PLX 
    PLP 
    RTS 
}