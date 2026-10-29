; Per-frame actor: cameraDeltaX = cameraTargetX, and bit 9 ($0200) of the frame counter $0036 (incremented once per frame in the NMI) selects INC (bit set) or DEC (bit clear) of cameraDeltaY.
; 
; Bit 9 flips every 512 frames, so cameraDeltaY ramps up 512 steps and back down 512 steps (about 8.5 s per half at 60 Hz): a slow vertical drift.
; cameraDeltaX / Y are not the camera itself: camera_tilemap copies them into effectScrollH / V in layer-1 delta mode ($06EF bit 2), and camera_scroll actors compute them as parallax ratios of cameraTargetX / Y.
; No extracted script references this actor by label (no spawn or entry reference found), so it is either unused or spawned from data.
---------------------------------------------

!frameCounter                   0036
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraDeltaY                   06C4

---------------------------------------------

camera_delta_oscillator [
  actor-def < #00, #00, #20, {

  CameraDeltaOscillate:
    COP [SetEntryHere]
    LDA $cameraTargetX    ; Sync horizontal delta to camera target
    STA $cameraDeltaX
    LDA $frameCounter     ; Frame counter $0036 (2 bytes, INC per frame in the NMI)
    AND #$0200            ; Bit 9: toggles every 512 frames
    BEQ loc_08B58E
    INC $cameraDeltaY     ; Bit set: cameraDeltaY += 1 per frame
    RTL 

  loc_08B58E:
    DEC $cameraDeltaY     ; Bit clear: cameraDeltaY -= 1 per frame
    RTL 
} >
]