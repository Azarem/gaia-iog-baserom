; HDMA effect A for the comet lair arena.
; 
; Technical thinker providing the first layer of HDMA
; visual effects for the Dark Gaia boss arena.
---------------------------------------------

---------------------------------------------

comet_lair_hdma_a [
  thinker-def < #04, #08, {

  code_00BCF7:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    LDA #$0000
    STA $7E8C30
    STA $7E8E30
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BCF7 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]