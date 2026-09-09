!animScratch2                   7F000E

---------------------------------------------

sine_hdma_ending_wave [
  thinker-def < #04, #08, {

  code_00BF1B:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BF1B )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    RTL 
} >
]

code_00BF3A {
    LDA $animScratch2, X
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryContinue]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #0F )
    REP #$20
    RTL 
}