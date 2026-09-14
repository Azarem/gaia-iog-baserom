?INCLUDE 'enemy_stats_table'
?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!playerFlags                    09AE
!displayModeFlags               09EC
!jewelsCollected                0AB0
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dm40_trapped_slave [
  actor-def < #00, #00, #01, {

  code_05D739:
    COP [BranchIfFlagByte] ( #D9, #01, &code_05D796 )
    COP [SpawnAfterFlags] ( @code_05D7CB, #$1000 )
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12

  loc_05D760:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_05D782
    COP [BranchIfPlayerInAbsTiles] ( #08, #14, #0A, #17, &code_05D77E )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_05D77E {
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_05D782:
    LDA $playerFlags
    BIT #$0002
    BNE loc_05D78F
    DEC $24
    BMI loc_05D760
    RTL 

  loc_05D78F:
    COP [SpawnAfterFlags] ( @SpawnDebrisBurst, #$3000 )
}

code_05D796 {
    COP [SetFlagByte] ( #D9 )
    COP [DrawMetatileAbs] ( #08, #11, #D5 )
    COP [DrawMetatileAbs] ( #09, #11, #D4 )
    COP [DrawMetatileAbs] ( #08, #12, #EC )
    COP [DrawMetatileAbs] ( #09, #12, #DC )
    COP [DrawMetatileAbs] ( #08, #13, #F4 )
    COP [DrawMetatileAbs] ( #09, #13, #E4 )
    COP [DrawMetatileAbs] ( #08, #14, #02 )
    COP [DrawMetatileAbs] ( #09, #14, #02 )
    COP [SolidHighAbs] ( #08, #13 )
    COP [SolidHighAbs] ( #09, #13 )
    COP [Die]
}

code_05D7CB {
    COP [AddPosition] ( #08, #00 )
    LDA #$2000
    TSB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #D9, #01 )
    LDA #$2000
    TRB $10
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0003
    STA $jewelsCollected
    CLD 
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [ClearFlagByte] ( #00 )
    COP [PrintDialogString] ( &dialogstring_05D819 )
    LDA #$EFF0
    TRB $joypadMaskStd
    LDA #$0080
    TSB $displayModeFlags
    COP [StageSpriteLoopMoveY] ( #0D, #08, #01 )
    COP [AnimLoop]
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}

dialogstring_05D819 `[DEF]Thank you.[N]I was buried in[N]the cave-in...[FIN]What would happen if[N]we took longer...[FIN]We want to give you a[N]present. I'm sending 3[N]Red Jewels to[N]the Jeweler.[END]`