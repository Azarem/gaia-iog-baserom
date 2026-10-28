; World map controller (scene $FE actor, Bank 03, 238321-239290). The scene is a Mode 7 map; this file runs the arrival zoom, the destination menu, the companion dots, the route playback and the dive into the destination scene.
; 
; === HOW A TRIP STARTS ===
; 
; Both kinds of trip arrive through CheckSceneTransition / ExecuteSceneTransition, which see a nonzero $0D52/$0D53 and then move $0D52 -> $0D54 (worldMapPlayerX), $0652 -> $0D6C, sceneNext -> $0D6E and sceneCurrent -> $0D6F, and switch to scene $FE:
; - Menu trip: the exit actor in a town or dungeon entrance (overworld_exit) writes $0D60 := 0 and runs COP StageWorldMapChoice (start X, start Y, choice id). The choice id in $0D58 selects a menu in world_map_options.
; - Scripted trip: an NPC departure script (13 of them, e.g. ec0A_kara, wa79_neil, daC8_neil) fills the party array, runs COP StageWorldMapMove (start X, start Y, 0, route id) and has already queued the destination with QueueMapChange. StageWorldMapMove clears $0D58, so there is no menu.
; 
; === STATE BLOCK $0D52-$0D6F ===
; 
; | Address | Meaning |
; |---------|---------|
; | $0D52 | staged start X; nonzero = a world-map entry is pending (moved to $0D54 and cleared on arrival) |
; | $0D54 / $0D56 | worldMapPlayerX / Y: start position on the 1024 x 1024 map |
; | $0D58 | choice id (0 = none). The low 5 bits index world_map_options |
; | $0D5A | route id (0 = none). Index into world_map_route_table, set by COP #65 / #67 |
; | $0D5C | route subroutine return pointer (0 = none) |
; | $0D5E | written by COP #65 / #67 (always 0), never read |
; | $0D60-$0D6A | party array: six words of spm_overworld_sprites animation indices. $0D60 is the leader, $0D62-$0D6A are up to five companions, 0 = empty |
; | $0D6C | deferred $0652 (scroll parameters of the queued scene change) |
; | $0D6E | destination scene (low byte); a scripted trip gets it from ExecuteSceneTransition, a menu trip from DeferSceneTransition |
; | $0D6F | scene being left (the start name is looked up with it) |
; 
; ClearWorldMapState zeroes $0D52-$0D6D (14 words, CPY #$001C), so $0D6E/$0D6F survive the trip.
; 
; === MODE 7 PARAMETERS THE CONTROLLER DRIVES ===
; 
; Mode7PerspectiveInit (scene thinker, see mode7_perspective) sets the global words $B8 := $0400, $B6 := 0, $BC := 0 and the centre $CA/$CC := ($0D54, $0D56). Per frame it turns them into the M7A-M7D HDMA tables:
; - $B8 is the divisor at the top scanline: smaller = zoomed out, larger = zoomed in ($80 is about 1:1).
; - $B6 is how much the divisor grows per scanline: 0 = flat map, larger = stronger perspective.
; - $BC is the rotation index (512 steps per turn). Route steps change it, so the map turns during a trip. The old comments called it elevation.
; - $CA/$CC are the world X/Y (map centre). cameraTargetX/Y follow as centre - ($80, $70).
; 
; === TIMELINE ===
; 
; 1. WorldMapController (WorldMapControllerEntry): characterForm := 0, two palette-reset thinkers (bundle $0B: Will's normal sprite colours, CGRAM $81-$8F), ClearAllWramFlags, mask the buttons, spawn ArrivalAndTravelSetup as a child (flags $3800). With no choice id it dies here; otherwise it gives the child animScratch2 |= $0804, saves DeferSceneTransition with SetSavedPtr and runs world_map_options[choice & $1F] (menu and handler).
; 2. ArrivalAndTravelSetup, 44 ticks: places itself (the leader's dot) at the start position, centres the camera, then each tick adds the TickGravity delta (always negative: -$20 rising to about -2) to $B8. The divisor falls from $0400 to about $34 (hand-computed), a zoom-out from 8x in to a wide view.
; 3. Menu trips only: wait 16 ticks (WaitByte #0F), spawn WorldMapSplitEffect, then poll $0D5A every frame (RTL = try again next frame) while the menu is open. Choosing Quit leaves it at 0: the handler has already queued the scene you came from and DeferSceneTransition just dies, so this actor idles until the scene changes.
; 4. Tilt phase (TiltPhaseStart), 93 ticks: shows the start-area name (see world_map_scene_names), adds the TickGravity delta ((t * (t >> 1)) >> 7, growing) to $B6 and 1 to $B8. $B6 ends at about $03F0, so the flat map tilts into a strong perspective view. Then the name is cleared ($00DA := 0).
; 5. Companion dots: the party array is scanned from $0D62, N companions pick entry N of companion_formation_tables, and one CompanionDotMovement actor per companion is spawned. RouteAnimationEngine is spawned and this actor becomes the leader's dot.
; 6. RouteAnimationEngine plays the route bytes (see world_map_route_table): X, Y and rotation steps change $CA/$CC/$BC.
; 7. RouteEndHandler: dots die, the destination name shows for 60 ticks (WaitByte #3B), $B6 falls by $10 per frame until the map is flat again (Start skips everything), then the deferred sceneNext/$0652 are restored and the controller dives: $B8 grows by an increasing delta, a zoom-in while the scene exit transition runs.
; 
; === SPRITES (spm_overworld_sprites) ===
; 
; The spritemap (scene_meta_00FE, $1238 bytes, gfx_overworld_actors, palette pal_overworld_sprites at colour $90) has 14 animations; the spm_overworld_sprites block note lists them. The leader and companion dots use the animation index from the party array as actor field $28.
; - 0-5: 4-frame cycles (hold 7), one per party slot value (art identity not checked). 6: one 16 x 16 part in 4 frames.
; - 7-A: four 5-frame sets. wa79_neil fills the party array with 7, 8, 9, A for the Watermia to Euro leg (menu handlers set only $0D60 := 7), so these look like the pieces of one vehicle (not checked at runtime).
; - B: 3 frames of hold 1, a 79 x 48 px box of 24 parts, used as the leader by daC8_neil (Dao to Over Babel). C: the same box with 27 parts, no writer found. D: 4 frames of hold 9, 48-64 x 64 px, used as the leader by wa78_men (Watermia to South Cape).
; 
; === KEY ROUTINES ===
; 
; - DeferSceneTransition: callback after the menu handler; keeps the queued scene out of the way while the route plays.
; - ArrivalAndTravelSetup: arrival zoom, menu wait, tilt phase, dot formation, route launch; then runs as the leader's dot.
; - CompanionDotMovement: one companion dot (also the shared dot loop).
; - RouteAnimationEngine: interpreter for the world_map_route_table bytes. RouteEndHandler: end-of-route name, untilt and dive.
; - LookupMapName: scene id -> name string pointer.
---------------------------------------------

?BANK 03

?INCLUDE 'actor_pool'
?INCLUDE 'flag_helpers'
?INCLUDE 'move_chain_table'
?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'world_map_options'
?INCLUDE 'world_map_route_table'
?INCLUDE 'world_map_scene_names'
?INCLUDE 'WorldMapSplitEffect'

!sceneNext                      0642
!gfxCacheIdxB                   064A
!warpScrollParams               0652
!joypadMaskStd                  065A
!joypadRaw                      0660
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!characterForm                  0AD4
!worldMapStagedX                0D52
!worldMapPlayerX                0D54
!worldMapPlayerY                0D56
!worldMapChoiceId               0D58
!worldMapRouteId                0D5A
!worldMapRouteReturnPtr         0D5C
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch2                   7F002E

---------------------------------------------

; Controller actor of scene $FE. Resets the character form and palettes, spawns ArrivalAndTravelSetup, and for a menu trip runs the world_map_options handler for the choice id (the handler ends in RestoreSavedPtr, which returns to DeferSceneTransition). With no choice id (scripted trip) it dies at once and the child does all the work.

WorldMapController [
  actor-def < #00, #00, #20, {

; Entry of the controller actor: characterForm := 0, a palette-reset thinker for bundle $0B (twice), ClearAllWramFlags, ArrivalAndTravelSetup spawned as a child (flags $3800), the buttons masked. With no choice id it goes to WorldMapControllerDie; otherwise it yields once, sets the child's animScratch2 bits, saves DeferSceneTransition with SetSavedPtr and runs world_map_options[choice id & $1F].

  WorldMapControllerEntry:
    LDA #$0000            ; Reset to Will's base form (characterForm = 0)
    STA $characterForm
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Palette reset thinker, bundle $0B = Will's 15 normal colours at CGRAM $81-$8F (PaletteRestart + PaletteStep, then it kills itself)
    JSL $@flag_helpers.ClearAllWramFlags ; Clear all WRAM event flags for clean world map state
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Same palette reset thinker spawned a second time (reason not known, OQ-I059-2)
    COP [SpawnAfterFlags] ( @ArrivalAndTravelSetup, #$3800 ) ; Spawn ArrivalAndTravelSetup as linked child with flags $3800
    LDA #$FFFC            ; Suppress nearly all buttons in joypadCurrent (shipped $FFFC, vanilla $FFF0); Start is still read from joypadRaw
    TSB $joypadMaskStd
    LDA $worldMapChoiceId ; Menu trip (choice id set) or scripted trip (0: nothing to dispatch, this actor dies below)
    BEQ WorldMapControllerDie ; No destination → skip to Die (idle arrival only)
    COP [SetEntryHereAndYield]
    PHX                   ; Save actor index, switch to child actor index (Y from SpawnAfterFlags)
    TYX 
    LDA $animScratch2, X
    ORA #$0804            ; Child's animScratch2 |= $0804 (bits 2 and 11, the thinker filter flags; effect on an actor not verified, OQ-I059-1)
    STA $animScratch2, X
    PLX 
    LDA $worldMapChoiceId ; Reload destination → $24 for option dispatch
    STA $24
    AND #$001F            ; Choice id low 5 bits = index into world_map_options (ids $01-$1B are staged, $1C-$26 never)
    STA $0000
    COP [SetSavedPtr] ( &DeferSceneTransition ) ; Each menu handler ends in RestoreSavedPtr, which returns to DeferSceneTransition
    COP [SwitchCase] ( #$0000, &world_map_options ) ; Run world_map_options[choice]: the menu, then the chosen handler
} >
]

---------------------------------------------
; Callback after the menu handler. Route id 0 means the player chose Quit (the handler queued the scene they came from), so it just dies and the normal scene change happens. Otherwise it moves the queued destination into $0D6E (low byte only, $0D6F keeps the source scene) and $0652 into $0D6C, then clears both so the scene does not change until the route has played.

DeferSceneTransition {
    LDA $worldMapRouteId  ; Route id still 0: the player chose Quit, so just die (the handler already queued the origin scene)
    BEQ WorldMapControllerDie ; No active route → Die
    SEP #$20
    LDA $sceneNext        ; Save pending sceneNext to $0D6E — defer scene transition
    STA $0D6E             ; Destination scene -> $0D6E, low byte only (the source scene stays in $0D6F)
    REP #$20
    LDA $warpScrollParams ; Save auxiliary scene data ($0652) to $0D6C
    STA $0D6C             ; $0652 (scroll parameters of the queued scene change) -> $0D6C
    STZ $warpScrollParams ; Clear $0652 and sceneNext so the scene does not change while the route plays
    STZ $sceneNext        ; Clear sceneNext — transition is now deferred until route completes

; The single COP Die shared by the controller (no choice id: a scripted trip, the child does all the work) and by DeferSceneTransition (route id 0: the player chose Quit and the handler already queued the origin scene).

  WorldMapControllerDie:
    COP [Die]
}

---------------------------------------------
; Child actor (flags $3800, script-driven). Phases: 44-tick zoom-out ($B8 falls), for a menu trip a 16-tick wait + WorldMapSplitEffect + wait for the player's route, the 93-tick tilt phase with the start name ($B6 grows), then the companion dots. It finally becomes the leader's dot through the shared loop in CompanionDotMovement and dies when the route ends.

ArrivalAndTravelSetup {
    LDA $worldMapPlayerX  ; Load initial player X from $0D54 → sprite X ($14)
    STA $14
    SEC 
    SBC #$0080            ; Camera target X = player X − $80 (center 256px screen)
    STA $cameraTargetX
    LDA $worldMapPlayerY  ; Load initial player Y from $0D56 → sprite Y ($16)
    STA $16
    SEC 
    SBC #$0070            ; Camera target Y = player Y − $70 (center 224px screen)
    STA $cameraTargetY
    COP [InitGravity] ( #20, #05, #00 ) ; v0 = $20, shift 5: tick delta = ((t * (t >> 1)) >> 5) - $20, negative for all 44 ticks (sum about -970)
    COP [LoopStart] ( #2C ) ; 44 ticks of zoom-out, one yield per tick
    COP [TickGravity]     ; moveScratch2 := the gravity-curve delta for this tick
    LDA $moveScratch2, X  ; Add this tick's TickGravity delta (moveScratch2) to $B8 below
    CLC 
    ADC $00B8             ; Mode 7 divisor $B8 += delta (negative): about $0400 down to about $34, the view zooms out (OQ-I059-4)
    STA $00B8
    COP [SetEntryHereAndYield]
    COP [LoopEnd]
    LDA $worldMapChoiceId ; Menu trip (choice id set): wait for a route; scripted trip (0): go straight on
    BEQ TiltPhaseStart
    COP [WaitByte] ( #0F ) ; WaitByte #0F = 16 ticks before the HDMA effect starts
    COP [SpawnThinker] ( @WorldMapSplitEffect ) ; WorldMapSplitEffect: BGMODE/COLDATA split with a moving boundary row (see its notes)
    COP [SetEntryHere]    ; Poll point: re-entered every frame while the menu is open
    LDA $worldMapRouteId  ; Route id set by the chosen handler (StageWorldMapMoveIds): nonzero = a destination with a route was chosen
    BNE TiltPhaseStart    ; Route chosen: continue with the tilt phase
    RTL                   ; No route yet (menu open, or Quit): yield and poll again next frame

; Tilt phase. Looks up and shows the name of the scene being left ($0D6F), then 93 ticks of gravity-curve growth in $B6 (perspective) and $B8 + 1.

  TiltPhaseStart:
    LDA $0D6F             ; Scene being left -> $0000, the LookupMapName key for the start name
    AND #$00FF
    STA $0000
    COP [SpawnBeforeFlags] ( @pr_text_placement_calc, #$2000 ) ; Name actor (pr_text_placement_calc): builds the sprite text of the string in its $26, then dies
    JSR $&LookupMapName   ; Y := name string pointer for scene $0000
    TYA                   ; Transfer name string pointer (Y) → save into spawned actor's $0026
    LDY $04               ; Y := the new name actor (AllocateActorBefore leaves it in $04; LookupMapName clobbered Y)
    STA $0026, Y
    COP [InitGravity] ( #00, #07, #00 ) ; v0 = 0, shift 7: tick delta = (t * (t >> 1)) >> 7, growing from 0
    COP [LoopStart] ( #5D ) ; 93 ticks of tilt phase
    COP [TickGravity]
    LDA $00B6             ; Perspective $B6 += delta: the flat map tilts (about $03F0 after 93 ticks)
    CLC 
    ADC $moveScratch2, X
    STA $00B6
    INC $00B8             ; Divisor $B8 + 1 per tick (slight zoom in)
    COP [LoopEnd]
    LDA #$0000            ; Clear moveScratch2 — reset per-frame movement delta
    STA $moveScratch2, X
    LDA #$2000            ; Clear bit 13 ($2000, script-driven mode forced on by CopyActorState) so the leader is handled like the $1800 dots
    TRB $10
    LDY #$0000

; Party scan: Y steps through $0D62, $0D64, ... and stops at the first empty slot or at Y = $0C. Y - 2 is then 2 x the number of companions.

  ScanPartyArray:
    INY                   ; Scan the party array from $0D62 (the leader's $0D60 is skipped)
    INY 
    CPY #$000C            ; Stop after $0D6A: at most 5 companions
    BCS SelectFormation
    LDA $0D60, Y          ; Slot in use (nonzero animation index)?
    BNE ScanPartyArray

; Picks the formation layout for the companions counted by ScanPartyArray: the pointer comes from companion_formation_tables (entry N for N companions) and is kept in $18 / $1A for the dot spawn loop; the leader's animation index (party array word 0) goes to actor $28.

  SelectFormation:
    PHX                   ; Layout table index: entry N for N companions (word entries, X = 2N)
    TYX 
    DEX 
    DEX 
    LDA $@companion_formation_tables, X ; Layout pointer for this companion count (entry 6 unreachable)
    STA $18
    LDA #$*companion_formation_tables ; Bank byte of companion_formation_tables → $1A for long addressing
    STA $1A
    PLX 
    LDA $0D60             ; Leader animation index (party array word 0) -> actor $28
    STA $28
    LDA [$18]             ; First slot pair of the layout = the leader's slot (screen offsets X, Y from the camera target)
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

; Dot spawn loop: one CompanionDotMovement per non-empty slot $0D62-$0D6A. Each gets its animation index, its slot pair from the layout, and the leader's pair as home.

  SpawnDotLoop:
    INY                   ; Dot spawn loop: Y := next slot ($0D62, $0D64, ... $0D6A)
    INY 
    STY $26
    LDA $0D60, Y          ; Check if companion slot is active ($0D60,Y ≠ 0)
    BEQ FormationDone     ; Empty slot: no more companions
    PHA 
    COP [SpawnAfterFlags] ( @CompanionDotMovement, #$1800 ) ; One dot actor per companion (flags $1800: bit 13 clear), spawned at the leader's position
    PLA 
    STA $0028, Y          ; New dot's animation index := party array value
    LDA [$18]             ; Read next position pair from layout data
    STA $0024, Y          ; New dot's own slot pair (next pair of the layout)
    LDA $24               ; Pass center reference position into spawned actor's $0026
    STA $0026, Y          ; New dot's home pair := the leader's slot pair (where it returns when the route ends)
    INC $18
    INC $18
    LDY $26
    CPY #$000A            ; Slots $0D62-$0D68 loop back; after $0D6A the loop ends
    BCC SpawnDotLoop

; All companion dots are spawned: the leader's home pair is its own slot pair (so it dies as soon as the route ends), two AnimOnce frames, the start-area name is cleared, RouteAnimationEngine is spawned before this actor and this actor joins DotAnimationLoop as the leader's dot.

  FormationDone:
    LDA $24               ; Store final formation center position into this actor's orbitDiameter
    STA $orbitDiameter, X ; Home pair of this (leader) dot := its own slot pair, so it dies as soon as the route ends
    COP [LoopStart] ( #02 ) ; Two AnimOnce steps before the route starts
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
    STZ $00DA             ; Remove the start-area name sprites (sprite-text byte count := 0)
    COP [SpawnBefore] ( @RouteAnimationEngine ) ; Spawn RouteAnimationEngine before this actor; it plays the route bytes
    BRA DotAnimationLoop  ; Join the shared dot loop (this actor is the leader's dot from now on)
}

---------------------------------------------
; A companion's dot. Entry: it was spawned at the leader's position, so it glides to its own formation slot (camera + slot pair) at 1 pixel per frame, then joins the shared dot loop at DotAnimationLoop.
; Actor fields: $24 = own slot pair (low byte X, high byte Y, screen offsets), $26 = leader's slot pair (copied to orbitDiameter as home), $28 = animation index.

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
    COP [MoveToward] ( #FF, #01 ) ; Glide from the leader's position to this slot at 1 px/frame (animation operand #FF leaves the animation unchanged)
    LDA $orbitAngle, X    ; Reload position pair from orbitAngle for animation calculations
    STA $24

; Shared dot loop (leader and companions). Every frame the dot is placed at camera + slot pair; while a route is playing the frame hold time (from $08 into $26) counts down and AnimOneFrame stages the next animation frame. When the route id becomes 0 the dot moves one step toward its home pair and dies, so all dots are gone as soon as the route ends. The leader's home is its own slot, so it dies at once.

  DotAnimationLoop:
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
    LDA $worldMapRouteId  ; Route active? ($0D5A ≠ 0 → stay in animation loop)
    BEQ DotRouteEnded
    DEC $26               ; Decrement animation timer; negative = restart cycle
    BMI DotNextCycle
    RTL                   ; Timer still positive → yield for next frame (RTL)

; Animation timer expired: restart the shared dot loop.

  DotNextCycle:
    BRA DotAnimationLoop

; Route id is 0 (the route is over): the home X is the low byte of orbitDiameter + cameraTargetX; when the dot is already there the Y test follows and the dot dies, otherwise it goes to DotMoveHome.

  DotRouteEnded:
    LDA $orbitDiameter, X ; Route done: compute home position X from orbitDiameter + cameraTargetX
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    CMP $14               ; Check if already at home X position
    BNE DotMoveHome
    LDA $7F0013, X        ; Compute home Y from $7F0013 (orbitDiameter high byte) + cameraTargetY
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    CMP $16               ; Check if already at home Y position
    BNE DotMoveHome
    COP [Die]             ; Home reached: remove the dot (the leader's home is its own slot, so it dies at once)

; Not at home yet: the Y target is the high byte of orbitDiameter ($7F0013) + cameraTargetY, one MoveToward step toward home, then Die.

  DotMoveHome:
    LDA $7F0013, X        ; Not at home yet: recompute Y target for final MoveToward
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 ) ; One final step toward home position, then die
    COP [Die]
}

---------------------------------------------
; Formation layouts indexed by the number of companions N (entry N; entry 6 is never reached because at most 5 companions are scanned). Each layout is a list of screen-offset pairs (X, Y) from the camera target, the first for the leader. N = 1 uses formation_leader_plus_1 (two dots side by side), N = 4 uses formation_leader_plus_4, all others use formation_leader_plus_5.

companion_formation_tables [
  &formation_leader_plus_5   ;00
  &formation_leader_plus_1   ;01
  &formation_leader_plus_5   ;02
  &formation_leader_plus_5   ;03
  &formation_leader_plus_4   ;04
  &formation_leader_plus_5   ;05
  &formation_leader_plus_5   ;06
]

---------------------------------------------
; Eight offset pairs: leader (80,80), then (70,90) (90,90) (68,A0) (98,A0) (80,98), (60,B0) (A0,B0). Only the first six are reachable (leader + 5 companions).

formation_leader_plus_5 #80807090909068A098A0809860B0A0B0

---------------------------------------------
; Two pairs for N = 1: leader (78,80), companion (88,80).

formation_leader_plus_1 #78808880

---------------------------------------------
; Five pairs for N = 4: same as the first five pairs of formation_leader_plus_5 (the entry is redundant).

formation_leader_plus_4 #80807090909068A098A0

---------------------------------------------
; Interpreter for the route bytes of world_map_route_table[$0D5A]. A step is four bytes: move_chain_table indices for X ($CA), Y ($CC) and rotation ($BC), then a tick count n (the step runs n + 1 ticks). Index 0 is null (that axis stands still). $FF ends the route, $FE calls a subroutine (2-byte target, one level). Each tick adds the next delta of each active axis and sets cameraTargetX/Y = centre - ($80, $70). The delta chains come from move_chain_table (constants +-1.. and half-speed alternations).

RouteAnimationEngine {
    PHX                   ; Load route pointer: world_map_route_table[$0D5A × 2] → $2C/$2E
    LDA $worldMapRouteId
    ASL 
    TAX 
    LDA $@world_map_route_table, X
    STA $2C
    LDA #$*world_map_route_table
    STA $2E
    PLX 

; Read the next step: $FF -> RouteEndHandler, $FE -> RouteSubroutineCall, otherwise load the three delta chain pointers and the tick count and start the step.

  RouteStepLoop:
    LDA [$2C]             ; Read route step type byte from [$2C]
    AND #$00FF
    CMP #$00FF            ; $FF = end-of-route marker → RouteEndHandler
    BNE RouteNotEnd
    JMP $&RouteEndHandler

; The step byte is not $FF: advance past it; $FE calls a subroutine (RouteSubroutineCall), anything else is the X delta index of a normal step.

  RouteNotEnd:
    INC $2C               ; Advance past type byte
    CMP #$00FE            ; $FE = subroutine call marker → RouteSubroutineCall
    BNE RouteDeltaTables
    JMP $&RouteSubroutineCall

; Normal step: the X, Y and rotation delta chains are looked up in move_chain_table ($18, $1A, $1C) and the tick count n is stored in $24; SetEntryHere then yields one frame per tick.

  RouteDeltaTables:
    ASL                   ; Step type × 2 → index into move_chain_table for X delta source
    TAY 
    LDA $&move_chain_table, Y
    STA $18
    LDA [$2C]             ; Read Y movement table index (byte 2)
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&move_chain_table, Y ; Look up Y delta source pointer from move_chain_table
    STA $1A
    LDA [$2C]             ; Read Z movement table index (byte 3)
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&move_chain_table, Y ; Look up Z delta source pointer from move_chain_table
    STA $1C
    LDA [$2C]             ; Read frame count (byte 4) → $24
    AND #$00FF
    INC $2C
    STA $24
    COP [SetEntryHere]    ; Yield one frame per route step iteration
    LDA $18               ; X axis: check for null pointer (0 = no X movement this step)
    BEQ RouteAxisY
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

; X axis done or absent (null chain pointer): handle the Y axis in the same way (chain pointer $1A, world Y $00CC, cameraTargetY = Y - $70).

  RouteAxisY:
    LDA $1A               ; Y axis: check for null pointer
    BEQ RouteAxisRotation
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

; Y axis done or absent: add the rotation delta chain $1C to the rotation index $BC.

  RouteAxisRotation:
    LDA $1C               ; Z axis: check for null pointer
    BEQ RouteCountTick
    LDA ($1C)             ; Read Z delta from indirect pointer
    INC $1C
    INC $1C
    CLC 
    ADC $00BC             ; Rotation index $BC += delta (the map turns; not elevation)
    STA $00BC             ; Store the new rotation index
    LDA ($1C)             ; Read next Z pointer word
    STA $1C

; End of the tick: decrement the remaining tick count; while it is still non-negative the actor yields (RTL).

  RouteCountTick:
    DEC $24               ; Decrement frame count; negative = step complete → next step
    BMI RouteNextStep
    RTL                   ; Frame count still positive → yield (RTL) for next tick

; The count went negative: the step is complete, continue with the next one at RouteStepLoop.

  RouteNextStep:
    JMP $&RouteStepLoop
}

---------------------------------------------
; Start pressed during the end-of-route countdown: restore the deferred sceneNext/$0652, clear the state block and yield; the scene changes at once without the dive.

SkipToSceneTransition {
    LDA $0D6E             ; Start skip: restore deferred scene ID ($0D6E) → sceneNext
    AND #$00FF
    STA $sceneNext
    LDA $0D6C             ; Restore auxiliary data ($0D6C) → $0652
    STA $warpScrollParams
    JSR $&ClearWorldMapState ; Clear entire world map state block
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Route byte $FE: remember the address after the 2-byte target in $0D5C and continue at the target. One nesting level only; a second $FE would overwrite $0D5C. No shipped route uses it: no step in world_map_route_table starts with $FE (every route is 4n step bytes plus a hidden $FF end byte).

RouteSubroutineCall {
    LDA $2C               ; Save return address ($2C + 2) → $0D5C for subroutine return
    INC 
    INC 
    STA $worldMapRouteReturnPtr
    LDA [$2C]             ; Load 2-byte subroutine target from route data → $2C
    STA $2C
    JMP $&RouteStepLoop   ; Jump to RouteStepLoop to execute subroutine
}

---------------------------------------------
; Route byte $FF. A pending subroutine return (nonzero $0D5C) continues the caller. A true end: clear route and choice ids (the dots notice and die), show the destination name (scene $0D6E) for 60 ticks (WaitByte #3B), then lower $B6 by $10 per frame until it would go negative (the map is flat again; Start skips to the scene change). Landing: $B6 := 0, transition speeds gfxCacheIdxB := $0406, restore the deferred scene change, clear the state block, and from then on add the TickGravity delta to $B8 every frame (zoom-in dive) until the scene changes.

RouteEndHandler {
    LDA $worldMapRouteReturnPtr ; Check subroutine return pointer ($0D5C)
    BEQ RouteTrulyEnded   ; Zero = no return pending → true end of route
    STZ $worldMapRouteReturnPtr ; Clear return pointer, restore $2C, continue processing
    STA $2C
    JMP $&RouteStepLoop

; True end of the route (no subroutine return pending).

  RouteTrulyEnded:
    STZ $worldMapRouteId  ; True route end: clear route active flag ($0D5A)
    STZ $worldMapChoiceId ; Clear destination ($0D58)
    LDA $0D6E             ; Load destination area ID from $0D6E for name display
    AND #$00FF
    STA $0000
    COP [SpawnAfterFlags] ( @pr_text_placement_calc, #$2000 ) ; Spawn name display actor for destination area
    JSR $&LookupMapName   ; Look up destination area name
    TYA 
    LDY $06
    STA $0026, Y          ; Store name pointer into spawned actor's $0026
    COP [WaitByte] ( #3B ) ; WaitByte #3B = 60 ticks to show the destination name
    COP [SetEntryHere]
    LDA $00B6             ; End-of-route flatten loop: perspective $B6 -= $10 per frame
    SEC 
    SBC #$0010
    BMI RouteEndLanding   ; $B6 would go negative: the map is flat again, landing complete
    STA $00B6
    LDA $joypadRaw        ; Check Start button ($1000 in raw joypad) for fast travel skip
    BIT #$1000
    BNE SkipToSceneTransition ; Start pressed → SkipToSceneTransition (bypass descent animation)
    RTL 

; Landing: perspective gone, restore the deferred scene change and start the zoom-in dive while the scene exit runs.

  RouteEndLanding:
    LDA #$0000            ; Map flat again: $B6 := 0
    STA $00B6
    COP [SetEntryHereAndYield] ; Save the re-entry point and yield
    STZ $00DA             ; Remove the destination name sprites (sprite-text byte count := 0)
    LDA #$0800            ; Set bit 11 ($0800, cutscene-active per cop_handlers_dialog) so the dive keeps running during the exit (inferred)
    TSB $10
    COP [InitGravity] ( #00, #06, #00 ) ; v0 = 0, shift 6: dive delta = (t * (t >> 1)) >> 6, growing from 0
    LDA #$0406            ; Transition speeds: low byte $06 (exit), high byte $04 (enter), per scene_lifecycle
    STA $gfxCacheIdxB
    LDA $0D6E             ; Restore deferred scene ID ($0D6E) → sceneNext
    AND #$00FF
    STA $sceneNext
    LDA $0D6C             ; Restore auxiliary data ($0D6C) → $0652
    STA $warpScrollParams
    JSR $&ClearWorldMapState ; Clear world map state block
    COP [SetEntryHere]
    COP [TickGravity]
    LDA $moveScratch2, X  ; Dive: $B8 += delta, so the divisor grows (zoom in) while the scene exit transition runs
    CLC 
    ADC $00B8
    STA $00B8
    RTL 
}

---------------------------------------------
; Zero $0D52-$0D6D (14 words). $0D6E/$0D6F are not cleared.

ClearWorldMapState {
    LDA #$0000            ; Zero-fill loop: $0000 → $0D52 through $0D6C (14 words)
    LDY #$0000

; Zero-fill loop of ClearWorldMapState: 14 words from $0D52 to $0D6D.

  ClearStateLoop:
    STA $worldMapStagedX, Y
    INY 
    INY 
    CPY #$001C
    BCC ClearStateLoop
    RTS 
}

---------------------------------------------
; Search world_map_scene_names (3-byte entries: scene id, name pointer) for the scene id in $0000. Found: Y := name pointer. Not found: Y is returned unchanged (the table has no terminator, see world_map_scene_names). Called with the source scene $0D6F at the start and the destination $0D6E at the end.

LookupMapName {
    PHP                   ; Save registers, set up 8-bit mode for byte comparison
    PHX 
    LDX #$0000
    SEP #$20
    PHB 
    LDA #$^world_map_scene_names ; Set DBR to world_map_scene_names bank for direct addressing
    PHA 
    PLB 

; Search loop of LookupMapName: compare the scene id of entry X with $0000; a zero id byte ends the search (miss), a match goes to LookupMapNameFound, otherwise X advances by 3.

  LookupMapNameLoop:
    LDA $&world_map_scene_names, X ; Scene id of entry X (3-byte entries: id, name pointer)
    BEQ LookupMapNameMiss ; Zero id byte = end; the table has no terminator entry, so a miss would run on into the strings (OQ-I059-7)
    CMP $0000             ; Compare against target area ID ($0000)
    BEQ LookupMapNameFound ; Match → load name pointer
    INX                   ; No match: advance X by 3 (each entry = 1 byte ID + 2 byte pointer)
    INX 
    INX 
    BRA LookupMapNameLoop

; Match: Y := the name pointer at world_map_scene_names + 1 + X, restore DBR / X / P and return.

  LookupMapNameFound:
    REP #$20              ; Match found: switch to 16-bit, load name pointer from world_map_scene_names+1
    LDY $&world_map_scene_names+1, X
    PLB 
    PLX 
    PLP 
    RTS 

; Zero id byte reached (no match, OQ-I059-7): restore DBR / X / P and return with Y unchanged.

  LookupMapNameMiss:
    PLB 
    PLX 
    PLP 
    RTS 
}