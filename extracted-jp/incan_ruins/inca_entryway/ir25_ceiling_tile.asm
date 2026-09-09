?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A

---------------------------------------------

h_ir25_ceiling_tile [
  actor-def < #18, #00, #23, {

  code_04FD69:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #2F, #01, &code_04FDB8 )
    COP [ExitIfFlagByte] ( #2F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D0E8, #$2000 )
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
    BRA code_04FDB8
} >
]

code_04FDB8 {
    LDA #$2000
    TRB $10
    COP [CollPrioritySetMin]
    COP [ClearAllHere]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}