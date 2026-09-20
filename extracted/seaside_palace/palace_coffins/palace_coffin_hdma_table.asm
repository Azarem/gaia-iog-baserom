; HDMA table data for the Seaside Palace coffin room effects.
; 
; Lookup table providing HDMA gradient parameters for the
; eerie lighting in the coffin examination rooms.
---------------------------------------------

!tileStagingBuffer              7E7000

---------------------------------------------

palace_coffin_hdma_table [
  thinker-def < #04, #08, {

  code_00BE3B:
    PHX 
    LDX #$0000
    LDY #$0010

  loc_00BE42:
    LDA #$0090
    STA $tileStagingBuffer, X
    LDA #$7100
    STA $7E7001, X
    INX 
    INX 
    INX 
    DEY 
    BPL loc_00BE42
    LDX #$0000
    LDY #$0010

  loc_00BE5C:
    LDA #$0000
    STA $7E7100, X
    INX 
    INX 
    DEY 
    BPL loc_00BE5C
    PLX 
    COP [QueueHdma] ( $7E7000, #21 )
    COP [SetEntryHereAndYield]
    COP [SetFlagByte] ( #FF )
    COP [SetEntryHere]
    COP [QueueHdma] ( $7E7000, #21 )
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BE3B )
    RTL 
} >
]