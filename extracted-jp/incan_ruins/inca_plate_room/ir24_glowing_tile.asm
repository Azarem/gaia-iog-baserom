!orbitAngle                     7F0010

---------------------------------------------

h_ir24_glowing_tile [
  actor-def < #00, #00, #23, {

  code_058273:
    COP [BranchIfFlagWord] ( #$0112, #01, &code_0582A9 )
} >
]

code_05827A {
    LDA #$0258
    STA $orbitAngle, X
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #14, #17, #17, #1A, &code_058290 )
    COP [SetEntryExitNow] ( @code_05827A )
}

code_058290 {
    LDA $orbitAngle, X
    DEC 
    BEQ loc_05829C
    STA $orbitAngle, X
    RTL 

  loc_05829C:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #12 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0112 )
}

code_0582A9 {
    COP [Die]
}