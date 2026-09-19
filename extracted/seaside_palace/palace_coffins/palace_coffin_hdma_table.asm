; Custom static HDMA scroll table builder for Seaside Palace coffin room, slot #00.
; 
; Constructs 16 three-byte HDMA entries at tileStagingBuffer ($7E7000) targeting register $2171 (BG2 vertical scroll), zeroes 16 data words at $7E7100, then queues HDMA on channel #21. Uses SetEntryExit/SetEntryContinue to rebuild and re-queue each frame when flag #FF is clear. Provides per-scanline scroll control for the coffin room layout rather than using the engine's sine generator.
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
    COP [SetEntryExit]
    COP [SetFlagByte] ( #FF )
    COP [SetEntryContinue]
    COP [QueueHdma] ( $7E7000, #21 )
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BE3B )
    RTL 
} >
]