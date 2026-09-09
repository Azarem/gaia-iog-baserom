!joypadMaskStd                  065A

---------------------------------------------

sc08_erik [
  actor-def < #0B, #00, #10, {

  code_048D98:
    COP [BranchIfFlagByte] ( #10, #01, &code_048DCF )
    COP [ExitIfFlagByte] ( #10, #01 )
    COP [StageSpriteLoop] ( #0C, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_048DD1 )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_048E00 )
    COP [StageSpriteMoveX] ( #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0F, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_048DCF {
    COP [Die]
}

widestring_048DD1 `[TPL:B][TPL:5]Seth:[N]I'll see you guys[N]at the usual place![PAL:0][END]`

widestring_048E00 `[TPL:B][TPL:3]Erik:[N]I have to go home[N]first. I'll see you guys[N]there later.[FIN]If you don't hurry home, [N]your mother will think [N]that you were kept after [N]school....Heh heh heh.[PAL:0][END]`