; Sine wave HDMA effect for the Tower of Babel ending scenes.
; 
; Creates a wavy screen distortion effect during the
; post-boss sequences and ending transitions.
---------------------------------------------

!animScratch2                   7F000E

---------------------------------------------

sine_hdma_ending_wave [
  thinker-def < #04, #08, {

  code_00BF1B:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BF1B )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    RTL 
} >
]

SineHdmaEndingWaveGen {
    LDA $animScratch2, X  ; SineHdmaEndingWaveGen: OR animScratch2 bit 0, GenHdmaSine, QueueHdma channel $10
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryHere]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #0F )
    REP #$20
    RTL 
}