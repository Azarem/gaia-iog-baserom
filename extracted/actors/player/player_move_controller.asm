; Per-frame player movement controller — SpawnAfter companion actor (176798–177195).
; 
; Spawned by PlayerCharacterDef as a SpawnAfter companion. Runs every frame after the player character actor to handle physics integration and position updates.
; 
; === PIPELINE ===
; 
; 1. SUBPIXEL SCALING: Scales local coordinates ($14, $16) by ×4 to sub-pixel precision (2 fractional bits).
; 
; 2. FREEZE CHECK: If player actor flag $0080 (freeze) is set AND iframeCounter is non-negative (no active invincibility), skip the entire frame. If iframes are active (negative counter), movement continues even while frozen.
; 
; 3. CLIMB/SPECIAL GATE: If playerFlags bits 9+11 ($0A00 = $0200 climb + $0800 special) are set, zero external velocities and skip — position is controlled by the traversal system (vine/ladder/shimmy) directly.
; 
; 4. POSITION SYNC: Compare local position with player actor position. If they differ (e.g. player was teleported by a script or COP command), re-sync local to match the player actor.
; 
; 5. VELOCITY CALCULATION: Two mutually exclusive paths per axis:
;    a. Speed == 0 (idle/walking): Use D-pad velocity from JoypadToVelocity + external velocity ($0408/$040A)
;    b. Speed != 0 (running/inertial): Use playerSpeed × 4 + external velocity, then clear playerFlags bit 12 ($1000 walk-attack)
; 
; 6. COLLISION: If player is grounded (flag $0008), call player_move_main.PlayerMovementTick for full tile collision. If airborne, directly add delta to position (no collision).
; 
; 7. WRITEBACK: Store final sub-pixel positions back to local ($14,$16) and player actor pixel positions ($0014,$0016). Sync actor flag bit 2 (solid contact) from local to player.
; 
; === SUB-PIXEL MODEL ===
; Positions use 2 fractional bits (×4 scaling). Pixel position = sub-pixel >> 2. This gives 0.25-pixel movement resolution. Cardinal D-pad velocity is ±8 sub-pixels (2.0 px/frame), diagonal is ±6 (1.5 px/frame ≈ cardinal/√2 for normalized diagonal speed).
; 
; === JoypadToVelocity ===
; Converts D-pad state ($0657, joypad high byte) to a packed 16-bit velocity: high byte = NS (Y), low byte = EW (X). Priority: Left > Right > Up > Down. Cardinal = ±8, diagonal = ±6.
---------------------------------------------

?INCLUDE 'player_move_main'

!extVelocityX                   0408
!extVelocityY                   040A
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!iframeCounter                  7F0028

---------------------------------------------

; Per-frame player movement integration — SpawnAfter companion actor.
; 
; Seven-stage pipeline executed every frame after the player character:
; 1. SUBPIXEL SCALING: Local coords ($14,$16) × 4 for 2-bit fractional precision (0.25 px resolution)
; 2. FREEZE CHECK: Skip if actor flag $0080 (freeze) set AND iframeCounter non-negative
; 3. CLIMB/SPECIAL GATE: If playerFlags $0A00 ($0200 climb + $0800 special), zero external velocities and skip
; 4. POSITION SYNC: If local position differs from player actor (teleported), re-sync
; 5. VELOCITY CALC: Combine joypad D-pad velocity (from JoypadToVelocity) OR speed × 4 with external velocity ($0408/$040A). Attack/run flags ($3000) force zero joypad velocity
; 6. COLLISION: Grounded ($0008) → PlayerMovementTick (full tile collision). Airborne → direct position add
; 7. WRITEBACK: Store sub-pixel and pixel positions back to actor, sync flag bit 2 (solid contact)
; 
; External velocities (wind, conveyors, knockback) are consumed each frame — sources must re-apply them every frame to persist.

