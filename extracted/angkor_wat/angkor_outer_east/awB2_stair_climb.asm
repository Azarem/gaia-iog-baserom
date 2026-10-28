; Stair climb trigger in the Angkor Wat outer east area.
; 
; Automated stair-climbing actor that forces the player
; into a scripted ascending movement when entering the
; stairway zone.
---------------------------------------------

?INCLUDE 'slider_glide'

---------------------------------------------

awB2_stair_climb [
  actor-def < #00, #00, #23, {

  code_0898CB:
    COP [WaitOnFlagWord] ( #$016B, #01 )
    LDA #$000A
    STA $0E
    COP [JumpFar] ( @slider_glide.SliderGlideTriggerNorthMain )
} >
]