; Decorative boulder on the Larai Cliff back side (variant A).
; 
; Simple sprite prop at priority #30. Checks flag $30 — if set,
; hides display and idles. Otherwise shows boulder sprite.
; Used for visual dressing on the cliff.
---------------------------------------------

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