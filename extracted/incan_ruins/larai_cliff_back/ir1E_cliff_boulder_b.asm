; Decorative boulder on the Larai Cliff back side (variant B).
; 
; Identical to variant A but placed at a different position.
; Same flag $30 check and sprite priority #30.
---------------------------------------------

---------------------------------------------

ir1E_cliff_boulder_b [
  actor-def < #19, #02, #30, {

  code_09C566:
    COP [AddPosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [ExitIfFlagByte] ( #31, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
} >
]