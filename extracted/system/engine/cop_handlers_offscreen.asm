?BANK 00

!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC

---------------------------------------------

; COP #68 (script name BranchIfOffscreen) camera-bounds branch taking one &Code operand. Compares the actor pixel position ($14/$16) against cameraOffsetX/Y and cameraBoundsX/Y; if the actor is on screen, the branch operand is skipped and execution continues. If the actor is outside the visible window, the script jumps to the branch target. Used by off-screen despawn and activation logic.

BranchIfOffCamera {
    TYX 
    LDA $14               ; Compare actor X against cameraOffsetX/cameraBoundsX window
    BMI loc_009DE1
    CMP $cameraOffsetX    ; Below cameraOffsetX → off-camera left
    BCC loc_009DE1
    CMP $cameraBoundsX    ; Above cameraBoundsX → off-camera right
    BCS loc_009DE1
    LDA $16               ; Compare actor Y position against vertical camera window
    BMI loc_009DE1
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
; COP #69 with one word operand (max frame count). Compares against global frame counter $00E4; yields RTL when the counter has reached or exceeded the limit, otherwise RTI and continues.

HaltIfMaxFrames {
    TYX 
    LDA [$0A]             ; Read max frame count threshold (word)
    INC $0A
    INC $0A
    CMP $00E4             ; Compare threshold against global frame counter $00E4
    BCC loc_009E01        ; Counter ≥ threshold → yield has expired, resume script
    LDA $0A               ; Counter < threshold: rewind script and yield RTL
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 

  loc_009E01:
    LDA $0A
    STA $02, S
    RTI 
}