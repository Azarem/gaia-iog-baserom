!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

pyCD_kara [
  actor-def < #03, #00, #30, {

  code_08BD33:
    COP [BranchIfFlagByte] ( #D0, #01, &code_08BE0D )
    COP [ExitIfFlagByte] ( #C2, #01 )
    COP [ExitIfFlagByte] ( #C3, #01 )
    COP [ExitIfFlagByte] ( #C4, #01 )
    COP [ExitIfFlagByte] ( #C5, #01 )
    COP [ExitIfFlagByte] ( #C6, #01 )
    COP [ExitIfFlagByte] ( #C7, #01 )
    COP [BranchIfFlagByte] ( #BB, #01, &code_08BE0F )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$0800
    TSB $10
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #09, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [WaitByte] ( #0F )
    COP [LoopInit] ( #06 )
    COP [StageSpriteMoveX] ( #09, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$000A
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BE66 )
    COP [WaitByte] ( #3B )
    LDA #$0068
    STA $moveXAlt, X
    LDA #$00B0
    STA $moveYAlt, X
    COP [MoveToward] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BEA9 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_08BE61 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08BE0D {
    COP [Die]
}

code_08BE0F {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #08, #0B )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08BE61 )
    COP [ExitIfFlagByte] ( #FC, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08BFC7 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_08C127 )
    COP [SetFlagByte] ( #D0 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #C8, #$0070, #$00A0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_08BE61 {
    COP [PrintWideString] ( &widestring_08BF8F )
    RTL 
}

widestring_08BE66 `[TPL:9][TPL:1][DLY:2]Kara: [N]Will... [FIN]Why must everyone[N]hate each other...?[FIN]I...[N][PAU:3C]I...[PAL:0][END]`

widestring_08BEA9 `[TPL:A][TPL:1][DLY:0]Kara: [N]I'm sorry... [N]I got upset... [FIN]You are doing your [N]best to save the world.[FIN]At first I just wanted[N]to find my father...[FIN]But somehow it got[N]to be a trial.....[FIN]But me.[N]I don't regret coming[N]on this journey...[FIN]Let's go and [N]find the fifth [N]Mystic Statue...[PAL:0][END]`

widestring_08BF8F `[TPL:B][TPL:1]Kara:[N]The melody you played[N]became the Jackal's[N]dirge.[PAL:0][END]`

widestring_08BFC7 `[TPL:A]I heard a voice from the[N]Flute! [FIN]The same voice I[N]heard in the prison[N]at Edward Castle...[FIN][TPL:4][DLY:1]Flute: [N]Will. You've done well to [N]have come this far. [FIN][TPL:0]Will: [N]Father?! [FIN][TPL:4]Flute:[N]I'm at the Tower now.[FIN]Bring the five Mystic [N]Statues to the Tower. [FIN]The statues you've [N]collected hold the key [N]to the fate of humanity. [FIN]Will..Hurry...The comet[N]is approaching. [FIN][PAL:0][SFX:0]The voice of the Flute[N]quiets and disappears.[PAL:0][END]`

widestring_08C127 `[TPL:B][TPL:1]Kara: It seems [N]something terrible has [N]happened that [N]we don't know about... [FIN][TPL:0]Will: What to do... [N]I was told to go to the [N]Tower of Babel, but [N]that little island... [FIN][TPL:1]Kara: [N]I hear Neil has built [N]another airplane. [FIN]It seems he's flying to [N]the desert town. Let's [N]go back there.[PAL:0][END]`