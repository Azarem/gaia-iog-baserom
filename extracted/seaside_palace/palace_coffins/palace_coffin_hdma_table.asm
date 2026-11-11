; HDMA table thinker of the Seaside Palace coffin scene ($5C).
; 
; On its first pass it fills 17 three-byte rows ($90 and the pointer $7100) of the staging buffer $7E7000 and a table of zero words at $7E7100, queues the buffer with QueueHdma (#21), yields and sets scene setup flag $FF. From then on it queues the same buffer every frame while $FF is set and rebuilds the table if $FF is clear.
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
    COP [QueueHdma] ( $tileStagingBuffer, #21 )
    COP [SetEntryHereAndYield]
    COP [SetFlagByte] ( #FF )
    COP [SetEntryHere]
    COP [QueueHdma] ( $tileStagingBuffer, #21 )
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BE3B )
    RTL 
} >
]