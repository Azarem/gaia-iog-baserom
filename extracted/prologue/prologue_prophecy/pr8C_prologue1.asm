?INCLUDE 'pr_actor_0BCF52'
?INCLUDE 'pr_thinkers'
?INCLUDE 'sFE_proc_03A940'

!gfxCacheIdxB                   064A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!M7SEL                          211A
!animScratch2                   7F000E

---------------------------------------------

pr8C_prologue1 [
  actor-def < #00, #00, #38, {

  code_0BCA05:
    LDA #$0800
    STA $gfxCacheIdxB
    COP [BranchIfFlagByte] ( #F4, #00, &code_0BCAAF )
    COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$016E, #$03E8, #$1800 )
    COP [WaitByte] ( #00 )
    COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$0166, #$041A, #$1800 )
    COP [WaitByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$01A4, #$03F0, #$1800 )
    COP [WaitByte] ( #00 )
    COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$01A0, #$040C, #$1800 )
    COP [WaitByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$01D2, #$03FC, #$1800 )
    SEP #$20
    STZ $M7SEL
    REP #$20
    COP [SpawnThinker] ( @sFE_proc_03A940.code_03A985 )
    TXA 
    TYX 
    TAY 
    LDA #$0804
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SpawnBeforeFlags] ( @code_0BCABF, #$2800 )
    COP [SpawnAfterAbsFlags] ( @pr_actor_0BCF52.code_0BCF8F, #$0038, #$0030, #$2000 )
    LDA #$&spritestring_0BD044
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [WaitWord] ( #$01DF )
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @pr_actor_0BCF52.code_0BCF8F, #$003C, #$0020, #$2000 )
    LDA #$&spritestring_0BD06D
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BCAAF {
    COP [Die]
}

code_0BCAB1 {
    COP [StageSpriteMoveX] ( #8B, #11 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_0BCAB1 )
    COP [Die]
}

code_0BCABF {
    LDA #$03FC
    STA $24
    LDA #$0000
    STA $cameraTargetX
    LDA #$0360
    STA $cameraTargetY
    LDA #$0080
    STA $00CA
    LDA #$03E0
    STA $00CC
    LDA #$0280
    STA $00B6
    LDA #$0020
    STA $00B8
    STZ $00BC
    COP [SetEntryContinue]
    LDA $cameraTargetX
    INC 
    AND #$03FF
    STA $cameraTargetX
    CLC 
    ADC #$0080
    STA $00CA
    DEC $24
    BMI loc_0BCB03
    RTL 

  loc_0BCB03:
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    INC $00BC
    DEC $00B6
    LDA $00B6
    CMP #$0180
    BEQ loc_0BCB1C
    CMP #$00D0
    BEQ loc_0BCB22
    RTL 

  loc_0BCB1C:
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    RTL 

  loc_0BCB22:
    COP [ClearFlagByte] ( #F4 )
    LDA #$0808
    STA $gfxCacheIdxB
    COP [ClearFlagWord] ( #$017C )
    COP [ClearFlagWord] ( #$017D )
    COP [ClearFlagWord] ( #$017E )
    COP [ClearFlagWord] ( #$017F )
    COP [QueueMapChange] ( #8D, #$0000, #$0000, #00, #$4400 )
    COP [SetEntryContinue]
    DEC $00B6
    INC $00BC
    RTL 
}
---------------------------------------------

spritestring_0BD044 ~The world was in[N]an age of [N]exploration.~

spritestring_0BD06D ~Looking for new[N]lands,[N]man uncovered the[N]relics of ancient[N]cultures.~