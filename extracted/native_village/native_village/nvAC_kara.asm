?INCLUDE 'nv_actor_0881A5'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraBoundsY                  06DC
!playerActor                    09AA

---------------------------------------------

nvAC_kara [
  actor-def < #0C, #00, #10, {

  code_08805A:
    LDA #$0220
    STA $cameraBoundsY
    COP [BranchIfFlagByte] ( #B6, #01, &code_0880D4 )
    COP [BranchIfFlagByte] ( #CF, #01, &code_0880D4 )
    COP [BranchIfFlagByte] ( #B2, #01, &code_0881BE )
    COP [BranchIfFlagByte] ( #AF, #01, &code_088152 )
    COP [BranchIfFlagByte] ( #B0, #01, &code_0880D6 )
    COP [BranchIfFlagByte] ( #AD, #01, &code_0880D4 )
    COP [BranchIfFlagByte] ( #AC, #01, &code_0880B8 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0881E2 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #AC )
    COP [SetFlagByte] ( #01 )
    COP [StageSpriteLoopMoveXY] ( #10, #08, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #06, #02 )
    COP [AnimLoop]
} >
]

code_0880B8 {
    COP [SetTilePos] ( #0B, #0E )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0881D0 )
    COP [ExitIfFlagByte] ( #AD, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
}

code_0880D4 {
    COP [Die]
}

code_0880D6 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0882C7 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_088A60, #$0158, #$0040, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_088A90, #$0018, #$00C0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_088AAF, #$00B8, #$0180, #$1000 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PrintWideString] ( &widestring_08830F )
    COP [LoopInit] ( #02 )
    COP [WaitByte] ( #27 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [LoopNext]
    COP [WaitByte] ( #27 )
    COP [LoopInit] ( #04 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [WaitByte] ( #18 )
    COP [LoopNext]
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #AC, #$0080, #$00F0, #03, #$2200 )
    COP [SetFlagByte] ( #AF )
    COP [SetEntryContinue]
    RTL 
}

code_088152 {
    COP [SpawnAfterAbsFlags] ( @nv_actor_0881A5, #$0088, #$00FE, #$1002 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetTilePos] ( #06, #10 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08839D )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [PrintWideString] ( &widestring_0887C6 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [PrintWideString] ( &widestring_088811 )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @nv_actor_0881A5.code_0881AE, #$1002 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0881DD )
    COP [SetEntryContinue]
    RTL 
}
---------------------------------------------

code_0881BE {
    COP [SetTilePos] ( #12, #0C )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0881D8 )
    COP [SetEntryContinue]
    RTL 
}

code_0881D0 {
    COP [PrintWideString] ( &widestring_08826B )
    COP [SetFlagByte] ( #AD )
    RTL 
}

code_0881D8 {
    COP [PrintWideString] ( &widestring_0884A4 )
    RTL 
}

code_0881DD {
    COP [PrintWideString] ( &widestring_0884FB )
    RTL 
}

widestring_0881E2 `[TPL:A][TPL:1]Kara: [N]It's as hot as [N]the tropics... [FIN][TPL:3]Erik: [N]I see the world tilted, [N]my eyes blurred... [FIN][TPL:0]Will: There's nothing we [N]can do. Let's stay in [N]this village today.[PAL:0][END]`

widestring_08826B `[TPL:A][TPL:1]Kara: Strange. Not a [N]soul here, and skeletons[N]scattered around... [FIN]Should we go into[N]the houses?[PAL:0][END]`

widestring_0882C7 `[TPL:E][TPL:0]Exhausted from the[N]trip, they fall into[N]a deep sleep...[FIN]A long time passes...[PAL:0][END]`

widestring_08830F `[TPL:E][TPL:0][DLY:2]Will:[N]What... Hamlet... Let me[N]sleep a while longer...[FIN][TPL:1][DLY:1]Kara: Uhhn.... [N]What? Will... Don't [N]be so noisy...[FIN][CLD][PAU:3C][TPL:E][TPL:1][DLY:0]Kara: AH! [N]Who! Who are you?![PAL:0][END]`

widestring_08839D `[TPL:A][TPL:0][SFX:0]They seem to be [N]very hungry... [FIN][TPL:1][SFX:10]Kara: Look. Those [N]children look so upset... [FIN][TPL:0]Will: That's right... [N]The servant boy said [N]that in Freejia. [FIN]There's so much famine [N]in this country... [FIN][TPL:1]Kara: Those bones are the[N]bodies of people who've [N]starved to death. [FIN][TPL:3]Erik: [N]Oh, no! We'll be next!![PAL:0][END]`

widestring_0884A4 `[TPL:E][TPL:1]Kara: I learned a [N]word from the children. [FIN]It seems that (Ramapoe)[N]means (Hello)[N]in this region.[PAL:0][END]`

widestring_0884FB `[TPL:F][TPL:1]Kara: [N]He just jumped into [N]the fire... [FIN]Hamlet, noble pig... [N]I will miss you...[PAL:0][END]`
---------------------------------------------

widestring_0887C6 `[TPL:A][TPL:1][DLY:2]Kara: Hamlet... [N]Why such a sad look? [FIN]It's as if we will soon [N]be separated...[PAL:0][END]`

widestring_088811 `[TPL:A][TPL:1]Kara: [N]A-a-a-a-a-a!!!!! [FIN][DLY:0]Hamlet!! Hamlet!! [FIN][TPL:0][DLY:1]Will: [N]Hamlet... Why? [PAL:0][END]`
---------------------------------------------

code_088A60 {
    COP [StageSpriteLoopMoveX] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoopMoveX] ( #20, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #01 )
    COP [Die]
}

code_088A90 {
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteLoopMoveX] ( #21, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [Die]
}

code_088AAF {
    COP [StageSpriteLoopMoveY] ( #1F, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [Die]
}