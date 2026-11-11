; Statue prop on the Larai Cliff back side, variant B (mantel tiles $26-$27, $15-$16; scene row at tile (26,17)).
; 
; Same script as variant A with flag $31 (Incan Statue B placed on the mantel by UseItem_IncaStatueB): it spawns hidden, waits with WaitOnFlagByte(#31, #01), then shows the statue sprite and idles. Sprite priority #30.
---------------------------------------------

---------------------------------------------

ir1E_cliff_mantel_b [
  actor-def < #19, #02, #30, {

  code_09C566:
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [WaitOnFlagByte] ( #31, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
} >
]