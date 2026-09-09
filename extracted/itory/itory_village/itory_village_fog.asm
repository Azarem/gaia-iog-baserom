!playerActor                    09AA
!CGADSUB                        2131

---------------------------------------------

itory_village_fog [
  thinker-def < #00, #08, {

  code_00B81A:
    COP [ExitIfFlagByte] ( #2B, #01 )
    COP [SetEntryContinue]
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