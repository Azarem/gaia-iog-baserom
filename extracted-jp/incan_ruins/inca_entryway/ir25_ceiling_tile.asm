?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A

---------------------------------------------

h_ir25_ceiling_tile [
  actor-def < #18, #00, #23, {

  code_04FD69:
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_04FDB8 )
    COP [WaitOnFlagByte] ( #2F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D0E8, #$2000 )
    COP [WaitByte] ( #B3 )
    COP [RngByte]
    STA $08
    COP [SetEntryHereAndYield]
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [SetPriorityMax]
    COP [StageSpriteLoopMoveY] ( #18, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [ClearPriorityMax]
    COP [StageSpriteMoveY] ( #18, #35 )
    COP [AnimOnce]
    BRA code_04FDB8
} >
]

code_04FDB8 {
    LDA #$2000
    TRB $10
    COP [SetPriorityMin]
    COP [ClearCollisionHere]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}