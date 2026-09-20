; Per-frame camera tracking actor placed at slot #01 in 220+ field scenes (Bank 00).
; 
; On entry it sets actor flag $1000 and calls SetEntryContinue, then each tick computes BG scroll deltas from the player's pixel position unless layerPriorityFlag bit $0200 freezes the camera. It reads player coordinates through the player actor DP, derives tile indices, and applies a 128-pixel dead zone before clamping targets to scene-defined cameraOffset/cameraBounds limits.
; 
; When playerFlags bit $0100 is clear it writes cameraTargetX/Y, then subtracts current bg1ScrollH/bg2ScrollH to produce effectDeltaX/Y ($06E4/$06E6). Those deltas feed the visual effect pipeline (effect_velocity_init → effect_position_update → effect_subpixel_math) for smooth subpixel scrolling.
---------------------------------------------

!bg1ScrollH                     068A
!bg2ScrollH                     068E
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

camera_scroll_controller [
  actor-def < #00, #00, #2C, {

  CameraScrollUpdate:
    LDA #$1000
    TSB $12
    COP [SetEntryHere]
    LDA $layerPriorityFlag
    BIT #$0200
    BEQ loc_00EB00
    RTL 

  loc_00EB00:
    PHD 
    LDA $playerActorDp
    TCD 
    LDA $14
    SEC 
    SBC #$0008
    STA $playerXPos
    LSR                   ; ÷16: pixel X → tile X
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $16               ; Player actor Y position (pixel)
    SEC 
    SBC #$0010            ; Subtract 16px sprite offset
    STA $playerYPos
    LSR                   ; ÷16: pixel Y → tile Y
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $playerFlags
    BIT #$0100            ; Camera lock flag — skip target calc
    BNE loc_00EB85
    LDA $14               ; Player pixel X
    SEC 
    SBC #$0080            ; Center camera: X - 128px dead zone
    BMI loc_00EB4D        ; Underflow → clamp to left offset
    CMP $cameraOffsetX
    BMI loc_00EB4D        ; Below left limit → clamp
    CLC 
    ADC #$0100            ; Add screen width (256px)
    CMP $cameraBoundsX
    BMI loc_00EB52        ; Within bounds → use computed target
    LDA $cameraBoundsX    ; Over right limit → clamp to max
    BRA loc_00EB52

  loc_00EB48:
    LDA $cameraBoundsX
    BRA loc_00EB52

  loc_00EB4D:
    LDA $cameraOffsetX
    BRA loc_00EB56

  loc_00EB52:
    SEC                   ; Subtract screen width to get scroll origin
    SBC #$0100

  loc_00EB56:
    STA $cameraTargetX
    LDA $16               ; Player pixel Y
    SEC 
    SBC #$0080            ; Center camera: Y - 128px dead zone
    BMI loc_00EB79        ; Underflow → clamp to top offset
    CMP $cameraOffsetY
    BMI loc_00EB79        ; Below top limit → clamp
    CLC 
    ADC #$0100            ; Add screen height (256px)
    CMP $cameraBoundsY
    BMI loc_00EB7E        ; Within bounds → use computed target
    LDA $cameraBoundsY    ; Over bottom limit → clamp to max
    BRA loc_00EB7E

  loc_00EB74:
    LDA $cameraBoundsY
    BRA loc_00EB7E

  loc_00EB79:
    LDA $cameraOffsetY    ; Clamp to top offset
    BRA loc_00EB82

  loc_00EB7E:
    SEC                   ; Subtract screen height to get scroll origin
    SBC #$0100

  loc_00EB82:
    STA $cameraTargetY

; Compute scroll deltas for the visual effect pipeline

  loc_00EB85:
    LDA $cameraTargetX    ; Delta X = target - current BG1 scroll
    SEC 
    SBC $bg1ScrollH
    STA $effectDeltaX
    LDA $cameraTargetY    ; Delta Y = target - current BG2 scroll
    SEC 
    SBC $bg2ScrollH
    STA $effectDeltaY
    PLD 
    RTL 
} >
]