?BANK 02

?INCLUDE 'dialogue_engine'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'system_core'

!joypadMaskStd                  065A
!musicParentActor               06F2
!musicTransitionState           06FA
!displayModeFlags               09EC
!APUIO1                         2141
!chatPtr                        7F000A
!orbitAngle                     7F0010

---------------------------------------------

MusicPlaybackActor {
    LDA $musicParentActor
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 )
    CPY #$1FC0
    BNE loc_02A056
    JMP $&code_02A0DD

  loc_02A056:
    TXA 
    TYX 
    TAY 
    LDA $26
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A07D
    RTL 

  loc_02A07D:
    COP [SpawnAfterFlags] ( @MusicRenderSync, #$2000 )
    LDA $20
    STA $0020, Y
    LDA $22
    STA $0022, Y
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_02A0A9
    RTL 

  loc_02A0A9:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 )
    CPY #$1FC0
    BEQ code_02A0DD
    PHX 
    LDA $orbitAngle, X
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A0DA
    RTL 

  loc_02A0DA:
    COP [WaitByte] ( #01 )
}

code_02A0DD {
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}

MusicRenderSync {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    PHP 
    PHB 
    REP #$20
    STZ $joypadMaskStd
    SEP #$20
    LDA $22
    PHA 
    PLB 
    LDY $20
    JSL $@system_core.UpdateFrameRender
    REP #$20
    JSL $@dialogue_engine.WideStringRenderer
    PLB 
    PLP 
    COP [Die]
}

IsMusicPlaying {
    LDA $musicTransitionState
    BNE loc_02A119
    LDA $displayModeFlags
    BIT #$0080
    BNE loc_02A119
    CLC 
    RTL 

  loc_02A119:
    SEC 
    RTL 
}