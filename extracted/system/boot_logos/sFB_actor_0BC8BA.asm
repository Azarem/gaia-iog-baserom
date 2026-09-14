?INCLUDE 'system_strings'

!joypadMaskStd                  065A
!displayModeFlags               09EC
!TM                             212C
!STAT78                         213F
!MEMSEL                         420D
!cgramPalette                   7F0A00

---------------------------------------------

sFB_actor_0BC8BA [
  actor-def < #00, #00, #18, {

  code_0BC8BD:
    LDA #$4000
    TSB $displayModeFlags
    LDA #$0000
    STA $cgramPalette
    SEP #$20
    LDA #$01
    STA $MEMSEL
    LDA #$10
    STA $TM
    REP #$20
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA $STAT78
    BIT #$10
    BEQ loc_0BC8EA
    JMP $&func_0BC896

  loc_0BC8EA:
    REP #$20
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #10, #01, &code_0BC90F )
    COP [AddPosition] ( #00, #F0 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #10 )
    COP [QueueMapChange] ( #FB, #$0000, #$0000, #00, #$1100 )
    COP [Die]
} >
]

code_0BC90F {
    COP [StageSpriteLoop] ( #00, #02 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #10 )
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}
---------------------------------------------

func_0BC896 {
    REP #$20
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 )
    LDA #$0000
    STA $cgramPalette
    COP [RunBg3Script] ( @system_strings.boot_screen_strings )
    SEP #$20
    LDA #$04
    STA $TM
    REP #$20
    COP [SetEntryContinue]
    RTL 
}