; Spin Dash gate on the Great Wall rampway (scene $85).
; 
; The actor loops on SetEntryHere and tests BranchIfPlayerAt ( #$0458, #$00D0 ). When that test matches, code_07E90F decides from the player's state: characterForm nonzero (Freedan or Shadow) passes, Will passes when abilityBitmask bit 2 ($0004, Spin Dash) is set, and Will without Spin Dash gets $03C0 written to the player actor's field $14 (the X position word), 152 below the X operand $0458 of the test. The code does not test an attack or a hit on the gate.
---------------------------------------------

!playerActor                    09AA
!abilityBitmask                 0AA2
!characterForm                  0AD4

---------------------------------------------

gw85_spin_dash_gate [
  actor-def < #00, #00, #30, {

  code_07E904:
    COP [SetEntryHere]
    COP [BranchIfPlayerAt] ( #$0458, #$00D0, &code_07E90F )
    RTL 
} >
]

code_07E90F {
    LDA $characterForm
    BNE loc_07E91C
    LDA $abilityBitmask
    BIT #$0004
    BEQ loc_07E91D

  loc_07E91C:
    RTL 

  loc_07E91D:
    LDY $playerActor
    LDA #$03C0
    STA $0014, Y
    RTL 
}