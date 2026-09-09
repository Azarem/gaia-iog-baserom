---------------------------------------------

it17_kara [
  actor-def < #13, #00, #10, {

  code_04E1B6:
    COP [BranchIfFlagByte] ( #37, #01, &code_04E1EF )
    COP [SetOnInteract] ( &code_04E1F1 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04E223 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #03 )
} >
]

code_04E1EF {
    COP [Die]
}

code_04E1F1 {
    COP [PrintWideString] ( &widestring_04E1F6 )
    RTL 
}

widestring_04E1F6 `[TPL:A][TPL:1]Kara: It's a  [N]great village. The [N]breeze is refreshing.[PAL:0][END]`

widestring_04E223 `[TPL:A][TPL:1]Kara: I'm going, too! [N]I want to see [N]the Moon Tribe. [FIN]Since I escaped the[N]confinement of the[N]castle, [FIN]I want to[N]see and hear everything.[PAL:0][END]`