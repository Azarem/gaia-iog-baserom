?INCLUDE 'EscortFollowPathTracker'
?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A
!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

btDF_kara [
  actor-def < #1A, #00, #30, {

  code_099E8F:
    COP [BranchIfFlagByte] ( #D4, #01, &code_099EA0 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #70, #09, #72, #0D, &code_099EA2 )
    RTL 
} >
]

code_099EA0 {
    COP [Die]
}

code_099EA2 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_099F1B )
    LDA #$0003
    JSL $@InitPlayerScriptVariant
    COP [SetTilePos] ( #75, #09 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_099F2A )
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$0010
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #20, #01 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #77 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetFlagByte] ( #D4 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

dialogstring_099F1B `[TPL:A][TPL:1]Wait....[PAL:0][END]`

dialogstring_099F2A `[TPL:B][TPL:0][DLY:0]Will: [N]Kara!!!? [FIN][TPL:1]Kara: I'm sorry. [N]I just feel that, if [N]we part now, we'll [N]never meet again... [FIN][TPL:0]Will: [N]But Kara, why have you [N]come here? [FIN]You can't come here[N]unless you have the[N]Crystal Ring...[FIN][TPL:1]Kara: Could that [N]be the ring... [N]Didn't you find it [N]in the Incan Gold Ship? [FIN][TPL:0]This Crystal Ring is[N]dark blue...[FIN]The ring you have is[N]light blue...[FIN]A light one[N]and a dark one...[FIN]Will: I understand.. [N]No matter what happens, [N]don't leave me.[PAL:0][END]`