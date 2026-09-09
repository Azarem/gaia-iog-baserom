?BANK 08

?INCLUDE 'pyDA_lithograph1'

!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph2 [
  actor-def < #00, #00, #30, {

  code_08C84F:
    COP [BranchIfFlagByte] ( #C3, #01, &code_08C866 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C86D )
    COP [ExitIfFlagByte] ( #C3, #01 )
} >
]

code_08C866 {
    COP [StageBgChange] ( #95 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C86D {
    COP [BranchIfFlagByte] ( #C3, #01, &code_08C88B )
    COP [PrintWideString] ( &pyDA_lithograph1.widestring_08C7C9 )
    COP [GiveItem] ( #1F, &pyDA_lithograph1.pyDA_lithograph_full )
    COP [SetFlagByte] ( #C3 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @pyDA_lithograph1.widestring_08C831 )
}

code_08C88B {
    RTL 
}

