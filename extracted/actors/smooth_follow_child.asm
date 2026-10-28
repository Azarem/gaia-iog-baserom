; Straight-line projectile mover (Bank 00, 58587-58964), shared by six enemy projectile scripts. smooth_follow_child is the visible projectile body; a hidden child (SmoothFollowChildTick) aims ONCE at a target actor and then moves along that fixed heading at a fixed speed, copying its position to the body every frame. It does not chase: after the first frame the target is ignored.
; 
; === CALLERS ===
; 
; pyCC_blaster (two projectile actors), awB1_wall_walker (code_0BBD19), ec0C_ribber (code_0A843E) and the unused unused_follow_chain set $24 = playerActor, a speed in loopCounter ($7F0014: 1 in pyCC_blaster and ec0C_ribber, 2 in awB1 and gw8A) and then enter smooth_follow_child by a tail call (push of bank and entry minus 1, RTL). gw8A_sand_fanger (code_0B8979) and pyDD_mummy_queen (code_0BA782) skip the body and spawn SmoothFollowChildTick themselves with SpawnAfterMarked (flags $2000), storing playerActor in the child's $24; pyDD uses the speed 4 + $0B02. In every case the spawner is the projectile itself, so the tick moves the spawner.
; combat_collision uses SmoothFollowChildDie as the default onCollideCallback: an actor with extendedFlags $0010 and no callback of its own is pointed at it when it touches the player, so these projectiles die after the hit is applied.
; 
; === HOW IT WORKS ===
; 
; 1. smooth_follow_child clears word $2A, spawns the tick as a hidden marked child (flags $2000) and gives it the target in $24. If the pool is full (Y = $1FC0) it dies at once. Then it plays AnimOnce every frame and dies when its own $10 bit $4000 is set. That bit is the off-screen flag SortActorsByDepth sets when the actor box is completely off the screen; it is not set by a parent. Die also kills the marked tick.
; 2. On its first frame the tick copies the body's loopCounter (the speed: pixels per frame on the dominant axis), forms dx = target.X - self.X and dy = target.Y - 8 - self.Y, stores |dx| in $0018 and |dy| in $001C (global scratch words, not actor fields) and picks one of 8 handlers from the signs and from which magnitude is larger.
; 3. The handler calls ComputeFollowAngle (Y-dominant) or ComputeFollowAngleAlt (X-dominant) once. That fills orbitAngle with a slope row of smooth_follow's dither table and clears the dither phase. COP SetEntryHere then saves the address of the next instruction, so every later frame resumes AFTER the aim: ComputeFollowStep gives $0000 = major-axis pixels (loopCounter) and $0002 = minor-axis pixels (0 or 1 per pixel from the slope row), the handler applies them to the tick's own X/Y with its fixed signs, and SmoothFollowWriteParentPos copies X/Y to the body (the tick's $04 prev-link). The heading never changes.
; 
; === HANDLER HEADINGS ===
; 
; dx >= 0, dy >= 0 (target south-east): |dy| >= |dx| SmoothFollowApplySSE (Y += major, X += minor); |dy| < |dx| SmoothFollowApplyESE (X += major, Y += minor).
; dx >= 0, dy < 0 (north-east): |dy| >= |dx| SmoothFollowApplyNNE (Y -= major, X += minor); |dy| < |dx| SmoothFollowApplyENE (X += major, Y -= minor).
; dx < 0, dy >= 0 (south-west): |dy| >= |dx| SmoothFollowApplySSW (Y += major, X -= minor); |dy| < |dx| SmoothFollowApplyWSW (X -= major, Y += minor).
; dx < 0, dy < 0 (north-west): |dy| >= |dx| SmoothFollowApplyNNW (Y -= major, X -= minor); |dy| < |dx| SmoothFollowApplyWNW (X -= major, Y -= minor).
; Each handler is named after the heading it fires. Five of them were first called SmoothFollowApplyEastPrimary (SSE), EastSecondary (SSW), WestPrimary (WSW), WestSecondary (WNW) and SouthPrimary (NNW), which described neither the dominant axis nor the direction, and three (NNE, ENE, ESE) had only loc_ labels.
; 
; === CORRECTIONS ===
; 
; The old header said the actor makes a child 'smoothly chase a reference actor', that it updates 'both actors' positions each frame' and that it dies 'when the parent actor sets flag $4000 or on special actor ID $1FC0'. The aim is taken once; only the tick moves and it writes the body's position; $4000 is the body's own off-screen flag and $1FC0 is the pool-exhausted result of the spawn.
---------------------------------------------

?BANK 00

?INCLUDE 'smooth_follow'

!loopCounter                    7F0014

---------------------------------------------

; Projectile body. Clears word $2A, spawns SmoothFollowChildTick as a hidden marked child (flags $2000) and hands it the target from $24 (set by the caller: the player). Y = $1FC0 (no free actor) kills the body. Otherwise it plays AnimOnce each frame and dies when its own $10 bit $4000 (off-screen flag) is set. The body never moves by itself: the tick writes its X/Y.

smooth_follow_child {
    STZ $002A, X          ; Clear actor word $2A (scratch; its use here was not traced)
    COP [SpawnAfterMarked] ( @SmoothFollowChildTick, #$2000 ) ; Hidden marked child that moves this actor; Y = child, or $1FC0 when the pool is full
    CPY #$1FC0            ; Actor pool exhausted?
    BEQ SmoothFollowChildDie ; Yes → die immediately
    LDA $24               ; Target actor slot (the caller stores playerActor in $24) becomes the tick's $24
    STA $0024, Y

; Idle loop of the body: SetEntryHere + AnimOnce (one frame per pass); leaves to SmoothFollowChildDie when the actor box is off-screen ($10 bit $4000).

  SmoothFollowChildBodyLoop:
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA $10
    BIT #$4000            ; Own $10 bit $4000 = actor box completely off-screen (set each frame by SortActorsByDepth)
    BEQ SmoothFollowChildBodyLoop ; No → continue idle loop

; COP Die. Also the default onCollideCallback: RunInteractionCollision points an actor with extendedFlags $0010 and no callback at this label when it touches the player, so a projectile that hits dies here (after the damage). Die also kills the marked tick child.

  SmoothFollowChildDie:
    COP [Die]
}

---------------------------------------------
; Hidden aiming child (spawned by smooth_follow_child, gw8A_sand_fanger and pyDD_mummy_queen). On its first frame: copy the speed from the parent's loopCounter, form dx = target.X - self.X and dy = target.Y - 8 - self.Y (the 8 aims at the target's middle), store |dx| in $0018 and |dy| in $001C and branch to one of 8 handlers by the signs and the larger magnitude (heading table in the block note). The handlers call SetEntryHere after the aim, so this dispatch code runs only once.

SmoothFollowChildTick {
    TXY 
    LDX $0004, Y          ; X := tick's $04 prev-link = the actor that spawned it (the projectile body)
    LDA $loopCounter, X   ; Speed (pixels per frame on the dominant axis) from the body's loopCounter; copied only on the first frame
    TYX 
    STA $loopCounter, X
    LDY $24               ; Y = target actor pointer
    LDA $0014, Y          ; deltaX = target.X - self.X
    SEC 
    SBC $14
    BMI SmoothFollowTickTargetWest ; Target is west → negate X
    STA $0018             ; $18 = |deltaX| (target is east)
    LDA $0016, Y          ; deltaY = target.Y - 8 - self.Y
    SEC 
    SBC #$0008            ; Center Y on sprite midpoint
    SEC 
    SBC $16
    BMI SmoothFollowTickTargetNorth ; Target is north → negate Y
    STA $001C             ; $1C = |deltaY| (target is south)
    CMP $0018             ; Compare |deltaY| vs |deltaX|
    BCC SmoothFollowTickGoESE ; |dy| < |dx|: X-dominant, ESE
    JMP $&SmoothFollowApplySSE ; |dy| >= |dx|: Y-dominant, SSE

; dx >= 0, dy >= 0, |dy| < |dx|: X-dominant, continue at SmoothFollowApplyESE (ESE).

  SmoothFollowTickGoESE:
    BRA SmoothFollowApplyESE ; To the ESE handler

; dx >= 0, dy < 0 (target north): negate dy, then |dy| >= |dx| goes to SmoothFollowApplyNNE (NNE) and |dy| < |dx| to SmoothFollowApplyENE (ENE).

  SmoothFollowTickTargetNorth:
    EOR #$FFFF            ; Negate deltaY (target is north)
    INC 
    STA $001C             ; $1C = |deltaY|
    CMP $0018             ; Compare |deltaY| vs |deltaX|
    BCS SmoothFollowApplyNNE ; |dy| >= |dx|: Y-dominant, NNE
    BRA SmoothFollowApplyENE ; |dy| < |dx|: X-dominant, ENE

; dx < 0 (target west): negate dx, recompute dy, then split into SW (dy >= 0) and NW (SmoothFollowTickTargetNorthWest).

  SmoothFollowTickTargetWest:
    EOR #$FFFF            ; Negate deltaX (target is west)
    INC 
    STA $0018             ; $18 = |deltaX|
    LDA $0016, Y          ; Recompute deltaY for west quadrant
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI SmoothFollowTickTargetNorthWest ; Target is NW
    STA $001C             ; Target is SW: $1C = |deltaY|
    CMP $0018
    BCC SmoothFollowTickGoWSW ; |dy| < |dx|: X-dominant, WSW
    JMP $&SmoothFollowApplySSW ; |dy| >= |dx|: Y-dominant, SSW

; SW with |dy| < |dx|: jump to SmoothFollowApplyWSW (WSW).

  SmoothFollowTickGoWSW:
    JMP $&SmoothFollowApplyWSW

; dx < 0, dy < 0 (north-west): negate dy; |dy| >= |dx| jumps to SmoothFollowApplyNNW (NNW), otherwise SmoothFollowTickGoWNW.

  SmoothFollowTickTargetNorthWest:
    EOR #$FFFF            ; Negate deltaY (target is NW)
    INC 
    STA $001C             ; $1C = |deltaY|
    CMP $0018
    BCC SmoothFollowTickGoWNW ; |dy| < |dx|: X-dominant, WNW
    JMP $&SmoothFollowApplyNNW ; |dy| >= |dx|: Y-dominant, NNW

; NW with |dy| < |dx|: jump to SmoothFollowApplyWNW (WNW).

  SmoothFollowTickGoWNW:
    JMP $&SmoothFollowApplyWNW

; Heading NNE (target north-east, |dy| >= |dx|). Aims once with ComputeFollowAngle, SetEntryHere, then each frame Y -= major ($0000) and X += minor ($0002); writes the position to the body.

  SmoothFollowApplyNNE:
    JSR $&smooth_follow.ComputeFollowAngle ; Aim once: slope row for |dx|/|dy| into orbitAngle, dither phase 0 (Y-dominant)
    COP [SetEntryHere]    ; Later frames resume after this point: the aim above is never repeated
    JSR $&smooth_follow.ComputeFollowStep ; $0000 = major-axis pixels (loopCounter), $0002 = minor-axis pixels (dithered)
    LDA $16               ; Y -= major (north)
    SEC 
    SBC $0000
    STA $16
    LDA $14               ; X += minor (east)
    CLC 
    ADC $0002
    STA $14
    JMP $&SmoothFollowWriteParentPos

; Heading ENE (target north-east, |dx| > |dy|). Aims once with ComputeFollowAngleAlt, then each frame X += major and Y -= minor.

  SmoothFollowApplyENE:
    JSR $&smooth_follow.ComputeFollowAngleAlt ; Aim once (X-dominant)
    COP [SetEntryHere]    ; Later frames resume here
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14               ; X += major (east)
    CLC 
    ADC $0000
    STA $14
    LDA $16               ; Y -= minor (north)
    SEC 
    SBC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos

; Heading ESE (target south-east, |dx| > |dy|). Aims once with ComputeFollowAngleAlt, then each frame X += major and Y += minor.

  SmoothFollowApplyESE:
    JSR $&smooth_follow.ComputeFollowAngleAlt ; Aim once (X-dominant)
    COP [SetEntryHere]    ; Later frames resume here
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14               ; X += major (east)
    CLC 
    ADC $0000
    STA $14
    LDA $16               ; Y += minor (south)
    CLC 
    ADC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos
}

---------------------------------------------
; Heading SSE: target south-east (dx >= 0, dy >= 0) with |dy| >= |dx|. ComputeFollowAngle once, then each frame Y += major ($0000) and X += minor ($0002).

SmoothFollowApplySSE {
    JSR $&smooth_follow.ComputeFollowAngle ; Aim once (Y-dominant)
    COP [SetEntryHere]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    CLC 
    ADC $0002
    STA $14
    JMP $&SmoothFollowWriteParentPos
}

---------------------------------------------
; Heading SSW: target south-west (dx < 0, dy >= 0) with |dy| >= |dx|. ComputeFollowAngle once, then each frame Y += major and X -= minor. Reached from the west half of the tick.

SmoothFollowApplySSW {
    JSR $&smooth_follow.ComputeFollowAngle ; Aim once (Y-dominant)
    COP [SetEntryHere]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA SmoothFollowWriteParentPos
}

---------------------------------------------
; Heading WSW: target south-west with |dx| > |dy|. ComputeFollowAngleAlt once, then each frame X -= major and Y += minor.

SmoothFollowApplyWSW {
    JSR $&smooth_follow.ComputeFollowAngleAlt ; Aim once (X-dominant)
    COP [SetEntryHere]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    CLC 
    ADC $0002
    STA $16
    BRA SmoothFollowWriteParentPos
}

---------------------------------------------
; Heading WNW: target north-west with |dx| > |dy|. ComputeFollowAngleAlt once, then each frame X -= major and Y -= minor.

SmoothFollowApplyWNW {
    JSR $&smooth_follow.ComputeFollowAngleAlt ; Aim once (X-dominant)
    COP [SetEntryHere]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    SEC 
    SBC $0002
    STA $16
    BRA SmoothFollowWriteParentPos
}

---------------------------------------------
; Heading NNW: target north-west with |dy| >= |dx|. ComputeFollowAngle once, then each frame Y -= major and X -= minor.

SmoothFollowApplyNNW {
    JSR $&smooth_follow.ComputeFollowAngle ; Aim once (Y-dominant)
    COP [SetEntryHere]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    SEC 
    SBC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA SmoothFollowWriteParentPos
}

---------------------------------------------
; Copy the tick's X/Y to the actor in its $04 prev-link (the spawner, i.e. the visible projectile) and return (RTL). This is the only way the body moves.

SmoothFollowWriteParentPos {
    LDA $0004, X          ; Body = the tick's prev-link
    TAY 
    LDA $0014, X          ; Copy self.X → parent.X
    STA $0014, Y
    LDA $0016, X          ; Copy self.Y → parent.Y
    STA $0016, Y
    RTL 
}