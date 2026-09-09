!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!cameraBoundsY                  06DC
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

wa78_actor_0781BE [
  actor-def < #00, #00, #2B, {

  code_0781C1:
    LDA #$1000
    TSB $12
    LDA #$0400
    STA $cameraBoundsY
    COP [ExitIfFlagByte] ( #8D, #01 )
    LDA $cameraTargetY
    STA $16

  loc_0781D5:
    LDA #$0000
    STA $chatPtr, X

  loc_0781DC:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@camera_keyframe_078238, X
    STA $0000
    LDA $@camera_keyframe_078238+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_0781FE
    XBA 
    DEC 
    XBA 

  loc_0781FE:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_0781D5
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_07822C
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    STA $cameraDeltaY
    RTL 

  loc_07822C:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_0781DC
} >
]

camera_keyframe_078238 [
  camera-keyframe < #01, #04 >   ;00
  camera-keyframe < #02, #04 >   ;01
  camera-keyframe < #03, #03 >   ;02
  camera-keyframe < #04, #03 >   ;03
  camera-keyframe < #05, #02 >   ;04
  camera-keyframe < #06, #02 >   ;05
  camera-keyframe < #07, #02 >   ;06
  camera-keyframe < #08, #02 >   ;07
  camera-keyframe < #09, #04 >   ;08
  camera-keyframe < #0A, #02 >   ;09
  camera-keyframe < #0B, #02 >   ;0A
  camera-keyframe < #0C, #02 >   ;0B
  camera-keyframe < #0D, #02 >   ;0C
  camera-keyframe < #0E, #03 >   ;0D
  camera-keyframe < #0F, #03 >   ;0E
  camera-keyframe < #10, #04 >   ;0F
  camera-keyframe < #11, #04 >   ;10
  camera-keyframe < #11, #3C >   ;11
  camera-keyframe < #11, #04 >   ;12
  camera-keyframe < #10, #04 >   ;13
  camera-keyframe < #0F, #03 >   ;14
  camera-keyframe < #0E, #03 >   ;15
  camera-keyframe < #0D, #02 >   ;16
  camera-keyframe < #0C, #02 >   ;17
  camera-keyframe < #0B, #02 >   ;18
  camera-keyframe < #0A, #02 >   ;19
  camera-keyframe < #09, #04 >   ;1A
  camera-keyframe < #08, #02 >   ;1B
  camera-keyframe < #07, #02 >   ;1C
  camera-keyframe < #06, #02 >   ;1D
  camera-keyframe < #05, #02 >   ;1E
  camera-keyframe < #04, #03 >   ;1F
  camera-keyframe < #03, #03 >   ;20
  camera-keyframe < #02, #04 >   ;21
  camera-keyframe < #01, #04 >   ;22
  camera-keyframe < #00, #3C >   ;23
  camera-keyframe < #00, #00 >   ;24
]