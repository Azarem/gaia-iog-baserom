; Full lily pad in Watermia — static platform.
; 
; Non-interactive lily pad decoration on the water surface.
; Visual element of Watermia's water-town aesthetic.
---------------------------------------------

?INCLUDE 'wa78_men'

---------------------------------------------

wa78_full_pad [
  actor-def < #1F, #01, #10, {

  code_079B8B:
    COP [SpawnAfterFlags] ( @wa78_men.code_078504, #$1000 )
    LDA #$0048
    STA $0014, Y
    LDA #$0004
    STA $000E, Y
    COP [AddPosition] ( #08, #00 )

  code_079BA2:
    COP [LoopInit] ( #B0 )
    COP [StageSpriteMoveX] ( #1F, #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    LDY $06
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    COP [LoopInit] ( #B0 )
    COP [StageSpriteMoveX] ( #1F, #02 )
    COP [AnimOnce]
    LDY $06
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    COP [StageSpriteMoveY] ( #1F, #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JMP $&code_079BA2
} >
]