?INCLUDE 'chunk_3B7DD'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!playerWallType                 09B0
!playerSpeedEw                  09B2
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

h_ec11_voice [
  actor-def < #0F, #01, #01, {

  code_04F725:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  loc_04F73D:
    LDA #$00FF
    STA $currentHp, X

  code_04F744:
    COP [SetHitCallback] ( &code_04F752 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_04F744 )
} >
]

code_04F752 {
    LDA #$0200
    TSB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    BRA loc_04F73D
}

actor_def_04F768 [
  actor-def < #0F, #01, #01, {

  code_04F76B:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  code_04F783:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_04F796 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04F796 {
    LDA #$0200
    TSB $10
    COP [BranchIfFlagWord] ( #$0113, #01, &code_04F7BC )
    COP [BranchIfFlagByte] ( #02, #00, &code_04F7BC )
    COP [BranchIfFlagByte] ( #01, #01, &code_04F7D0 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04F7EF )
    COP [SetFlagByte] ( #03 )
    BRA loc_04F7C1
}

code_04F7BC {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]

  loc_04F7C1:
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    COP [SetEntryExitNow] ( @code_04F783 )
}

code_04F7D0 {
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageBgChange] ( #13 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0113 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [PrintWideString] ( &widestring_04F819 )
    COP [PlaySoundCh1] ( #16 )
    COP [SetEntryContinue]
    RTL 
}

widestring_04F7EF `[DEF][TPL:2]ちょっとぉ![N]同時に おさなきゃ ダメだって[N]言ったでしょ![FIN][JMP:&ec11_voice.widestring_04F8FC+M]`

widestring_04F819 `[PAU:1E][DEF][TPL:2]やったぁ![N]トビラが 開いたわよっ![FIN]さあ 先へ 行って![END]`

actor_def_04F841 [
  actor-def < #00, #00, #23, {

  code_04F844:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_04F8F9 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_04F857 )
    RTL 
} >
]

code_04F857 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04F8FC )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    LDA #$CFF0
    TRB $joypadMaskStd

  code_04F870:
    COP [SetEntryContinue]
    LDA #$2200
    STA $0E
    COP [LoopInit] ( #78 )
    COP [BranchIfFlagByte] ( #03, #01, &code_04F8F3 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopInit] ( #3C )
    COP [BranchIfFlagByte] ( #03, #01, &code_04F8F3 )
    JSR $&it1B_trial.code_04F977
    LDA #$0001
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [LoopInit] ( #78 )
    COP [BranchIfFlagByte] ( #03, #01, &code_04F8F3 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopInit] ( #3C )
    COP [BranchIfFlagByte] ( #03, #01, &code_04F8F3 )
    JSR $&it1B_trial.code_04F977
    LDA #$0002
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [LoopInit] ( #63 )
    COP [BranchIfFlagByte] ( #03, #01, &code_04F8F3 )
    COP [LoopNext]
    COP [SetFlagByte] ( #01 )
    COP [PlaySoundCh1] ( #11 )
    COP [LoopInit] ( #28 )
    COP [BranchIfFlagByte] ( #02, #00, &code_04F8F9 )
    JSR $&it1B_trial.code_04F977
    LDA #$0003
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [ClearFlagByte] ( #01 )
    COP [PrintWideString] ( &widestring_04F7EF )
}

code_04F8F3 {
    COP [ClearFlagByte] ( #03 )
    JMP $&code_04F870
}

code_04F8F9 {
    COP [SetEntryContinue]
    RTL 
}

widestring_04F8FC `[TPL:A][TPL:2][::]不思議な声:[N]このスイッチはね 2つ 同時に[N]おさないと トビラが開かないの.[FIN]あたしが かけ声をかけるから[N]それにあわせて スイッチを[N]おしてね.[FIN]1 2 3の タイミングだからね.[N]まちがえないでね.[END]`

code_04F977 {
    LDA $playerWallType
    CLC 
    ADC #$0007
    STA $14
    LDA $playerSpeedEw
    SEC 
    SBC #$0020
    STA $16
    RTS 
}