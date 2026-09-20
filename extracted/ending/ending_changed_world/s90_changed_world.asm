; Changed world overview — continents have shifted.
; 
; Story scene (~76 lines). Will: "Somehow the land has taken on
; a strange shape." Will's father: "That's the new world."
; Kara observes the transformed globe. Visual scene showing
; the continents rearranging into their modern positions
; after the comet's influence.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!displayModeFlags               09EC
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

s90_changed_world [
  actor-def < #00, #00, #30, {

  code_0BDE43:
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$4001
    TSB $displayModeFlags
    SEP #$20
    LDA #$02
    STA $CGWSEL
    LDA #$41
    STA $CGADSUB
    REP #$20
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #80 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #81 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #82 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #83 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #77 )
    COP [PaletteStart] ( #77 )
    COP [PaletteStep]
    COP [StageBgChange] ( #84 )
    COP [ApplyBgChange]
    COP [PaletteStart] ( #78 )
    COP [PaletteStep]
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_0BDED4 )
    COP [WaitByte] ( #B3 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

dialogstring_0BDED4 `[DLG:3,13][SIZ:D,3][SFX:0][TPL:0][SFX:0][DLY:6]Will: [N]Somehow the land [N]has taken on [N]a strange shape.[PAU:B4][CLR][TPL:4][SFX:0]Will's father: [N]That's the new world.[PAU:B4][CLR][TPL:1][SFX:0]Kara: [N]New world?[PAU:B4][CLR][TPL:4][SFX:0]Will's father: The path [N]of evolution, changed [N]by the comet, has [N]continued until now.[PAU:B4][CLR]The Earth, too,[N]has a life.[N][PAU:3C]It, too, has evolved and[N]changed its shape.[PAU:B4][CLR]Now that the comet has[N]no influence on the[N]world, it's returned to[N]its original condition.[PAU:B4][CLD]`