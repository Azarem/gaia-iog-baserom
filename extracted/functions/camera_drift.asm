; Camera drift library (Bank 00, 53134-53350): three short-lived actor scripts that nudge the camera during set pieces. Scene scripts spawn them with SpawnAfterFlags / SpawnListAppend; each dies when finished.
; 
; === CALLERS ===
; 
; CameraDriftLoopSimple: pyCD_flame_statue, ir25_ceiling_tile, ir29_castoth. CameraDriftLoopShip: st68_kara (Angel Village undersea tunnel), gs2D_lily, gs2D_lance, gs2B_erik (Gold Ship). CameraDriftPatterned: awB1_gorgon, pyD9_dangerslide_controller, ir29_castoth (3 sites).
; 
; === VARIABLES ===
; 
; cameraTargetX / Y ($06BE / $06C2) are the layer-0 scroll targets (camera_scroll_controller recomputes them each frame). cameraDeltaX / Y ($06C0 / $06C4) are the layer-1 (second background layer) scroll POSITION, not per-frame deltas: the layer1_scroll_actors actors and camera_scroll write them, and CameraSmoothScroll copies them to effectScrollH / V ($068C / $0690, the BG2 scroll) when layerPriorityFlag bit $0400 is set. While that mode is active the drift therefore moves both layers together. These are not the effectDeltaX / Y ($06E4 / $06E6) that camera_scroll_controller writes. Whether the offsets added here survive the recompute is not established statically (OQ-I050-2).
; 
; === CameraDriftLoopSimple ===
; 
; LoopStart #$78 runs 120 passes, one frame each (every LoopEnd pass yields). Each pass adds r = (RngByte and 3) - 1, that is -1, 0, +1 or +2 (bias +0.5), to cameraTargetY and to cameraDeltaY. Nothing is undone at the end. The same formula is the Y shake in player_character. Then Die. The old note said 'random +-1'.
; 
; === CameraDriftLoopShip ===
; 
; Sets $12 bit $1000 (the display / overlay-active qualifier, so the drift also runs in the display-filtered modes) and $26 := 0 ($26 = the offset applied last frame). 120 passes: while playerFlags bit $0100 (forced walk) is set a pass does nothing; otherwise cameraDeltaY -= $26 (undo last frame), $26 := RngByte and 3 (0 to 3), then cameraTargetY += $26 and cameraDeltaY += $26. After the loop it yields once (SetEntryHereAndYield), subtracts the last $26 from cameraDeltaY and dies. So the delta offset is temporary (each frame replaces the previous one) while the target offset is not undone here.
; 
; === CameraDriftPatterned ===
; 
; $28 := RngByte (random starting phase), $2A := 2, SetEntryHere. Each run: DBR := program bank (to read camera_drift_offsets), Y offset := table[$28 and 7] then $28++, added to cameraTargetY (a negative result is clamped to 0) and, unless $24 = $FFFF, to cameraDeltaY (clamped to 0); then the X offset := table[$28 and 7], i.e. the next entry, with the same rules. A run is followed by $08 := 3 (3 frames) and DEC $2A; the third run ends in Die, so the actor lives about 9 frames and applies 3 Y and 3 X offsets. The next run's Y entry is the previous run's X entry.
; camera_drift_offsets holds 16 words but the index is masked to 3 bits, so only the first 8 are used: +1, -1, -2, +1, +2, 0, -2, +1 (sum 0). The last 8 words (+5, -4, -2, +4, +1, -5, +4, -3, also summing to 0) are never read.
---------------------------------------------

!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerFlags                    09AE

---------------------------------------------

; Jitter for 120 frames: each frame adds -1 to +2 pixels (bias +0.5) to cameraTargetY and cameraDeltaY, then Die. See the block note.

