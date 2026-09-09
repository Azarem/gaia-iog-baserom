!joypadMaskStd                  065A
!playerYPos                     09A4
!playerSpeedEw                  09B2

---------------------------------------------

ir1E_actor_09C4B2 [
  actor-def < #00, #00, #30, {

  code_09C4B5:
    COP [SetEntryExit]
    LDA $playerYPos
    CMP #$0110
    BCS loc_09C4C4
    COP [SetFlagByte] ( #00 )
    BRA loc_09C4C7

  loc_09C4C4:
    COP [ClearFlagByte] ( #00 )

  loc_09C4C7:
    COP [BranchIfFlagByte] ( #30, #00, &code_09C4B5 )
    COP [BranchIfFlagByte] ( #31, #00, &code_09C4B5 )
    COP [SetFlagByte] ( #00 )
    COP [PlaySoundBoth] ( #$1616 )

  loc_09C4DA:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$01E8, #$0120, &code_09C4ED )
    COP [BranchIfPlayerAt] ( #$01E7, #$0120, &code_09C4ED )
    RTL 
} >
]

code_09C4ED {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundBoth] ( #$1616 )
    COP [LoopInit] ( #28 )
    COP [SpawnAfterFlags] ( @code_09C51B, #$1000 )
    COP [SetEntryDelayExit] ( @code_09C508, #$0008 )
}

code_09C508 {
    COP [LoopNext]
    LDA #$FFF8
    STA $playerSpeedEw
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #3B )
    BRA loc_09C4DA
}

code_09C51B {
    LDA #$02A0
    STA $14
    COP [RngByte]
    CLC 
    ADC #$0090
    STA $16
    COP [RngByte]
    AND #$0003
    BEQ loc_09C53B
    DEC 
    BEQ loc_09C544
    COP [StageSpriteLoopMoveX] ( #1A, #40, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_09C53B:
    COP [StageSpriteLoopMoveX] ( #1B, #40, #0E )
    COP [AnimLoop]
    COP [Die]

  loc_09C544:
    COP [StageSpriteLoopMoveX] ( #1C, #40, #10 )
    COP [AnimLoop]
    COP [Die]
}