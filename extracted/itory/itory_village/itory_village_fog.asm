; Position-dependent fog overlay for Itory Village's west side.
; 
; Waits with WaitOnFlagByte(#2B, #01) until flag $2B (Lilly's arrival cutscene is done) is set; before that it does nothing, so the fog is off during the cutscene. After that it runs every frame via SetEntryHere: it reads the player actor's X coordinate and compares it against threshold #$01B0 (432 pixels). West of the threshold it writes #$50 to CGADSUB ($2131) for halftone subscreen color addition fog; east of it, it clears CGADSUB to #$00.
---------------------------------------------

!playerActor                    09AA
!CGADSUB                        2131

---------------------------------------------

itory_village_fog [
  thinker-def < #00, #08, {

  code_00B81A:
    COP [WaitOnFlagByte] ( #2B, #01 )
    COP [SetEntryHere]
    LDY $playerActor
    LDA $0014, Y
    CMP #$01B0
    BCC loc_00B835
    SEP #$20
    LDA #$00
    STA $CGADSUB
    REP #$20
    RTL 

  loc_00B835:
    SEP #$20
    LDA #$50
    STA $CGADSUB
    REP #$20
    RTL 
} >
]