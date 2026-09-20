; Mummy Queen arena boundary walls — invisible collision.
; 
; Defines the boss arena's playable area by creating
; invisible collision barriers. Prevents the player from
; leaving the fight zone during the battle.
---------------------------------------------

!playerYPos                     09A4
!playerActor                    09AA

---------------------------------------------

pyDD_queen_arena_boundary [
  actor-def < #00, #00, #20, {

  loc_0BA5E2:
    LDY $playerActor
    LDA $0010, Y
    AND #$FFFE
    STA $0010, Y
    COP [SetEntryHere]
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
    COP [SetEntryHere]
    LDA $playerYPos
    CMP #$01B0
    BEQ loc_0BA618
    RTL 

  loc_0BA618:
    BRA loc_0BA5E2
}