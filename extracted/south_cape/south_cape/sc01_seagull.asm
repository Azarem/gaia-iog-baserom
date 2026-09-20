; Animated seagull actor that flies back and forth across South Cape.
; 
; Randomly picks a Y height and direction (left or right), then loops
; a 3-pass flying animation pattern with sprite movement. Purely
; cosmetic ambient decoration.
---------------------------------------------

---------------------------------------------

sc01_seagull [
  actor-def < #23, #00, #18, {

  code_048007:
    LDA #$0200
    TSB $12
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )

  code_048011:
    COP [SetEntryHere]
    COP [RngByte]
    STA $08
    PHA 
    AND #$001F
    CLC 
    ADC #$0010
    ASL 
    ASL 
    ASL 
    ASL 
    STA $16
    PLA 
    AND #$0001
    BNE loc_04802E
    JMP $&code_048069

  loc_04802E:
    LDA #$0320
    STA $14
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )
    COP [StageSpriteLoopMoveXY] ( #23, #20, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveXY] ( #24, #04, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #24, #04, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #24, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #23, #18, #04, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #23, #18, #04, #11 )
    COP [AnimLoop]
    COP [LoopEnd]
    JMP $&code_048011
} >
]

code_048069 {
    LDA #$FFE0
    STA $14
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )
    COP [StageSpriteLoopMoveXY] ( #23, #20, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveXY] ( #24, #03, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #24, #03, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #24, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #23, #18, #03, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #23, #18, #03, #11 )
    COP [AnimLoop]
    COP [LoopEnd]
    JMP $&code_048011
}

code_0480A4 {
    COP [PlaySoundCh1] ( #18 )
    RTL 
}