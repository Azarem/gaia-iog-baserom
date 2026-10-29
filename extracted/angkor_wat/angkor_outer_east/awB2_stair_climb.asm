; Psycho Slider glide trigger in the Angkor Wat outer east area.
; 
; The actor waits until event flag $016B is set (WaitOnFlagWord, sense 1), stores $000A in $0E (the glide length, in units of 16 px: LockPlayerForClimb) and JumpFar's to slider_glide.SliderGlideTriggerNorthMain. From there it runs as a north Psycho Slider glide trigger (see the slider_glide block note).
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