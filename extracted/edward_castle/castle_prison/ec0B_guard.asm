; Prison guard NPC who refuses help.
; 
; Single dialog where the guard says he does not need anyone's help.
---------------------------------------------

!playerActor                    09AA

---------------------------------------------

ec0B_guard [
  actor-def < #1B, #00, #10, {

  code_04DC1C:
    COP [BranchIfFlagByte] ( #42, #00, &code_04DC26 )
    COP [ClearHighAbs] ( #09, #17 )
} >
]

code_04DC26 {
    COP [BranchIfFlagByte] ( #43, #00, &code_04DC30 )
    COP [ClearHighAbs] ( #14, #17 )
}

code_04DC30 {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DC59 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0D, #12, #11, #14, &code_04DC4F )
    LDY $playerActor
    LDA #$2000
    STA $000E, Y
    RTL 
}

code_04DC4F {
    LDY $playerActor
    LDA #$3000
    STA $000E, Y
    RTL 
}

code_04DC59 {
    COP [PrintDialogString] ( &dialogstring_04DC5E )
    RTL 
}

dialogstring_04DC5E `[TPL:E]I don't need anyone's[N]help... I can[N]get out by myself...[END]`