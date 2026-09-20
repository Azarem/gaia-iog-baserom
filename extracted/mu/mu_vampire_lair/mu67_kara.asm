; Kara in the vampire lair — pragmatic about escaping.
; 
; Says: "It doesn't matter! Let's think about how to leave Mu!"
; Focused on survival rather than the drama. Brief NPC
; during the vampire lair escape.
---------------------------------------------

!gfxCacheIdxB                   064A

---------------------------------------------

mu67_kara [
  actor-def < #1B, #00, #30, {

  code_06A849:
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [WaitByte] ( #1D )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06A894 )
    LDA #$0000
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0070, #$00C0, #00, #$1200 )
    COP [SetEntryContinue]
    RTL 
} >
]

dialogstring_06A894 `[TPL:B][TPL:1]Kara: [N]It doesn't matter! [FIN]Let's think about how[N]to leave Mu![FIN][TPL:2]Lilly: That's good. We[N]heard some things from[N]someone called Rama.[FIN][TPL:0]Will told everyone about [N]Mu and the people [N]who had come through [N]the underwater tunnel... [FIN][TPL:1]Kara: [N]It's such a sad story... [FIN]separated from those [N]with whom they lived.[FIN]Others remaining under[N]water... [FIN][TPL:6]Neil: If we go through [N]the tunnel, maybe we[N]can reach the mainland.[FIN][TPL:4]Lance: Good idea! [N]Let's get out of here!![PAL:0][END]`