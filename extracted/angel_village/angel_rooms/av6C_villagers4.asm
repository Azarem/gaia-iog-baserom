?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

av6C_villagers4 [
  actor-def < #02, #00, #10, {

  code_06CA13:
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_06CA43 )
    LDA #$0200
    TSB $12

  loc_06CA20:
    COP [StageSpriteLoopMoveX] ( #09, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #04, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #14 )
    COP [AnimLoop]
    BRA loc_06CA20
} >
]

code_06CA43 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06CA4E )
}

code_list_06CA4E [
  &code_06CA52   ;00
  &code_06CA57   ;01
]

code_06CA52 {
    COP [PrintDialogString] ( &dialogstring_06CA5C )
    RTL 
}

code_06CA57 {
    COP [PrintDialogString] ( &dialogstring_06CA71 )
    RTL 
}

dialogstring_06CA5C `[TPL:A]People here love[N]to dance.[END]`

dialogstring_06CA71 `[TPL:A]The picture on that wall[N]was painted by Ishtar.[FIN]But the model in the [N]painting was lost. [END]`