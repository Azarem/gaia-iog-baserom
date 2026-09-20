; Timed HDMA effect C for the comet lair.
; 
; Time-varying HDMA distortion that pulses during the
; Dark Gaia fight. Creates dynamic visual intensity changes
; during boss phase transitions.
---------------------------------------------

---------------------------------------------

comet_lair_hdma_c_timed [
  thinker-def < #04, #08, {

  code_00BD44:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #08 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &comet_lair_hdma_c_timed )
    COP [BranchOnFlagByte] ( #01, #01, &CometLairHdmaCTimedBurst )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 
} >
]

CometLairHdmaCTimedBurst {
    LDA #$0070            ; CometLairHdmaCTimedBurst: reload amplitude 4, count down 112 frames
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #04 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &CometLairHdmaCTimedBurst )
    LDA $7F0008, X
    DEC 
    STA $7F0008, X
    BEQ loc_00BD93
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 

  loc_00BD93:
    COP [SetEntryHere]
    RTL 
}