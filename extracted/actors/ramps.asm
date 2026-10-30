; Four ramp-jump launcher actors (ramp_east, ramp_west, ramp_north, ramp_south; Bank 00, 53971-54829). Each one watches the player; when the player runs into its window the ramp takes the player's script over, locks the controls and carries the player a fixed distance along one axis. East/west ramps spawn a child actor that adds a precomputed vertical arc, so the player leaps; north/south ramps just move the player vertically for a number of animation cycles. Earlier notes called them collision tiles; they are actors placed through scene_actors.
; 
; === PER-FRAME WATCH (two stages) ===
; 
; All four are actor-def <#00,#00,#20> and follow one pattern, mirrored per direction:
; 1. Stage 1 (every frame): RampCheckPlayerSpeed passes when |speed| on the ramp's axis (playerSpeedEw for east/west, playerSpeedNs for north/south) is at least 6 and playerFlags bit $0800 (script lock) is clear. Then the player must be inside the ramp's window (table below). When both hold the ramp executes SetEntryHere and enters stage 2.
; 2. Stage 2: every frame the ramp compares the player's position on the ramp's axis with its own. When the two are EXACTLY equal it fires the launch. If the distance grows to $10 or more it goes back to stage 1 with JumpNextFrame. Speed and lock are not rechecked in stage 2.
; 
; | Ramp | Axis | Window (player minus ramp) | Direction of the climb | Exit speed |
; |------|------|----------------------------|------------------------|------------|
; | ramp_east  | X, |dy| <= $18 | +2 .. +15 (player just east) | west (-8 per frame) | $FFF8 |
; | ramp_west  | X, |dy| <= $18 | -16 .. -2 (player just west) | east (+8 per frame) | $0008 |
; | ramp_north | Y, |dx| <= $10 | +2 .. +15 (player just south) | north (-8 per frame) | $FFF8 on playerSpeedNs |
; | ramp_south | Y, |dx| <= $10 | -16 .. -2 (player just north) | south (+8 per frame) | $0008 on playerSpeedNs |
; 
; The direction of the speed is not tested: any |speed| >= 6 on the axis arms the ramp. The names describe the side the ramp sits on relative to the player. Chain $10 / $0F of move_chain_table are the constant -8 / +8 per frame movements used by StagePlayerMoveXY. The ramp keeps its temporary window edge in the global words $0018 (east/west) and $001C (south) rather than in its own direct page; nothing yields between writing and using them.
; 
; === LAUNCH (RampBeginPlayerControl) ===
; 
; The ramp writes the climb routine's address into the player's entry pointer ($00 / $02 of playerActor), then calls RampBeginPlayerControl: it zeroes playerSpeedEw and playerSpeedNs, stores the ramp's own $0E (the spawn-record type byte >> 1) into the player's statsPtr, zeroes the player's $2C / $2E, masks the D-pad ($0F00 into joypadMaskStd) and sets playerFlags $0800. The ramp itself then restarts at stage 1 and stays blocked by the $0800 lock until RestorePlayerControl clears it. The $0E value is the ramp's parameter: the arc selector for east/west and the loop count for north/south.
; 
; === EAST / WEST CLIMB (RampPlayerClimbEast, RampPlayerClimbWest) ===
; 
; Runs as the player. COP [SpawnAfter] RampArcDriver creates the arc child right after the player (the child's $04 link is the player, the player's $06 link is the child); the player then writes the exit speed ($FFF8 east ramp, $0008 west ramp) into the child's orbitDiameter, clears $0008 in its own $10 (collision-aware movement off) and sets $0200, and loops StagePlayerMoveXY plus AnimOnce forever: animation $21 with X chain $10 (-8 per frame) for east, animation $24 with chain $0F (+8) for west. The loop ends because the child restores the player's entry.
; RampArcDriver reads the player's statsPtr (0 or 1), multiplies by 3 to index ramp_motion_curves (pointer + frame count), and from then on adds one sign-extended byte of the chosen curve to the player's Y ($16) each frame (ramp_motion_curve_step). After the last frame it copies orbitDiameter into playerSpeedEw, calls slider_glide.RestorePlayerControl, sets slopeStepCounter = 0 and decelStepCounter = 7 and dies.
; Spawn type byte 1 ($0E = 0) selects ramp_curve_arc_64: 64 frames, rising up to 204 pixels (peak at frame 28) and returning to the start height (sum 0), about 512 pixels of horizontal travel. Spawn type 3 ($0E = 1) selects ramp_curve_arc_32: 32 frames, peak rise 50 pixels, ending 8 pixels lower (sum +8), about 256 pixels of travel. Only the Itory ramp pair (scene 15) uses type 1; every other east/west ramp uses type 3. These distances are static estimates (8 px x frames); they were not measured at runtime.
; 
; === NORTH / SOUTH CLIMB (RampPlayerClimbNorth, RampPlayerClimbSouth) ===
; 
; No child and no arc. The player's loopCounter is set to statsPtr (the ramp's $0E: type $09 = 4, $0B = 5, $11 = 8, $03 = 1) and each loop iteration is StagePlayerMoveXY plus AnimOnce, i.e. one full animation cycle of Y movement at -8 (north, animation $1E, chain $10) or +8 (south, animation $19, chain $0F) per frame. After the loop playerSpeedNs = $FFF8 (north) or $0008 (south), RestorePlayerControl runs and the two step counters are reset as above. LoopEnd decrements before testing, so a count of 0 would run 65536 iterations; the placed ramps never use 0.
; 
; === PLACEMENT ===
; 
; 58 actor-spawn lines in scene_actors: 26 ramp_east, 22 ramp_west, 6 ramp_north, 4 ramp_south, in scenes 15, 1E, 21, 23, 4F, 53, 82, 83, 85 (Great Wall wall_rampway), 88, A1-A3, A5, A7 (A1, A2 and A5 are in mountain_temple/), B3, B5, CE, CF and D6 (pyramid/). East/west ramps use type 3 except the Itory pair; north uses type 9 (one type 3 in scene 21); south uses type $0B in scene 21 and $11 elsewhere.
; 
; === QUIRKS ===
; 
; - The climb labels name the direction of travel: RampClimbNorthStep is the loop head of the NORTH climb and RampClimbSouthStep the loop head of the SOUTH climb; RampPlayerClimbWest is the west entry (ramp_east) and RampPlayerClimbNorth the north entry (ramp_north).
; - The launch needs exact equality of the player and ramp coordinates on the axis in stage 2. Whether the player's step size always hits it was not checked at runtime.
; - RampPlayerClimbEast stores the exit speed through LDX $06 without checking that SpawnAfter succeeded; if the actor pool were full the climb loop would never end. No evidence that this happens in practice.
; - The player's $10 bit $0200 is set here and by slider_glide; combat_collision includes it in the skip mask ($76E0) of its normal enemy-hits-player pass (the friendly pass uses $74E0, which allows it).
---------------------------------------------

