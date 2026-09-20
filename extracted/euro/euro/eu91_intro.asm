; Euro arrival narration — town introduction.
; 
; Extended narration (~93 lines): "We crossed the desert and
; finally arrived in the village of Euro." Multi-phase arrival
; cutscene establishing the European setting.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!playerActor                    09AA

---------------------------------------------

eu91_intro [
  actor-def < #00, #00, #38, {

  code_07BE25:
    COP [BranchOnFlagByte] ( #A5, #01, &code_07BEB2 )
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
    COP [SpawnListAppend] ( @code_07BED1, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @code_07BEB4, #$2800 )
    COP [WaitByte] ( #27 )
    COP [StageSpriteLoopMoveX] ( #08, #10, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #1E, #02 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetFlagByte] ( #A5 )
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07C011 )
    COP [WaitByte] ( #3B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #96, #$00A0, #$0090, #03, #$1100 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
} >
]

code_07BEB2 {
    COP [Die]
}

code_07BEB4 {
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

code_07BED1 {
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07BEDA )
    COP [Die]
}

dialogstring_07BEDA `[DEF][TPL:0][SFX:10][DLY:2]We crossed the desert[N]and finally arrived in[N]the village of Euro.[PAU:78][CLR]Euro was a bustling[N]city, larger than[N]I had imagined.[PAU:B4][CLR]Neil's parents lived [N]there, and ran a [N]company called Rolek.[PAU:78][CLR]Neil hadn't been there [N]for three years.[N]His parents welcomed[N]him home.[PAU:78][CLR]They set off fireworks. [N]There were dancers. [N]It looked like a [N]festival had started.[PAU:B4][PAL:0][CLD]`

dialogstring_07C011 `[DEF][TPL:0][SFX:10][DLY:2]This is the house [N]where Neil's parents [N]live. We were shown [N]to the guest room.[PAL:0][END]`