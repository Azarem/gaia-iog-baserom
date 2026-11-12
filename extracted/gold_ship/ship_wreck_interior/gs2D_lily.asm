; Lilly in the wrecked Gold Ship interior (scene $2D) — wakes Will, then reacts to the Queen's ring.
; 
; Flag $50 clear (first visit): sets $50, sets the joypad lock ($CFFC), holds Will in player_transition_handlers.PlayerPoseHold, waits 30 ticks (WaitByte #1D), prints 'Will! Wake up!', waits 60 ticks (WaitByte #3B), returns Will to player_character.PlayerIdleEntry, releases the joypad lock ($EFFC) and falls into code_058CFF. Flag $50 set: starts at code_058CFF.
; 
; code_058CFF: waits for scratch flag $01 (set by gs2D_mummy's first talk), is placed at tile (1D,0D) and walks, waits for scratch flag $02 (set by gs2D_mummy's dialog), prints the ring dialog, starts music #1B, shakes the camera three times with camera_drift (CameraDriftLoopShip), prints Kara's 'What?', starts music #06, sets musicRoomGroup to 1, installs the talk handler code_058DB6 and releases the joypad lock ($EFFC). From then on each frame it tests RngByte AND $E0 and, when the result is not zero, stores it in $08 and spawns another camera shake. The talk handler before the ring dialog is code_058DB1.
---------------------------------------------

?INCLUDE 'camera_drift'
?INCLUDE 'player_character'
?INCLUDE 'player_transition_handlers'

!joypadMaskStd                  065A
!musicRoomGroup                 06F6
!playerActor                    09AA

---------------------------------------------

gs2D_lily [
  actor-def < #23, #00, #18, {

  code_058CA5:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_058DB1 )
    COP [BranchOnFlagByte] ( #50, #01, &code_058CFF )
    COP [SetFlagByte] ( #50 )
    LDA #$CFFC
    TSB $joypadMaskStd
    LDY $playerActor
    LDA #$*player_transition_handlers.PlayerPoseHold
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerPoseHold
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_058DBB )
    COP [WaitByte] ( #3B )
    LDY $playerActor
    LDA #$*player_character.PlayerIdleEntry
    STA $0002, Y
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]

code_058CFF {
    LDA #$0800
    TSB $10
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [SetTilePos] ( #1D, #0D )
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #26, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    LDA #$0800
    TRB $10
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [PrintDialogString] ( &dialogstring_058E4A )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    COP [LoopStart] ( #02 )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #17 )
    COP [LoopEnd]
    COP [PrintDialogString] ( &dialogstring_058F44 )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [WaitByte] ( #77 )
    LDA #$0001
    STA $musicRoomGroup
    COP [SetInteractHandler] ( &code_058DB6 )
    LDA #$EFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    COP [RngByte]
    AND #$00E0
    BNE loc_058D9D
    RTL 

  loc_058D9D:
    STA $08
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    RTL 
}

code_058DB1 {
    COP [PrintDialogString] ( &dialogstring_058DDA )
    RTL 
}

code_058DB6 {
    COP [PrintDialogString] ( &dialogstring_058F53 )
    RTL 
}

dialogstring_058DBB `[TPL:A][TPL:2]Lilly: [N]Will! [FIN]Will! Wake up![PAL:0][END]`

dialogstring_058DDA `[TPL:A][TPL:2]Lilly: You're back so[N]late, the Elder must[N]have read your fortune.[FIN]He said that you were [N]floating alone on the [N]sea. I was so surprised.[PAL:0][END]`

dialogstring_058E4A `[TPL:B][TPL:2]Lilly: That ring must[N]be one of the artifacts[N]put on this ship.[FIN]This is the most valuable [N]of all the artifacts. [FIN][TPL:1]Kara: Many people [N]have lost their lives [N]trying to get rich [N]by finding this ring. [FIN]I want the ring. [N]It's so pretty. I [N]really must have it. [FIN][TPL:2]Lilly: Have you[N]no shame!?!?[N]You could be cursed!!![PAL:0][END]`

dialogstring_058F44 `[TPL:9][TPL:1]Kara: [N]What?[PAL:0][END]`

dialogstring_058F53 `[TPL:B][TPL:2]Lilly: [N]Maybe it belongs to[N]Riverson! [FIN]In this part of the [N]ocean, there are fish [N]that are as dangerous [N]as, well, sharks!![PAL:0][END]`