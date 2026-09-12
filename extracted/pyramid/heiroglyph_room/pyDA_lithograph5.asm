?BANK 08

?INCLUDE 'pyDA_lithograph1'

!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph5 [
  actor-def < #00, #00, #30, {

  code_08CA47:
    COP [BranchIfFlagByte] ( #C6, #01, &code_08CA5E )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08CA65 )
    COP [ExitIfFlagByte] ( #C6, #01 )
} >
]

code_08CA5E {
    COP [StageBgChange] ( #98 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08CA65 {
    COP [BranchIfFlagByte] ( #C6, #01, &code_08CA83 )
    COP [PrintDialogString] ( &pyDA_lithograph1.dialogstring_08C7C9 )
    COP [GiveItem] ( #22, &pyDA_lithograph1.pyDA_lithograph_full )
    COP [SetFlagByte] ( #C6 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @pyDA_lithograph1.dialogstring_08C831 )
}

code_08CA83 {
    RTL 
}

