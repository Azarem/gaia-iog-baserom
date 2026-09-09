---------------------------------------------

native_village_dup_unused [
  thinker-def < #04, #08, {

  code_00BEAC:
    LDA #$0004
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #20 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BEAC )
    COP [TickSineHdma] ( #04, #02 )
    COP [BindSineHdma] ( $7E8C00, #0E )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]