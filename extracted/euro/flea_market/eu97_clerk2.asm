?INCLUDE 'EscortFollowPathTracker'

!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

eu97_clerk2 [
  actor-def < #2C, #00, #03, {

  code_07CC3C:
    COP [BranchIfPlayerAt] ( #$0170, #$00D0, &code_07CC86 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #30, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07CC88 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$002A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
} >
]

code_07CC86 {
    COP [Die]
}

widestring_07CC88 `[TPL:A]Clerk: [N]Aren't you Neil, [N]from this village?! [FIN]Rolek manages this[N]store, too.[FIN]I understand.[N]Please take whatever[N]you like.[END]`