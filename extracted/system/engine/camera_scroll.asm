; Camera scroll actor definitions and shared subroutines (Bank 00).
; 
; Defines four actor-based camera scroll behaviors used during gameplay and cutscenes. Each scroll actor sets bit 12 ($1000) in the actor status word as a camera-active flag, then computes per-frame scroll deltas using the hardware multiply/divide unit (MulDivide).
; 
; The four scroll modes are:
; - ScrollCameraInit: Initialization mode — aligns camera to tile grid with centering offsets, runs a 3-iteration ramp-up loop computing deltas, saves the initial Y delta, then sets a forced X scroll override (bit 15 set) and clears the normal X delta.
; - ScrollCameraTrack: Continuous tracking — aligns position to tile grid each frame, then recomputes both X and Y scroll deltas via MulDivide.
; - ScrollCameraVertical: Vertical-only tracking — aligns position but only computes the Y axis delta, leaving horizontal scrolling unchanged.
; - ScrollCameraAccumulate: Additive accumulation mode — computes deltas and adds running accumulated offsets from DP $24/$26 to both axes.
; 
; Shared subroutines:
; - TileAlignCoord: Converts a pixel coordinate to a tile-grid-aligned value by shifting right 4 bits and masking to $0F0F.
; - TileAlignPosition: Applies TileAlignCoord to both X ($14, with −8px centering offset) and Y ($16) parameters.
; - ComputeScrollDeltas: Uses JSL to hardware_math.MulDivide to compute scroll velocity for each axis from the camera target positions and speed parameters.
---------------------------------------------

?BANK 00

?INCLUDE 'hardware_math'

!savedCameraDelta               0690
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!forcedScrollOverride           06C8

---------------------------------------------

; Camera initialization scroll actor.
; 
; Sets bit 12 ($1000) in actor status as a camera-active flag. Subtracts centering offsets (−8px X, −16px Y) from position parameters and aligns both axes to the 16×16 tile grid via TileAlignCoord.
; 
; Runs a 3-iteration ramp-up loop (COP LoopInit with count 3) that computes scroll deltas each iteration via ComputeScrollDeltas. After the loop, saves the final Y delta to savedCameraDelta ($0690).
; 
; Then sets the actor entry point (COP SetEntryContinue) for per-frame execution, computes deltas one more time, and forces the X scroll by writing cameraDeltaX with bit 15 set to forcedScrollOverride ($06C8). The normal cameraDeltaX is zeroed since the forced override takes precedence.
; 
; Used during scene transitions where the camera needs to snap to a position, ramp up smoothly, then maintain a forced horizontal scroll.

ScrollCameraInit [
  actor-def < #00, #00, #2C, {

  code_00E950:
    LDA #$1000
    TSB $12               ; Set bit 12 in actor status — marks this actor as the active camera controller
    LDA $14
    SEC 
    SBC #$0008            ; Subtract 8px to center camera X on player sprite midpoint
    JSR $&TileAlignCoord
    STA $14
    LDA $16
    SEC 
    SBC #$0010            ; Subtract 16px to center camera Y above player sprite top
    JSR $&TileAlignCoord
    STA $16
    COP [LoopInit] ( #03 ) ; Initialize 3-iteration scroll ramp-up loop via COP LoopInit
    JSR $&ComputeScrollDeltas
    LDA $cameraDeltaY     ; Save initial Y scroll delta to savedCameraDelta before entering per-frame loop
    STA $savedCameraDelta
    COP [LoopNext]
    COP [SetEntryContinue] ; Set actor re-entry point; yields then continues computing deltas each frame
    JSR $&ComputeScrollDeltas
    LDA $cameraDeltaX
    ORA #$8000            ; Bit 15 marks this value as a forced scroll override
    STA $forcedScrollOverride ; Store to forcedScrollOverride ($06C8); engine applies this directly instead of normal delta
    STZ $cameraDeltaX     ; Clear normal cameraDeltaX since forced override takes precedence
    RTL 
} >
]
---------------------------------------------

; Simple continuous camera tracking actor.
; 
; Sets the camera-active flag, aligns position parameters to the tile grid via TileAlignPosition, then enters a per-frame loop (COP SetEntryContinue). Each frame, both X and Y scroll deltas are recomputed by ComputeScrollDeltas using the current camera targets and speed parameters.
; 
; The simplest scroll mode — used when the camera should smoothly follow the player with no special behavior.

ScrollCameraTrack [
  actor-def < #00, #00, #2C, {

  code_00EA99:
    LDA #$1000
    TSB $12               ; Set camera-active flag (bit 12) in actor status word
    JSR $&TileAlignPosition
    COP [SetEntryContinue] ; Set re-entry point; actor recomputes both scroll deltas every frame from here
    JSR $&ComputeScrollDeltas
    RTL 
} >
]

