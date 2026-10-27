---------------------------------------------

h_ir1E_actor_09C563 [
  actor-def < #19, #02, #30, {

  code_058180:
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [WaitOnFlagByte] ( #31, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
} >
]