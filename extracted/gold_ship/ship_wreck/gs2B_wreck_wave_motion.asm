; Wave motion parallax controller for the wrecked ship scenes.
; 
; Active in scenes $2D-$2F (wrecked ship deck rooms). Adjusts
; cameraDeltaY by subtracting $20 to create the visual effect
; of the ship bobbing on waves. Uses chatPtr, orbitAngle, and
; orbitDiameter for sinusoidal wave timing.
---------------------------------------------

!sceneCurrent                   0644
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

gs2B_wreck_wave_motion [
  actor-def < #00, #00, #2B, {

  code_05802A:
    LDA $sceneCurrent
    CMP #$002D
    BCC loc_058041
    CMP #$002F
    BCS loc_058041
    LDA $cameraDeltaY
    SEC 
    SBC #$0020
    STA $cameraDeltaY

  loc_058041:
    LDA #$0000
    STA $chatPtr, X

  loc_058048:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@unk18_0580B0, X
    STA $0000
    LDA $@unk18_0580B0+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_05806A
    XBA 
    DEC 
    XBA 

  loc_05806A:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_058041
    STA $orbitDiameter, X
    COP [SetEntryHere]
    LDA $orbitDiameter, X
    BEQ loc_0580A4
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    LDA $sceneCurrent
    CMP #$002F
    BEQ loc_05809D
    RTL 

  loc_05809D:
    LDA $cameraDeltaY
    STA $cameraTargetY
    RTL 

  loc_0580A4:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_058048
} >
]
---------------------------------------------

unk18_0580B0 [
  camera-keyframe < #01, #01 >   ;00
  camera-keyframe < #00, #03 >   ;01
  camera-keyframe < #01, #01 >   ;02
  camera-keyframe < #00, #03 >   ;03
  camera-keyframe < #01, #01 >   ;04
  camera-keyframe < #00, #02 >   ;05
  camera-keyframe < #01, #01 >   ;06
  camera-keyframe < #00, #02 >   ;07
  camera-keyframe < #01, #01 >   ;08
  camera-keyframe < #00, #01 >   ;09
  camera-keyframe < #01, #01 >   ;0A
  camera-keyframe < #00, #01 >   ;0B
  camera-keyframe < #01, #01 >   ;0C
  camera-keyframe < #00, #01 >   ;0D
  camera-keyframe < #01, #01 >   ;0E
  camera-keyframe < #00, #01 >   ;0F
  camera-keyframe < #01, #04 >   ;10
  camera-keyframe < #01, #01 >   ;11
  camera-keyframe < #00, #01 >   ;12
  camera-keyframe < #01, #01 >   ;13
  camera-keyframe < #00, #01 >   ;14
  camera-keyframe < #01, #01 >   ;15
  camera-keyframe < #00, #01 >   ;16
  camera-keyframe < #01, #01 >   ;17
  camera-keyframe < #00, #01 >   ;18
  camera-keyframe < #01, #01 >   ;19
  camera-keyframe < #00, #02 >   ;1A
  camera-keyframe < #01, #01 >   ;1B
  camera-keyframe < #00, #02 >   ;1C
  camera-keyframe < #01, #01 >   ;1D
  camera-keyframe < #00, #03 >   ;1E
  camera-keyframe < #01, #01 >   ;1F
  camera-keyframe < #00, #03 >   ;20
  camera-keyframe < #00, #3C >   ;21
  camera-keyframe < #FF, #01 >   ;22
  camera-keyframe < #00, #03 >   ;23
  camera-keyframe < #FF, #01 >   ;24
  camera-keyframe < #00, #03 >   ;25
  camera-keyframe < #FF, #01 >   ;26
  camera-keyframe < #00, #02 >   ;27
  camera-keyframe < #FF, #01 >   ;28
  camera-keyframe < #00, #02 >   ;29
  camera-keyframe < #FF, #01 >   ;2A
  camera-keyframe < #00, #01 >   ;2B
  camera-keyframe < #FF, #01 >   ;2C
  camera-keyframe < #00, #01 >   ;2D
  camera-keyframe < #FF, #01 >   ;2E
  camera-keyframe < #00, #01 >   ;2F
  camera-keyframe < #FF, #01 >   ;30
  camera-keyframe < #00, #01 >   ;31
  camera-keyframe < #FF, #04 >   ;32
  camera-keyframe < #FF, #01 >   ;33
  camera-keyframe < #00, #01 >   ;34
  camera-keyframe < #FF, #01 >   ;35
  camera-keyframe < #00, #01 >   ;36
  camera-keyframe < #FF, #01 >   ;37
  camera-keyframe < #00, #01 >   ;38
  camera-keyframe < #FF, #01 >   ;39
  camera-keyframe < #00, #01 >   ;3A
  camera-keyframe < #FF, #01 >   ;3B
  camera-keyframe < #00, #02 >   ;3C
  camera-keyframe < #FF, #01 >   ;3D
  camera-keyframe < #00, #02 >   ;3E
  camera-keyframe < #FF, #01 >   ;3F
  camera-keyframe < #00, #03 >   ;40
  camera-keyframe < #FF, #01 >   ;41
  camera-keyframe < #00, #03 >   ;42
  camera-keyframe < #00, #3C >   ;43
  camera-keyframe < #00, #00 >   ;44
]
---------------------------------------------

code_05F859 {
    LDA $cameraTargetY
    STA $16

  loc_05F85E:
    LDA #$0000
    STA $chatPtr, X

  code_05F865:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@unk18_0580B0, X
    STA $0000
    LDA $@unk18_0580B0+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_05F887
    XBA 
    DEC 
    XBA 

  loc_05F887:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_05F85E
    STA $orbitDiameter, X
    COP [SetEntryHere]
    LDA $orbitDiameter, X
    BEQ loc_05F8B3
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $16
    STA $16
    STA $cameraTargetY
    RTL 

  loc_05F8B3:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    JMP $&code_05F865
}