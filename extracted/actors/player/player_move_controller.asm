; Player movement integrator (Bank 02, 176798-177195): the per-frame companion actor that turns the player's velocity inputs into a new position.
; 
; SPAWN AND ORDER: PlayerCharacterDef spawns it with SpawnAfter. Every SpawnAfter inserts the new actor directly behind its spawner, and slope_ramp_physics is spawned after this actor, so the actor list reads attack_ability_system, player, slope_ramp_physics, this controller. The slope code has therefore already edited playerSpeedEw / playerSpeedNs when this runs in the same frame. CopyActorState sets the hidden bit ($2000) on it, so only its script runs.
; 
; STATE: this actor's own $14 / $16 hold the player's position in SUB-PIXELS (4 per pixel, 2 fractional bits). The x4 scaling at the top runs once, when the actor spawns; every later frame resumes after SetEntryHere. The player actor's $0014 / $0016 stay in plain pixels (the write-back stores sub-pixels >> 2).
; 
; PER FRAME:
; 1. HIT-STUN: if the player's $10 has bit $0080 (the iframe counter is running) and iframeCounter is not negative, skip the frame. A positive counter is hit-stun, so this is the check that freezes the player (actor_execution exempts the player from its own freeze); a negative counter (recovery) lets movement continue.
; 2. LOCK: if playerFlags has EITHER bit $0200 (game over) or $0800 (script / ability lock) set, clear extVelocityX / Y and skip: the script or the traversal code (ledge jump, ladder, shimmy, the slider-glide triggers, cutscene) owns the position.
; 3. SYNC: if the player actor's pixel position differs from local >> 2 (a script or COP moved the player), adopt the actor's position x4; the old fraction is lost.
; 4. VELOCITY, per axis. Speed word (playerSpeedEw / playerSpeedNs) zero: joypad velocity from JoypadToVelocity plus the external velocity; the joypad part is forced to zero while playerFlags has $1000 (on-slope latch) or $2000 (guard / channel stance). Speed nonzero: speed x 4 plus the external velocity, and the $1000 latch is cleared. One speed unit is one pixel per frame; the joypad gives +/-8 sub-pixels (2 px per frame).
; 5. MOVE: bit $0008 of the player actor's $10 means 'collision-checked movement' (actor_execution uses the same bit for every actor). Set: player_move_main.PlayerMovementTick runs the tile collision with X = THIS actor's slot, positions in the low-RAM words $22 / $26 and velocities in $20 / $24. Clear (the ledge-jump, ladder and shimmy states clear it and restore it on exit): the velocity is added to the position with no collision.
; 6. WRITE-BACK: local position = $22 / $26; the player actor gets position >> 2; bit $0004 (solid contact, set by the tick in this actor's own $10) is copied into the player's $10.
; 
; External velocities ($0408 / $040A) are consumed (zeroed) every frame, so a source must write them every frame to keep pushing: av71_wind_effect, btEA_conveyor_controller, combat_collision (push hits), gw82_archer, sg55_viper. scene_lifecycle clears them and both speed words at scene setup.
; JoypadToVelocity (end of file) is called only from here.
---------------------------------------------

?INCLUDE 'player_move_main'

!extVelocityX                   0408
!extVelocityY                   040A
!joypadCurrent                  0656
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!iframeCounter                  7F0028

---------------------------------------------

; Entry and per-frame routine. The scaling of $14 / $16 above SetEntryHere runs only when the actor spawns; the code from SetEntryHere down runs every frame (stages in the block note).

PlayerMoveController {
    LDA $14               ; Runs once, at spawn (above SetEntryHere): local X x 4 = sub-pixels (2 fractional bits)
    ASL 
    ASL 
    STA $14
    LDA $16
    ASL 
    ASL 
    STA $16
    COP [SetEntryHere]    ; Resume point: every frame from here on
    PHX 
    LDX $playerActor
    LDA $0010, X
    BIT #$0080            ; Bit $0080 = the iframe counter is running (hit-stun or recovery)
    BEQ PlayerMoveNotStunned
    LDA $iframeCounter, X
    BMI PlayerMoveNotStunned ; Negative = recovery after a hit: movement continues
    PLX                   ; Zero or positive counter = hit-stun: restore X and skip the frame (the stunned player cannot move)
    RTL 

; Passed the hit-stun gate (the iframe counter is not running, or it is negative = recovery after a hit): restore X and go on to the lock test.

  PlayerMoveNotStunned:
    PLX 
    LDA $playerFlags
    BIT #$0A00            ; Test $0200 (game over) OR $0800 (script / ability lock): either bit blocks movement
    BEQ PlayerMoveSync
    STZ $extVelocityX     ; Locked: drop the external velocities so no push is stored up
    STZ $extVelocityY
    RTL 

; Stage 3 (sync), X part: if the player actor's pixel X differs from local X >> 2 (a script, COP or knockback moved the player), adopt the actor's X x 4; the old fraction is lost.

  PlayerMoveSync:
    LDY $playerActor
    LDA $14
    LSR 
    LSR 
    CMP $0014, Y
    BEQ PlayerMoveSyncY
    LDA $0014, Y          ; The player was moved elsewhere (script, COP, knockback): adopt the actor's X x 4 (the old fraction is lost)
    ASL 
    ASL 
    STA $14

; Stage 3 (sync), Y part: the same comparison and adoption for Y.

  PlayerMoveSyncY:
    LDA $16               ; Same sync for Y: local Y >> 2 against the player actor's pixel Y
    LSR 
    LSR 
    CMP $0016, Y
    BEQ PlayerMoveJoypadGate
    LDA $0016, Y
    ASL 
    ASL 
    STA $16

; Stage 4 start: playerFlags $1000 (on-slope latch) or $2000 (guard / channel stance) forces the packed joypad velocity to zero; otherwise the pad is read at PlayerMoveReadPad.

  PlayerMoveJoypadGate:
    LDA $playerFlags      ; playerFlags $3000 = $1000 on-slope latch + $2000 guard / channel stance: no joypad movement in either state
    BIT #$3000
    BEQ PlayerMoveReadPad
    LDA #$0000            ; Joypad velocity forced to zero (packed Y:X)
    BRA PlayerMoveAxisX

; JoypadToVelocity returns the packed joypad velocity (high byte Y, low byte X).

  PlayerMoveReadPad:
    JSR $&JoypadToVelocity ; A = packed joypad velocity: high byte Y (NS), low byte X (EW)

; X axis of stage 4: keep the packed velocity on the stack, hand local X to the tick in $22, clear $20. Speed word playerSpeedEw zero: joypad X (sign-extended low byte) plus extVelocityX. Nonzero: speed x 4 plus extVelocityX, and the on-slope latch $1000 is cleared.

  PlayerMoveAxisX:
    PHA                   ; Keep the packed joypad velocity on the stack ($01,S) for both axes
    LDA $14               ; X axis: local X (sub-pixels) is the X position handed to the tick in $22
    STA $0022
    STZ $0020
    LDA $playerSpeedEw    ; Speed word EW: zero = walking, nonzero = slope / run / slide speed
    BNE loc_02B327
    LDA $01, S            ; Zero speed: X velocity = low byte of the packed pad velocity, sign-extended from 8 to 16 bits
    AND #$00FF
    BIT #$0080
    BEQ loc_02B31E
    ORA #$FF00

  loc_02B31E:
    CLC 
    ADC $extVelocityX     ; + external X velocity (wind, conveyor, push)
    STA $0020
    BRA PlayerMoveAxisY

  loc_02B327:
    ASL                   ; Speed path: speed x 4 (one speed unit = 1 px per frame) plus the external X velocity
    ASL 
    CLC 
    ADC $extVelocityX
    STA $0020             ; $20 = X velocity for the tick
    LDA #$1000            ; A moving speed overrides the slope state: clear the on-slope latch ($1000) in playerFlags
    TRB $playerFlags

; Y axis of stage 4: consume extVelocityX, hand local Y to the tick in $26, clear $24. Speed word playerSpeedNs zero: slopeFracAccum is zeroed and the velocity is joypad Y (high byte, sign-extended) plus extVelocityY. Nonzero: speed x 4 plus extVelocityY, and the on-slope latch is cleared.

  PlayerMoveAxisY:
    STZ $extVelocityX     ; External X velocity consumed
    STZ $0024
    LDA $16               ; Y axis: $26 = local Y (sub-pixels)
    STA $0026
    LDA $playerSpeedNs    ; Speed word NS
    BNE loc_02B360
    STZ $slopeFracAccum   ; Idle on this axis: zero the slope fraction accumulator (no slope physics when stopped)
    LDA $01, S            ; Zero speed: Y velocity = high byte of the packed pad velocity (XBA to the low byte), sign-extended
    XBA 
    AND #$00FF
    BIT #$0080
    BEQ loc_02B357
    ORA #$FF00

  loc_02B357:
    CLC 
    ADC $extVelocityY
    STA $0024
    BRA PlayerMoveCollisionStage

  loc_02B360:
    ASL                   ; Speed path: speed x 4 plus the external Y velocity (as for X)
    ASL 
    CLC 
    ADC $extVelocityY
    STA $0024             ; $24 = Y velocity for the tick
    LDA #$1000            ; Clear the on-slope latch (as for X)
    TRB $playerFlags

; Stage 5 (move): consume extVelocityY and drop the packed pad velocity. Player Flags10 bit $0008 (collision-checked movement) set: PlayerMoveCollisionTick. Clear (ledge jump, ladder, shimmy): $22 += $20 and $26 += $24 directly, no collision, then the write-back.

  PlayerMoveCollisionStage:
    STZ $extVelocityY     ; External Y velocity consumed
    PLA                   ; Drop the packed pad velocity from the stack
    LDY $playerActor
    LDA $0010, Y
    BIT #$0008            ; Bit $0008 = collision-checked movement (cleared during a ledge jump, a ladder climb or a shimmy)
    BNE PlayerMoveCollisionTick
    LDA $0020             ; Clear: add the velocity to the position directly, no collision ($22 += $20, $26 += $24)
    CLC 
    ADC $0022
    STA $0022
    LDA $0024
    CLC 
    ADC $0026
    STA $0026
    BRA PlayerMoveWriteBack

; Collision-checked move: store this actor's slot in the scratch word $000A (the tick reads X from it) and JSL player_move_main.PlayerMovementTick, which moves $22 / $26 against the tile map and sets bit $0004 of this actor's $10 on a solid contact.

  PlayerMoveCollisionTick:
    STX $000A             ; Save this actor's slot in the engine scratch word $000A (the tick reads X from it)
    TXY 
    JSL $@player_move_main.PlayerMovementTick ; PlayerMovementTick: tile collision; moves $22 / $26 and sets bit $0004 of this actor's $10 on a solid contact

; Stage 6: local position := $22 / $26, the player actor's pixel X / Y := position >> 2, and bit $0004 (solid contact this tick) is copied from this actor's $10 into the player's $10.

  PlayerMoveWriteBack:
    LDY $playerActor
    LDA $0022             ; Write-back: the final X / Y (sub-pixels) become the local position; >> 2 goes to the player actor's pixel position
    STA $14
    LSR 
    LSR 
    STA $0014, Y
    LDA $0026
    STA $16
    LSR 
    LSR 
    STA $0016, Y
    LDA $0010, Y          ; Copy bit $0004 (solid contact this tick) from this actor's $10 into the player's: clear it in the player's flags first ...
    AND #$FFFB
    PHA 
    LDA $10
    AND #$0004
    ORA $01, S
    STA $0010, Y
    PLA 
    RTL 
}

---------------------------------------------
; Packs the D-pad into one word: high byte = Y velocity, low byte = X velocity, signed sub-pixels per frame (positive = east / south). Called only from PlayerMoveController.
; Reads the pad's high byte ($0657) in 8-bit mode: bit 0 Right, bit 1 Left, bit 2 Down, bit 3 Up. Left wins over Right and Up over Down. Cardinal moves are +/-8 (2.0 px per frame); a diagonal uses +/-6 on each axis (resultant about 2.1 px per frame, so diagonals are slightly faster than cardinals).

JoypadToVelocity {
    PHP 
    SEP #$20
    LDA $joypadCurrent+1  ; Pad high byte ($0657): bit 0 Right, 1 Left, 2 Down, 3 Up
    BIT #$02              ; Left held: left handler (Left wins over Right)
    BNE JoypadVelocityLeft
    BIT #$01
    BNE JoypadVelocityRight
    BIT #$08
    BNE JoypadVelocityPureUp
    BIT #$04
    BNE JoypadVelocityPureDown
    LDA #$00
    XBA 
    LDA #$00              ; ... X = 0
    BRA JoypadVelocityDone

; Left held (Left wins over Right): neither Up nor Down goes to JoypadVelocityPureLeft, Up goes to JoypadVelocityUpLeft, otherwise Down + Left: Y = +6, X = -6.

  JoypadVelocityLeft:
    BIT #$0C              ; Left handler: test the vertical bits ($0C = Up | Down)
    BEQ JoypadVelocityPureLeft
    BIT #$08
    BNE JoypadVelocityUpLeft
    LDA #$06              ; Down + Left: Y = +6, X = -6
    XBA 
    LDA #$FA
    BRA JoypadVelocityDone

; Up + Left: Y = -6, X = -6.

  JoypadVelocityUpLeft:
    LDA #$FA              ; Up + Left: Y = -6, X = -6
    XBA 
    LDA #$FA
    BRA JoypadVelocityDone

; Left alone: Y = 0, X = -8 ($F8).

  JoypadVelocityPureLeft:
    LDA #$00              ; Pure left: Y = 0, X = -8 ($F8)
    XBA 
    LDA #$F8

; Exit of the left handlers and of the no-direction case: restore P and return with the packed velocity (Y in the high byte, X in the low byte).

  JoypadVelocityDone:
    PLP 
    RTS 

; Right held (Left clear): the same structure as the left handler: neither vertical bit goes to JoypadVelocityPureRight, Up goes to JoypadVelocityUpRight, otherwise Down + Right: Y = +6, X = +6.

  JoypadVelocityRight:
    BIT #$0C              ; Right handler: same structure as the left handler
    BEQ JoypadVelocityPureRight
    BIT #$08
    BNE JoypadVelocityUpRight
    LDA #$06              ; Down + Right: Y = +6, X = +6
    XBA 
    LDA #$06
    BRA JoypadVelocityDoneRight

; Up + Right: Y = -6, X = +6.

  JoypadVelocityUpRight:
    LDA #$FA              ; Up + Right: Y = -6, X = +6
    XBA 
    LDA #$06
    BRA JoypadVelocityDoneRight

; Right alone: Y = 0, X = +8.

  JoypadVelocityPureRight:
    LDA #$00              ; Pure right: Y = 0, X = +8
    XBA 
    LDA #$08

; Exit of the right handlers: restore P and return (same as JoypadVelocityDone).

  JoypadVelocityDoneRight:
    PLP 
    RTS 

; Up held with Left and Right clear: Y = -8, X = 0; restores P and returns directly.

  JoypadVelocityPureUp:
    LDA #$F8              ; Pure up: Y = -8 ($F8), X = 0
    XBA 
    LDA #$00
    PLP 
    RTS 

; Down held with Left, Right and Up clear: Y = +8, X = 0; restores P and returns directly.

  JoypadVelocityPureDown:
    LDA #$08              ; Pure down: Y = +8, X = 0
    XBA 
    LDA #$00
    PLP 
    RTS 
}