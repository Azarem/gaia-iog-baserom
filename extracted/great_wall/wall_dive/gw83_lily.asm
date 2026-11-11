; Lilly at the Great Wall dive entrance — cutscene when Will reaches the ledge.
; 
; Dies at spawn when flag $93 is set. Otherwise it watches for the player in tiles (3B,08)-(3D,0B). On entry it enters display-filter mode (displayModeFlags $0080), sets $93, locks the joypad ($EFFC), prints "Wait!", walks Lilly in (sprite loops #33) and then toward the player, prints "Are you looking for Lance? I'll go with you!" and her closing line, restores the joypad and display mode and dies. The actor sets no party or escort state; the only persistent effect is flag $93.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

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
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_07B6FF )
    COP [SetMetasprite] ( @spriteset_pickups_effects )
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
    LDA #$EFFC
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