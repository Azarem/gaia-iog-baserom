!displayModeFlags               09EC

---------------------------------------------

it19_inca_statue_a [
  actor-def < #00, #00, #30, {

  code_04F35C:
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04F373 )
    COP [ExitIfFlagByte] ( #2D, #01 )
    COP [StageBgChange] ( #1B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011B )
    COP [Die]
} >
]

code_04F373 {
    COP [GiveItem] ( #03, &code_04F388 )
    COP [SetFlagByte] ( #2D )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_04F38D )
    RTL 
}

code_04F388 {
    COP [PrintDialogString] ( &dialogstring_04F3A8 )
    RTL 
}

dialogstring_04F38D `[TPL:A][SFX:0][DLY:9]You've found[N]Incan Statue A.[PAU:FF][END]`

dialogstring_04F3A8 `[TPL:A]You've found Incan [N]Statue A! But your [N]inventory is full! [END]`