?BANK 00

?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'slider_glide'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!retPtr2                        7F001E
!statsPtr                       7F0020

---------------------------------------------

ramp_east [
  actor-def < #00, #00, #20, {

  code_00D2D3:
    COP [SetEntryHere]    ; Idle stage 1 re-entry point

; ramp_east stage 1 (re-entered by JumpNextFrame). Scratch $0018 = ramp X + 8, then the speed, row (|dy| <= $18) and column (player X - ramp X in 2..15) checks. RTL leaves the ramp at this entry for the next frame.

  RampEastWatch:
    LDA $14               ; Ramp X ...
    CLC 
    ADC #$0008            ; ... + 8 ...
    STA $0018             ; ... into global scratch $0018
    LDA $playerSpeedEw    ; Player's horizontal speed
    JSR $&RampCheckPlayerSpeed ; Carry clear = |speed| >= 6 and no script lock
    BCC loc_00D2E7        ; Armed speed: continue with the position checks
    RTL                   ; Too slow or locked: wait for the next frame

  loc_00D2E7:
    LDY $playerActor
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC $16               ; ... minus ramp Y = dy
    BPL loc_00D2F6
    EOR #$FFFF            ; Absolute value of dy
    INC 

  loc_00D2F6:
    CMP #$0019            ; |dy| <= $18?
    BMI loc_00D2FC
    RTL                   ; Not in the ramp's row

  loc_00D2FC:
    LDA $0014, Y          ; Player X ...
    SEC 
    SBC #$0008            ; ... minus 8 ...
    SEC 
    SBC $0018             ; ... minus (ramp X + 8) = player X - ramp X - 16
    BMI loc_00D30A        ; Negative: player X - ramp X < 16
    RTL                   ; Player 16 or more pixels east of the ramp: wait

  loc_00D30A:
    BPL loc_00D310        ; Dead branch: the BMI above was taken, so N is still set here and this BPL is never taken; the EOR / INC below always runs
    EOR #$FFFF
    INC 

  loc_00D310:
    CMP #$000F            ; Window: player X - ramp X between 2 and 15 pixels
    BCC RampEastArmed
    RTL                   ; Too close (< 2) or too far: wait

; ramp_east stage 2: SetEntryHere again, then compare player X with ramp X each frame. Equal: RampEastLaunch launches. Distance >= $10: back to stage 1. Otherwise keep waiting.

  RampEastArmed:
    COP [SetEntryHere]    ; Stage 2: armed, wait for exact alignment
    LDY $playerActor
    LDA $0014, Y          ; Player X ...
    SEC 
    SBC $14               ; ... minus ramp X
    BEQ RampEastLaunch    ; Exactly aligned: launch
    BPL loc_00D329
    EOR #$FFFF
    INC                   ; Absolute distance

  loc_00D329:
    CMP #$0010            ; Still within 15 pixels?
    BCS loc_00D32F
    RTL                   ; Keep waiting; speed and lock are not rechecked

  loc_00D32F:
    COP [JumpNextFrame] ( @RampEastWatch ) ; Moved 16 or more pixels away: disarm and restart stage 1

; ramp_east launch: point the player's entry at RampPlayerClimbEast, run RampBeginPlayerControl, return to stage 1.

  RampEastLaunch:
    LDA #$&RampPlayerClimbEast ; Player entry = RampPlayerClimbEast ...
    STA $0000, Y          ; ... low word ...
    LDA #$*RampPlayerClimbEast
    STA $0002, Y          ; ... and bank
    JSR $&RampBeginPlayerControl ; Lock the player: zero speeds, statsPtr = arc index, D-pad masked, $0800 set
    COP [JumpNextFrame] ( @RampEastWatch ) ; Back to stage 1 (blocked by the $0800 lock until control is restored)
} >
]

