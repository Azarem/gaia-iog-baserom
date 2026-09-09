?INCLUDE 'camera_drift'

!joypadMaskStd                  065A

---------------------------------------------

ir25_ceiling_tile [
  actor-def < #18, #00, #23, {

  code_09C33E:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #2F, #01, &code_09C38D )
    COP [ExitIfFlagByte] ( #2F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopSimple, #$2000 )
    COP [WaitByte] ( #B3 )
    COP [RngByte]
    STA $08
    COP [SetEntryExit]
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [CollPrioritySetMax]
    COP [StageSpriteLoopMoveY] ( #18, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [CollPriorityClearMax]
    COP [StageSpriteMoveY] ( #18, #35 )
    COP [AnimOnce]
    BRA code_09C38D
} >
]

code_09C38D {
    LDA #$2000
    TRB $10
    COP [CollPrioritySetMin]
    COP [ClearAllHere]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}