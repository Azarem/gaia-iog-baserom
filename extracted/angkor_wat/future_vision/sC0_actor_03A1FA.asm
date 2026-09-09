?INCLUDE 'oneshot_palette_flash_19'
?INCLUDE 'sFE_proc_03A940'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!INIDISP                        2100
!M7SEL                          211A
!TM                             212C
!CGWSEL                         2130
!CGADSUB                        2131
!animScratch2                   7F000E
!loopCounter                    7F0014

---------------------------------------------

sC0_actor_03A1FA [
  actor-def < #00, #00, #18, {

  code_03A1FD:
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    STZ $M7SEL
    LDA #$01
    STA $TM
    STA $CGADSUB
    LDA #$82
    STA $CGWSEL
    REP #$20
    COP [SpawnThinker] ( @sFE_proc_03A940.code_03A985 )
    PHX 
    TYX 
    LDA #$0804
    STA $animScratch2, X
    PLX 
    COP [SpawnBefore] ( @code_03A22E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_03A22E {
    LDA #$0800
    TSB $10
    LDA #$0170
    STA $cameraTargetX
    LDA #$01D0
    STA $cameraTargetY
    LDA #$01F0
    STA $00CA
    LDA #$0250
    STA $00CC
    LDA #$001C
    STA $00B8
    LDA #$0130
    STA $00BC
    COP [SpawnThinker] ( @oneshot_palette_flash_19.code_00B7D8 )
    COP [SetEntryContinue]
    INC $00BC
    LDA $0036
    AND #$0001
    BEQ loc_03A26A
    RTL 

  loc_03A26A:
    LDA $00B8
    CMP #$0080
    BEQ loc_03A277
    INC 
    STA $00B8
    RTL 

  loc_03A277:
    COP [SetEntryContinue]
    LDA $00BC
    AND #$01FF
    BEQ loc_03A285
    INC $00BC
    RTL 

  loc_03A285:
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    LDA $00B8
    CMP #$0060
    BEQ loc_03A2A6
    DEC 
    STA $00B8
    INC $00B6
    INC $cameraTargetY
    INC $cameraTargetY
    INC $00CC
    INC $00CC
    RTL 

  loc_03A2A6:
    COP [LoopInit] ( #FF )
    DEC $cameraTargetY
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #80 )
    DEC $cameraTargetY
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #7F )
    DEC $cameraTargetY
    DEC $00CC
    LDA $loopCounter, X
    AND #$0078
    LSR 
    LSR 
    LSR 
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [LoopNext]
    COP [QueueMapChange] ( #BF, #$00F8, #$00C0, #00, #$2200 )
    LDA #$0001
    STA $gfxCacheIdxA
    LDA #$0400
    STA $gfxCacheIdxB
    COP [SetEntryContinue]
    RTL 
}