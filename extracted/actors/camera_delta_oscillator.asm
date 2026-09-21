; Camera oscillation actor — copies cameraTargetX to cameraDeltaX each frame and
; alternates cameraDeltaY ±1 based on bit 9 of the global frame counter ($0036).
; Produces a subtle vertical camera wobble effect. Runs continuously via SetEntryHere.
---------------------------------------------

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
    LDA $0036             ; Global frame counter
    AND #$0200            ; Bit 9: toggles every 512 frames
    BEQ loc_08B58E
    INC $cameraDeltaY     ; Odd half: nudge camera down
    RTL 

  loc_08B58E:
    DEC $cameraDeltaY     ; Even half: nudge camera up
    RTL 
} >
]