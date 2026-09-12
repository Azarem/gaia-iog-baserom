?INCLUDE 'EscortFollowPathTracker'

!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

btE3_kara [
  actor-def < #1C, #00, #03, {

  code_098518:
    COP [BranchIfFlagByte] ( #D4, #01, &btE3_kara_destroy )
    COP [BranchIfPlayerAt] ( #$0080, #$01A0, &code_098529 )
    JMP $&btE3_kara_destroy
} >
]

code_098529 {
    COP [AddPosition] ( #08, #00 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_098577 )
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
    LDA #$1000
    TRB $10
    LDA #$0B00
    TSB $10
    COP [SetFlagByte] ( #D4 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

dialogstring_098577 `[TPL:A][TPL:0]Will: [N]Kara! [N]Where did you go?! [FIN][TPL:1]Kara: There was talk [N]that the vampire [N]woman had come... [FIN]They say that her body [N]is eternal... [FIN]They say that once the[N]comet is gone,[FIN]she'll be able to[N]rest in peace.[END]`
---------------------------------------------

btE3_kara_destroy {
    COP [Die]
}