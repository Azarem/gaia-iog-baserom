; Per-frame camera tracking actor (Bank 00, 60144-60314), the camera actor of 220+ field scenes. It reads the player's position, derives the scroll position that centres the player (clamped to the scene's window) and publishes the distance from the current scroll to that target as effectDeltaX / effectDeltaY for the layer1_scroll_actors actors (Layer1DriftUnbounded, Layer1DriftWrapped, Layer1ParallaxRatio). It scrolls nothing itself.
; 
; === ENTRY AND FREEZE ===
; 
; actor-def: sprite 0, flags 0, header byte $2C. Every run sets $12 bit $1000 (the display / overlay-active qualifier that lets the actor run in the display-filtered and overlay-only modes; CopyActorState never copies it), calls SetEntryHere and returns at once when layerPriorityFlag bit $0200 is set (camera frozen; the attack setup in player_character sets it).
; 
; === PLAYER POSITION ===
; 
; D := playerActorDp (the player's actor slot), so $14 / $16 are the player's pixel X / Y. playerXPos := X - 8 and playerYPos := Y - $10 (sprite-adjusted reference point), playerXTile / playerYTile := those values >> 4. These four words are refreshed every frame, also while the target is held.
; 
; === TARGET (skipped while playerFlags bit $0100, forced walk, is set) ===
; 
; Per axis, with P = the player actor's pixel position (not the adjusted one): t = P - $80. If t is negative or below cameraOffset, the target is cameraOffset (left / top limit). Otherwise e = t + $100; if e is at or beyond cameraBounds the target is cameraBounds - $100, else it is t. So cameraOffset is the left / top edge of the scene's window and cameraBounds the right / bottom edge. There is no dead zone: the old note called the P - 128 centring a 'dead zone'.
; Both axes use the constants $80 and $100. Horizontally that centres the player in the 256-pixel view; vertically the target puts the player 128 lines below the top of a 224-line screen, 16 lines below the middle (OQ-I049-4). The result goes to cameraTargetX / cameraTargetY.
; 
; === DELTAS ===
; 
; effectDeltaX := cameraTargetX - bg1ScrollH and effectDeltaY := cameraTargetY - mapScrollV ($068E, the vertical scroll that UploadScrollRegisters writes to BG1VOFS; the old comment said BG2). This also runs while the forced walk holds the target, so the deltas keep following whatever forced_walk wrote to the target.
; 
; === DEAD CODE ===
; 
; CameraDeadBoundsX and CameraDeadBoundsY (LDA cameraBoundsX / cameraBoundsY, BRA) are never branched to: the preceding code ends in BRA, and no other file references them.
---------------------------------------------

!bg1ScrollH                     068A
!mapScrollV                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerFlags                    09AE
!playerActorDp                  09F4

---------------------------------------------

; Actor definition: sprite 0, flags 0, header byte $2C. The body is CameraScrollUpdate.

camera_scroll_controller [
  actor-def < #00, #00, #2C, {

; Per-frame body: set the overlay qualifier, SetEntryHere, return when the camera is frozen, then refresh the player position words, compute the target (unless forced walk) and the deltas.

  CameraScrollUpdate:
    LDA #$1000
    TSB $12               ; Set $12 bit $1000 so the camera also runs in the display-filtered and overlay-only actor modes
    COP [SetEntryHere]
    LDA $layerPriorityFlag
    BIT #$0200            ; layerPriorityFlag bit $0200 = camera frozen (set by the attack setup in player_character): return without updating anything
    BEQ loc_00EB00
    RTL 

; Not frozen: switch D to the player actor and refresh playerXPos / playerYPos and the tile coordinates.

  loc_00EB00:
    PHD 
    LDA $playerActorDp
    TCD                   ; D := player actor slot, so $14 / $16 below are the player's pixel X / Y
    LDA $14
    SEC 
    SBC #$0008            ; playerXPos := X - 8 (the Y word below is Y - $10)
    STA $playerXPos
    LSR                   ; ÷16: pixel X → tile X
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $16
    SEC 
    SBC #$0010            ; Subtract 16px sprite offset
    STA $playerYPos
    LSR                   ; ÷16: pixel Y → tile Y
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $playerFlags
    BIT #$0100            ; playerFlags bit $0100 = forced walk: leave cameraTarget to forced_walk and skip to the delta step
    BNE loc_00EB85
    LDA $14               ; Player pixel X
    SEC 
    SBC #$0080            ; t = X - 128: the scroll position that centres the player in the 256-pixel view
    BMI loc_00EB4D        ; Underflow → clamp to left offset
    CMP $cameraOffsetX
    BMI loc_00EB4D        ; Below left limit → clamp
    CLC 
    ADC #$0100            ; e = t + 256 = the view's right edge, compared with cameraBoundsX
    CMP $cameraBoundsX
    BMI loc_00EB52        ; Within bounds → use computed target
    LDA $cameraBoundsX    ; Over right limit → clamp to max
    BRA loc_00EB52

; Dead code (never branched to): loads cameraBoundsX and jumps to the right-edge path.

  CameraDeadBoundsX:
    LDA $cameraBoundsX
    BRA loc_00EB52

; Target X below the left limit (or negative): use cameraOffsetX.

  loc_00EB4D:
    LDA $cameraOffsetX
    BRA loc_00EB56

; Right-edge path: subtracts $100 from the edge value to turn it into the scroll origin (the left edge of the view).

  loc_00EB52:
    SEC                   ; Subtract screen width to get scroll origin
    SBC #$0100

; Stores cameraTargetX and computes cameraTargetY the same way (offset / bounds are the Y words).

  loc_00EB56:
    STA $cameraTargetX
    LDA $16               ; Player pixel Y
    SEC 
    SBC #$0080            ; t = Y - 128: same constant as X although the screen is 224 lines tall (OQ-I049-4)
    BMI loc_00EB79        ; Underflow → clamp to top offset
    CMP $cameraOffsetY
    BMI loc_00EB79        ; Below top limit → clamp
    CLC 
    ADC #$0100            ; e = t + 256 = the view's bottom edge, compared with cameraBoundsY
    CMP $cameraBoundsY
    BMI loc_00EB7E        ; Within bounds → use computed target
    LDA $cameraBoundsY    ; Over bottom limit → clamp to max
    BRA loc_00EB7E

; Dead code (never branched to): loads cameraBoundsY and jumps to the bottom-edge path.

  CameraDeadBoundsY:
    LDA $cameraBoundsY
    BRA loc_00EB7E

; Target Y above the top limit (or negative): use cameraOffsetY.

  loc_00EB79:
    LDA $cameraOffsetY    ; Clamp to top offset
    BRA loc_00EB82

; Bottom-edge path: subtracts $100 from the edge value to turn it into the scroll origin (the top of the view).

  loc_00EB7E:
    SEC                   ; Subtract screen height to get scroll origin
    SBC #$0100

; Stores cameraTargetY.

  loc_00EB82:
    STA $cameraTargetY

; Delta step (also reached directly while the forced walk holds the target): effectDeltaX / effectDeltaY := target - current BG1 scroll (bg1ScrollH, mapScrollV).

  loc_00EB85:
    LDA $cameraTargetX    ; Delta X = target - current BG1 scroll
    SEC 
    SBC $bg1ScrollH
    STA $effectDeltaX
    LDA $cameraTargetY    ; Delta Y = target - mapScrollV (the vertical scroll written to BG1VOFS)
    SEC 
    SBC $mapScrollV
    STA $effectDeltaY
    PLD 
    RTL 
} >
]