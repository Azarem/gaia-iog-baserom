?INCLUDE 'func_06B9F2'

---------------------------------------------

av6C_villagers5 [
  actor-def < #0A, #00, #10, {

  code_06CD4A:
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_06CD7A )
    LDA #$0200
    TSB $12

  loc_06CD57:
    COP [StageSpriteLoopMoveX] ( #10, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #04, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #14 )
    COP [AnimLoop]
    BRA loc_06CD57
} >
]

code_06CD7A {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06CD85 )
}

code_list_06CD85 [
  &code_06CD8B   ;00
  &code_06CD90   ;01
  &code_06CD95   ;02
]

code_06CD8B {
    COP [PrintDialogString] ( &dialogstring_06CD9A )
    RTL 
}

code_06CD90 {
    COP [PrintDialogString] ( &dialogstring_06CDD4 )
    RTL 
}

code_06CD95 {
    COP [PrintDialogString] ( &dialogstring_06CE56 )
    RTL 
}

dialogstring_06CD9A `[TPL:A]I dance to remember [N]what it feels like to be [N]human. But... [END]`

dialogstring_06CDD4 `[TPL:B]We are expressionless,[N]but Ishtar painted us[N]with faces overflowing[N]with human kindness.[FIN]After that, people [N]wanting to be painted [N]flocked here. [END]`

dialogstring_06CE56 `[TPL:A]I used to dance with the [N]person in that picture. [END]`