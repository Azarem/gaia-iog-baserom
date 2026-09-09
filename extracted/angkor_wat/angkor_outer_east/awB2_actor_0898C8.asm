?INCLUDE 'stair_climb'

---------------------------------------------

awB2_actor_0898C8 [
  actor-def < #00, #00, #23, {

  code_0898CB:
    COP [ExitIfFlagWord] ( #$016B, #01 )
    LDA #$000A
    STA $0E
    COP [JumpScript] ( @stair_climb.code_00D16D )
} >
]