ramp_west [
  actor-def < #00, #00, #20, {

  code_00D34B:
    COP [SetEntryHere]    ; Idle stage 1 re-entry point

; ramp_west stage 1. Scratch $0018 = ramp X - 8; the window is player X - ramp X in -16..-2.

  RampWestWatch:
    LDA $14               ; Ramp X ...
    SEC 
    SBC #$0008            ; ... - 8 ...
    STA $0018             ; ... into global scratch $0018
    LDA $playerSpeedEw    ; Player's horizontal speed
    JSR $&RampCheckPlayerSpeed ; Carry clear = |speed| >= 6 and no script lock
    BCC loc_00D35F
    RTL                   ; Too slow or locked: wait for the next frame

  loc_00D35F:
    LDY $playerActor
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC $16               ; ... minus ramp Y = dy
    BPL loc_00D36E
    EOR #$FFFF            ; Absolute value of dy
    INC 

  loc_00D36E:
    CMP #$0019            ; |dy| <= $18?
    BMI loc_00D374
    RTL                   ; Not in the ramp's row

  loc_00D374:
    LDA $0014, Y          ; Player X ...
    CLC 
    ADC #$0008            ; ... + 8 ...
    SEC 
    SBC $0018             ; ... minus (ramp X - 8) = player X - ramp X + 16
    BPL loc_00D382        ; Non-negative: player at most 16 pixels west of the ramp
    RTL                   ; Further west: wait

  loc_00D382:
    CMP #$000F            ; Window: player X - ramp X between -16 and -2
    BCC RampWestArmed
    RTL                   ; Too close (> -2) or too far: wait

; ramp_west stage 2 (same structure as ramp_east).

  RampWestArmed:
    COP [SetEntryHere]    ; Stage 2: armed, wait for exact alignment
    LDY $playerActor
    LDA $0014, Y          ; Player X ...
    SEC 
    SBC $14               ; ... minus ramp X
    BEQ RampWestLaunch    ; Exactly aligned: launch
    BPL loc_00D39B
    EOR #$FFFF            ; Absolute distance
    INC 

  loc_00D39B:
    CMP #$0010            ; Still within 15 pixels?
    BCS loc_00D3A1
    RTL                   ; Keep waiting; speed and lock are not rechecked

  loc_00D3A1:
    COP [JumpNextFrame] ( @RampWestWatch ) ; Moved 16 or more pixels away: disarm and restart stage 1

; ramp_west launch: the player's entry becomes RampPlayerClimbWest (the west climb).

  RampWestLaunch:
    LDA #$&RampPlayerClimbWest ; Player entry = west climb (RampPlayerClimbWest) ...
    STA $0000, Y          ; ... low word ...
    LDA #$*RampPlayerClimbWest
    STA $0002, Y          ; ... and bank
    JSR $&RampBeginPlayerControl ; Lock the player: zero speeds, statsPtr = arc index, D-pad masked, $0800 set
    COP [JumpNextFrame] ( @RampWestWatch ) ; Back to stage 1 (blocked by the $0800 lock until control is restored)
} >
]

