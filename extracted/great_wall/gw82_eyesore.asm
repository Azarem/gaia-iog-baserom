; Eyesore enemy — floating eye creature on the Great Wall.
; 
; Flying enemy that tracks the player and fires projectile
; attacks. Uses BranchOnPlayer* for directional aiming.
; Moves erratically with aerial movement patterns, making
; it difficult to hit consistently.
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw82_eyesore [
  actor-def < #00, #00, #00, {

  loc_0B8DC1:
    COP [WaitWhileOffscreen] ( #07 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    LDA $10
    BIT #$4000
    BNE loc_0B8DC1
    COP [BranchIfPlayerNear] ( #04, &code_0B8E29 )

  code_0B8DDF:
    COP [BranchOnPlayerX] ( #$0000, &code_0B8DEA, &code_0B8DEA, &code_0B8DF2 )
    RTL 
} >
]

code_0B8DEA {
    COP [StageSprAndHitbox] ( #02 )
    LDA #$FFE0
    BRA loc_0B8DFD
}

code_0B8DF2 {
    COP [StageSprAndHitbox] ( #82 )
    LDA #$0002
    TSB $12
    LDA #$0020

  loc_0B8DFD:
    CLC 
    ADC $14
    STA $moveXAlt, X
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #FF, #01 )
    LDA #$0008
    TRB $10
    LDA #$0002
    TRB $12
    BRA loc_0B8DC1
}

code_0B8E29 {
    LDA #$0001
    TSB $12
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]
    COP [LoopStart] ( #03 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [RngByte]
    COP [SpawnAfterOffsetFlags] ( @code_0B8E67, #$0000, #$FFF6, #$0302 )
    COP [SpawnAfterOffsetFlags] ( @code_0B8E6C, #$0000, #$FFF6, #$0302 )
    COP [PlaySoundCh1] ( #1E )
    COP [LoopEnd]
    COP [StageSpriteLoop] ( #00, #02 )
    COP [AnimLoop]
    LDA #$0001
    TRB $12
    JMP $&code_0B8DDF
}

code_0B8E67 {
    LDA #$4000
    TSB $12
}

code_0B8E6C {
    COP [InitGravity] ( #02, #0A, #00 )
    PEA $&code_0B8E91-1
    LDA $0410
    AND #$0003
    BNE loc_0B8E80
    COP [StageMoveX] ( #00 )
    RTS 

  loc_0B8E80:
    DEC 
    BNE loc_0B8E86
    COP [StageMoveX] ( #13 )

  loc_0B8E86:
    DEC 
    BNE loc_0B8E8D
    COP [StageMoveX] ( #11 )
    RTS 

  loc_0B8E8D:
    COP [StageMoveX] ( #13 )
    RTS 
}

code_0B8E91 {
    COP [RngByte]
    AND #$001F
    STA $24
    LDA $12
    BIT #$4000
    BEQ loc_0B8EA7
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_0B8EA7:
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [StageSprAndHitbox] ( #04 )

  loc_0B8EB3:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BNE loc_0B8EC8
    COP [ReloadMoveDurations]
    STZ $2E
    BRA loc_0B8EB3

  loc_0B8EC8:
    COP [SetEntryHere]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0B8ED6
    DEC $24
    BMI loc_0B8EB3
    RTL 

  loc_0B8ED6:
    LDA #$0102
    TRB $10
    STZ $2C
    STZ $2E
    COP [BranchIfBehindWall] ( &code_0B8EF0 )
    COP [StageSpriteMoveXY] ( #04, #47, #45 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
}

code_0B8EF0 {
    COP [Die]
}