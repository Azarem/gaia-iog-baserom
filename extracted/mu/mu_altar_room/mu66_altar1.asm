; Statue sprite and scene reload of the first altar in the Mu altar room (scene $66).
; 
; Waits for flag $80 (Rama Statue placed on the first pedestal by UseItem_RamaStatue), shows its statue frame #2D and waits for $81. When both flags are set and the player stands outside tiles (00,00)-(20,20) it locks the joypad ($CFFC), waits 30 ticks (WaitByte #1D) and queues a map change to scene $66 at pixel (00F8,01D8). It sets no flag.
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

mu66_altar1 [
  actor-def < #2D, #00, #30, {

  code_069C2D:
    COP [NudgePosition] ( #00, #F8 )
    COP [WaitOnFlagByte] ( #80, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #81, #01 )
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #20, #20, &code_069C6A )
    LDA #$CFFC
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
    COP [SetEntryHere]
    RTL 
}