!gfxCacheIdxB                   064A

---------------------------------------------

wa79_lily [
  actor-def < #22, #00, #10, {

  code_07A870:
    COP [BranchIfFlagByte] ( #97, #01, &code_07A904 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A8F3 )
    COP [BranchIfFlagByte] ( #91, #01, &code_07A8F1 )
    COP [SetOnInteract] ( &code_07A915 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoop] ( #24, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #0C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #28 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07A974 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [PrintWideString] ( &widestring_07A9F2 )
    COP [StageSpriteLoopMoveX] ( #29, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #26, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07AA09 )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #26, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #27, #11 )
    COP [AnimOnce]
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #7F, #$02E0, #$00B0, #00, #$4500 )
} >
]

code_07A8F1 {
    COP [Die]
}

code_07A8F3 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A91A )
    COP [SetEntryContinue]
    RTL 
}

code_07A904 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A91F )
    COP [SetEntryContinue]
    RTL 
}

code_07A915 {
    COP [PrintWideString] ( &widestring_07A92F )
    RTL 
}

code_07A91A {
    COP [PrintWideString] ( &widestring_07AA34 )
    RTL 
}

code_07A91F {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07A92A )
    COP [PrintWideString] ( &widestring_07AA5E )
    RTL 
}

code_07A92A {
    COP [PrintWideString] ( &widestring_07AAA3 )
    RTL 
}

widestring_07A92F `[TPL:A][TPL:2][SFX:19]Lilly: I heard that [N]Lance saw someone he [N]knew in town. [FIN]I guess he went to[N]look for him.[END]`

widestring_07A974 `[TPL:A][TPL:2]Lilly: What?[N]Everybody remembered[N]my birthday?[FIN][TPL:3]Erik:[N]Didn't you expect it?[FIN]Everybody kept it secret[N]to surprise you.[FIN][TPL:6]Neil: Hey Kara. [N]Bring that.[PAL:0][END]`

widestring_07A9F2 `[TPL:A][TPL:2]Lilly: Huh? [N]I wonder what? [END]`

widestring_07AA09 `[TPL:A][TPL:2]Lilly: [N]Excuse me everyone. [N]I'll be right back.. [END]`

widestring_07AA34 `[TPL:A][TPL:2]Lilly: [N]I hope Lance's father [N]recovers quickly.[PAL:0][END]`

widestring_07AA5E `[TPL:A][TPL:2]Lilly: I decided to stay[N]in this town, too.[FIN]Ask Lance [N]the reason why.[PAL:0][END]`

widestring_07AAA3 `[TPL:A][TPL:2]Lilly:[N]Rumor is we're going to[N]collide with a big star.[FIN]I don't believe[N]rumors like that.[PAL:0][END]`