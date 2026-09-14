?BANK 09

?INCLUDE 'ec11_countdown'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec11_button_voice [
  actor-def < #0F, #01, #01, {

  code_09BCD4:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  code_09BCEC:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_09BCFF )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_09BCFF {
    LDA #$0200
    TSB $10
    COP [BranchIfFlagWord] ( #$0113, #01, &code_09BD25 )
    COP [BranchIfFlagByte] ( #02, #00, &code_09BD25 )
    COP [BranchIfFlagByte] ( #01, #01, &code_09BD39 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_09BD58 )
    COP [SetFlagByte] ( #03 )
    BRA loc_09BD2A
}

code_09BD25 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]

  loc_09BD2A:
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    COP [SetEntryExitNow] ( @code_09BCEC )
}

code_09BD39 {
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageBgChange] ( #13 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0113 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [PrintDialogString] ( &dialogstring_09BD92 )
    COP [PlaySoundCh1] ( #16 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_09BD58 `[DEF][TPL:2]Wait! I told you,[N]you have to push them[N]at the same time![FIN][JMP:&ec11_countdown.dialogstring_09BE70+M]`

dialogstring_09BD92 `[PAU:1E][DEF][TPL:2]Stop![N]The door is open!![FIN]Go in!![END]`