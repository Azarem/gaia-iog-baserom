; Lilly at the Great Wall dive entrance — offers to accompany Will.
; 
; Lilly calls: "Wait!" Then: "Are you looking for Lance? I'll go
; with you!" Story moment where Lilly joins as companion for
; the Great Wall dungeon. Sets escort flag and manages
; the party transition.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!joypadMaskStd                  065A
!playerActor                    09AA
!displayModeFlags               09EC
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw83_lily [
  actor-def < #00, #00, #30, {

  code_07B67A:
    COP [BranchOnFlagByte] ( #93, #01, &code_07B6FD )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #3B, #08, #3D, #0B, &code_07B68B )
    RTL 
} >
]

code_07B68B {
    LDA #$0080
    TSB $displayModeFlags
    COP [SetFlagByte] ( #93 )
    LDA #$2000
    TRB $10
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_07B6FF )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteLoopMoveX] ( #33, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #33, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #33, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #33, #13 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_07B709 )
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07B731 )
    LDA #$EFF0
    TRB $joypadMaskStd
    LDA #$0080
    TRB $displayModeFlags
}

code_07B6FD {
    COP [Die]
}

dialogstring_07B6FF `[TPL:C][TPL:2]Wait![END]`

dialogstring_07B709 `[TPL:D][TPL:2]Lilly: [N]Are you looking for Lance?[FIN]I'll go with you![END]`

dialogstring_07B731 `[TPL:E][TPL:2]Lilly: Ha ha. It's been [N]a long time since I [N]borrowed Will's pocket. [FIN]Well, let's go.[END]`