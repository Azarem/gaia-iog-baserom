; Floor switch on the garden southwest underside — makes a sound on step.
; 
; Interactable tile. When stepped on: "When you step on this
; tile it makes a sound..." Used as part of a puzzle sequence
; to open a passage on the underside area.
---------------------------------------------

---------------------------------------------

sg52_switch [
  actor-def < #00, #00, #20, {

  code_05F6D3:
    COP [BranchIfFlagWord] ( #$012E, #01, &code_05F6F8 )

  loc_05F6DA:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05F70E )
    COP [BranchIfActorAt] ( #03, #$0258, #$0330, &code_05F6EB )
    RTL 
} >
]

code_05F6EB {
    COP [StageBgChange] ( #2E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$012D )
    COP [SetFlagWord] ( #$012E )
}

code_05F6F8 {
    LDY #$1090
    LDA #$0258
    STA $0014, Y
    LDA #$0330
    STA $0016, Y
    COP [ClearLowAbs] ( #38, #32 )
    COP [SetEntryContinue]
    RTL 
}

code_05F70E {
    COP [PrintDialogString] ( &dialogstring_05F71C )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05F71B )
    BRA loc_05F6DA
}

code_05F71B {
    RTL 
}

dialogstring_05F71C `[DEF]When you step on this[N]tile it makes a sound...[END]`