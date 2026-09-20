; Unreferenced byte-identical duplicate of native_village_sine_hdma with identical logic: InitSineHdma on $8800 (20-byte, speed $04), TickSineHdma, dual BindSineHdma to channels $0E and $10.
; 
; The active native_village_sine_hdma thinker is used on Native Village scenes instead. Dead copy left in the unused bank region.
---------------------------------------------

---------------------------------------------

native_village_dup_unused [
  thinker-def < #04, #08, {

  code_00BEAC:
    LDA #$0004
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #20 )
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BEAC )
    COP [TickSineHdma] ( #04, #02 )
    COP [BindSineHdma] ( $7E8C00, #0E )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]