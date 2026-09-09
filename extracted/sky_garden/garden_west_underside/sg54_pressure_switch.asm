---------------------------------------------

sg54_pressure_switch [
  actor-def < #00, #00, #20, {

  code_05F74C:
    COP [BranchIfFlagWord] ( #$012F, #01, &code_05F768 )
    COP [SetEntryContinue]
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