PlayerMoveController {
    LDA $14               ; Per-frame movement companion: scale local X/Y to sub-pixel precision (×4 = 2 fractional bits)
    ASL 
    ASL 
    STA $14
    LDA $16
    ASL 
    ASL 
    STA $16
    COP [SetEntryContinue] ; Actor continue — runs each frame after player_character
    PHX                   ; Check if player is frozen ($0080) — if frozen with no active iframes, skip movement entirely
    LDX $playerActor
    LDA $0010, X
    BIT #$0080
    BEQ loc_02B2C0
    LDA $iframeCounter, X ; Negative iframe counter = active invincibility → allow movement even while frozen
    BMI loc_02B2C0
    PLX                   ; Frozen + no iframes → skip this frame (no position update)
    RTL 

  loc_02B2C0:
    PLX 
    LDA $playerFlags      ; Check climb/special flags ($0A00 = $0200 climb + $0800 special state)
    BIT #$0A00
    BEQ loc_02B2D0
    STZ $extVelocityX     ; Climbing or special traversal active → zero external velocities and skip (traversal controls position directly)
    STZ $extVelocityY
    RTL 

  loc_02B2D0:
    LDY $playerActor      ; Sync local position with player actor — if actor was teleported, re-sync local sub-pixel coordinates
    LDA $14
    LSR 
    LSR 
    CMP $0014, Y
    BEQ loc_02B2E3
    LDA $0014, Y
    ASL 
    ASL 
    STA $14

  loc_02B2E3:
    LDA $16               ; Same Y-axis sync: compare local Y with player actor Y, override if different
    LSR 
    LSR 
    CMP $0016, Y
    BEQ loc_02B2F3
    LDA $0016, Y
    ASL 
    ASL 
    STA $16

  loc_02B2F3:
    LDA $playerFlags      ; Check attack/run flags ($3000 = $1000 attack-walk + $2000 run) — if either set, zero joypad velocity
    BIT #$3000
    BEQ loc_02B300
    LDA #$0000
    BRA loc_02B303

  loc_02B300:
    JSR $&JoypadToVelocity ; Normal state: convert D-pad to velocity via JoypadToVelocity

  loc_02B303:
    PHA                   ; Push packed joypad velocity (high=NS, low=EW) and begin EW axis processing
    LDA $14
    STA $0022             ; Save current sub-pixel X position to work area $0022
    STZ $0020
    LDA $playerSpeedEw    ; Check EW speed: if zero (idle), use joypad + external; if nonzero (running), use speed × 4 + external
    BNE loc_02B327
    LDA $01, S            ; Idle EW: extract low byte (EW velocity) from joypad result, sign-extend from 8 to 16 bits
    AND #$00FF
    BIT #$0080
    BEQ loc_02B31E
    ORA #$FF00

  loc_02B31E:
    CLC 
    ADC $extVelocityX     ; Add external EW velocity ($0408) — e.g. wind, conveyor belts, knockback
    STA $0020
    BRA loc_02B336

  loc_02B327:
    ASL                   ; Running EW: speed × 4 (ASL ASL) to convert to sub-pixel velocity, add external velocity
    ASL 
    CLC 
    ADC $extVelocityX
    STA $0020
    LDA #$1000            ; Clear walk-attack flag ($1000) — active running overrides walk-attack state
    TRB $playerFlags

  loc_02B336:
    STZ $extVelocityX     ; Consume extVelocityX, begin NS axis processing
    STZ $0024
    LDA $16
    STA $0026
    LDA $playerSpeedNs    ; Check NS speed: same dual-path as EW axis
    BNE loc_02B360
    STZ $slopeFracAccum   ; Idle NS: zero slope fractional accumulator (no slope physics when stopped)
    LDA $01, S            ; Extract high byte (NS velocity) via XBA from joypad result, sign-extend
    XBA 
    AND #$00FF
    BIT #$0080
    BEQ loc_02B357
    ORA #$FF00

  loc_02B357:
    CLC 
    ADC $extVelocityY
    STA $0024
    BRA loc_02B36F

  loc_02B360:
    ASL                   ; Running NS: speed × 4, add external velocity, clear walk-attack flag
    ASL 
    CLC 
    ADC $extVelocityY
    STA $0024
    LDA #$1000
    TRB $playerFlags

  loc_02B36F:
    STZ $extVelocityY     ; Consume extVelocityY, pop joypad value, check ground flag for collision path
    PLA 
    LDY $playerActor
    LDA $0010, Y
    BIT #$0008            ; Ground flag ($0008): if grounded → full tile collision via PlayerMovementTick
    BNE loc_02B394
    LDA $0020             ; Airborne: directly add deltas to position (no tile collision, free movement)
    CLC 
    ADC $0022
    STA $0022
    LDA $0024
    CLC 
    ADC $0026
    STA $0026
    BRA loc_02B39C

  loc_02B394:
    STX $000A             ; Grounded: save actor index, call player_move_main.PlayerMovementTick for collision detection
    TXY 
    JSL $@player_move_main.PlayerMovementTick

  loc_02B39C:
    LDY $playerActor      ; Write final sub-pixel position to local coords and pixel position to player actor
    LDA $0022
    STA $14
    LSR 
    LSR 
    STA $0014, Y          ; Convert sub-pixel X (>>2) to pixel X and store to player actor slot
    LDA $0026
    STA $16
    LSR 
    LSR 
    STA $0016, Y          ; Same for Y axis: sub-pixel → pixel → player actor
    LDA $0010, Y          ; Sync flag bit 2 (solid contact): copy from local actor flags ($10) to player actor ($0010,Y)
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
; Convert D-pad state to packed velocity vector.
; 
; Reads joypad high byte ($0657) in 8-bit mode. Scans D-pad bits in priority order: Left ($02) > Right ($01) > Up ($08) > Down ($04). For diagonal combinations (two D-pad bits), generates reduced-magnitude velocity (±6 instead of ±8) for normalized diagonal speed.
; 
; Returns 16-bit packed result: high byte = NS (Y) velocity, low byte = EW (X) velocity.
; Cardinal: ±8 sub-pixels (2.0 px/frame). Diagonal: ±6 sub-pixels (1.5 px/frame ≈ cardinal/√2).
; Signs: positive X = East, negative X = West, positive Y = South, negative Y = North.

JoypadToVelocity {
    PHP                   ; Convert D-pad state to packed velocity: high byte = NS(Y), low byte = EW(X). Priority: L > R > U > D
    SEP #$20
    LDA $0657             ; Read joypad high byte ($0657) in 8-bit mode — bits: ----UDLR
    BIT #$02              ; Left pressed → left handler (has priority over right)
    BNE loc_02B3E3
    BIT #$01              ; Right pressed → right handler
    BNE loc_02B400
    BIT #$08              ; Up only → pure north velocity (Y=-8, X=0)
    BNE loc_02B41D
    BIT #$04              ; Down only → pure south velocity (Y=+8, X=0)
    BNE loc_02B424
    LDA #$00              ; No D-pad held → zero velocity (Y=0, X=0)
    XBA 
    LDA #$00
    BRA loc_02B3FE

  loc_02B3E3:
    BIT #$0C              ; Left handler: check for vertical component (Up/Down held simultaneously)
    BEQ loc_02B3F9
    BIT #$08
    BNE loc_02B3F2
    LDA #$06              ; Down+Left diagonal: Y=+6, X=-6 (reduced magnitude for normalized diagonal speed)
    XBA 
    LDA #$FA
    BRA loc_02B3FE

  loc_02B3F2:
    LDA #$FA              ; Up+Left diagonal: Y=-6, X=-6
    XBA 
    LDA #$FA
    BRA loc_02B3FE

  loc_02B3F9:
    LDA #$00              ; Pure Left: Y=0, X=-8 ($F8 signed)
    XBA 
    LDA #$F8

  loc_02B3FE:
    PLP 
    RTS 

  loc_02B400:
    BIT #$0C              ; Right handler: check for vertical component
    BEQ loc_02B416
    BIT #$08
    BNE loc_02B40F
    LDA #$06              ; Down+Right diagonal: Y=+6, X=+6
    XBA 
    LDA #$06
    BRA loc_02B41B

  loc_02B40F:
    LDA #$FA              ; Up+Right diagonal: Y=-6, X=+6
    XBA 
    LDA #$06
    BRA loc_02B41B

  loc_02B416:
    LDA #$00              ; Pure Right: Y=0, X=+8
    XBA 
    LDA #$08

  loc_02B41B:
    PLP 
    RTS 

  loc_02B41D:
    LDA #$F8              ; Pure Up: Y=-8 ($F8), X=0
    XBA 
    LDA #$00
    PLP 
    RTS 

  loc_02B424:
    LDA #$08              ; Pure Down: Y=+8, X=0
    XBA 
    LDA #$00
    PLP 
    RTS 
}