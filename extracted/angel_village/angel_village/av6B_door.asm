; Door mechanism in Angel Village — opens/closes passage.
; 
; Interactive or auto-triggered door. Manages the open/close
; state with BG change and flag tracking. Used for village
; interior access.
---------------------------------------------

---------------------------------------------

av6B_door [
  actor-def < #00, #00, #30, {

  code_06D748:
    SEP #$20
    LDA #$0F
    STA $7FC568
    STA $7FC56A
    STA $7FCA52
    STA $7FCA54
    REP #$20
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfPlayerNear] ( #01, &code_06D76F )
    COP [SetOnInteract] ( &code_06D780 )
    COP [ExitIfFlagByte] ( #01, #01 )
} >
]

code_06D76F {
    COP [PlaySoundCh2] ( #06 )
    COP [StageBgChange] ( #45 )
    COP [ApplyBgChange]
    LDA #$0000
    STA $0AA6
    COP [SetEntryContinue]
    RTL 
}

code_06D780 {
    COP [SetFlagByte] ( #01 )
    RTL 
}