; Helper actor spawned by boss and puzzle scripts to make a child actor smoothly chase a reference actor.
; 
; Computes directional follow steps via smooth_follow.ComputeFollowAngle/ComputeFollowStep based on relative X/Y offsets, updating both actors' positions each frame. Used in Pyramid Blaster, Angkor wall walker, Mummy Queen, Sand Fanger, Edward Ribber, and other chase segments. Dies when the parent actor sets flag $4000 or on special actor ID $1FC0.
---------------------------------------------

?BANK 00

?INCLUDE 'smooth_follow'

!loopCounter                    7F0014

---------------------------------------------

; Entry point: spawn a SmoothFollowChildTick child for per-frame position updates, pass target ref ($24), then idle-animate until parent sets $4000 kill flag.

smooth_follow_child {
    STZ $002A, X          ; Clear scratch
    COP [SpawnMarkedAfter] ( @SmoothFollowChildTick, #$2000 ) ; Spawn tick handler as child actor
    CPY #$1FC0            ; Actor pool exhausted?
    BEQ SmoothFollowChildDie ; Yes → die immediately
    LDA $24               ; Pass chase target actor ID to child
    STA $0024, Y

  loc_00E4EF:
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000            ; Parent set kill flag?
    BEQ loc_00E4EF        ; No → continue idle loop

; Kill entry point, also used as default collision callback by combat_collision for non-combat actors.

  SmoothFollowChildDie:
    COP [Die]
}

---------------------------------------------
; Per-frame tick: compute relative offset (target - self) for X and Y, determine which quadrant the target is in, then dispatch to the appropriate directional follow routine. Y offset is biased by -8px to center on the sprite midpoint.

SmoothFollowChildTick {
    TXY 
    LDX $0004, Y          ; Load parent actor pointer
    LDA $loopCounter, X   ; Copy parent's loop counter to self
    TYX 
    STA $loopCounter, X
    LDY $24               ; Y = target actor pointer
    LDA $0014, Y          ; deltaX = target.X - self.X
    SEC 
    SBC $14
    BMI loc_00E53D        ; Target is west → negate X
    STA $0018             ; $18 = |deltaX| (target is east)
    LDA $0016, Y          ; deltaY = target.Y - 8 - self.Y
    SEC 
    SBC #$0008            ; Center Y on sprite midpoint
    SEC 
    SBC $16
    BMI loc_00E52F        ; Target is north → negate Y
    STA $001C             ; $1C = |deltaY| (target is south)
    CMP $0018             ; Compare |deltaY| vs |deltaX|
    BCC loc_00E52D        ; |deltaY| < |deltaX| → east+south secondary
    JMP $&SmoothFollowApplyEastPrimary ; |deltaY| >= |deltaX| → east primary

  loc_00E52D:
    BRA loc_00E5A6        ; East + South: alt angle path

  loc_00E52F:
    EOR #$FFFF            ; Negate deltaY (target is north)
    INC 
    STA $001C             ; $1C = |deltaY|
    CMP $0018             ; Compare |deltaY| vs |deltaX|
    BCS loc_00E570        ; |deltaY| >= |deltaX| → north primary
    BRA loc_00E58B        ; |deltaY| < |deltaX| → east+north secondary

  loc_00E53D:
    EOR #$FFFF            ; Negate deltaX (target is west)
    INC 
    STA $0018             ; $18 = |deltaX|
    LDA $0016, Y          ; Recompute deltaY for west quadrant
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E55E        ; Target is NW
    STA $001C             ; Target is SW: $1C = |deltaY|
    CMP $0018
    BCC loc_00E55B        ; |deltaY| < |deltaX| → west primary
    JMP $&SmoothFollowApplyEastSecondary ; |deltaY| >= |deltaX| → east secondary (SW)

  loc_00E55B:
    JMP $&SmoothFollowApplyWestPrimary

  loc_00E55E:
    EOR #$FFFF            ; Negate deltaY (target is NW)
    INC 
    STA $001C             ; $1C = |deltaY|
    CMP $0018
    BCC loc_00E56D        ; |deltaY| < |deltaX| → west secondary
    JMP $&SmoothFollowApplySouthPrimary ; |deltaY| >= |deltaX| → south primary (NW)

  loc_00E56D:
    JMP $&SmoothFollowApplyWestSecondary

  loc_00E570:
    JSR $&smooth_follow.ComputeFollowAngle ; North primary: compute angle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep ; Compute step from angle
    LDA $16               ; Y -= step (move north)
    SEC 
    SBC $0000
    STA $16
    LDA $14               ; X += step (move east)
    CLC 
    ADC $0002
    STA $14
    JMP $&SmoothFollowWriteParentPos

  loc_00E58B:
    JSR $&smooth_follow.ComputeFollowAngleAlt ; East+North secondary: alt angle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14               ; X += step (move east)
    CLC 
    ADC $0000
    STA $14
    LDA $16               ; Y -= step (move north)
    SEC 
    SBC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos

  loc_00E5A6:
    JSR $&smooth_follow.ComputeFollowAngleAlt ; East+South secondary: alt angle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14               ; X += step (move east)
    CLC 
    ADC $0000
    STA $14
    LDA $16               ; Y += step (move south)
    CLC 
    ADC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos
}

---------------------------------------------
; Apply follow step when target is east and |deltaY| dominates: Y += step, X += step.

SmoothFollowApplyEastPrimary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
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
; Apply follow step when target is east-secondary (SW quadrant): Y += step, X -= step.

SmoothFollowApplyEastSecondary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
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
; Apply follow step when target is west and |deltaX| dominates: X -= step, Y += step.

SmoothFollowApplyWestPrimary {
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
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
; Apply follow step when target is west-secondary (NW quadrant): X -= step, Y -= step.

SmoothFollowApplyWestSecondary {
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
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
; Apply follow step when target is south-primary (NW when |deltaY| dominates): Y -= step, X -= step.

SmoothFollowApplySouthPrimary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
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
; Write this actor's updated position back to the parent actor's position fields.

SmoothFollowWriteParentPos {
    LDA $0004, X          ; Parent actor pointer
    TAY 
    LDA $0014, X          ; Copy self.X → parent.X
    STA $0014, Y
    LDA $0016, X          ; Copy self.Y → parent.Y
    STA $0016, Y
    RTL 
}