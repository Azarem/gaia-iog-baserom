; Late-game sine HDMA wave used across Comet approach, Dark Space, and Dark Castoth Lair.
; 
; Initializes counter #$0008, builds sine table at $7E8800 with amplitude 40, ticks at speed #01, and binds to HDMA channel #0F. Includes an auxiliary path that sets animScratch2 bit 0, calls GenHdmaSine, and queues HDMA — a one-shot regen path. Produces slow, wide-amplitude background distortion for pre-final-boss and comet-approach areas.
---------------------------------------------

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

SineHdmaEndingWaveGen {
    LDA $animScratch2, X  ; SineHdmaEndingWaveGen: OR animScratch2 bit 0, GenHdmaSine, QueueHdma channel $10
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryContinue]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #0F )
    REP #$20
    RTL 
}