!cameraDeltaX                   06C0

---------------------------------------------

larai_cliff_scroll_wave [
  thinker-def < #04, #08, {

  code_00BD98:
    LDA #$0004
    STA $7F0008, X
    COP [SetFlagByte] ( #FF )
    COP [InitSineHdma] ( #$8800, #10 )
    LDA $cameraDeltaX
    PHA 
    LDA $0722
    LSR 
    LSR 
    LSR 
    LSR 
    STA $cameraDeltaX
    COP [TickSineHdma] ( #04, #02 )
    PLA 
    STA $cameraDeltaX
    COP [BindSineHdma] ( $7E8800, #0D )
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BD98 )
    RTL 
} >
]