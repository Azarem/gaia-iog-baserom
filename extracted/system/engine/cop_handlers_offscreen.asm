; Camera-window and timeline-wait COP handlers (40381–40454, Bank 00).
; 
; - BranchIfOffCamera (COP #68): branch when the actor lies outside the camera's scroll window.
; - HaltIfMaxFrames (COP #69): hold the script until the global timeline counter $00E4 exceeds a threshold.
; 
; BranchIfOffCamera returns by storing the next script address in the saved COP frame ($02,S) and executing RTI. HaltIfMaxFrames either does the same or, while waiting, rewinds the actor's entry pointer and yields with RTL.
---------------------------------------------

?BANK 00

!actorLimitThreshold            00E4
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC

---------------------------------------------

; COP #68 with one &Code operand. Compares the actor position ($14 = X, $16 = Y) against the camera window: cameraOffsetX/Y (left/top limit) and cameraBoundsX/Y (right/bottom limit), the active map window's scroll limits per docs/wram-memory-map.md. If both axes are inside the window the operand is skipped and the script continues; otherwise the script jumps to the operand. A negative position counts as outside, the lower limit is inclusive and the upper limit exclusive (position ≥ limit = outside). Used by enemy scripts (e.g. awB0_zip_fly, pyD2_haunt, gw83_asp, gw82_fire_bug, av6D_dive_bat).

BranchIfOffCamera {
    TYX 
    LDA $14               ; Compare actor X against cameraOffsetX/cameraBoundsX window
    BMI loc_009DE1        ; Negative X → outside
    CMP $cameraOffsetX    ; Below cameraOffsetX → off-camera left
    BCC loc_009DE1
    CMP $cameraBoundsX    ; Above cameraBoundsX → off-camera right
    BCS loc_009DE1
    LDA $16               ; Compare actor Y position against vertical camera window
    BMI loc_009DE1        ; Negative Y → outside
    CMP $cameraOffsetY    ; Below cameraOffsetY → off-camera top
    BCC loc_009DE1
    CMP $cameraBoundsY    ; Above cameraBoundsY → off-camera bottom
    BCS loc_009DE1
    LDA $0A               ; All bounds passed: actor is on-camera, skip branch operand
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009DE1:
    LDA [$0A]             ; Off-camera: take branch to target
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #69 with one word operand (frame threshold). Compares it with the global timeline counter $00E4 (mnemonic actorLimitThreshold; the ending-credits actors keep it running, e.g. code_09E919 in sF7_credits increments it each tick, and it is $FFFF while stopped). While the counter is NOT above the threshold (counter ≤ threshold, unsigned) the handler rewinds the actor's entry pointer ($00) to this COP, discards the COP frame and yields with RTL, so the COP runs again next tick. Once the counter is above the threshold the script continues via RTI. Used as a timeline wait in the ending credits.

HaltIfMaxFrames {
    TYX 
    LDA [$0A]             ; Read max frame count threshold (word)
    INC $0A
    INC $0A
    CMP $actorLimitThreshold ; Compare threshold against the global timeline counter $00E4
    BCC loc_009E01        ; Threshold < counter (counter above it) → wait is over, resume script
    LDA $0A               ; Counter ≤ threshold: back up to this COP (opcode + signature + word operand = 4 bytes)
    SEC 
    SBC #$0004
    STA $00               ; Actor entry pointer ($00) = this COP, re-run next tick
    PLA                   ; Discard the COP interrupt frame
    PLA 
    RTL                   ; Yield to the actor loop

  loc_009E01:
    LDA $0A
    STA $02, S
    RTI 
}