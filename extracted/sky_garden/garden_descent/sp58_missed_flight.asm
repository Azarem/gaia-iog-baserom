---------------------------------------------

sp58_missed_flight [
  actor-def < #03, #00, #18, {

  code_068003:
    LDA #$1000
    TSB $12
    LDA $0AA6
    BNE loc_068040
    LDA #$FFA4
    STA $14
    COP [StageSpriteLoopMoveX] ( #03, #2A, #01 )
    COP [AnimLoop]
    COP [SpawnAfterFlags] ( @code_068042, #$2000 )

  code_068020:
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_068020 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    LDA #$01C0
    STA $14

  loc_068038:
    COP [StageSpriteMoveX] ( #83, #02 )
    COP [AnimOnce]
    BRA loc_068038

  loc_068040:
    COP [Die]
} >
]

code_068042 {
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06805C )
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    CMP #$0120
    BCS loc_068056
    RTL 

  loc_068056:
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06805C `[TPL:A][TPL:6]Neil: [N]Shoot!! [N]I dropped a contact!! [FIN][TPL:1]Kara: You what!!! [N]Idiot! Will is [N]doomed for sure now! [FIN][TPL:4]Lance: Neil! It's still [N]a little ways to the [N]ground. Try again! [FIN][TPL:6]Neil: [N]Okay! [N]I'll get him this time!![PAL:0][END]`