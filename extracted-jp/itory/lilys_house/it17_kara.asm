---------------------------------------------

h_it17_kara [
  actor-def < #13, #00, #10, {

  code_04DAEC:
    COP [BranchIfFlagByte] ( #37, #01, &code_04DB25 )
    COP [SetOnInteract] ( &code_04DB27 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04DB5B )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #03 )
} >
]

code_04DB25 {
    COP [Die]
}

code_04DB27 {
    COP [PrintWideString] ( &widestring_04DB2C )
    RTL 
}

widestring_04DB2C `[TPL:A][TPL:1]カレン:[N]しゃくだけど すてきな村ね.[N]風がさわやかで きもちいい···[PAL:0][END]`

widestring_04DB5B `[TPL:A][TPL:1]カレン:[N]あたしも いくっ![N]月の種族って 見てみたいわ.[FIN]せっかく きゅうくつなお城を[N]ぬけだせたんですもの.[N]何でも 見たり聞いたりしたいの.[PAL:0][END]`