; Stair climb trigger in the Angkor Wat outer east area.
; 
; Automated stair-climbing actor that forces the player
; into a scripted ascending movement when entering the
; stairway zone.
---------------------------------------------

?INCLUDE 'stair_climb'

---------------------------------------------

awB2_stair_climb [
  actor-def < #00, #00, #23, {

  code_0898CB:
    COP [ExitIfFlagWord] ( #$016B, #01 )
    LDA #$000A
    STA $0E
    COP [JumpScript] ( @stair_climb.code_00D16D )
} >
]