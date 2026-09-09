!gfxCacheIdxB                   064A
!joypadCurrent                  0656
!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

gw8B_lance [
  actor-def < #05, #00, #10, {

  code_07B776:
    COP [BranchIfFlagByte] ( #C8, #01, &code_07B7FA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #17, #09, #1B, &code_07B789 )
    RTL 
} >
]

code_07B789 {
    COP [SpawnAfterFlags] ( @e_gw8B_lily, #$1000 )
    COP [SetOnInteract] ( &code_07B7FC )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #12, #17, #14, #1B, &code_07B7A3 )
    RTL 
}

code_07B7A3 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [FadeThenStartMusic] ( #15 )
    COP [WaitWord] ( #$0167 )
    COP [PrintWideString] ( &widestring_07B960 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07B9B1 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07BA2E )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveX] ( #09, #0A, #01 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #96 )
    COP [SetFlagByte] ( #C8 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #80, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_07B7FA {
    COP [Die]
}

code_07B7FC {
    COP [BranchIfFlagByte] ( #02, #01, &code_07B81F )
    COP [RemoveItem] ( #17 )
    COP [PrintWideString] ( &widestring_07B8AD )
    COP [SetFlagByte] ( #02 )
    LDA #$0200
    TSB $layerPriorityFlag
    LDA #$2000
    TSB $joypadMaskStd
    LDA #$2000
    TRB $joypadCurrent
    RTL 
}

code_07B81F {
    COP [PrintWideString] ( &widestring_07B8AD+M )
    RTL 
}
---------------------------------------------

widestring_07B824 `[TPL:A][TPL:2]Lilly:[N]You're crazy! I've[N]been worried sick![FIN]What if you'd been [N]attacked! [FIN][TPL:4]Lance: [N]Sorry to have [N]worried you. [FIN]But I got some medicine[N]to cure my father.[PAL:0][END]`

widestring_07B8AD `[TPL:A][TPL:4]Lance: [N]Oh. That stone . . . [FIN][TPL:0]Will: If you follow the [N]stone chips, the trail [N]leads here.[FIN]I'll give them back[N]to you. [WAI][CLD][PAU:3C][::][TPL:A][TPL:4][SFX:0][DLY:2]Lance whispers... [FIN]Lance: [N]Will...will you take [N]care of Lilly for me? [END]`

widestring_07B960 `[TPL:A][TPL:4][DLY:2]Lance:[N]I was saved thanks[N]to these stones...[FIN]This was the necklace [N]I made for you. [END]`

widestring_07B9B1 `[TPL:A][TPL:4]Lance: There aren't many [N]necklace stones left. [N]Will you take them? [FIN][SFX:0][TPL:6][DLY:2]Lance, fixing the [N]necklace, puts it [N]around her neck. [END]`

widestring_07BA2E `[TPL:A][TPL:4][DLY:0]Lance: Wow!! I've never [N][DLY:1]felt this way before![FIN]It's like a million [N]summer days! [FIN][TPL:2][DLY:1]Lilly:[N](Sob).[N]I feel the same way.[FIN]Let's go back to the[N]village. I'm sure[N]everyone's worried.[END]`
---------------------------------------------

e_gw8B_lily {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0068
    STA $moveXAlt, X
    LDA #$01A0
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_07B824 )
    COP [SetFlagByte] ( #01 )
    COP [SetOnInteract] ( &code_07BB84 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #28, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #24, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07BBB0 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07BC42 )
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_07BCAA )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteLoopMoveX] ( #29, #0A, #01 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_07BB84 {
    COP [PrintWideString] ( &widestring_07BB89 )
    RTL 
}

widestring_07BB89 `[TPL:A][TPL:2]Lilly:[N]Already? You're[N]selfish....[END]`

widestring_07BBB0 `[TPL:A][TPL:4][DLY:0]Lance: Aaah... [WAI][CLD][PAU:3C][TPL:A][TPL:2][DLY:2]Lilly: [N]I won't run this time. [FIN]This happened so [N]suddenly, I didn't know [N]what to do... [FIN]I don't want to show [N]my face now. [FIN]I'm crying[N]from happiness...[END]`

widestring_07BC42 `[TPL:A][TPL:2][DLY:2]Lilly: I've always felt[N]there was something[N]different about you.[FIN]Now I feel I know[N]what the difference is.[FIN]I want to give you[N]an answer...[END]`

widestring_07BCAA `[TPL:A][TPL:2]Lilly:[N][DLY:3]I love you, too.[FIN][DLY:2]I want to be with[N]you forever...[END]`