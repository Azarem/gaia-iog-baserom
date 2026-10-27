; Camera scroll actor definitions and shared subroutines (Bank 00).
; 
; Defines four actor-based camera scroll behaviors used during gameplay and cutscenes. Each actor sets bit 12 ($1000) of its status word ($12; the meaning of that bit was not verified) and then computes per-frame scroll deltas with the hardware multiply/divide unit (MulDivide).
; 
; Spawn parameters: the X/Y bytes of the actor-spawn entry are not positions. The spawner makes them pixel coordinates (tile × 16); TileAlignCoord then packs each into (page << 8 | tile) and ComputeScrollDeltas passes it to MulDivide as the packed operand: low byte = multiplier, high byte = divisor. Zero skips the axis. Spawn bytes seen in extracted/: #11 (most common), #21, #41, #00, #DF (Init only). The −8 px X offset makes the X multiplier one less than the Y one for the same spawn byte (OQ-57).
; 
; The four scroll modes are:
; - ScrollCameraInit: aligns both coordinates, runs the delta computation 3 times (identical inputs), copies the Y delta to effectScrollV, then computes once more and moves cameraDeltaX (bit 15 set) into forcedScrollOverride, zeroing cameraDeltaX. Used only with spawn #DF, #DF.
; - ScrollCameraTrack: aligns once, then recomputes both deltas every frame.
; - ScrollCameraVertical: aligns once, then recomputes only the Y delta every frame (X ignored).
; - ScrollCameraAccumulate: recomputes both deltas every frame and adds the accumulators in DP $24/$26 (zeroed at start, writable by other actors).
; 
; Shared subroutines:
; - TileAlignCoord: packs a pixel coordinate into (page << 8 | tile): LSR ×4 in 8-bit mode shifts only the low byte, the high byte is kept, then AND #$0F0F. Result in Y.
; - TileAlignPosition: applies TileAlignCoord to X ($14, after subtracting 8) and Y ($16).
; - ComputeScrollDeltas: for each axis, MulDivide(A = packed ratio from $14/$16, Y = cameraTargetX/Y) → cameraDeltaX/Y; an axis whose packed value is 0 is skipped and keeps its previous delta.
---------------------------------------------

?BANK 00

?INCLUDE 'hardware_math'

!effectScrollV                  0690
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!forcedScrollOverride           06C8

---------------------------------------------

; Camera initialization scroll actor (spawn #DF, #DF; Mt. Kress scenes).
; 
; Sets bit 12 ($1000) in the actor status word, subtracts 8 px (X) and 16 px (Y) from the position parameters and packs both with TileAlignCoord into the multiplier/divisor words $14/$16.
; 
; Runs COP LoopStart with count 3 around ComputeScrollDeltas; all three passes use the same inputs, so they give the same result. After the loop, copies cameraDeltaY to effectScrollV ($0690).
; 
; Then sets the re-entry point (COP SetEntryHere), computes the deltas again each frame, ORs bit 15 into cameraDeltaX and stores it in forcedScrollOverride ($06C8), and zeroes cameraDeltaX. Outside visual_effect_pipeline no reader of $06C8 was found in extracted/ (OQ-57).

ScrollCameraInit [
  actor-def < #00, #00, #2C, {

  code_00E950:
    LDA #$1000
    TSB $12               ; Set bit 12 in actor status — marks this actor as the active camera controller
    LDA $14
    SEC 
    SBC #$0008            ; Subtract 8px X centering offset
    JSR $&TileAlignCoord
    STA $14
    LDA $16
    SEC 
    SBC #$0010            ; Subtract 16 px (Y offset) before packing
    JSR $&TileAlignCoord
    STA $16
    COP [LoopStart] ( #03 ) ; COP LoopStart(3): repeat the next block 3 times (same inputs each pass)
    JSR $&ComputeScrollDeltas
    LDA $cameraDeltaY     ; Copy the Y delta to effectScrollV ($0690, layer-1 vertical effect scroll)
    STA $effectScrollV
    COP [LoopEnd]
    COP [SetEntryHere]    ; Set the re-entry point: later frames resume here
    JSR $&ComputeScrollDeltas
    LDA $cameraDeltaX
    ORA #$8000            ; Set bit 15 on the X delta
    STA $forcedScrollOverride ; Store in forcedScrollOverride ($06C8); no reader outside visual_effect_pipeline was found (OQ-57)
    STZ $cameraDeltaX     ; Zero cameraDeltaX after moving its value into the override word
    RTL 
} >
]
---------------------------------------------

; Simple continuous camera tracking actor.
; 
; Sets bit 12 of the status word, packs the spawn position via TileAlignPosition, then re-runs ComputeScrollDeltas every frame (after COP SetEntryHere) with the current camera targets.
; 
; The default camera actor: about 100 scene spawns use it (87 of them with #11, #11).

ScrollCameraTrack [
  actor-def < #00, #00, #2C, {

  code_00EA99:
    LDA #$1000
    TSB $12               ; Set camera-active flag (bit 12) in actor status word
    JSR $&TileAlignPosition
    COP [SetEntryHere]    ; Set re-entry point; actor recomputes both scroll deltas every frame from here
    JSR $&ComputeScrollDeltas
    RTL 
} >
]

---------------------------------------------
; Vertical-only camera tracking actor-def referenced from scene_actors in Edward's Castle, Itory, Incan Ruins and Dao.
; 
; Sets bit 12, packs the position via TileAlignPosition, then every frame computes only the Y delta through MulDivide when $16 is nonzero. cameraDeltaX is left unchanged and the X parameter ($14) is ignored. Three of its spawns use #21, #00, whose Y parameter is 0, so they compute nothing (OQ-57).

ScrollCameraVertical [
  actor-def < #00, #00, #2C, {

  code_00EAAA:
    LDA #$1000
    TSB $12
    JSR $&TileAlignPosition
    COP [SetEntryHere]
    LDA $16               ; $16 = packed Y ratio; zero means this actor computes no vertical delta
    BEQ loc_00EAC2
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide ; MulDivide: cameraDeltaY = cameraTargetY × multiplier ÷ divisor
    STA $cameraDeltaY

  loc_00EAC2:
    RTL 
} >
]

