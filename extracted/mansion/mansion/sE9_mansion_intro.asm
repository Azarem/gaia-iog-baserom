; Mansion entrance narration — awakening in a strange place.
; 
; Story text: "When I awoke, I was standing in the entrance
; to a strange mansion." Introduces the optional Solid Arm
; boss area. Sets the unsettling atmosphere of the Jeweler
; Gem's true domain.
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!CGADSUB                        2131

---------------------------------------------

sE9_mansion_intro [
  actor-def < #00, #00, #30, {

  code_08FC6D:
    COP [BranchIfFlagByte] ( #29, #01, &code_08FC92 )
    SEP #$20
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SetFlagByte] ( #29 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08FCBE )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_08FC92 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInRelTiles] ( #32, #3E, #34, #3F, &code_08FCA6 )
    SEP #$20
    LDA #$21
    STA $CGADSUB
    REP #$20
    RTL 
}

code_08FCA6 {
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$0280, #$01A0, #80, #$2310 )
    COP [Die]
}

dialogstring_08FCBE `[TPL:A][TPL:0]When I awoke, I was [N]standing in the entrance[N]to a strange mansion.[PAL:0][END]`