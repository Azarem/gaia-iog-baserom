!sceneCurrent                   0644

---------------------------------------------

av70_hidden_passage [
  actor-def < #00, #00, #30, {

  code_06D5A1:
    LDA $sceneCurrent
    CMP #$0073
    BEQ loc_06D5C7
    COP [BranchIfFlagWord] ( #$0143, #01, &code_06D5C5 )
    COP [SetOnInteract] ( &code_06D5E5 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #43 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0143 )
} >
]

code_06D5C5 {
    COP [Die]

  loc_06D5C7:
    COP [BranchIfFlagWord] ( #$0144, #01, &code_06D5E3 )
    COP [SetOnInteract] ( &code_06D5E5 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #44 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0144 )
}

code_06D5E3 {
    COP [Die]
}

code_06D5E5 {
    COP [PrintDialogString] ( &dialogstring_06D5ED )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_06D5ED `[TPL:9][TPL:0]The wind blows through[N]a crack in the wall.[FIN]I found a hidden pass![PAL:0][END]`