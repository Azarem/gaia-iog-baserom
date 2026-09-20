; New Babel overview — the transformed world.
; 
; Brief scene: "The Earth's look had changed, but, glowing in
; the sky, it was as beautiful as ever. Buildings and cities..."
; Shows the post-comet world with rebuilt civilization.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!displayModeFlags               09EC
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

s89_new_babel [
  actor-def < #00, #00, #30, {

  code_0BE02C:
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$4001
    TSB $displayModeFlags
    SEP #$20
    LDA #$11
    STA $TM
    LDA #$04
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$01
    STA $CGADSUB
    REP #$20
    COP [WaitWord] ( #$00EF )
    COP [PrintDialogString] ( &dialogstring_0BE075 )
    COP [WaitWord] ( #$01DF )
    COP [FadeThenStartMusic] ( #14 )
    COP [WaitByte] ( #B3 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #F7, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

dialogstring_0BE075 `[DEF][SFX:0][DLY:8]The Earth's look had[N]changed, but, glowing[N]in the sky, it was[N]as beautiful as ever.[PAU:B4][CLR]Buildings replaced the [N]forests, rivers became [N]roads, but the villages [N]held only smiling faces.[PAU:B4][CLR]But the Earth was[N]the only one[N]that looked sad.[PAU:B4][CLR]Tomorrow morning [N]Kara and I will start [N]our new lives.[PAU:B4][CLR]The Tower of Babel[N]stands tall, as if it[N]knows the whole future[N]of the Earth...[PAU:F0][CLD]`