; King Bat boss enemy for the aqueduct hall.
; 
; Multi-phase boss with flight patterns, dive attacks, and
; HP-gated phase transitions.
---------------------------------------------

!playerYPos                     09A4

---------------------------------------------

ec0F_king_bat [
  actor-def < #1F, #00, #00, {

  code_0A85FA:
    LDA #$0010
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetSpritePalette] ( #02 )
    COP [AddPosition] ( #08, #00 )
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8733
    BCC loc_0A8614
    RTL 

  loc_0A8614:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]

  loc_0A862E:
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #A1, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #9F, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #A1, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #A0, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A862E
} >
]

ec0F_sub_bat1 [
  actor-def < #1F, #00, #00, {

  code_0A866C:
    JSR $&code_0A8743
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8733
    BCC loc_0A867A
    RTL 

  loc_0A867A:
    COP [StageSpriteMoveX] ( #21, #02 )
    COP [AnimOnce]

  loc_0A8680:
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #A0, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A8680
} >
]

ec0F_sub_bat2 [
  actor-def < #1F, #00, #00, {

  code_0A869D:
    JSR $&code_0A8743
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8733
    BCC loc_0A86AB
    RTL 

  loc_0A86AB:
    COP [StageSpriteMoveX] ( #A1, #01 )
    COP [AnimOnce]

  loc_0A86B1:
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    BRA loc_0A86B1
} >
]

ec0F_sub_bat3 [
  actor-def < #1F, #00, #00, {

  code_0A86CE:
    JSR $&code_0A8743
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8733
    BCC loc_0A86DC
    RTL 

  loc_0A86DC:
    COP [StageSpriteLoopMoveX] ( #21, #02, #02 )
    COP [AnimLoop]

  loc_0A86E3:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #20, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A86E3
} >
]

ec0F_sub_bat4 [
  actor-def < #1F, #00, #00, {

  code_0A8702:
    JSR $&code_0A8743
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8733
    BCC loc_0A8710
    RTL 

  loc_0A8710:
    COP [StageSpriteLoopMoveX] ( #A1, #02, #01 )
    COP [AnimLoop]

  loc_0A8717:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #20, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    BRA loc_0A8717
} >
]

code_0A8733 {
    LDA $16
    SEC 
    SBC $playerYPos
    BPL loc_0A873F
    EOR #$FFFF
    INC 

  loc_0A873F:
    CMP #$003C
    RTS 
}

code_0A8743 {
    LDA #$0010
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetSpritePalette] ( #00 )
    COP [AddPosition] ( #08, #00 )
    RTS 
}

code_0A8753 {
    COP [Die]
}