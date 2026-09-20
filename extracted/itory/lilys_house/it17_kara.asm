; Kara in Lily's house.
; 
; Multi-state dialog: comments on the village breeze, then
; insists on joining Will to see the Moon Tribe.
---------------------------------------------

---------------------------------------------

it17_kara [
  actor-def < #13, #00, #10, {

  code_04E1B6:
    COP [BranchOnFlagByte] ( #37, #01, &code_04E1EF )
    COP [SetInteractHandler] ( &code_04E1F1 )
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04E223 )
    COP [SetFlagByte] ( #02 )
    COP [WaitOnFlagByte] ( #02, #00 )
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
    COP [PrintDialogString] ( &dialogstring_04E1F6 )
    RTL 
}

dialogstring_04E1F6 `[TPL:A][TPL:1]Kara: It's a  [N]great village. The [N]breeze is refreshing.[PAL:0][END]`

dialogstring_04E223 `[TPL:A][TPL:1]Kara: I'm going, too! [N]I want to see [N]the Moon Tribe. [FIN]Since I escaped the[N]confinement of the[N]castle, [FIN]I want to[N]see and hear everything.[PAL:0][END]`