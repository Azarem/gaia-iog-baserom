; Controller of the arrival cutscene at the Angel Village entrance (scene $69); the actor prints Neil's and Lance's lines.
; 
; The actor dies at spawn when flag $8D (the Watermia arrival has started) or flag $75 (this cutscene was shown) is set. Otherwise it locks the joypad ($CFFC), prints 'Neil: We're here at last...' and 'Lance: Look! A sign!', walks, prints the sign discussion, and sets scratch flag $01 (Lilly, Neil and Erik walk). It then waits for scratch $04 (the end of the Lilly/Kara exchange), sets persistent flag $75, walks to its final position and unlocks the joypad.
; 
; The chain of scratch flags is $01 Lance, $02 Lilly, $03 Kara, $04 Lilly; the other four av69 actors run the same two death tests.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

av69_lance [
  actor-def < #03, #00, #10, {

  code_06BA88:
    COP [BranchOnFlagByte] ( #8D, #01, &av69_lance_destroy )
    COP [BranchOnFlagByte] ( #75, #01, &av69_lance_destroy )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06BAFA )
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06BB50 )
    COP [SetFlagByte] ( #01 )
    COP [StageSpriteLoop] ( #05, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [SetFlagByte] ( #75 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #13 )
    COP [AnimLoop]
} >
]

av69_lance_destroy {
    COP [Die]
}

dialogstring_06BAFA `[TPL:B][TPL:6]Neil: We're here [N]at last. We've walked[N]through the tunnel for[N]almost a month... [FIN][TPL:4]Lance: [N]Look! A sign![PAL:0][END]`

dialogstring_06BB50 `[TPL:A][TPL:4]Lance: What? [N]Angel Tribe? Travellers, [N]please use this room?[FIN][TPL:6]Neil: Angels living [N]in a place like this? [FIN][TPL:6]Neil: They say angels [N]don't like meeting [N]with people. [FIN]First we can rest in[N]that room...[PAL:0][END]`