; Title screen intro sequence — scene $FC master controller for the opening cinematic and text display.
; 
; Loads the title palette, spawns a child sprite actor for the animated comet/logo, and drives the
; timed text display sequence. After a ~42-second idle period ($09D3 frames), sets flag $F4 (title
; screen viewed) and transitions to scene $8C.
; 
; === DISPLAY LAYERS ===
; 
; TM starts at $10 (BG1 only for title background). The child actor (TitleCometSpriteActor) later sets TM = $16
; (BG1 + BG2 + BG3) after the sprite animation completes, enabling the text and subtitle layers.
; 
; === TEXT TIMING ===
; 
; Two BG3 text scripts are shown in sequence:
; - consolestring_01DA5E after $B3 frames (179 frames, ~3 seconds)
; - consolestring_01DA47 after $77 more frames (119 frames, ~2 seconds)
---------------------------------------------

?INCLUDE 'system_strings'

!gfxCacheIdxB                   064A
!displayModeFlags               09EC
!TM                             212C
!cgramPalette                   7F0A00

---------------------------------------------

sFC_title_intro [
  actor-def < #00, #00, #30, {

  TitleIntroInit:
    LDA #$4001            ; Bits 14+0: title display mode
    TSB $displayModeFlags
    COP [CopyPalette] ( @pal_title, #00, #00, #20 ) ; Full title palette (32 colors)
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 ) ; Comet sprite palette (8 colors)
    LDA #$0000
    STA $cgramPalette
    COP [SpawnAfterAbsFlags] ( @TitleCometSpriteActor, #$0080, #$0050, #$1800 ) ; Spawn comet actor at (128,80)
    SEP #$20
    LDA #$10              ; BG1 only — title background
    STA $TM
    REP #$20
    LDA #$0804            ; Graphics cache: transition effect index
    STA $gfxCacheIdxB
    COP [WaitByte] ( #B3 ) ; Wait 179 frames (~3 sec)
    COP [RunBg3Script] ( @system_strings.consolestring_01DA5E ) ; First title text string
    COP [WaitByte] ( #77 ) ; Wait 119 frames (~2 sec)
    COP [RunBg3Script] ( @system_strings.consolestring_01DA47 ) ; Second title text string
    COP [WaitWord] ( #$09D3 ) ; Wait 2515 frames (~42 sec idle)
    COP [SetFlagByte] ( #F4 ) ; Mark title screen as viewed
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 ) ; Transition to scene $8C (prologue)
    COP [SetEntryContinue]
    RTL 
} >
]

---------------------------------------------
; Title screen comet/logo sprite — animated sprite that sweeps across the title, then enables text layers.
; Plays a stationary sprite loop, then a horizontal movement animation, and finally enables BG2+BG3.

TitleCometSpriteActor {
    COP [SetSpritePriority] ( #10 ) ; Sprite priority $10
    COP [StageSpriteLoop] ( #00, #F0 ) ; Stationary sprite loop #00, 240 ticks
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #00, #40, #02 ) ; Horizontal sweep: 64px at speed 2
    COP [AnimLoop]
    COP [WaitByte] ( #3B ) ; Wait 59 frames (~1 sec) after sweep
    SEP #$20
    LDA #$16              ; BG1 + BG2 + BG3: enable text/subtitle layers
    STA $TM
    REP #$20
    COP [SetEntryContinue] ; Persist as idle actor
    RTL 
}

---------------------------------------------
; Title screen palette fade — steps palette animation #2D once and terminates.

TitlePaletteFadeStep {
    COP [PaletteStart] ( #2D ) ; Initialize palette animation #45
    COP [PaletteStep]     ; Step one fade frame
    COP [Die]
}