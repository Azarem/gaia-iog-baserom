; Pressure switch on the garden west underside — opens gate while held.
; 
; Invisible trigger that detects player standing on it. While
; active, opens or maintains an associated gate. Returns when
; the player steps off. Used in the underside passage puzzles.
---------------------------------------------

---------------------------------------------

sg54_pressure_switch [
  actor-def < #00, #00, #20, {

  code_05F74C:
    COP [BranchOnFlagWord] ( #$012F, #01, &code_05F768 )
    COP [SetEntryHere]
    COP [BranchIfActorAt] ( #03, #$0348, #$02E0, &code_05F75F )
    RTL 
} >
]

code_05F75F {
    COP [StageBgChange] ( #2F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$012F )
}

code_05F768 {
    COP [Die]

  loc_05F76A:
    RTL 
}