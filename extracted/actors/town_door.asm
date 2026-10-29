; Reusable town door (Bank 00, 50675-50732). 16 placements in three scenes: $01 South Cape (5 doors), $32 Freejia (4) and $91 (7); fr32_guide spawns one more at runtime (SpawnAfterAbsFlags at TownDoorInit, X $0278, Y $0230).
; 
; A door is drawn closed (frame #01 of spriteset_npc_props) and solid. When the player is next to it (BranchIfPlayerNear radius 1: both |dx| and |dy| within 16 px) and HOLDS UP (joypad $0800) for 8 consecutive frames, it plays SFX #0E on channel 2, clears its solid mark, switches to the open frame #00 and idles for the rest of the scene visit (nothing closes it again). The code tests the Up direction. Releasing Up or leaving the box restarts the count: the loop is re-entered through TownDoorProximityCheck and LoopStart reloads the counter.
; 
; A door that is already within radius 1 when it spawns skips the closed state: TownDoorInit branches straight to TownDoorOpenIdle, so it starts open (the player has just come out of the building).
; 
; Re-entry: after the first off-screen wait the entry pointer ($00) is the WaitWhileOffscreen op itself (it stores itself while the door is off-screen, which is the state at spawn because InitActorFromSceneData sets Flags10 bit $4000). Every later frame resumes there, passes straight through while on-screen and runs TownDoorProximityCheck. A door that is already on-screen at its first pass would instead be re-entered at AnimOnce and run the Init-time BranchIfPlayerNear to TownDoorOpenIdle first, which would open it without the Up hold; whether that case occurs is not traced.
; 
; The solid mark: MarkSolidHere / ClearSolidHere OR and AND the high nibble of the collision cells under the actor's hitbox rectangle, not a single tile. The door itself is not a warp; the building entrance is a separate trigger.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

town_door [
  actor-def < #01, #00, #10, {

; Door initialisation: closed frame #01, solid mark, start open if the player is already next to the door, then WaitWhileOffscreen (the loop head of later frames) and TownDoorProximityCheck.

  TownDoorInit:
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #01 ) ; Closed door frame
    COP [AnimOnce]
    COP [MarkSolidHere]   ; Block the door's hitbox rectangle (high nibble of the collision cells under it), not just one tile
    COP [BranchIfPlayerNear] ( #01, &TownDoorOpenIdle ) ; Player within 16 px on both axes at spawn (just came out of the building): start open
    COP [WaitWhileOffscreen] ( #0A ) ; Off-screen ($4000 set at spawn): operand #0A goes to $08, so this op re-runs 11 ticks later; it becomes the entry pointer, the loop head of later frames

; Per-frame test: player within 16 px on both axes -> TownDoorHoldUpLoop, otherwise end this pass (the entry pointer stays on WaitWhileOffscreen).

  TownDoorProximityCheck:
    COP [BranchIfPlayerNear] ( #01, &TownDoorHoldUpLoop ) ; Player within 16 px on both axes: go to the hold-Up loop
    RTL                   ; Not near: end this pass (the entry pointer stays on WaitWhileOffscreen)
} >
]

---------------------------------------------
; Hold-Up loop: LoopStart sets a counter of 8, BranchIfPressed tests Up ($0800) every frame. Up not held: the count is lost (JumpNextFrame back to the proximity check, which re-enters here with a fresh counter). Up held for 8 consecutive frames: continue at TownDoorOpenSound.

TownDoorHoldUpLoop {
    COP [LoopStart] ( #08 ) ; 8 frames to hold Up before door opens
    COP [BranchIfPressed] ( #$0800, &TownDoorOpenSound ) ; Up ($0800) held in joypadCurrent: go to LoopEnd, which counts this frame
    COP [JumpNextFrame] ( @TownDoorProximityCheck ) ; Up not held: the count is lost; the next frame re-checks proximity and re-enters the loop with a fresh counter
}

---------------------------------------------
; LoopEnd (counts the held frame; after the 8th it falls through) and the door SFX #0E; falls into TownDoorOpenIdle where the frame actually changes.

TownDoorOpenSound {
    COP [LoopEnd]         ; Count one held frame; after the 8th the loop falls through, before that it repeats the Up test next frame
    COP [PlaySoundCh2] ( #0E ) ; Door open SFX
}

---------------------------------------------
; Open state: clear the solid mark, show the open frame #00 and idle on a bare RTL for the rest of the scene visit (nothing closes the door). Also the target when the player is already near at spawn.

TownDoorOpenIdle {
    COP [ClearSolidHere]  ; Remove the solid mark again (AND of the same hitbox rectangle)
    COP [StageSpriteFrame] ( #00 ) ; Open door frame
    COP [AnimOnce]
    COP [SetEntryHere]    ; Open and idle: later frames resume at the RTL below; nothing closes the door
    RTL 
}