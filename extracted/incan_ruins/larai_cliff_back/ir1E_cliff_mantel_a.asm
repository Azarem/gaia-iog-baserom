; Statue prop on the Larai Cliff back side, variant A (mantel tiles $37-$38, $12-$13; scene row at tile (37,14)).
; 
; Spawns hidden (the third actor-def byte #30 sets $2000 in $10), nudges its position by (08,FE), sets sprite priority #30 and waits with WaitOnFlagByte(#30, #01). When flag $30 (Incan Statue A placed on the mantel by UseItem_IncaStatueA) is set it clears $2000 in $10, which shows the statue sprite, and idles. With the flag already set at scene load the wait passes at once.
---------------------------------------------

---------------------------------------------

ir1E_cliff_mantel_a [
  actor-def < #19, #02, #30, {

  code_09C550:
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [WaitOnFlagByte] ( #30, #01 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
} >
]