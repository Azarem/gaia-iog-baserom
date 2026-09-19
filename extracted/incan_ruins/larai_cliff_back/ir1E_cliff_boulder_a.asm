---------------------------------------------

ir1E_cliff_boulder_a [
  actor-def < #19, #02, #30, {

  code_09C550:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #30, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]