---------------------------------------------

dc30_dog [
  actor-def < #48, #00, #10, {

  code_05AA6F:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05AA89 )
    COP [SolidHighHere]

  loc_05AA7A:
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoop] ( #48, #10 )
    COP [AnimLoop]
    BRA loc_05AA7A
} >
]

code_05AA89 {
    COP [PrintDialogString] ( &dialogstring_05AA91 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05AA91 `[DEF]Woof woof!![END]`