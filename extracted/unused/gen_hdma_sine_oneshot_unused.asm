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
    COP [SetEntryContinue]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #10 )
    REP #$20
    RTL 
} >
]