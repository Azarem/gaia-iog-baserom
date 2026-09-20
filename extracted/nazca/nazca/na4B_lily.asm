; Lilly at Nazca — wonders about the ancient builders.
; 
; Extended NPC (~110 lines). "The ancients were amazing. I wonder
; why they made this..." Later: "Doesn't there seem to be a
; pattern in the way the rocks are scattered around?" Lilly
; provides the clue for the puzzle solution.
---------------------------------------------

?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A

---------------------------------------------

na4B_lily [
  actor-def < #23, #00, #10, {

  code_05EFEC:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F0B6 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #26, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F0BB )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #10, #09 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F0B6 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_05F148 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #08 )
    LDA #$0002
    JSL $@InitPlayerScriptVariant
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05F160 )
    COP [SetFlagByte] ( #0A )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F0C3 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #07, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #29, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #0D, #01 )
    COP [StageSpriteMoveX] ( #29, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F0B6 {
    COP [PrintDialogString] ( &dialogstring_05F0C8 )
    RTL 
}

code_05F0BB {
    COP [PrintDialogString] ( &dialogstring_05F0FE )
    COP [SetFlagByte] ( #07 )
    RTL 
}

code_05F0C3 {
    COP [PrintDialogString] ( &dialogstring_05F1C3 )
    RTL 
}

dialogstring_05F0C8 `[DEF][TPL:2]Lilly: The ancients were[N]amazing. I wonder why[N]they made this...[PAL:0][END]`

dialogstring_05F0FE `[DEF][TPL:2]Lilly: Doesn't there[N]seem to be a pattern in[N]the way the rocks are[N]scattered around?[PAL:0][END]`

dialogstring_05F148 `[DEF][TPL:2]Lilly: Aaaah![N]I've got it!!![END]`

dialogstring_05F160 `[PAU:28][DEF][TPL:2][DLY:0]Look! Look where the[N]rocks are on the ground![FIN]They're positioned like[N]the stars in the[N]constellation of Cygnus![PAL:0][END]`

dialogstring_05F1C3 `[DEF][TPL:2]Lilly: A riddle[N]in a constellation.[N]Kind of romantic.[PAL:0][END]`