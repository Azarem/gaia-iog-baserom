!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

ec0A_throne_guard1 [
  actor-def < #1D, #00, #18, {

  code_04C61D:
    COP [SetOnInteract] ( &code_04C66A )
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [ClearLowHere]
    COP [SetOnInteract] ( #$0000 )
    COP [StageSpriteLoopMoveX] ( #21, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteLoopMoveX] ( #21, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #05, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C66A {
    COP [PrintDialogString] ( &dialogstring_04C66F )
    RTL 
}

dialogstring_04C66F `[DEF]Soldier: If you want to[N]see the King, keep[N]your wits about you.[END]`

ec0A_throne_guard2 [
  actor-def < #1C, #00, #18, {

  code_04C6A2:
    COP [SetOnInteract] ( &code_04C765 )
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
    COP [PrintDialogString] ( &dialogstring_04C76A )
    COP [SetFlagByte] ( #0B )
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [WaitByte] ( #0B )
    COP [SpawnAfterFlags] ( @code_04C6F2, #$2000 )
    COP [StageSpriteLoopMoveY] ( #1E, #05, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C6F2 {
    LDY $playerActor
    LDA $0014, Y
    CMP #$01F8
    BEQ loc_04C707
    INC 
    STA $0014, Y
    COP [SetEntryExit]
    COP [SetEntryExit]
    BRA code_04C6F2

  loc_04C707:
    COP [SpawnAfterFlags] ( @code_04C721, #$2000 )
    COP [LoopInit] ( #50 )
    LDY $playerActor
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_04C721 {
    COP [WaitByte] ( #1F )
    LDA #$000F
    STA $orbitAngle, X

  code_04C72B:
    LDA $orbitAngle, X
    DEC 
    BMI loc_04C744
    STA $orbitAngle, X
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [SetEntryDelayExit] ( @code_04C72B, #$0004 )

  loc_04C744:
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

code_04C765 {
    COP [PrintDialogString] ( &dialogstring_04C66F )
    RTL 
}

dialogstring_04C76A `[TPL:D][TPL:0]Will: [N]Ma'am! Save me!![FIN][TPL:3]Queen Edwina: [N]Did you say Ma'am??![PAL:0][END]`