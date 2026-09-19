?INCLUDE 'mode7_perspective'
?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'pr_thinkers'

!gfxCacheIdxB                   064A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!M7SEL                          211A
!animScratch2                   7F000E

---------------------------------------------

pr8C_prologue5 [
  actor-def < #00, #00, #38, {

  code_0BCE7C:
    COP [BranchIfFlagByte] ( #F4, #01, &code_0BCEBB )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0038, #$0038, #$2000 )
    LDA #$&spritestring_0BD272
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    SEP #$20
    STZ $M7SEL
    REP #$20
    COP [SpawnThinker] ( @mode7_perspective.Mode7PerspectiveUpdate )
    TXA 
    TYX 
    TAY 
    LDA #$0804
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SpawnBeforeFlags] ( @code_0BCEBD, #$2800 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BCEBB {
    COP [Die]
}

code_0BCEBD {
    LDA #$0200
    STA $00B6
    LDA #$0020
    STA $00B8
    STZ $00BC
    LDA #$0280
    STA $cameraTargetX
    LDA #$0300
    STA $cameraTargetY
    LDA #$0300
    STA $00CA
    LDA #$0380
    STA $00CC
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CMP #$0040
    BEQ loc_0BCF00
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0080
    STA $00CC
    RTL 

  loc_0BCF00:
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CMP #$FFD8
    BEQ loc_0BCF1F
    SEC 
    SBC #$0001
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0080
    STA $00CC
    DEC $00B6
    RTL 

  loc_0BCF1F:
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #82 )
    DEC $00B6
    COP [LoopNext]
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    COP [LoopInit] ( #64 )
    DEC $00B6
    COP [LoopNext]
    LDA #$0008
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    DEC $00B6
    BEQ loc_0BCF4F
    RTL 

  loc_0BCF4F:
    COP [SetEntryContinue]
    RTL 
}
---------------------------------------------

spritestring_0BD272 ~No one thought[N]these ruins would[N]bring about[N]disaster...~