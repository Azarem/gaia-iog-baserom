---------------------------------------------

h_ir1E_actor_09C54D [
  actor-def < #19, #02, #30, {

  code_05816A:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #30, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]