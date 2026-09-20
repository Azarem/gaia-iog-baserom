; Class dismissed — the game's final scene (~208 lines).
; 
; Returns to South Cape school where the game began.
; "Class is over. Please be careful crossing the street."
; Will walks out of school into the sunlight. The bookend
; moment that closes the game's narrative loop. Includes
; the mysterious final encounter on the street.
---------------------------------------------

!joypadMaskStd                  065A
!displayModeFlags               09EC
!TM                             212C
!backdropColors                 7F0C00

---------------------------------------------

sF0_class_dismissed [
  actor-def < #00, #00, #20, {

  code_09DB6A:
    LDA #$1000
    TSB $12
    LDA #$4001
    TSB $displayModeFlags
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$FF
    STA $backdropColors
    REP #$20
    STZ $00E4
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SpawnAfter] ( @code_09DC2D )
    COP [SpawnAfterAbsFlags] ( @code_09DC63, #$0098, #$0078, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09DC78, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09DC97, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09DCB6, #$0000, #$0088, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09DCD5, #$0000, #$0078, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_09DCF4, #$0088, #$0040, #$3000 )
    COP [WaitByte] ( #0F )
    INC $00E4
    COP [WaitWord] ( #$00B3 )
    INC $00E4
    COP [WaitWord] ( #$00B3 )
    COP [LoopStart] ( #06 )
    COP [PlaySoundBoth] ( #$0909 )
    COP [JumpAfterDelay] ( @code_09DBF3, #$001E )
} >
]

code_09DBF3 {
    COP [LoopEnd]
    COP [WaitWord] ( #$003B )
    COP [PrintDialogString] ( &dialogstring_09DD10 )
    COP [WaitWord] ( #$003B )
    COP [StartMusic] ( #02 )
    COP [WaitWord] ( #$0077 )
    INC $00E4
    COP [WaitByte] ( #13 )
    INC $00E4
    COP [WaitByte] ( #13 )
    INC $00E4
    COP [WaitByte] ( #27 )
    INC $00E4
    COP [WaitByte] ( #27 )
    INC $00E4
    COP [WaitWord] ( #$0077 )
    INC $00E4
    COP [SetEntryHere]
    RTL 
}

code_09DC2D {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0001
    BEQ loc_09DC3B
    RTL 

  loc_09DC3B:
    COP [PaletteStart] ( #6A )
    COP [PaletteStep]
    COP [SetEntryHere]
    LDA $00E4
    CMP #$0002
    BEQ loc_09DC4B
    RTL 

  loc_09DC4B:
    COP [PaletteStart] ( #1C )
    COP [PaletteStep]
    COP [SetEntryHere]
    LDA $00E4
    CMP #$0007
    BEQ loc_09DC5B
    RTL 

  loc_09DC5B:
    COP [PaletteStart] ( #70 )
    COP [PaletteStep]
    COP [SetEntryHere]
    RTL 
}

code_09DC63 {
    LDA #$1000
    TSB $12

  loc_09DC68:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09DC68
    COP [SetEntryHere]
    RTL 
}

code_09DC78 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0003
    BEQ loc_09DC86
    RTL 

  loc_09DC86:
    COP [StageSpriteMoveX] ( #00, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09DC86
    COP [SetEntryHere]
    RTL 
}

code_09DC97 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0004
    BEQ loc_09DCA5
    RTL 

  loc_09DCA5:
    COP [StageSpriteMoveX] ( #01, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09DCA5
    COP [SetEntryHere]
    RTL 
}

code_09DCB6 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0005
    BEQ loc_09DCC4
    RTL 

  loc_09DCC4:
    COP [StageSpriteMoveX] ( #02, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09DCC4
    COP [SetEntryHere]
    RTL 
}

code_09DCD5 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0006
    BEQ loc_09DCE3
    RTL 

  loc_09DCE3:
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
    LDA $00E4
    CMP #$0007
    BNE loc_09DCE3
    COP [SetEntryHere]
    RTL 
}

code_09DCF4 {
    LDA #$1000
    TSB $12
    LDA $00E4
    CMP #$0008
    BEQ loc_09DD02
    RTL 

  loc_09DD02:
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #09, #11 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

dialogstring_09DD10 `[DLG:0,17][SIZ:F,3][DLY:5]         Class is over.[N][PAU:B4][CLR]       Please be careful[N]      crossing the street.[N][PAU:F0][CLR]      We have had a lot of[N]    traffic accidents lately.[N][PAU:68][CLD]`