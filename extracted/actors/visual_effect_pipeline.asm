; Forced camera-scroll effect system with three actor entry points.
; 
; effect_velocity_init converts actor position to scroll velocity and sets forcedScrollOverride for cutscene camera takeover; effect_subpixel_math applies subpixel scroll math with camera target ratios; effect_position_update integrates velocity with bounds clamping. Spawned in Sky Garden viper lair, Babel Tower plane jump, and other scripted camera-pan sequences. Drives cinematic background scrolling independent of normal player camera.
---------------------------------------------

?INCLUDE 'hardware_math'

!bg1ScrollV                     068C
!savedCameraDelta               0690
!effectBoundsX                  0694
!effectBoundsY                  0698
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!forcedScrollOverride           06C8
!effectDeltaX                   06E4
!effectDeltaY                   06E6

---------------------------------------------

; Visual-effect actor that seeds forced camera scroll from actor placement coordinates.
; 
; Converts actor $14/$16 (pixel position) into signed scroll velocities at $2C/$2E, zeroes integrated position state, waits one frame, then adds effectDeltaX/Y from the camera_scroll_controller and writes forcedScrollOverride ($06C8) with bit 15 set. Spawned in Babel Tower plane-jump and other cutscene scenes.

effect_velocity_init [
  actor-def < #00, #00, #2C, {

  code_00E8DA:
    LDA #$1000
    TSB $12
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080
    BEQ loc_00E8F1
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00E8F1:
    STA $2C
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    BIT #$0080
    BEQ loc_00E906
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00E906:
    STA $2E
    LDA #$0000
    STA $14
    STA $bg1ScrollV
    STA $cameraDeltaX
    STA $16
    STA $savedCameraDelta
    STA $cameraDeltaY
    COP [WaitByte] ( #01 )
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX
    STA $14
    ORA #$8000
    STA $forcedScrollOverride
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY
    STA $16
    STA $cameraDeltaY
    LDA $2C
    STA $06E8
    LDA $cameraDeltaY
    SEC 
    SBC $savedCameraDelta
    STA $06EA
    RTL 
} >
]
---------------------------------------------

; Per-frame subpixel scroll refinement actor spawned alongside effect_position_update.
; 
; On entry calls SetEntryContinue and accumulates fractional scroll: when $14 has a nonzero high byte it scales through hardware_math.MulDivide against cameraTargetX into forcedScrollOverride; otherwise sign-extends and adds the low byte directly. Used in Sky Garden viper lair and mystic-statue sequences for smooth cinematic pans.

effect_subpixel_math {
    COP [SetEntryContinue]
    PEA $&EffectUpdateCameraDeltaY-1
    LDA $14
    BIT #$8000
    BNE loc_00E9A7
    BIT #$FF00
    BEQ loc_00E9BA
    LDY $cameraTargetX
    JSL $@hardware_math.MulDivide
    STA $forcedScrollOverride
    RTS 

  loc_00E9A7:
    AND #$00FF
    BIT #$0080
    BEQ loc_00E9B2
    ORA #$FF00

  loc_00E9B2:
    CLC 
    ADC $forcedScrollOverride
    STA $forcedScrollOverride
    RTS 

  loc_00E9BA:
    BIT #$0080
    BEQ loc_00E9C2
    ORA #$FF00

  loc_00E9C2:
    CLC 
    ADC $forcedScrollOverride
    STA $forcedScrollOverride
    RTS 
}

EffectUpdateCameraDeltaY {
    LDA $16
    BIT #$FF00
    BEQ loc_00E9DC
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide
    STA $cameraDeltaY
    RTL 

  loc_00E9DC:
    BIT #$0080
    BEQ loc_00E9E4
    ORA #$FF00

  loc_00E9E4:
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    RTL 
}
---------------------------------------------

; Integrating scroll actor that advances forced camera motion with hard bounds.
; 
; Each tick converts actor coordinates to velocity ($2C/$2E), adds effectDeltaX/Y, clamps cameraDeltaX against effectBoundsX and cameraDeltaY against effectBoundsY, then writes render deltas to $06E8/$06EA. Pairs with effect_velocity_init and effect_subpixel_math in the visual_effect_pipeline block.

effect_position_update [
  actor-def < #00, #00, #2C, {

  code_00E9EF:
    LDA #$1000
    TSB $12
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080
    BEQ loc_00EA06
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00EA06:
    STA $2C
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    BIT #$0080
    BEQ loc_00EA1B
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00EA1B:
    STA $2E
    LDA #$0000
    STA $14
    STA $16
    COP [SetEntryContinue]
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX
    STA $14
    STA $cameraDeltaX
    BPL loc_00EA43
    LDA $effectBoundsX
    STA $cameraDeltaX
    STA $bg1ScrollV
    STA $14
    BRA loc_00EA53

  loc_00EA43:
    CMP $effectBoundsX
    BCC loc_00EA53
    LDA #$0000
    STA $cameraDeltaX
    STA $14
    STA $bg1ScrollV

  loc_00EA53:
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY
    STA $16
    STA $cameraDeltaY
    BPL loc_00EA71
    LDA $effectBoundsY
    DEC 
    STA $cameraDeltaY
    STA $savedCameraDelta
    STA $16
    BRA loc_00EA81

  loc_00EA71:
    CMP $effectBoundsY
    BCC loc_00EA81
    LDA #$0000
    STA $cameraDeltaY
    STA $16
    STA $savedCameraDelta

  loc_00EA81:
    LDA $cameraDeltaX
    SEC 
    SBC $bg1ScrollV
    STA $06E8
    LDA $cameraDeltaY
    SEC 
    SBC $savedCameraDelta
    STA $06EA
    RTL 
} >
]