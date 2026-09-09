---------------------------------------------

h_sc03_lances_mother [
  actor-def < #13, #00, #10, {

  code_048D80:
    COP [SetOnInteract] ( &code_048E0D )

  code_048D84:
    COP [StageSpriteMoveX] ( #18, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #17, #14 )
    COP [AnimOnce]
    LDA #$01B0
    STA $16
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #18, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #18, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #16, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #05, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    LDA #$0070
    STA $16
    COP [StageSpriteLoopMoveY] ( #16, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    JMP $&code_048D84
} >
]

code_048E0D {
    COP [PrintWideString] ( &widestring_048E12 )
    RTL 
}

widestring_048E12 `[DEF]ロブの母:[N]あなたのお父さんと うちの人が[N]バベルの塔で 行方不明になってから[N]もう 1年が たつんだねえ.[FIN]なんだか つい 昨日のような[N]気がするよ···[END]`