!joypadMaskStd                  065A
!playerSpeedEw                  09B2

---------------------------------------------

h_ir1E_actor_09C4B2 [
  actor-def < #00, #00, #30, {

  code_0580CF:
    COP [SetEntryExit]
    LDA $playerSpeedEw
    CMP #$0110
    BCS chunk_058000.loc_0580DE
    COP [SetFlagByte] ( #00 )
    BRA chunk_058000.loc_0580E1

  loc_0580DE:
    COP [ClearFlagByte] ( #00 )

  loc_0580E1:
    COP [BranchIfFlagByte] ( #30, #00, &chunk_058000.code_0580CF )
    COP [BranchIfFlagByte] ( #31, #00, &chunk_058000.code_0580CF )
    COP [SetFlagByte] ( #00 )
    COP [PlaySoundBoth] ( #$1616 )

  loc_0580F4:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$01E8, #$0120, &chunk_058000.code_058107 )
    COP [BranchIfPlayerAt] ( #$01E7, #$0120, &chunk_058000.code_058107 )
    RTL 
} >
]

code_058107 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundBoth] ( #$1616 )
    COP [LoopInit] ( #28 )
    COP [SpawnAfterFlags] ( @chunk_058000.code_058135, #$1000 )
    COP [SetEntryDelayExit] ( @chunk_058000.code_058122, #$0008 )
}

code_058122 {
    COP [LoopNext]
    LDA #$FFF8
    STA $09C0
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #3B )
    BRA chunk_058000.loc_0580F4
}

code_058135 {
    LDA #$02A0
    STA $14
    COP [RngByte]
    CLC 
    ADC #$0090
    STA $16
    COP [RngByte]
    AND #$0003
    BEQ chunk_058000.loc_058155
    DEC 
    BEQ chunk_058000.loc_05815E
    COP [StageSpriteLoopMoveX] ( #1A, #40, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_058155:
    COP [StageSpriteLoopMoveX] ( #1B, #40, #0E )
    COP [AnimLoop]
    COP [Die]

  loc_05815E:
    COP [StageSpriteLoopMoveX] ( #1C, #40, #10 )
    COP [AnimLoop]
    COP [Die]
}