ramp_north [
  actor-def < #00, #00, #20, {

  code_00D3BD:
    COP [SetEntryHere]    ; Idle stage 1 re-entry point

; ramp_north stage 1: axis Y. Checks playerSpeedNs, |player X - ramp X| <= $10 and player Y - ramp Y in 2..15.

  RampNorthWatch:
    LDA $playerSpeedNs    ; Player's vertical speed
    JSR $&RampCheckPlayerSpeed ; Carry clear = |speed| >= 6 and no script lock
    BCC loc_00D3C8
    RTL                   ; Too slow or locked: wait for the next frame

  loc_00D3C8:
    LDY $playerActor
    LDA $0014, Y          ; Player X ...
    SEC 
    SBC $14               ; ... minus ramp X = dx
    BPL loc_00D3D7
    EOR #$FFFF            ; Absolute value of dx
    INC 

  loc_00D3D7:
    CMP #$0011            ; |dx| <= $10?
    BMI loc_00D3DD
    RTL                   ; Not in the ramp's column

  loc_00D3DD:
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC #$0010            ; ... minus $10 ...
    SEC 
    SBC $16               ; ... minus ramp Y = player Y - ramp Y - 16
    BMI loc_00D3EA        ; Negative: player Y - ramp Y < 16
    RTL                   ; 16 or more pixels south of the ramp: wait

  loc_00D3EA:
    BPL loc_00D3F0        ; Dead branch: the BMI above was taken, so N is still set here and this BPL is never taken; the EOR / INC below always runs
    EOR #$FFFF
    INC 

  loc_00D3F0:
    CMP #$000F            ; Window: player Y - ramp Y between 2 and 15 pixels
    BCC RampNorthArmed
    RTL                   ; Too close (< 2) or too far: wait

; ramp_north stage 2: compare player Y with ramp Y each frame.

  RampNorthArmed:
    COP [SetEntryHere]    ; Stage 2: armed, wait for exact alignment
    LDY $playerActor
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC $16               ; ... minus ramp Y
    BEQ RampNorthLaunch   ; Exactly aligned: launch
    BPL loc_00D409
    EOR #$FFFF            ; Absolute distance
    INC 

  loc_00D409:
    CMP #$0010            ; Still within 15 pixels?
    BCS loc_00D40F
    RTL                   ; Keep waiting; speed and lock are not rechecked

  loc_00D40F:
    COP [JumpNextFrame] ( @RampNorthWatch ) ; Moved 16 or more pixels away: disarm and restart stage 1

; ramp_north launch: the player's entry becomes RampPlayerClimbNorth (the north climb).

  RampNorthLaunch:
    LDA #$&RampPlayerClimbNorth ; Player entry = north climb (RampPlayerClimbNorth) ...
    STA $0000, Y          ; ... low word ...
    LDA #$*RampPlayerClimbNorth
    STA $0002, Y          ; ... and bank
    JSR $&RampBeginPlayerControl ; Lock the player: zero speeds, statsPtr = loop count, D-pad masked, $0800 set
    COP [JumpNextFrame] ( @RampNorthWatch ) ; Back to stage 1 (blocked by the $0800 lock until control is restored)
} >
]

