; Spin Dash gate on the Great Wall rampway.
; 
; Gate that can only be opened by using the Spin Dash ability.
; Checks the player form (Freedan with Spin Dash) and opens
; when the attack connects. Blocks non-Freedan access.
---------------------------------------------

!playerActor                    09AA
!abilityBitmask                 0AA2
!characterForm                  0AD4

---------------------------------------------

gw85_spin_dash_gate [
  actor-def < #00, #00, #30, {

  code_07E904:
    COP [SetEntryContinue]
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