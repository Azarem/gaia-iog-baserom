!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerActor                    09AA

---------------------------------------------

wa78_intro [
  actor-def < #00, #00, #38, {

  code_078003:
    COP [BranchIfFlagByte] ( #8D, #01, &code_07808E )
    LDA #$0008
    TSB $12
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0800
    TSB $10
    COP [SpawnLastRel] ( @code_0780AD, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @code_078090, #$2800 )
    COP [StageSpriteLoopMoveY] ( #07, #08, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #07, #10, #11, #02 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetFlagByte] ( #8D )
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_078139 )
    COP [WaitByte] ( #3B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #00, #$1100 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_07808E {
    COP [Die]
}

code_078090 {
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0080
    STA $cameraTargetX
    STA $cameraDeltaX
    LDA $0016, Y
    SEC 
    SBC #$0080
    STA $cameraTargetY
    STA $cameraDeltaY
    RTL 
}

code_0780AD {
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0780B6 )
    COP [Die]
}

widestring_0780B6 `[DEF][TPL:0][SFX:10][DLY:3]We went to the Water[N]City, Watermia.[PAU:78][N]A beautiful town with[N]houses built on rafts.[PAU:78][CLR]The townspeople have[N]kindly put us up at[N]the house of young Luke.[PAU:B4][PAL:0][CLD]`

widestring_078139 `[DEF][CLR][TPL:0][SFX:10][DLY:0]This is Luke's house.[N]He is a loveable[N]young fisherman.[FIN]I am going out on[N]a long fishing voyage.[N]You can use my house[N]while I'm gone.[PAL:0][END]`