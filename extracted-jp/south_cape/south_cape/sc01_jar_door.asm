!joypadMaskStd                  065A

---------------------------------------------

h_sc01_jar_door [
  actor-def < #00, #00, #10, {

  code_04897E:
    COP [SetPriorityMax]
    COP [DrawMetatileAbs] ( #2C, #0E, #F8 )
    COP [DrawMetatileAbs] ( #15, #24, #F8 )
    COP [BranchOnFlagByte] ( #11, #01, &code_0489CF )
    COP [SetEntryHere]
    COP [BranchIfPlayerAt] ( #$0078, #$025E, &code_04899B )
    RTL 
} >
]

code_04899B {
    COP [SetFlagByte] ( #11 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteMoveY] ( #3F, #21 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ClearPriorityMax]
    COP [PrintDialogString] ( &dialogstring_0489D1 )
    COP [LoopStart] ( #10 )
    LDA #$2000
    TSB $10
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [SetEntryHereAndYield]
    COP [LoopEnd]
}

code_0489CF {
    COP [Die]
}

dialogstring_0489D1 `[TPL:10][TPL:0]モリスの家の ドアを[N]開けたとたん 中から ツボが[N]飛んできたっ![END]`