CameraDriftLoopSimple {
    COP [LoopStart] ( #78 ) ; 120 passes, one frame each (every LoopEnd pass yields)
    COP [RngByte]
    AND #$0003            ; r = (0 to 3) - 1 = -1 to +2, the same jitter as the Y shake in player_character
    SEC 
    SBC #$0001
    PHA 
    CLC 
    ADC $cameraTargetY    ; The offset goes to the target here and to cameraDeltaY below; nothing is undone
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    COP [LoopEnd]
    COP [Die]

; Jitter for 120 frames that skips forced-walk frames and replaces the delta offset each frame (0 to 3 pixels on the target and the delta), then undoes the last delta offset and dies.

  CameraDriftLoopShip:
    LDA #$1000            ; Set $12 bit $1000 (display / overlay-active qualifier) so the drift also runs in the display-filtered modes
    TSB $12
    STZ $26               ; $26 = the offset applied last frame (none yet)
    COP [LoopStart] ( #78 )
    LDA $playerFlags
    BIT #$0100            ; playerFlags bit $0100 = forced walk: skip this pass, the last offset stays in place
    BNE CameraDriftShipPassEnd
    LDA $cameraDeltaY
    SEC 
    SBC $26               ; Undo last frame's offset in the delta before applying a new one
    STA $cameraDeltaY
    COP [RngByte]
    AND #$0003            ; New offset 0 to 3, kept in $26 for the next frame
    STA $26
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY

; End of a loop pass (also the skip target while the forced walk is active).

  CameraDriftShipPassEnd:
    COP [LoopEnd]
    COP [SetEntryHereAndYield] ; Yield once; the next run removes the last delta offset and dies
    LDA $cameraDeltaY
    SEC 
    SBC $26
    STA $cameraDeltaY
    COP [Die]

; Short structured sway: 3 runs, 3 frames apart, adding consecutive entries of camera_drift_offsets to the target and delta, Y first and then X from the next entry.

  CameraDriftPatterned:
    COP [RngByte]         ; Random starting phase for the table walk
    STA $28
    LDA #$0002
    STA $2A               ; $2A := 2: three runs in total
    COP [SetEntryHere]
    PHB                   ; DBR := program bank so camera_drift_offsets can be read with a 16-bit address
    PHK 
    PLB 
    LDA $28
    INC $28
    AND #$0007            ; Masked to 8 entries (the table's last 8 words are never used)
    ASL 
    TAY 
    LDA $&camera_drift_offsets, Y ; Offset word for the Y axis
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    BPL loc_00D016        ; Clamp the target at 0
    STZ $cameraTargetY

; Y delta step: skipped when $24 = $FFFF, otherwise adds the same offset to cameraDeltaY (clamped to 0).

  loc_00D016:
    LDA $24               ; $24 = $FFFF skips the delta update (OQ-I050-4)
    CMP #$FFFF
    BEQ loc_00D02C
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    BPL loc_00D02D
    STZ $cameraDeltaY
    BRA loc_00D02D

; $24 = $FFFF: drop the Y offset without touching the delta.

  loc_00D02C:
    PLA 

; X axis: the next table entry (the incremented $28 and 7) is added to cameraTargetX with the same clamp.

  loc_00D02D:
    LDA $28               ; X axis uses the next table entry ($28 was incremented above)
    AND #$0007
    ASL 
    TAY 
    LDA $&camera_drift_offsets, Y
    PHA 
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    BPL loc_00D044
    STZ $cameraTargetX

; X delta step: same $24 test and clamp for cameraDeltaX.

  loc_00D044:
    LDA $24
    CMP #$FFFF
    BEQ loc_00D05A
    PLA 
    CLC 
    ADC $cameraDeltaX
    STA $cameraDeltaX
    BPL loc_00D05B
    STZ $cameraDeltaX
    BRA loc_00D05B

; $24 = $FFFF: drop the X offset without touching the delta.

  loc_00D05A:
    PLA 

; End of a run: restore DBR, wait 3 frames ($08), count down $2A and return, or die on the third run.

  loc_00D05B:
    PLB 
    LDA #$0003
    STA $08               ; Wait 3 frames before the next run
    DEC $2A               ; $2A counts 2, 1, 0 and then goes negative: the third run dies
    BMI loc_00D066
    RTL 

; Third run done: Die.

  loc_00D066:
    COP [Die]
}

---------------------------------------------
; Offset table, 16 signed words. The scripts mask the index to 3 bits, so only the first 8 are used (+1, -1, -2, +1, +2, 0, -2, +1, sum 0); the last 8 are unreferenced.

camera_drift_offsets #0100FFFFFEFF010002000000FEFF01000500FCFFFEFF04000100FBFF0400FDFF