?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'player_transition_handlers'

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

dc31_kara [
  actor-def < #2D, #00, #10, {

  code_05AF88:
    COP [BranchIfFlagByte] ( #56, #01, &code_05B007 )
    COP [SetOnInteract] ( &code_05B016 )
    COP [BranchIfFlagByte] ( #76, #01, &code_05B009 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #31, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05ADAE )
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C46D
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C46D
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0000
    JSL $@InitPlayerScriptVariant
    COP [WaitByte] ( #3B )
    LDA #$0002
    JSL $@InitPlayerScriptVariant
    COP [WaitByte] ( #13 )
    COP [PrintDialogString] ( &dialogstring_05AE00 )
    COP [SetFlagByte] ( #02 )

  loc_05AFE7:
    COP [ExitIfFlagByte] ( #56, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #30, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2E, #04, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05B007 {
    COP [Die]
}

code_05B009 {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SolidHighHere]
    BRA loc_05AFE7
}

code_05B016 {
    COP [PrintDialogString] ( &dialogstring_05AF2F )
    COP [SetFlagByte] ( #56 )
    RTL 
}
---------------------------------------------

dialogstring_05ADAE `[TPL:E][TPL:1]Kara: [N]Will! Will!! [N]Wake up! ! ! [FIN]We've reached land!![N]We're saved!!![FIN][TPL:0]Will: [N]Uhhh...[PAL:0][END]`

dialogstring_05AE00 `[TPL:E][TPL:0]Will: Kara...? [N]Where am I...? [FIN][TPL:1]Kara: [N]We're at the home of the [N]kind man who saved us. [FIN]You've been tossing[N]in your sleep.[FIN]I kept putting the[N]blankets on you, but[N]you threw them off.[PAL:0][END]`
---------------------------------------------

dialogstring_05AF2F `[TPL:A][TPL:1]Kara: At any rate, [N]let's go to Freejia. [FIN]I'm going to thank the[N]dog. Come back[N]when you're ready.[PAL:0][END]`