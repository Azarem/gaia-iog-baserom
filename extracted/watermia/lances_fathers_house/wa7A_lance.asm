!joypadMaskStd                  065A

---------------------------------------------

wa7A_lance [
  actor-def < #15, #00, #10, {

  code_07AAF8:
    COP [BranchIfFlagByte] ( #90, #01, &code_07AB69 )
    COP [SetOnInteract] ( &code_07AB6B )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    STZ $0688
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_07AB82 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_07AB6F )
    COP [ExitIfFlagByte] ( #90, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #07, #08, #0A, &code_07AB34 )
    RTL 
} >
]

code_07AB34 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_07AC08 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #16, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #11 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_07AB69 {
    COP [Die]
}

code_07AB6B {
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_07AB6F {
    COP [BranchIfFlagByte] ( #01, #01, &code_07AB7A )
    COP [PrintWideString] ( &widestring_07AB82 )
    RTL 
}

code_07AB7A {
    COP [PrintWideString] ( &widestring_07ABC4 )
    COP [SetFlagByte] ( #90 )
    RTL 
}

widestring_07AB82 `[TPL:A][TPL:4][SFX:1C]Lance: Will, do you [N]recognize this person? [FIN]He's my father.[PAL:0][END]`

widestring_07ABC4 `[TPL:A][TPL:4][SFX:1C]Lance: He seems to have [N]lost his memory.[FIN]I finally met my[N]lost father, but...[PAL:0][END]`

widestring_07AC08 `[TPL:A][TPL:4][SFX:1C]Lance: [N]Will, wait. [N]I'll go, too. [FIN]I'm preparing Lilly's[N]birthday party. I want[N]to finish by dark.[FIN]Let's go to our room.[PAL:0][END]`