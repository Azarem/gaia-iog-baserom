; Zip Fly enemy — fast darting insect in Angkor Wat (~337 lines).
; 
; Extremely fast flying enemy with erratic flight patterns.
; Darts at the player in quick bursts, pauses briefly, then
; darts again. Difficult to hit due to speed. Complex
; directional AI with random movement variation.
---------------------------------------------

---------------------------------------------

awB0_zip_fly [
  actor-def < #00, #00, #00, {

  code_0BAF52:
    COP [SetSpritePriority] ( #30 )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    STZ $24

  loc_0BAF63:
    COP [BranchIfOffscreen] ( &code_0BAF71 )
    COP [WaitWhileOffscreen] ( #0F )

  code_0BAF6A:
    LDA $10
    BIT #$4000
    BNE loc_0BAF63
} >
]

code_0BAF71 {
    COP [SetSavedPtr] ( &code_0BAF6A )
    LDA $24
    INC 
    STA $24
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BAF88 )
}

code_list_0BAF88 [
  &code_0BAF98   ;00
  &code_0BAFBF   ;01
  &code_0BB00D   ;02
  &code_0BAFE6   ;03
  &code_0BB034   ;04
  &code_0BB06B   ;05
  &code_0BB0A1   ;06
  &code_0BB0DA   ;07
]

code_0BAF98 {
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCS code_0BAFBF
    COP [StageSpriteLoopMoveX] ( #02, #04, #08 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFBD
    STZ $24
    COP [StageSpriteLoop] ( #07, #0A )
    COP [AnimLoop]
    JMP $&code_0BB113

  loc_0BAFBD:
    COP [RestoreSavedPtr]
}

code_0BAFBF {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCC code_0BAF98
    COP [StageSpriteLoopMoveX] ( #82, #04, #07 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFE4
    STZ $24
    COP [StageSpriteLoop] ( #07, #0A )
    COP [AnimLoop]
    JMP $&code_0BB113

  loc_0BAFE4:
    COP [RestoreSavedPtr]
}

code_0BAFE6 {
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCS code_0BB00D
    COP [StageSpriteLoopMoveY] ( #01, #04, #08 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFE4
    STZ $24
    COP [StageSpriteLoop] ( #06, #0A )
    COP [AnimLoop]
    JMP $&code_0BB113
}

code_0BB00B {
    COP [RestoreSavedPtr]
}

code_0BB00D {
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCC code_0BAFE6
    COP [StageSpriteLoopMoveY] ( #00, #04, #07 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB032
    STZ $24
    COP [StageSpriteLoop] ( #05, #0A )
    COP [AnimLoop]
    JMP $&code_0BB113

  loc_0BB032:
    COP [RestoreSavedPtr]
}

code_0BB034 {
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCC code_0BB00D
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCC loc_0BB04F
    JMP $&code_0BAFBF

  loc_0BB04F:
    COP [StageSpriteLoopMoveXY] ( #03, #04, #06, #05 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB069
    STZ $24
    COP [StageSpriteLoop] ( #08, #0A )
    COP [AnimLoop]
    JMP $&code_0BB113

  loc_0BB069:
    COP [RestoreSavedPtr]
}

code_0BB06B {
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCS code_0BB00D
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCC loc_0BB086
    JMP $&code_0BAFBF

  loc_0BB086:
    COP [StageSpriteLoopMoveXY] ( #04, #04, #06, #06 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB09F
    STZ $24
    COP [StageSpriteLoop] ( #09, #0A )
    COP [AnimLoop]
    BRA code_0BB113

  loc_0BB09F:
    COP [RestoreSavedPtr]
}

code_0BB0A1 {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCS loc_0BB0B0
    JMP $&code_0BAF98

  loc_0BB0B0:
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCS loc_0BB0BF
    JMP $&code_0BAFE6

  loc_0BB0BF:
    COP [StageSpriteLoopMoveXY] ( #83, #04, #05, #05 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB0D8
    STZ $24
    COP [StageSpriteLoop] ( #88, #0A )
    COP [AnimLoop]
    BRA code_0BB113

  loc_0BB0D8:
    COP [RestoreSavedPtr]
}

code_0BB0DA {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCS loc_0BB0E9
    JMP $&code_0BAF98

  loc_0BB0E9:
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCC loc_0BB0F8
    JMP $&code_0BB00D

  loc_0BB0F8:
    COP [StageSpriteLoopMoveXY] ( #84, #04, #05, #06 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB111
    STZ $24
    COP [StageSpriteLoop] ( #89, #0A )
    COP [AnimLoop]
    BRA code_0BB113

  loc_0BB111:
    COP [RestoreSavedPtr]
}

code_0BB113 {
    COP [BranchIfPlayerNear] ( #04, &code_0BB11A )
    COP [RestoreSavedPtr]
}

code_0BB11A {
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB128 )
}

code_list_0BB128 [
  &code_0BB138   ;00
  &code_0BB147   ;01
  &code_0BB157   ;02
  &code_0BB166   ;03
  &code_0BB176   ;04
  &code_0BB185   ;05
  &code_0BB195   ;06
  &code_0BB1A4   ;07
]

code_0BB138 {
    COP [StageSpriteLoop] ( #01, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #01, #06, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB147 {
    COP [StageSpriteLoop] ( #84, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #84, #06, #05, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB157 {
    COP [StageSpriteLoop] ( #82, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #82, #06, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB166 {
    COP [StageSpriteLoop] ( #83, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #83, #06, #05, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB176 {
    COP [StageSpriteLoop] ( #00, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #00, #06, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB185 {
    COP [StageSpriteLoop] ( #03, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #03, #06, #06, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB195 {
    COP [StageSpriteLoop] ( #02, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #06, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB1A4 {
    COP [StageSpriteLoop] ( #04, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #04, #06, #06, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}