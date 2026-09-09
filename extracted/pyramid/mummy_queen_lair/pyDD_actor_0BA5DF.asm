!playerYPos                     09A4
!playerActor                    09AA

---------------------------------------------

pyDD_actor_0BA5DF [
  actor-def < #00, #00, #20, {

  loc_0BA5E2:
    LDY $playerActor
    LDA $0010, Y
    AND #$FFFE
    STA $0010, Y
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #08, #0C, #0D, #0E, &code_0BA601 )
    COP [BranchIfPlayerInAbsTiles] ( #14, #0C, #19, #0E, &code_0BA601 )
    RTL 
} >
]

code_0BA601 {
    LDY $playerActor
    LDA $0010, Y
    ORA #$0001
    STA $0010, Y
    COP [SetEntryContinue]
    LDA $playerYPos
    CMP #$01B0
    BEQ loc_0BA618
    RTL 

  loc_0BA618:
    BRA loc_0BA5E2
}