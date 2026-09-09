!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

mu66_altar1 [
  actor-def < #2D, #00, #30, {

  code_069C2D:
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #80, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #81, #01 )
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #20, #20, &code_069C6A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0303
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #66, #$00F8, #$01D8, #80, #$2200 )
} >
]

code_069C6A {
    COP [SetEntryContinue]
    RTL 
}