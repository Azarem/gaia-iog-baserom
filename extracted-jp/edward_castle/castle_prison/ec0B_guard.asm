!decelStepCounter               09B8

---------------------------------------------

h_ec0B_guard [
  actor-def < #1B, #00, #10, {

  code_04D5A7:
    COP [BranchOnFlagByte] ( #42, #00, &code_04D5B1 )
    COP [ClearTypeAbs] ( #09, #17 )
} >
]

code_04D5B1 {
    COP [BranchOnFlagByte] ( #43, #00, &code_04D5BB )
    COP [ClearTypeAbs] ( #14, #17 )
}

code_04D5BB {
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04D5E4 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0D, #12, #11, #14, &code_04D5DA )
    LDY $decelStepCounter
    LDA #$2000
    STA $000E, Y
    RTL 
}

code_04D5DA {
    LDY $decelStepCounter
    LDA #$3000
    STA $000E, Y
    RTL 
}

code_04D5E4 {
    COP [PrintDialogString] ( &dialogstring_04D5E9 )
    RTL 
}

dialogstring_04D5E9 `[TPL:E]私は 人の 手助けは受けん.[N]自分の力で 出てみせる···[END]`