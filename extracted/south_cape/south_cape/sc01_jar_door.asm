; Seth's house door event in South Cape.
; 
; Triggers the comedic jar-throwing cutscene when Will approaches
; Seth's front door, showing his parents fighting.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

sc01_jar_door [
  actor-def < #00, #00, #10, {

  code_0489F5:
    COP [CollPrioritySetMax]
    COP [DrawMetatileAbs] ( #2C, #0E, #F8 )
    COP [DrawMetatileAbs] ( #15, #24, #F8 )
    COP [BranchIfFlagByte] ( #11, #01, &code_048A46 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0078, #$025E, &code_048A12 )
    RTL 
} >
]

code_048A12 {
    COP [SetFlagByte] ( #11 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteMoveY] ( #3F, #21 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [CollPriorityClearMax]
    COP [PrintDialogString] ( &dialogstring_048A48 )
    COP [LoopInit] ( #10 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    COP [LoopNext]
}

code_048A46 {
    COP [Die]
}

dialogstring_048A48 `[TPL:10][TPL:0]No sooner was the door[N]to Seth's house opened[N]than a jar came flying[N]out![END]`