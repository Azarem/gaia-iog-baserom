!chatPtr                        7F000A

---------------------------------------------

ir21_splop [
  actor-def < #1D, #01, #23, {

  code_0A97F1:
    COP [AddPosition] ( #08, #00 )
    LDA #$0080
    TSB $12
    COP [WaitWhileOffscreen] ( #30 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #08, &code_0A9805 )
    RTL 
} >
]

code_0A9805 {
    LDA #$2000
    TRB $10
    LDA #$0008
    TRB $12
    LDA $10
    BIT #$4000
    BNE loc_0A9819
    COP [PlaySoundCh1] ( #26 )

  loc_0A9819:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0300
    TRB $10
    LDA #$000F
    STA $chatPtr, X

  code_0A982A:
    LDA $chatPtr, X
    DEC 
    STA $chatPtr, X
    BEQ code_0A9805
    CMP #$0006
    BEQ loc_0A9866
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    DEC 
    BMI code_0A987C
    BEQ code_0A988E
    DEC 
    BEQ code_0A98A0
    DEC 
    BEQ code_0A98AF
    COP [BranchNearerAxis] ( &code_0A9852, &code_0A985C )
}

code_0A9852 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A98A0, &code_0A985C, &code_0A98AF )
}

code_0A985C {
    COP [BranchOnPlayerY] ( #$0008, &code_0A988E, &code_0A982A, &code_0A987C )

  loc_0A9866:
    LDA #$0300
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA #$0008
    TSB $12
    BRA code_0A982A
}

code_0A987C {
    COP [BranchIfSolidSouth] ( &code_0A982A )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0A982A )
    COP [StageSpriteMoveY] ( #1F, #28 )
    COP [AnimOnce]
    BRA code_0A982A
}

code_0A988E {
    COP [BranchIfSolidNorth] ( &code_0A982A )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0A982A )
    COP [StageSpriteMoveY] ( #20, #27 )
    COP [AnimOnce]
    BRA code_0A982A
}

code_0A98A0 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0A982A )
    COP [StageSpriteMoveX] ( #21, #27 )
    COP [AnimOnce]
    JMP $&code_0A982A
}

code_0A98AF {
    COP [BranchIfSolidEast] ( &code_0A982A )
    COP [StageSpriteMoveX] ( #A1, #28 )
    COP [AnimOnce]
    JMP $&code_0A982A
}