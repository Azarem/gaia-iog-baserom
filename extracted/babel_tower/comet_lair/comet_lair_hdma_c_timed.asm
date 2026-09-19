; Timed transition sine HDMA for Comet Lair story beats, slot #05.
; 
; Phase 1: standard sine on $7E8400 bound to HDMA channel #0D (BG1 horizontal scroll) at tick speed #05, waiting for flag #01. Phase 2: reloads with amplitude 4, counts down 112 frames while continuing TickSineHdma/BindSineHdma each frame. At countdown zero, calls SetEntryContinue and stops — gradually dampening the wave distortion during a Lair cutscene event.
---------------------------------------------

---------------------------------------------

comet_lair_hdma_c_timed [
  thinker-def < #04, #08, {

  code_00BD44:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &comet_lair_hdma_c_timed )
    COP [BranchIfFlagByte] ( #01, #01, &CometLairHdmaCTimedBurst )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 
} >
]

CometLairHdmaCTimedBurst {
    LDA #$0070            ; CometLairHdmaCTimedBurst: reload amplitude 4, count down 112 frames
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #04 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &CometLairHdmaCTimedBurst )
    LDA $7F0008, X
    DEC 
    STA $7F0008, X
    BEQ loc_00BD93
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 

  loc_00BD93:
    COP [SetEntryContinue]
    RTL 
}