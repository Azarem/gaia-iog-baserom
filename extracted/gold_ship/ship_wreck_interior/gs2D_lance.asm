; Lance on the Gold Ship interior — triggers a cutscene on approach.
; 
; Before flag $01: positioned at tile (0F, 0D) facing south with
; ClearLowHere. When player is within 3 tiles, triggers a cutscene
; with camera_drift screen shake. Uses joypadMaskStd for joypad
; locking during the scene. After flag $01: solid with interaction.
---------------------------------------------

?INCLUDE 'camera_drift'

!joypadMaskStd                  065A

---------------------------------------------

gs2D_lance [
  actor-def < #03, #00, #10, {

  code_058FC3:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_059028 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [SetTilePos] ( #0F, #0D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #03, &code_058FE0 )
    RTL 
} >
]

code_058FE0 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_05913D )
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_059157 )
    COP [SetFlagByte] ( #51 )
    COP [SetInteractHandler] ( #$0000 )
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #02 )
    COP [AnimOnce]
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [Die]
}

code_059028 {
    COP [PrintDialogString] ( &dialogstring_05902D )
    RTL 
}

dialogstring_05902D `[TPL:A][TPL:4]Lance: You were acting[N]strange, so we [N]followed you. [FIN]Then we reached[N]a strange town...[FIN][TPL:2]Lilly: Wait. Don't call [N]it strange. I [N]was born there. [FIN][TPL:4]Lance: [N]It's invisible. [FIN]I'd call that pretty[N]strange. [FIN]Will. You can't [N]go on a journey [N]without telling us. [FIN]Since we're friends, we [N]have to share good times [N]and bad.[PAL:0][END]`

dialogstring_05913D `[TPL:A][TPL:4]Lance: [N]Are you OK?[PAL:0][END]`

dialogstring_059157 `[TPL:8][TPL:5]Wa-a-a-a--a-ah!!!![FIN][TPL:9][TPL:4]Lance: That's Seth! It's [N]coming from the deck![PAL:0][END]`