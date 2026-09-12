?INCLUDE 'system_strings'

!gfxCacheIdxB                   064A
!displayModeFlags               09EC
!TM                             212C
!cgramPalette                   7F0A00

---------------------------------------------

sFC_actor_0BC924 [
  actor-def < #00, #00, #30, {

  code_0BC927:
    LDA #$4001
    TSB $displayModeFlags
    COP [CopyPalette] ( @pal_title, #00, #00, #20 )
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 )
    LDA #$0000
    STA $cgramPalette
    COP [SpawnAfterAbsFlags] ( @code_0BC988, #$0080, #$0050, #$1800 )
    SEP #$20
    LDA #$10
    STA $TM
    REP #$20
    LDA #$0804
    STA $gfxCacheIdxB
    COP [WaitByte] ( #B3 )
    COP [RunBg3Script] ( @system_strings.consolestring_01DA5E )
    COP [WaitByte] ( #77 )
    COP [RunBg3Script] ( @system_strings.consolestring_01DA47 )
    COP [WaitWord] ( #$09D3 )
    COP [SetFlagByte] ( #F4 )
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BC988 {
    COP [SetSpritePriority] ( #10 )
    COP [StageSpriteLoop] ( #00, #F0 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #00, #40, #02 )
    COP [AnimLoop]
    COP [WaitByte] ( #3B )
    SEP #$20
    LDA #$16
    STA $TM
    REP #$20
    COP [SetEntryContinue]
    RTL 
}

code_0BC9A7 {
    COP [PaletteStart] ( #2D )
    COP [PaletteStep]
    COP [Die]
}