ramp_south [
  actor-def < #00, #00, #20, {

  code_00D42B:
    COP [SetEntryHere]    ; Idle stage 1 re-entry point

; ramp_south stage 1: scratch $001C = ramp Y - $10; the window is player Y - ramp Y in -16..-2 with |dx| <= $10.

  RampSouthWatch:
    LDA $16               ; Ramp Y ...
    SEC 
    SBC #$0010            ; ... - $10 ...
    STA $001C             ; ... into global scratch $001C
    LDA $playerSpeedNs    ; Player's vertical speed
    JSR $&RampCheckPlayerSpeed ; Carry clear = |speed| >= 6 and no script lock
    BCC loc_00D43F
    RTL                   ; Too slow or locked: wait for the next frame

  loc_00D43F:
    LDY $playerActor
    LDA $0014, Y          ; Player X ...
    SEC 
    SBC $14               ; ... minus ramp X = dx
    BPL loc_00D44E
    EOR #$FFFF            ; Absolute value of dx
    INC 

  loc_00D44E:
    CMP #$0011            ; |dx| <= $10?
    BMI loc_00D454
    RTL                   ; Not in the ramp's column

  loc_00D454:
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC $001C             ; ... minus (ramp Y - $10) = player Y - ramp Y + 16
    BPL loc_00D45E
    RTL                   ; Further than 16 pixels north of the ramp: wait

  loc_00D45E:
    CMP #$000F            ; Window: player Y - ramp Y between -16 and -2
    BCC RampSouthArmed
    RTL                   ; Too close (> -2) or too far: wait

; ramp_south stage 2: compare player Y with ramp Y each frame.

  RampSouthArmed:
    COP [SetEntryHere]    ; Stage 2: armed, wait for exact alignment
    LDY $playerActor
    LDA $0016, Y          ; Player Y ...
    SEC 
    SBC $16               ; ... minus ramp Y
    BEQ RampSouthLaunch   ; Exactly aligned: launch
    BPL loc_00D477
    EOR #$FFFF            ; Absolute distance
    INC 

  loc_00D477:
    CMP #$0010            ; Still within 15 pixels?
    BCS loc_00D47D
    RTL                   ; Keep waiting; speed and lock are not rechecked

  loc_00D47D:
    COP [JumpNextFrame] ( @RampSouthWatch ) ; Moved 16 or more pixels away: disarm and restart stage 1

; ramp_south launch: the player's entry becomes RampPlayerClimbSouth.

  RampSouthLaunch:
    LDA #$&RampPlayerClimbSouth ; Player entry = RampPlayerClimbSouth ...
    STA $0000, Y          ; ... low word ...
    LDA #$*RampPlayerClimbSouth
    STA $0002, Y          ; ... and bank
    JSR $&RampBeginPlayerControl ; Lock the player: zero speeds, statsPtr = loop count, D-pad masked, $0800 set
    COP [JumpNextFrame] ( @RampSouthWatch ) ; Back to stage 1 (blocked by the $0800 lock until control is restored)
} >
]

---------------------------------------------
; Takes the player over: zero both speeds, statsPtr = ramp $0E (curve index or loop count), zero player $2C / $2E, mask the D-pad ($0F00) and set playerFlags $0800. Y = player actor on entry; X = the ramp.

RampBeginPlayerControl {
    STZ $playerSpeedEw    ; No horizontal speed ...
    STZ $playerSpeedNs    ; ... and no vertical speed
    LDA $0E               ; Ramp's $0E = spawn type byte >> 1
    PHX 
    TYX                   ; X = player actor (Y was set by the caller)
    STA $statsPtr, X      ; Player statsPtr = arc index (east/west) or loop count (north/south)
    LDA #$0000
    STA $002C, X          ; Clear player $2C ...
    STA $002E, X          ; ... and $2E
    PLX                   ; Restore X = the ramp
    LDA #$0F00
    TSB $joypadMaskStd    ; Mask the D-pad bits
    LDA #$0800
    TSB $playerFlags      ; Script lock: playerFlags $0800
    RTS 
}

---------------------------------------------
; A = signed speed on the ramp's axis. Carry clear = |speed| >= 6 and playerFlags $0800 clear; carry set otherwise.

RampCheckPlayerSpeed {
    BPL loc_00D4C1        ; Absolute value of the speed
    EOR #$FFFF
    INC 

  loc_00D4C1:
    CMP #$0006            ; |speed| >= 6?
    BCC loc_00D4D0
    LDA $playerFlags      ; Player flags
    BIT #$0800            ; Script lock set?
    BNE loc_00D4D0
    CLC                   ; Armed: carry clear
    RTS 

  loc_00D4D0:
    SEC                   ; Not armed: carry set
    RTS 
}

---------------------------------------------
; East-ramp climb (runs as the player): spawn the arc child, give it the exit speed $FFF8, then loop animation $21 with X chain $10 (-8 per frame) until the child restores control.

