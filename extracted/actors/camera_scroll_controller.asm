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

  code_00EAF0:
    LDA #$1000
    TSB $12
    COP [SetEntryContinue]
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
    LSR                   ; Wrap below 0 → reset to 15 (16-direction circle)
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $16
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $playerFlags
    BIT #$0100            ; AND $000F: wrap at 16
    BNE loc_00EB85
    LDA $14
    SEC 
    SBC #$0080
    BMI loc_00EB4D
    CMP $cameraOffsetX
    BMI loc_00EB4D
    CLC 
    ADC #$0100            ; $0000 = $FFFF signals direction is resolved (snap case)
    CMP $cameraBoundsX
    BMI loc_00EB52        ; Read parent actor from $0004,X
    LDA $cameraBoundsX
    BRA loc_00EB52

  loc_00EB48:
    LDA $cameraBoundsX
    BRA loc_00EB52

  loc_00EB4D:
    LDA $cameraOffsetX
    BRA loc_00EB56

  loc_00EB52:
    SEC                   ; Zero OAM flip bits in $002A
    SBC #$0100

  loc_00EB56:
    STA $cameraTargetX
    LDA $16
    SEC 
    SBC #$0080
    BMI loc_00EB79
    CMP $cameraOffsetY
    BMI loc_00EB79
    CLC 
    ADC #$0100
    CMP $cameraBoundsY
    BMI loc_00EB7E
    LDA $cameraBoundsY
    BRA loc_00EB7E

  loc_00EB74:
    LDA $cameraBoundsY
    BRA loc_00EB7E

  loc_00EB79:
    LDA $cameraOffsetY    ; ASL ×2 for word table offset into FollowDirectionTable
    BRA loc_00EB82        ; chatPtr sign → carry flag for direction handler

  loc_00EB7E:
    SEC 
    SBC #$0100

  loc_00EB82:
    STA $cameraTargetY    ; Load handler address from FollowDirectionTable[direction]

  loc_00EB85:
    LDA $cameraTargetX
    SEC 
    SBC $bg1ScrollH
    STA $effectDeltaX
    LDA $cameraTargetY
    SEC 
    SBC $bg2ScrollH
    STA $effectDeltaY
    PLD 
    RTL 
} >
]