---------------------------------------------

h_ir1E_actor_09C563 [
  actor-def < #19, #02, #30, {

  code_058180:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #31, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]