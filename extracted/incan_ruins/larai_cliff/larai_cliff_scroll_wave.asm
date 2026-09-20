; Scroll-linked sine HDMA unique to Larai Cliff.
; 
; Initializes sine table at $7E8800 with amplitude 16, temporarily overwrites cameraDeltaX ($06C0) with the upper nibble of scroll accumulator $0722 before TickSineHdma, then restores the original value. Binds $7E8800 to HDMA channel #0D at tick speed #04, tying wave amplitude to camera scroll position for parallax-linked cliff-edge distortion. Re-inits when flag #FF is clear; produces water/wind shimmer at the cliff edge tied to player movement.
---------------------------------------------

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
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BD98 )
    RTL 
} >
]