; Layer-1 scroll drivers (Bank 00, 59610-60053): three actor scripts that set the scroll position of the second background layer (cameraDeltaX / Y). They were first grouped as visual_effect_pipeline, a name that suggested sprites or visual effects; they have nothing to do with either.
; 
; === SPAWN ===
; 
; - Layer1DriftWrapped: scene actor record < X byte $01, Y byte $82 > in scene_actors entries $09 and $32 (scene_09_actors, scene_32_actors).
; - Layer1DriftUnbounded: record < $02, $02 > in scene_actors entries $4E and $50 (scene_4E_actors, scene_50_actors).
; - Layer1ParallaxRatio: sg55_viper_arena (SpawnBeforeFlags #$2800, then $14 := $0201 and $16 := 0) and sg55_mystic_statue code_0ACE81 ($14 := $0201, $16 := $000C).
; 
; === SPAWN BYTES = VELOCITY (the first two actors) ===
; 
; InitActorFromSceneData turns the record's X and Y bytes into pixels (byte x 16), so $14 >> 4 gives the X byte back and $16 >> 4 the Y byte. Both are decoded as sign-magnitude: bit 7 = negative, bits 0-6 = magnitude. The Y byte is decremented first, so Y byte 1 = 0, 2 = +1, $82 = -1; Y byte 0 gives $0081 (+129), a quirk the shipped records never use. Result: Layer1DriftWrapped drifts at X +1, Y -1 px per frame; Layer1DriftUnbounded at X +2, Y +1.
; 
; === VARIABLES ===
; 
; cameraTargetX / Y ($06BE / $06C2): layer-0 scroll target (camera_scroll_controller). cameraDeltaX / Y ($06C0 / $06C4): the layer-1 scroll POSITION, not a delta: CameraSmoothScroll (camera_tilemap) copies them to effectScrollH / V ($068C / $0690, the BG2 scroll) when layerPriorityFlag bit $0400 is set. effectDeltaX / Y ($06E4 / $06E6): written by camera_scroll_controller, how far the camera moved (target - current scroll); the drifters add it so layer 1 follows the camera. effectBoundsX / Y ($0694 / $0698): layer-1 width and height (set in scene_script). effectRenderDeltaX / Y ($06E8 / $06EA): written only by these actors; no reader was found outside scene_lifecycle, which clears them. forcedScrollOverride ($06C8): written here with bit 15 set, the same convention as ScrollCameraInit; no reader found (OQ-I051-2).
; 
; The old header said the actors seed and integrate velocities for 'cutscene camera takeover' and that Layer1ParallaxRatio refines the other two every frame. The velocity decode and the integration are in the same actor, and Layer1ParallaxRatio is independent: its $14 / $16 are a parallax ratio or a drift, not a subpixel remainder.
---------------------------------------------

?INCLUDE 'hardware_math'

!effectScrollH                  068C
!effectScrollV                  0690
!effectBoundsX                  0694
!effectBoundsY                  0698
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!forcedScrollOverride           06C8
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!effectRenderDeltaX             06E8
!effectRenderDeltaY             06EA

---------------------------------------------

; Layer-1 drift at constant velocity, no bounds. Actor-def: sprite 0, flags 0, header byte $2C. The spawn bytes are decoded into $2C / $2E (see the block note), the offsets are zeroed, and after a WaitByte #01 (2 ticks) the code integrates every frame: $14 / $16 are the accumulated layer-1 X / Y offset.
; Per frame (after the WaitByte, apparently without an own SetEntryHere: OQ-I051-1): $14 += $2C + effectDeltaX and forcedScrollOverride := $14 | $8000 (X); $16 += $2E + effectDeltaY and cameraDeltaY := $16 (Y); effectRenderDeltaX := the X velocity ($2C), effectRenderDeltaY := cameraDeltaY - effectScrollV. The two axes are not symmetric: X never reaches cameraDeltaX.

Layer1DriftUnbounded [
  actor-def < #00, #00, #2C, {

; Init: $12 |= $1000 (display / overlay-active qualifier), decode the spawn X byte into $2C, then the Y byte (minus 1) into $2E, zero the offsets and the layer-1 scroll state, WaitByte 1, then the per-frame integration; the RTL ends each frame.

  code_00E8DA:
    LDA #$1000
    TSB $12               ; $12 bit $1000: display / overlay-active qualifier, so the actor also runs in the display-filtered modes
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080            ; Spawn X byte (pixels / 16): bit 7 = negative, bits 0-6 = magnitude
    BEQ loc_00E8F1
    AND #$FF7F
    EOR #$FFFF
    INC 

; X velocity stored in $2C; decode the Y byte (minus 1) the same way.

  loc_00E8F1:
    STA $2C               ; $2C := X velocity in px per frame
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC                   ; Spawn Y byte - 1 (Y byte 2 = +1, $82 = -1; byte 0 would give +129, unused)
    BIT #$0080
    BEQ loc_00E906
    AND #$FF7F
    EOR #$FFFF
    INC 

; Y velocity stored in $2E; zero $14 / $16 and the layer-1 scroll state (effectScrollH / V, cameraDeltaX / Y).

  loc_00E906:
    STA $2E               ; $2E := Y velocity in px per frame
    LDA #$0000
    STA $14               ; Zero the accumulated offsets $14 / $16 and the layer-1 scroll state
    STA $effectScrollH
    STA $cameraDeltaX
    STA $16
    STA $effectScrollV
    STA $cameraDeltaY
    COP [WaitByte] ( #01 ) ; WaitByte #01 = 2 ticks (N + 1); the code below then runs every frame (no SetEntryHere in this actor, OQ-I051-1)
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX     ; $14 += X velocity + effectDeltaX (camera movement), so layer 1 also follows the camera
    STA $14
    ORA #$8000
    STA $forcedScrollOverride ; X position with bit 15 set goes to forcedScrollOverride; no reader found (OQ-I051-2)
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY     ; $16 += Y velocity + effectDeltaY
    STA $16
    STA $cameraDeltaY     ; Y position is the layer-1 scroll Y
    LDA $2C
    STA $effectRenderDeltaX ; effectRenderDeltaX := the X velocity (not a position delta)
    LDA $cameraDeltaY     ; effectRenderDeltaY := cameraDeltaY - effectScrollV
    SEC 
    SBC $effectScrollV
    STA $effectRenderDeltaY
    RTL 
} >
]
---------------------------------------------

; Layer-1 parallax ratio or drift, run every frame. The spawner sets $14 (X) and $16 (Y). A word with a nonzero high byte is a RATIO lo / hi: the layer-1 position becomes the camera target x lo / hi (hardware_math.MulDivide: (A low x Y) / A high). $0201 = target x 1 / 2, so layer 1 scrolls at half speed (both sg55 spawns use it for X). With a zero high byte the signed low byte is ADDED every frame instead (for X bit 15 forces this mode too); sg55_mystic_statue sets $16 := $000C, +12 px per frame on cameraDeltaY.
; The X result goes to forcedScrollOverride ($06C8, no reader found: OQ-I051-2), the Y result to cameraDeltaY. The X half returns through the PEA into Layer1ParallaxRatioY, whose RTL ends the frame.

Layer1ParallaxRatio {
    COP [SetEntryHere]    ; Per-frame entry
    PEA $&Layer1ParallaxRatioY-1 ; Return address for the X half: it continues in Layer1ParallaxRatioY (the Y half)
    LDA $14               ; $14 = X parameter set by the spawner: ratio (high byte nonzero) or signed drift (low byte)
    BIT #$8000            ; Bit 15: forced additive mode
    BNE loc_00E9A7
    BIT #$FF00            ; High byte zero: additive mode as well
    BEQ loc_00E9BA
    LDY $cameraTargetX
    JSL $@hardware_math.MulDivide ; forcedScrollOverride := cameraTargetX x lo / hi ($0201 = x 1 / 2)
    STA $forcedScrollOverride
    RTS 

; Bit 15 set: additive mode; sign-extend the low byte of $14.

  loc_00E9A7:
    AND #$00FF
    BIT #$0080
    BEQ loc_00E9B2
    ORA #$FF00

; forcedScrollOverride += the signed low byte; the RTS continues in Layer1ParallaxRatioY.

  loc_00E9B2:
    CLC 
    ADC $forcedScrollOverride ; Additive: forcedScrollOverride += the signed low byte
    STA $forcedScrollOverride
    RTS 

; High byte zero: additive mode; sign-extend the low byte.

  loc_00E9BA:
    BIT #$0080
    BEQ loc_00E9C2
    ORA #$FF00

; forcedScrollOverride += the signed low byte (zero-high-byte case); the RTS continues in Layer1ParallaxRatioY.

  loc_00E9C2:
    CLC 
    ADC $forcedScrollOverride ; Same add for the zero-high-byte case
    STA $forcedScrollOverride
    RTS 
}

---------------------------------------------
; Y half of Layer1ParallaxRatio: $16 with a nonzero high byte is a ratio, cameraDeltaY := cameraTargetY x lo / hi; otherwise cameraDeltaY += the signed low byte (there is no bit-15 test for Y). Ends with RTL, the frame's return to the actor dispatcher.

Layer1ParallaxRatioY {
    LDA $16
    BIT #$FF00            ; $16 high byte nonzero = ratio mode (Y has no bit-15 test)
    BEQ loc_00E9DC
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide ; cameraDeltaY := cameraTargetY x lo / hi
    STA $cameraDeltaY
    RTL 

; High byte zero: sign-extend the low byte of $16.

  loc_00E9DC:
    BIT #$0080
    BEQ loc_00E9E4
    ORA #$FF00

; cameraDeltaY += the signed low byte.

  loc_00E9E4:
    CLC 
    ADC $cameraDeltaY     ; Additive: cameraDeltaY += the signed low byte
    STA $cameraDeltaY
    RTL 
}
---------------------------------------------

; Layer-1 drift with bounds: the same velocity decode as Layer1DriftUnbounded, but the position wraps at the layer size. Per frame: $14 += $2C + effectDeltaX and cameraDeltaX := $14; below 0 it wraps to effectBoundsX, at or above effectBoundsX it wraps to 0 (effectScrollH is set to the same value, so no render delta results). Y: the same with $16, effectDeltaY and cameraDeltaY, except that a negative position wraps to effectBoundsY - 1 (X uses effectBoundsX itself, no -1).
; effectRenderDeltaX / Y := cameraDeltaX / Y - effectScrollH / V. Spawned from scene_actors entries $09 and $32 with < $01, $82 >: X +1, Y -1 px per frame.

Layer1DriftWrapped [
  actor-def < #00, #00, #2C, {

; Init: $12 |= $1000, decode the spawn bytes into $2C / $2E, zero $14 / $16, then SetEntryHere: the integration below runs every frame and ends with RTL.

  code_00E9EF:
    LDA #$1000
    TSB $12               ; $12 bit $1000: display / overlay-active qualifier
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080            ; Spawn X byte: sign-magnitude decode, as in Layer1DriftUnbounded
    BEQ loc_00EA06
    AND #$FF7F
    EOR #$FFFF
    INC 

; X velocity stored in $2C; decode the Y byte (minus 1).

  loc_00EA06:
    STA $2C               ; $2C := X velocity in px per frame
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC                   ; Spawn Y byte - 1
    BIT #$0080
    BEQ loc_00EA1B
    AND #$FF7F
    EOR #$FFFF
    INC 

; Y velocity stored in $2E; zero the offsets $14 / $16 and set the per-frame entry.

  loc_00EA1B:
    STA $2E               ; $2E := Y velocity in px per frame
    LDA #$0000
    STA $14               ; Zero the offsets $14 / $16
    STA $16
    COP [SetEntryHere]    ; Per-frame entry
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX     ; $14 += X velocity + effectDeltaX
    STA $14
    STA $cameraDeltaX     ; cameraDeltaX := the new layer-1 X
    BPL loc_00EA43
    LDA $effectBoundsX    ; Below 0: wrap to effectBoundsX (the Y side wraps to bounds - 1)
    STA $cameraDeltaX
    STA $effectScrollH
    STA $14
    BRA loc_00EA53

; X position is not negative: wrap to 0 when it reaches effectBoundsX.

  loc_00EA43:
    CMP $effectBoundsX    ; At or above the layer width: wrap to 0
    BCC loc_00EA53
    LDA #$0000
    STA $cameraDeltaX
    STA $14
    STA $effectScrollH

; Y: $16 += $2E + effectDeltaY, cameraDeltaY := $16; below 0 wrap to effectBoundsY - 1.

  loc_00EA53:
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY     ; $16 += Y velocity + effectDeltaY
    STA $16
    STA $cameraDeltaY     ; cameraDeltaY := the new layer-1 Y
    BPL loc_00EA71
    LDA $effectBoundsY    ; Below 0: wrap to effectBoundsY - 1
    DEC 
    STA $cameraDeltaY
    STA $effectScrollV
    STA $16
    BRA loc_00EA81

; Y position is not negative: wrap to 0 when it reaches effectBoundsY.

  loc_00EA71:
    CMP $effectBoundsY    ; At or above the layer height: wrap to 0
    BCC loc_00EA81
    LDA #$0000
    STA $cameraDeltaY
    STA $16
    STA $effectScrollV

; Render deltas: layer-1 position minus the BG2 scroll value, for both axes.

  loc_00EA81:
    LDA $cameraDeltaX     ; Render deltas = layer-1 position - the BG2 scroll value (effectScrollH / V)
    SEC 
    SBC $effectScrollH
    STA $effectRenderDeltaX
    LDA $cameraDeltaY
    SEC 
    SBC $effectScrollV
    STA $effectRenderDeltaY
    RTL 
} >
]