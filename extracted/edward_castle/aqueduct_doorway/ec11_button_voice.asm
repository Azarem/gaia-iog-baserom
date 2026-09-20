; Mysterious voice at the aqueduct doorway buttons.
; 
; Multi-phase dialog: instructs Will to push switches simultaneously,
; counts down, and announces when the door opens.
---------------------------------------------

?BANK 09

?INCLUDE 'ec11_countdown'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

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
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]

  code_09BCEC:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_09BCFF )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
} >
]

code_09BCFF {
    LDA #$0200
    TSB $10
    COP [BranchOnFlagWord] ( #$0113, #01, &code_09BD25 )
    COP [BranchOnFlagByte] ( #02, #00, &code_09BD25 )
    COP [BranchOnFlagByte] ( #01, #01, &code_09BD39 )
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
    COP [JumpNextFrame] ( @code_09BCEC )
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
    COP [SetEntryHere]
    RTL 
}

dialogstring_09BD58 `[DEF][TPL:2]Wait! I told you,[N]you have to push them[N]at the same time![FIN][JMP:&ec11_countdown.dialogstring_09BE70+M]`

dialogstring_09BD92 `[PAU:1E][DEF][TPL:2]Stop![N]The door is open!![FIN]Go in!![END]`