RampPlayerClimbEast {
    COP [SpawnAfter] ( @RampArcDriver ) ; Spawn the arc driver right after the player in the actor list
    PHX 
    LDX $06               ; X = the new child (the player's $06 link)
    LDA #$FFF8            ; Exit speed -8 (west) ...
    STA $orbitDiameter, X ; ... into the child's orbitDiameter
    PLX                   ; X = the player again
    LDA #$0008
    TRB $10               ; Player $10 bit 3 off: collision-aware movement disabled
    LDA #$0200
    TSB $10               ; Player $10 bit $0200 on: ignore enemy contact (CombatCollision_InnerLoop mask $76E0; contact skip measured with the bit forced on; this write site not run)

  loc_00D4EC:
    COP [StagePlayerMoveXY] ( #21, #10, #00 ) ; Animation $21, X chain $10 (constant -8 per frame), no Y chain
    COP [AnimOnce]        ; Wait one frame for the animation
    BRA loc_00D4EC        ; Repeat until the child restores the player's entry

; West-ramp climb (unnamed in the original): same as RampPlayerClimbEast with exit speed $0008, animation $24 and X chain $0F (+8 per frame).

  RampPlayerClimbWest:
    COP [SpawnAfter] ( @RampArcDriver ) ; Spawn the arc driver right after the player in the actor list
    PHX 
    LDX $06               ; X = the new child (the player's $06 link)
    LDA #$0008            ; Exit speed +8 (east) ...
    STA $orbitDiameter, X ; ... into the child's orbitDiameter
    PLX                   ; X = the player again
    LDA #$0008
    TRB $10               ; Player $10 bit 3 off: collision-aware movement disabled
    LDA #$0200
    TSB $10               ; Player $10 bit $0200 on: ignore enemy contact (CombatCollision_InnerLoop mask $76E0; contact skip measured with the bit forced on; this write site not run)

  loc_00D50F:
    COP [StagePlayerMoveXY] ( #24, #0F, #00 ) ; Animation $24, X chain $0F (constant +8 per frame), no Y chain
    COP [AnimOnce]        ; Wait one frame for the animation
    BRA loc_00D50F        ; Repeat until the child restores the player's entry

; North-ramp climb entry: loopCounter = statsPtr, loop head RampClimbNorthStep. Clears $0008 / sets $0200 in the player's $10.

  RampPlayerClimbNorth:
    LDA $statsPtr, X      ; statsPtr = ramp's loop count ...
    STA $loopCounter, X   ; ... into loopCounter
    LDA #$&RampClimbNorthStep ; LoopEnd returns to RampClimbNorthStep (the north loop head)
    STA $retPtr2, X       ; Loop return address
    LDA #$0008
    TRB $10               ; Player $10 bit 3 off: collision-aware movement disabled
    LDA #$0200
    TSB $10               ; Player $10 bit $0200 on: ignore enemy contact (CombatCollision_InnerLoop mask $76E0; contact skip measured with the bit forced on; this write site not run)

; Loop head of the NORTH climb: animation $1E, Y chain $10 (-8 per frame), one animation cycle per iteration; after the last iteration playerSpeedNs = $FFF8 and control is restored.

  RampClimbNorthStep:
    COP [StagePlayerMoveXY] ( #1E, #00, #10 ) ; Animation $1E, Y chain $10 (constant -8 per frame), no X chain
    COP [AnimOnce]        ; One full animation cycle
    COP [LoopEnd]         ; Loop until the count is used up (decrements before testing)
    LDA #$FFF8            ; Exit speed -8 ...
    STA $playerSpeedNs    ; ... on the vertical axis
    JSR $&slider_glide.RestorePlayerControl ; Give the controls back: idle entry, $10 bit 3 on and $0200 off, D-pad unmasked, $0800 cleared
    LDA #$0000
    STA $slopeStepCounter ; No slope step in progress
    LDA #$0007
    STA $decelStepCounter ; Deceleration step counter = 7
    RTL                   ; Back to the actor runner
}

---------------------------------------------
; South-ramp climb entry: loopCounter = statsPtr, loop head RampClimbSouthStep, SetEntryHere, clears $0008 / sets $0200 in the player's $10.

RampPlayerClimbSouth {
    LDA $statsPtr, X      ; statsPtr = ramp's loop count ...
    STA $loopCounter, X   ; ... into loopCounter
    LDA #$&RampClimbSouthStep ; LoopEnd returns to RampClimbSouthStep (the south loop head)
    STA $retPtr2, X       ; Loop return address
    COP [SetEntryHere]    ; Re-entry point for the climb
    LDA #$0008
    TRB $10               ; Player $10 bit 3 off: collision-aware movement disabled
    LDA #$0200
    TSB $10               ; Player $10 bit $0200 on: ignore enemy contact (CombatCollision_InnerLoop mask $76E0; contact skip measured with the bit forced on; this write site not run)

; Loop head of the SOUTH climb: animation $19, Y chain $0F (+8 per frame), one animation cycle per iteration; after the last iteration playerSpeedNs = $0008 and control is restored.

  RampClimbSouthStep:
    COP [StagePlayerMoveXY] ( #19, #00, #0F ) ; Animation $19, Y chain $0F (constant +8 per frame), no X chain
    COP [AnimOnce]        ; One full animation cycle
    COP [LoopEnd]         ; Loop until the count is used up (decrements before testing)
    LDA #$0008            ; Exit speed +8 ...
    STA $playerSpeedNs    ; ... on the vertical axis
    JSR $&slider_glide.RestorePlayerControl ; Give the controls back: idle entry, $10 bit 3 on and $0200 off, D-pad unmasked, $0800 cleared
    LDA #$0000
    STA $slopeStepCounter ; No slope step in progress
    LDA #$0007
    STA $decelStepCounter ; Deceleration step counter = 7
    RTL                   ; Back to the actor runner
}
---------------------------------------------

; Arc driver child of the east/west climbs. X = $04 link = the player. Selects the curve from the player's statsPtr, sets loopCounter = frame count and orbitAngle = byte offset of the curve, then runs ramp_motion_curve_step once per frame. At the end: playerSpeedEw = orbitDiameter (exit speed), RestorePlayerControl, step counters reset, COP Die.

RampArcDriver {
    PHX                   ; Save the child's slot
    LDX $04               ; X = $04 link = the spawner (the player)
    LDA $statsPtr, X      ; Player statsPtr = curve index (0 or 1)
    ASL 
    CLC 
    ADC $statsPtr, X      ; Index x 3: ramp_motion_curves entries are 3 bytes
    TAX                   ; X = byte offset of the entry
    LDA $@hdma_ramp_tables.ramp_motion_curves+2, X ; Entry byte +2 = frame count
    AND #$00FF
    TAY                   ; Y = frame count
    LDA $@hdma_ramp_tables.ramp_motion_curves, X ; Entry word +0 = curve address
    SEC 
    SBC #$&hdma_ramp_tables.ramp_motion_curves ; Make it an offset from the start of ramp_motion_curves
    PLX                   ; X = the child again
    STA $orbitAngle, X    ; Child orbitAngle = curve offset
    TYA 
    STA $loopCounter, X   ; Child loopCounter = frame count
    STZ $2A               ; Frame index = 0
    LDA #$&ramp_motion_curve_step
    STA $retPtr2, X       ; LoopEnd returns to ramp_motion_curve_step each frame

; One frame of the arc: read the next signed byte of the curve (orbitAngle + frame index $2A), sign-extend and add it to the player's Y at $16. LoopEnd repeats it once per frame for the curve's frame count.

  ramp_motion_curve_step:
    PHX                   ; Save the child's slot
    LDA $orbitAngle, X    ; Curve offset ...
    CLC 
    ADC $2A               ; ... + frame index
    INC $2A               ; Next frame
    TAX 
    LDA $@hdma_ramp_tables.ramp_motion_curves, X ; Curve byte: signed Y delta in pixels
    AND #$00FF
    BIT #$0080            ; Negative byte?
    BEQ loc_00D60B
    ORA #$FF00            ; Sign-extend to 16 bits

  loc_00D60B:
    LDX $04               ; X = the player
    CLC 
    ADC $0016, X          ; Player Y + delta ...
    STA $0016, X          ; ... stored back
    PLX                   ; X = the child again
    COP [LoopEnd]         ; One iteration per frame for the curve's frame count
    LDA $orbitDiameter, X ; Exit speed given by the climb
    STA $playerSpeedEw    ; Player horizontal speed = exit speed
    JSR $&slider_glide.RestorePlayerControl ; Give the controls back: idle entry, $10 bit 3 on and $0200 off, D-pad unmasked, $0800 cleared
    LDA #$0000
    STA $slopeStepCounter ; No slope step in progress
    LDA #$0007
    STA $decelStepCounter ; Deceleration step counter = 7
    COP [Die]             ; Arc finished: remove the child
}