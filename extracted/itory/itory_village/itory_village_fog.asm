; Position-dependent fog overlay for Itory Village's west side.
; 
; Reads the player actor's X coordinate and compares against threshold #$01B0 (432 pixels). West of the threshold: writes #$50 to CGADSUB ($2131) for halftone subscreen color addition fog; east of it: clears CGADSUB to #$00. Exits entirely when flag #2B is set; runs every frame via SetEntryHere otherwise.
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