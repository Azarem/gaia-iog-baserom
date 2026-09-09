?INCLUDE 'vblank_joypad'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!INIDISP                        2100

---------------------------------------------

sFC_actor_0BC9AE [
  actor-def < #00, #00, #38, {

  code_0BC9B1:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitWord] ( #$021B )
    BRA loc_0BC9C6
} >
]

sFC_actor_0BC9BD [
  actor-def < #00, #00, #38, {

  code_0BC9C0:
    LDA #$FFF0
    TSB $joypadMaskStd

  loc_0BC9C6:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$1001, &code_0BC9CF )
    RTL 
} >
]

code_0BC9CF {
    STZ $0DB6
    LDA #$0000
    STA $gfxCacheIdxB
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #FA, #$0100, #$0370, #00, #$4400 )
    COP [SetEntryExit]
    PHD 
    PHX 
    LDA #$0000
    TCD 
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    PLX 
    PLD 
    COP [SetEntryContinue]
    SEP #$20
    LDA #$00
    STA $INIDISP
    REP #$20
    RTL 
}