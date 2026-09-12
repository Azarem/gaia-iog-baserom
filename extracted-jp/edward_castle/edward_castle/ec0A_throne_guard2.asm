?INCLUDE 'ec0A_throne_guard1'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!decelStepCounter               09B8
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

h_ec0A_throne_guard2 [
  actor-def < #1C, #00, #18, {

  code_04C210:
    COP [SetOnInteract] ( &code_04C2D3 )
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [ClearLowHere]
    COP [SetOnInteract] ( #$0000 )
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_04C2D8 )
    COP [SetFlagByte] ( #0B )
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [WaitByte] ( #0B )
    COP [SpawnAfterFlags] ( @code_04C260, #$2000 )
    COP [StageSpriteLoopMoveY] ( #1E, #05, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C260 {
    LDY $decelStepCounter
    LDA $0014, Y
    CMP #$01F8
    BEQ loc_04C275
    INC 
    STA $0014, Y
    COP [SetEntryExit]
    COP [SetEntryExit]
    BRA code_04C260

  loc_04C275:
    COP [SpawnAfterFlags] ( @code_04C28F, #$2000 )
    COP [LoopInit] ( #50 )
    LDY $decelStepCounter
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_04C28F {
    COP [WaitByte] ( #1F )
    LDA #$000F
    STA $orbitAngle, X

  code_04C299:
    LDA $orbitAngle, X
    DEC 
    BMI loc_04C2B2
    STA $orbitAngle, X
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [SetEntryDelayExit] ( @code_04C299, #$0004 )

  loc_04C2B2:
    COP [SetFlagByte] ( #21 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0301
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #0B, #$00E8, #$00A0, #83, #$3200 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_04C2D3 {
    COP [PrintDialogString] ( &ec0A_throne_guard1.dialogstring_04C1E8 )
    RTL 
}

dialogstring_04C2D8 `[TPL:D][TPL:0]テム:[N]おばさん! たすけてっ![FIN][TPL:3]エドワード王后:[N]オバサンですってっ?!!![PAL:0][END]`