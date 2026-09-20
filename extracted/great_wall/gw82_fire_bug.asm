; Fire Bug enemy — flame-carrying insect on the Great Wall.
; 
; Fast-moving enemy with contact fire damage. Moves in erratic
; patterns with directional sprite animation. Burns the player
; on contact. Common enemy in the wall corridor sections.
---------------------------------------------

?INCLUDE 'EnemyDefeatDispatch'

!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch2                   7F002E

---------------------------------------------

gw82_fire_bug [
  actor-def < #18, #00, #00, {

  code_0B8C73:
    COP [OrActorFlags] ( #$0020 )
    COP [SetDeathCallback] ( @code_0B8DB9 )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $26

  loc_0B8C86:
    COP [BranchIfOffscreen] ( &code_0B8C94 )
    COP [WaitWhileOffscreen] ( #05 )

  code_0B8C8D:
    LDA $10
    BIT #$4000
    BNE loc_0B8C86
} >
]

code_0B8C94 {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0040, &code_0B8CA3, &code_0B8CD4, &code_0B8CBB )
}

code_0B8CA3 {
    LDA $7F100C, X
    SEC 
    SBC #$00C1
    CMP $14
    BPL code_0B8CBB
    LDA #$FFC0
    JSR $&code_0B8D65
    COP [MoveToward] ( #19, #02 )
    BRA code_0B8C8D
}

code_0B8CBB {
    LDA $7F100C, X
    CLC 
    ADC #$00C1
    CMP $14
    BMI code_0B8CA3
    LDA #$0040
    JSR $&code_0B8D65
    COP [MoveToward] ( #99, #02 )
    JMP $&code_0B8C8D
}

code_0B8CD4 {
    LDA #$2000
    TSB $12
    COP [BranchOnPlayerX] ( #$0000, &code_0B8CE3, &code_0B8CE3, &code_0B8CF4 )
}

code_0B8CE3 {
    LDA $7F100C, X
    SEC 
    SBC #$00B0
    CMP $14
    BPL code_0B8CF4
    COP [StageSprAndHitbox] ( #19 )
    BRA loc_0B8D08
}

code_0B8CF4 {
    LDA $7F100C, X
    CLC 
    ADC #$00A1
    CMP $14
    BMI code_0B8CE3
    COP [StageSprAndHitbox] ( #99 )
    LDA #$4000
    TSB $12

  loc_0B8D08:
    COP [InitGravity] ( #02, #0A, #00 )

  loc_0B8D0D:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    COP [TickGravity]
    COP [StageForceMoveX] ( #02 )
    LDA $16
    CMP $26
    BCC loc_0B8D28
    DEC $24
    BMI loc_0B8D0D
    RTL 

  loc_0B8D28:
    LDA #$6000
    TRB $12
    STZ $2C
    LDA #$0000
    STA $moveScratch2, X
    LDA $26
    CMP $16
    BEQ loc_0B8D4E
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #19, #02 )
    LDA $26
    STA $16

  loc_0B8D4E:
    LDA $10
    BIT #$4000
    BEQ loc_0B8D58
    JMP $&code_0B8C8D

  loc_0B8D58:
    COP [SpawnAfterFlags] ( @code_0B8D73, #$0201 )
    COP [PlaySoundCh1] ( #21 )
    JMP $&code_0B8C8D
}

code_0B8D65 {
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    RTS 
}

code_0B8D73 {
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0B8D82 )
    BRA loc_0B8D8A
}

code_0B8D82 {
    COP [LoopNext]
    COP [Die]

  loc_0B8D86:
    COP [BranchIfSolidSouth] ( &code_0B8D91 )

  loc_0B8D8A:
    COP [SpawnAfterFlags] ( @code_0B8D99, #$0200 )
}

code_0B8D91 {
    COP [StageSpriteLoop] ( #04, #04 )
    COP [AnimLoop]

  loc_0B8D97:
    COP [Die]
}

code_0B8D99 {
    LDA $10
    BIT #$4000
    BNE loc_0B8D97
    COP [PlaySoundCh1] ( #21 )
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #04, #01 )
    BRA loc_0B8D86
}

code_0B8DB9 {
    COP [JumpScript] ( @EnemyDefeatDispatch )
}