---------------------------------------------
; Accumulative camera scroll actor-def used in Pyramid interior scenes.
; 
; Zeroes the accumulators at DP $24 (X) and $26 (Y), packs the position via TileAlignPosition, then each frame calls ComputeScrollDeltas and adds the accumulators to cameraDeltaX and cameraDeltaY. Other actors can write $24/$26 to add drift on top of the standard tracking.

ScrollCameraAccumulate [
  actor-def < #00, #00, #24, {

  code_00EAC6:
    LDA #$1000
    TSB $12
    LDA #$0000            ; Zero both X and Y scroll accumulator registers at DP $24 and $26
    STA $24
    STA $26
    JSR $&TileAlignPosition
    COP [SetEntryHere]
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

; Packs a pixel coordinate into (page << 8 | tile).
; 
; In 8-bit accumulator mode LSR ×4 shifts only the low byte (÷ 16, the tile index within a 256-px page); the hidden high byte (the page) is untouched. After returning to 16-bit mode, AND #$0F0F keeps the low nibble of each byte, and the result is transferred to Y for the caller to store.

TileAlignCoord {
    SEP #$20              ; 8-bit mode: LSR operates independently on high and low bytes of the coordinate
    LSR                   ; LSR ×4 on the low byte only: ÷ 16 = tile index within the 256-px page
    LSR 
    LSR 
    LSR 
    REP #$20              ; Back to 16-bit; the high byte (page) is unchanged
    AND #$0F0F            ; Keep the low nibble of each byte: (page << 8 | tile)
    TAY 
    RTS 
}

---------------------------------------------
; Applies TileAlignCoord to both position parameters.
; 
; Subtracts 8 px from X ($14) before packing; Y ($16) is packed as is. The packed words are stored back to $14/$16, where ComputeScrollDeltas uses them as the multiplier (low byte) and divisor (high byte) for MulDivide.

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
; Computes the scroll delta for both axes with the hardware multiply/divide unit.
; 
; For each axis: A = the packed ratio in $14 (X) or $16 (Y), Y = cameraTargetX ($06BE) or cameraTargetY ($06C2); calls hardware_math.MulDivide via JSL, which returns (A low byte × Y) ÷ A high byte, and stores it in cameraDeltaX ($06C0) or cameraDeltaY ($06C4).
; 
; If the packed value is 0 the MulDivide call and the store are skipped and that axis keeps its previous delta.

ComputeScrollDeltas {
    LDA $14               ; Load X scroll speed parameter; zero skips horizontal delta computation entirely
    BEQ loc_00ED19        ; $14 = packed X ratio; zero skips the X delta
    LDY $cameraTargetX
    JSL $@hardware_math.MulDivide ; MulDivide: cameraDeltaX = cameraTargetX × multiplier ÷ divisor
    STA $cameraDeltaX

  loc_00ED19:
    LDA $16               ; Load Y scroll speed parameter; zero skips vertical delta computation
    BEQ loc_00ED27
    LDY $cameraTargetY
    JSL $@hardware_math.MulDivide ; MulDivide: cameraDeltaY = cameraTargetY × multiplier ÷ divisor
    STA $cameraDeltaY

  loc_00ED27:
    RTS 
}