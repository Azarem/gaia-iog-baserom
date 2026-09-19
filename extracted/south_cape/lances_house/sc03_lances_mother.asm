; Lance's frail mother NPC.
; 
; Multi-state dialog gated by story progression. Initially speaks
; about Will's father being lost at the Tower of Babel. Dialog
; changes as the story progresses.
---------------------------------------------

---------------------------------------------

sc03_lances_mother [
  actor-def < #13, #00, #10, {

  code_048E87:
    COP [SetOnInteract] ( &code_048F14 )

  code_048E8B:
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
    JMP $&code_048E8B
} >
]

code_048F14 {
    COP [PrintDialogString] ( &dialogstring_048F19 )
    RTL 
}

dialogstring_048F19 `[DEF]Lance's mother: Your[N]father has been lost at[N]the Tower of Babel[N]for a year now...[FIN]It seems like[N]only yesterday...[END]`