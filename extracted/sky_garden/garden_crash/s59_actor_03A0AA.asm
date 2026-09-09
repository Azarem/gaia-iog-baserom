?INCLUDE 'sFE_proc_03A940'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!M7SEL                          211A
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!animScratch2                   7F000E
!moveScratch2                   7F002E

---------------------------------------------

s59_actor_03A0AA [
  actor-def < #00, #00, #18, {

  code_03A0AD:
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    STZ $M7SEL
    LDA #$01
    STA $TS
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
    COP [SpawnBefore] ( @code_03A120 )
    LDA $cameraTargetX
    CLC 
    ADC #$0080
    STA $14
    COP [StageSprAndHitbox] ( #04 )

  loc_03A0E7:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CLC 
    ADC #$00B4
    STA $16
    COP [BranchIfFlagByte] ( #01, #01, &code_03A109 )
    DEC $24
    BMI loc_03A107
    RTL 

  loc_03A107:
    BRA loc_03A0E7
} >
]

code_03A109 {
    COP [SetEntryExit]
    COP [LoopInit] ( #1E )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $cameraTargetY
    CLC 
    ADC #$00B4
    STA $16
    COP [LoopNext]
    COP [SetEntryContinue]
    RTL 
}

code_03A120 {
    LDA #$0800
    TSB $10
    LDA #$0258
    STA $24
    LDA $cameraTargetX
    CLC 
    ADC #$0080
    STA $00CA
    LDA #$0200
    STA $00B6
    LDA #$0032
    STA $00B8
    STZ $00BC
    COP [SetEntryContinue]
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    DEC $24
    BMI loc_03A15E
    RTL 

  loc_03A15E:
    COP [SetFlagByte] ( #01 )
    COP [LoopInit] ( #3C )
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    COP [LoopNext]
    COP [SpawnAfterFlags] ( @code_03A1E9, #$2000 )
    COP [InitGravity] ( #00, #05, #00 )
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    CMP #$0500
    BCS loc_03A1AF
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 

  loc_03A1AF:
    LDA #$0001
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #80, #$1100 )
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    LDA $cameraTargetY
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 
}

code_03A1E9 {
    COP [LoopInit] ( #06 )
    COP [RngByte]
    AND #$001C
    STA $08
    COP [PlaySoundCh1] ( #15 )
    COP [LoopNext]
    COP [Die]
}