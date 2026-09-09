!decelStepCounter               09B8

---------------------------------------------

h_ec0B_guard [
  actor-def < #1B, #00, #10, {

  code_04D5A7:
    COP [BranchIfFlagByte] ( #42, #00, &code_04D5B1 )
    COP [ClearHighAbs] ( #09, #17 )
} >
]

code_04D5B1 {
    COP [BranchIfFlagByte] ( #43, #00, &code_04D5BB )
    COP [ClearHighAbs] ( #14, #17 )
}

code_04D5BB {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D5E4 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
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
    COP [PrintWideString] ( &widestring_04D5E9 )
    RTL 
}

widestring_04D5E9 `[TPL:E]私は 人の 手助けは受けん.[N]自分の力で 出てみせる···[END]`