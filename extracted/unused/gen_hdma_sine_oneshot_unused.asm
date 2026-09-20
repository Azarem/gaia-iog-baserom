; Unreferenced one-shot HDMA sine generator using COP GenHdmaSine and QueueHdma instead of the InitSineHdma/BindSineHdma loop pattern.
; 
; Would have applied a single sine-table HDMA write rather than a continuous wave. Superseded by sine_hdma_slow_wave and native_village_sine_hdma.
---------------------------------------------

!animScratch2                   7F000E

---------------------------------------------

gen_hdma_sine_oneshot_unused [
  thinker-def < #04, #08, {

  code_00BF54:
    LDA #$0006
    STA $0E
    LDA #$0005
    STA $7F0008, X
    LDA $animScratch2, X
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryHere]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #10 )
    REP #$20
    RTL 
} >
]