---------------------------------------------
; Vertical-only camera tracking actor-def referenced from scene_actors in Edward's Castle, Itory, Incan Ruins, and Dao.
; 
; Sets camera-active flag $1000, tile-aligns position via TileAlignPosition, then loops with SetEntryContinue computing only the Y scroll delta through MulDivide when speed parameter $16 is nonzero. Leaves cameraDeltaX unchanged from any prior scroll actor. X speed parameter $14 is ignored entirely.

ScrollCameraVertical [
  actor-def < #00, #00, #2C, {

  code_00EAAA:
    LDA #$1000
    TSB $12
    JSR $&TileAlignPosition
    COP [SetEntryContinue]
    LDA $16               ; Check Y scroll speed parameter at DP $16; zero means no vertical scrolling needed
    BEQ loc_00EAC2
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide ; Compute vertical scroll delta = cameraTargetY × speed / scale via MulDivide
    STA $cameraDeltaY

  loc_00EAC2:
    RTL 
} >
]

---------------------------------------------
; Accumulative camera scroll actor-def used in Pyramid interior scenes.
; 
; Initializes X/Y accumulator registers at DP $24 and $26 to zero, tile-aligns position, then each frame calls ComputeScrollDeltas and adds the accumulators to cameraDeltaX and cameraDeltaY. External actors can pre-load $24/$26 to inject extra drift on top of standard tracking.

ScrollCameraAccumulate [
  actor-def < #00, #00, #24, {

  code_00EAC6:
    LDA #$1000
    TSB $12
    LDA #$0000            ; Zero both X and Y scroll accumulator registers at DP $24 and $26
    STA $24
    STA $26
    JSR $&TileAlignPosition
    COP [SetEntryContinue]
    JSR $&ComputeScrollDeltas
    LDA $cameraDeltaX     ; Add running accumulated X offset ($24) to computed horizontal scroll delta
    CLC 
    ADC $24
    STA $cameraDeltaX
    LDA $cameraDeltaY     ; Add running accumulated Y offset ($26) to computed vertical scroll delta
    CLC 
    ADC $26
    STA $cameraDeltaY
    RTL 
} >
]
---------------------------------------------

; Converts a pixel coordinate to a tile-grid-aligned value.
; 
; Switches to 8-bit accumulator, shifts right 4 times (divides by 16 — the metatile width), then restores 16-bit mode and masks with $0F0F to isolate valid 4-bit tile indices in both the high and low bytes. The result is transferred to Y for the caller to store.
; 
; The 8-bit shift is key: by operating in 8-bit mode, the LSR operations independently divide the high and low bytes of the 16-bit value, producing two separate 4-bit tile indices packed into a word.

TileAlignCoord {
    SEP #$20              ; 8-bit mode: LSR operates independently on high and low bytes of the coordinate
    LSR                   ; Shift right ×4: divide by 16 to convert pixel position to metatile grid index
    LSR 
    LSR 
    LSR 
    REP #$20
    AND #$0F0F            ; Mask $0F0F isolates 4-bit tile indices from both packed bytes
    TAY 
    RTS 
}

---------------------------------------------
; Applies tile-grid alignment to both camera position parameters.
; 
; Subtracts 8 pixels from the X position ($14) to center the camera horizontally on the player sprite midpoint before aligning. The Y position ($16) is aligned without any centering offset.
; 
; Both axes are processed through TileAlignCoord, and the aligned results (in Y register) are stored back to their respective DP locations.

TileAlignPosition {
    LDA $14
    SEC 
    SBC #$0008            ; Subtract 8px half-tile centering offset before aligning X to tile grid
    JSR $&TileAlignCoord
    STY $14
    LDA $16               ; Y position aligns directly to tile grid with no centering offset
    JSR $&TileAlignCoord
    STY $16
    RTS 
}

---------------------------------------------
; Computes scroll velocity for both axes using the hardware multiply/divide unit.
; 
; For each axis: loads the speed parameter ($14 for X, $16 for Y) and camera target position (cameraTargetX $06BE or cameraTargetY $06C2), then calls hardware_math.MulDivide via JSL. The result is stored to cameraDeltaX ($06C0) or cameraDeltaY ($06C4).
; 
; If a speed parameter is zero, the corresponding MulDivide call and delta store are skipped entirely (the axis remains at its previous value). This allows selective axis computation — e.g., ScrollCameraVertical only sets $16 nonzero.

ComputeScrollDeltas {
    LDA $14               ; Load X scroll speed parameter; zero skips horizontal delta computation entirely
    BEQ loc_00ED19
    LDY $cameraTargetX
    JSL $@hardware_math.MulDivide ; MulDivide: cameraDeltaX = cameraTargetX × speed parameter / scale factor
    STA $cameraDeltaX

  loc_00ED19:
    LDA $16               ; Load Y scroll speed parameter; zero skips vertical delta computation
    BEQ loc_00ED27
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide ; MulDivide: cameraDeltaY = cameraTargetY × speed parameter / scale factor
    STA $cameraDeltaY

  loc_00ED27:
    RTS 
}